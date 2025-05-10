import QtQuick
import CancerMoles 1.0 // Импорт констант

Item { // Используем Item как легкий контейнер
    id: root

    // --- Свойства компонента ---
    property url logoSource: "file:///C:/Users/user/Documents/QtDesigner/CancerMoles/CancerMoles/assets/images/логотип.svg"
        // "C:/Users/user/Documents\QtDesigner\CancerMoles\CancerMoles\assets\images\логотип.svg"
                                                           // Используйте "qrc:" если ресурсы встроены, или относительный путь.
    property bool showBackground: false // Показывать ли белый фон (по умолчанию - нет)
    property color backgroundColor: Constants.buttonSecondaryBackground // Белый цвет фона из констант
    property real backgroundRadius: 12 // Скругление фона
    property real logoPadding: 8      // Отступ лого от краев фона, если фон показан

    // Задайте желаемые размеры компонента по умолчанию
    implicitWidth: 64
    implicitHeight: 64

    // Прямоугольник для фона (виден, только если showBackground = true)
    Rectangle {
        id: backgroundRect
        anchors.fill: parent // Заполняет весь Item
        color: root.backgroundColor
        radius: root.backgroundRadius
        visible: root.showBackground // Ключевое свойство для включения/выключения фона
        // Опционально: добавить рамку, если нужно
        // border.color: Constants.divider
        // border.width: 1
    }

    // Изображение логотипа
    Image {
        id: logoImage
        anchors.fill: parent // Заполняет весь Item
        // Применяем отступы только если фон видим
        anchors.margins: root.showBackground ? root.logoPadding : 0
        source: root.logoSource // Источник изображения из свойства
        fillMode: Image.PreserveAspectFit // Сохранять пропорции, вписывая в область
        smooth: true // Сглаживание для лучшего вида
        antialiasing: true
    }
}
