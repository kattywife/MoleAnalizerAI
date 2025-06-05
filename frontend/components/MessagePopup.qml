// WarningPopup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window // For Screen

import "../" as App
import "../components" as Components

Popup {
    id: rootPopup
    modal: true
    width: 450
    height: 175
    // height will be determined by content, or you can set a fixed/min/max height
    anchors.centerIn: Overlay.overlay // Centers on the entire screen
    padding: 0 // We handle padding with our custom background/layout

    // --- Properties ---
    property string popupType: "warning" // "info", "warning", "error"
    property alias titleText: titleLabel.text
    property alias messageText: messageLabel.text
    property alias closeButtonText: closeButton.text

    // --- Signals ---
    signal closedByUser()

    // --- Internal Logic for Icon and Color ---
    readonly property var typeConfig: {
        "info": {
            "icon": "qrc:/icons/info_icon.svg", // Replace with your actual icon path
            "color": Constants.infoColor,
            "defaultTitle": qsTr("Информация")
        },
        "warning": {
            "icon": "file:///../assets/images/warning_icon.png", //"qrc:/icons/warning_icon.svg", // Replace with your actual icon path
            "color": Constants.warningColor,
            "defaultTitle": qsTr("Предупреждение")
        },
        "error": {
            "icon": "qrc:/icons/error_icon.svg", // Replace with your actual icon path
            "color": Constants.errorColor,
            "defaultTitle": qsTr("Ошибка")
        }
    }

    property url currentIcon: rootPopup.typeConfig[popupType] ? rootPopup.typeConfig[popupType].icon : rootPopup.typeConfig["info"].icon
    property color currentColor: Constants.textPrimary //rootPopup.typeConfig[popupType] ? rootPopup.typeConfig[popupType].color : rootPopup.typeConfig["info"].color
    property string currentDefaultTitle: rootPopup.typeConfig[popupType] ? rootPopup.typeConfig[popupType].defaultTitle : rootPopup.typeConfig["info"].defaultTitle

    // --- Visuals ---
    background: Rectangle {
        color: "white"
        border.color: Constants.divider
        border.width: 1
        radius: 6 // Slightly more rounded
    }

    // Using ColumnLayout for overall structure
    ColumnLayout {
        anchors.fill: parent
        spacing: 0 // We'll use margins on items for spacing

        // --- Custom Header ---
        Rectangle {
            id: dialogHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 50 // Increased height for icon
            color: "white" // Or a very light shade of currentColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                Image {
                    id: typeIcon
                    source: rootPopup.currentIcon
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                    fillMode: Image.PreserveAspectFit
                    // Optional: If your SVGs are monochrome and you want to color them:
                    // sourceSize: Qt.size(24, 24) // Important for SVG rendering if using ColorOverlay
                    // ColorOverlay {
                    //     anchors.fill: parent
                    //     source: parent
                    //     color: rootPopup.currentColor
                    // }
                }

                Text {
                    id: titleLabel
                    text: rootPopup.currentDefaultTitle // Default title, can be overridden
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    font.pixelSize: 17
                    font.bold: true
                    color: Constants.textPrimary
                    elide: Text.ElideRight
                }
            }

            Rectangle { // Header bottom border
                Layout.fillWidth: true // Not needed if parent is Rectangle
                width: parent.width
                height: 1
                color: Constants.divider
                anchors.bottom: parent.bottom
            }
        }

        // --- Content Item ---
        Item { // Container for content with padding
            Layout.fillWidth: true
            Layout.fillHeight: true // Takes up remaining space
            Layout.topMargin: 15
            Layout.bottomMargin: 15
            Layout.leftMargin: 20
            Layout.rightMargin: 20

            Text {
                id: messageLabel
                anchors.fill: parent
                text: qsTr("This is a default message. Please provide specific content.")
                color: Constants.textPrimary
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                // verticalAlignment: Text.AlignTop // if you want it at the top
            }
        }


        // --- Footer ---
        Rectangle {
            id: dialogFooter
            Layout.fillWidth: true
            Layout.preferredHeight: 55 // Slightly more space
            color: "white"

            Rectangle { // Footer top border
                width: parent.width
                height: 1
                color: Constants.divider
                anchors.top: parent.top
            }

            RowLayout {
                anchors.fill: parent
                anchors.rightMargin: 15 // Align button to the right
                anchors.leftMargin: 15  // For consistent padding
                Layout.alignment: Qt.AlignVCenter // Center items vertically in the footer

                Item { Layout.fillWidth: true } // Spacer to push button to the right

                //Button { // Using standard QtQuick.Controls Button
                Components.SmallActionButton{
                    id: closeButton
                    text: qsTr("Close")

                    onClicked: {
                        rootPopup.close()
                        rootPopup.closedByUser()
                    }
                }
            }
        }
    }

    // --- Convenience Methods ---
    function show(type, title, message) {
        rootPopup.popupType = type || "info";
        rootPopup.titleText = title || rootPopup.currentDefaultTitle; // Use default if title not provided
        rootPopup.messageText = message || "";
        rootPopup.open();
    }
}