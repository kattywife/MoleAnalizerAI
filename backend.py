import os
import numpy as np
import tensorflow as tf
from datetime import datetime
from typing import Dict, Optional
from PIL import Image
from PySide6.QtCore import QObject, Slot, Signal

class SkinCancerModel:
    def __init__(self, model_path: str = "model.h5"):
        self.model = self._load_model(model_path)
        self.image_size = (224, 224)

    def _load_model(self, model_path: str) -> tf.keras.Model:
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found at {model_path}")
        
        try:
            model = tf.keras.models.load_model(model_path)
            print("Model loaded successfully")
            return model
        except Exception as e:
            raise RuntimeError(f"Error loading model: {e}")

    def preprocess_image(self, image_path: str) -> np.ndarray:
        try:
            img = Image.open(image_path).convert('RGB')
            img = img.resize(self.image_size)
            img_array = np.array(img).astype('float32') / 255.0
            return np.expand_dims(img_array, axis=0)
        except Exception as e:
            raise RuntimeError(f"Error processing image: {e}")

    def predict(self, image_path: str) -> Dict[str, float]:
        try:
            processed_img = self.preprocess_image(image_path)
            prediction = self.model.predict(processed_img)[0][0]
            return {
                "malignant_prob": float(prediction),
                "benign_prob": float(1 - prediction)
            }
        except Exception as e:
            raise RuntimeError(f"Prediction error: {e}")

class SkinAnalysisBackend:
    def __init__(self, model_path: str = "model.h5"):
        self.upload_dir = "uploads"
        os.makedirs(self.upload_dir, exist_ok=True)
        self.current_image_path = None
        self.model = SkinCancerModel(model_path)

    def save_mole_image(self, image_path: str) -> str:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        ext = os.path.splitext(image_path)[1]
        new_filename = f"mole_{timestamp}{ext}"
        save_path = os.path.join(self.upload_dir, new_filename)

        try:
            with open(image_path, "rb") as src, open(save_path, "wb") as dst:
                dst.write(src.read())
            self.current_image_path = save_path
            return save_path
        except Exception as e:
            raise RuntimeError(f"Error saving image: {e}")

    def analyze_mole(self) -> Dict[str, str]:
        if not self.current_image_path:
            raise ValueError("No image available for analysis")

        try:
            results = self.model.predict(self.current_image_path)
            diagnosis = "Злокачественное" if results["malignant_prob"] > 0.5 else "Доброкачественное"

            return {
                "status": "success",
                "diagnosis": diagnosis,
                "confidence": max(results["malignant_prob"], results["benign_prob"]),
                "malignant_prob": results["malignant_prob"],
                "benign_prob": results["benign_prob"],
                "recommendation": "Срочно обратитесь к врачу" if diagnosis == "Злокачественное"
                                else "Плановый осмотр через 6 месяцев",
                "image_path": self.current_image_path
            }
        except Exception as e:
            raise RuntimeError(f"Analysis failed: {e}")

class SkinSightBackend(QObject):
    analysisComplete = Signal(dict)
    
    def __init__(self, model_path: str = "model.h5"):
        super().__init__()
        self.patients = []
        self.current_user = "Виктор Иванов"
        self.image_analyzer = SkinAnalysisBackend(model_path)
    
    @Slot(str, result=str)
    def save_image(self, file_path: str) -> str:
        try:
            clean_path = file_path.replace("file://", "")
            return self.image_analyzer.save_mole_image(clean_path)
        except Exception as e:
            print(f"Error saving image: {e}")
            return ""
    
    @Slot(str)
    def analyze_image(self, image_path: str):
        try:
            result = self.image_analyzer.analyze_mole()
            self.analysisComplete.emit(result)
        except Exception as e:
            print(f"Error analyzing image: {e}")
            self.analysisComplete.emit({
                "status": "error",
                "message": str(e)
            })
    
    @Slot(result=list)
    def get_patients(self) -> list:
        return self.patients
    
    @Slot(dict, result=int)
    def add_patient(self, patient_data: dict) -> int:
        try:
            self.patients.append(patient_data)
            return len(self.patients) - 1
        except Exception as e:
            print(f"Error adding patient: {e}")
            return -1
