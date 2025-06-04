-- Create database if not exists
CREATE DATABASE IF NOT EXISTS skinsight CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE skinsight;

-- Patients table
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
);

-- Mole analyses table
CREATE TABLE IF NOT EXISTS mole_analyses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    melanoma_probability FLOAT NOT NULL,
    predictions TEXT,
    diagnosis_text TEXT,
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    INDEX idx_patient_analysis (patient_id, analyzed_at)
);

-- Analysis metadata table for storing additional analysis information
CREATE TABLE IF NOT EXISTS analysis_metadata (
    id INT PRIMARY KEY AUTO_INCREMENT,
    analysis_id INT NOT NULL,
    key_name VARCHAR(50) NOT NULL,
    value_text TEXT,
    FOREIGN KEY (analysis_id) REFERENCES mole_analyses(id) ON DELETE CASCADE,
    INDEX idx_analysis_key (analysis_id, key_name)
);