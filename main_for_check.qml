import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "SkinSight"

    property var analysisResult: ({})

    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: "Анализ родинки"
                font.pixelSize: 24
                font.bold: true
            }

            RowLayout {
                Button {
                    text: "Загрузить изображение"
                    onClicked: fileDialog.open()
                }

                Button {
                    id: analyzeBtn
                    text: "Анализировать"
                    enabled: backend.imageAnalyzer.currentImagePath !== ""
                    onClicked: {
                        busyIndicator.running = true
                        analyzeBtn.enabled = false
                        backend.imageAnalyzer.analyzeMole()
                    }
                }
            }

            BusyIndicator {
                id: busyIndicator
                running: false
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: "#cccccc"
                radius: 5

                Image {
                    id: moleImage
                    anchors.fill: parent
                    anchors.margins: 5
                    fillMode: Image.PreserveAspectFit
                    source: backend.imageAnalyzer.currentImagePath ? "file:///" + backend.imageAnalyzer.currentImagePath : ""
                }

                Label {
                    anchors.centerIn: parent
                    text: "Изображение не загружено"
                    visible: moleImage.source == ""
                    color: "#666666"
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: analysisResult.diagnosis !== undefined
                title: "Результаты анализа"

                background: Rectangle {
                    border.color: analysisResult.diagnosis === "Злокачественное" ? "#e74c3c" : "#2ecc71"
                    radius: 5
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 8

                    Label {
                        text: "Диагноз: " + (analysisResult.diagnosis || "")
                        font.bold: true
                        color: analysisResult.diagnosis === "Злокачественное" ? "#e74c3c" : "#2ecc71"
                    }

                    Label {
                        text: "Уверенность: " + (analysisResult.confidence ? (analysisResult.confidence * 100).toFixed(1) + "%" : "")
                    }

                    Label {
                        text: "Рекомендация: " + (analysisResult.recommendation || "")
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    FileDialog {
            id: fileDialog
            title: "Выберите изображение"
            nameFilters: ["Images (*.png *.jpg *.jpeg)"]
            onAccepted: {
                // Получаем путь как строку и сразу передаем в бэкенд
                backend.imageAnalyzer.saveMoleImage(String(fileDialog.fileUrl))
            }
        }

        Connections {
            target: backend.imageAnalyzer
            function onImageLoaded(path) {
                console.log("Изображение загружено:", path)
                imagePreview.source = "file:///" + path
            }
        }
    }

    Connections {
        target: backend.imageAnalyzer
        function onAnalysisCompleted(result) {
            busyIndicator.running = false
            analyzeBtn.enabled = true
            analysisResult = result
        }
        function onErrorOccurred(message) {
            busyIndicator.running = false
            analyzeBtn.enabled = true
            errorDialog.text = message
            errorDialog.open()
        }
        function onImageLoaded(path) {
            moleImage.source = "file:///" + path
        }
    }

    Dialog {
        id: errorDialog
        title: "Ошибка"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        width: 400

        Label {
            text: errorDialog.text
            wrapMode: Text.WordWrap
        }
    }
}
