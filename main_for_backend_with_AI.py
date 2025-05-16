import os
import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal
from backend import SkinSightBackend

class Bridge(QObject):
    analysisComplete = Signal(dict)
    
    def __init__(self, backend):
        super().__init__()
        self.backend = backend

    @Slot(str)
    def analyze_image(self, image_path):
        try:
            result = self.backend.image_analyzer.analyze_mole()
            self.analysisComplete.emit(result)
        except Exception as e:
            print(f"Analysis error: {e}")

    @Slot(str, result=str)
    def save_image(self, file_url):
        try:
            file_path = file_url.replace("file://", "")
            return self.backend.image_analyzer.save_mole_image(file_path)
        except Exception as e:
            print(f"Image save error: {e}")
            return ""

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    backend = SkinSightBackend("model.h5")
    bridge = Bridge(backend)
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", bridge)
    engine.load(os.path.join(os.path.dirname(__file__), "main.qml"))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())
