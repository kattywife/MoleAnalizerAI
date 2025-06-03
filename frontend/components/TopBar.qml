import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../" as App

Rectangle {
    id: topBarRoot
    implicitHeight: 60
    color: App.Constants.accent

    property string userName: "Доктор"
    property string clinicName: "SkinSight"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 15

        Logo {
            id: headerLogo
            implicitWidth: 40
            implicitHeight: 40
            showBackground: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: clinicName
            color: "white"
            font {
                pixelSize: 22
                bold: true
                family: App.Constants.fontFamily
            }
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        Text {
            id: welcomeText
            text: qsTr("Добро пожаловать, %1!").arg(userName)
            color: "white"
            font {
                pixelSize: 14
                family: App.Constants.fontFamily
            }
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            width: 36
            height: 36
            radius: width / 2
            color: "white"
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: userName.charAt(0).toUpperCase()
                color: App.Constants.accent
                font {
                    pixelSize: 18
                    bold: true
                    family: App.Constants.fontFamily
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: userMenu.open()
            }
        }
    }

    Menu {
        id: userMenu
        y: topBarRoot.height

        MenuItem {
            text: qsTr("Настройки профиля")
            onTriggered: {
                // TODO: Open profile settings
            }
        }

        MenuItem {
            text: qsTr("Выход")
            onTriggered: Qt.quit()
        }
    }
}
