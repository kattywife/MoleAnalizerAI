
import React, { useState, useCallback, useRef } from 'react';
import { UI_TEXT } from '../constants';
import { Button } from './common/Button';
import { Spinner } from './common/Spinner';

interface ImageUploadScreenProps {
  onAnalyze: (file: File) => void;
  isLoading: boolean;
}

export const ImageUploadScreen: React.FC<ImageUploadScreenProps> = ({ onAnalyze, isLoading }) => {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [fileError, setFileError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
    setFileError(null);
    const file = event.target.files?.[0];
    if (file) {
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
      if (!allowedTypes.includes(file.type)) {
        setFileError(UI_TEXT.fileTypeNotSupported);
        setSelectedFile(null);
        setPreviewUrl(null);
        if (fileInputRef.current) fileInputRef.current.value = ""; // Reset file input
        return;
      }
      setSelectedFile(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  }, []);

  const handleAnalyzeClick = useCallback(() => {
    if (selectedFile) {
      onAnalyze(selectedFile);
    }
  }, [selectedFile, onAnalyze]);

  const triggerFileInput = () => {
    fileInputRef.current?.click();
  };

  return (
    <div className="flex flex-col items-center justify-center p-4 sm:p-6 bg-white shadow-xl rounded-lg border border-sky-200 w-full max-w-sm sm:max-w-md md:max-w-lg lg:max-w-xl mx-auto">
      <h2 className="text-xl sm:text-2xl font-semibold text-gray-700 mb-4 sm:mb-6 text-center">{UI_TEXT.uploadPrompt}</h2>
      
      <div className="w-full mb-4 sm:mb-6">
        <input
          type="file"
          accept="image/jpeg, image/png, image/webp"
          onChange={handleFileChange}
          className="hidden"
          ref={fileInputRef}
          disabled={isLoading}
        />
        <Button 
          onClick={triggerFileInput} 
          variant="secondary" 
          className="w-full py-2.5 sm:py-3 text-sm sm:text-base"
          disabled={isLoading}
        >
          <i className="fas fa-cloud-upload-alt mr-2"></i>
          <span className="truncate">{selectedFile ? selectedFile.name : UI_TEXT.selectImageButton}</span>
        </Button>
        {fileError && <p className="text-red-500 text-xs sm:text-sm mt-1 sm:mt-2">{fileError}</p>}
      </div>

      {previewUrl && (
        <div className="mb-4 sm:mb-6 w-full max-w-xs sm:max-w-sm md:max-w-md aspect-square border-2 border-dashed border-gray-300 rounded-lg p-1 sm:p-2 flex items-center justify-center mx-auto">
          <img src={previewUrl} alt="Selected mole" className="max-w-full max-h-full object-contain rounded" />
        </div>
      )}

      <Button 
        onClick={handleAnalyzeClick} 
        disabled={!selectedFile || isLoading} 
        variant="primary"
        className="w-full py-2.5 sm:py-3 text-sm sm:text-base"
      >
        {isLoading ? (
          <>
            <Spinner size="sm" />
            <span className="ml-2">{UI_TEXT.analyzing}</span>
          </>
        ) : (
          <>
           <i className="fas fa-search-plus mr-2"></i>
           {UI_TEXT.analyzeButton}
          </>
        )}
      </Button>
    </div>
  );
};
