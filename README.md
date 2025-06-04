```markdown
# SkinSight API

**Version:** 1.0 (Reflects API version, individual models have their own versions)

## Table of Contents

1.  [Introduction](#1-introduction)
2.  [Features](#2-features)
3.  [Technology Stack](#3-technology-stack)
4.  [Project Structure](#4-project-structure)
5.  [Setup and Installation](#5-setup-and-installation)
    *   [Prerequisites](#prerequisites)
    *   [Local Setup](#local-setup)
    *   [Docker Setup](#docker-setup)
6.  [Running the Server](#6-running-the-server)
    *   [Local Development](#local-development)
    *   [Using Docker](#using-docker)
7.  [API Endpoints](#7-api-endpoints)
    *   [7.1. `POST /predict`](#71-post-predict)
    *   [7.2. `GET /health`](#72-get-health)
    *   [7.3. `GET /`](#73-get-)
    *   [7.4. `GET /docs`](#74-get-docs)
    *   [7.5. `GET /redoc`](#75-get-redoc)
8.  [Configuration](#8-configuration)
9.  [Error Handling](#9-error-handling)
10. [Logging](#10-logging)
11. [Important Notes on Preprocessing](#11-important-notes-on-preprocessing)
12. [Future Considerations](#12-future-considerations)
13. [Troubleshooting](#13-troubleshooting)

## 1. Introduction

The SkinSight API provides a backend service for analyzing images of skin moles to assist dermatologists and oncologists in identifying potential skin conditions. It uses machine learning models to predict the probability of various skin diseases.

**Disclaimer:** This API and its underlying models are intended as a decision support tool for qualified medical professionals. They are **not** a substitute for professional medical advice, diagnosis, or treatment.

The API can process requests in two ways:
*   With an image and patient metadata: Utilizes a multi-input ML model.
*   With an image only: Utilizes an image-only ML model.

## 2. Features

*   Accepts skin lesion images (JPEG, PNG).
*   Optionally accepts patient metadata (age, sex, location) in JSON format.
*   Utilizes different ML models based on the presence of metadata.
*   Returns probabilistic scores for various skin conditions (e.g., Melanoma, Nevus).
*   Input validation for image size, type, and metadata.
*   Structured JSON responses for success and errors.
*   Health check endpoint.
*   Automatic API documentation via Swagger UI and ReDoc.
*   Containerized with Docker for easy deployment.

## 3. Technology Stack

*   **Language:** Python 3.10+
*   **Web Framework:** FastAPI
*   **ML Libraries:** TensorFlow, Keras 3
*   **Image Processing:** Pillow
*   **ASGI Server:** Uvicorn
*   **Containerization:** Docker
*   **Dependency Management:** pip, `requirements.txt`

## 4. Project Structure

skin_cancer_api/
├── app/                    # Main application package
│   ├── __init__.py
│   ├── main.py             # FastAPI application, endpoints
│   ├── model_loader.py     # Loads and manages ML models
│   ├── preprocessing.py    # Data preprocessing functions
│   ├── schemas.py          # Pydantic models for request/response validation
│   └── config.py           # Application configuration
├── model/                    # Directory for trained ML model files
│   ├── model_epoch_11_val_loss_0.81.h5          # Example multi-input model
│   └── model_epoch_06_val_loss_0.94_images.h5   # Example image-only model
├── test_images/            # Optional: For storing test images
│   └── ISIC_0000035.jpg
├── .env.example            # Example environment variables
├── Dockerfile              # Docker configuration
├── README.md               # This file
└── requirements.txt        # Python dependencies

## 5. Setup and Installation

### Prerequisites

*   Python 3.10 or higher
*   pip (Python package installer)
*   Docker (optional, for containerized deployment)
*   Git (for cloning the repository, if applicable)
*   Trained model files (see `model/` directory above).

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
    Ensure your trained model files (e.g., `model_epoch_11_val_loss_0.81.h5` and `model_epoch_06_val_loss_0.94_images.h5`) are placed in the `model/` directory. Update paths in `app/config.py` if your filenames differ.

5.  **Environment Variables (Optional):**
    Create a `.env` file in the project root by copying `.env.example`. You can override default configurations here (e.g., `LOG_LEVEL`, model paths).
    ```bash
    cp .env.example .env
    # Edit .env if needed
    ```

### Docker Setup

1.  **Ensure Docker is installed and running.**
2.  **Place Model Files:** Ensure model files are in the `model/` directory as they will be copied into the Docker image.
3.  **Build the Docker image:**
    From the project root directory (`skin_cancer_api/`):
    ```bash
    docker build -t skinsight-api .
    ```

## 6. Running the Server

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

## 7. API Endpoints

### 7.1. `POST /predict`

Analyzes a skin lesion image and (optionally) metadata to predict probabilities of skin conditions.

*   **URL:** `/predict`
*   **Method:** `POST`
*   **Content-Type:** `multipart/form-data`

**Form Fields:**

*   `image_file` (file, **required**): Image of the skin lesion (JPEG or PNG). Max size: 10MB (configurable).
*   `metadata` (string, **optional**): JSON string containing patient metadata. If provided, a multi-input model is used. If omitted, an image-only model is used.
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

**Success Response (200 OK):**

*   **Content-Type:** `application/json`
*   **Body:**
    ```json
    {
      "predictions": {
        "Melanoma": 0.153,
        "Nevus": 0.701,
        // ... other class probabilities
      },
      "model_version": "1.0.2" // or "1.0.0_img_only" depending on model used
    }
    ```

**Error Responses:** See [Error Handling](#9-error-handling).

**Example `curl` requests:**

*   **With metadata:**
    ```bash
    curl -X POST \
         -F "image_file=@/path/to/your/image.jpg" \
         -F 'metadata={"age": 55, "sex": "Male", "location": "Trunk"}' \
         http://localhost:8000/predict
    ```

*   **Without metadata (image-only):**
    ```bash
    curl -X POST \
         -F "image_file=@/path/to/your/image.jpg" \
         http://localhost:8000/predict
    ```

### 7.2. `GET /health`

Checks the health of the API, including model loading status.

*   **URL:** `/health`
*   **Method:** `GET`
*   **Success Response (200 OK or 503 Service Unavailable):**
    ```json
    {
      "status": "healthy", // or "unhealthy"
      "multi_input_model_loaded": true,
      "image_only_model_loaded": true // or false if not loaded/configured
    }
    ```

### 7.3. `GET /`

Welcome endpoint.

*   **URL:** `/`
*   **Method:** `GET`
*   **Success Response (200 OK):**
    ```json
    {
      "message": "Welcome to the SkinSight API. Use the /predict endpoint to analyze images."
    }
    ```

### 7.4. `GET /docs`

Provides interactive API documentation (Swagger UI).

### 7.5. `GET /redoc`

Provides alternative API documentation (ReDoc).

## 8. Configuration

Key configurations are managed in `app/config.py` and can be overridden using environment variables (see `.env.example`).

*   `MODEL_PATH`: Path to the multi-input model.
*   `IMAGE_ONLY_MODEL_PATH`: Path to the image-only model.
*   `IMG_SIZE`: Target image size for preprocessing.
*   `CLASSES`, `INTERNAL_CLASSES`, `CLASS_NAME_MAPPING`: Skin condition class names and mappings.
*   `MAX_FILE_SIZE_MB`: Maximum allowed image file size.
*   `ALLOWED_IMAGE_TYPES`: Allowed image MIME types.
*   `SEX_MAPPING`, `ALLOWED_SEX_VALUES`: Configuration for 'sex' metadata.
*   `ANATOM_SITE_MAPPING`, `ALLOWED_LOCATION_VALUES`: Configuration for 'location' metadata.
*   `AGE_MEAN_PLACEHOLDER`, `AGE_STD_PLACEHOLDER`: **Placeholder** values for age scaling. See [Important Notes on Preprocessing](#11-important-notes-on-preprocessing).
*   `LOG_LEVEL`: Logging level (e.g., INFO, DEBUG).

## 9. Error Handling

The API returns structured JSON error responses.

*   **400 Bad Request / 422 Unprocessable Entity (Input Validation):**
    ```json
    {
      "error": {
        "code": "INVALID_INPUT" // or "VALIDATION_ERROR", "FILE_TOO_LARGE", etc.
        "message": "Descriptive error message.",
        "details": { // or an array of details
            "field": "metadata.age",
            "value_provided": -5,
            "message": "Age must be a positive integer."
        }
      }
    }
    ```
*   **500 Internal Server Error (Server-side issues):**
    ```json
    {
      "error": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "An unexpected error occurred while processing the request. Please try again later."
      }
    }
    ```
*   **503 Service Unavailable (e.g., critical model not loaded):**
    Used by the `/health` endpoint or if a requested model is not ready during `/predict`.

## 10. Logging

The application logs requests, responses, errors, and key processing steps.
*   Logs are output to the console.
*   Log level can be configured via the `LOG_LEVEL` environment variable (default: INFO).
*   A middleware logs request method, path, status code, and processing time.

## 11. Important Notes on Preprocessing

The accuracy of the model predictions heavily relies on consistent preprocessing between training and inference.

*   **Metadata Encoding/Scaling:**
    *   The current implementation in `app/preprocessing.py` uses hardcoded mappings (`SEX_MAPPING`, `ANATOM_SITE_MAPPING`) and placeholder values for age scaling (`AGE_MEAN_PLACEHOLDER`, `AGE_STD_PLACEHOLDER`).
    *   **CRITICAL:** For production use, these should be replaced by loading saved `LabelEncoder` (for categorical features) and `StandardScaler` (for numerical features like age) objects that were fitted on the original training data. This ensures that the transformations applied during inference are identical to those applied during training.
    *   These scalers/encoders can be saved using libraries like `joblib` or `pickle` during the model training phase and then loaded in `app/preprocessing.py`.

*   **Image Preprocessing:**
    *   Image resizing and normalization (e.g., `efficientnet.preprocess_input`) are performed as per the base model's requirements (`EfficientNetB0`).

## 12. Future Considerations (Out of Scope for v1.0)

*   User authentication and authorization (e.g., API keys).
*   Rate limiting.
*   Batch image processing endpoint.
*   Endpoint for model version information.
*   Integration with monitoring systems (Prometheus, Grafana).
*   Returning interpretable results (e.g., Grad-CAM).

## 13. Troubleshooting

*   **`ModuleNotFoundError`:** Ensure you are running `uvicorn` commands from the project root directory (`skin_cancer_api/`) and that your virtual environment is activated.
*   **Model Not Found Errors:**
    *   Verify that the model files exist in the `model/` directory.
    *   Check that `MODEL_PATH` and `IMAGE_ONLY_MODEL_PATH` in `app/config.py` (or your `.env` file) point to the correct filenames.
*   **CUDA Errors (e.g., `failed call to cuInit`):**
    *   If you don't have/need GPU support, install `tensorflow-cpu` instead of `tensorflow`.
    *   If you need GPU support, ensure your NVIDIA drivers, CUDA toolkit, and cuDNN are correctly installed and compatible with your TensorFlow version.
*   **Incorrect Predictions:**
    *   Double-check the preprocessing steps, especially the metadata encoding and scaling (see section 11).
    *   Ensure the model architectures defined in `app/model_loader.py` exactly match the saved model files.
*   **Permission Denied (Docker):** If Docker has issues accessing files, check file permissions or Docker volume mount configurations.
```