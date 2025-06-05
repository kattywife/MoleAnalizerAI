
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
  welcomeMessage: "Добро пожаловать, Доктор!",
  uploadPrompt: "Загрузите изображение родинки для анализа.",
  selectImageButton: "Выберите изображение",
  analyzeButton: "Анализировать",
  analyzing: "Анализ...",
  backButton: "Назад",
  finishAnalysisButton: "Закончить анализ",
  evaluateResultsButton: "Оценивайте результаты",
  originalImage: "Исходное изображение:",
  melanomaRiskText: (riskLevel: string) => `${riskLevel} Риск развития меланомы`,
  probability: "Вероятность",
  diagnosis: "Диагноз",
  errorPrefix: "Ошибка:",
  localApiError: "При анализе изображения с помощью службы локального анализа произошла ошибка. Это может быть связано с неполадками в сети или с локальным сервером. Пожалуйста, повторите попытку позже или с другим изображением.",
  fileReadError: "Ошибка при чтении файла. Пожалуйста, попробуйте использовать другое изображение.",
  fileTypeNotSupported: "Тип файла не поддерживается. Пожалуйста, загрузите изображение в формате JPG, PNG или WEBP.",
  notAMoleModalTitle: "На изображении отсутствует родинка",
  notAMoleModalMessage: "Загруженное изображение не похоже на родинку на коже. Пожалуйста, загрузите четкое изображение родинки крупным планом для анализа.",
  modalOkButton: "ОК",
};
