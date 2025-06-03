// CancerMoles/components/AnalysisWorkspace.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import "../components" as Components
import "../" as App


Rectangle {
    id: analysisWorkspaceRoot
    color: "transparent"
    
    // Signals for communication with MainScreen
    signal analysisTriggered(url imageSource, string imageName, int patientId)
    
    // Properties to track state
    property bool isAnalyzing: false
    property bool hasValidImage: loadedImage.source !== ""
    property bool hasValidPatient: patientForm.patientId > 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 25

        RowLayout {
            Layout.fillWidth: parent
            Layout.fillHeight: parent

            // Left column with image
            ColumnLayout {
                id: leftColumn
                Layout.preferredWidth: analysisWorkspaceRoot.width * 0.55
                Layout.fillHeight: true
                spacing: 20

                Rectangle {
                    id: imageDisplayArea
                    Layout.fillWidth: true
                    // Layout.preferredHeight: leftColumn.height * 0.7
                    Layout.fillHeight: true
                    color: App.Constants.appBackground
                    border.color: App.Constants.divider
                    border.width: 1
                    radius: App.Constants.radiusMedium

                    Image {
                        id: loadedImage
                        anchors.fill: parent
                        anchors.margins: 5
                        source: ""
                        fillMode: Image.PreserveAspectFit
                        visible: source !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Загрузите изображение родинки для анализа")
                        color: App.Constants.textPlaceholder
                        visible: !loadedImage.source
                        font.pixelSize: 16
                    }

                    // Overlay for analysis in progress
                    Rectangle {
                        anchors.fill: parent
                        color: "#80000000"
                        visible: isAnalyzing
                        
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: isAnalyzing
                        }
                        
                        Text {
                            anchors.top: parent.top
                            anchors.topMargin: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Анализ изображения...")
                            color: "white"
                            font.pixelSize: 16
                        }
                    }
                }
            }

            // Right column with patient data
            ColumnLayout {
                id: rightColumn
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                

                Components.PatientDataForm {
                    id: patientForm
                    Layout.fillWidth: true
                    isEditable: false //true
                    
                    // Connect to backend signals
                    Component.onCompleted: {
                        backend.patientAdded.connect(function(patientId) {
                            patientForm.patientId = patientId
                            patientForm.isEditable = false
                        })
                        
                        backend.patientUpdated.connect(function(patientId) {
                            if (patientId === patientForm.patientId) {
                                // Refresh patient data
                                var details = backend.get_patient_details(patientId)
                                patientForm.updateFromData(details)
                            }
                        })
                    }
                }

                ColumnLayout {
                    id: patientSearchComp
                    Layout.fillWidth: true
                    spacing: 20
                    visible: false

                    // Search bar
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Поиск пациентов по ФИО или телефону...")
                        color: App.Constants.textSecondary
                        leftPadding: 10 // Make space for the icon
                        rightPadding: 10

                        background: Rectangle {
                            color: "white"//App.Constants.appBackground
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
                                var currentSearchTerm = searchField.text
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
                                            patientForm.updateFromData(modelData)
                                            backend.currentPatientId = modelData.id
                                            patientSearchComp.visible = false
                                            patientForm.visible = true
                                            console.log("Set patient id:", modelData.id)
                                            console.log(backend.currentPatientId)
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
                        }
                        }
                }


                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 10

                    Components.SmallActionButton {
                        text: qsTr("Новый пациент")
                        onClicked: {
                            // Clear form and prepare for new patient
                            patientForm.clear()
                            patientSearchComp.visible = false
                            patientForm.visible = true

                            patientForm.isEditable = true 
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                    }

                    Components.SmallActionButton {
                        text: qsTr("Выбрать пациента")
                        onClicked: {
                            // Open patient search dialog
                            // patientSearchDialog.open()
                            patientSearchComp.visible = true
                            patientForm.visible = false
                            //patientSearchDialog.open()
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        RowLayout {
            id: buttonsColumn
            Layout.fillWidth: parent
            Layout.preferredHeight: 50
            spacing: 20

            Components.LargeActionButton {
                id: loadImageButton
                text: qsTr("Загрузить изображение")
                Layout.preferredWidth: 250
                Layout.preferredHeight: 50
                enabled: !isAnalyzing
                onClicked: fileDialog.open()
            }

            Item { Layout.fillWidth: true }

            Components.AccentActionButton {
                id: analyzeDataButton
                text: qsTr("Анализировать")
                Layout.preferredWidth: 250
                Layout.preferredHeight: 50
                enabled: hasValidImage &&  !isAnalyzing  //hasValidPatient &&
                onClicked: {
                    isAnalyzing = true
                    var savedPath = backend.save_image(loadedImage.source.toString()) 
                    var patientId = backend.add_patient(patientForm.getFormData()) 
                    backend.currentPatientId = patientId
                    if (savedPath) {
                        var result = backend.analyze_current_image()
                        if (result) {
                            analysisTriggered(loadedImage.source, 
                                           savedPath.split('/').pop(), 
                                           patientId)
                        }
                    }
                    isAnalyzing = false
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Выберите изображение")
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp)"]
        onAccepted: {
            console.log(selectedFile)
            loadedImage.source = selectedFile
        }
    }

    Connections {
        target: backend
        
        function onAnalysisStarted() {
            isAnalyzing = true
        }
        
        function onAnalysisComplete(result) {
            isAnalyzing = false
            // Analysis results will be handled by MainScreen
        }
        
        function onErrorOccurred(error) {
            isAnalyzing = false
            // Show error dialog
            //errorDialog.text = error
            //errorDialog.open()
        }
    }

    Components.PatientSearchDialog {
        id: patientSearchDialog
        anchors.centerIn: parent
        onPatientSelected: function(patientData) {
            backend.currentPatientId = patientData.id
        }
    }

    // Dialog {
    //     id: errorDialog
    //     title: qsTr("Ошибка")
    //     standardButtons: Dialog.Ok
    //     property alias text: errorText.text
        
    //     Text {
    //         id: errorText
    //         wrapMode: Text.WordWrap
    //     }
    // }
}
