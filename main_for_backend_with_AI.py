import sys
import os
from PySide6.QtWidgets import (QApplication, QMainWindow, QStackedWidget, QVBoxLayout,
                             QWidget, QLabel, QPushButton, QFrame, QLineEdit,
                             QDateEdit, QComboBox, QGroupBox, QHBoxLayout,
                             QFileDialog, QGraphicsView, QGraphicsScene, QTextEdit,
                             QMessageBox, QProgressDialog)
from PySide6.QtCore import Qt, QDate, QThread, Signal
from PySide6.QtGui import QPixmap
from backend import SkinSightBackend

class AnalysisThread(QThread):
    finished = Signal(dict)
    error = Signal(str)

    def __init__(self, backend):
        super().__init__()
        self.backend = backend

    def run(self):
        try:
            result = self.backend.analyze_mole()
            self.finished.emit(result)
        except Exception as e:
            self.error.emit(str(e))

class MainMenuPage(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.init_ui()
    def init_ui(self):
        main_layout = QHBoxLayout()
        left_menu = QVBoxLayout()
        left_menu.setAlignment(Qt.AlignTop | Qt.AlignLeft)
        
        label_menu = QLabel("Меню")
        self.patients_btn = QPushButton("Пациенты")
        self.analysis_btn = QPushButton("Анализы")
        settings_btn = QPushButton("Настройки")

        left_menu.addWidget(label_menu)
        left_menu.addWidget(self.patients_btn)
        left_menu.addWidget(self.analysis_btn)
        left_menu.addWidget(settings_btn)

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
        exit_btn.clicked.connect(self.parent.close)
        right_content.addWidget(exit_btn)

        main_layout.addLayout(left_menu)
        main_layout.addLayout(right_content)
        self.setLayout(main_layout)

        self.patients_btn.clicked.connect(self.parent.show_patients)
        self.new_analysis_btn.clicked.connect(self.parent.show_patients)

class PatientsPage(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.init_ui()
        self.analysis_thread = None
        self.progress_dialog = None

    def init_ui(self):
        layout = QVBoxLayout()

        control_panel = QHBoxLayout()
        self.new_patient_btn = QPushButton("Новый пациент")
        self.select_patient_btn = QPushButton("Выбрать пациента")
        control_panel.addWidget(self.new_patient_btn)
        control_panel.addWidget(self.select_patient_btn)
        layout.addLayout(control_panel)

        patient_group = QGroupBox("Данные пациента")
        patient_layout = QVBoxLayout()

        fields = [
            ("ФИО:", QLineEdit()),
            ("Пол:", QComboBox()),
            ("Дата рождения:", QDateEdit()),
            ("Телефон:", QLineEdit()),
            ("Адрес:", QLineEdit()),
            ("ID:", QLineEdit()),
            ("История болезней:", QTextEdit())
        ]
        
        fields[1][1].addItems(["Мужской", "Женский"])
        fields[2][1].setDisplayFormat("dd.MM.yyyy")
        fields[2][1].setDate(QDate.currentDate())
        fields[6][1].setMaximumHeight(100)

        self.input_fields = {}
        for label_text, widget in fields:
            row = QHBoxLayout()
            row.addWidget(QLabel(label_text))
            row.addWidget(widget)
            patient_layout.addLayout(row)
            self.input_fields[label_text[:-1]] = widget

        patient_group.setLayout(patient_layout)
        layout.addWidget(patient_group)

        image_panel = QHBoxLayout()
        self.upload_btn = QPushButton("Загрузить изображение")
        self.analyze_btn = QPushButton("Анализировать")
        image_panel.addWidget(self.upload_btn)
        image_panel.addWidget(self.analyze_btn)
        layout.addLayout(image_panel)

        self.image_view = QGraphicsView()
        self.image_scene = QGraphicsScene()
        self.image_view.setScene(self.image_scene)
        layout.addWidget(self.image_view)

        self.result_group = QGroupBox("Результаты анализа")
        result_layout = QVBoxLayout()
        self.result_text = QTextEdit()
        self.result_text.setReadOnly(True)
        result_layout.addWidget(self.result_text)
        self.result_group.setLayout(result_layout)
        layout.addWidget(self.result_group)

        self.back_btn = QPushButton("Назад в меню")
        layout.addWidget(self.back_btn)

        self.setLayout(layout)

        self.upload_btn.clicked.connect(self.load_image)
        self.analyze_btn.clicked.connect(self.start_analysis)
        self.back_btn.clicked.connect(self.parent.show_main_menu)
        self.new_patient_btn.clicked.connect(self.add_patient)

    def load_image(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Выберите изображение родинки",
            "",
            "Images (*.png *.jpg *.jpeg *.bmp)"
        )

        if file_path:
            try:
                saved_path = self.parent.backend.image_analyzer.save_mole_image(file_path)
                if saved_path:
                    pixmap = QPixmap(saved_path)
                    self.image_scene.clear()
                    self.image_scene.addPixmap(pixmap)
                    self.image_view.fitInView(self.image_scene.itemsBoundingRect(), Qt.KeepAspectRatio)
                    self.result_text.clear()
            except Exception as e:
                QMessageBox.critical(self, "Ошибка", str(e))

    def start_analysis(self):
        if not self.parent.backend.image_analyzer.current_image_path:
            QMessageBox.warning(self, "Ошибка", "Сначала загрузите изображение")
            return

        self.progress_dialog = QProgressDialog("Анализ изображения...", "Отмена", 0, 0, self)
        self.progress_dialog.setWindowTitle("Пожалуйста, подождите")
        self.progress_dialog.setWindowModality(Qt.WindowModal)
        self.progress_dialog.setCancelButton(None)  # Нельзя отменить
        self.progress_dialog.show()

        self.analysis_thread = AnalysisThread(self.parent.backend.image_analyzer)
        self.analysis_thread.finished.connect(self.on_analysis_complete)
        self.analysis_thread.error.connect(self.on_analysis_error)
        self.analysis_thread.start()

    def on_analysis_complete(self, result):
        self.progress_dialog.close()

        result_text = (
            f"Диагноз: {result['diagnosis']}\n"
            f"Уверенность: {result['confidence']:.1%}\n"
            f"Вероятность злокачественности: {result['malignant_prob']:.1%}\n"
            f"Вероятность доброкачественности: {result['benign_prob']:.1%}\n\n"
            f"Рекомендация: {result['recommendation']}"
        )

        self.result_text.setPlainText(result_text)

        if result['diagnosis'] == "Злокачественное":
            self.result_group.setStyleSheet("QGroupBox { color: red; font-weight: bold; }")
        else:
            self.result_group.setStyleSheet("")

    def on_analysis_error(self, error_msg):
        self.progress_dialog.close()
        QMessageBox.critical(self, "Ошибка анализа", error_msg)

    def add_patient(self):
        try:
            patient_data = {
                "full_name": self.input_fields["ФИО"].text(),
                "gender": self.input_fields["Пол"].currentText(),
                "birth_date": self.input_fields["Дата рождения"].date().toString("dd.MM.yyyy"),
                "contact": self.input_fields["Телефон"].text(),
                "address": self.input_fields["Адрес"].text(),
                "id": self.input_fields["ID"].text(),
                "medical_history": self.input_fields["История болезней"].toPlainText(),
                "image_path": self.parent.backend.image_analyzer.current_image_path,
                "analysis_result": self.result_text.toPlainText() if not self.result_text.isEmpty() else None
            }

            patient_id = self.parent.backend.add_patient(patient_data)
            QMessageBox.information(self, "Успех", f"Пациент добавлен с ID: {patient_id}")
        except Exception as e:
            QMessageBox.critical(self, "Ошибка", str(e))

class SkinSightApp(QMainWindow):
    def __init__(self, model_path="model.h5"):
        super().__init__()
        self.setWindowTitle("SkinSight - Анализатор родинок")
        self.setMinimumSize(1000, 800)

        if not os.path.exists(model_path):
            QMessageBox.critical(None, "Ошибка",
                                f"Файл модели {model_path} не найден.\n"
                                "Пожалуйста, разместите модель в той же папке.")
            sys.exit(1)
        self.backend = SkinSightBackend(model_path)

        self.stacked_widget = QStackedWidget()
        self.setCentralWidget(self.stacked_widget)

        self.main_menu_page = MainMenuPage(self)
        self.patients_page = PatientsPage(self)

        self.stacked_widget.addWidget(self.main_menu_page)
        self.stacked_widget.addWidget(self.patients_page)

        self.show_main_menu()

    def show_main_menu(self):
        self.stacked_widget.setCurrentWidget(self.main_menu_page)

    def show_patients(self):
        self.stacked_widget.setCurrentWidget(self.patients_page)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle("Fusion")

    try:
        window = SkinSightApp("model.h5")
        window.show()
        sys.exit(app.exec())
    except Exception as e:
        QMessageBox.critical(None, "Фатальная ошибка", f"Не удалось запустить приложение: {str(e)}")
        sys.exit(1)

