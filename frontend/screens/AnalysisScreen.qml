import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../components" as Components
import "../" as App

Rectangle {
    id: analysisScreen
    color: App.Constants.appBackground

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Components.TopBar {
            id: topBar
            Layout.fillWidth: true
        }

        Rectangle {
            id: contentWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            color: "transparent"
            border.color: App.Constants.divider
            border.width: 1
            radius: App.Constants.radiusMedium

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Components.LeftMenuPanel {
                    id: leftMenu
                    Layout.preferredWidth: 250
                    Layout.fillHeight: true
                    activeMenuButtonText: qsTr("Анализы")

                    onMenuItemClicked: function(buttonText) {
                        if (buttonText === qsTr("Главное меню")) {
                            stackView.pop()
                        } else if (buttonText === qsTr("Выход")) {
                            Qt.quit()
                        }
                    }
                }

                Components.WorkspacePanel {
                    id: workspace
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StackView {
                        id: stackView
                        anchors.fill: parent
                        initialItem: analysisWorkspace

                        // Transition animation
                        popEnter: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                        }
                        popExit: Transition {
                            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
                        }
                        pushEnter: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                        }
                        pushExit: Transition {
                            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
                        }
                    }
                }
            }
        }
    }

    // Components
    Component {
        id: analysisWorkspace
        AnalysisWorkspace {
            onAnalysisTriggered: function(imageSource, imageName, patientId) {
                stackView.push(analysisResults, {
                    imageSourceToDisplay: imageSource,
                    imageName: imageName,
                    melanomaProbability: backend.get_current_analysis_result().melanoma_probability * 100
                })
            }
        }
    }

    Component {
        id: analysisResults
        AnalysisResultsWorkspace {
            onBackClicked: stackView.pop()
            onSaveResultClicked: {
                const result = backend.get_current_analysis_result()
                if (result && !result.saved) {
                    backend.save_analysis_result()
                }
            }
            onFinishAnalysisClicked: stackView.pop()
        }
    }

    Components.PatientSearchDialog {
        id: patientSearchDialog
        onPatientSelected: function(patientData) {
            backend.currentPatientId = patientData.id
        }
    }

    Connections {
        target: backend
        
        function onErrorOccurred(error) {
            // Show error dialog
            errorDialog.text = error
            errorDialog.open()
        }
    }

    Dialog {
        id: errorDialog
        title: qsTr("Ошибка")
        standardButtons: Dialog.Ok
        modal: true

        Text {
            id: errorText
            wrapMode: Text.WordWrap
            color: App.Constants.textPrimary
        }
    }
}
