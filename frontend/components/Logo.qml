import QtQuick
import "../" as App

Item {
    id: root

    property url logoSource: Qt.resolvedUrl("../assets/images/logo.png")
    property bool showBackground: false
    property color backgroundColor: "white"
    property real backgroundRadius: App.Constants.radiusMedium
    property real logoPadding: 8

    implicitWidth: 64
    implicitHeight: 64

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: root.backgroundColor
        radius: root.backgroundRadius
        visible: root.showBackground
        border.color: App.Constants.divider
        border.width: root.showBackground ? 1 : 0
    }

    Image {
        id: logoImage
        anchors.fill: parent
        anchors.margins: root.showBackground ? root.logoPadding : 0
        source: root.logoSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true

        // Fallback if logo not found
        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("Error loading logo:", source)
                // Load fallback text
                logoText.visible = true
            }
        }
    }

    Text {
        id: logoText
        visible: false
        anchors.centerIn: parent
        text: "SS"
        color: App.Constants.accent
        font {
            pixelSize: Math.min(parent.width, parent.height) * 0.5
            bold: true
            family: App.Constants.fontFamily
        }
    }
}
