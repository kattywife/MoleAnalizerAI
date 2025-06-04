// CancerMoles/components/PatientsWorkspace.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components" as Components
import "../" as App

Rectangle {
    id: patientsWorkspaceRoot
    color: "transparent"

    property string currentSearchTerm: ""
    property list<variant> modelProbabilities: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Search bar
        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: qsTr("Поиск пациентов по ФИО или телефону...")
            color: App.Constants.textSecondary
            leftPadding: 10 // Make space for the icon
            rightPadding: 10

            background: Rectangle {
                color: "white" //App.Constants.appBackground
                border.color: App.Constants.divider
                border.width: 1
                radius: 18 
                implicitHeight: 36
                implicitWidth: 200
            }

            Timer {
                id: searchTimer
                interval: 500
                onTriggered: {
                    currentSearchTerm = searchField.text
                    if (currentSearchTerm.length >= 3) {
                        const results = backend.search_patients(currentSearchTerm)
                        patientsListView.model = results
                    } else {
                        patientsListView.model = []
                    }
                }
            }

            onTextChanged: searchTimer.restart()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 25

            // Left column with patient list and details
            ColumnLayout {
                Layout.preferredWidth: parent.width * 0.4
                Layout.fillHeight: true
                spacing: 15

                // Patients list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //Layout.preferredHeight: parent.height * 0.4
                    color: "white"
                    border.color: App.Constants.divider
                    border.width: 1
                    radius: App.Constants.radiusMedium

                    ListView {
                        id: patientsListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: []

                        delegate: ItemDelegate {
                            width: parent.width
                            height: 60

                            background: Rectangle { 
                                color: "transparent"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                Text {
                                    text: modelData.full_name
                                    font.bold: true
                                    color: App.Constants.textPrimary
                                }

                                Text {
                                    text: qsTr("Телефон: ") + (modelData.phone || qsTr("Не указан"))
                                    color: App.Constants.textSecondary
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: qsTr("Дата рождения: ") + Qt.formatDate(new Date(modelData.birth_date), "dd.MM.yyyy")
                                    color: App.Constants.textSecondary
                                    font.pixelSize: 12
                                }
                            }

                            onClicked: {
                                patientDetailsForm.updateFromData(modelData)
                                const analyses = backend.get_patient_analyses(modelData.id)
                                patientHistoryTable.analyses = analyses
                            }
                        }

                        ScrollBar.vertical: ScrollBar {}
                    }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (searchField.text.length < 3) 
                                return qsTr("Введите минимум 3 символа для поиска")
                            if (patientsListView.count === 0) 
                                return qsTr("Ничего не найдено")
                            return ""
                        }
                        color: App.Constants.textPlaceholder
                        visible: patientsListView.count === 0
                    }
                }

                // Patient details form
                Components.PatientDataForm {
                    id: patientDetailsForm
                    Layout.fillWidth: true
                    //Layout.fillHeight: true

                    Component.onCompleted: {
                        backend.patientUpdated.connect(function(patientId) {
                            if (patientId === patientDetailsForm.patientId) {
                                const details = backend.get_patient_details(patientId)
                                if (details) {
                                    updateFromData(details)
                                    patientHistoryTable.analyses = details.analyses || []
                                }
                            }
                        })
                    }
                }
            }

            // Right column with analysis history
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                Text {
                    text: qsTr("История анализов")
                    font.bold: true
                    font.pixelSize: 18
                    color: App.Constants.textPrimary
                }

                Components.AnalysisHistoryTable {
                    id: patientHistoryTable
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onAnalysisSelected: function(analysis) {
                        // Show analysis details in a dialog
                        analysisDetailsDialog.imageSource = "../../" + analysis.image_path // Temp because of /frontend/screens
                        analysisDetailsDialog.melanomaProbability = analysis.melanoma_probability * 100
                        analysisDetailsDialog.diagnosisText = analysis.diagnosis_text
                        //patientsWorkspaceRoot.modelProbabilities = analysis.predictions //modelProbabilities
                        probabilityTableInstance.modelData = probabilityTableInstance.modelPredictionsToArray(analysis.predictions) //modelProbabilities
                        console.log(analysis.predictions )
                        analysisDetailsDialog.open()
                    }
                }
            }
        }
    }

    Dialog {
        id: analysisDetailsDialog
        title: qsTr("Детали анализа")
        modal: true
        width: parent.width * 0.85
        height: parent.height * 0.85
        anchors.centerIn: parent

        property url imageSource: ""
        property real melanomaProbability: 0
        property string diagnosisText: ""

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

        contentItem: RowLayout {
            spacing: 20

            Rectangle {
                Layout.preferredWidth: parent.width * 0.55
                Layout.fillHeight: true
                color: App.Constants.appBackground
                border.color: App.Constants.divider
                border.width: 1
                radius: App.Constants.radiusMedium

                Image {
                    anchors.fill: parent
                    anchors.margins: 10
                    source: analysisDetailsDialog.imageSource
                    fillMode: Image.PreserveAspectFit
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                Components.MelanomaIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    value: analysisDetailsDialog.melanomaProbability
                }

                Text {
                    text: analysisDetailsDialog.diagnosisText //detail_text
                    color: App.Constants.textPrimary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Components.ProbabilityDiagnosisTable {
                        id: probabilityTableInstance
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        modelData: patientsWorkspaceRoot.modelProbabilities
                    }

                Item { Layout.fillHeight: true }
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
    }
}
