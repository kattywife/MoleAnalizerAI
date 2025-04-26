import tensorflow as tf
import numpy as np
from PIL import Image
import os
import sys

# --- Configuration ---
MODEL_PATH = "" 
IMAGE_PATH = ""

# --- Model Input Expectations (Derived from your training code) ---
EXPECTED_IMAGE_HEIGHT = 224
EXPECTED_IMAGE_WIDTH = 224

# --- Load the Model ---
print(f"Loading model from: {MODEL_PATH}")
if not os.path.exists(MODEL_PATH):
    print(f"Error: Model file not found at {MODEL_PATH}")
    sys.exit(1)

try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Model loaded successfully.")
except Exception as e:
    print(f"Error loading model: {e}")
    print("Make sure TensorFlow/Keras is installed and the .h5 file is valid.")
    sys.exit(1)

# --- Load and Prepare the Image ---
print(f"\nLoading and preparing image: {IMAGE_PATH}")
if not os.path.exists(IMAGE_PATH):
    print(f"Error: Image file not found at {IMAGE_PATH}")
    sys.exit(1)

try:
    # Load image using Pillow
    img = Image.open(IMAGE_PATH)

    # Ensure image is RGB (convert if necessary)
    img = img.convert('RGB')

    # Resize image to the expected dimensions (224x224)
    # Using default interpolation (BILINEAR) is usually fine, even if training used NEAREST.
    img = img.resize((EXPECTED_IMAGE_WIDTH, EXPECTED_IMAGE_HEIGHT))

    # Convert image to NumPy array
    img_array = np.array(img)

    # --- IMPORTANT: Preprocessing ---
    # Convert to float32, as the model expects float inputs
    img_array = img_array.astype('float32')
    img_batch = np.expand_dims(img_array, axis=0)

except Exception as e:
    print(f"Error processing image: {e}")
    sys.exit(1)

# --- Make Prediction ---
print("\nMaking prediction...")
try:
    predictions = model.predict(img_batch)
    probability_malignant = predictions[0][0] 

    print("Prediction successful.")

except Exception as e:
    print(f"Error during prediction: {e}")
    # This might happen if the loaded model structure is unexpected or input shape is wrong.
    sys.exit(1)

# --- Display Result ---
print("\n--- Prediction Result ---")
print(f"Model: {os.path.basename(MODEL_PATH)}")
print(f"Image: {os.path.basename(IMAGE_PATH)}")
print(f"Predicted probability of being MALIGNANT: {probability_malignant:.4f} ({probability_malignant * 100:.2f}%)")

# You can add a threshold to make a classification decision
threshold = 0.5 
print(f"\nClassification based on threshold = {threshold}:")
if probability_malignant >= threshold:
    print(f"-> Likely MALIGNANT")
else:
    print(f"-> Likely BENIGN")