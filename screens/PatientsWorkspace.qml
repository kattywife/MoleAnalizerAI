// CancerMoles/components/PatientsWorkspace.qml
import QtQuick
import QtQuick.Layouts
import CancerMoles.components 1.0 // Для Constants, кнопок, PatientDataForm, AnalysisHistoryTable

Rectangle {
    id: patientsWorkspaceRoot
    color: "transparent" // Фон от родительского WorkspacePanel/Container

    // Модель данных для таблицы (пример)
    property list<variant> sampleHistoryData: [
        { analysisDate: "01.01.2024", riskValue: "13%" },
        { analysisDate: "15.02.2024", riskValue: "10%" },
        { analysisDate: "10.03.2024", riskValue: "25%" },
        { analysisDate: "20.04.2024", riskValue: "8%" }
    ]

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20 // Общие отступы для контента
        spacing: 25 // Расстояние между левой и правой колонками

        // --- Левая колонка: Кнопки действий и форма данных пациента ---
        ColumnLayout {
            id: leftPatientColumn
            Layout.preferredWidth: patientsWorkspaceRoot.width * 0.40 // Примерно 40% ширины
            Layout.fillHeight: true
            spacing: 25 // Вертикальный зазор между элементами

            // Кнопки "История анализов" и "Выбор пациента"
            // Используем LargeActionButton, так как они выглядят крупнее SmallActionButton
            LargeActionButton {
                id: btnAnalysisHistory
                text: qsTr("История анализов")
                Layout.fillWidth: true // Растягиваем по ширине колонки
                // Layout.preferredHeight: 50 // Если нужна фиксированная высота
                onClicked: console.log("Кнопка 'История анализов' нажата")
            }

            LargeActionButton {
                id: btnSelectPatient
                text: qsTr("Выбор пациента")
                Layout.fillWidth: true
                onClicked: console.log("Кнопка 'Выбор пациента' нажата")
            }

            Item{Layout.fillHeight: true}

            // Форма данных пациента
            PatientDataForm {
                id: patientDetailsForm
                Layout.fillWidth: true
                // Layout.preferredHeight: patientDetailsForm.implicitHeight // Чтобы не растягивалась сильно, если есть место
                // Пример заполнения
                // patientName: "Сидоров Сидор Сидорович"
                // patientGender: "Мужской"
                // patientBirthDate: "10.10.1990"
                // patientId: "P003"
            }
        }

        // --- Правая колонка: Таблица истории анализов ---
        ColumnLayout { // Используем ColumnLayout, если над таблицей может быть заголовок или другие элементы
            id: rightHistoryColumn
            Layout.fillWidth: true // Занимает оставшуюся ширину
            Layout.fillHeight: true
            spacing: 10 // Если будут другие элементы

            // Заголовок для таблицы (опционально, если не встроен в саму таблицу)
            /*
            Text {
                text: qsTr("История анализов пациента:")
                font.bold: true
                font.pixelSize: 18
                color: Constants.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            */

            AnalysisHistoryTable {
                id: patientHistoryTable
                Layout.fillWidth: true
                Layout.fillHeight: true // Таблица занимает все доступное место в правой колонке
                //tableModel: patientsWorkspaceRoot.sampleHistoryData // Передаем модель данных
            }
        }
    }
}
