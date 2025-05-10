import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects // Для тени

// Импортируем наш синглтон с константами (убедитесь, что путь/имя модуля верное)
import CancerMoles 1.0

Button {
    id: control

    // --- Настраиваемые свойства (остаются для текста и, возможно, иконки) ---
    // text: qsTr("Текст") // Лучше задавать текст при использовании кнопки
    property bool active: false
    // --- Используем цвета и параметры из Constants.qml ---
    readonly property color normalColor: Constants.buttonSecondaryBackground
    readonly property color hoverColor: Constants.buttonSecondaryHover
    readonly property color pressedColor: Constants.buttonSecondaryPressed
    readonly property color pressedHoverColor: Constants.buttonSecondaryPressedHover
    readonly property color borderColor: Constants.buttonSecondaryBorder // Он же Constants.borderPrimary
    readonly property color textColor: Constants.buttonSecondaryText     // Он же Constants.textSecondary
    readonly property int borderWidth: 2                  // Толщина рамки (можно тоже вынести в Constants)
    readonly property real cornerRadius: height / 2       // Радиус скругления (делает капсулу)
    readonly property real shadowOffset: 2                // Смещение тени (можно вынести в Constants)
    readonly property real shadowRadius: 3.0              // Радиус размытия тени (можно вынести в Constants)
    readonly property color shadowColor: Constants.shadow // Цвет тени из констант

    // Минимальные и предпочтительные размеры (можно настроить)
    implicitWidth: Math.max(contentItem.implicitWidth + 40, 120)
    implicitHeight: Math.max(contentItem.implicitHeight + 15, 40)

    // Отключаем стандартный фон и рамку Button
    background: Item {}

    // Кастомный фон с рамкой и динамическим цветом из Constants
    Item {
        id: backgroundItem
        anchors.fill: parent

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            // Выбираем цвет фона в зависимости от состояния кнопки, используя значения из Constants
            color: {
                if(control.active) {
                    control.pressedHoverColor
                }
                else if (control.pressed && control.hovered) {
                    control.pressedHoverColor // Constants.buttonSecondaryPressedHover
                } else if (control.pressed) {
                    control.pressedColor      // Constants.buttonSecondaryPressed
                } else if (control.hovered) {
                    control.hoverColor        // Constants.buttonSecondaryHover
                } else {
                    control.normalColor       // Constants.buttonSecondaryBackground
                }
            }
            border.color: control.borderColor // Constants.buttonSecondaryBorder
            border.width: control.borderWidth
            radius: control.cornerRadius
        }

        // Тень для эффекта объема (применяется к фону)
        DropShadow {
            anchors.fill: backgroundRect
            source: backgroundRect
            horizontalOffset: control.shadowOffset
            verticalOffset: control.shadowOffset
            radius: control.shadowRadius
            samples: 17 // Качество тени
            color: control.shadowColor   // Constants.shadow
            spread: 0.1
            visible: active//control.enabled
        }
    }

    // Содержимое кнопки (текст)
    contentItem: Text {
        text: control.text // Текст берется из свойства кнопки
        font: control.font // Шрифт берется из свойства кнопки
        color: control.textColor // Используем цвет текста из Constants (Constants.buttonSecondaryText)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
