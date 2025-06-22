// TopBar.qml
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

        // --- NEW: THEME SWITCHER ICON ---
        MouseArea {
            id: themeSwitcher
            width: 30
            height: 30
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 10
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                // Call the global function to toggle the theme
                App.Constants.toggleTheme()
            }

            Text {
                anchors.centerIn: parent
                // The icon character changes based on the theme state
                text: App.Constants.isDark ? "☀️" : "🌙"
                color: "white"
                font.pixelSize: 20

                ToolTip.visible: themeSwitcher.hovered
                ToolTip.text: App.Constants.isDark ? qsTr("Переключить на светлую тему") : qsTr("Переключить на темную тему")
            }
        }
        // --- END OF NEW CODE ---

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
                cursorShape: Qt.PointingHandCursor
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