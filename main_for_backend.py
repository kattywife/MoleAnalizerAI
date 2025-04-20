import sys
import os
from typing import Optional
from PySide6.QtWidgets import (QApplication, QMainWindow, QStackedWidget, QVBoxLayout,
                             QWidget, QLabel, QPushButton, QFrame, QLineEdit,
                             QDateEdit, QComboBox, QGroupBox, QHBoxLayout,
                             QFileDialog, QGraphicsView, QGraphicsScene)
from PySide6.QtCore import Qt, QDate
from PySide6.QtGui import QPixmap, QImage

class SkinAnalysisBackend:
    def __init__(self):
        self.upload_dir = "uploads"
        os.makedirs(self.upload_dir, exist_ok=True)
        self.current_image_path = None

    def save_mole_image(self, image_path: str) -> Optional[str]:
        """Сохраняет изображение и возвращает путь к файлу"""
        try:
            timestamp = QDate.currentDate().toString("yyyyMMdd") + "_" + QDate.currentDate().toString("HHmmss")
            ext = os.path.splitext(image_path)[1]
            new_filename = f"mole_{timestamp}{ext}"
            save_path = os.path.join(self.upload_dir, new_filename)

            with open(image_path, "rb") as src, open(save_path, "wb") as dst:
                dst.write(src.read())

            self.current_image_path = save_path
            return save_path
        except Exception as e:
            print(f"Ошибка сохранения: {e}")
            return None

    def analyze_mole(self) -> dict:
        """Анализ текущего изображения"""
        if not self.current_image_path:
            return {"status": "error", "message": "Изображение не загружено"}

        return {
            "status": "success",
            "diagnosis": "Доброкачественное образование",
            "confidence": 0.92,
            "recommendation": "Плановый осмотр через 6 месяцев"
        }

class SkinSightBackend:
    def __init__(self):
        self.patients = []
        self.current_user = "Иван Иванов"
        self.image_backend = SkinAnalysisBackend()

    def add_patient(self, patient_data):
        """Добавление нового пациента"""
        self.patients.append(patient_data)
        return len(self.patients) - 1

class MainMenuPage(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.init_ui()

    def init_ui(self):
        main_layout = QHBoxLayout()

        # Левое меню
        left_menu = QVBoxLayout()
        left_menu.setAlignment(Qt.AlignTop | Qt.AlignLeft)

        label_menu = QLabel("Планов меню")
        self.patients_btn = QPushButton("Пациенты")
        self.analysis_btn = QPushButton("Анализы")
        settings_btn = QPushButton("Настройки")

        left_menu.addWidget(label_menu)
        left_menu.addWidget(self.patients_btn)
        left_menu.addWidget(self.analysis_btn)
        left_menu.addWidget(settings_btn)

        # Правая часть
        right_content = QVBoxLayout()
        right_content.setAlignment(Qt.AlignTop)

        welcome_label = QLabel(f"Добро пожаловать, {self.parent.backend.current_user}!")
        right_content.addWidget(welcome_label)

        separator = QFrame()
        separator.setFrameShape(QFrame.HLine)
        right_content.addWidget(separator)

        self.new_analysis_btn = QPushButton("НОВЫЙ АНАЛИЗ")
        right_content.addWidget(self.new_analysis_btn)

        exit_btn = QPushButton("Выход")
        right_content.addWidget(exit_btn)

        main_layout.addLayout(left_menu)
        main_layout.addLayout(right_content)
        self.setLayout(main_layout)

class PatientsPage(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.init_ui()

    def init_ui(self):
        layout = QVBoxLayout()

        # Кнопки управления пациентом
        btn_layout = QHBoxLayout()
        new_patient_btn = QPushButton("Новый пациент")
        select_patient_btn = QPushButton("Выбрать пациента")
        btn_layout.addWidget(new_patient_btn)
        btn_layout.addWidget(select_patient_btn)
        layout.addLayout(btn_layout)

        # Группа данных пациента
        patient_group = QGroupBox("Данные пациента")
        patient_layout = QVBoxLayout()

        # ФИО
        name_layout = QHBoxLayout()
        name_label = QLabel("ФИО:")
        self.name_input = QLineEdit()
        name_layout.addWidget(name_label)
        name_layout.addWidget(self.name_input)
        patient_layout.addLayout(name_layout)

        # Пол
        gender_layout = QHBoxLayout()
        gender_label = QLabel("Пол:")
        self.gender_combo = QComboBox()
        self.gender_combo.addItems(["Мужской", "Женский"])
        gender_layout.addWidget(gender_label)
        gender_layout.addWidget(self.gender_combo)
        patient_layout.addLayout(gender_layout)

        # Дата рождения
        birth_layout = QHBoxLayout()
        birth_label = QLabel("Дата рождения:")
        self.birth_date = QDateEdit()
        self.birth_date.setDisplayFormat("dd.MM.yyyy")
        self.birth_date.setDate(QDate.currentDate())
        birth_layout.addWidget(birth_label)
        birth_layout.addWidget(self.birth_date)
        patient_layout.addLayout(birth_layout)

        # Контактные данные
        contact_layout = QHBoxLayout()
        contact_label = QLabel("Телефон:")
        self.contact_input = QLineEdit()
        contact_layout.addWidget(contact_label)
        contact_layout.addWidget(self.contact_input)
        patient_layout.addLayout(contact_layout)

        # Адрес
        address_layout = QHBoxLayout()
        address_label = QLabel("Адрес:")
        self.address_input = QLineEdit()
        address_layout.addWidget(address_label)
        address_layout.addWidget(self.address_input)
        patient_layout.addLayout(address_layout)

        # ID
        id_layout = QHBoxLayout()
        id_label = QLabel("ID:")
        self.id_input = QLineEdit()
        id_layout.addWidget(id_label)
        id_layout.addWidget(self.id_input)
        patient_layout.addLayout(id_layout)

        # Медицинская история
        history_layout = QHBoxLayout()
        history_label = QLabel("История болезней:")
        self.history_input = QLineEdit()
        history_layout.addWidget(history_label)
        history_layout.addWidget(self.history_input)
        patient_layout.addLayout(history_layout)

        patient_group.setLayout(patient_layout)
        layout.addWidget(patient_group)

        # Работа с изображением
        img_btn_layout = QHBoxLayout()
        self.upload_btn = QPushButton("Загрузить изображение")
        self.analyze_btn = QPushButton("Анализировать")
        img_btn_layout.addWidget(self.upload_btn)
        img_btn_layout.addWidget(self.analyze_btn)
        layout.addLayout(img_btn_layout)

        # Просмотр изображения
        self.image_view = QGraphicsView()
        self.image_scene = QGraphicsScene()
        self.image_view.setScene(self.image_scene)
        layout.addWidget(self.image_view)

        # Кнопка назад
        self.back_btn = QPushButton("Назад")
        layout.addWidget(self.back_btn)

        # Подключение сигналов
        self.upload_btn.clicked.connect(self.load_image)
        self.analyze_btn.clicked.connect(self.analyze_image)
        self.back_btn.clicked.connect(self.parent.show_main_menu)
        new_patient_btn.clicked.connect(self.add_patient)

        self.setLayout(layout)

    def load_image(self):
        """Загрузка изображения через диалоговое окно"""
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Выберите изображение",
            "",
            "Images (*.png *.jpg *.jpeg *.bmp)"
        )

        if file_path:
            saved_path = self.parent.backend.image_backend.save_mole_image(file_path)
            if saved_path:
                pixmap = QPixmap(saved_path)
                self.image_scene.clear()
                self.image_scene.addPixmap(pixmap)
                self.image_view.fitInView(self.image_scene.itemsBoundingRect(), Qt.KeepAspectRatio)

    def analyze_image(self):
        """Анализ загруженного изображения"""
        if not self.parent.backend.image_backend.current_image_path:
            print("Сначала загрузите изображение")
            return

        result = self.parent.backend.image_backend.analyze_mole()
        print("Результат анализа:", result)
        # Здесь можно добавить вывод результатов в интерфейс

    def add_patient(self):
        """Добавление нового пациента"""
        patient_data = {
            "full_name": self.name_input.text(),
            "gender": self.gender_combo.currentText(),
            "birth_date": self.birth_date.date().toString("dd.MM.yyyy"),
            "contact": self.contact_input.text(),
            "address": self.address_input.text(),
            "id": self.id_input.text(),
            "medical_history": self.history_input.text(),
            "image_path": self.parent.backend.image_backend.current_image_path
        }

        patient_id = self.parent.backend.add_patient(patient_data)
        print(f"Добавлен пациент с ID: {patient_id}")

class SkinSightApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("SkinSight")
        self.setGeometry(100, 100, 800, 600)

        # Инициализация backend
        self.backend = SkinSightBackend()

        # Настройка интерфейса
        self.stacked_widget = QStackedWidget()
        self.setCentralWidget(self.stacked_widget)

        # Создание страниц
        self.main_menu_page = MainMenuPage(self)
        self.patients_page = PatientsPage(self)

        # Добавление страниц
        self.stacked_widget.addWidget(self.main_menu_page)
        self.stacked_widget.addWidget(self.patients_page)

        # Подключение сигналов
        self.main_menu_page.patients_btn.clicked.connect(self.show_patients)
        self.main_menu_page.new_analysis_btn.clicked.connect(self.show_patients)

    def show_main_menu(self):
        self.stacked_widget.setCurrentWidget(self.main_menu_page)

    def show_patients(self):
        self.stacked_widget.setCurrentWidget(self.patients_page)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = SkinSightApp()
    window.show()
    sys.exit(app.exec_())
