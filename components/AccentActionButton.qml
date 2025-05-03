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
    readonly property color normalColor: Constants.buttonAccentBackground     // Бордовый фон
    readonly property color hoverColor: Constants.buttonAccentHoverBackground // Ярко-красный фон при наведении
    // readonly property color pressedColor: Constants.buttonAccentHoverBackground // Можно сделать таким же, как hover, если нужно нажатие
    readonly property color borderColor: Constants.buttonAccentBackground     // Рамка того же цвета, что и фон
    readonly property color textColor: Constants.buttonAccentText           // Белый текст

    readonly property int borderWidth: 1                  // Тонкая рамка (или 0, если не нужна)
    readonly property real cornerRadius: 8                // Прямоугольное скругление
    readonly property real shadowOffset: 2
    readonly property real shadowRadius: 3.0
    readonly property color shadowColor: Constants.shadow

    // --- Размеры (как у "малой" кнопки) ---
    implicitWidth: Math.max(contentItem.implicitWidth + 30, 100)
    implicitHeight: Math.max(contentItem.implicitHeight + 10, 35)

    // Отключаем стандартный фон и рамку Button
    background: Item {
        id: backgroundItem
        anchors.fill: parent

        // Прямоугольник фона
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            // Цвет фона зависит от наведения
            color: control.hovered ? control.hoverColor : control.normalColor
            border.color: control.borderColor // Рамка того же цвета
            border.width: control.borderWidth
            radius: control.cornerRadius
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
        color: control.textColor // Белый цвет текста
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Опционально: небольшое изменение при нажатии для обратной связи
    /*
    scale: control.pressed ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: 50 } }
    */
}
