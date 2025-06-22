import QtQuick
import "../" as App

Item {
    id: root
    property real value: 0
    
    implicitWidth: 200
    implicitHeight: 120

    Rectangle {
        id: indicatorBackground
        anchors.fill: parent
        color: App.Constants.appBackground
        border.color: App.Constants.divider
        border.width: 1
        radius: App.Constants.radiusMedium

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Item {
                width: parent.width
                height: 40

                Rectangle {
                    id: progressBar
                    width: parent.width
                    height: 16
                    radius: height / 2
                    color: App.Constants.appBackground

                    Rectangle {
                        width: parent.width * (root.value / 100)
                        height: parent.height
                        radius: parent.radius
                        color: getRiskColor(root.value)
                        
                        Behavior on width {
                            NumberAnimation { duration: 500; easing.type: Easing.OutQuad }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: progressBar.height + 8
                    text: Math.round(root.value) + "%"
                    color: getRiskColor(root.value)
                    font {
                        bold: true
                        pixelSize: 24
                    }
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: getRiskText(root.value)
                color: App.Constants.textSecondary
                font.pixelSize: 14
                wrapMode: Text.WordWrap
            }
        }
    }

    function getRiskColor(value) {
        if (value > 70) {
            return App.Constants.melanomaProbabilityHigh
        } else if (value > 40) {
            return App.Constants.melanomaProbabilityMedium
        }
        return App.Constants.melanomaProbabilityLow
    }

    function getRiskText(value) {
        if (value > 70) {
            return qsTr("Высокий риск")
        } else if (value > 40) {
            return qsTr("Средний риск")
        }
        return qsTr("Низкий риск")
    }
}
