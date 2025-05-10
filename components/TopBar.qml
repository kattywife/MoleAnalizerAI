// CancerMoles/TopBar.qml
import QtQuick
import QtQuick.Layouts
import CancerMoles 1.0 // Для Constants и Logo

Rectangle {
    id: topBarRoot
    width: parent.width // Будет задаваться извне
    implicitHeight: 60   // Фиксированная высота как на макете
    color: Constants.headerBackground

    property alias userName: welcomeText.text // Для динамической установки имени

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20  // Отступы по бокам
        anchors.rightMargin: 20
        spacing: 15

        Logo {
            id: headerLogo
            implicitWidth: 40
            implicitHeight: 40
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: qsTr("SkinSight")
            color: Constants.headerText
            font.pixelSize: 22 // Чуть меньше для лучшего вида
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true } // Распорка

        Text {
            id: welcomeText
            text: qsTr("Добро пожаловать, Иван Иванов!") // Значение по умолчанию
            color: Constants.headerText
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle { // Аватарка
            width: 36
            height: 36
            radius: width / 2
            color: Constants.headerText // Белый круг
            border.color: Qt.darker(Constants.headerBackground, 1.2)
            border.width: 1
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
