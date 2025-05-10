import QtQuick
import CancerMoles 1.0 // Импорт констант

Rectangle {
    id: root

    // --- Свойства компонента ---
    property real value: 0 // Входное значение риска (0-100)

    // --- Параметры внешнего вида ---
    readonly property color textColor: Constants.textPrimary // Белый текст
    readonly property int borderWidth: 2
    readonly property real cornerRadius: 8 // Скругление как у других кнопок/элементов

    // Задаем размеры по умолчанию (можете настроить)
    implicitWidth: 80
    implicitHeight: 50

    // Определяем цвет фона и рамки на основе значения value
    color: {
        if (root.value <= 10) {
            Constants.resultLowRisk // Зеленый
        } else if (root.value <= 40) {
            Constants.resultMediumRisk // Оранжевый/Желтый
        } else {
            Constants.resultHighRisk // Красный
        }
    }
    border.color: Constants.borderPrimary   // Рамка того же цвета, что и фон
    border.width: root.borderWidth
    radius: root.cornerRadius

    // Текст для отображения значения
    Text {
        id: valueText
        anchors.centerIn: parent // Центрируем текст внутри прямоугольника
        color: root.textColor    // Белый цвет текста
        font.bold: true          // Жирный шрифт
        font.pixelSize: Math.min(root.width, root.height) * 0.4 // Размер шрифта относительно размера индикатора

        // Форматируем текст: округляем значение и добавляем "%"
        text: Math.round(root.value) + "%"
    }
}
