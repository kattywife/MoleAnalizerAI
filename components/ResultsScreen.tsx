
import React from 'react';
import type { DiagnosisResult } from '../types';
import { UI_TEXT, MELANOMA_LOW_THRESHOLD, MELANOMA_HIGH_THRESHOLD } from '../constants';
import { Button } from './common/Button';
import { Card } from './common/Card';

interface ResultsScreenProps {
  imagePreviewUrl: string;
  imageName: string;
  analysisResults: DiagnosisResult[];
  melanomaRiskPercent: number;
  onBack: () => void;
  onFinishAnalysis: () => void;
}

const getRiskLevel = (percentage: number): { text: string; colorClass: string; bgColorClass: string } => {
  if (percentage < MELANOMA_LOW_THRESHOLD) {
    return { text: "Low", colorClass: "text-green-600", bgColorClass: "bg-green-100" };
  } else if (percentage <= MELANOMA_HIGH_THRESHOLD) {
    return { text: "Medium", colorClass: "text-yellow-600", bgColorClass: "bg-yellow-100" };
  } else {
    return { text: "High", colorClass: "text-red-600", bgColorClass: "bg-red-100" };
  }
};

export const ResultsScreen: React.FC<ResultsScreenProps> = ({
  imagePreviewUrl,
  imageName,
  analysisResults,
  melanomaRiskPercent,
  onBack,
  onFinishAnalysis,
}) => {
  const melanomaRisk = getRiskLevel(melanomaRiskPercent);

  return (
    <Card className="p-0 flex flex-col overflow-hidden flex-grow">
      <div className="flex flex-col md:flex-row flex-grow">
        {/* Left Panel: Image */}
        <div className="md:w-1/2 p-4 md:p-6 border-b md:border-b-0 md:border-r border-gray-200 flex flex-col items-center justify-center">
          <div className="w-full max-w-xs sm:max-w-sm md:max-w-md lg:max-w-lg aspect-square rounded-lg overflow-hidden mb-2 sm:mb-3 shadow">
            <img src={imagePreviewUrl} alt="Analyzed mole" className="w-full h-full object-cover" />
          </div>
          <p className="text-xs sm:text-sm text-gray-600 italic mb-3 sm:mb-4 text-center">{UI_TEXT.originalImage} {imageName}</p>
          <Button onClick={onBack} variant="outline" className="w-full max-w-xs sm:w-auto text-sm sm:text-base py-2">
            <i className="fas fa-arrow-left mr-1.5 sm:mr-2"></i>
            {UI_TEXT.backButton}
          </Button>
        </div>

        {/* Right Panel: Results */}
        <div className="md:w-1/2 p-4 md:p-6 flex flex-col flex-grow justify-center">
          <div className={`p-2 sm:p-3 rounded-md mb-4 sm:mb-6 text-center ${melanomaRisk.bgColorClass}`}>
            <span className={`text-2xl sm:text-3xl font-bold ${melanomaRisk.colorClass}`}>
              {melanomaRiskPercent.toFixed(1)}%
            </span>
            <p className={`text-base sm:text-lg font-medium ${melanomaRisk.colorClass}`}>
              {UI_TEXT.melanomaRiskText(melanomaRisk.text)}
            </p>
          </div>

          <div className="mb-2 sm:mb-3 flex justify-between items-center text-xs sm:text-sm font-semibold text-gray-600">
            <span className="min-w-[6rem] sm:min-w-[7rem] md:min-w-[8.5rem] text-left pr-2">{UI_TEXT.probability}</span>
            <span className="flex-grow text-left pl-1 sm:pl-2">{UI_TEXT.diagnosis}</span>
          </div>
          
          <div className="space-y-1.5 sm:space-y-2 mb-4 sm:mb-6 flex-grow overflow-y-auto pr-1 sm:pr-2 max-h-[35vh] sm:max-h-[40vh] md:max-h-[calc(100vh-420px)] min-h-[120px] sm:min-h-[150px]">
            {analysisResults.length > 0 ? analysisResults.map((result) => (
              <div key={result.code} className="flex items-center justify-between p-1.5 sm:p-2 bg-gray-50 rounded-md hover:bg-gray-100 transition-colors">
                <span className="inline-block text-xs sm:text-sm md:text-base font-bold text-red-700 bg-white border-2 border-red-700 rounded-full px-2.5 sm:px-3 md:px-4 py-1 text-center min-w-[6rem] sm:min-w-[7rem] md:min-w-[8.5rem]">
                  {(result.probability * 100).toFixed(1)}%
                </span>
                <span className="text-xs sm:text-sm text-gray-700 text-left pl-2 sm:pl-3 flex-shrink min-w-0 flex-grow">{result.name}</span>
              </div>
            )) : (
              <p className="text-gray-500 text-sm">No detailed diagnosis results available.</p>
            )}
          </div>
          
          <div className="mt-auto space-y-2 sm:space-y-3 pt-2 sm:pt-4">
            <Button onClick={onFinishAnalysis} variant="primary" className="w-full text-sm sm:text-base py-2 sm:py-2.5">
              <i className="fas fa-check-circle mr-1.5 sm:mr-2"></i>
              {UI_TEXT.finishAnalysisButton}
            </Button>
          </div>
        </div>
      </div>
    </Card>
  );
};
