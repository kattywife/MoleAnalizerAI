import sys
import os
from pathlib import Path
import pytest
import numpy as np
from PIL import Image
import tensorflow as tf
import json

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from backend.model_handler import ModelHandler
from tests.conftest import get_test_file_path

@pytest.fixture
def test_image():
    """Create a test image for model predictions."""
    img_path = get_test_file_path("test_mole.jpg")
    if not img_path.exists():
        # Create a simple test image
        img = Image.new('RGB', (224, 224), color='brown')
        img.save(img_path)
    return str(img_path)

@pytest.fixture
def test_model():
    """Create a simple test model that always predicts low melanoma probability."""
    model_dir = project_root / "models"
    model_dir.mkdir(exist_ok=True)
    model_path = model_dir / "model.h5"
    
    if not model_path.exists():
        # Create a simple model for testing
        inputs = tf.keras.Input(shape=(224, 224, 3))
        x = tf.keras.layers.GlobalAveragePooling2D()(inputs)
        outputs = tf.keras.layers.Dense(2, activation='softmax')(x)
        model = tf.keras.Model(inputs, outputs)
        model.save(model_path)
    
    # Update config to use test model
    config = {
        "database": {
            "host": "localhost",
            "user": "root",
            "password": "",
            "database": "skinsight_test"
        },
        "application": {
            "models_dir": "models",
            "model_file": "model.h5",
            "uploads_dir": "uploads"
        }
    }
    
    config_path = project_root / "test_config.json"
    with open(config_path, "w") as f:
        json.dump(config, f)
    
    return str(model_path)

def test_model_initialization(test_model):
    """Test that ModelHandler initializes correctly."""
    handler = ModelHandler()
    assert handler.model is not None
    assert handler.image_size == (224, 224)

def test_preprocess_image(test_model, test_image):
    """Test image preprocessing."""
    handler = ModelHandler()
    processed = handler.preprocess_image(test_image)
    
    assert isinstance(processed, np.ndarray)
    assert processed.shape == (1, 224, 224, 3)
    assert processed.dtype == np.float32
    assert np.max(processed) <= 1.0
    assert np.min(processed) >= 0.0

def test_predict(test_model, test_image):
    """Test model prediction."""
    handler = ModelHandler()
    prediction = handler.predict(test_image)
    
    assert isinstance(prediction, dict)
    assert "melanoma_probability" in prediction
    assert "benign_probability" in prediction
    assert 0 <= prediction["melanoma_probability"] <= 1
    assert 0 <= prediction["benign_probability"] <= 1
    assert abs(prediction["melanoma_probability"] + prediction["benign_probability"] - 1.0) < 1e-6

def test_get_prediction_text():
    """Test prediction text generation."""
    handler = ModelHandler()
    
    # Test high risk case
    high_risk = handler.get_prediction_text({"melanoma_probability": 0.8})
    assert "High Risk" in high_risk[0]
    assert "Urgent" in high_risk[0]
    
    # Test medium risk case
    medium_risk = handler.get_prediction_text({"melanoma_probability": 0.5})
    assert "Medium Risk" in medium_risk[0]
    assert "Recommended" in medium_risk[0]
    
    # Test low risk case
    low_risk = handler.get_prediction_text({"melanoma_probability": 0.2})
    assert "Low Risk" in low_risk[0]
    assert "Regular Monitoring" in low_risk[0]

def test_error_handling(test_model):
    """Test error handling for invalid inputs."""
    handler = ModelHandler()
    
    # Test invalid image path
    with pytest.raises(RuntimeError):
        handler.preprocess_image("nonexistent_image.jpg")
    
    # Test invalid image file
    invalid_image = get_test_file_path("invalid.txt")
    with open(invalid_image, "w") as f:
        f.write("Not an image")
    
    with pytest.raises(RuntimeError):
        handler.predict(str(invalid_image))
        
    # Clean up
    os.remove(invalid_image)