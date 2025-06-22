// Constants.qml
import QtQuick

// This file is a singleton, globally available as "Constants" or "App.Constants"
pragma Singleton

QtObject {
    id: constants

    // --- Theme State ---
    // The core property that controls the theme. Default is light (false).
    property bool isDark: false

    // The function that the UI will call to switch the theme.
    function toggleTheme() {
        isDark = !isDark;
        // The change in 'isDark' will automatically update all bound properties.
    }

    // --- Theme-Dependent Colors ---
    // Each property now uses a ternary operator to choose the color
    // based on the 'isDark' property.

    // --- Main Colors ---
    readonly property color appBackground: isDark ? "#1E1E1E" : "#F5EEEE"
    readonly property color headerBackground: "#861010"   // Stays the same for brand consistency
    readonly property color headerText: "#FFFFFF"

    // --- Text Colors ---
    readonly property color textPrimary: isDark ? "#E0E0E0" : "#863A1A"
    readonly property color textSecondary: isDark ? "#BDBDBD" : "#863A1A"
    readonly property color textOnPrimary: "#FFFFFF"
    readonly property color textOnAccent: "#FFFFFF"
    readonly property color textPlaceholder: isDark ? "#757575" : "#A0A0A0"
    readonly property color accent: "#861010"

    // --- Borders and Dividers ---
    readonly property color borderPrimary: isDark ? textSecondary : textSecondary
    readonly property color divider: isDark ? "#3A3A3A" : "#E0E0E0"

    // --- Button Colors ---
    // Primary Button
    readonly property color buttonPrimaryBackground: headerBackground
    readonly property color buttonPrimaryText: textOnPrimary

    // Secondary Button
    readonly property color buttonSecondaryBackground: isDark ? "#2C2C2C" : "#FFFFFF"
    readonly property color buttonSecondaryBorder: borderPrimary
    readonly property color buttonSecondaryText: textPrimary
    readonly property color buttonSecondaryHover: isDark ? "#3D3D3D" : "#EAEAEA"
    readonly property color buttonSecondaryPressed: isDark ? "#4A4A4A" : "#E7C2C2"
    readonly property color buttonSecondaryPressedHover: isDark ? "#5A5A5A" : "#E78585"

    // Disabled State
    readonly property color buttonDisabledBackground: isDark ? "#424242" : "#CECECE"
    readonly property color buttonDisabledText: isDark ? "#757575" : "#A0A0A0"

    // Accent Button
    readonly property color buttonAccentBackground: headerBackground
    readonly property color buttonAccentHoverBackground: "#BE2121"
    readonly property color buttonAccentText: textOnPrimary

    // --- Specific Element Colors ---
    readonly property color imagePlaceholder: buttonDisabledBackground
    readonly property color shadow: isDark ? "#99000000" : "#80000000"

    // Result Colors
    readonly property color melanomaProbabilityHigh: "#FF5722"  // A more visible orange-red
    readonly property color melanomaProbabilityMedium: "#FFA726"
    readonly property color melanomaProbabilityLow: "#66BB6A"   // Slightly darker green for better contrast

    // Table Colors
    readonly property color tableHeaderBackground: isDark ? "#333333" : "#D2B48C"
    readonly property color tableHeaderText: textPrimary
    readonly property color tableCellBorder: isDark ? "#555555" : "#863A1A"
    readonly property color headerPillBackground: isDark ? "#3B1A1A" : "#FBECEC"

    // Status Colors
    readonly property color infoColor: isDark ? "#4FC3F7" : "#2196F3"
    readonly property color warningColor: isDark ? "#FFB74D" : "#FF9800"
    readonly property color errorColor: isDark ? "#E57373" : "#F44336"


    // --- Non-Color Constants (remain unchanged) ---
    readonly property int spacing: 16
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 12
    readonly property var fontFamily: Qt.platform.os === "windows" ? "Segoe UI" : "Arial"
}