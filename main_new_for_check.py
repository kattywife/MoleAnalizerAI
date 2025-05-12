import os
import sys
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend import SkinAnalysisBackend

def main():
    if not os.path.exists("model.h5"):
        print("Error: Model file 'model.h5' not found!", file=sys.stderr)
        sys.exit(1)

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = SkinAnalysisBackend()
    engine.rootContext().setContextProperty("backend", backend)

    engine.load(QUrl.fromLocalFile("main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
