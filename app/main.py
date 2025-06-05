# app/main.py
from fastapi import FastAPI, File, UploadFile, Form, HTTPException, status, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

from fastapi.middleware.cors import CORSMiddleware
from pydantic import ValidationError as PydanticValidationError
import json
import logging
import time

from typing import Optional, AsyncGenerator # For lifespan, if used
from contextlib import asynccontextmanager # For lifespan, if used

# Assuming your Pydantic models are in schemas.py
import schemas # Import the whole module
import preprocessing
import model_loader

# Import all necessary config variables
from config import (
    LOG_LEVEL, MODEL_VERSION, IMAGE_ONLY_MODEL_VERSION, NOT_A_MOLE_MESSAGE,
    SKIN_CLASS_NAME_MAPPING, SKIN_CLASSES_INTERNAL,
    ALLOWED_IMAGE_TYPES, MAX_FILE_SIZE_MB,
    MOLE_DETECTOR_CLASSES, MOLE_DETECTOR_THRESHOLD # Mole detector config
)

logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# OR if still using @app.on_event (as per your provided context):
app = FastAPI(title="SkinSight API", version="1.1", description="API for skin lesion analysis with mole pre-detection.")


# Configure CORS
origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins, # Allows specific origins
    allow_credentials=True,
    allow_methods=["*"], # Allows all methods (GET, POST, etc.)
    allow_headers=["*"], # Allows all headers
)

@app.on_event("startup")
async def startup_event():
    logger.info("Application startup...")
    try:
        model_loader.load_models()
        if model_loader.ml_model_mole_detector is None:
            logger.critical("CRITICAL: Mole detector model failed to load. Application will not function correctly.")
        else: logger.info("Mole detector model loaded.")
        if model_loader.ml_model_multi_input_skin is None:
            logger.warning("Multi-input skin classifier not loaded (optional or misconfigured).")
        else: logger.info("Multi-input skin classifier model loaded.")
        if model_loader.ml_model_image_only_skin is None:
            logger.warning("Image-only skin classifier not loaded (optional or misconfigured).")
        else: logger.info("Image-only skin classifier model loaded.")
        logger.info("ML Models loading process complete.")
    except Exception as e:
        logger.critical(f"Critical failure during model loading on startup: {e}", exc_info=True)
        raise RuntimeError(f"Application startup failed: Could not load critical models. {e}")

# --- Exception Handlers & Middleware (ensure these are defined or imported if used) ---
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.warning(f"Validation error for request {request.url.path}: {exc.errors()}")
    error_details = []
    for error in exc.errors():
        field = " -> ".join(map(str, error["loc"]))
        if error["loc"] and error["loc"][0] == 'body':
            field = " -> ".join(map(str, error["loc"][1:]))
        error_details.append(schemas.ErrorDetail(field=field, message=error["msg"]))
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=schemas.ErrorResponse(
            error=schemas.ErrorContent(code="VALIDATION_ERROR", message="Input validation failed.", details=error_details)
        ).dict(exclude_none=True)
    )

async def http_error_handler(request: Request, exc: HTTPException):
    logger.error(f"HTTPException for request {request.url.path}: {exc.status_code} - {exc.detail}")
    error_code, error_message, details_obj = "UNKNOWN_ERROR", str(exc.detail), None
    if isinstance(exc.detail, dict):
        error_code = exc.detail.get("code", error_code)
        error_message = exc.detail.get("message", error_message)
        if "field" in exc.detail or "value_provided" in exc.detail:
             details_obj = schemas.ErrorDetail(field=exc.detail.get("field"), value_provided=exc.detail.get("value_provided"), message=exc.detail.get("details_message"))
    elif isinstance(exc.detail, str):
        if exc.status_code == status.HTTP_400_BAD_REQUEST: error_code = "INVALID_INPUT"
        elif exc.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR:
            error_code = "INTERNAL_SERVER_ERROR"
            error_message = "An unexpected error occurred while processing the request. Please try again later."
    return JSONResponse(
        status_code=exc.status_code,
        content=schemas.ErrorResponse(error=schemas.ErrorContent(code=error_code, message=error_message, details=details_obj)).dict(exclude_none=True)
    )
app.add_exception_handler(HTTPException, http_error_handler)

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    logger.info(f"Request: {request.method} {request.url.path} - Status: {response.status_code} - Duration: {process_time:.4f}s")
    return response

# --- API Endpoints ---
@app.get("/", tags=["General"])
async def read_root():
    return {"message": "Welcome to the SkinSight API. Use the /predict endpoint to analyze images."}

@app.get("/health", tags=["General"])
async def health_check():
    detector_loaded = model_loader.ml_model_mole_detector is not None
    multi_skin_loaded = model_loader.ml_model_multi_input_skin is not None
    img_only_skin_loaded = model_loader.ml_model_image_only_skin is not None
    is_healthy = detector_loaded # Mole detector is critical
    return JSONResponse(
        status_code=status.HTTP_200_OK if is_healthy else status.HTTP_503_SERVICE_UNAVAILABLE,
        content={
            "status": "healthy" if is_healthy else "unhealthy",
            "mole_detector_model_loaded": detector_loaded,
            "multi_input_skin_model_loaded": multi_skin_loaded,
            "image_only_skin_model_loaded": img_only_skin_loaded,
            "reason": "Mole detector is critical and not loaded." if not detector_loaded else None
        }
    )

@app.post("/predict",
          responses={
              status.HTTP_200_OK: {
                  "description": "Successful prediction (either mole classification or 'not a mole' determination).",
                  "content": {
                      "application/json": {
                          "examples": {
                              "mole_classification": {
                                  "summary": "Mole Classification Result",
                                  "value": {
                                      "predictions": {"Melanoma": 0.1, "Nevus": 0.9},
                                      "model_version": "1.0.2",
                                      "mole_detection_probability": 0.9705, # Added
                                      "is_mole": True # Added
                                  }
                              },
                              "not_a_mole": {
                                  "summary": "Not a Mole Result",
                                  "value": {
                                      "message": NOT_A_MOLE_MESSAGE,
                                      "is_mole": False,
                                      "model_used": "mole_detector",
                                      "mole_detection_probability": 0.3822 # Added
                                  }
                              }
                          }
                      }
                  }
              },
              status.HTTP_400_BAD_REQUEST: {"model": schemas.ErrorResponse},
              status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": schemas.CustomHTTPValidationError if hasattr(schemas, 'CustomHTTPValidationError') else schemas.ErrorResponse },
              status.HTTP_500_INTERNAL_SERVER_ERROR: {"model": schemas.ErrorResponse},
              status.HTTP_503_SERVICE_UNAVAILABLE: {"model": schemas.ErrorResponse}
          },
          tags=["Analysis"])
async def predict_skin_lesion(
    image_file: UploadFile = File(..., description="Image of the skin lesion (JPEG or PNG). Max 10MB."),
    metadata: Optional[str] = Form(None, alias="metadata", description='OPTIONAL JSON string with patient metadata.')
):
    logger.info(f"Received prediction request. Image: {image_file.filename}, Metadata: {'Provided' if metadata else 'Not provided'}")

    # --- Initial Image Validation (common) ---
    if image_file.size > MAX_FILE_SIZE_MB * 1024 * 1024:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "FILE_TOO_LARGE", "message": f"Image file size exceeds limit of {MAX_FILE_SIZE_MB}MB.", "field": "image_file"})
    if image_file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "INVALID_FILE_TYPE", "message": f"Invalid image file type. Allowed types: {', '.join(ALLOWED_IMAGE_TYPES)}.", "field": "image_file"})

    image_bytes = await image_file.read() # Read once

    # Variable to store mole detection probability
    mole_detection_prob_value: Optional[float] = None

    # --- Step 1: Mole Detection ---
    try:
        logger.debug("Preprocessing image for mole detector...")
        preprocessed_image_for_detector = preprocessing.preprocess_image_for_mole_detector(image_bytes)
        
        logger.debug("Running mole detection model...")
        mole_detector_model = model_loader.get_mole_detector_model()
        # Ensure input key matches mole detector model's expectation (e.g., 'input_layer')
        mole_detector_input_data = {'input_layer': preprocessed_image_for_detector}
        detector_prediction_probs = mole_detector_model.predict(mole_detector_input_data)
        
        mole_detection_prob_value = float(f"{detector_prediction_probs[0][0]:.4f}") # Format and store
        logger.info(f"Mole detection probability: {mole_detection_prob_value}")

        is_mole = mole_detection_prob_value > MOLE_DETECTOR_THRESHOLD
        predicted_detector_label = MOLE_DETECTOR_CLASSES[1] if is_mole else MOLE_DETECTOR_CLASSES[0]
        logger.info(f"Mole detector classified as: {predicted_detector_label}")

        if not is_mole:
            logger.info("Image classified as 'not_mole'. Returning early.")
            return schemas.NotAMoleResponse(
                message=NOT_A_MOLE_MESSAGE,
                mole_detection_probability=mole_detection_prob_value
            )

    except RuntimeError as e:
         logger.critical(f"Mole detector model error: {e}", exc_info=True)
         raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail={"code": "MODEL_NOT_READY", "message": "The mole detection model is not available."})
    except ValueError as e:
        logger.error(f"Mole detector preprocessing error: {e}", exc_info=True)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "PREPROCESSING_ERROR_DETECTOR", "message": str(e)})
    except Exception as e:
        logger.error(f"Unexpected error during mole detection: {e}", exc_info=True)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR_DETECTOR", "message": "Error during mole detection."})

    # --- Step 2: Skin Condition Classification (if identified as a mole) ---
    logger.info(f"Image classified as 'mole' (Prob: {mole_detection_prob_value}). Proceeding to skin condition classification.")
    try:
        preprocessed_image_for_skin_classifier = preprocessing.preprocess_image_for_skin_classifier(image_bytes)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "PREPROCESSING_ERROR_SKIN", "message": str(e)})
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR_SKIN_PREPROC", "message": "Error during skin image preprocessing."})

    raw_skin_predictions = None
    used_skin_model_version = None

    if metadata:
        try:
            metadata_dict = json.loads(metadata)
            parsed_metadata = schemas.MetadataBase(**metadata_dict)
            preprocessed_metadata_values = preprocessing.preprocess_metadata(parsed_metadata)
        except json.JSONDecodeError: raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "INVALID_JSON_METADATA", "message": "Metadata is not a valid JSON string.", "field": "metadata"})
        except PydanticValidationError as e:
            error_details = [schemas.ErrorDetail(field="metadata." + ".".join(map(str, err['loc'])), value_provided=err.get('input', str(err.get('input'))), message=err['msg']) for err in e.errors()]
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"code": "INVALID_INPUT", "message": "Metadata validation failed.", "details": error_details[0] if len(error_details) == 1 else error_details})
        except Exception as e: raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "METADATA_PREPROCESSING_FAILURE", "message": f"Failed to preprocess metadata: {e}"})

        model_input_multi = {
            'image_input': preprocessed_image_for_skin_classifier, # Ensure this key matches model
            'metadata_input': preprocessed_metadata_values     # Ensure this key matches model
        }
        try:
            model_multi_skin = model_loader.get_multi_input_skin_model()
            raw_skin_predictions = model_multi_skin.predict(model_input_multi)
            used_skin_model_version = MODEL_VERSION
        except RuntimeError as e: raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail={"code": "MODEL_NOT_READY", "message": "Multi-input skin model not ready."})
        except Exception as e: raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR", "message": "Error during multi-input skin model processing."})
    else: # Image-only skin classification
        try:
            model_image_only_skin = model_loader.get_image_only_skin_model()
            # Ensure this key matches model
            raw_skin_predictions = model_image_only_skin.predict(
                {'image_input': preprocessed_image_for_skin_classifier}
            )
            used_skin_model_version = IMAGE_ONLY_MODEL_VERSION
        except RuntimeError as e: raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail={"code": "MODEL_NOT_READY", "message": "Image-only skin model not ready."})
        except Exception as e: raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "INTERNAL_SERVER_ERROR", "message": "Error during image-only skin model processing."})

    if raw_skin_predictions is None or len(raw_skin_predictions[0]) != len(SKIN_CLASSES_INTERNAL):
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"code": "MODEL_OUTPUT_MISMATCH", "message": "Skin classifier output issue."})

    predictions_dict = {
        SKIN_CLASS_NAME_MAPPING[SKIN_CLASSES_INTERNAL[i]]: float(f"{raw_skin_predictions[0][i]:.3f}")
        for i in range(len(SKIN_CLASSES_INTERNAL))
    }
    logger.info(f"Skin classification successful (model: {used_skin_model_version}). Results: {predictions_dict}")
    
    return schemas.PredictionResponse(
        predictions=predictions_dict,
        model_version=used_skin_model_version,
        mole_detection_probability=mole_detection_prob_value
        # is_mole=True will be set by default in Pydantic model schemas.PredictionResponse
    )

if __name__ == "__main__":
    logger.info("Starting Uvicorn server for local development (via __main__)...")
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level=LOG_LEVEL.lower() if isinstance(LOG_LEVEL, str) else "info")