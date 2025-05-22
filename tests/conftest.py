import os
import sys
from pathlib import Path
import pytest
from PySide6.QtQml import QQmlEngine
from PySide6.QtCore import QCoreApplication

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Set QML import path
os.environ["QML_IMPORT_PATH"] = str(project_root / "frontend")

@pytest.fixture(scope="session")
def qapp():
    """Create QApplication instance for the test session."""
    app = QCoreApplication.instance()
    if app is None:
        import sys
        from PySide6.QtWidgets import QApplication
        app = QApplication(sys.argv)
    return app

@pytest.fixture
def qml_engine(qapp):
    """Create a QML engine for testing QML components."""
    engine = QQmlEngine()
    engine.addImportPath(str(project_root / "frontend"))
    return engine

@pytest.fixture
def test_files_path():
    """Return path to test files directory."""
    return project_root / "tests" / "test_files"

@pytest.fixture
def temp_uploads_dir(tmp_path):
    """Create a temporary uploads directory for testing."""
    uploads_dir = tmp_path / "uploads"
    uploads_dir.mkdir()
    return uploads_dir