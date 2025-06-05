# app/preprocessing.py
import numpy as np
from PIL import Image
import io
# Import specific preprocessors as needed by base models
from tensorflow.keras.applications import efficientnet # For skin classifiers
# For mole detector, we'll use a dynamic import based on config
# from tensorflow.keras.applications.efficientnet import preprocess_input as effnet_preprocess
# from tensorflow.keras.applications.mobilenet_v2 import preprocess_input as mobilenetv2_preprocess

from config import (
    SKIN_CLASSIFIER_IMG_SIZE,
    MOLE_DETECTOR_IMG_SIZE, MOLE_DETECTOR_BASE_MODEL_NAME, # For mole detector preprocessing
    SEX_MAPPING, ANATOM_SITE_MAPPING, AGE_MEAN_PLACEHOLDER, AGE_STD_PLACEHOLDER
)
from schemas import MetadataBase
import logging

logger = logging.getLogger(__name__)

def _get_preprocess_fn_for_base_model(base_model_name_local):
    """Dynamically gets the correct Keras preprocessing function."""
    if base_model_name_local == 'EfficientNetB0':
        from tensorflow.keras.applications.efficientnet import preprocess_input
        return preprocess_input
    elif base_model_name_local == 'MobileNetV2':
        from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
        return preprocess_input
    # Add more elif for other base models if needed
    # elif base_model_name_local == 'ResNet50':
    #     from tensorflow.keras.applications.resnet50 import preprocess_input
    #     return preprocess_input
    else:
        logger.warning(f"Preprocessing for {base_model_name_local} not explicitly set in _get_preprocess_fn. Defaulting to simple scaling.")
        return lambda x: x / 255.0 # Simple scaling if unknown

def preprocess_image_for_mole_detector(image_bytes: bytes):
    """Loads and preprocesses an image for the mole detector model."""
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    except Exception as e:
        logger.error(f"Error opening image from bytes for mole detector: {e}")
        raise ValueError("Invalid image file for mole detector.")

    target_size = (MOLE_DETECTOR_IMG_SIZE, MOLE_DETECTOR_IMG_SIZE)
    img = img.resize(target_size)
    img_array = np.array(img)

    preprocess_fn = _get_preprocess_fn_for_base_model(MOLE_DETECTOR_BASE_MODEL_NAME)
    processed_img_array = preprocess_fn(img_array.astype(np.float32)) # Ensure float32

    img_batch = np.expand_dims(processed_img_array, axis=0)
    return img_batch


def preprocess_image_for_skin_classifier(image_bytes: bytes):
    """Loads and preprocesses an image for the skin condition classifier models."""
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    except Exception as e:
        logger.error(f"Error opening image from bytes for skin classifier: {e}")
        raise ValueError("Invalid image file for skin classifier.")

    target_size = (SKIN_CLASSIFIER_IMG_SIZE, SKIN_CLASSIFIER_IMG_SIZE)
    img = img.resize(target_size)
    img_array = np.array(img)

    # Assuming EfficientNetB0 for skin classifiers based on previous config
    # If SKIN_CLASSIFIER_BASE_MODEL_NAME can vary, use _get_preprocess_fn_for_base_model here too
    img_processed = efficientnet.preprocess_input(img_array.astype(np.float32))
    expanded_img = np.expand_dims(img_processed, axis=0)
    return expanded_img

# Renamed old load_and_preprocess_image_from_bytes to be more specific
load_and_preprocess_image_for_skin_classifier = preprocess_image_for_skin_classifier


def preprocess_metadata(metadata: MetadataBase):
    # ... (this function remains the same as before) ...
    processed_features = []
    scaled_age = (metadata.age - AGE_MEAN_PLACEHOLDER) / AGE_STD_PLACEHOLDER
    processed_features.append(scaled_age)
    sex_str = metadata.sex.lower()
    encoded_sex = SEX_MAPPING.get(sex_str, SEX_MAPPING.get('other'))
    processed_features.append(float(encoded_sex))
    site_str_input = metadata.location.lower()
    internal_site_key = "unknown"
    if site_str_input == "trunk": internal_site_key = "trunk"
    elif site_str_input == "head/neck": internal_site_key = "head/neck"
    elif site_str_input == "palms/soles": internal_site_key = "palms/soles"
    elif site_str_input == "oral/genital": internal_site_key = "oral/genital"
    elif site_str_input == "extremities":
        internal_site_key = 'extremities' if 'extremities' in ANATOM_SITE_MAPPING else 'lower extremity'
    encoded_site = ANATOM_SITE_MAPPING.get(internal_site_key, ANATOM_SITE_MAPPING.get('unknown'))
    processed_features.append(float(encoded_site))
    metadata_array = np.array([processed_features], dtype=np.float32)
    logger.info(f"Processed metadata array: {metadata_array}")
    return metadata_array