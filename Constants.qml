import QtQuick // Импорт нужен всегда

// Делаем этот файл синглтоном, доступным глобально
pragma Singleton

QtObject {
    // --- Основные цвета приложения ---
    readonly property color appBackground: "#F5EEEE"      // Очень светлый фон
    readonly property color headerBackground: "#861010"   // Бордовый
    readonly property color headerText: "#FFFFFF"         // Белый

    // --- Цвета текста ---
    // ИЗМЕНЕНО: Основной цвет текста теперь коричневый
    readonly property color textPrimary: "#863A1A"        // Основной текст (коричневый)
    // Вторичный цвет текста оставляем таким же, т.к. он используется для рамок и кнопок
    readonly property color textSecondary: "#863A1A"      // Коричневый (Sienna) - для акцентов, рамок, текста кнопок
    readonly property color textOnPrimary: "#FFFFFF"      // Текст на бордовом фоне (белый)
    readonly property color textOnAccent: "#FFFFFF"       // Текст на цветных фонах результатов (белый)
    readonly property color textPlaceholder: "#A0A0A0"    // Цвет для плейсхолдеров

    // --- Цвета рамок и разделителей ---
    // Используем textSecondary (который тоже #863A1A) для рамок
    readonly property color borderPrimary: textSecondary
    readonly property color divider: "#E0E0E0"            // Светло-серый для разделителей

    // --- Цвета кнопок ---
    // Основная кнопка (типа "Анализировать")
    readonly property color buttonPrimaryBackground: headerBackground // Бордовый #861010
    readonly property color buttonPrimaryText: textOnPrimary          // Белый текст

    // Вторичная кнопка / Кнопка меню
    readonly property color buttonSecondaryBackground: "#FFFFFF"        // Белый фон
    readonly property color buttonSecondaryBorder: borderPrimary        // Коричневая рамка (#863A1A)
    readonly property color buttonSecondaryText: textSecondary          // Коричневый текст (#863A1A)
    readonly property color buttonSecondaryHover: "#EAEAEA"             // Светло-серый при наведении
    readonly property color buttonSecondaryPressed: "#E7C2C2"           // Светло-розовый при нажатии
    readonly property color buttonSecondaryPressedHover: "#E78585"      // Розовый/лососевый (нажатие + наведение)

    // Отключенное состояние
    readonly property color buttonDisabledBackground: "#CECECE" // Серый фон
    readonly property color buttonDisabledText: "#A0A0A0"       // Блеклый текст

    // Акцентная кнопка
    readonly property color buttonAccentBackground: headerBackground // Используем основной бордовый #861010
    readonly property color buttonAccentHoverBackground: "#BE2121" // Более яркий красный для наведения
    readonly property color buttonAccentText: textOnPrimary         // Белый текст

    // --- Цвета специфичных элементов ---
    readonly property color imagePlaceholder: buttonDisabledBackground // Серый #CECECE для области изображения
    readonly property color shadow: "#80000000"           // Полупрозрачный черный для теней

    // Цвета для отображения результатов анализа
    readonly property color resultHighRisk: "#FF0000"     // Красный
    readonly property color resultMediumRisk: "#FFA500"   // Оранжевый
    readonly property color resultLowRisk: "#90EE90"      // Светло-зеленый

    // Цвета для таблиц
    readonly property color tableHeaderBackground: "#D2B48C" // Бежевый (Tan)
    // ИЗМЕНЕНО: Текст заголовка таблицы теперь тоже будет коричневым, т.к. он использует textPrimary
    readonly property color tableHeaderText: textPrimary
    readonly property color tableCellBorder: tableCellBorder   // Коричневая рамка ячейки (#863A1A)

    // --- Дополнительные цвета из скриншота (пока не используются) ---
    // readonly property color unusedRed: "#BE2121"
    // readonly property color unusedTransparentWhite: "#00FFFFFF"
}
