
import type { DIAGNOSIS_CLASSES } from './constants';
import type { Part } from '@google/genai';

export type DiagnosisCode = keyof typeof DIAGNOSIS_CLASSES;

export interface DiagnosisResult {
  code: DiagnosisCode;
  name: string;
  probability: number; // 0 to 1
}

export interface GeminiApiResponse {
  MEL?: number;
  NV?: number;
  BCC?: number;
  AK?: number;
  BKL?: number;
  DF?: number;
  VASC?: number;
  [key: string]: number | undefined;
}

export type ImagePart = Part; // from @google/genai
    