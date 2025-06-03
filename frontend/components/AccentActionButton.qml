import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../" as App

Button {
    id: control

    // Properties
    readonly property color normalColor: App.Constants.accent
    readonly property color hoverColor: Qt.darker(App.Constants.accent, 1.1)
    readonly property color pressedColor: Qt.darker(App.Constants.accent, 1.2)
    readonly property color textColor: "white"
    readonly property int borderWidth: 0
    readonly property real cornerRadius: App.Constants.radiusMedium
    readonly property real shadowOffset: 2
    readonly property real shadowRadius: 3.0
    readonly property color shadowColor: Qt.rgba(0, 0, 0, 0.2)

    implicitWidth: Math.max(contentItem.implicitWidth + 40, 120)
    implicitHeight: Math.max(contentItem.implicitHeight + 16, 40)

    background: Item {
        id: backgroundItem
        anchors.fill: parent

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: {
                if (control.pressed) return control.pressedColor
                if (control.hovered) return control.hoverColor
                return control.normalColor
            }
            border.width: control.borderWidth
            radius: control.cornerRadius

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        DropShadow {
            anchors.fill: backgroundRect
            source: backgroundRect
            horizontalOffset: control.pressed ? 1 : control.shadowOffset
            verticalOffset: control.pressed ? 1 : control.shadowOffset
            radius: control.pressed ? control.shadowRadius / 2 : control.shadowRadius
            samples: 17
            color: control.shadowColor
            spread: 0.1
            visible: control.enabled

            Behavior on horizontalOffset { NumberAnimation { duration: 150 } }
            Behavior on verticalOffset { NumberAnimation { duration: 150 } }
            Behavior on radius { NumberAnimation { duration: 150 } }
        }
    }

    contentItem: Text {
        text: control.text
        font {
            pixelSize: 14
            bold: true
            family: App.Constants.fontFamily
        }
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    scale: control.pressed ? 0.98 : 1.0
    
    Behavior on scale { 
        NumberAnimation { 
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
}
