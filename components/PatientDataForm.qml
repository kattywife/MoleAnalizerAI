import QtQuick
// import QtQuick.Controls // Controls больше не нужен, если использовать Text вместо Label
import QtQuick.Layouts

// Импортируем наш синглтон с константами
import CancerMoles 1.0

Rectangle { // Используем Rectangle вместо Frame/Item
    id: root
    implicitWidth: 300 // Задайте желаемую ширину по умолчанию
    // Высота = высота контента + удвоенный отступ
    implicitHeight: contentLayout.implicitHeight + internalPadding * 2
    color: "transparent" // Фон самого Rectangle (можно Constants.appBackground)

    // --- Параметры внешнего вида ---
    readonly property int internalPadding: 10 // Внутренний отступ (бывший padding)
    border.color: Constants.borderPrimary   // Коричневая рамка
    border.width: 2
    radius: 4 // Небольшое скругление углов рамки (опционально)


    // --- Свойства для данных пациента ---
    property alias titleText: titleLabel.text
    property string patientName: ""
    property string patientGender: ""
    property string patientBirthDate: ""
    property string patientId: ""

    // Основной Layout для содержимого (Заголовок + Форма)
    ColumnLayout {
        id: contentLayout
        // Заполняет Rectangle с учетом отступов (margins = padding)
        anchors.fill: parent
        anchors.margins: root.internalPadding // Применяем отступ
        spacing: 15 // Отступ между заголовком и формой

        // Заголовок
        Text { // Используем Text вместо Label, чтобы не тянуть Controls
            id: titleLabel
            text: qsTr("Данные пациента:")
            color: Constants.textPrimary
            font.bold: true
            Layout.fillWidth: true
            // horizontalAlignment: Text.AlignHCenter
        }

        // Форма для данных
        // Форма для данных (ИСПОЛЬЗУЕМ GridLayout)
                    GridLayout { // <--- ЗАМЕНА
                        id: formLayout // Оставляем id для удобства
                        columns: 2     // <--- Указываем 2 колонки
                        Layout.fillWidth: true
                        // Опционально: задать отступ между колонками
                        // columnSpacing: 10

                        // --- Поле: ФИО ---
                        // Колонка 1: Метка
                        Text { text: qsTr("ФИО:"); color: Constants.textPrimary; /* Layout.alignment: Qt.AlignRight */ } // Убрал Layout.labelFor
                        // Колонка 2: Значение/Линия
                        Item {
                            id: nameDisplay
                            Layout.fillWidth: true
                            implicitHeight: nameText.implicitHeight + 4

                            Text {
                                id: nameText
                                text: root.patientName
                                color: Constants.textPrimary
                                visible: root.patientName !== ""
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                height: 1; color: Constants.borderPrimary
                                anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                                visible: root.patientName === ""
                            }
                        }

                        // --- Поле: Пол ---
                        // Колонка 1: Метка
                        Text { text: qsTr("Пол:"); color: Constants.textPrimary; /* Layout.alignment: Qt.AlignRight */ }
                        // Колонка 2: Значение/Линия
                        Item {
                            id: genderDisplay
                            Layout.fillWidth: true
                            implicitHeight: genderText.implicitHeight + 4

                            Text {
                                id: genderText
                                text: root.patientGender
                                color: Constants.textPrimary
                                visible: root.patientGender !== ""
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                height: 1; color: Constants.borderPrimary
                                anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                                visible: root.patientGender === ""
                            }
                        }

                        // --- Поле: Дата рождения ---
                        // Колонка 1: Метка
                        Text { text: qsTr("Дата рождения:"); color: Constants.textPrimary; /* Layout.alignment: Qt.AlignRight */ }
                        // Колонка 2: Значение/Линия
                        Item {
                            id: birthDateDisplay
                            Layout.fillWidth: true
                            implicitHeight: birthDateText.implicitHeight + 4

                            Text {
                                id: birthDateText
                                text: root.patientBirthDate
                                color: Constants.textPrimary
                                visible: root.patientBirthDate !== ""
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                height: 1; color: Constants.borderPrimary
                                anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                                visible: root.patientBirthDate === ""
                            }
                        }

                        // --- Поле: ID ---
                        // Колонка 1: Метка
                        Text { text: qsTr("ID:"); color: Constants.textPrimary; /* Layout.alignment: Qt.AlignRight */ }
                        // Колонка 2: Значение/Линия
                        Item {
                            id: idDisplay
                            Layout.fillWidth: true
                            implicitHeight: idText.implicitHeight + 4

                            Text {
                                id: idText
                                text: root.patientId
                                color: Constants.textPrimary
                                visible: root.patientId !== ""
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                height: 1; color: Constants.borderPrimary
                                anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                                visible: root.patientId === ""
                            }
                        }
                    } // Конец GridLayout
    } // Конец ColumnLayout
} // Конец Rectangle
