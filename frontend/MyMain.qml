import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "./screens" as Screens

Window {
    id: root
    width: 1200 // Увеличим немного для лучшего соответствия пропорциям
    height: 800
    visible: true
    title: "QML Clicker"

    //ColumnLayout {
    //    anchors.centerIn: parent // Центрируем содержимое
    //    anchors.fill: parent
    //    spacing: 20 // Отступ между элементами
//
    //    Screens.MainScreen {
    //        id: mainScreen
    //        Layout.fillHeight: true
    //        Layout.fillWidth: true
    //        //anchors.fill: parent
    //    }
    //}

    Item {
        anchors.centerIn: parent // Центрируем содержимое
        anchors.fill: parent
    
        Screens.MainScreen {
            id: mainScreen
            anchors.fill: parent
        }
    }
}