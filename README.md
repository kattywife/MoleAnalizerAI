# SkinSight API

**Version:** 1.1 (Reflects API version, individual models have their own versions)

## Table of Contents

1.  [Introduction](#1-introduction)
2.  [Features](#2-features)
3.  [Workflow Overview](#3-workflow-overview)
4.  [Technology Stack](#4-technology-stack)
5.  [Project Structure](#5-project-structure)
6.  [Setup and Installation](#6-setup-and-installation)
    *   [Prerequisites](#prerequisites)
    *   [Local Setup](#local-setup)
    *   [Docker Setup](#docker-setup)
7.  [Running the Server](#7-running-the-server)
    *   [Local Development](#local-development)
    *   [Using Docker](#using-docker)
8.  [API Endpoints](#8-api-endpoints)
    *   [8.1. `POST /predict`](#81-post-predict)
    *   [8.2. `GET /health`](#82-get-health)
    *   [8.3. `GET /`](#83-get-)
    *   [8.4. `GET /docs`](#84-get-docs)
    *   [8.5. `GET /redoc`](#85-get-redoc)
9.  [Configuration](#9-configuration)
10. [Error Handling](#10-error-handling)
11. [Logging](#11-logging)
12. [Important Notes on Preprocessing](#12-important-notes-on-preprocessing)
13. [Future Considerations](#13-future-considerations)
14. [Troubleshooting](#14-troubleshooting)

## 1. Introduction

The SkinSight API provides a backend service for analyzing images of skin moles to assist dermatologists and oncologists in identifying potential skin conditions. It uses machine learning models to predict the probability of various skin diseases.

**Disclaimer:** This API and its underlying models are intended as a decision support tool for qualified medical professionals. They are **not** a substitute for professional medical advice, diagnosis, or treatment.

## 2. Features

*   **Mole Pre-detection:** An initial ML model screens the image to determine if it likely contains a mole.
*   Accepts skin lesion images (JPEG, PNG).
*   Optionally accepts patient metadata (age, sex, location) in JSON format for detailed classification if a mole is detected.
*   Utilizes different ML models for skin condition classification based on the presence of metadata.
*   Returns probabilistic scores for various skin conditions (e.g., Melanoma, Nevus) if a mole is detected.
*   Returns the probability from the initial mole detection step in all responses.
*   Input validation for image size, type, and metadata.
*   Structured JSON responses for success and errors.
*   Health check endpoint.
*   Automatic API documentation via Swagger UI and ReDoc.
*   Containerized with Docker for easy deployment.

## 3. Workflow Overview

1.  Client sends an image (and optionally metadata) to the `/predict` endpoint.
2.  The image undergoes initial validation (size, type).
3.  A **Mole Detector Model** analyzes the image.
    *   The probability of the image containing a mole is determined.
    *   If the model predicts **"not a mole"** (below a configured threshold):
        *   A response is sent back immediately, indicating it's not a mole, along with the detection probability.
    *   If the model predicts **"a mole"**:
        *   The workflow proceeds to skin condition classification.
4.  **Skin Condition Classification** (if a mole was detected):
    *   If `metadata` was provided: A multi-input (image + metadata) model is used.
    *   If `metadata` was not provided: An image-only model is used.
    *   The model predicts probabilities for various skin conditions.
5.  A JSON response containing the skin condition probabilities, the model version used for classification, and the initial mole detection probability is returned.

## 4. Technology Stack

*   **Language:** Python 3.10+
*   **Web Framework:** FastAPI
*   **ML Libraries:** TensorFlow, Keras 3
*   **Image Processing:** Pillow
*   **ASGI Server:** Uvicorn
*   **Containerization:** Docker
*   **Dependency Management:** pip, `requirements.txt`

## 5. Project Structure

```
skin_cancer_api/
├── app/                    # Main application package
│   ├── __init__.py
│   ├── main.py             # FastAPI application, endpoints
│   ├── model_loader.py     # Loads and manages ML models
│   ├── preprocessing.py    # Data preprocessing functions
│   ├── schemas.py          # Pydantic models for request/response validation
│   └── config.py           # Application configuration
├── model/                    # Directory for trained ML model files
│   ├── mole_detector_epoch_01_val_acc_1.00_96.h5 # Example mole detector model
│   ├── model_epoch_11_val_loss_0.81.h5          # Example multi-input skin classifier
│   └── model_epoch_06_val_loss_0.94_images.h5   # Example image-only skin classifier
├── test_images/            # Optional: For storing test images
│   └── ISIC_0000035.jpg
├── .env.example            # Example environment variables
├── Dockerfile              # Docker configuration
├── README.md               # This file
└── requirements.txt        # Python dependencies
```

## 6. Setup and Installation

### Prerequisites

*   Python 3.10 or higher
*   pip (Python package installer)
*   Docker (optional, for containerized deployment)
*   Git (for cloning the repository, if applicable)
*   Trained model files (see `model/` directory above). Ensure you have all three: the mole detector, the multi-input skin classifier, and the image-only skin classifier.

### Local Setup

1.  **Clone the repository (if applicable):**
    ```bash
    git clone <repository_url>
    cd skin_cancer_api
    ```

2.  **Create and activate a virtual environment:**
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Linux/macOS
    # venv\Scripts\activate    # On Windows
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
    *Note: If you don't have a GPU or don't want to use it, you can install the CPU-only version of TensorFlow. Modify `requirements.txt` to use `tensorflow-cpu` instead of `tensorflow` before running `pip install`.*

4.  **Place Model Files:**
    Ensure your trained model files (mole detector, multi-input skin classifier, image-only skin classifier) are placed in the `model/` directory. Update paths in `app/config.py` if your filenames differ from the examples.

5.  **Environment Variables (Optional):**
    Create a `.env` file in the project root by copying `.env.example`. You can override default configurations here (e.g., `LOG_LEVEL`, model paths, thresholds).
    ```bash
    cp .env.example .env
    # Edit .env if needed
    ```

### Docker Setup

1.  **Ensure Docker is installed and running.**
2.  **Place Model Files:** Ensure all required model files are in the `model/` directory as they will be copied into the Docker image.
3.  **Build the Docker image:**
    From the project root directory (`skin_cancer_api/`):
    ```bash
    docker build -t skinsight-api .
    ```

## 7. Running the Server

### Local Development

From the project root directory (`skin_cancer_api/`):
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
The API will be accessible at `http://localhost:8000`. The `--reload` flag enables auto-reloading on code changes.

### Using Docker

```bash
docker run -d -p 8000:8000 --name skinsight-container skinsight-api
```
*   `-d`: Run in detached mode.
*   `-p 8000:8000`: Map port 8000 of the host to port 8000 of the container.
*   `--name skinsight-container`: Assign a name to the container.

The API will be accessible at `http://localhost:8000`.

To view logs from the Docker container:
```bash
docker logs skinsight-container -f
```

To stop the container:
```bash
docker stop skinsight-container
```

To remove the container:
```bash
docker rm skinsight-container
```

## 8. API Endpoints

### 8.1. `POST /predict`

Analyzes a skin lesion image. First, it determines if the image contains a mole using a pre-detection model. If a mole is detected, it then proceeds to classify skin conditions, optionally using provided patient metadata.

*   **URL:** `/predict`
*   **Method:** `POST`
*   **Content-Type:** `multipart/form-data`

**Form Fields:**

*   `image_file` (file, **required**): Image of the skin lesion (JPEG or PNG). Max size: 10MB (configurable).
*   `metadata` (string, **optional**): JSON string containing patient metadata. If provided *and* a mole is detected by the pre-screener, a multi-input model is used for detailed skin condition classification.
    *   **Example JSON for `metadata`:**
        ```json
        {
          "age": 55,
          "sex": "Male",
          "location": "Trunk"
        }
        ```
    *   **Required `metadata` fields (if `metadata` string is provided):**
        *   `age` (integer, >0)
        *   `sex` (string, e.g., "Male", "Female", "Other" - see `ALLOWED_SEX_VALUES` in `app/config.py`)
        *   `location` (string, e.g., "Trunk", "Head/Neck" - see `ALLOWED_LOCATION_VALUES` in `app/config.py`)

**Success Responses (200 OK):**

The structure of the success response depends on the outcome of the initial mole detection step.

*   **Case 1: Image classified as "Not a Mole" by the pre-detector**
    *   **Content-Type:** `application/json`
    *   **Body Example:**
        ```json
        {
          "message": "The uploaded image is not classified as a mole by the initial screening model.",
          "is_mole": false,
          "mole_detection_probability": 0.3822,
          "model_used": "mole_detector"
        }
        ```

*   **Case 2: Image classified as "Mole" by the pre-detector, followed by Skin Condition Classification**
    *   **Content-Type:** `application/json`
    *   **Body Example (if metadata was provided):**
        ```json
        {
          "predictions": {
            "Melanoma": 0.153,
            "Nevus": 0.701,
            "Basal cell carcinoma": 0.105,
            "Actinic keratosis": 0.021,
            "Benign keratosis-like lesions": 0.010,
            "Dermatofibroma": 0.005,
            "Vascular lesions": 0.005
          },
          "model_version": "1.0.2", // Version of the skin condition classifier model used
          "is_mole": true,
          "mole_detection_probability": 0.9705
        }
        ```
    *   **Body Example (if metadata was NOT provided, image-only skin classification):**
        ```json
        {
          "predictions": {
            "Melanoma": 0.120,
            "Nevus": 0.750,
            // ... other class probabilities
          },
          "model_version": "1.0.0_img_only", // Version of the image-only skin classifier
          "is_mole": true,
          "mole_detection_probability": 0.9650
        }
        ```

**Error Responses:** See [Error Handling](#10-error-handling) for details on 4xx and 5xx error structures. Common errors include invalid input, file too large, or internal server errors if a model fails.

**Example `curl` requests:**

*   **With metadata (targets multi-input skin classifier if mole is detected):**
    ```bash
    curl -X POST \
         -F "image_file=@/path/to/your/image.jpg" \
         -F 'metadata={"age": 55, "sex": "Male", "location": "Trunk"}' \
         http://localhost:8000/predict
    ```

*   **Without metadata (targets image-only skin classifier if mole is detected):**
    ```bash
    curl -X POST \
         -F "image_file=@/path/to/your/image.jpg" \
         http://localhost:8000/predict
    ```

### 8.2. `GET /health`

Checks the health of the API, including the loading status of all machine learning models.

*   **URL:** `/health`
*   **Method:** `GET`
*   **Success Response (200 OK or 503 Service Unavailable):**
    ```json
    {
      "status": "healthy", // "unhealthy" if mole_detector_model is not loaded
      "mole_detector_model_loaded": true,
      "multi_input_skin_model_loaded": true, // or false if not loaded/configured
      "image_only_skin_model_loaded": true // or false if not loaded/configured
      // "reason" field appears if status is "unhealthy"
    }
    ```
    *(The overall `status` field depends critically on the `mole_detector_model_loaded` status).*

### 8.3. `GET /`

A simple welcome endpoint for the API.

*   **URL:** `/`
*   **Method:** `GET`
*   **Success Response (200 OK):**
    ```json
    {
      "message": "Welcome to the SkinSight API. Use the /predict endpoint to analyze images."
    }
    ```

### 8.4. `GET /docs`

Provides interactive API documentation powered by Swagger UI. Allows trying out the API endpoints directly from the browser.

### 8.5. `GET /redoc`

Provides alternative API documentation powered by ReDoc.

## 9. Configuration

Key configurations are managed in `app/config.py` and can be overridden using environment variables (see `.env.example` for a template).

*   **Mole Detector Model:**
    *   `MOLE_DETECTOR_MODEL_PATH`: Path to the mole detector model file.
    *   `MOLE_DETECTOR_IMG_SIZE`: Target image size for the mole detector.
    *   `MOLE_DETECTOR_BASE_MODEL_NAME`: Base architecture name (e.g., 'EfficientNetB0').
    *   `MOLE_DETECTOR_DROPOUT_RATE`: Dropout rate used if rebuilding the model.
    *   `MOLE_DETECTOR_CLASSES`: Expected class names, typically `['not_mole', 'mole']`.
    *   `MOLE_DETECTOR_THRESHOLD`: Probability threshold to classify an image as containing a mole.
*   **Skin Condition Classifier Models:**
    *   `MODEL_PATH`: Path to the multi-input (image + metadata) skin classifier model.
    *   `MODEL_VERSION`: Version string for the multi-input skin classifier.
    *   `IMAGE_ONLY_MODEL_PATH`: Path to the image-only skin classifier model.
    *   `IMAGE_ONLY_MODEL_VERSION`: Version string for the image-only skin classifier.
    *   `SKIN_CLASSIFIER_IMG_SIZE`: Target image size for these models.
    *   `SKIN_CLASSIFIER_BASE_MODEL_NAME`: Base architecture name.
    *   `SKIN_CLASSIFIER_DROPOUT_RATE`: Dropout rate if rebuilding.
    *   `SKIN_CLASSES_DISPLAY`, `SKIN_CLASSES_INTERNAL`, `SKIN_CLASS_NAME_MAPPING`: Definitions for skin condition classes.
    *   `METADATA_FEATURES_COUNT`: Number of metadata features expected by the multi-input model.
*   **API & General:**
    *   `MAX_FILE_SIZE_MB`: Maximum allowed uploaded image file size.
    *   `ALLOWED_IMAGE_TYPES`: List of allowed image MIME types.
    *   `LOG_LEVEL`: Application logging level (e.g., INFO, DEBUG, WARNING, ERROR).
    *   `NOT_A_MOLE_MESSAGE`: Message returned when the pre-detector classifies an image as not a mole.
*   **Metadata Specific (for multi-input skin classifier):**
    *   `SEX_MAPPING`, `ALLOWED_SEX_VALUES`: Configuration for 'sex' metadata.
    *   `ANATOM_SITE_MAPPING`, `ALLOWED_LOCATION_VALUES`: Configuration for 'location' metadata.
    *   `AGE_MEAN_PLACEHOLDER`, `AGE_STD_PLACEHOLDER`: **Placeholder** values for age scaling. See [Important Notes on Preprocessing](#12-important-notes-on-preprocessing).

## 10. Error Handling

The API returns structured JSON error responses for client-side (4xx) and server-side (5xx) errors.

*   **Example 400 Bad Request (e.g., invalid metadata field):**
    ```json
    {
      "error": {
        "code": "INVALID_INPUT",
        "message": "Metadata validation failed.",
        "details": {
            "field": "metadata.age",
            "value_provided": -5,
            "message": "Input should be greater than 0"
        }
      }
    }
    ```
*   **Example 422 Unprocessable Entity (e.g., missing required form field by FastAPI):**
    ```json
    {
        "error": {
            "code": "VALIDATION_ERROR",
            "message": "Input validation failed.",
            "details": [
                {
                    "field": "image_file",
                    "message": "Field required"
                }
            ]
        }
    }
    ```
*   **Example 500 Internal Server Error (e.g., model prediction failure):**
    ```json
    {
      "error": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "An unexpected error occurred while processing the request. Please try again later."
      }
    }
    ```
*   **Example 503 Service Unavailable (e.g., critical model not loaded):**
    ```json
    {
        "error": {
            "code": "MODEL_NOT_READY",
            "message": "The mole detection model is not available."
        }
    }
    ```

## 11. Logging

The application implements logging for requests, responses, errors, and key processing steps.
*   Logs are output to the standard console.
*   The log level can be configured using the `LOG_LEVEL` environment variable (default is "INFO").
*   A middleware logs essential information for each HTTP request: method, URL path, response status code, and processing duration.
*   Detailed logs are generated during model loading and prediction stages.

## 12. Important Notes on Preprocessing

The accuracy of the model predictions heavily relies on consistent preprocessing between the training phase and inference in this API.

*   **Metadata Encoding/Scaling (for Multi-Input Skin Classifier):**
    *   The current implementation in `app/preprocessing.py` uses hardcoded mappings (`SEX_MAPPING`, `ANATOM_SITE_MAPPING`) and placeholder values for age scaling (`AGE_MEAN_PLACEHOLDER`, `AGE_STD_PLACEHOLDER`).
    *   **CRITICAL:** For reliable and accurate predictions in a production environment, these hardcoded/placeholder values **must be replaced**. You should load saved `LabelEncoder` objects (for categorical features like `sex` and `location`) and a `StandardScaler` object (for numerical features like `age`) that were fitted on the original training dataset. This ensures that the data transformations applied during inference are identical to those applied during model training.
    *   These scaler and encoder objects can be saved during the model training phase using libraries like `joblib` or `pickle`, and then loaded within the `app/preprocessing.py` module.

*   **Image Preprocessing:**
    *   Images are resized to the target dimensions specified for each model (`MOLE_DETECTOR_IMG_SIZE`, `SKIN_CLASSIFIER_IMG_SIZE`).
    *   Normalization (e.g., `efficientnet.preprocess_input` or `mobilenet_v2.preprocess_input`) is applied according to the base model architecture used for each respective ML model. Ensure the `BASE_MODEL_NAME` configurations in `app/config.py` match the models.

## 13. Future Considerations (Out of Scope for Current Version)

*   Enhanced user authentication and authorization (e.g., OAuth2, API keys with scopes).
*   More sophisticated rate limiting and request throttling.
*   An endpoint for batch processing multiple images in a single request.
*   An endpoint to retrieve detailed information about available models and their versions.
*   Integration with dedicated monitoring and observability systems (e.g., Prometheus, Grafana, Sentry).
*   Functionality to return model interpretability results (e.g., Grad-CAM heatmaps or LIME explanations).
*   Mechanisms for collecting feedback from medical professionals to facilitate model retraining and improvement (requires significant backend and MLOps infrastructure).

## 14. Troubleshooting

*   **`ModuleNotFoundError`:** Ensure you are running `uvicorn` commands from the project root directory (`skin_cancer_api/`) and that your Python virtual environment is activated. Check your `PYTHONPATH` if issues persist.
*   **Model Not Found Errors (`FileNotFoundError` during startup):**
    *   Verify that all three model files (mole detector, multi-input skin classifier, image-only skin classifier) exist in the `model/` directory.
    *   Double-check that the path configurations (`MOLE_DETECTOR_MODEL_PATH`, `MODEL_PATH`, `IMAGE_ONLY_MODEL_PATH`) in `app/config.py` (or your `.env` file) accurately point to the correct filenames within the `model/` directory.
*   **CUDA Errors (e.g., `failed call to cuInit`, `could not load dynamic library 'libcudart.so.11.0'`):**
    *   If you do not intend to use a GPU for inference, ensure you have installed the CPU-only version of TensorFlow (`tensorflow-cpu`). Modify `requirements.txt` and reinstall.
    *   If GPU support is required, verify that your NVIDIA drivers, CUDA Toolkit, and cuDNN library are correctly installed and their versions are compatible with the TensorFlow version being used. Consult the TensorFlow documentation for official compatibility matrices.
*   **Input Layer Name Mismatches (`ValueError: Missing data for input ...`):**
    *   This error indicates that the dictionary key used when calling `model.predict()` does not match the name of the input layer(s) in the loaded Keras model.
    *   Carefully check the `name` argument of the `tf.keras.layers.Input(...)` layers in your model-building functions in `app/model_loader.py`.
    *   Ensure that the keys in the dictionaries passed to `model.predict()` (both during warm-up in `model_loader.py` and during actual prediction in `main.py`) exactly match these expected input layer names.
*   **Incorrect Predictions or Unexpected Behavior:**
    *   Thoroughly review the preprocessing steps in `app/preprocessing.py` for both images and metadata. Ensure they perfectly align with the preprocessing performed during model training.
    *   Verify that the `MOLE_DETECTOR_THRESHOLD` in `app/config.py` is set to an appropriate value for distinguishing moles from non-moles based on your mole detector's output distribution.
    *   Ensure the model architectures defined in `app/model_loader.py` (the `build_..._definition` functions) accurately reflect the architectures of your saved model files, especially if the system falls back to rebuilding the model and loading weights.
*   **Permission Denied (Docker):** If Docker encounters permission issues when trying to access files (e.g., model files), check the file permissions on your host machine for the directories being copied or mounted into the container.
*   **Large Image Files:** If you are still getting "FILE_TOO_LARGE" errors, ensure the `MAX_FILE_SIZE_MB` in `app/config.py` is set appropriately and that your test images comply with this limit.

