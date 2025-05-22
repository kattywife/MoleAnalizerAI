import os
import sys
from pathlib import Path

# Add the project root directory to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from PySide6.QtCore import QUrl, Qt
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from backend import BackendBridge

def main():
    # Enable High DPI scaling
    QGuiApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.PassThrough)
    os.environ["QT_ENABLE_HIGHDPI_SCALING"] = "1"
    
    # Create the Qt Application
    app = QGuiApplication(sys.argv)
    app.setApplicationName("SkinSight")
    app.setOrganizationName("SkinSight")
    app.setWindowIcon(QIcon(os.path.join("frontend", "assets", "images", "логотип.svg")))

    # Create QML engine
    engine = QQmlApplicationEngine()
    
    # Create and register the backend bridge
    backend = BackendBridge()
    engine.rootContext().setContextProperty("backend", backend)

    # Set up QML import paths and dependencies
    qml_root = project_root / "frontend"
    engine.addImportPath(str(qml_root))

    # Load the main QML file
    qml_file = os.path.join("frontend", "MyMain.qml")
    # qml_file = os.path.join("frontend", "screens", "MainScreen.qml")
    engine.load(QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), qml_file)))
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())