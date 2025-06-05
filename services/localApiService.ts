
import type { GeminiApiResponse, GeminiApiPredictionScores } from '../types';

const getApiUrl = (): string => {
  const apiUrl = process.env.API_URL;
  if (!apiUrl) {
    console.error("API_URL environment variable not set.");
    throw new Error("API URL not configured. Please set the API_URL environment variable.");
  }
  return apiUrl;
};

export const analyzeImageWithLocalApi = async (file: File): Promise<GeminiApiResponse> => {
  const formData = new FormData();
  formData.append('image_file', file);

  try {
    const apiUrl = getApiUrl();
    const response = await fetch(apiUrl, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      // Try to parse error response from API if available
      let errorDetails = `HTTP error! status: ${response.status}`;
      try {
        const errorData = await response.json();
        errorDetails += ` - ${errorData.error?.message || errorData.detail || JSON.stringify(errorData)}`;
      } catch (e) {
        // Ignore if error response is not JSON
      }
      throw new Error(errorDetails);
    }

    const data = await response.json();

    // Adapt local API response to the GeminiApiResponse structure
    if (data.is_mole === true && data.predictions) {
      return {
        predictions: data.predictions as GeminiApiPredictionScores,
        model_version: data.model_version,
        is_mole: data.is_mole,
        mole_detection_probability: data.mole_detection_probability,
      };
    } else if (data.is_mole === false) {
      return {
        predictions: {}, // Empty predictions as it's not a mole for detailed classification
        is_mole: false,
        mole_detection_probability: data.mole_detection_probability,
        model_version: data.model_used || 'mole_detector', // Use model_used or a default
      };
    } else {
      // Should not happen if API behaves as documented
      console.error("Unexpected response structure from local API:", data);
      throw new Error("Unexpected response structure from local API.");
    }

  } catch (error) {
    console.error("Error calling local API or processing its response:", error);
    if (error instanceof Error) {
       throw new Error(`Failed to analyze image with local API: ${error.message}`);
    }
    throw new Error("Failed to analyze image with local API due to an unknown error.");
  }
};
