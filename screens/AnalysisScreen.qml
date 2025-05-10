import QtQuick
import QtQuick.Layouts
import CancerMoles.components 1.0 // Ваш модуль с компонентами и константами
import CancerMoles 1.0

Rectangle {
    id: analysisScreen
    width: 1024 // Примерная ширина
    height: 768 // Примерная высота
    color: Constants.appBackground

    // --- ВЕРХНЯЯ ПАНЕЛЬ (HEADER) ---
    // (Такая же, как в MainScreen.qml - можно вынести в компонент позже)
    Rectangle {
        id: header
        width: parent.width
        height: 60
        color: Constants.headerBackground
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 10

            Logo {
                id: headerLogo
                implicitWidth: 40
                implicitHeight: 40
                logoSource: "qrc:/qt/qml/CancerMoles/assets/images/logo.png" // ВАШ ПУТЬ К ЛОГО
            }
            Text {
                text: qsTr("SkinSight")
                color: Constants.headerText
                font.pixelSize: 24
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
            Item { Layout.fillWidth: true }
            Text {
                text: qsTr("Добро пожаловать, Иван Иванов!") // TODO: Динамически
                color: Constants.headerText
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
            Rectangle {
                width: 36; height: 36; radius: width / 2
                color: Constants.headerText
                border.color: Qt.darker(Constants.headerBackground, 1.2)
                border.width: 1
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // --- КОНТЕЙНЕР ДЛЯ ОСНОВНОГО СОДЕРЖИМОГО ---
    Rectangle {
        id: contentWrapper
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        color: Constants.appBackground
        border.color: Constants.divider
        border.width: 1
        radius: 8

        RowLayout {
            id: mainAreaLayout
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            // --- ЛЕВОЕ МЕНЮ ---
            // (Такое же, как в MainScreen.qml, но активна другая кнопка)
            Rectangle {
                id: leftMenuPanel
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 15
                    anchors.bottomMargin: 15
                    spacing: 10

                    CustomMenuButton {
                        text: qsTr("Главное меню")
                        Layout.fillWidth: true
                    }
                    CustomMenuButton {
                        text: qsTr("Пациенты")
                        Layout.fillWidth: true
                    }
                    CustomMenuButton {
                        text: qsTr("Анализы")
                        Layout.fillWidth: true
                        // Делаем эту кнопку "активной"
                        // Используем цвета, которые имитируют "нажатое" состояние или специальные цвета для активного пункта
                        //normalColor: Constants.buttonSecondaryPressed // Светло-розовый фон
                        // Можно также изменить цвет рамки, если нужно более явное выделение
                        // borderColor: Constants.buttonSecondaryBorder // Оставляем стандартную коричневую рамку
                                                                    // или можно Constants.headerBackground для бордовой
                    }
                    CustomMenuButton {
                        text: qsTr("Настройки")
                        Layout.fillWidth: true
                    }
                    Item { Layout.fillHeight: true }
                    CustomMenuButton {
                        text: qsTr("Выход")
                        Layout.fillWidth: true
                        onClicked: {
                            console.log("Выход нажат на экране Анализы")
                            // Qt.quit()
                        }
                    }
                }
            }

            // --- РАБОЧАЯ ОБЛАСТЬ ЭКРАНА "АНАЛИЗЫ" ---
            Item { // Используем Item как гибкий контейнер для более сложного Layout
                id: workspace
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10 // Отступы внутри рабочей области
                    spacing: 20 // Расстояние между левой (изображение) и правой (данные) колонками

                    // --- Левая колонка: Изображение и кнопка загрузки ---
                    ColumnLayout {
                        id: leftColumn
                        Layout.preferredWidth: workspace.width * 0.5 // Примерно половина ширины
                        Layout.fillHeight: true
                        spacing: 15

                        // Плейсхолдер для изображения
                        Rectangle {
                            id: imagePlaceholder
                            Layout.fillWidth: true
                            Layout.preferredHeight: leftColumn.height * 0.6 // Занимает большую часть высоты левой колонки
                                                                          // или можно задать фиксированную высоту
                            // Layout.preferredHeight: 300
                            color: Constants.imagePlaceholder // Серый цвет из констант
                            border.color: Constants.borderPrimary
                            border.width: 1
                            radius: 4
                            // TODO: Здесь будет отображаться загруженное изображение
                        }

                        LargeActionButton {
                            id: loadImageButton
                            text: qsTr("Загрузить изображение")
                            Layout.alignment: Qt.AlignHCenter
                            // implicitWidth: leftColumn.width * 0.8 // Ширина относительно колонки
                            onClicked: {
                                console.log("Загрузить изображение")
                                // TODO: Логика загрузки изображения
                            }
                        }
                         Item { Layout.fillHeight: true } // Распорка, чтобы кнопка не прилипала к низу, если мало места
                    }

                    // --- Правая колонка: Данные пациента и кнопка анализа ---
                    ColumnLayout {
                        id: rightColumn
                        Layout.fillWidth: true
                        Layout.fillHeight: true // Заполняет доступную высоту
                        spacing: 15
                        // Layout.alignment: Qt.AlignTop // Выравнивание по верху

                        // Кнопки "Новый пациент" и "Выбрать пациента"
                        RowLayout {
                            spacing: 10
                            Layout.alignment: Qt.AlignRight // Прижать к правому краю

                            SmallActionButton {
                                text: qsTr("Новый пациент")
                                onClicked: {
                                    console.log("Новый пациент")
                                    // TODO: Логика создания нового пациента
                                }
                            }
                            SmallActionButton {
                                text: qsTr("Выбрать пациента")
                                onClicked: {
                                    console.log("Выбрать пациента")
                                    // TODO: Логика выбора пациента
                                }
                            }
                        }

                        PatientDataForm {
                            id: patientForm
                            Layout.fillWidth: true
                            // Заполняем данными (пока статично для примера)
                            // patientName: "Иванов Иван Иванович"
                            // patientGender: "Мужской"
                            // patientBirthDate: "01.01.1980"
                            // patientId: "P001"
                        }

                        Item { Layout.fillHeight: true } // Распорка, чтобы кнопка "Анализировать" была внизу

                        AccentActionButton {
                            id: analyzeDataButton
                            text: qsTr("Анализировать")
                            Layout.fillWidth: true // Растянуть на всю ширину правой колонки
                            // implicitHeight: 50 // Можно задать фиксированную высоту, если нужно
                            onClicked: {
                                console.log("Анализировать")
                                // TODO: Логика анализа
                            }
                        }
                    }
                }
            }
        }
    }
}
