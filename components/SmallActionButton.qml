import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects // Используем правильный импорт для тени

// Импортируем наш синглтон с константами
import CancerMoles 1.0

Button {
    id: control

    // --- Настраиваемые свойства ---
    // text: qsTr("Текст") // Задавать при использовании

    // --- Используем цвета и параметры из Constants.qml ---
    // Цвета и базовый стиль такие же, как у LargeActionButton
    readonly property color normalColor: Constants.buttonSecondaryBackground
    readonly property color hoverColor: Constants.buttonSecondaryHover
    readonly property color pressedColor: Constants.buttonSecondaryPressed
    readonly property color pressedHoverColor: Constants.buttonSecondaryPressedHover
    readonly property color borderColor: Constants.buttonSecondaryBorder
    readonly property color textColor: Constants.buttonSecondaryText
    readonly property int borderWidth: 2
    readonly property real cornerRadius: 8 // Прямоугольное скругление
    readonly property real shadowOffset: 2
    readonly property real shadowRadius: 3.0
    readonly property color shadowColor: Constants.shadow

    // --- Размеры (уменьшенные по сравнению с LargeActionButton) ---
    implicitWidth: Math.max(contentItem.implicitWidth + 30, 100) // Меньше отступы и мин. ширина
    implicitHeight: Math.max(contentItem.implicitHeight + 10, 35) // Меньше отступы и мин. высота

    // Отключаем стандартный фон и рамку Button
    background: Item {
        id: backgroundItem
        anchors.fill: parent

        // Прямоугольник фона
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            // Цвет фона зависит от состояния (логика как в CustomMenuButton/LargeActionButton)
            color: {
                if (control.pressed && control.hovered) {
                    control.pressedHoverColor
                } else if (control.pressed) {
                    control.pressedColor
                } else if (control.hovered) {
                    control.hoverColor
                } else {
                    control.normalColor
                }
            }
            border.color: control.borderColor
            border.width: control.borderWidth
            radius: control.cornerRadius // Используем прямоугольное скругление
        }

        // Тень для эффекта объема
        DropShadow {
            anchors.fill: backgroundRect
            source: backgroundRect
            horizontalOffset: control.shadowOffset
            verticalOffset: control.shadowOffset
            radius: control.shadowRadius
            samples: 17
            color: control.shadowColor
            spread: 0.1
            visible: control.enabled
        }
    }

    // Содержимое кнопки (текст)
    contentItem: Text {
        text: control.text
        font: control.font
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
