# app/model_loader.py
import tensorflow as tf
try:
    import keras as keras_core
    from keras import layers, models, applications
except ImportError:
    keras_core = tf.keras
    from tensorflow.keras import layers, models, applications

import numpy as np
import os
import logging

# Ensure all necessary config variables are imported
from config import (
    MODEL_PATH, IMAGE_ONLY_MODEL_PATH, MOLE_DETECTOR_MODEL_PATH,
    SKIN_CLASSES_INTERNAL, METADATA_FEATURES_COUNT,
    SKIN_CLASSIFIER_IMG_SIZE, SKIN_CLASSIFIER_BASE_MODEL_NAME, SKIN_CLASSIFIER_DROPOUT_RATE,
    MOLE_DETECTOR_IMG_SIZE, MOLE_DETECTOR_BASE_MODEL_NAME, MOLE_DETECTOR_DROPOUT_RATE, MOLE_DETECTOR_CLASSES
)

logger = logging.getLogger(__name__)

ml_model_multi_input_skin = None
ml_model_image_only_skin = None
ml_model_mole_detector = None


# --- Model Definition for Multi-Input Skin Classifier ---
def build_multi_input_skin_classifier_definition(num_classes, img_size, base_model_name, dropout_rate, metadata_input_shape):
    # Input layers named to match expected keys by the saved model if it's a full model
    image_input_tensor = layers.Input(shape=(img_size, img_size, 3), name='image_input') # CORRECTED NAME
    metadata_input_tensor = layers.Input(shape=metadata_input_shape, name='metadata_input') # CORRECTED NAME

    if base_model_name == 'EfficientNetB0':
        base_model_effnet = applications.EfficientNetB0(input_shape=(img_size, img_size, 3), include_top=False, weights='imagenet')
    else:
        raise ValueError(f"Unsupported base model: {base_model_name}")
    base_model_effnet.trainable = False # As per initial training setup

    x = base_model_effnet(image_input_tensor, training=False)
    x = layers.GlobalAveragePooling2D()(x)

    y = layers.Dense(64, activation='relu')(metadata_input_tensor)
    y = layers.Dropout(dropout_rate)(y)

    combined_features = layers.concatenate([x, y])
    z = layers.Dense(128, activation='relu')(combined_features)
    z = layers.Dropout(dropout_rate)(z)
    # Output layer name can be unique if desired, doesn't affect input matching
    output_layer = layers.Dense(num_classes, activation='softmax', name='output_skin_multi')(z)
    model = models.Model(inputs=[image_input_tensor, metadata_input_tensor], outputs=output_layer)
    return model

# --- Model Definition for Image-Only Skin Classifier ---
def build_image_only_skin_classifier_definition(num_classes, img_size, base_model_name, dropout_rate):
    # Input layer named to match expected key by the saved model
    image_input_tensor = layers.Input(shape=(img_size, img_size, 3), name='image_input') # CORRECTED NAME

    if base_model_name == 'EfficientNetB0':
        base_model_img_only = applications.EfficientNetB0(input_shape=(img_size, img_size, 3), include_top=False, weights='imagenet')
    else:
        raise ValueError(f"Unsupported base model: {base_model_name}")
    base_model_img_only.trainable = False

    x = base_model_img_only(image_input_tensor, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dense(128, activation='relu')(x)
    x = layers.Dropout(dropout_rate)(x)
    # Output layer name can be unique
    output_layer = layers.Dense(num_classes, activation='softmax', name='output_skin_imgonly')(x)
    model = models.Model(inputs=image_input_tensor, outputs=output_layer)
    return model

# --- Model Definition for Mole Detector (Binary Classifier) ---
def build_mole_detector_model_definition(img_size_local, base_model_name_local, dropout_rate_local):
    # Input layer named to match expected key by the saved model
    input_tensor = tf.keras.layers.Input(shape=(img_size_local, img_size_local, 3), name="input_layer") # CORRECTED NAME

    if base_model_name_local == 'EfficientNetB0':
        base_model_builder = tf.keras.applications.EfficientNetB0
    elif base_model_name_local == 'MobileNetV2':
        base_model_builder = tf.keras.applications.MobileNetV2
    else:
        raise ValueError(f"Unsupported base model for mole detector rebuilding: {base_model_name_local}")

    base_model = base_model_builder(input_tensor=input_tensor, include_top=False, weights=None)
    x = base_model.output
    x = tf.keras.layers.GlobalAveragePooling2D(name="gap_mole_detector")(x)
    x = tf.keras.layers.Dense(128, activation='relu', name="dense_1_mole_detector")(x)
    x = tf.keras.layers.Dropout(dropout_rate_local, name="dropout_mole_detector")(x)
    # Output layer name can be unique
    output_tensor = tf.keras.layers.Dense(1, activation='sigmoid', name="output_mole_detector")(x)
    rebuilt_model = tf.keras.models.Model(inputs=input_tensor, outputs=output_tensor)
    return rebuilt_model

def _load_and_warmup_model_generic(model_path, model_name_log, model_builder_fn, model_args, warmup_input_fn):
    if not model_path or not os.path.exists(model_path):
        logger.warning(f"{model_name_log} model path not configured or file not found: {model_path}. Model will not be loaded.")
        return None
    
    model = None
    try:
        logger.info(f"Attempting standard load for {model_name_log} from {model_path}...")
        model = keras_core.models.load_model(model_path, compile=False)
        logger.info(f"{model_name_log} model loaded successfully (standard load_model) from {model_path}.")
    except Exception as e1:
        logger.warning(f"Standard load_model for {model_name_log} failed: {e1}. Attempting rebuild and weight loading...")
        try:
            model = model_builder_fn(**model_args)
            model.load_weights(model_path)
            logger.info(f"{model_name_log} model loaded successfully (rebuild & load_weights) from {model_path}.")
        except Exception as e2:
            logger.error(f"Failed to load {model_name_log} by rebuilding and loading weights: {e2}", exc_info=True)
            return None

    if model:
        try:
            warmup_data = warmup_input_fn()
            logger.debug(f"Warming up {model_name_log} with input keys: {list(warmup_data.keys()) if isinstance(warmup_data, dict) else 'N/A (direct tensor)'}")
            model.predict(warmup_data)
            logger.info(f"{model_name_log} model warm-up successful.")
        except Exception as e_warmup:
            logger.error(f"Error during {model_name_log} model warm-up: {e_warmup}", exc_info=True)
            # Optionally set model to None if warm-up fails critically, e.g., model = None
            # This will then be caught by the get_..._model() functions
    return model


def load_models():
    global ml_model_multi_input_skin, ml_model_image_only_skin, ml_model_mole_detector

    # --- Load Mole Detector Model ---
    mole_detector_args = {
        'img_size_local': MOLE_DETECTOR_IMG_SIZE,
        'base_model_name_local': MOLE_DETECTOR_BASE_MODEL_NAME,
        'dropout_rate_local': MOLE_DETECTOR_DROPOUT_RATE
    }
    def mole_detector_warmup_input():
        # Key matches 'name' in build_mole_detector_model_definition's Input layer
        return {'input_layer': np.zeros((1, MOLE_DETECTOR_IMG_SIZE, MOLE_DETECTOR_IMG_SIZE, 3), dtype=np.float32)}
    
    ml_model_mole_detector = _load_and_warmup_model_generic(
        MOLE_DETECTOR_MODEL_PATH, "Mole Detector",
        build_mole_detector_model_definition, mole_detector_args,
        mole_detector_warmup_input
    )
    if ml_model_mole_detector is None:
        logger.critical("Mole detector model FAILED to load. This is a critical component.")

    # --- Load Multi-Input Skin Classifier ---
    multi_input_skin_args = {
        'num_classes': len(SKIN_CLASSES_INTERNAL), 'img_size': SKIN_CLASSIFIER_IMG_SIZE,
        'base_model_name': SKIN_CLASSIFIER_BASE_MODEL_NAME, 'dropout_rate': SKIN_CLASSIFIER_DROPOUT_RATE,
        'metadata_input_shape': (METADATA_FEATURES_COUNT,)
    }
    def multi_input_skin_warmup_input():
        # Keys match 'name' attributes in build_multi_input_skin_classifier_definition's Input layers
        return {
            'image_input': np.zeros((1, SKIN_CLASSIFIER_IMG_SIZE, SKIN_CLASSIFIER_IMG_SIZE, 3), dtype=np.float32),
            'metadata_input': np.zeros((1, METADATA_FEATURES_COUNT), dtype=np.float32)
        }
    ml_model_multi_input_skin = _load_and_warmup_model_generic(
        MODEL_PATH, "Multi-Input Skin Classifier",
        build_multi_input_skin_classifier_definition, multi_input_skin_args,
        multi_input_skin_warmup_input
    )

    # --- Load Image-Only Skin Classifier ---
    image_only_skin_args = {
        'num_classes': len(SKIN_CLASSES_INTERNAL), 'img_size': SKIN_CLASSIFIER_IMG_SIZE,
        'base_model_name': SKIN_CLASSIFIER_BASE_MODEL_NAME, 'dropout_rate': SKIN_CLASSIFIER_DROPOUT_RATE
    }
    def image_only_skin_warmup_input():
        # Key matches 'name' in build_image_only_skin_classifier_definition's Input layer
        return {'image_input': np.zeros((1, SKIN_CLASSIFIER_IMG_SIZE, SKIN_CLASSIFIER_IMG_SIZE, 3), dtype=np.float32)}

    ml_model_image_only_skin = _load_and_warmup_model_generic(
        IMAGE_ONLY_MODEL_PATH, "Image-Only Skin Classifier",
        build_image_only_skin_classifier_definition, image_only_skin_args,
        image_only_skin_warmup_input
    )

# --- Getters for models ---
def get_mole_detector_model():
    if ml_model_mole_detector is None:
        logger.error("Mole detector model is not available (load failed or not configured).")
        raise RuntimeError("Mole detector model is not available.")
    return ml_model_mole_detector

def get_multi_input_skin_model():
    if ml_model_multi_input_skin is None:
        logger.error("Multi-input skin classifier model is not available.")
        raise RuntimeError("Multi-input skin classifier model is not available.")
    return ml_model_multi_input_skin

def get_image_only_skin_model():
    if ml_model_image_only_skin is None:
        logger.error("Image-only skin classifier model is not available.")
        raise RuntimeError("Image-only skin classifier model is not available.")
    return ml_model_image_only_skin