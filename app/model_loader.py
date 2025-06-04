# app/model_loader.py
import tensorflow as tf
try:
    import keras as keras_core
    from keras import layers, models, applications
except ImportError:
    # print("Keras 3 (as 'keras') not found, falling back to tf.keras.") # Less verbose in production
    keras_core = tf.keras
    from tensorflow.keras import layers, models, applications

import numpy as np
import os
import logging

from config import (
    MODEL_PATH, INTERNAL_CLASSES, IMG_SIZE, BASE_MODEL_NAME, DROPOUT_RATE, METADATA_FEATURES_COUNT,
    IMAGE_ONLY_MODEL_PATH # New config for image-only model
)

logger = logging.getLogger(__name__)

# Global variables for models
ml_model_multi_input = None
ml_model_image_only = None

# --- Model Definition for Multi-Input Model (from before) ---
def build_multi_input_model_definition(num_classes, img_size, base_model_name, dropout_rate, metadata_input_shape):
    image_input = layers.Input(shape=(img_size, img_size, 3), name='image_input')
    if base_model_name == 'EfficientNetB0':
        base_model_effnet = applications.EfficientNetB0( # Renamed to avoid clash
            input_shape=(img_size, img_size, 3),
            include_top=False,
            weights='imagenet'
        )
    else:
        raise ValueError(f"Unsupported base model: {base_model_name}")
    base_model_effnet.trainable = False
    x = base_model_effnet(image_input, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    metadata_input = layers.Input(shape=metadata_input_shape, name='metadata_input')
    y = layers.Dense(64, activation='relu')(metadata_input)
    y = layers.Dropout(dropout_rate)(y)
    combined_features = layers.concatenate([x, y])
    z = layers.Dense(128, activation='relu')(combined_features)
    z = layers.Dropout(dropout_rate)(z)
    output_layer = layers.Dense(num_classes, activation='softmax', name='output')(z)
    model = models.Model(inputs=[image_input, metadata_input], outputs=output_layer)
    return model

# --- Model Definition for Image-Only Model ---
# IMPORTANT: This definition MUST match the architecture of your 'model_epoch_06_val_loss_0.94_images.h5'
# This is a common structure for an image-only model based on EfficientNetB0. Adjust if yours is different.
def build_image_only_model_definition(num_classes, img_size, base_model_name, dropout_rate):
    image_input = layers.Input(shape=(img_size, img_size, 3), name='image_input') # Ensure name matches if loading full model

    if base_model_name == 'EfficientNetB0':
        base_model_img_only = applications.EfficientNetB0( # Renamed
            input_shape=(img_size, img_size, 3),
            include_top=False,
            weights='imagenet'
        )
    # Add elif for other base models if you plan to use them
    else:
        raise ValueError(f"Unsupported base model: {base_model_name}")

    base_model_img_only.trainable = False # Set based on how it was trained/saved

    x = base_model_img_only(image_input, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    # Example classification head - adjust to match your image-only model
    x = layers.Dense(128, activation='relu')(x) # Common intermediate dense layer
    x = layers.Dropout(dropout_rate)(x) # Dropout is inactive during inference
    output_layer = layers.Dense(num_classes, activation='softmax', name='output')(x) # Ensure name matches

    model = models.Model(inputs=image_input, outputs=output_layer)
    return model

def _load_and_warmup_model(model_path, model_builder_fn, model_args, warmup_input):
    if not os.path.exists(model_path):
        logger.error(f"Model file not found at {model_path}. Cannot load.")
        raise FileNotFoundError(f"Model file not found at {model_path}")

    logger.info(f"Reconstructing model architecture for {model_path}...")
    model = model_builder_fn(**model_args)
    
    logger.info(f"Loading weights from {model_path}...")
    model.load_weights(model_path)
    logger.info(f"Weights loaded successfully into model from {model_path}.")

    # Warm-up prediction
    model.predict(warmup_input)
    logger.info(f"Model from {model_path} warm-up successful.")
    return model

def load_models(): # Renamed from load_model to load_models
    global ml_model_multi_input, ml_model_image_only

    # --- Load Multi-Input Model ---
    try:
        logger.info("Loading multi-input model...")
        multi_input_args = {
            'num_classes': len(INTERNAL_CLASSES),
            'img_size': IMG_SIZE,
            'base_model_name': BASE_MODEL_NAME,
            'dropout_rate': DROPOUT_RATE,
            'metadata_input_shape': (METADATA_FEATURES_COUNT,)
        }
        dummy_image = np.zeros((1, IMG_SIZE, IMG_SIZE, 3), dtype=np.float32)
        dummy_metadata = np.zeros((1, METADATA_FEATURES_COUNT), dtype=np.float32)
        multi_input_warmup = {'image_input': dummy_image, 'metadata_input': dummy_metadata}
        
        ml_model_multi_input = _load_and_warmup_model(MODEL_PATH, build_multi_input_model_definition, multi_input_args, multi_input_warmup)
        logger.info("Multi-input ML Model loaded successfully.")
    except Exception as e:
        logger.error(f"Error loading multi-input ML model: {e}", exc_info=True)
        raise RuntimeError(f"Failed to load multi-input model: {e}") # Or handle more gracefully

    # --- Load Image-Only Model ---
    if not IMAGE_ONLY_MODEL_PATH or not os.path.exists(IMAGE_ONLY_MODEL_PATH):
        logger.warning(f"Image-only model path not configured or file not found: {IMAGE_ONLY_MODEL_PATH}. Image-only predictions will not be available.")
        ml_model_image_only = None # Explicitly set to None
    else:
        try:
            logger.info("Loading image-only model...")
            image_only_args = {
                'num_classes': len(INTERNAL_CLASSES), # Assuming same classes
                'img_size': IMG_SIZE,
                'base_model_name': BASE_MODEL_NAME, # Assuming same base model type
                'dropout_rate': DROPOUT_RATE # Assuming same dropout rate
            }
            # Warmup input for image-only model is just the image
            image_only_warmup = dummy_image # Re-use dummy_image from above
            
            ml_model_image_only = _load_and_warmup_model(IMAGE_ONLY_MODEL_PATH, build_image_only_model_definition, image_only_args, image_only_warmup)
            logger.info("Image-only ML Model loaded successfully.")
        except Exception as e:
            logger.error(f"Error loading image-only ML model: {e}", exc_info=True)
            # Decide if this is critical. For now, allow app to start but log error.
            ml_model_image_only = None
            logger.warning("Image-only model failed to load. Predictions requiring it will fail.")


def get_multi_input_model():
    if ml_model_multi_input is None:
        # This should ideally not happen if load_models is called on startup.
        logger.error("Multi-input model was not loaded. This indicates a startup problem.")
        raise RuntimeError("Multi-input model is not available.")
    return ml_model_multi_input

def get_image_only_model():
    if ml_model_image_only is None:
        logger.error("Image-only model was not loaded. This indicates a startup problem or misconfiguration.")
        raise RuntimeError("Image-only model is not available.")
    return ml_model_image_only