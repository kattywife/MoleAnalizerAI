import QtQuick
import QtQuick.Layouts
import CancerMoles 1.0 // Импорт констант

Rectangle { // Используем Rectangle как корневой элемент
    id: root
    // Задаем размеры (можно сделать адаптивными)
    implicitWidth: 250
    implicitHeight: 300 // Высота по умолчанию, можно настроить
    color: "transparent" // Фон самого компонента (за рамкой)
    border.color: Constants.borderPrimary // Внешняя рамка таблицы
    border.width: 2
    radius: 4 // Небольшое скругление углов (опционально)

    // Свойство для модели данных (массив объектов)
    // Пример объекта: { analysisDate: "01.01.2025", riskValue: "13%" }
    property list<variant> tableModel: []

    // Основной Layout: Заголовок над списком
    ColumnLayout {
        anchors.fill: parent // Заполняет родительский Rectangle
        spacing: 0 // Нет зазора между заголовком и первой строкой

        // --- Заголовок таблицы ---
        Rectangle { // Фон заголовка
            id: headerRect
            // Предполагаем, что фон заголовка - коричневый
            color: Constants.borderPrimary // Используем цвет рамки для фона заголовка
            // Если фон другой (бежевый), используйте: Constants.tableHeaderBackground
            Layout.fillWidth: true
            implicitHeight: headerRow.implicitHeight + 10 // Высота строки + отступы

            RowLayout { // Размещение текста заголовка
                id: headerRow
                anchors.fill: parent
                anchors.leftMargin: 5 // Отступы внутри заголовка
                anchors.rightMargin: 5

                // Текст "Дата"
                Text {
                    text: qsTr("Дата")
                    color: Constants.textOnPrimary // Белый текст на коричневом фоне
                    // Если фон заголовка другой, используйте Constants.tableHeaderText
                    font.bold: true
                    Layout.fillWidth: true // Распределить ширину
                    horizontalAlignment: Text.AlignHCenter
                }
                // Вертикальный разделитель в заголовке
                Rectangle {
                     width: 1; Layout.preferredHeight: parent.height
                     color: Constants.textOnPrimary // Белый разделитель (или цвет фона, если нужен только отступ)
                     opacity: 0.5 // Полупрозрачный
                }
                // Текст "Риск"
                Text {
                    text: qsTr("Риск")
                    color: Constants.textOnPrimary // Белый текст
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // --- Список строк данных ---
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true // Занять оставшуюся высоту
            clip: true // Обрезать содержимое, выходящее за границы
            model: root.tableModel // Используем модель из свойства компонента

            // Делегат для отображения каждой строки
            delegate: Rectangle { // Каждая строка - Rectangle с границами
                width: listView.width
                height: rowLayout.implicitHeight + 10 // Высота по тексту + отступы
                color: "transparent" // Фон строки (можно чередовать цвета)
                // Нижняя граница строки
                border.color: Constants.tableCellBorder
                border.width: 1 // Только нижняя граница (или все?) - сейчас все

                RowLayout { // Размещение ячеек в строке
                    id: rowLayout
                    anchors.fill: parent
                    anchors.leftMargin: 5 // Отступы внутри ячеек
                    anchors.rightMargin: 5

                    // Ячейка "Дата"
                    Text {
                        // Пытаемся получить данные из модели, или пустая строка
                        text: modelData ? (modelData.analysisDate || "") : ""
                        color: Constants.textPrimary // Коричневый текст
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight // Обрезать текст, если не влезает
                    }
                    // Вертикальный разделитель в строке
                    Rectangle {
                        width: 1; Layout.preferredHeight: parent.height
                        color: Constants.tableCellBorder
                    }
                    // Ячейка "Риск"
                    Text {
                        text: modelData ? (modelData.riskValue || "") : ""
                        color: Constants.textPrimary
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                } // Конец RowLayout строки
            } // Конец делегата (Rectangle строки)

             // Отображение для пустого списка (опционально)
             /* overlay: Rectangle { // Показывается поверх списка, если он пуст
                anchors.fill: parent
                color: "transparent" // Или Constants.appBackground
                visible: listView.count === 0 // Показать только если список пуст
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Нет данных")
                    color: Constants.textPlaceholder
                }
            } */

        } // Конец ListView
    } // Конец ColumnLayout
} // Конец Rectangle (root)
