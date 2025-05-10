// CancerMoles/components/AnalysisWorkspace.qml
import QtQuick
import QtQuick.Layouts
import CancerMoles.components 1.0 // Для Constants, PatientDataForm, кнопок

Rectangle { // Корневой элемент, фон будет от WorkspacePanel/Container на MainScreen
    id: analysisWorkspaceRoot
    color: "transparent" // Фон уже предоставлен родительским контейнером (белый)
    signal analysisTriggered(url imageSource, string imageName, string patientId) // Передаем данные для анализа
    // Свойства для данных (пока не используются, но могут понадобиться)
    // property var currentPatient: null
    // property url currentImageSource: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20 // Внутренние отступы для всего контента от краев рабочей области
        spacing: 25 // Расстояние между левой и правой колонками


        RowLayout{
            Layout.fillWidth: parent
            Layout.fillHeight: parent

        // --- Левая колонка: Изображение и кнопка загрузки ---
            ColumnLayout {
                id: leftColumn
                Layout.preferredWidth: analysisWorkspaceRoot.width * 0.55 // Чуть больше половины для изображения
                Layout.fillHeight: true
                spacing: 20

                Rectangle { // Плейсхолдер для изображения
                    id: imageDisplayArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: leftColumn.height * 0.7 // Большую часть высоты левой колонки
                    // Для более точного соответствия макету, можно попробовать фиксированную высоту или соотношение сторон
                    // Например, если изображение обычно 4:3 и ширина колонки ~400, то высота ~300
                    // Layout.preferredHeight: Math.min(leftColumn.height * 0.7, width * 0.75) // Попытка сохранить пропорции

                    color: Constants.imagePlaceholder // Серый цвет
                    border.color: Constants.borderPrimary
                    border.width: 1
                    radius: 6

                    // Здесь будет Image для отображения загруженного фото
                    Image {
                        id: loadedImage
                        anchors.fill: parent
                        anchors.margins: 5 // Небольшой отступ от рамки плейсхолдера
                        source: "" // Будет устанавливаться динамически
                        fillMode: Image.PreserveAspectFit
                        visible: source !== "" // Показываем, только если есть изображение
                    }

                    Text { // Текст, если изображение не загружено
                        anchors.centerIn: parent
                        text: qsTr("Изображение не загружено")
                        color: Constants.textPlaceholder
                        visible: loadedImage.source === ""
                        font.pixelSize: 16
                    }
                }

                // LargeActionButton {
                //     id: loadImageButton
                //     text: qsTr("Загрузить изображение")
                //     Layout.alignment: Qt.AlignHCenter
                //     // Layout.preferredWidth: leftColumn.width * 0.7 // Можно ограничить ширину
                //     onClicked: {
                //         console.log("Загрузить изображение - нажато")
                //         // TODO: Логика открытия диалога выбора файла и установки loadedImage.source
                //         // Например: loadedImage.source = "file:///path/to/image.jpg"
                //     }
                // }

                Item { Layout.fillHeight: true } // Распорка, чтобы кнопка не растягивалась сильно при малом контенте
            }

            // --- Правая колонка: Данные пациента и кнопка анализа ---
            ColumnLayout {
                id: rightColumn
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                RowLayout { // Кнопки "Новый пациент" и "Выбрать пациента"
                    // Layout.fillWidth: true // Растягиваем по ширине правой колонки
                    Layout.alignment: Qt.AlignRight // Чтобы кнопки были справа
                    spacing: 10

                    SmallActionButton {
                        text: qsTr("Новый пациент")
                        onClicked: console.log("Новый пациент - нажато")
                    }
                    SmallActionButton {
                        text: qsTr("Выбрать пациента")
                        onClicked: console.log("Выбрать пациента - нажато")
                    }
                }

                PatientDataForm {
                    id: patientForm
                    Layout.fillWidth: true
                    // titleText: qsTr("Данные по пациенту:") // Можно переопределить заголовок, если нужно
                    // Пример заполнения (будет динамическим)
                    // patientName: "Петров Петр Петрович"
                    // patientGender: "Мужской"
                    // patientBirthDate: "15.05.1975"
                    // patientId: "P002"
                }

                Item { Layout.fillHeight: true } // Распорка, чтобы кнопка "Анализировать" была внизу

                // AccentActionButton {
                //     id: analyzeDataButton
                //     text: qsTr("Анализировать")
                //     Layout.fillWidth: true // Растянуть на всю ширину правой колонки
                //     Layout.preferredHeight: 50 // Задаем высоту явно, как на макете
                //     onClicked: {
                //         console.log("Анализировать - нажато")
                //         // TODO: Логика сбора данных и запуска анализа
                //     }
                // }
            }
        }
        RowLayout {
            id: buttonsColumn
            Layout.fillWidth: parent
            Layout.preferredHeight: 50
            spacing: 20

            LargeActionButton {
                id: loadImageButton
                text: qsTr("Загрузить изображение")
                Layout.preferredWidth: 250
                Layout.preferredHeight: 50
                //Layout.alignment: Qt.AlignHCenter
                // Layout.preferredWidth: leftColumn.width * 0.7 // Можно ограничить ширину
                onClicked: {
                    console.log("Загрузить изображение - нажато")
                    // TODO: Логика открытия диалога выбора файла и установки loadedImage.source
                    // Например: loadedImage.source = "file:///path/to/image.jpg"
                }
            }

            Item {
                Layout.fillWidth: true
            }

            AccentActionButton {
                id: analyzeDataButton
                text: qsTr("Анализировать")
                Layout.preferredWidth: 250
                Layout.preferredHeight: 50
                onClicked: {
                    console.log("Анализировать - нажато");
                    // Предположим, у нас есть данные для передачи
                    var imgSrc = loadedImage.source; // или ссылка на выбранный файл
                    var imgName = "какое-то_имя.jpg"; // из выбранного файла или поля ввода
                    var patId = patientForm.patientId;  // из формы

                    // Эмитируем сигнал
                    analysisWorkspaceRoot.analysisTriggered(imgSrc, imgName, patId);
                }
            }
        }

    }
    // Item {
    //     Layout.fillHeight: true
    //     Layout.fillWidth: true
    // }
}
