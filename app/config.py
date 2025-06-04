# app/config.py
import os
from dotenv import load_dotenv

load_dotenv()

_CURRENT_FILE_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_CURRENT_FILE_DIR)

# --- Model and Image settings ---
# Model with metadata
MODEL_PATH = os.getenv("MODEL_PATH", os.path.join(_PROJECT_ROOT, "model", "model_epoch_11_val_loss_0.81.h5"))
METADATA_FEATURES_COUNT = 3 # For the multi-input model
BASE_MODEL_NAME = 'EfficientNetB0' # Assuming both models use the same base for image part
DROPOUT_RATE = 0.3 # Assuming same dropout for consistency if applicable

# Image-only model
IMAGE_ONLY_MODEL_PATH = os.getenv("IMAGE_ONLY_MODEL_PATH", os.path.join(_PROJECT_ROOT, "model", "model_epoch_06_val_loss_0.94_images.h5"))
IMAGE_ONLY_MODEL_VERSION = "1.0.0_img_only" # Example version for image-only model

IMG_SIZE = 224
# These classes should be consistent for both models' outputs
# If the image-only model was trained on a different set/order of classes,
# this needs careful handling. For now, assume they are the same.
CLASSES = [
    'Melanoma', 'Nevus', 'Basal cell carcinoma', 'Actinic keratosis',
    'Benign keratosis-like lesions', 'Dermatofibroma', 'Vascular lesions'
]
INTERNAL_CLASSES = [
    'melanoma', 'nevus', 'basal_cell_carcinoma', 'actinic_keratosis',
    'benign_keratosis', 'dermatofibroma', 'vascular_lesions'
]
CLASS_NAME_MAPPING = {
    'melanoma': 'Melanoma',
    'nevus': 'Nevus',
    'basal_cell_carcinoma': 'Basal cell carcinoma',
    'actinic_keratosis': 'Actinic keratosis',
    'benign_keratosis': 'Benign keratosis-like lesions',
    'dermatofibroma': 'Dermatofibroma',
    'vascular_lesions': 'Vascular lesions'
}
MODEL_VERSION = "1.0.2" # Version for the multi-input model

# API settings
MAX_FILE_SIZE_MB = 10
ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png"]

# Metadata Mappings & Scaling (only for multi-input model)
SEX_MAPPING = {'male': 1, 'female': 0, 'other': 2}
ALLOWED_SEX_VALUES = ["Male", "Female", "Other"]

ANATOM_SITE_MAPPING = {
    'trunk': 0, 'extremities': 1, 'upper extremity': 2,
    'lower extremity': 1, 'head/neck': 3, 'palms/soles': 4,
    'oral/genital': 5, 'unknown': 6
}
ALLOWED_LOCATION_VALUES = ["Trunk", "Head/Neck", "Extremities", "Palms/Soles", "Oral/Genital"]

AGE_MEAN_PLACEHOLDER = 50.0
AGE_STD_PLACEHOLDER = 15.0

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()