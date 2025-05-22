import sys
from pathlib import Path
import pytest
from PySide6 import QtCore
from PySide6.QtCore import Qt, QObject
from PySide6.QtQml import QQmlComponent

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

@pytest.mark.gui
def test_patient_data_form(qml_engine):
    """Test PatientDataForm component."""
    component = QQmlComponent(qml_engine)
    component.loadUrl(QtCore.QUrl.fromLocalFile(
        str(project_root / "frontend/components/PatientDataForm.qml")
    ))
    
    assert not component.isError(), component.errorString()
    form = component.create()
    assert form is not None
    
    # Test setting and getting form data
    form.setProperty("patientName", "Test Patient")
    form.setProperty("patientGender", "female")
    form.setProperty("patientPhone", "1234567890")
    
    assert form.property("patientName") == "Test Patient"
    assert form.property("patientGender") == "female"
    assert form.property("patientPhone") == "1234567890"

@pytest.mark.gui
def test_melanoma_indicator(qml_engine):
    """Test MelanomaIndicator component."""
    component = QQmlComponent(qml_engine)
    component.loadUrl(QtCore.QUrl.fromLocalFile(
        str(project_root / "frontend/components/MelanomaIndicator.qml")
    ))
    
    assert not component.isError(), component.errorString()
    indicator = component.create()
    assert indicator is not None
    
    # Test risk level changes
    indicator.setProperty("riskLevel", 0.15)
    assert indicator.property("riskLevel") == 0.15
    assert indicator.property("riskText") == "Low Risk"
    
    indicator.setProperty("riskLevel", 0.75)
    assert indicator.property("riskLevel") == 0.75
    assert indicator.property("riskText") == "High Risk"

@pytest.mark.gui
def test_analysis_history_table(qml_engine):
    """Test AnalysisHistoryTable component."""
    component = QQmlComponent(qml_engine)
    component.loadUrl(QtCore.QUrl.fromLocalFile(
        str(project_root / "frontend/components/AnalysisHistoryTable.qml")
    ))
    
    assert not component.isError(), component.errorString()
    table = component.create()
    assert table is not None
    
    # Test setting analysis data
    test_data = [
        {
            "date": "2025-05-17",
            "risk_level": 0.15,
            "diagnosis": "Low Risk",
            "image_path": "/test/image1.jpg"
        },
        {
            "date": "2025-05-16",
            "risk_level": 0.65,
            "diagnosis": "Medium Risk",
            "image_path": "/test/image2.jpg"
        }
    ]
    
    table.setProperty("analysisHistory", test_data)
    assert len(table.property("analysisHistory")) == 2

@pytest.mark.gui
def test_action_buttons(qml_engine):
    """Test various action button components."""
    button_components = [
        "SmallActionButton.qml",
        "LargeActionButton.qml",
        "AccentActionButton.qml",
        "AnalyzeButton.qml",
        "CustomMenuButton.qml"
    ]
    
    for button_file in button_components:
        component = QQmlComponent(qml_engine)
        component.loadUrl(QtCore.QUrl.fromLocalFile(
            str(project_root / f"frontend/components/{button_file}")
        ))
        
        assert not component.isError(), component.errorString()
        button = component.create()
        assert button is not None
        
        # Test button properties
        button.setProperty("text", "Test Button")
        assert button.property("text") == "Test Button"
        
        if hasattr(button, "enabled"):
            button.setProperty("enabled", False)
            assert not button.property("enabled")

@pytest.mark.gui
def test_workspaces(qml_engine):
    """Test workspace components."""
    workspace_components = [
        "AnalysisWorkspace.qml",
        "AnalysisResultsWorkspace.qml",
        "PatientsWorkspace.qml"
    ]
    
    for workspace_file in workspace_components:
        component = QQmlComponent(qml_engine)
        component.loadUrl(QtCore.QUrl.fromLocalFile(
            str(project_root / f"frontend/screens/{workspace_file}")
        ))
        
        assert not component.isError(), component.errorString()
        workspace = component.create()
        assert workspace is not None