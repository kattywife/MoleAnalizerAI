import os
from datetime import datetime
from typing import Optional

class SkinAnalysisBackend:
    def __init__(self):
        self.upload_dir = "uploads"
        os.makedirs(self.upload_dir, exist_ok=True)

    def save_mole_image(self, image_data: bytes, filename: str) -> Optional[str]:
        """Сохраняет изображение и возвращает путь к файлу"""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            ext = os.path.splitext(filename)[1]
            new_filename = f"mole_{timestamp}{ext}"
            save_path = os.path.join(self.upload_dir, new_filename)

            with open(save_path, "wb") as f:
                f.write(image_data)

            return save_path
        except Exception as e:
            print(f"Ошибка сохранения: {e}")
            return None

    def analyze_mole(self, image_path: str) -> dict:
        """Заглушка для анализа изображения (реальная реализация будет использовать ИИ)"""
        return {
            "status": "success",
            "diagnosis": "Доброкачественное образование",
            "confidence": 0.92,
            "recommendation": "Плановый осмотр через 6 месяцев"
        }
