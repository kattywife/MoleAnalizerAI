import os
import numpy as np
import tensorflow as tf
from datetime import datetime
from typing import Dict
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


class Backend(QObject):
    analysisComplete = Signal(dict)
    errorOccurred = Signal(str)
    imageSaved = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.upload_dir = "uploads"
        os.makedirs(self.upload_dir, exist_ok=True)
        self.current_image_path = None
        self.model = None
        
        try:
            self.model = SkinCancerModel()
        except Exception as e:
            print(f"Could not load ML model: {e}")

    @Slot(str, result=str)
    def save_mole_image(self, image_path: str) -> str:
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            ext = os.path.splitext(image_path)[1]
            new_filename = f"mole_{timestamp}{ext}"
            save_path = os.path.join(self.upload_dir, new_filename)

            with open(image_path, "rb") as src, open(save_path, "wb") as dst:
                dst.write(src.read())
            
            self.current_image_path = save_path
            self.imageSaved.emit(save_path)
            return save_path
        except Exception as e:
            self.errorOccurred.emit(f"Error saving image: {e}")
            return ""

    @Slot(result=dict)
    def analyze_mole(self) -> dict:
        if not self.current_image_path:
            self.errorOccurred.emit("Изображение не загружено")
            return {"status": "error", "message": "Изображение не загружено"}

        if not self.model:
            self.errorOccurred.emit("Модель не загружена")
            return {"status": "error", "message": "Модель не загружена"}

        try:
            results = self.model.predict(self.current_image_path)
            diagnosis = "Злокачественное" if results["malignant_prob"] > 0.5 else "Доброкачественное"

            result = {
                "status": "success",
                "diagnosis": diagnosis,
                "confidence": float(max(results["malignant_prob"], results["benign_prob"])),
                "malignant_prob": float(results["malignant_prob"]),
                "benign_prob": float(results["benign_prob"]),
                "recommendation": "Срочно обратитесь к врачу" if diagnosis == "Злокачественное"
                                else "Плановый осмотр через 6 месяцев",
                "image_path": self.current_image_path
            }
            
            self.analysisComplete.emit(result)
            return result
            
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка анализа: {e}")
            return {"status": "error", "message": str(e)}

    @Slot(result=bool)
    def isModelLoaded(self) -> bool:
        return self.model is not None
