import tensorflow as tf

try:
    model = tf.keras.models.load_model("model.h5")
    print("✅ Модель загружена успешно!")
    print(f"Архитектура: {model.summary()}")
except Exception as e:
    print(f"❌ Ошибка: {e}")
