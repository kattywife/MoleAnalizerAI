import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../" as App
import "../components" as Components

Dialog {
    id: root
    title: qsTr("Поиск пациента")
    modal: true
    width: 600
    height: 400

    // Signal emitted when a patient is selected
    signal patientSelected(var patientData)

    // Search results model
    ListModel { id: searchResultsModel }

    background: Rectangle {
                color: "white"
                border.color: App.Constants.divider
                border.width: 1
                radius: 4
            }

    // --- Custom Header ---
    header: Rectangle {
        id: dialogHeader
        width: parent.width 
        height: 35
        color: "white"

        Text {
            text: qsTr("Детали анализа") // The title text
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            font.pixelSize: 16
            font.bold: true
            color: App.Constants.textPrimary 
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.darker(dialogHeader.color, 1.2) // Slightly darker than header bg
            anchors.bottom: parent.bottom
        }
    }

    contentItem: ColumnLayout {
        spacing: 16

        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: qsTr("Введите ФИО или телефон пациента")
            
            Timer {
                id: searchTimer
                interval: 500
                onTriggered: {
                    const results = backend.search_patients(searchField.text)
                    searchResultsModel.clear()
                    results.forEach(patient => searchResultsModel.append(patient))
                }
            }

            onTextChanged: {
                if (text.length >= 3) {
                    searchTimer.restart()
                } else {
                    searchResultsModel.clear()
                }
            }
        }

        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: searchResultsModel
            clip: true

            delegate: ItemDelegate {
                width: parent.width
                contentItem: ColumnLayout {
                    spacing: 4
                    
                    Text {
                        text: model.full_name
                        font.bold: true
                        color: App.Constants.textPrimary
                    }
                    
                    Text {
                        text: qsTr("Телефон: ") + (model.phone || qsTr("Не указан"))
                        color: App.Constants.textSecondary
                        font.pixelSize: 12
                    }
                    
                    Text {
                        text: qsTr("Дата рождения: ") + Qt.formatDate(new Date(model.birth_date), "dd.MM.yyyy")
                        color: App.Constants.textSecondary
                        font.pixelSize: 12
                    }
                }

                onClicked: {
                    root.patientSelected(model)
                    root.accept()
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        Text {
            text: qsTr("Введите минимум 3 символа для поиска")
            color: App.Constants.textPlaceholder
            visible: searchField.text.length < 3
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("Ничего не найдено")
            color: App.Constants.textPlaceholder
            visible: searchField.text.length >= 3 && searchResultsModel.count === 0
            Layout.alignment: Qt.AlignHCenter
        }
    }

    footer: Rectangle {
            id: dialogFooter
            width: parent.width 
            height: 45
            color: "white"

            RowLayout{
                anchors.fill: parent
                anchors.centerIn: parent
                anchors.margins: 5

                Item{
                    Layout.fillWidth: true
                }

                Components.SmallActionButton{ 
                    id: closeDialogButton
                    text: "Закрыть"

                    onClicked: {
                        analysisDetailsDialog.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.darker(dialogHeader.color, 1.2)
                anchors.top: parent.top
            }
        }

    standardButtons: Dialog.Close

    onOpened: {
        searchField.clear()
        searchField.forceActiveFocus()
    }
}