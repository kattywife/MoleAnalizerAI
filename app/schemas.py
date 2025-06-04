from pydantic import BaseModel, Field, validator
from typing import Dict, List, Optional, Any
from config import ALLOWED_SEX_VALUES, ALLOWED_LOCATION_VALUES

class MetadataBase(BaseModel):
    age: int = Field(..., gt=0, description="Age of the patient, must be a positive integer.")
    sex: str = Field(..., description=f"Sex of the patient. Allowed values: {', '.join(ALLOWED_SEX_VALUES)}")
    location: str = Field(..., description=f"Anatomical location of the mole. Allowed values: {', '.join(ALLOWED_LOCATION_VALUES)}")

    @validator('sex')
    def sex_must_be_in_allowed_values(cls, value):
        if value.lower() not in [s.lower() for s in ALLOWED_SEX_VALUES]:
            raise ValueError(f"Invalid sex. Must be one of: {', '.join(ALLOWED_SEX_VALUES)}")
        return value # Return original case for consistency if needed, or .lower()

    @validator('location')
    def location_must_be_in_allowed_values(cls, value):
        # Case-insensitive check but store/use as provided if valid
        allowed_lower = [loc.lower() for loc in ALLOWED_LOCATION_VALUES]
        if value.lower() not in allowed_lower:
            raise ValueError(f"Invalid location. Must be one of: {', '.join(ALLOWED_LOCATION_VALUES)}")
        # Find original casing to return it
        for original_loc in ALLOWED_LOCATION_VALUES:
            if original_loc.lower() == value.lower():
                return original_loc
        return value # Should not reach here if logic is correct


class PredictionResponse(BaseModel):
    predictions: Dict[str, float]
    model_version: str = Field(default=..., example="1.0.2")

class ErrorDetail(BaseModel):
    field: Optional[str] = None
    value_provided: Optional[Any] = None
    message: Optional[str] = None # For Pydantic's own error messages

class ErrorContent(BaseModel):
    code: str
    message: str
    details: Optional[ErrorDetail | List[ErrorDetail]] = None # Allow single or list of details

class ErrorResponse(BaseModel):
    error: ErrorContent

# For FastAPI's automatic 422 response customization
class HTTPValidationErrorDetail(BaseModel):
    loc: List[str]
    msg: str
    type: str

class CustomHTTPValidationError(BaseModel):
    error: ErrorContent