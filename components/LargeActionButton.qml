import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects // Для тени

// Импортируем наш синглтон с константами
import CancerMoles 1.0

Button {
    id: control

    // --- Настраиваемые свойства ---
    // text: qsTr("Текст") // Задавать при использовании

    // --- Используем цвета и параметры из Constants.qml ---
    // Эти цвета точно такие же, как для CustomMenuButton
    readonly property color normalColor: Constants.buttonSecondaryBackground        // Белый фон
    readonly property color hoverColor: Constants.buttonSecondaryHover         // Светло-серый при наведении
    readonly property color pressedColor: Constants.buttonSecondaryPressed       // Светло-розовый при нажатии
    readonly property color pressedHoverColor: Constants.buttonSecondaryPressedHover // Лососевый (нажатие + наведение)
    readonly property color borderColor: Constants.buttonSecondaryBorder       // Коричневая рамка
    readonly property color textColor: Constants.buttonSecondaryText         // Коричневый текст

    readonly property int borderWidth: 2                  // Толщина рамки
    readonly property real cornerRadius: 8                // Небольшое скругление углов (как у PrimaryButton)
    readonly property real shadowOffset: 2
    readonly property real shadowRadius: 3.0
    readonly property color shadowColor: Constants.shadow

    // Размеры, как у "большой" кнопки PrimaryButton
    implicitWidth: Math.max(contentItem.implicitWidth + 60, 180)
    implicitHeight: Math.max(contentItem.implicitHeight + 20, 50)

    // Отключаем стандартный фон и рамку Button
    background: Item {
        id: backgroundItem
        anchors.fill: parent

        // Прямоугольник фона
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            // Цвет фона зависит от состояния (логика как в CustomMenuButton)
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

        // Тень для эффекта объема (применяется к фону)
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
        text: control.text // Текст берется из свойства кнопки
        font: control.font
        color: control.textColor // Коричневый цвет текста из Constants
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
