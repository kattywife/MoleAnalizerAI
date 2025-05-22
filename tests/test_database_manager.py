import sys
import os
from pathlib import Path
import pytest
from datetime import datetime, date
import json
import mysql.connector

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from backend.database_manager import DatabaseManager

def is_mysql_available():
    """Check if MySQL server is accessible."""
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password=""
        )
        conn.close()
        return True
    except mysql.connector.Error:
        return False

# Skip all tests if MySQL is not available
pytestmark = pytest.mark.skipif(
    not is_mysql_available(),
    reason="MySQL server is not available"
)

@pytest.fixture
def test_config():
    """Create a test config file with test database settings."""
    config = {
        "database": {
            "host": "localhost",
            "user": "root",
            "password": "",
            "database": "skinsight_test"
        }
    }
    config_path = project_root / "test_config.json"
    with open(config_path, "w") as f:
        json.dump(config, f)
    yield str(config_path)
    os.remove(config_path)

@pytest.fixture
def db_manager(test_config):
    """Create a DatabaseManager instance for testing."""
    manager = DatabaseManager(test_config)
    yield manager
    # Clean up
    manager.cursor.execute("DROP DATABASE IF EXISTS skinsight_test")
    manager.close()

def test_connection(db_manager):
    """Test database connection and initialization."""
    assert db_manager.is_connected()
    db_manager.ensure_connected()
    assert db_manager.connection is not None
    assert db_manager.cursor is not None

def test_add_patient(db_manager):
    """Test adding a new patient."""
    patient_data = {
        "full_name": "Test Patient",
        "gender": "male",
        "birth_date": date(1990, 1, 1),
        "phone": "1234567890",
        "address": "Test Address",
        "medical_history": "No history"
    }
    
    patient_id = db_manager.add_patient(patient_data)
    assert patient_id > 0
    
    # Verify patient was added
    result = db_manager.get_patient(patient_id)
    assert result is not None
    assert result["full_name"] == patient_data["full_name"]
    assert result["gender"] == patient_data["gender"]

def test_search_patients(db_manager):
    """Test patient search functionality."""
    # Add test patients
    patients = [
        {
            "full_name": "John Doe",
            "gender": "male",
            "birth_date": date(1990, 1, 1),
            "phone": "1111111111"
        },
        {
            "full_name": "Jane Doe",
            "gender": "female",
            "birth_date": date(1992, 2, 2),
            "phone": "2222222222"
        }
    ]
    
    for patient in patients:
        db_manager.add_patient(patient)
    
    # Search by name
    results = db_manager.search_patients("Doe")
    assert len(results) == 2
    
    # Search by phone
    results = db_manager.search_patients("1111")
    assert len(results) == 1
    assert results[0]["full_name"] == "John Doe"

def test_add_and_get_analysis(db_manager):
    """Test adding and retrieving analysis records."""
    # Add test patient
    patient_data = {
        "full_name": "Analysis Test Patient",
        "gender": "female",
        "birth_date": date(1995, 5, 5),
        "phone": "5555555555"
    }
    patient_id = db_manager.add_patient(patient_data)
    
    # Add analysis
    analysis_data = {
        "patient_id": patient_id,
        "image_path": "/test/image.jpg",
        "melanoma_probability": 0.15,
        "diagnosis_text": "Low risk",
        "metadata": {
            "detail_text": "Additional details",
            "benign_probability": "0.85"
        }
    }
    
    analysis_id = db_manager.add_analysis(analysis_data)
    assert analysis_id > 0
    
    # Get analyses for patient
    analyses = db_manager.get_patient_analyses(patient_id)
    assert len(analyses) == 1
    assert analyses[0]["melanoma_probability"] == 0.15
    assert "detail_text:Additional details" in analyses[0]["metadata"]

def test_update_patient(db_manager):
    """Test updating patient information."""
    # Add test patient
    patient_data = {
        "full_name": "Update Test Patient",
        "gender": "male",
        "birth_date": date(1985, 3, 3),
        "phone": "3333333333"
    }
    patient_id = db_manager.add_patient(patient_data)
    
    # Update patient
    updated_data = dict(patient_data)
    updated_data["id"] = patient_id
    updated_data["full_name"] = "Updated Name"
    updated_data["phone"] = "9999999999"
    
    success = db_manager.update_patient(updated_data)
    assert success
    
    # Verify update
    result = db_manager.get_patient(patient_id)
    assert result["full_name"] == "Updated Name"
    assert result["phone"] == "9999999999"

def test_error_handling(db_manager):
    """Test error handling in database operations."""
    # Test invalid patient data
    with pytest.raises(Exception):
        db_manager.add_patient({})  # Missing required fields
    
    # Test invalid analysis data
    with pytest.raises(Exception):
        db_manager.add_analysis({})  # Missing required fields
    
    # Test invalid patient update
    with pytest.raises(ValueError):
        db_manager.update_patient({"full_name": "Test"})  # Missing ID