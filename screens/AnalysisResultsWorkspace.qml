// CancerMoles/components/AnalysisResultsWorkspace.qml
import QtQuick
import QtQuick.Layouts
import CancerMoles.components 1.0 // Для Constants, кнопок, MelanomaIndicator
import CancerMoles 1.0

Rectangle {
    id: resultsWorkspaceRoot
    color: "transparent" // Фон от родительского WorkspacePanel/Container

    // Свойства для отображения данных (будут передаваться извне)
    property url imageSourceToDisplay: "" // Путь к изображению, которое было проанализировано
    property string imageName: "kakabyaka.jpg" // Имя файла для отображения
    property real melanomaProbability: 90 // Вероятность меланомы (0-100)

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
            Layout.preferredWidth: resultsWorkspaceRoot.width * 0.45 // Та же пропорция, что и на экране анализа
            Layout.fillHeight: true
            spacing: 15

            Rectangle { // Плейсхолдер/отображение изображения
                id: imageDisplayAreaResults
                Layout.fillWidth: true
                Layout.preferredHeight: leftResultsColumn.height * 0.7 // Пропорции как на предыдущем экране
                color: Constants.imagePlaceholder // Фон, если изображение не загрузится
                border.color: Constants.borderPrimary
                border.width: 1
                radius: 6

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
                    color: Constants.textPlaceholder
                    visible: analyzedImage.source === "" || analyzedImage.status === Image.Error
                    font.pixelSize: 16
                }
            }

            Text { // Исходное изображение: имя файла
                text: qsTr("Исходное изображение:\n") + resultsWorkspaceRoot.imageName
                color: Constants.textPrimary
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true } // Распорка, чтобы кнопка "Назад" была внизу

            SmallActionButton { // Кнопка "Назад"
                text: qsTr("Назад")
                Layout.alignment: Qt.AlignHCenter // Или Qt.AlignLeft / Qt.AlignRight по вашему усмотрению
                // Layout.preferredWidth: 150 // Можно задать ширину
                onClicked: resultsWorkspaceRoot.backClicked()
            }
        }

        // --- Правая колонка: Результаты анализа и кнопки действий ---
        ColumnLayout {
            id: rightResultsColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20
            Layout.topMargin: 10 // Небольшой отступ сверху для блока результатов

            // Блок с результатами (рамка, заголовок, индикатор)
            Rectangle {
                id: resultsBlock
                Layout.fillWidth: true
                Layout.fillHeight: true
                // Высота будет определяться содержимым + отступами
                // Layout.preferredHeight: 250 // Можно задать, если нужно
                color: Constants.buttonSecondaryBackground // Белый фон для блока
                border.color: Constants.borderPrimary // Коричневая рамка
                border.width: 2
                radius: 8 // Скругление углов
                Layout.alignment: Qt.AlignTop // Прижимаем блок результатов к верху правой колонки

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15 // Внутренние отступы
                    spacing: 20

                    Text {
                        text: qsTr("Вероятность меланомы:")
                        color: Constants.textPrimary
                        font.bold: true
                        font.pixelSize: 18
                        Layout.alignment: Qt.AlignHCenter
                    }

                    MelanomaIndicator {
                        id: probabilityIndicator
                        value: resultsWorkspaceRoot.melanomaProbability
                        implicitWidth: 120 // Задаем размеры для индикатора
                        implicitHeight: 80
                        // Lsyout.preferredHeight: 80
                        // Lsyout.preferredWidth: 120
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            } // Конец resultsBlock

            Item { Layout.fillHeight: true } // Распорка, чтобы кнопки были внизу

            LargeActionButton {
                id: saveResultButton
                text: qsTr("Сохранить результат")
                Layout.fillWidth: true
                onClicked: resultsWorkspaceRoot.saveResultClicked()
            }

            AccentActionButton {
                id: finishAnalysisButton
                text: qsTr("Закончить анализ")
                Layout.fillWidth: true
                Layout.preferredHeight: 50 // Как на макете
                onClicked: resultsWorkspaceRoot.finishAnalysisClicked()
            }
        }
    }
}
