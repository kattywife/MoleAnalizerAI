
import React, { useState, useCallback } from 'react';
import { Header } from './components/Header';
import { ImageUploadScreen } from './components/ImageUploadScreen';
import { ResultsScreen } from './components/ResultsScreen';
import { analyzeImageWithGemini, fileToGenerativePart } from './services/geminiService';
import type { DiagnosisResult, GeminiApiResponse } from './types';
import { DIAGNOSIS_CLASSES, UI_TEXT, MODEL_NAME } from './constants';

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

  const resetToUploadScreen = useCallback(() => {
    setCurrentView(View.Upload);
    setUploadedImageFile(null);
    setUploadedImagePreview(null);
    setAnalysisResults(null);
    setMelanomaRiskPercent(null);
    setError(null);
    setIsLoading(false);
  }, []);

  const handleImageUpload = useCallback(async (file: File) => {
    if (!process.env.API_KEY) {
        setError(UI_TEXT.noApiKey);
        setIsLoading(false);
        return;
    }
    setIsLoading(true);
    setError(null);
    setUploadedImageFile(file);
    setUploadedImagePreview(URL.createObjectURL(file));

    try {
      const imagePart = await fileToGenerativePart(file);
      
      const prompt = `You are a dermatological AI assistant. Analyze the provided image of a skin mole.
Return a JSON object with estimated probabilities for the following skin conditions.
The keys in the JSON object should be the short codes: ${Object.keys(DIAGNOSIS_CLASSES).join(', ')}.
The values should be probabilities as numbers between 0 and 1 (e.g., 0.87 for 87%).
Example JSON format:
{
  "MEL": 0.01,
  "NV": 0.87,
  "BCC": 0.43,
  "AK": 0.10,
  "BKL": 0.23,
  "DF": 0.14,
  "VASC": 0.05
}
Ensure the output is ONLY the JSON object. Do not include any other text or markdown formatting.`;

      const rawResults = await analyzeImageWithGemini(prompt, imagePart);

      const parsedResults: DiagnosisResult[] = [];
      let melRisk = 0;

      for (const key in rawResults) {
        if (Object.prototype.hasOwnProperty.call(DIAGNOSIS_CLASSES, key)) {
          const code = key as keyof typeof DIAGNOSIS_CLASSES;
          const probability = rawResults[code] ?? 0;
          parsedResults.push({
            code: code,
            name: DIAGNOSIS_CLASSES[code].name,
            probability: probability,
          });
          if (code === 'MEL') {
            melRisk = probability * 100;
          }
        }
      }
      
      // Sort results by probability, descending
      parsedResults.sort((a, b) => b.probability - a.probability);

      setAnalysisResults(parsedResults);
      setMelanomaRiskPercent(melRisk);
      setCurrentView(View.Results);
    } catch (err) {
      console.error("Analysis error:", err);
      let errorMessage = UI_TEXT.geminiError;
      if (err instanceof Error) {
        errorMessage = `${UI_TEXT.errorPrefix} ${err.message}`;
      }
      setError(errorMessage);
    } finally {
      setIsLoading(false);
    }
  }, []);

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
          <ImageUploadScreen onAnalyze={handleImageUpload} isLoading={isLoading} />
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
    </div>
  );
};

export default App;
