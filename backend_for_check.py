import os
import numpy as np
import tensorflow as tf
from datetime import datetime
from PySide6.QtCore import QObject, Signal, Slot, Property

class SkinAnalysisBackend(QObject):
    analysisCompleted = Signal(dict)
    errorOccurred = Signal(str)
    imageLoaded = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._upload_dir = "uploads"
        os.makedirs(self._upload_dir, exist_ok=True)
        self._current_image_path = ""
        self._model = self._load_model()
        self._image_size = (224, 224)

    @Slot(str, result=bool)
    def saveMoleImage(self, image_path: str) -> bool:
        try:
            clean_path = image_path
            if image_path.startswith("file://"):
                clean_path = image_path[7:]

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            ext = os.path.splitext(clean_path)[1]
            save_path = os.path.join(self._upload_dir, f"mole_{timestamp}{ext}")

            with open(clean_path, "rb") as src, open(save_path, "wb") as dst:
                dst.write(src.read())

            self._current_image_path = save_path
            self.imageLoaded.emit(save_path)
            return True
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка сохранения: {str(e)}")
            return False
