// screens/MainScreen.qml
import QtQuick
import QtQuick.Layouts
import components // Модуль с общими компонентами (TopBar, LeftMenuPanel, WorkspacePanel, Constants, Logo, AnalyzeButton)
import screens

Rectangle {
    id: mainScreenRoot
    width: 1200 // Увеличим немного для лучшего соответствия пропорциям
    height: 800
    color: Constants.appBackground // Общий фон приложения (#F5EEEE)

    property url currentAnalyzedImageSource: ""
    property string currentAnalyzedImageName: ""
    property real currentMelanomaProbability: 0

    // Основной ColumnLayout для TopBar и остального контента
    ColumnLayout {
        anchors.fill: parent
        spacing: 0 // Нет зазора между TopBar и нижней частью

        TopBar {
            id: topBar
            Layout.fillWidth: true
            // userName: "Динамическое Имя" // Можно будет установить позже
        }

        // Контейнер для "белой" части (меню + рабочая область)
        // Этот контейнер будет иметь отступы от краев и тонкую внешнюю рамку,
        // которая на макете выглядит как цвет фона.
        Rectangle {
            id: mainContentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20 // Отступы от краев окна до этой "белой" области
            color: "transparent" // Сам этот контейнер прозрачный

            // Тонкая рамка вокруг всей контентной зоны, как на макете.
            // Цвет рамки соответствует цвету фона приложения, создавая эффект "выдавленности"
            // или просто очень светлая рамка.
            // На макете рамка едва заметна и такого же цвета, что и фон.
            // Для более явной рамки можно использовать Constants.divider.
            // Пока сделаем ее очень светлой, почти как фон.
            border.color: Qt.lighter(Constants.appBackground, 1.02) // Чуть светлее фона, или Constants.divider
            border.width: 1
            radius: 8 // Небольшое скругление углов этой общей области

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15 // Внутренние отступы от рамки mainContentArea до LeftMenu и Workspace
                spacing: 15         // Зазор между LeftMenu и Workspace

                LeftMenuPanel {
                    id: leftMenu
                    Layout.preferredWidth: 250 // Ширина левого меню (подбираем по макету)
                    Layout.fillHeight: true
                    activeMenuButtonText: "Главное меню" // Устанавливаем активную кнопку


                    onMenuItemClicked: (buttonText) => {
                        // leftMenu.activeMenuButtonText = buttonText;
                        if (buttonText === qsTr("Главное меню")) {
                            workspaceLoader.sourceComponent = mainScreenContent;
                        } else if (buttonText === qsTr("Пациенты")) {
                            workspaceLoader.sourceComponent = patientsScreenContentComponent;
                        } else if (buttonText === qsTr("Анализы")) {
                            // При выборе "Анализы" всегда начинаем с настройки
                            workspaceLoader.sourceComponent = analysisSetupScreenContentComponent;
                        } else if (buttonText === qsTr("Выход")) {
                            Qt.quit();
                        } else {
                            workspaceLoader.sourceComponent = placeholderContentComponent;
                        }
                    }
                }

                WorkspacePanel { // Или Rectangle, как было в моем примере
                    id: workspace
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Loader {
                        id: workspaceLoader
                        anchors.fill: parent
                        sourceComponent: mainScreenContent // Начальный контент
                    }
                }
            }
        }
    }

    Component {
        id: analysisScreenContentComponent
        AnalysisWorkspace { // Используем наш новый компонент
            anchors.fill: parent
        }
    }

    Component {
       id: analysisResultsScreenContentComponent
       AnalysisResultsWorkspace {
           anchors.fill: parent
           // Передаем данные в компонент результатов
           imageSourceToDisplay: mainScreenRoot.currentAnalyzedImageSource
           imageName: mainScreenRoot.currentAnalyzedImageName
           melanomaProbability: mainScreenRoot.currentMelanomaProbability

           onBackClicked: {
               // Вернуться к настройке анализа
               workspaceLoader.sourceComponent = analysisSetupScreenContentComponent;
               // Опционально, сбросить активную кнопку меню, если нужно
               // leftMenu.activeMenuButtonText = qsTr("Анализы"); // Она и так должна быть "Анализы"
           }
           onSaveResultClicked: {
               console.log("Сохранить результат: ", imageName, melanomaProbability + "%");
               // TODO: Логика сохранения
           }
           onFinishAnalysisClicked: {
               console.log("Закончить анализ для: ", imageName);
               // Вернуться на главный экран или к списку анализов/пациентов
               workspaceLoader.sourceComponent = mainScreenContent;
               leftMenu.activeMenuButtonText = qsTr("Главное меню");
           }
       }
   }


    Component {
           id: patientsScreenContentComponent
           PatientsWorkspace { // Используем наш новый компонент
               anchors.fill: parent
           }
       }

    // Заглушка для других секций (если нужна)
    Component {
        id: placeholderContentComponent
        Rectangle {
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("Контент для '") + leftMenu.activeMenuButtonText + qsTr("' будет здесь.")
                font.pixelSize: 18
                color: Constants.textPlaceholder
            }
        }
    }

    Component {
            id: analysisSetupScreenContentComponent
            AnalysisWorkspace {
                anchors.fill: parent
                onAnalysisTriggered: (imgSrc, imgName, patId) => {
                    console.log("Запущен анализ для:", imgSrc, imgName, "пациент:", patId);
                    // Здесь должна быть логика самого анализа (вызов C++ или Python)
                    // Для примера, просто генерируем случайный результат
                    var randomProbability = Math.round(Math.random() * 100);

                    // Обновляем свойства в mainScreenRoot для передачи в AnalysisResultsWorkspace
                    mainScreenRoot.currentAnalyzedImageSource = imgSrc;
                    mainScreenRoot.currentAnalyzedImageName = imgName; // Или более осмысленное имя
                    mainScreenRoot.currentMelanomaProbability = randomProbability;

                    // Переключаем Loader на компонент с результатами
                    workspaceLoader.sourceComponent = analysisResultsScreenContentComponent;
                }
            }
        }


    // --- Компоненты для содержимого рабочей области ---
    // Контент для главного экрана (пока что лого, приветствие и кнопка)
    Component {
        id: mainScreenContent
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30
            width: parent.width * 0.8
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter // Ограничим ширину для лучшего вида
            Item{
                Layout.fillHeight: parent
            }
            Logo {
                implicitWidth: 100
                implicitHeight: 100
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: qsTr("Добро пожаловать в SkinSight -")
                color: Constants.textPrimary
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: qsTr("помощник по анализу родинок с искусственным интеллектом!")
                color: Constants.textPrimary
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }
            AnalyzeButton {
                text: qsTr("НОВЫЙ АНАЛИЗ")
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    console.log("Кнопка 'Новый анализ' нажата")
                    // Здесь можно будет, например, переключить leftMenu.activeMenuButton на "Анализы"
                    // и загрузить соответствующий контент в workspaceLoader
                    leftMenu.activeMenuButton = qsTr("Анализы")
                    // А затем обработать это в onMenuItemClicked или напрямую загрузить
                    // workspaceLoader.source = "AnalysisWorkspace.qml"
                    workspaceContentText.text = "Переход к созданию нового анализа..." // Заглушка
                }
            }
            // Заглушка для текстового вывода, если другой контент не загружен
            Text { id: workspaceContentText; visible: false; color: Constants.textPrimary }
            Item{
                Layout.fillHeight: parent
            }
        }
    }

    // Компонент для экрана Анализы (просто пример, его нужно будет создать отдельно)
    /*
    Component {
        id: analysisScreenContentComponent
        // AnalysisWorkspaceSpecifics { // Заменить на ваш реальный компонент
        //     anchors.fill: parent
        // }
        Rectangle { color: "lightblue"; Text { anchors.centerIn: parent; text: "Контент для Анализов"} }
    }
    */
}
