# SkinSight Database Structure

## Tables Overview

### patients

Stores information about patients in the system.

| Column          | Type      | Description                    | Constraints |
|----------------|-----------|--------------------------------|-------------|
| id             | INT       | Unique patient identifier      | PK, AUTO_INCREMENT |
| full_name      | VARCHAR   | Patient's full name           | NOT NULL |
| gender         | ENUM      | 'male' or 'female'            | NOT NULL |
| birth_date     | DATE      | Patient's date of birth       | NOT NULL |
| phone          | VARCHAR   | Contact phone number          | |
| address        | TEXT      | Patient's address             | |
| medical_history| TEXT      | General medical history notes  | |
| created_at     | TIMESTAMP | Record creation timestamp     | DEFAULT CURRENT_TIMESTAMP |
| updated_at     | TIMESTAMP | Last update timestamp         | ON UPDATE CURRENT_TIMESTAMP |

Indexes:
- PRIMARY KEY (id)
- INDEX idx_full_name (full_name)
- INDEX idx_phone (phone)

### mole_analyses

Stores results of mole analysis scans.

| Column               | Type      | Description                    | Constraints |
|---------------------|-----------|--------------------------------|-------------|
| id                  | INT       | Unique analysis identifier     | PK, AUTO_INCREMENT |
| patient_id          | INT       | Reference to patient          | FK, NOT NULL |
| image_path          | VARCHAR   | Path to stored image          | NOT NULL |
| melanoma_probability| FLOAT     | ML model prediction (0-1)     | NOT NULL |
| diagnosis_text      | TEXT      | Detailed diagnosis text       | |
| analyzed_at         | TIMESTAMP | Analysis timestamp            | DEFAULT CURRENT_TIMESTAMP |

Indexes:
- PRIMARY KEY (id)
- FOREIGN KEY (patient_id) REFERENCES patients(id)
- INDEX idx_patient_analysis (patient_id, analyzed_at)

### analysis_metadata

Stores additional metadata for analyses.

| Column     | Type    | Description                    | Constraints |
|-----------|---------|--------------------------------|-------------|
| id        | INT     | Unique metadata identifier     | PK, AUTO_INCREMENT |
| analysis_id| INT     | Reference to analysis         | FK, NOT NULL |
| key_name  | VARCHAR | Metadata key name             | NOT NULL |
| value_text| TEXT    | Metadata value                | |

Indexes:
- PRIMARY KEY (id)
- FOREIGN KEY (analysis_id) REFERENCES mole_analyses(id)
- INDEX idx_analysis_key (analysis_id, key_name)

## Relationships

1. One patient can have many analyses (1:N)
   - patients.id -> mole_analyses.patient_id

2. One analysis can have many metadata entries (1:N)
   - mole_analyses.id -> analysis_metadata.analysis_id

## Data Flow

1. Patient Creation/Update:
   - Basic information stored in patients table
   - Updates trigger updated_at timestamp

2. Analysis Process:
   - Image uploaded and path stored
   - ML model prediction stored as probability
   - Additional data stored in metadata table
   - Links to patient via patient_id

3. Metadata Storage:
   - Flexible key-value storage for additional analysis data
   - Common keys include:
     - detail_text: Detailed analysis description
     - benign_probability: Inverse of melanoma probability
