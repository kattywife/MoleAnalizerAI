import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../" as App

Button {
    id: control

    // --- Настраиваемые свойства ---
    // text: qsTr("Текст") // Задавать при использовании

    // --- Используем цвета и параметры из Constants.qml ---
    // Подбираем цвета из Constants, соответствующие виду кнопки:
    // Normal state: Розовая рамка (#E7C2C2), белый фон (#FFFFFF)
    // Hover state: Лососевый фон (#E78585)
    readonly property color normalOuterColor: App.Constants.buttonSecondaryPressed       // Светло-розовый фон/рамка в обычном состоянии
    readonly property color normalInnerColor: App.Constants.buttonSecondaryBackground    // Белый внутренний фон в обычном состоянии
    readonly property color hoverBackgroundColor: App.Constants.buttonSecondaryPressedHover // Лососевый фон при наведении
    readonly property color borderColor: App.Constants.borderPrimary                     // Коричневая рамка
    readonly property color textColor: App.Constants.textPrimary                         // Коричневый текст

    readonly property int borderWidth: 2                  // Толщина внешней рамки
    readonly property int internalPadding: 4              // Отступ между внешней рамкой и белым фоном (для Normal)
    readonly property real cornerRadius: 8                // Небольшое скругление углов
    readonly property real shadowOffset: 2
    readonly property real shadowRadius: 3.0
    readonly property color shadowColor: App.Constants.shadow

    // Задаем большие размеры по умолчанию для "большой" кнопки
    implicitWidth: Math.max(contentItem.implicitWidth + 60, 180) // Шире
    implicitHeight: Math.max(contentItem.implicitHeight + 20, 50)  // Выше

    // Отключаем стандартный фон и рамку Button
    background: Item {
        id: backgroundItem
        anchors.fill: parent

        // Основной прямоугольник фона/рамки
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            // Цвет фона зависит от наведения
            color: control.hovered ? control.hoverBackgroundColor : control.normalOuterColor
            border.color: control.borderColor
            border.width: control.borderWidth
            radius: control.cornerRadius

            // Внутренний белый прямоугольник (виден только в обычном состоянии)
            Rectangle {
                anchors.fill: parent
                // Отступы = толщина рамки + доп. отступ
                anchors.margins: control.borderWidth + control.internalPadding
                // Скругление чуть меньше внешнего
                radius: Math.max(0, control.cornerRadius - (control.borderWidth + control.internalPadding))
                color: control.normalInnerColor
                visible: !control.hovered // Показываем только когда нет наведения
            }
        }

        // Тень для эффекта объема (применяется к внешнему прямоугольнику)
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
        font: control.font // Можно настроить шрифт отдельно, если нужно
        color: control.textColor // Коричневый цвет текста из Constants
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
