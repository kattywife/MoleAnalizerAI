import os
from datetime import datetime
from typing import Dict, List, Optional, Any
from PySide6.QtCore import QObject, Slot, Signal, Property
from .database_manager import DatabaseManager
from .model_handler import ModelHandler

class BackendBridge(QObject):
    # Signals for QML communication
    analysisComplete = Signal(dict)
    errorOccurred = Signal(str)
    patientAdded = Signal(int)  # Emits patient ID
    patientUpdated = Signal(int)  # Emits patient ID
    analysisStarted = Signal()
    analysisProgress = Signal(float)  # Progress percentage
    userChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.upload_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
        os.makedirs(self.upload_dir, exist_ok=True)
        
        try:
            self.db = DatabaseManager()
            self.model = ModelHandler()
            self._current_patient_id = None
            self._current_image_path = None
            self._user_name = "Доктор"
            self._clinic_name = "SkinSight"
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(dict, result=int)
    def add_patient(self, patient_data: Dict[str, Any]) -> int:
        """Add a new patient to the database."""
        try:
            patient_id = self.db.add_patient(patient_data)
            self.patientAdded.emit(patient_id)
            return patient_id
        except Exception as e:
            self.errorOccurred.emit(f"Error adding patient: {e}")
            return -1

    @Slot(str, result=str)
    def save_image(self, image_path: str) -> str:
        """Save uploaded image to the uploads directory."""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            ext = os.path.splitext(image_path)[1]
            filename = f"mole_{timestamp}{ext}"
            save_path = os.path.join(self.upload_dir, filename)
            
            # Copy the file
            with open(image_path, "rb") as src, open(save_path, "wb") as dst:
                dst.write(src.read())
            
            self._current_image_path = save_path
            return save_path
        except Exception as e:
            self.errorOccurred.emit(f"Error saving image: {e}")
            return ""

    @Slot(result=dict)
    def analyze_current_image(self) -> Dict[str, Any]:
        """Analyze the currently loaded image."""
        if not self._current_image_path:
            self.errorOccurred.emit("No image loaded for analysis")
            return {}

        try:
            self.analysisStarted.emit()
            
            # Get model prediction
            probabilities = self.model.predict(self._current_image_path)
            diagnosis, detail_text = self.model.get_prediction_text(probabilities)
            
            result = {
                "melanoma_probability": probabilities["melanoma_probability"],
                "benign_probability": probabilities["benign_probability"],
                "diagnosis": diagnosis,
                "detail_text": detail_text,
                "image_path": self._current_image_path
            }
            
            # If we have a current patient, save the analysis
            if self._current_patient_id:
                analysis_data = {
                    "patient_id": self._current_patient_id,
                    "image_path": self._current_image_path,
                    "melanoma_probability": probabilities["melanoma_probability"],
                    "diagnosis_text": diagnosis,
                    "metadata": {
                        "detail_text": detail_text,
                        "benign_probability": str(probabilities["benign_probability"])
                    }
                }
                self.db.add_analysis(analysis_data)
            
            self.analysisComplete.emit(result)
            return result
        except Exception as e:
            self.errorOccurred.emit(f"Error during analysis: {e}")
            return {}

    @Slot(str, result=list)
    def search_patients(self, search_term: str) -> List[Dict[str, Any]]:
        """Search for patients by name or phone number."""
        try:
            return self.db.search_patients(search_term)
        except Exception as e:
            self.errorOccurred.emit(f"Error searching patients: {e}")
            return []

    @Slot(int, result=dict)
    def get_patient_details(self, patient_id: int) -> Dict[str, Any]:
        """Get detailed patient information including analysis history."""
        try:
            patient = self.db.get_patient(patient_id)
            if patient:
                patient["analyses"] = self.db.get_patient_analyses(patient_id)
            return patient or {}
        except Exception as e:
            self.errorOccurred.emit(f"Error fetching patient details: {e}")
            return {}

    @Slot(int, dict, result=bool)
    def update_patient(self, patient_id: int, patient_data: Dict[str, Any]) -> bool:
        """Update an existing patient's information."""
        try:
            patient_data['id'] = patient_id
            self.db.update_patient(patient_data)
            self.patientUpdated.emit(patient_id)
            return True
        except Exception as e:
            self.errorOccurred.emit(f"Error updating patient: {e}")
            return False

    @Slot(result=dict)
    def get_current_analysis_result(self) -> Dict[str, Any]:
        """Get the most recent analysis result."""
        try:
            if not self._current_image_path:
                return {}
            
            current_result = {
                "image_path": self._current_image_path,
                "diagnosis": "",
                "detail_text": "",
                "melanoma_probability": 0.0
            }
            
            # Check if we have a cached result
            if hasattr(self, '_current_result'):
                return self._current_result
            
            # Otherwise return empty result
            return current_result
        except Exception as e:
            self.errorOccurred.emit(f"Error retrieving analysis result: {e}")
            return {}

    @Slot(result=bool)
    def save_analysis_result(self) -> bool:
        """Save the current analysis result to the database."""
        try:
            if not hasattr(self, '_current_result') or not self._current_result:
                self.errorOccurred.emit("No analysis result to save")
                return False

            if not self._current_patient_id:
                self.errorOccurred.emit("No patient selected")
                return False

            analysis_data = {
                "patient_id": self._current_patient_id,
                "image_path": self._current_image_path,
                "melanoma_probability": self._current_result["melanoma_probability"],
                "diagnosis_text": self._current_result["diagnosis"],
                "metadata": {
                    "detail_text": self._current_result["detail_text"],
                    "benign_probability": str(1.0 - self._current_result["melanoma_probability"])
                }
            }

            analysis_id = self.db.add_analysis(analysis_data)
            self._current_result["saved"] = True
            return analysis_id > 0
        except Exception as e:
            self.errorOccurred.emit(f"Error saving analysis result: {e}")
            return False

    @Slot(int, result=list)
    def get_patient_analyses(self, patient_id: int) -> List[Dict[str, Any]]:
        """Get all analyses for a specific patient."""
        try:
            analyses = self.db.get_patient_analyses(patient_id)
            
            # Process metadata if present
            for analysis in analyses:
                if "metadata" in analysis and analysis["metadata"]:
                    metadata_dict = {}
                    for item in analysis["metadata"].split(","):
                        if ":" in item:
                            key, value = item.split(":", 1)
                            metadata_dict[key] = value
                    analysis["metadata"] = metadata_dict
            
            return analyses
        except Exception as e:
            self.errorOccurred.emit(f"Error fetching patient analyses: {e}")
            return []

    @Property(int)
    def currentPatientId(self) -> Optional[int]:
        """Current patient ID property for QML."""
        return self._current_patient_id

    @currentPatientId.setter
    def currentPatientId(self, patient_id: int):
        if self._current_patient_id != patient_id:
            self._current_patient_id = patient_id

    @Property(str)
    def currentImagePath(self) -> Optional[str]:
        """Current image path property for QML."""
        return self._current_image_path

    @currentImagePath.setter
    def currentImagePath(self, image_path: str):
        if self._current_image_path != image_path:
            self._current_image_path = image_path

    @Property(str, notify=userChanged)
    def userName(self) -> str:
        return self._user_name

    @userName.setter
    def userName(self, name: str):
        if self._user_name != name:
            self._user_name = name
            self.userChanged.emit()

    @Property(str, notify=userChanged)
    def clinicName(self) -> str:
        return self._clinic_name

    @clinicName.setter
    def clinicName(self, name: str):
        if self._clinic_name != name:
            self._clinic_name = name
            self.userChanged.emit()