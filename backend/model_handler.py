import os
import numpy as np
import tensorflow as tf
from PIL import Image
from typing import Dict, Tuple
import json
from pathlib import Path
import requests
import json

class ModelHandler:
    # def __init__(self):
    #     # Load config to get model path
    #     config_path = Path(__file__).parent.parent / "config.json"
    #     try:
    #         with open(config_path, "r") as f:
    #             config = json.load(f)
    #             models_dir = config["application"]["models_dir"]
    #             model_file = config["application"]["model_file"]
    #     except Exception as e:
    #         raise RuntimeError(f"Error loading config: {e}")

    #     # Construct absolute model path
    #     model_path = Path(__file__).parent.parent / models_dir / model_file
    #     if not model_path.exists():
    #         raise FileNotFoundError(f"Model file not found at {model_path}")
            
    #     self.model = tf.keras.models.load_model(str(model_path))
    #     self.image_size = (224, 224)  # Standard input size for many CNN models
        
    # def preprocess_image(self, image_path: str) -> np.ndarray:
    #     """Preprocesses an image for model prediction."""
    #     try:
    #         img = Image.open(image_path).convert('RGB')
    #         img = img.resize(self.image_size)
    #         img_array = np.array(img).astype('float32') / 255.0
    #         return np.expand_dims(img_array, axis=0)
    #     except Exception as e:
    #         raise RuntimeError(f"Error preprocessing image: {e}")

    # def predict(self, image_path: str) -> Dict[str, float]:
    #     """
    #     Analyzes an image and returns prediction probabilities.
    #     Returns dict with melanoma_probability and benign_probability.
    #     """
    #     try:
    #         processed_image = self.preprocess_image(image_path)
    #         prediction = self.model.predict(processed_image)[0]
            
    #         # Assuming binary classification where index 1 is melanoma probability
    #         melanoma_prob = float(prediction[1])
    #         benign_prob = float(prediction[0])
            
    #         return {
    #             "melanoma_probability": melanoma_prob,
    #             "benign_probability": benign_prob
    #         }
    #     except Exception as e:
    #         raise RuntimeError(f"Error during prediction: {e}")

    def predict(self, image_path: str) -> Dict[str, float]:
        """
        Analyzes an image and returns prediction probabilities.
        Returns dict with melanoma_probability and benign_probability.
        """
        try: 
            image_file = {
                "image_file": (os.path.basename(image_path), open(image_path, 'rb'), 'image/jpeg') 
            }
            payload_metadata = {
                "metadata": json.dumps({"age": 30, "sex": "Male", "location": "Trunk"})
            }   #'{"metadata": {"age": 30, "sex": "Male", "location": "Trunk"} }'
            response = requests.post(
                "http://0.0.0.0:8000/predict", 
                files = image_file,
                data = payload_metadata
            )
            response_dict = json.loads(response.text)

            return response_dict
        except Exception as e:
            raise RuntimeError(f"Error during prediction: {e}")
        finally:
            # Ensure the file is closed if it was opened
            if 'image_file' in image_file and image_file['image_file'][1]:
                try:
                    image_file['image_file'][1].close()
                except Exception as fe:
                    print(f"Error closing file: {fe}")


    def get_prediction_text(self, melanoma_prob: float) -> Tuple[str, str]:
        """Returns a tuple of (diagnosis, detailed_text) based on probabilities."""
        
        if melanoma_prob > 0.7:
            detail = "High Risk - Urgent Medical Attention Required"
        elif melanoma_prob > 0.4:
            detail = "Medium Risk - Medical Consultation Recommended"
        else:
            detail = "Low Risk - Regular Monitoring Advised"

        return "", detail


    # def get_prediction_text(self, probabilities: Dict[str, float]) -> Tuple[str, str]:
    #     """Returns a tuple of (diagnosis, detailed_text) based on probabilities."""
    #     melanoma_prob = probabilities["melanoma_probability"]
    #     risk_level = self._get_risk_level(melanoma_prob)
        
    #     if melanoma_prob > 0.7:
    #         diagnosis = "High Risk - Urgent Medical Attention Required"
    #         detail = f"The analysis indicates a {risk_level} risk of melanoma ({melanoma_prob:.1%}). Immediate medical consultation is strongly recommended."
    #     elif melanoma_prob > 0.4:
    #         diagnosis = "Medium Risk - Medical Consultation Recommended"
    #         detail = f"The analysis shows a {risk_level} risk of melanoma ({melanoma_prob:.1%}). A medical consultation is recommended for further evaluation."
    #     else:
    #         diagnosis = "Low Risk - Regular Monitoring Advised"
    #         detail = f"The analysis suggests a {risk_level} risk of melanoma ({melanoma_prob:.1%}). Continue regular monitoring and follow standard skin check protocols."
            
    #     return diagnosis, detail

    def _get_risk_level(self, probability: float) -> str:
        """Converts probability to a risk level string."""
        if probability > 0.7:
            return "high"
        elif probability > 0.4:
            return "medium"
        else:
            return "low"