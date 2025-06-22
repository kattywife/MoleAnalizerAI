import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "./screens" as Screens

Window {
    id: root
    width: 1200 // Увеличим немного для лучшего соответствия пропорциям
    height: 800
    visible: true
    title: "SkinSight"

    Item {
        anchors.centerIn: parent // Центрируем содержимое
        anchors.fill: parent
    
        Screens.MainScreen {
            id: mainScreen
            anchors.fill: parent
        }
    }
}