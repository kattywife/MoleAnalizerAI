import QtQuick
import "../" as App

Rectangle {
    id: workspaceRoot
    // Ширина и высота будут задаваться извне (через Layout)
    // Layout.fillWidth: true
    // Layout.fillHeight: true
    color: App.Constants.buttonSecondaryBackground // Белый фон

    // Используем default property alias для легкого добавления контента
    default property alias content: contentItem.data

    // Элемент, куда будет добавляться контент
    Item {
        id: contentItem
        anchors.fill: parent
        // Можно добавить внутренние отступы, если они всегда нужны для рабочей области
        // anchors.margins: 20
    }
}
