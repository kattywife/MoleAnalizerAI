
export const DIAGNOSIS_CLASSES = {
  MEL: { name: 'Melanoma', code: 'MEL' as const },
  NV: { name: 'Nevus', code: 'NV' as const },
  BCC: { name: 'Basal cell carcinoma', code: 'BCC' as const },
  AK: { name: 'Actinic keratosis', code: 'AK' as const },
  BKL: { name: 'Benign keratosis-like lesions', code: 'BKL' as const },
  DF: { name: 'Dermatofibroma', code: 'DF' as const },
  VASC: { name: 'Vascular lesions', code: 'VASC' as const },
};

export type DiagnosisCode = keyof typeof DIAGNOSIS_CLASSES;

export const MELANOMA_LOW_THRESHOLD = 10; // Percentage
export const MELANOMA_HIGH_THRESHOLD = 50; // Percentage

export const UI_TEXT = {
  appName: "SkinSight",
  welcomeMessage: "Welcome, Doctor!",
  uploadPrompt: "Upload an image of a mole for analysis.",
  selectImageButton: "Select Image",
  analyzeButton: "Analyze",
  analyzing: "Analyzing...",
  backButton: "Back",
  finishAnalysisButton: "Finish Analysis",
  evaluateResultsButton: "Evaluate Results",
  originalImage: "Original Image:",
  melanomaRiskText: (riskLevel: string) => `${riskLevel} Risk of Melanoma`,
  probability: "Probability",
  diagnosis: "Diagnosis",
  errorPrefix: "Error:",
  localApiError: "An error occurred while analyzing the image with the local analysis service. This could be due to network issues or an issue with the local server. Please try again later or with a different image. Check the console for more details.",
  fileReadError: "Error reading file. Please try a different image.",
  fileTypeNotSupported: "File type not supported. Please upload a JPG, PNG, or WEBP image.",
  notAMoleModalTitle: "Image Not a Mole",
  notAMoleModalMessage: "The uploaded image does not appear to be a skin mole. Please upload a clear, close-up image of a mole for analysis.",
  modalOkButton: "OK",
};
