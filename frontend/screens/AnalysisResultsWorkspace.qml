// CancerMoles/components/AnalysisResultsWorkspace.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components" as Components
import "../" as App

Rectangle {
    id: resultsWorkspaceRoot
    color: "transparent" // Фон от родительского WorkspacePanel/Container

    // Свойства для отображения данных (будут передаваться извне)
    property url imageSourceToDisplay: "" // Путь к изображению, которое было проанализировано
    property string imageName: "" // Имя файла для отображения
    property real melanomaProbability: 0 // Вероятность меланомы (0-100)
    property string diagnosisText: "" // Текст диагноза
    property string detailText: "" // Детальный текст
    property bool isSaved: false // Сохранен ли результат

    // Сигналы для кнопок
    signal backClicked()
    signal saveResultClicked()
    signal finishAnalysisClicked()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20 // Общие отступы для контента
        spacing: 25

        // --- Левая колонка: Изображение, имя файла и кнопка "Назад" ---
        ColumnLayout {
            id: leftResultsColumn
            Layout.preferredWidth: resultsWorkspaceRoot.width * 0.40 // Та же пропорция, что и на экране анализа
            Layout.fillHeight: true
            spacing: 15

            Rectangle { // Плейсхолдер/отображение изображения
                id: imageDisplayAreaResults
                Layout.fillWidth: true
                Layout.preferredHeight: leftResultsColumn.height * 0.7 // Пропорции как на предыдущем экране
                color: App.Constants.appBackground // Фон, если изображение не загрузится
                border.color: App.Constants.divider
                border.width: 1
                radius: App.Constants.radiusMedium

                Image {
                    id: analyzedImage
                    anchors.fill: parent
                    anchors.margins: 5
                    source: resultsWorkspaceRoot.imageSourceToDisplay // Используем переданный источник
                    fillMode: Image.PreserveAspectFit
                    visible: source !== ""
                }
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Изображение не доступно")
                    color: App.Constants.textPlaceholder
                    visible: analyzedImage.source === "" || analyzedImage.status === Image.Error
                    font.pixelSize: 16
                }
            }

            Text { // Исходное изображение: имя файла
                text: qsTr("Исходное изображение:\n") + resultsWorkspaceRoot.imageName
                color: App.Constants.textPrimary
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true } // Распорка, чтобы кнопка "Назад" была внизу

            Components.SmallActionButton { // Кнопка "Назад"
                text: qsTr("Назад")
                Layout.alignment: Qt.AlignHCenter // Или Qt.AlignLeft / Qt.AlignRight по вашему усмотрению
                onClicked: resultsWorkspaceRoot.backClicked()
            }
        }

        // --- Правая колонка: Результаты анализа и кнопки действий ---
        ColumnLayout {
            id: rightResultsColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Блок с результатами (рамка, заголовок, индикатор)
            Rectangle {
                id: resultsBlock
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white" // Белый фон для блока
                border.color: App.Constants.divider // Коричневая рамка
                border.width: 1
                radius: App.Constants.radiusMedium // Скругление углов

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20 // Внутренние отступы
                    spacing: 20

                    Text {
                        text: resultsWorkspaceRoot.diagnosisText
                        color: getRiskColor(melanomaProbability)
                        font.bold: true
                        font.pixelSize: 20
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    Components.MelanomaIndicator {
                        id: probabilityIndicator
                        value: resultsWorkspaceRoot.melanomaProbability
                        implicitWidth: 200 // Задаем размеры для индикатора
                        implicitHeight: 100
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: resultsWorkspaceRoot.detailText
                        color: App.Constants.textSecondary
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: App.Constants.divider
                        visible: recommendationsList.count > 0
                    }

                    Components.ProbabilityDiagnosisTable {
                        id: probabilityTableInstance
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Define its ideal flexible height range
                        //Layout.minimumHeight: 50  // Smallest it can be before it might as well disappear
                                                 // (or 0 if you want it to fully disappear via layout)
                        //Layout.preferredHeight: probabilityTableInstance.implicitHeight // It wants to be its full content height
                        //Layout.maximumHeight: 400 // But not more than this

                        modelData: [
                            { probability: "87.4%", diagnosis: qsTr("Пигментный невус") },
                            { probability: "43.6%", diagnosis: qsTr("Базалиома") },
                            { probability: "32.1%", diagnosis: qsTr("Кератоз") },
                            { probability: "23.3%", diagnosis: qsTr("Себорейный кератоз") },
                            { probability: "14.2%", diagnosis: qsTr("Дерматофиброма") },
                            { probability: "10.5%", diagnosis: qsTr("Актинический кератоз") },
                            { probability: "5.2%", diagnosis: qsTr("Лентиго") },
                            { probability: "0.0%", diagnosis: qsTr("Меланома") }
                            // Add more items to ensure overflow for testing height: 250
                        ]
                    }

                    Item{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    // ListView {
                    //     id: recommendationsList
                    //     Layout.fillWidth: true
                    //     Layout.preferredHeight: contentHeight
                    //     interactive: false
                    //     model: ListModel {
                    //         ListElement { text: "Регулярно проводите самообследование кожи" }
                    //         ListElement { text: "Обратитесь к дерматологу для профессиональной консультации" }
                    //         ListElement { text: "Избегайте длительного пребывания на солнце" }
                    //     }
                    //     delegate: Text {
                    //         width: recommendationsList.width
                    //         text: "• " + model.text
                    //         color: App.Constants.textSecondary
                    //         wrapMode: Text.WordWrap
                    //         topPadding: 4
                    //         bottomPadding: 4
                    //     }
                    // }
                }
            } // Конец resultsBlock

            Components.LargeActionButton {
                id: saveResultButton
                text: qsTr("Сохранить результат")
                Layout.fillWidth: true
                enabled: !isSaved
                onClicked: {
                    isSaved = true
                    resultsWorkspaceRoot.saveResultClicked()
                }
            }

            Components.AccentActionButton {
                id: finishAnalysisButton
                text: qsTr("Закончить анализ")
                Layout.fillWidth: true
                Layout.preferredHeight: 50 
                onClicked: resultsWorkspaceRoot.finishAnalysisClicked()
            }
        }
    }

    function getRiskColor(probability) {
        if (probability > 70) {
            return App.Constants.melanomaProbabilityHigh
        } else if (probability > 40) {
            return App.Constants.melanomaProbabilityMedium
        }
        return App.Constants.melanomaProbabilityLow
    }

    Component.onCompleted: {
        const result = backend.get_current_analysis_result()
        if (result) {
            diagnosisText = result.diagnosis || ""
            detailText = result.detail_text || ""
            // Other properties are set by MainScreen
        }
    }
}
