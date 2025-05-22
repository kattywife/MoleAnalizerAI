# SkinSight - Skin Cancer Detection Application

SkinSight is a desktop application that helps medical professionals detect potential skin cancer (melanoma) by analyzing images of moles using machine learning.

## Features

- Upload and analyze mole images for melanoma detection
- Patient management with detailed medical history
- Analysis history tracking and result comparison
- High-quality image visualization
- Secure patient data storage
- Intuitive QML-based user interface

## Prerequisites

- Python 3.8 or higher
- MySQL Server
- Qt 6.5 or higher

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd SkinSight
```

2. Create and activate a Python virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Configure the database:
   - Install MySQL if not already installed
   - Edit `config.json` with your database credentials
   - The application will create the database and tables automatically on first run

5. Ensure the ML model is present:
   - Place the melanoma detection model in `models/model.h5`
   - The model should be a TensorFlow/Keras model trained for binary classification

## Running the Application

```bash
python main.py
```

## Project Structure

```
SkinSight/
├── backend/               # Python backend code
│   ├── database_manager.py    # Database operations
│   ├── model_handler.py       # ML model integration
│   └── backend_bridge.py      # QML-Python bridge
├── frontend/             # QML frontend code
│   ├── components/          # Reusable QML components
│   ├── screens/            # Application screens
│   └── assets/            # Images and resources
├── models/              # ML model files
├── uploads/            # Uploaded images
├── config.json         # Application configuration
└── requirements.txt    # Python dependencies
```

## Database Schema

The application uses three main tables:
- `patients`: Stores patient information
- `mole_analyses`: Stores analysis results
- `analysis_metadata`: Stores additional analysis data

## Development

- QML components are organized into modules for reusability
- The backend uses PySide6 for Qt integration
- Database operations are handled through a connection pool
- Image analysis is performed asynchronously

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
