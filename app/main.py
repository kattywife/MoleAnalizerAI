# app/main.py
from fastapi import FastAPI, File, UploadFile, Form, HTTPException, status, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError as PydanticValidationError
import json
import logging
import time
from typing import Optional # Import Optional

import schemas, preprocessing, model_loader
from config import (
    LOG_LEVEL, MODEL_VERSION, IMAGE_ONLY_MODEL_VERSION, # Import new version
    CLASSES, INTERNAL_CLASSES, CLASS_NAME_MAPPING, # Ensure these are available
    ALLOWED_IMAGE_TYPES, MAX_FILE_SIZE_MB # Keep these from config
)


logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(title="SkinSight API", version="1.0", description="...")

@app.on_event("startup")
async def startup_event():
    logger.info("Application startup...")
    try:
        model_loader.load_models() # Changed from load_model
        logger.info("ML Models loaded (or attempted to load).")
    except Exception as e:
        logger.critical(f"Critical failure during model loading on startup: {e}", exc_info=True)
        raise RuntimeError(f"Application startup failed: Could not load critical models. {e}")

# ... (shutdown_event, exception handlers, middleware, root, health_check remain mostly the same) ...
# Adjust health_check if needed to report status of both models
@app.get("/health", tags=["General"])
async def health_check():
    multi_loaded = model_loader.ml_model_multi_input is not None
    img_only_loaded = model_loader.ml_model_image_only is not None
    
    if multi_loaded: # At least the primary model must be loaded
        return {
            "status": "healthy",
            "multi_input_model_loaded": multi_loaded,
            "image_only_model_loaded": img_only_loaded
        }
    else:
        logger.error("Health check failed: Multi-input model not loaded.")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "unhealthy",
                "multi_input_model_loaded": multi_loaded,
                "image_only_model_loaded": img_only_loaded,
                "reason": "Critical model (multi-input) not loaded"
            }
        )


@app.post("/predict",
          response_model=schemas.PredictionResponse,
          # ... (responses remain the same) ...
          tags=["Analysis"])
async def predict_skin_lesion(
    image_file: UploadFile = File(..., description="Image of the skin lesion (JPEG or PNG). Max 10MB."),
    metadata: Optional[str] = Form(None, alias="metadata", description='OPTIONAL JSON string with patient metadata.') # Made Optional, default None
):
    logger.info(f"Received prediction request. Image: {image_file.filename}, Metadata (raw): {metadata if metadata else 'Not provided'}")

    # --- Image Validation (common for both paths) ---
    if image_file.size > MAX_FILE_SIZE_MB * 1024 * 1024:
        # ... (error handling as before) ...
        logger.warning(f"Image file too large: {image_file.size} bytes. Max: {MAX_FILE_SIZE_MB}MB")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "FILE_TOO_LARGE", "message": f"Image file size exceeds limit of {MAX_FILE_SIZE_MB}MB.", "field": "image_file"})
    if image_file.content_type not in ALLOWED_IMAGE_TYPES:
        # ... (error handling as before) ...
        logger.warning(f"Invalid image content type: {image_file.content_type}.")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "INVALID_FILE_TYPE", "message": f"Invalid image file type. Allowed types: {', '.join(ALLOWED_IMAGE_TYPES)}.", "field": "image_file"})

    # --- Preprocess Image (common for both paths) ---
    try:
        image_bytes = await image_file.read()
        logger.debug(f"Image file read, size: {len(image_bytes)} bytes.")
        preprocessed_image = preprocessing.load_and_preprocess_image_from_bytes(image_bytes)
        logger.debug("Image preprocessed successfully.")
    except ValueError as e:
        logger.error(f"Image preprocessing error: {e}", exc_info=True)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "PREPROCESSING_ERROR", "message": str(e)})
    except Exception as e:
        logger.error(f"Unexpected error during image preprocessing: {e}", exc_info=True)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR", "message": "An unexpected error occurred during image preprocessing."})

    raw_predictions = None
    used_model_version = None

    if metadata:
        # --- Path for prediction WITH METADATA ---
        logger.info("Processing with metadata.")
        try:
            metadata_dict = json.loads(metadata)
            parsed_metadata = schemas.MetadataBase(**metadata_dict)
            logger.debug(f"Parsed and validated metadata: {parsed_metadata.dict()}")
        except json.JSONDecodeError:
            # ... (error handling as before for metadata.json) ...
            logger.warning(f"Invalid JSON format for metadata: {metadata}", exc_info=True)
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "INVALID_JSON_METADATA", "message": "Metadata is not a valid JSON string.", "field": "metadata"})
        except PydanticValidationError as e:
            # ... (error handling as before for metadata content) ...
            logger.warning(f"Metadata validation failed: {e.errors()}", exc_info=True)
            error_details = [schemas.ErrorDetail(field="metadata." + ".".join(map(str, err['loc'])), value_provided=err.get('input', str(err.get('input'))), message=err['msg']) for err in e.errors()]
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "INVALID_INPUT", "message": "Metadata validation failed.", "details": error_details[0] if len(error_details) == 1 else error_details})

        try:
            preprocessed_metadata_values = preprocessing.preprocess_metadata(parsed_metadata)
            logger.debug("Metadata preprocessed successfully.")
        except Exception as e: # Catch any error from metadata preprocessing
            logger.error(f"Metadata preprocessing error: {e}", exc_info=True)
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "METADATA_PREPROCESSING_FAILURE", "message": f"Failed to preprocess metadata: {e}"})


        model_input_multi = {
            'image_input': preprocessed_image,
            'metadata_input': preprocessed_metadata_values
        }
        
        try:
            logger.debug("Sending data to multi-input model for prediction...")
            model_multi = model_loader.get_multi_input_model() # Get the specific model
            raw_predictions = model_multi.predict(model_input_multi)
            used_model_version = MODEL_VERSION
            logger.debug(f"Raw multi-input model predictions: {raw_predictions}")
        except RuntimeError as e: # Catch model not loaded specifically
             logger.critical(f"Multi-input model prediction error - Model not available: {e}", exc_info=True)
             raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail={"code": "MODEL_NOT_READY", "message": "The multi-input analysis model is not ready."})
        except Exception as e:
            logger.error(f"Error during multi-input model prediction: {e}", exc_info=True)
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR", "message": "Error during multi-input model processing."})

    else:
        # --- Path for prediction IMAGE-ONLY ---
        logger.info("Processing image-only.")
        try:
            logger.debug("Sending data to image-only model for prediction...")
            model_image_only = model_loader.get_image_only_model() # Get the specific model
            # Image-only model expects just the image array, not a dict (usually)
            # Check your image-only model's expected input format.
            # If it's a Keras model built with a named Input layer, it might expect a dict: {'image_input': preprocessed_image}
            # If it's a simpler sequential model or functional model taking raw tensor, then just preprocessed_image
            
            # Assuming image_input as key if build_image_only_model_definition used a named Input layer
            # Otherwise, it might just be: raw_predictions = model_image_only.predict(preprocessed_image)
            raw_predictions = model_image_only.predict({'image_input': preprocessed_image})
            used_model_version = IMAGE_ONLY_MODEL_VERSION # Use the specific version for this model
            logger.debug(f"Raw image-only model predictions: {raw_predictions}")
        except RuntimeError as e: # Catch model not loaded specifically
             logger.critical(f"Image-only model prediction error - Model not available: {e}", exc_info=True)
             raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail={"code": "MODEL_NOT_READY", "message": "The image-only analysis model is not ready."})
        except Exception as e:
            logger.error(f"Error during image-only model prediction: {e}", exc_info=True)
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR", "message": "Error during image-only model processing."})

    # --- Format and return result (common for both paths) ---
    if raw_predictions is None or len(raw_predictions[0]) != len(INTERNAL_CLASSES):
        logger.error(f"Model output issue. Predictions: {raw_predictions}, Expected classes: {len(INTERNAL_CLASSES)}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "MODEL_OUTPUT_MISMATCH", "message": "Model output issue."})

    predictions_dict = {
        CLASS_NAME_MAPPING[INTERNAL_CLASSES[i]]: float(f"{raw_predictions[0][i]:.3f}") # Or :.4f from your test
        for i in range(len(INTERNAL_CLASSES))
    }

    logger.info(f"Prediction successful using model version {used_model_version}. Results: {predictions_dict}")
    return schemas.PredictionResponse(
        predictions=predictions_dict,
        model_version=used_model_version
    )

# if __name__ == "__main__": (keep this for local dev if you use python app/main.py)

if __name__ == "__main__":
    import uvicorn
    # This is for local development. For production, use Gunicorn with Uvicorn workers.
    logger.info("Starting Uvicorn server for local development...")
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")