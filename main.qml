import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 2.3
import Qt.labs.platform 1.1

ApplicationWindow {
    id: mainWindow
    width: 1000
    height: 800
    visible: true
    title: "SkinSight - Анализатор родинок"

    property string currentUser: "Доктор Иванов"
    property string currentImagePath: ""
    property var analysisResult: ({})

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuPage
    }

    Component {
        id: mainMenuPage
        Rectangle {
            RowLayout {
                anchors.fill: parent
                ColumnLayout {
                    Layout.preferredWidth: 200
                    spacing: 10

                    Label { text: "Меню"; font.bold: true }
                    Button { text: "Пациенты"; onClicked: stackView.push(patientsPage) }
                    Button { text: "Анализы" }
                    Button { text: "Настройки" }
                }
                ColumnLayout {
                    Label {
                        text: `Добро пожаловать, ${currentUser}!`
                        font.pixelSize: 18
                    }

                    Rectangle { height: 1; color: "gray"; Layout.fillWidth: true }

                    Button {
                        text: "НОВЫЙ АНАЛИЗ"
                        onClicked: stackView.push(patientsPage)
                    }

                    Button {
                        text: "Выход"
                        onClicked: Qt.quit()
                    }
                }
            }
        }
    }

    Component {
        id: patientsPage
        Rectangle {
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                RowLayout {
                    Button { text: "Новый пациент"; onClicked: addPatient() }
                    Button { text: "Выбрать пациента" }
                }
                GroupBox {
                    title: "Данные пациента"
                    Layout.fillWidth: true

                    GridLayout {
                        columns: 2
                        width: parent.width

                        Label { text: "ФИО:" }
                        TextField { id: fullNameField }

                        Label { text: "Пол:" }
                        ComboBox {
                            model: ["Мужской", "Женский"]
                            currentIndex: 0
                        }

                        Label { text: "Дата рождения:" }
                        TextField {
                            text: Qt.formatDate(new Date(), "dd.MM.yyyy")
                        }

                        Label { text: "Телефон:" }
                        TextField { }

                        Label { text: "Адрес:" }
                        TextField { }

                        Label { text: "ID:" }
                        TextField { }

                        Label { text: "История болезней:" }
                        TextArea { }
                    }
                }

                RowLayout {
                    Button {
                        text: "Загрузить изображение"
                        onClicked: fileDialog.open()
                    }

                    Button {
                        text: "Анализировать"
                        onClicked: analyzeImage()
                        enabled: currentImagePath !== ""
                    }
                }

                Image {
                    id: moleImage
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    fillMode: Image.PreserveAspectFit
                    source: currentImagePath
                }
                GroupBox {
                    title: "Результаты анализа"
                    Layout.fillWidth: true

                    TextArea {
                        id: resultText
                        width: parent.width
                        readOnly: true
                        text: JSON.stringify(analysisResult, null, 2)
                        color: analysisResult.diagnosis === "Злокачественное" ? "red" : "black"
                        font.weight: analysisResult.diagnosis === "Злокачественное" ? Font.Bold : Font.Normal
                    }
                }

                Button {
                    text: "Назад в меню"
                    onClicked: stackView.pop()
                }
            }
        }
    }

    FileDialog {
           id: fileDialog
           title: "Выберите изображение"
           nameFilters: ["Images (*.png *.jpg *.jpeg)"]
           onAccepted: {
               currentImagePath = backend.save_image(selectedFile)
           }
       }
   
       Connections {
           target: backend
           function onAnalysisComplete(result) {
               analysisResult = {
                   status: result.status,
                   diagnosis: result.diagnosis,
                   confidence: result.confidence,
                   malignant_prob: result.malignant_prob,
                   benign_prob: result.benign_prob,
                   recommendation: result.recommendation
               }
           }
       }
   
       function analyzeImage() {
           backend.analyze_image(currentImagePath)
       }


    function addPatient() {
        console.log("Добавлен новый пациент:", fullNameField.text)
    }
}

