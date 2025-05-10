// CancerMoles/components/LeftMenuPanel.qml
import QtQuick
import QtQuick.Layouts
import CancerMoles.components 1.0

Rectangle {
    id: leftMenuRoot
    color: Constants.buttonSecondaryBackground

    // Свойство для хранения текста активной кнопки. Оно будет меняться ВНУТРИ этого компонента.
    property string activeMenuButtonText: qsTr("Главное меню")

    // Сигнал, который сообщает наружу, какая кнопка была нажата.
    // MainScreen будет слушать этот сигнал для смены контента.
    signal menuItemClicked(string buttonText)

    implicitWidth: columnLayout.implicitWidth + 2 * 20
    implicitHeight: columnLayout.implicitHeight + 2 * 20

    // Функция для обработки клика по кнопке меню
    function handleMenuClick(button) {
        if (activeMenuButtonText !== button.text) { // Меняем, только если нажата ДРУГАЯ кнопка
            activeMenuButtonText = button.text; // Обновляем внутреннее состояние активной кнопки
        }
        // Всегда эмитируем сигнал, чтобы MainScreen мог отреагировать,
        // даже если пользователь кликнул по уже активной кнопке (например, для обновления контента)
        menuItemClicked(button.text);
        console.log("LeftMenuPanel: active button is now", activeMenuButtonText)
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        CustomMenuButton {
            id: btnMainMenu
            text: qsTr("Главное меню")
            Layout.fillWidth: true
            // Состояние active теперь зависит от внутреннего свойства leftMenuRoot.activeMenuButtonText
            active: leftMenuRoot.activeMenuButtonText === text
            onClicked: leftMenuRoot.handleMenuClick(this) // Передаем саму кнопку в обработчик
        }
        CustomMenuButton {
            id: btnPatients
            text: qsTr("Пациенты")
            Layout.fillWidth: true
            active: leftMenuRoot.activeMenuButtonText === text
            onClicked: leftMenuRoot.handleMenuClick(this)
        }
        CustomMenuButton {
            id: btnAnalyzes
            text: qsTr("Анализы")
            Layout.fillWidth: true
            active: leftMenuRoot.activeMenuButtonText === text
            onClicked: leftMenuRoot.handleMenuClick(this)
        }
        CustomMenuButton {
            id: btnSettings
            text: qsTr("Настройки")
            Layout.fillWidth: true
            active: leftMenuRoot.activeMenuButtonText === text
            onClicked: leftMenuRoot.handleMenuClick(this)
        }

        Item { Layout.fillHeight: true }

        CustomMenuButton {
            id: btnExit
            text: qsTr("Выход")
            Layout.fillWidth: true
            // Кнопка Выход не становится "активной" в смысле навигации по экранам
            active: false // Или можно оставить active: leftMenuRoot.activeMenuButtonText === text, если это нужно
            onClicked: {
                // Для выхода можно не менять activeMenuButtonText
                // Просто эмитируем сигнал, чтобы MainScreen обработал выход
                leftMenuRoot.menuItemClicked(text);
            }
        }
    }
}
