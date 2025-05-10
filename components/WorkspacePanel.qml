// CancerMoles/WorkspacePanel.qml
import QtQuick
import CancerMoles 1.0 // Для Constants

Rectangle {
    id: workspaceRoot
    // Ширина и высота будут задаваться извне (через Layout)
    // Layout.fillWidth: true
    // Layout.fillHeight: true
    color: Constants.buttonSecondaryBackground // Белый фон

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
