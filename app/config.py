# app/config.py
import os
from dotenv import load_dotenv

load_dotenv()

_CURRENT_FILE_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_CURRENT_FILE_DIR)

# --- Mole Detector Model Configuration ---
MOLE_DETECTOR_MODEL_PATH = os.getenv("MOLE_DETECTOR_MODEL_PATH", os.path.join(_PROJECT_ROOT, "model", "mole_detector_epoch_01_val_acc_1.00_96.h5"))
MOLE_DETECTOR_IMG_SIZE = 224  # As per your test script
MOLE_DETECTOR_BASE_MODEL_NAME = 'EfficientNetB0' # As per your test script
MOLE_DETECTOR_DROPOUT_RATE = 0.3 # As per your test script
MOLE_DETECTOR_CLASSES = ['not_mole', 'mole'] # 0: not_mole, 1: mole
MOLE_DETECTOR_THRESHOLD = 0.5 # Threshold to classify as 'mole'

# --- Skin Condition Classifier Model Settings ---
# Model with metadata
MODEL_PATH = os.getenv("MODEL_PATH", os.path.join(_PROJECT_ROOT, "model", "model_epoch_11_val_loss_0.81.h5"))
MODEL_VERSION = "1.0.2"
METADATA_FEATURES_COUNT = 3

# Image-only skin condition classifier
# IMAGE_ONLY_MODEL_PATH = os.getenv("IMAGE_ONLY_MODEL_PATH", os.path.join(_PROJECT_ROOT, "model", "model_epoch_06_val_loss_0.94_images.h5"))
IMAGE_ONLY_MODEL_PATH = os.getenv("IMAGE_ONLY_MODEL_PATH", os.path.join(_PROJECT_ROOT, "model", "skin_lesion_model_image.h5"))
IMAGE_ONLY_MODEL_VERSION = "1.0.0_img_only"

# Common settings for skin condition classifiers
SKIN_CLASSIFIER_IMG_SIZE = 224 # Main image size for these models (can be same or different from detector)
SKIN_CLASSIFIER_BASE_MODEL_NAME = 'EfficientNetB0'
SKIN_CLASSIFIER_DROPOUT_RATE = 0.3

# Output classes for the skin condition classifiers
SKIN_CLASSES_DISPLAY = [ # For PRD-facing display
    'Melanoma', 'Nevus', 'Basal cell carcinoma', 'Actinic keratosis',
    'Benign keratosis-like lesions', 'Dermatofibroma', 'Vascular lesions'
]
SKIN_CLASSES_INTERNAL = [ # Internal names matching model training
    'melanoma', 'nevus', 'basal_cell_carcinoma', 'actinic_keratosis',
    'benign_keratosis', 'dermatofibroma', 'vascular_lesions'
]
SKIN_CLASS_NAME_MAPPING = {
    internal_name: display_name for internal_name, display_name in zip(SKIN_CLASSES_INTERNAL, SKIN_CLASSES_DISPLAY)
}


# API settings
MAX_FILE_SIZE_MB = 10 # Increased for testing potentially larger raw images
ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png"]

# Metadata Mappings & Scaling (only for multi-input skin classifier model)
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

# Message for non-mole detection
NOT_A_MOLE_MESSAGE = "The uploaded image is not classified as a mole by the initial screening model."