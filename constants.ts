
export const MODEL_NAME = 'gemini-2.5-flash-preview-04-17';

export const DIAGNOSIS_CLASSES = {
  MEL: { name: 'Melanoma', code: 'MEL' as const },
  NV: { name: 'Pigmented Nevus', code: 'NV' as const },
  BCC: { name: 'Basal Cell Carcinoma', code: 'BCC' as const },
  AK: { name: 'Actinic Keratosis', code: 'AK' as const },
  BKL: { name: 'Benign Keratosis', code: 'BKL' as const },
  DF: { name: 'Dermatofibroma', code: 'DF' as const },
  VASC: { name: 'Vascular Lesions', code: 'VASC' as const },
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
  geminiError: "An error occurred while analyzing the image. This could be due to network issues, API limits, or the image content. Please try again later or with a different image.",
  fileReadError: "Error reading file. Please try a different image.",
  fileTypeNotSupported: "File type not supported. Please upload a JPG, PNG, or WEBP image.",
  noApiKey: "API Key is not configured. The application cannot contact the analysis service. Please ensure the API_KEY environment variable is set.",
};
