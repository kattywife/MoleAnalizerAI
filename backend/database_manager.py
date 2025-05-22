import mysql.connector
from datetime import datetime
from typing import Dict, List, Optional, Any
import os
import json
from pathlib import Path

class DatabaseManager:
    def __init__(self, config_file: str = "config.json"):
        self.connection = None
        self.cursor = None
        config_path = Path(__file__).parent.parent / config_file
        self._load_config(str(config_path))
        self._connect()

    def _load_config(self, config_file: str):
        """Load database configuration from a JSON file or use defaults."""
        default_config = {
            "host": "localhost",
            "user": "root",
            "password": "",
            "database": "skinsight"
        }
        
        self.connection_params = default_config
        
        # Try to load from config file if it exists
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r') as f:
                    config = json.load(f)
                    self.connection_params.update(config.get('database', {}))
            except Exception as e:
                print(f"Warning: Could not load config file: {e}")

    def _connect(self):
        """Attempt to connect to the database, create if not exists."""
        try:
            # First try to connect to MySQL server without database
            conn_params = dict(self.connection_params)
            db_name = conn_params.pop('database')
            
            temp_conn = mysql.connector.connect(**conn_params)
            temp_cursor = temp_conn.cursor()
            
            # Create database if it doesn't exist
            temp_cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
            temp_cursor.close()
            temp_conn.close()
            
            # Now connect with the database
            self.connection = mysql.connector.connect(**self.connection_params)
            self.cursor = self.connection.cursor(dictionary=True)
            
            # Create tables if they don't exist
            self._create_tables()
            
        except mysql.connector.Error as err:
            print(f"Database connection error: {err}")
            self.connection = None
            self.cursor = None
            raise

    def _create_tables(self):
        """Create necessary tables if they don't exist."""
        create_patients_table = """
        CREATE TABLE IF NOT EXISTS patients (
            id INT PRIMARY KEY AUTO_INCREMENT,
            full_name VARCHAR(255) NOT NULL,
            gender ENUM('male', 'female') NOT NULL,
            birth_date DATE NOT NULL,
            phone VARCHAR(20),
            address TEXT,
            medical_history TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_full_name (full_name),
            INDEX idx_phone (phone)
        )
        """
        
        create_analyses_table = """
        CREATE TABLE IF NOT EXISTS mole_analyses (
            id INT PRIMARY KEY AUTO_INCREMENT,
            patient_id INT NOT NULL,
            image_path VARCHAR(255) NOT NULL,
            melanoma_probability FLOAT NOT NULL,
            diagnosis_text TEXT,
            analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
            INDEX idx_patient_analysis (patient_id, analyzed_at)
        )
        """
        
        create_metadata_table = """
        CREATE TABLE IF NOT EXISTS analysis_metadata (
            id INT PRIMARY KEY AUTO_INCREMENT,
            analysis_id INT NOT NULL,
            key_name VARCHAR(50) NOT NULL,
            value_text TEXT,
            FOREIGN KEY (analysis_id) REFERENCES mole_analyses(id) ON DELETE CASCADE,
            INDEX idx_analysis_key (analysis_id, key_name)
        )
        """
        
        self.cursor.execute(create_patients_table)
        self.cursor.execute(create_analyses_table)
        self.cursor.execute(create_metadata_table)
        self.connection.commit()

    def is_connected(self) -> bool:
        """Check if database connection is active."""
        return self.connection is not None and self.connection.is_connected()

    def ensure_connected(self):
        """Ensure database connection is active, reconnect if needed."""
        if not self.is_connected():
            self._connect()
        if not self.is_connected():
            raise RuntimeError("Could not establish database connection")

    def add_patient(self, patient_data: Dict[str, Any]) -> int:
        """Add a new patient to the database."""
        self.ensure_connected()
        
        query = """
        INSERT INTO patients (full_name, gender, birth_date, phone, address, medical_history)
        VALUES (%(full_name)s, %(gender)s, %(birth_date)s, %(phone)s, %(address)s, %(medical_history)s)
        """
        
        try:
            self.cursor.execute(query, patient_data)
            self.connection.commit()
            return self.cursor.lastrowid
        except mysql.connector.Error as err:
            self.connection.rollback()
            raise RuntimeError(f"Error adding patient: {err}")

    def add_analysis(self, analysis_data: Dict[str, Any]) -> int:
        """Add a new analysis record and its metadata."""
        self.ensure_connected()
        
        query = """
        INSERT INTO mole_analyses (patient_id, image_path, melanoma_probability, diagnosis_text)
        VALUES (%(patient_id)s, %(image_path)s, %(melanoma_probability)s, %(diagnosis_text)s)
        """
        
        try:
            self.cursor.execute(query, analysis_data)
            analysis_id = self.cursor.lastrowid
            
            # Add metadata if present
            if "metadata" in analysis_data and analysis_data["metadata"]:
                for key, value in analysis_data["metadata"].items():
                    self._add_analysis_metadata(analysis_id, key, value)
            
            self.connection.commit()
            return analysis_id
        except mysql.connector.Error as err:
            self.connection.rollback()
            raise RuntimeError(f"Error adding analysis: {err}")

    def _add_analysis_metadata(self, analysis_id: int, key: str, value: str):
        """Add metadata for an analysis."""
        query = """
        INSERT INTO analysis_metadata (analysis_id, key_name, value_text)
        VALUES (%s, %s, %s)
        """
        self.cursor.execute(query, (analysis_id, key, value))

    def get_patient(self, patient_id: int) -> Optional[Dict[str, Any]]:
        """Get patient details by ID."""
        self.ensure_connected()
        
        query = """
        SELECT id, full_name, gender, birth_date, phone, address, medical_history,
               created_at, updated_at
        FROM patients
        WHERE id = %s
        """
        
        self.cursor.execute(query, (patient_id,))
        result = self.cursor.fetchone()
        
        if result:
            # Convert datetime objects to strings for JSON serialization
            result['birth_date'] = result['birth_date'].isoformat()
            result['created_at'] = result['created_at'].isoformat()
            result['updated_at'] = result['updated_at'].isoformat()
        
        return result

    def get_patient_analyses(self, patient_id: int) -> List[Dict[str, Any]]:
        """Get all analyses for a patient with their metadata."""
        self.ensure_connected()
        
        query = """
        SELECT a.id, a.patient_id, a.image_path, a.melanoma_probability,
               a.diagnosis_text, a.analyzed_at,
               GROUP_CONCAT(CONCAT(m.key_name, ':', m.value_text)) as metadata
        FROM mole_analyses a
        LEFT JOIN analysis_metadata m ON a.id = m.analysis_id
        WHERE a.patient_id = %s
        GROUP BY a.id
        ORDER BY a.analyzed_at DESC
        """
        
        self.cursor.execute(query, (patient_id,))
        analyses = self.cursor.fetchall()
        
        # Convert datetime objects and process metadata
        for analysis in analyses:
            analysis['analyzed_at'] = analysis['analyzed_at'].isoformat()
        
        return analyses

    def search_patients(self, search_term: str) -> List[Dict[str, Any]]:
        """Search for patients by name or phone number."""
        self.ensure_connected()
        
        query = """
        SELECT id, full_name, gender, birth_date, phone
        FROM patients
        WHERE full_name LIKE %s OR phone LIKE %s
        ORDER BY full_name
        LIMIT 20
        """
        
        search_pattern = f"%{search_term}%"
        self.cursor.execute(query, (search_pattern, search_pattern))
        results = self.cursor.fetchall()
        
        # Convert datetime objects to strings
        for result in results:
            result['birth_date'] = result['birth_date'].isoformat()
        
        return results

    def update_patient(self, patient_data: Dict[str, Any]) -> bool:
        """Update an existing patient's information."""
        self.ensure_connected()
        
        if 'id' not in patient_data:
            raise ValueError("Patient ID is required for update")
        
        query = """
        UPDATE patients
        SET full_name = %(full_name)s,
            gender = %(gender)s,
            birth_date = %(birth_date)s,
            phone = %(phone)s,
            address = %(address)s,
            medical_history = %(medical_history)s
        WHERE id = %(id)s
        """
        
        try:
            self.cursor.execute(query, patient_data)
            self.connection.commit()
            return self.cursor.rowcount > 0
        except mysql.connector.Error as err:
            self.connection.rollback()
            raise RuntimeError(f"Error updating patient: {err}")

    def close(self):
        """Close database connection."""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
            
    def __del__(self):
        """Ensure connection is closed when object is destroyed."""
        self.close()