import os
import sys
import json
from pathlib import Path

def init_directories():
    """Initialize required directories and check model."""
    base_dir = Path(__file__).parent
    
    # Load config
    try:
        with open(base_dir / "config.json", "r") as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error loading config.json: {e}")
        return False

    # Create directories
    dirs_to_create = [
        config["application"]["uploads_dir"],
        config["application"]["models_dir"]
    ]

    for dir_path in dirs_to_create:
        full_path = base_dir / dir_path
        try:
            full_path.mkdir(parents=True, exist_ok=True)
            print(f"Directory {dir_path} ready")
        except Exception as e:
            print(f"Error creating directory {dir_path}: {e}")
            return False

    # Check model file
    model_path = base_dir / config["application"]["models_dir"] / config["application"]["model_file"]
    if not model_path.exists():
        print(f"Warning: Model file not found at {model_path}")
        print("Please ensure the ML model is placed in the correct location")
        return False

    print("All directories initialized successfully")
    return True

if __name__ == "__main__":
    if not init_directories():
        sys.exit(1)
    sys.exit(0)