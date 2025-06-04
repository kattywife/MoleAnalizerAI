
import { GoogleGenAI, GenerateContentResponse, Part } from "@google/genai";
import { MODEL_NAME } from '../constants';
import type { GeminiApiResponse } from '../types';

const getApiKey = (): string => {
  const apiKey = process.env.API_KEY;
  if (!apiKey) {
    console.error("API_KEY environment variable not set.");
    throw new Error("API Key not configured. Please set the API_KEY environment variable.");
  }
  return apiKey;
};

// Initialize with a function to ensure API_KEY is checked at runtime
// This won't actually re-initialize on every call, just a pattern.
// In a real app, you might initialize this once in a context or global setup.
const getAIClient = () => {
    return new GoogleGenAI({ apiKey: getApiKey() });
};


export const fileToGenerativePart = async (file: File): Promise<Part> => {
  const base64EncodedString = await new Promise<string>((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
        const result = reader.result as string;
        // result is "data:[mimeType];base64,[data]"
        // We need only the data part
        resolve(result.substring(result.indexOf(',') + 1));
    };
    reader.onerror = (err) => reject(err);
    reader.readAsDataURL(file);
  });

  return {
    inlineData: {
      mimeType: file.type,
      data: base64EncodedString,
    },
  };
};


export const analyzeImageWithGemini = async (prompt: string, imagePart: Part): Promise<GeminiApiResponse> => {
  const ai = getAIClient();
  try {
    const response: GenerateContentResponse = await ai.models.generateContent({
      model: MODEL_NAME,
      contents: [{ role: "user", parts: [imagePart, { text: prompt }] }],
      config: {
        responseMimeType: "application/json",
        // For this task, we want higher quality, so default thinking is fine.
        // If low latency was critical, we could add:
        // thinkingConfig: { thinkingBudget: 0 } 
      },
    });

    let jsonStr = response.text.trim();
    
    // Remove markdown fences if present
    const fenceRegex = /^```(?:json)?\s*\n?(.*?)\n?\s*```$/s;
    const match = jsonStr.match(fenceRegex);
    if (match && match[1]) {
      jsonStr = match[1].trim();
    }

    try {
      const parsedData = JSON.parse(jsonStr) as GeminiApiResponse;
      return parsedData;
    } catch (e) {
      console.error("Failed to parse JSON response from Gemini:", jsonStr, e);
      throw new Error(`Invalid JSON response from AI: ${(e as Error).message}`);
    }

  } catch (error) {
    console.error("Error calling Gemini API:", error);
    if (error instanceof Error && error.message.includes("API Key not valid")) {
         throw new Error("Invalid API Key. Please check your API_KEY environment variable.");
    }
    throw new Error(`Failed to analyze image with Gemini: ${(error as Error).message}`);
  }
};
    