import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../" as App

Rectangle {
    id: root
    implicitWidth: 500
    implicitHeight: 300
    color: App.Constants.appBackground
    border.color: App.Constants.divider
    border.width: 1
    radius: App.Constants.radiusMedium

    property var analyses: []
    signal analysisSelected(var analysis)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerRect
            Layout.fillWidth: true
            implicitHeight: 40
            color: App.Constants.appBackground
            radius: root.radius
            
            Rectangle {
                anchors.fill: parent
                //anchors.bottomLeft: parent.bottomLeft
                //anchors.bottomRight: parent.bottomRight
                color: parent.color
                height: parent.height / 2
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: qsTr("Дата")
                    font.bold: true
                    color: App.Constants.textPrimary
                    Layout.preferredWidth: 120
                }

                Text {
                    text: qsTr("Вероятность")
                    font.bold: true
                    color: App.Constants.textPrimary
                    Layout.preferredWidth: 100
                }

                Text {
                    text: qsTr("Диагноз")
                    font.bold: true
                    color: App.Constants.textPrimary
                    Layout.fillWidth: true
                }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.analyses

            ScrollBar.vertical: ScrollBar {}

            delegate: ItemDelegate {
                width: listView.width
                height: 60

                background: Rectangle { 
                    color:  App.Constants.appBackground
                    border.width: 1
                    border.color: App.Constants.divider
                    // anchors.margins: 2
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 10

                    Text {
                        text: Qt.formatDateTime(new Date(modelData.analyzed_at), "dd.MM.yyyy HH:mm")
                        color: App.Constants.textPrimary
                        Layout.preferredWidth: 120
                    }

                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 24
                        radius: height / 2
                        color: {
                            const prob = modelData.melanoma_probability
                            if (prob > 0.7) return App.Constants.melanomaProbabilityHigh
                            if (prob > 0.4) return App.Constants.melanomaProbabilityMedium
                            return App.Constants.melanomaProbabilityLow
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (modelData.melanoma_probability * 100).toFixed(1) + "%"
                            color: App.Constants.textPrimary
                            font.bold: true
                        }
                    }

                    Text {
                        text: modelData.diagnosis_text || qsTr("Нет данных")
                        color: App.Constants.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    SmallActionButton {
                        text: qsTr("Просмотр")
                        Layout.preferredWidth: 100
                        onClicked: root.analysisSelected(modelData)
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: App.Constants.divider
                    anchors.bottom: parent.bottom
                }
            }

            Text {
                anchors.centerIn: parent
                text: qsTr("История анализов пуста")
                color: App.Constants.textPlaceholder
                visible: listView.count === 0
            }
        }
    }
}
