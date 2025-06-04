import numpy as np
from PIL import Image
import io
from tensorflow.keras.applications import efficientnet # Or from keras.applications
from config import (
    IMG_SIZE,
    SEX_MAPPING,
    ANATOM_SITE_MAPPING,
    AGE_MEAN_PLACEHOLDER,
    AGE_STD_PLACEHOLDER,
    ALLOWED_LOCATION_VALUES # For mapping PRD values to internal
)
from schemas import MetadataBase
import logging

logger = logging.getLogger(__name__)

def load_and_preprocess_image_from_bytes(image_bytes: bytes, target_size=(IMG_SIZE, IMG_SIZE)):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    except Exception as e:
        logger.error(f"Error opening image from bytes: {e}")
        raise ValueError("Invalid image file. Could not be opened.")

    img = img.resize(target_size)
    img_array = np.array(img)

    # Apply EfficientNetB0 preprocessing
    img_processed = efficientnet.preprocess_input(img_array.astype(np.float32))
    expanded_img = np.expand_dims(img_processed, axis=0)
    return expanded_img

def preprocess_metadata(metadata: MetadataBase):
    """
    Preprocesses validated metadata into a format suitable for the model.
    WARNING: Uses placeholder scaling for age and hardcoded mappings for sex/location.
             This is NOT robust. Ideally, use saved scalers/encoders from training.
    """
    processed_features = []

    # 1. Age (age_approx) - StandardScaler was used in your notebook (assumed).
    #    Using placeholder scaling.
    scaled_age = (metadata.age - AGE_MEAN_PLACEHOLDER) / AGE_STD_PLACEHOLDER
    processed_features.append(scaled_age)

    # 2. Sex - LabelEncoder was used. Using hardcoded mapping.
    sex_str = metadata.sex.lower()
    encoded_sex = SEX_MAPPING.get(sex_str, SEX_MAPPING.get('other')) # Fallback to 'other'
    processed_features.append(float(encoded_sex))

    # 3. Anatomical Site (anatom_site_general) - LabelEncoder was used.
    #    Map PRD location values to the internal ones used by ANATOM_SITE_MAPPING.
    #    The PRD uses "Extremities", while your script might have used "lower extremity", "upper extremity".
    #    We simplify "Extremities" to one of the script's categories or a new one.
    site_str_input = metadata.location.lower() # PRD value
    internal_site_key = "unknown" # Default

    if site_str_input == "trunk":
        internal_site_key = "trunk"
    elif site_str_input == "head/neck":
        internal_site_key = "head/neck"
    elif site_str_input == "palms/soles":
        internal_site_key = "palms/soles"
    elif site_str_input == "oral/genital":
        internal_site_key = "oral/genital"
    elif site_str_input == "extremities":
        # Map PRD's "Extremities" to a value your model understands.
        # If your ANATOM_SITE_MAPPING has 'extremities' directly, use it.
        # Otherwise, map to 'lower extremity', 'upper extremity', or 'unknown'.
        # Example: defaulting to 'lower extremity's encoding if 'extremities' isn't a direct key.
        if 'extremities' in ANATOM_SITE_MAPPING:
            internal_site_key = 'extremities'
        else: # Fallback if 'extremities' itself is not a key
            internal_site_key = 'lower extremity' # Or 'unknown', or handle as error
    
    # Ensure the ANATOM_SITE_MAPPING uses lowercase keys to match site_str
    # Update ANATOM_SITE_MAPPING in config.py to use all lowercase keys
    encoded_site = ANATOM_SITE_MAPPING.get(internal_site_key, ANATOM_SITE_MAPPING.get('unknown'))
    processed_features.append(float(encoded_site))

    metadata_array = np.array([processed_features], dtype=np.float32) # Shape (1, num_features)
    logger.info(f"Processed metadata array: {metadata_array}")
    return metadata_array