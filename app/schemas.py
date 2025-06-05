# app/schemas.py
from pydantic import BaseModel, Field, validator
from typing import Dict, List, Optional, Any

# Import necessary values from config if used in examples or validation directly
# from app.config import ALLOWED_SEX_VALUES, ALLOWED_LOCATION_VALUES, NOT_A_MOLE_MESSAGE

# --- Input Schemas ---
class MetadataBase(BaseModel):
    age: int = Field(..., gt=0, description="Age of the patient, must be a positive integer.")
    sex: str = Field(..., description="Sex of the patient. e.g., Male, Female, Other") # Use config.ALLOWED_SEX_VALUES for example if defined
    location: str = Field(..., description="Anatomical location of the mole. e.g., Trunk, Head/Neck") # Use config.ALLOWED_LOCATION_VALUES for example

    @validator('sex')
    def sex_must_be_in_allowed_values(cls, value):
        # Ideally, pull ALLOWED_SEX_VALUES from config
        # For this example, hardcoding for brevity or assuming they are globally available
        # from app.config import ALLOWED_SEX_VALUES
        # if value.lower() not in [s.lower() for s in ALLOWED_SEX_VALUES]:
        #     raise ValueError(f"Invalid sex. Must be one of: {', '.join(ALLOWED_SEX_VALUES)}")
        # Simplified for this example:
        if value.lower() not in ["male", "female", "other"]: # Example validation
            raise ValueError("Invalid sex. Must be one of: Male, Female, Other")
        return value

    @validator('location')
    def location_must_be_in_allowed_values(cls, value):
        # Ideally, pull ALLOWED_LOCATION_VALUES from config
        # from app.config import ALLOWED_LOCATION_VALUES
        # allowed_lower = [loc.lower() for loc in ALLOWED_LOCATION_VALUES]
        # if value.lower() not in allowed_lower:
        #     raise ValueError(f"Invalid location. Must be one of: {', '.join(ALLOWED_LOCATION_VALUES)}")
        # Simplified for this example:
        example_locations = ["trunk", "head/neck", "extremities", "palms/soles", "oral/genital"]
        if value.lower() not in example_locations:
            raise ValueError(f"Invalid location. Must be one of: {', '.join(example_locations).title()}")
        return value


# --- Response Schemas ---
class NotAMoleResponse(BaseModel):
    message: str = Field(..., example="The uploaded image is not classified as a mole by the initial screening model.")
    is_mole: bool = Field(default=False, description="Indicates the initial screening outcome.")
    mole_detection_probability: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Probability that the image contains a mole, from the initial screening.",
        example=0.3822
    )
    model_used: str = Field(default="mole_detector", example="mole_detector")


class PredictionResponse(BaseModel):
    predictions: Dict[str, float] = Field(..., example={"Melanoma": 0.1, "Nevus": 0.9})
    model_version: str = Field(..., example="1.0.2")
    is_mole: bool = Field(default=True, description="Indicates the initial screening classified the image as a mole.")
    mole_detection_probability: Optional[float] = Field(
        None, # Can be None if, for some reason, mole detection wasn't run or applicable
        ge=0.0,
        le=1.0,
        description="Probability that the image contains a mole, from the initial screening.",
        example=0.9705
    )


# --- Error Schemas (usually remain consistent) ---
class ErrorDetail(BaseModel):
    field: Optional[str] = None
    value_provided: Optional[Any] = None
    message: Optional[str] = None


class ErrorContent(BaseModel):
    code: str
    message: str
    details: Optional[ErrorDetail | List[ErrorDetail]] = None # Python 3.10+ for |


class ErrorResponse(BaseModel):
    error: ErrorContent


# For FastAPI's automatic 422 response customization (if used)
class HTTPValidationErrorDetail(BaseModel):
    loc: List[str | int] # Field location can include integers for list indices
    msg: str
    type: str


class CustomHTTPValidationError(BaseModel):
    error: ErrorContent