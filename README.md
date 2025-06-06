# SkinSight AI: Skin Lesion Classification Model (Image-Only)

This repository contains a Jupyter Notebook (`SkinSight_model.ipynb`) that implements a deep learning model for skin lesion classification using the ISIC 2019 dataset. The model is designed to work solely with images and their corresponding diagnostic labels.

## Key Features and Modifications
The model incorporates several modifications for potentially improved performance and robustness:
-   **Mixed Precision Training:** Enabled for faster training on compatible GPUs.
-   **Class Weights:** Implemented to address dataset imbalance.
-   **Fine-tuning:** The pre-trained base model (EfficientNetB0 by default) is fine-tuned.
-   **AdamW Optimizer:** Utilized for potentially better generalization (`tf.keras.optimizers.AdamW`).
-   **Custom Focal Loss:** Option to use a custom implementation of Categorical Focal Loss for imbalanced classification.
-   **Learning Rate Scheduler:** `ReduceLROnPlateau` adjusts the learning rate during training.

## Dataset
The model is trained on the **ISIC 2019 Challenge dataset**.
-   **ISIC_2019_Training_Input:** Contains the skin lesion images.
-   **ISIC_2019_Training_Metadata.csv:** Contains metadata associated with the images.
-   **ISIC_2019_Training_GroundTruth.csv:** Contains the diagnostic labels for the training images.

**To download the dataset (if not already present):**
The notebook includes commented-out cells for downloading. You can run these commands in your terminal:
```bash
# Create data directories (the notebook also creates these)
mkdir -p data/images
mkdir -p data/metadata
mkdir -p models

# Download dataset files
# Ensure wget is installed or download manually
wget https://isic-challenge-data.s3.amazonaws.com/2019/ISIC_2019_Training_Input.zip
wget https://isic-challenge-data.s3.amazonaws.com/2019/ISIC_2019_Training_Metadata.csv -O ./data/metadata/ISIC_2019_Training_Metadata.csv
wget https://isic-challenge-data.s3.amazonaws.com/2019/ISIC_2019_Training_GroundTruth.csv -O ./data/metadata/ISIC_2019_Training_GroundTruth.csv

# Unzip images
# This command assumes ISIC_2019_Training_Input.zip is in the current directory.
# It will create a folder named ISIC_2019_Training_Input inside ./data/images/
unzip -q ISIC_2019_Training_Input.zip -d ./data/images
```
**Note:** The notebook expects the unzipped image folder to be `ISIC_2019_Training_Input` located at `./data/images/ISIC_2019_Training_Input/`. The CSV files should be in `./data/metadata/`.

## Setup and Dependencies
1.  **Create Directories:**
    The notebook includes a cell to create necessary directories:
    ```bash
    !mkdir -p data/images
    !mkdir -p data/metadata
    !mkdir -p models
    !mkdir -p models/checkpoints # Checkpoint directory is created by CONFIG
    ```
2.  **Install Libraries:**
    The required Python libraries can be installed using pip. The notebook has cells for this:
    ```bash
    !pip install tensorflow opencv-python pandas numpy matplotlib seaborn scikit-learn requests tqdm pillow
    !pip install keras --upgrade
    ```

## Notebook Structure
The notebook is organized into the following main sections:
1.  **Setup and Dependencies:** Imports libraries, sets random seeds, and enables mixed precision training. Defines a custom Focal Loss class.
2.  **Configuration:** Defines model parameters (image size, batch size, epochs, learning rates), paths, base model choice, optimizer settings, loss function choice, and class names.
3.  **Load ISIC Dataset Info:** Defines a function `load_isic_data_info` to load and merge metadata and ground truth CSVs, mapping one-hot encoded labels to a single diagnosis column.
4.  **Data Preprocessing:**
    *   Defines `create_data_generators` for setting up `ImageDataGenerator` with augmentation for training and preprocessing for validation/test.
    *   Defines `prepare_image_dataset_splits` to validate image files (check existence and integrity) and split the dataset into training, validation, and test sets, stratifying by diagnosis.
5.  **Dataset Info Loading Execution:** Executes `load_isic_data_info` and prints dataset statistics.
6.  **Dataset Splitting and Generator Creation Execution:** Executes `prepare_image_dataset_splits` and creates `DataFrameIterator` objects (`train_generator`, `val_generator`, `test_generator`).
7.  **Dataset Statistics and Visualization:** Displays class distribution in the training set using a count plot.
8.  **Display Sample Images:** Shows a batch of augmented images from the training generator.
9.  **Model Definition (Image-Only with Fine-tuning):**
    *   Defines `build_model_image_only` to construct a CNN.
    *   Uses a pre-trained base model (e.g., EfficientNetB0) from `tf.keras.applications`.
    *   Allows for fine-tuning by unfreezing a specified number of top layers of the base model (Batch Normalization layers in the base model are kept frozen).
    *   Adds a custom classification head (GlobalAveragePooling, BatchNormalization, Dropout, Dense layers).
10. **Model Compilation:**
    *   Instantiates the model using `build_model_image_only`.
    *   Selects and configures the optimizer (AdamW or Adam).
    *   Selects the loss function (Categorical Crossentropy or the custom Categorical Focal Loss).
    *   Defines evaluation metrics (accuracy, precision, recall, AUC).
    *   Prints model summary and trainable status of base model layers.
11. **Model Training:**
    *   Calculates class weights using `sklearn.utils.class_weight.compute_class_weight` to address class imbalance.
    *   Sets up Keras callbacks: `EarlyStopping`, `ModelCheckpoint`, `ReduceLROnPlateau`.
    *   Trains the model using `model.fit()` with the data generators and class weights.
    *   Saves the final model.
12. **Model Evaluation:**
    *   Plots training history (accuracy, loss, precision, recall, AUC vs. epochs).
    *   Evaluates the model on the test set using `model.evaluate()`.
    *   Generates predictions on the test set.
    *   Displays a classification report, a confusion matrix, and per-class ROC curves with AUC values.

## Configuration
Key training and model parameters are defined in the `CONFIG` dictionary at the beginning of the notebook. This allows for easy modification of:
-   `IMG_SIZE`: Input image dimensions (e.g., 224).
-   `BATCH_SIZE`: Batch size for training and evaluation (e.g., 32).
-   `EPOCHS`: Maximum number of training epochs (e.g., 50).
-   `FINETUNE_LEARNING_RATE`: Learning rate for the optimizer (e.g., 1e-4).
-   `BASE_MODEL`: Choice of pre-trained model (e.g., 'EfficientNetB0', 'ResNet50').
-   `N_LAYERS_TO_UNFREEZE`: Number of layers to unfreeze from the end of the base model for fine-tuning (e.g., 30).
-   `OPTIMIZER`: 'AdamW' or 'Adam'.
-   `WEIGHT_DECAY`: Weight decay for AdamW (e.g., 1e-5).
-   `LOSS_FUNCTION`: 'categorical_crossentropy' or 'focal_loss'.
-   `FOCAL_LOSS_ALPHA`, `FOCAL_LOSS_GAMMA`: Parameters for focal loss.
-   Paths for data, model saving, and checkpoints.

The list of `CLASSES` is also defined:
```python
CLASSES = [
    'melanoma', 'nevus', 'basal_cell_carcinoma', 'actinic_keratosis',
    'benign_keratosis', 'dermatofibroma', 'vascular_lesions'
]
```

## Model Architecture
-   **Base Model:** Leverages a pre-trained model from `tf.keras.applications` (default: `EfficientNetB0`). The `preprocessing_function` corresponding to the chosen base model is used.
-   **Fine-tuning:** A specified number of layers from the top of the base model (`CONFIG['N_LAYERS_TO_UNFREEZE']`) are made trainable. Batch Normalization layers within the base model are explicitly kept frozen during the fine-tuning phase to maintain stable statistics learned from ImageNet.
-   **Custom Head:** A custom classification head is added on top of the features extracted by the base model:
    -   `GlobalAveragePooling2D`
    -   `BatchNormalization`
    -   `Dropout`
    -   `Dense` layer (128 units, ReLU activation)
    -   `BatchNormalization`
    -   `Dropout` (half the rate of the previous dropout)
    -   Output `Dense` layer (number of classes, Softmax activation, `dtype='float32'` for mixed precision compatibility).

## Training
-   **Data Augmentation:** `ImageDataGenerator` is used for real-time data augmentation on the training set. Augmentations include rotation, width/height shifts, shear, zoom, horizontal/vertical flips, brightness adjustments, and channel shifts. Validation and test data are only preprocessed (scaled by the base model's specific function).
-   **Class Imbalance:** Class weights are calculated using `sklearn.utils.class_weight.compute_class_weight` with `class_weight='balanced'` and applied during training via the `class_weight` parameter in `model.fit()`.
-   **Callbacks:**
    -   `EarlyStopping`: Monitors `val_loss` and stops training if it doesn't improve for `EARLY_STOPPING_PATIENCE` epochs, restoring the best weights.
    -   `ModelCheckpoint`: Saves the model weights only when `val_loss` improves, storing epoch-specific checkpoints.
    -   `ReduceLROnPlateau`: Reduces the learning rate by `REDUCE_LR_FACTOR` if `val_loss` plateaus for `REDUCE_LR_PATIENCE` epochs.
-   **Mixed Precision:** TensorFlow's mixed precision training (`mixed_float16`) is enabled globally to potentially speed up training and reduce memory usage on compatible GPUs (NVIDIA Volta, Turing, Ampere, or newer).

## Evaluation
The model's performance is assessed using:
-   **Training History Plots:** Visualizations of training and validation metrics (accuracy, loss, precision, recall, AUC) over epochs.
-   **Test Set Evaluation:** Standard metrics (loss, accuracy, precision, recall, AUC) are reported on the unseen test set.
-   **Classification Report:** From `sklearn.metrics.classification_report`, providing precision, recall, F1-score, and support for each class.
-   **Confusion Matrix:** Visualizes the model's predictions against the true labels using `sklearn.metrics.confusion_matrix` and `seaborn.heatmap`.
-   **ROC Curves:** Per-class Receiver Operating Characteristic (ROC) curves and their Area Under the Curve (AUC) scores are plotted using `sklearn.metrics.roc_curve` and `sklearn.metrics.auc`.

## How to Run
1.  **Prerequisites:**
    *   Python 3.x
    *   pip
    *   A GPU is highly recommended for feasible training times, especially with mixed precision (NVIDIA Volta, Turing, Ampere or newer for `mixed_float16`).
2.  **Download the Notebook:** Obtain the `SkinSight_model.ipynb` file.
3.  **Download the ISIC 2019 Dataset:** Follow the instructions in the [Dataset](#dataset) section. Ensure the directory structure matches the notebook's expectations (`./data/images/ISIC_2019_Training_Input/` for images, `./data/metadata/` for CSVs).
4.  **Install Dependencies:** Run the pip install commands provided in the notebook or in the [Setup and Dependencies](#setup-and-dependencies) section within your Python environment.
5.  **Open and Run the Notebook:**
    *   Open `SkinSight_model.ipynb` in a Jupyter environment (e.g., Jupyter Lab, Jupyter Notebook, Google Colab, VS Code with Jupyter extension).
    *   If using Google Colab, ensure a GPU runtime is selected (Runtime > Change runtime type > GPU).
    *   Execute the cells in order. The initial cells download/prepare data, followed by model definition, training, and evaluation.

## Output
-   **Trained Model:** The final trained model (after `EarlyStopping` restores best weights if applicable) is saved to the path specified by `CONFIG['MODEL_SAVE_PATH']` (default: `./models/skin_lesion_model_image_only_finetuned.h5`).
-   **Checkpoints:** The best model checkpoints during training (based on `val_loss`) are saved in the `CONFIG['CHECKPOINT_DIR']` (default: `./models/checkpoints/`), with filenames indicating epoch and validation loss.
-   **Evaluation Results:** Metrics, training history plots, classification report, confusion matrix, and ROC curves are displayed directly in the notebook output.
