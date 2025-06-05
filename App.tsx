
import React, { useState, useCallback } from 'react';
import { Header } from './components/Header';
import { ImageUploadScreen } from './components/ImageUploadScreen';
import { ResultsScreen } from './components/ResultsScreen';
import { Modal } from './components/common/Modal';
import { analyzeImageWithLocalApi } from './services/localApiService'; // Updated import
import type { DiagnosisResult, GeminiApiResponse } from './types';
import { DIAGNOSIS_CLASSES, UI_TEXT } from './constants';

enum View {
  Upload,
  Results,
}

const App: React.FC = () => {
  const [currentView, setCurrentView] = useState<View>(View.Upload);
  const [uploadedImageFile, setUploadedImageFile] = useState<File | null>(null);
  const [uploadedImagePreview, setUploadedImagePreview] = useState<string | null>(null);
  const [analysisResults, setAnalysisResults] = useState<DiagnosisResult[] | null>(null);
  const [melanomaRiskPercent, setMelanomaRiskPercent] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [showNotAMoleModal, setShowNotAMoleModal] = useState<boolean>(false);

  const resetToUploadScreen = useCallback(() => {
    setCurrentView(View.Upload);
    setUploadedImageFile(null);
    setUploadedImagePreview(null);
    setAnalysisResults(null);
    setMelanomaRiskPercent(null);
    setError(null);
    setIsLoading(false);
    setShowNotAMoleModal(false);
  }, []);

  const handleImageUpload = useCallback(async (file: File) => {
    setIsLoading(true);
    setError(null);
    setUploadedImageFile(file);
    setUploadedImagePreview(URL.createObjectURL(file));

    try {
      // Call the new local API service
      const rawResults: GeminiApiResponse = await analyzeImageWithLocalApi(file);

      if (rawResults.is_mole === false) {
        setIsLoading(false);
        setShowNotAMoleModal(true);
        // Do not clear uploadedImageFile here, allow it to be cleared in closeNotAMoleModal or if a new upload starts
        return;
      }

      const parsedResults: DiagnosisResult[] = [];
      let melRisk = 0;
      const predictionScores = rawResults.predictions;

      if (!predictionScores || typeof predictionScores !== 'object') {
        console.error("API Response 'predictions' field is missing or not an object:", rawResults);
        throw new Error("The 'predictions' field is missing or invalid in the API response.");
      }
      
      for (const diagnosisCode in DIAGNOSIS_CLASSES) {
        if (Object.prototype.hasOwnProperty.call(DIAGNOSIS_CLASSES, diagnosisCode)) {
          const code = diagnosisCode as keyof typeof DIAGNOSIS_CLASSES;
          const diagnosisInfo = DIAGNOSIS_CLASSES[code];
          const diagnosisNameKey = diagnosisInfo.name;
          const probability = predictionScores[diagnosisNameKey] ?? 0;
          
          parsedResults.push({
            code: code,
            name: diagnosisInfo.name,
            probability: probability,
          });

          if (diagnosisNameKey === 'Melanoma') {
            melRisk = probability * 100;
          }
        }
      }
      
      parsedResults.sort((a, b) => b.probability - a.probability);

      setAnalysisResults(parsedResults);
      setMelanomaRiskPercent(melRisk);
      setCurrentView(View.Results);
    } catch (err) {
      console.error("Analysis error:", err);
      let errorMessage = UI_TEXT.localApiError; // Updated error message
      if (err instanceof Error) {
        errorMessage = err.message.startsWith("Failed to analyze image with local API:") 
            ? err.message 
            : `${UI_TEXT.errorPrefix} ${err.message}`;
      }
      setError(errorMessage);
      // Keep uploaded image preview even on error, so user sees what failed.
      // Cleared on "Back" or new upload.
    } finally {
      setIsLoading(false);
    }
  }, []);

  const closeNotAMoleModal = () => {
    setShowNotAMoleModal(false);
    setUploadedImageFile(null); 
    setUploadedImagePreview(null);
    if (currentView !== View.Upload) {
        setCurrentView(View.Upload);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-rose-50 text-gray-800">
      <Header />
      <main className="flex-grow container mx-auto p-3 sm:p-4 md:p-6 lg:p-8 flex flex-col">
        {error && (
          <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded" role="alert">
            {error}
          </div>
        )}
        {currentView === View.Upload && (
          <ImageUploadScreen 
            onAnalyze={handleImageUpload} 
            isLoading={isLoading}
          />
        )}
        {currentView === View.Results && uploadedImagePreview && analysisResults && melanomaRiskPercent !== null && uploadedImageFile && (
          <div className="flex flex-col flex-grow"> 
            <ResultsScreen
              imagePreviewUrl={uploadedImagePreview}
              imageName={uploadedImageFile.name}
              analysisResults={analysisResults}
              melanomaRiskPercent={melanomaRiskPercent}
              onBack={resetToUploadScreen}
              onFinishAnalysis={resetToUploadScreen}
            />
          </div>
        )}
      </main>
      <footer className="text-center p-3 sm:p-4 text-xs sm:text-sm text-gray-500">
        SkinSight &copy; {new Date().getFullYear()} - For informational purposes only. Consult a medical professional for diagnosis.
      </footer>

      <Modal
        isOpen={showNotAMoleModal}
        onClose={closeNotAMoleModal}
        title={UI_TEXT.notAMoleModalTitle}
      >
        {UI_TEXT.notAMoleModalMessage}
      </Modal>
    </div>
  );
};

export default App;
