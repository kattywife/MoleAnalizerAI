import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import screens
import components

Window {
    id: root
    width: 300
    height: 200
    visible: true
    title: "QML Clicker"

    // Свойство для хранения счета (будет связано с Python)
    // Мы могли бы полностью управлять им из QML, но для демонстрации
    // связи с Python, мы будем использовать бэкенд.
    // property int score: 0 // <- Вариант только на QML

    ColumnLayout {
        anchors.centerIn: parent // Центрируем содержимое
        spacing: 20 // Отступ между элементами

        Text {
            id: scoreLabel
            // Текст обновляется через свойство score из Python-бэкенда
            text: "Счет: " + backend.score
            font.pointSize: 18
            Layout.alignment: Qt.AlignHCenter // Горизонтальное выравнивание
        }

        // Button {
        //     id: clickButton
        //     text: "Кликни меня!"
        //     font.pointSize: 14
        //     Layout.alignment: Qt.AlignHCenter // Горизонтальное выравнивание

        //     // При нажатии на кнопку вызываем метод incrementScore из Python-бэкенда
        //     onClicked: backend.incrementScore()
        // }


        // Item {
        //     id: frame_11
        //     width: 689
        //     height: 219



        //     // Background rectangle if frame has fill or stroke

        //     Rectangle {
        //         anchors.fill: parent
        //         color: "#e7c2c2"
        //         border.width: 8
        //         border.color: "#863a1a"
        //         radius: 20
        //         opacity: 1
        //         visible: true

        //     }


        //     Item {
        //         id: frame_12
        //         width: 600
        //         height: 145



        //         // Background rectangle if frame has fill or stroke

        //         Rectangle {
        //             anchors.fill: parent
        //             color: "#ffffff"
        //             border.width: 8
        //             border.color: "#9d0202"
        //             radius: 20
        //             opacity: 1
        //             visible: true

        //         }


        //     Text {
        //         text: "Текст"
        //         font.family: "Roboto"
        //         font.pixelSize: 64
        //         color: "#863a1a"
        //         font.weight: 400
        //         opacity: 1
        //         visible: true
        //     }

        //     }

        // }
        // StyledButton.qml

        Control { // Use Control as the base
            id: control

            // --- Re-introduce Button-like properties ---
            property string text: "Текст"
            signal clicked() // Need to explicitly declare the signal

            // --- Sizing ---
            implicitWidth: 200
            implicitHeight: 60

            // --- Define the Content ---
            contentItem: Text {
                text: control.text
                font.bold: true
                font.pixelSize: control.height * 0.4
                color: "#A0522D" // Dark brown text color

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // --- Define the Background ---
            background: Rectangle {
                id: outerBackground
                // Make background itself transparent, we only use it for border/structure
                color: "transparent"
                radius: 8
                border.color: "#A0522D" // Dark brown border
                border.width: 2

                Rectangle {
                    id: innerBackground
                    anchors.fill: parent
                    anchors.margins: outerBackground.border.width
                    radius: outerBackground.radius - outerBackground.border.width // Adjust inner radius
                    color: "#F5E1E1" // Light pinkish/beige color

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        radius: parent.radius - anchors.margins // Adjust radius further
                        color: "white"
                    }
                }
            }

            // --- Interaction ---
            // Optional: Basic visual feedback for pressed state
            opacity: control.pressed ? 0.85 : 1.0

            // Handle mouse clicks to emit the clicked signal
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: control.clicked() // Emit the signal

                // Optional: Update pressed state for visual feedback
                // Note: Control doesn't have 'pressed' inherently like Button
                // We need to manage it via MouseArea if using Control directly
                onPressedChanged: {
                    if (pressed) {
                        control.pressed = true; // Use the Control's internal pressed property
                    } else {
                        control.pressed = false;
                    }
                }

                // Optional: Hover feedback
                hoverEnabled: true
                onHoveredChanged: {
                     outerBackground.border.color = hovered ? "#8B4513" : "#A0522D"; // Slightly darker on hover
                }
            }

            // Manage the 'pressed' state (Control has this property)
            // This needs to be linked to the MouseArea's state
            // The 'pressed' property IS available on Control, we just need to drive it.
            // The MouseArea's onPressedChanged handles this now.

        }
    }
}
