import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../" as App

Rectangle {
    id: root
    implicitWidth: 300
    implicitHeight: contentLayout.implicitHeight + internalPadding * 2
    color: "transparent"

    readonly property int internalPadding: 10
    border.color: App.Constants.divider
    border.width: 1
    radius: App.Constants.radiusSmall

    // Data properties
    property int patientId: 0
    property bool isEditable: false
    property alias titleText: titleLabel.text

    // Internal data model
    QtObject {
        id: internal
        property string fullName: ""
        property string gender: ""
        property string birthDate: ""
        property string phone: ""
        property string address: ""
        property string medicalHistory: ""
    }

    function clear() {
        internal.fullName = ""
        internal.gender = ""
        internal.birthDate = ""
        internal.phone = ""
        internal.address = ""
        internal.medicalHistory = ""
        patientId = 0
        isEditable = true
    }

    function updateFromData(data) {
        if (!data) return
        internal.fullName = data.full_name || ""
        internal.gender = data.gender || ""
        internal.birthDate = data.birth_date || ""
        internal.phone = data.phone || ""
        internal.address = data.address || ""
        internal.medicalHistory = data.medical_history || ""
        patientId = data.id || 0
    }

    function getFormData() {
        return {
            "full_name": internal.fullName,
            "gender": internal.gender,
            "birth_date": internal.birthDate,
            "phone": internal.phone,
            "address": internal.address,
            "medical_history": internal.medicalHistory
        }
    }

    function savePatient() {
        if (!isFormValid()) return false

        const data = getFormData()
        if (patientId > 0) {
            // Update existing patient
            backend.update_patient(patientId, data)
        } else {
            // Add new patient
            patientId = backend.add_patient(data)
        }
        isEditable = false
        return patientId > 0
    }

    function isFormValid() {
        return internal.fullName !== "" && 
               internal.gender !== "" && 
               internal.birthDate !== ""
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: root.internalPadding
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            
            Text {
                id: titleLabel
                text: qsTr("Данные пациента")
                color: App.Constants.textPrimary
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            SmallActionButton {
                text: isEditable ? qsTr("Сохранить") : qsTr("Изменить")
                visible: patientId > 0
                onClicked: {
                    if (isEditable) {
                        if (savePatient()) {
                            isEditable = false
                        }
                    } else {
                        isEditable = true
                    }
                }
            }
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 10
            rowSpacing: 8

            // Full Name
            Text { 
                text: qsTr("ФИО:") 
                color: App.Constants.textPrimary 
            }
            TextField {
                id: nameField
                Layout.fillWidth: true
                text: internal.fullName
                enabled: isEditable
                onTextChanged: if (enabled) internal.fullName = text
                placeholderText: qsTr("Введите ФИО пациента")
                color: App.Constants.textPrimary

                background: Rectangle {
                    color: "transparent" 

                    Rectangle { 
                        width: parent.width  
                        height: 2            
                        color:  App.Constants.borderPrimary 
                        anchors.bottom: parent.bottom 
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                }
            }

            // Gender
            Text { 
                text: qsTr("Пол:") 
                color: App.Constants.textPrimary 
            }
            ComboBox {
                id: genderCombo
                Layout.fillWidth: true
                model: [qsTr("Мужской"), qsTr("Женский")]
                enabled: isEditable
                currentIndex: internal.gender === "male" ? 0 : (internal.gender === "female" ? 1 : -1)
                onCurrentIndexChanged: if (enabled && currentIndex !== -1) {
                    internal.gender = currentIndex === 0 ? "male" : "female"
                }

                background: Rectangle {
                    color: App.Constants.appBackground
                    border.color: App.Constants.divider
                    border.width: 1
                    radius: 4
                    implicitHeight: 30 // Set a default height
                }
                contentItem: Text {
                    text: genderCombo.displayText // Displays the current item's text
                    font: genderCombo.font // Use ComboBox's font property
                    color: App.Constants.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    leftPadding: 10 // Padding for the text from the left edge
                    rightPadding: genderCombo.indicator.width + 5 // Space for indicator
                }
                popup: Popup {
                y: genderCombo.height -1 // Position below the ComboBox
                width: genderCombo.width // Match ComboBox width
                implicitHeight: contentItem.implicitHeight // Size based on content
                padding: 1 // Small padding around the ListView
                topMargin: 1 // Small margin to separate from combobox edge
                bottomMargin: 1

                // Background of the popup itself
                background: Rectangle {
                    color: App.Constants.appBackground
                    border.color: App.Constants.divider
                    border.width: 1
                    radius: 4
                }

                // Content of the popup (typically a ListView)
                contentItem: ListView {
                    clip: true // Important for rounded corners on the popup
                    implicitHeight: contentHeight // Adjust height based on items
                    model: genderCombo.model // Use the ComboBox's model

                    // --- 5. Customize each item in the dropdown list ---
                    delegate: ItemDelegate {
                        width: ListView.view.width // Fill width of ListView
                        text: modelData.textValue !== undefined ? modelData.textValue : modelData // Access model data
                        highlighted: ListView.isCurrentItem // Highlight current item

                        background: Rectangle {
                            color: parent.hovered ? App.Constants.buttonSecondaryHover : "transparent" // Hover color
                            radius: 3 // Slight rounding for items
                        }

                        contentItem: Text {
                                text: parent.text 
                                color: App.Constants.textPrimary
                                font: genderCombo.font
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        

                        onClicked: {
                            genderCombo.currentIndex = index
                            genderCombo.popup.close()
                        }
                    }
                }
                }

            }

            // Birth Date
            Text { 
                text: qsTr("Дата рождения:") 
                color: App.Constants.textPrimary 
            }
            TextField {
                id: birthDateField
                Layout.fillWidth: true
                text: internal.birthDate
                enabled: isEditable
                onTextChanged: if (enabled) internal.birthDate = text
                placeholderText: qsTr("ГГГГ-ММ-ДД")
                inputMask: "9999-99-99"
                color: App.Constants.textPrimary


                background: Rectangle {
                    color: "transparent" 

                    Rectangle { 
                        width: parent.width  
                        height: 2            
                        color:  App.Constants.borderPrimary 
                        anchors.bottom: parent.bottom 
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                }
            }

            // Phone
            Text { 
                text: qsTr("Телефон:") 
                color: App.Constants.textPrimary 
            }
            TextField {
                id: phoneField
                Layout.fillWidth: true
                text: internal.phone
                enabled: isEditable
                onTextChanged: if (enabled) internal.phone = text
                placeholderText: qsTr("+7 (XXX) XXX-XX-XX")
                color: App.Constants.textPrimary


                background: Rectangle {
                    color: "transparent" 

                    Rectangle { 
                        width: parent.width  
                        height: 2            
                        color:  App.Constants.borderPrimary 
                        anchors.bottom: parent.bottom 
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                }
            }

            // Address
            Text { 
                text: qsTr("Адрес:") 
                color: App.Constants.textPrimary 
            }
            TextField {
                id: addressField
                Layout.fillWidth: true
                text: internal.address
                enabled: isEditable
                onTextChanged: if (enabled) internal.address = text
                placeholderText: qsTr("Введите адрес")
                color: App.Constants.textPrimary


                background: Rectangle {
                    color: "transparent" 

                    Rectangle { 
                        width: parent.width  
                        height: 2            
                        color:  App.Constants.borderPrimary 
                        anchors.bottom: parent.bottom 
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                }
            }

            // Medical History
            Text { 
                text: qsTr("История болезней:") 
                color: App.Constants.textPrimary 
                Layout.alignment: Qt.AlignTop
            }
            TextArea {
                id: historyArea
                Layout.fillWidth: true
                text: internal.medicalHistory
                enabled: isEditable
                color: App.Constants.textPrimary
                onTextChanged: if (enabled) internal.medicalHistory = text
                placeholderText: qsTr("Введите историю болезней")
                wrapMode: TextArea.Wrap
                Layout.preferredHeight: 80
            }
        }
    }
}
