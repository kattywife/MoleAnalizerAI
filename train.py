import tensorflow as tf
import matplotlib.pyplot as plt
import numpy as np
import os

# --- Configuration ---
IMAGE_SIZE = (224, 224) 
BATCH_SIZE = 32        
DATA_DIR = ''   # Path to your organized dataset
SEED = 42              # For reproducibility

# --- Load Datasets ---
print("Loading training data...")
train_dataset = tf.keras.utils.image_dataset_from_directory(
    os.path.join(DATA_DIR, 'train'),
    labels='inferred',         # Labels inferred from folder names
    label_mode='binary',       # For benign/malignant (0 or 1)
    image_size=IMAGE_SIZE,
    interpolation='nearest',   # Or 'bilinear'
    batch_size=BATCH_SIZE,
    shuffle=True,
    seed=SEED
)

print("Loading validation data...")
validation_dataset = tf.keras.utils.image_dataset_from_directory(
    os.path.join(DATA_DIR, 'test'),
    labels='inferred',
    label_mode='binary',
    image_size=IMAGE_SIZE,
    interpolation='nearest',
    batch_size=BATCH_SIZE,
    shuffle=False, # No need to shuffle validation data
    seed=SEED
)

print("Loading test data...")
test_dataset = tf.keras.utils.image_dataset_from_directory(
    os.path.join(DATA_DIR, 'test'),
    labels='inferred',
    label_mode='binary',
    image_size=IMAGE_SIZE,
    interpolation='nearest',
    batch_size=BATCH_SIZE,
    shuffle=False, # No need to shuffle test data
    seed=SEED
)

# --- Get Class Names ---
class_names = train_dataset.class_names
print("Class names:", class_names) # Should be ['benign', 'malignant'] or similar

# --- Configure Datasets for Performance ---
AUTOTUNE = tf.data.AUTOTUNE
train_dataset = train_dataset.prefetch(buffer_size=AUTOTUNE)
validation_dataset = validation_dataset.prefetch(buffer_size=AUTOTUNE)
test_dataset = test_dataset.prefetch(buffer_size=AUTOTUNE)

# --- Data Augmentation Layer ---
data_augmentation = tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal_and_vertical", input_shape=(IMAGE_SIZE[0], IMAGE_SIZE[1], 3)),
    tf.keras.layers.RandomRotation(0.2),
    tf.keras.layers.RandomZoom(0.2),
    tf.keras.layers.RandomContrast(0.2),
])

# --- Rescaling Layer ---
rescale = tf.keras.layers.Rescaling(1./255) 


plt.figure(figsize=(10, 10))
for images, labels in train_dataset.take(1):
    for i in range(9):
        ax = plt.subplot(3, 3, i + 1)
        plt.imshow(images[i].numpy().astype("uint8"))
        plt.title(f"Class: {class_names[int(labels[i])]}")
        plt.axis("off")
plt.show()