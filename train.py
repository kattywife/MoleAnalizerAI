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



base_model = MobileNetV2(input_shape=IMAGE_SIZE + (3,), # (224, 224, 3)
                         include_top=False,
                         weights='imagenet')

# --- Freeze the Base Model ---
base_model.trainable = False

# --- Add Custom Classification Layers ---
inputs = tf.keras.Input(shape=IMAGE_SIZE + (3,))
x = data_augmentation(inputs) # Apply augmentation
x = rescale(x) # Apply rescaling (if not using model-specific preprocessing)
x = base_model(x, training=False) 
x = layers.GlobalAveragePooling2D()(x) # Pool features
x = layers.Dropout(0.3)(x)            
outputs = layers.Dense(1, activation='sigmoid')(x) 

model = tf.keras.Model(inputs, outputs)

# --- Compile the Model ---\
LEARNING_RATE = 0.001
optimizer = tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE)

# Critical metrics for medical tasks:
METRICS = [
    tf.keras.metrics.BinaryAccuracy(name='accuracy'),
    tf.keras.metrics.Precision(name='precision'), # Precision = TP / (TP + FP)
    tf.keras.metrics.Recall(name='recall'),       # Recall (Sensitivity) = TP / (TP + FN) - VERY IMPORTANT for catching malignant cases
    tf.keras.metrics.AUC(name='auc')              # Area under ROC curve
]

model.compile(optimizer=optimizer,
              loss='binary_crossentropy', 
              metrics=METRICS)

# --- Print Model Summary ---
model.summary()

# --- Callbacks ---
# Save the best model based on validation recall (or AUC/accuracy)
checkpoint_cb = tf.keras.callbacks.ModelCheckpoint(
    "best_mole_classifier_model.h5", # File path to save the model
    save_best_only=True,
    monitor='val_recall', # Monitor recall on validation set
    mode='max'             # Save when recall is maximized
)

checkpoint_cb = tf.keras.callbacks.ModelCheckpoint(
    "best_mole_classifier_model.h5", # File path to save the model
    save_best_only=True,
    monitor='val_recall', # Monitor recall on validation set
    mode='max'             # Save when recall is maximized
)

# Stop training early if validation loss doesn't improve for several epochs
early_stopping_cb = tf.keras.callbacks.EarlyStopping(
    monitor='val_loss',
    patience=10,          
    restore_best_weights=True 
)

# --- Training ---
EPOCHS = 50 
history = model.fit(
    train_dataset,
    epochs=EPOCHS,
    validation_data=validation_dataset,
    callbacks=[checkpoint_cb, early_stopping_cb]
)

# --- Fine-tuning Stage ---
print("\n--- Starting Fine-Tuning ---")

# Unfreeze some layers of the base model
base_model.trainable = True

# Freeze all layers except the top few (e.g., last 20 layers)
fine_tune_at = len(base_model.layers) - 20 # Example: unfreeze last 20 layers
for layer in base_model.layers[:fine_tune_at]:
    layer.trainable = False

# Re-compile the model with a very low learning rate
FINE_TUNE_LR = LEARNING_RATE / 10 # e.g., 0.0001
optimizer = tf.keras.optimizers.Adam(learning_rate=FINE_TUNE_LR)

model.compile(optimizer=optimizer,
              loss='binary_crossentropy',
              metrics=METRICS) # Keep the same metrics

model.summary() # Check trainable parameters now

# Continue training for a few more epochs
FINE_TUNE_EPOCHS = 20
total_epochs = EPOCHS + FINE_TUNE_EPOCHS

history_fine = model.fit(
    train_dataset,
    epochs=total_epochs,
    initial_epoch=history.epoch[-1] + 1, # Start from where the previous training stopped
    validation_data=validation_dataset,
    callbacks=[checkpoint_cb, early_stopping_cb] # Reuse or redefine callbacks
)