import sys
import os
from pathlib import Path
import pytest
from datetime import date
import shutil
import json
import mysql.connector

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from backend.backend_bridge import BackendBridge
from tests.conftest import get_test_file_path
from tests.test_database_manager import is_mysql_available

# Skip all tests if MySQL is not available
pytestmark = pytest.mark.skipif(
    not is_mysql_available(),
    reason="MySQL server is not available"
)

@pytest.fixture
def test_config():
    """Create a test config file."""
    config = {
        "database": {
            "host": "localhost",
            "user": "root",
            "password": "",
            "database": "skinsight_test"
        },
        "application": {
            "uploads_dir": "test_uploads",
            "models_dir": "models",
            "model_file": "model.h5"
        }
    }
    
    config_path = project_root / "test_config.json"
    with open(config_path, "w") as f:
        json.dump(config, f)
    
    # Create test uploads directory
    test_uploads = project_root / "test_uploads"
    test_uploads.mkdir(exist_ok=True)
    
    yield str(config_path)
    
    # Cleanup
    if test_uploads.exists():
        shutil.rmtree(test_uploads)
    os.remove(config_path)

@pytest.fixture
def backend(test_config):
    """Create BackendBridge instance for testing."""
    bridge = BackendBridge()
    yield bridge
    
    # Clean up database after tests
    bridge.db.cursor.execute("DROP DATABASE IF EXISTS skinsight_test")
    bridge.db.close()

@pytest.fixture
def test_image():
    """Create a test image for analysis."""
    img_path = get_test_file_path("test_mole.jpg")
    if not img_path.exists():
        # Create a simple test image
        from PIL import Image
        img = Image.new('RGB', (224, 224), color='brown')
        img.save(img_path)
    return str(img_path)

def test_full_analysis_workflow(backend, test_image):
    """Test complete workflow from adding patient to analyzing image."""
    # Add a test patient
    patient_data = {
        "full_name": "Integration Test Patient",
        "gender": "female",
        "birth_date": date(1980, 1, 1),
        "phone": "9876543210"
    }
    
    patient_id = backend.add_patient(patient_data)
    assert patient_id > 0
    
    # Set current patient
    backend.currentPatientId = patient_id
    
    # Save and analyze test image
    saved_path = backend.save_image(test_image)
    assert saved_path
    assert os.path.exists(saved_path)
    
    # Perform analysis
    result = backend.analyze_current_image()
    assert result
    assert "melanoma_probability" in result
    assert "diagnosis" in result
    assert "detail_text" in result
    
    # Save analysis result
    success = backend.save_analysis_result()
    assert success
    
    # Check patient history
    analyses = backend.get_patient_analyses(patient_id)
    assert len(analyses) == 1
    assert analyses[0]["image_path"] == saved_path
    assert "metadata" in analyses[0]

def test_patient_search_and_update(backend):
    """Test patient search and update functionality."""
    # Add test patients
    patients = [
        {
            "full_name": "John Integration",
            "gender": "male",
            "birth_date": date(1990, 1, 1),
            "phone": "1111111111"
        },
        {
            "full_name": "Jane Integration",
            "gender": "female",
            "birth_date": date(1992, 2, 2),
            "phone": "2222222222"
        }
    ]
    
    patient_ids = []
    for patient in patients:
        patient_id = backend.add_patient(patient)
        assert patient_id > 0
        patient_ids.append(patient_id)
    
    # Test search
    results = backend.search_patients("Integration")
    assert len(results) == 2
    
    # Test patient update
    update_data = dict(patients[0])
    update_data["id"] = patient_ids[0]
    update_data["phone"] = "9999999999"
    
    success = backend.update_patient(patient_ids[0], update_data)
    assert success
    
    # Verify update
    patient = backend.get_patient_details(patient_ids[0])
    assert patient["phone"] == "9999999999"

def test_error_handling(backend, test_image):
    """Test error handling in integrated operations."""
    # Test invalid patient data
    invalid_patient = {
        "full_name": "Invalid Patient"
        # Missing required fields
    }
    
    with pytest.raises(Exception):
        backend.add_patient(invalid_patient)
    
    # Test analysis without patient
    backend.currentPatientId = None
    backend.currentImagePath = test_image
    
    result = backend.analyze_current_image()
    assert result  # Analysis should work without patient
    
    # But saving should fail
    success = backend.save_analysis_result()
    assert not success  # Should fail without patient ID
    
    # Test invalid image path
    backend.currentImagePath = "nonexistent.jpg"
    result = backend.analyze_current_image()
    assert not result  # Should return empty dict for invalid image