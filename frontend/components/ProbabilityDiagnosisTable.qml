// ProbabilityDiagnosisTable.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls // For ScrollView
import "../" as App     // Assuming Constants.qml is one level up

Rectangle {
    id: rootTable

    // --- Public API / Properties ---
    property string probabilityHeaderText: qsTr("Вероятность")
    property string diagnosisHeaderText: qsTr("Диагноз")
    property list<variant> modelData: []

    function modelPredictionsToArray(modelPredictions){
        const diagnosisMap = {
            "Melanoma": "Меланома",
            "Nevus": "Пигментный невус", // Assuming Nevus -> Пигментный невус
            "Basal cell carcinoma": "Базалиома",
            "Actinic keratosis": "Актинический кератоз",
            "Benign keratosis-like lesions": "Себорейный кератоз", // Or could be "Кератоз"
            "Dermatofibroma": "Дерматофиброма",
            "Vascular lesions": "Сосудистые поражения" // Example, as it's in input but not target
            // Add other mappings if your input can have more keys
        };

        let modelProbabilitiesData = [];

        // 2. Iterate over the predictions, transform, and collect
        for (const key in modelPredictions) {
            if (modelPredictions.hasOwnProperty(key)) {
                const probabilityValue = modelPredictions[key];
                const russianDiagnosis = diagnosisMap[key] || key; // Fallback to key if no mapping

                modelProbabilitiesData.push({
                    probability: probabilityValue,
                    diagnosis: qsTr(`${russianDiagnosis}`)
                });
            }
        }

        // 3. Sort by numeric probability in descending order
        modelProbabilitiesData.sort((a, b) => b.probabilityValue - a.probabilityValue);
        console.log(modelProbabilitiesData)

        return modelProbabilitiesData
    }
    // --- Dimensions ---
    implicitWidth: 550 // Default width, can be overridden by parent layout

    // The implicitHeight will be the natural height of all its content.
    // If the parent constrains 'height' or 'Layout.preferredHeight' to less than this,
    // the ScrollView will become active.
    implicitHeight: contentWrapper.implicitHeight

    // --- Appearance ---
    color: App.Constants.buttonSecondaryBackground
    radius: App.Constants.radiusMedium
    clip: true // Crucial for ScrollView inside a Rectangle with radius

    ScrollView {
        id: scrollView
        anchors.fill: parent // ScrollView fills the rootTable
        clip: true

        // --- Scrollbar Styling ---
        ScrollBar.vertical: ScrollBar {
            // Explicitly anchor to the right of the ScrollView (its parent)
            anchors.right: parent.right
            anchors.rightMargin: 2 // Optional small margin from the edge
            width: 12 // Slightly wider for easier grabbing, includes padding
            policy: ScrollBar.AsNeeded // Only show when content overflows

            background: Rectangle {
                color: "transparent" // Track is transparent
            }
            contentItem: Rectangle { // The thumb itself
                // Anchors ensure thumb doesn't include scrollbar's own padding
                anchors.fill: parent
                anchors.margins: 2 // Makes thumb slightly smaller than scrollbar width/height

                radius: (parent.width - anchors.margins * 2) / 2 // Rounded thumb
                color: parent.hovered ? App.Constants.borderPrimary : Qt.alpha(App.Constants.borderPrimary, 0.7)
            }
        }
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded // Not used in this design
        }

        // --- Content Wrapper for Padding (acts as the contentItem for ScrollView) ---
        Rectangle {
            id: contentWrapper
            // Width: ScrollView provides availableWidth which accounts for the vertical scrollbar.
            width: scrollView.availableWidth
            // Height: Determined by its content (internalScrollableContent) plus vertical padding.
            // This height is what ScrollView compares against its own viewport height.
            implicitHeight: internalScrollableContent.implicitHeight + // Height of the actual content
                            internalScrollableContent.anchors.topMargin + // Top padding
                            internalScrollableContent.anchors.bottomMargin  // Bottom padding
            color: "transparent" // Wrapper itself is transparent

            // --- Container for all scrollable content (headers, data) ---
            ColumnLayout {
                id: internalScrollableContent
                anchors.fill: parent // Fills contentWrapper
                // Margins applied here act as padding *inside* the contentWrapper.
                anchors.topMargin: App.Constants.spacing
                anchors.bottomMargin: App.Constants.spacing
                anchors.leftMargin: App.Constants.spacing
                anchors.rightMargin: App.Constants.spacing

                // --- Header Row ---
                RowLayout {
                    id: headerRow
                    Layout.fillWidth: true
                    spacing: App.Constants.spacing

                    Rectangle {
                        id: probabilityHeaderRect
                        Layout.preferredWidth: 130
                        implicitHeight: 40
                        color: App.Constants.headerPillBackground
                        radius: App.Constants.radiusSmall
                        Text {
                            text: rootTable.probabilityHeaderText
                            anchors.centerIn: parent
                            font.family: App.Constants.fontFamily
                            font.bold: true; font.pixelSize: 15
                            color: App.Constants.textPrimary
                        }
                    }
                    Rectangle {
                        id: diagnosisHeaderRect
                        Layout.fillWidth: true
                        implicitHeight: probabilityHeaderRect.implicitHeight
                        color: App.Constants.headerPillBackground
                        radius: App.Constants.radiusSmall
                        Text {
                            text: rootTable.diagnosisHeaderText
                            anchors.centerIn: parent
                            font.family: App.Constants.fontFamily
                            font.bold: true; font.pixelSize: 15
                            color: App.Constants.textPrimary
                        }
                    }
                }

                // --- Data Rows Container ---
                ColumnLayout {
                    id: dataRowsLayout
                    Layout.fillWidth: true
                    Layout.topMargin: App.Constants.spacing * 0.75 // Space below header
                    spacing: App.Constants.spacing * 0.75          // Space between data rows

                    Repeater {
                        model: rootTable.modelData
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: headerRow.spacing // Align with header spacing
                            Rectangle {
                                id: probabilityPill
                                Layout.preferredWidth: probabilityHeaderRect.Layout.preferredWidth
                                implicitHeight: 36
                                color: App.Constants.buttonSecondaryBackground
                                border.color: App.Constants.textSecondary
                                border.width: 1.5
                                radius: implicitHeight / 2
                                Text {
                                    text: qsTr(Number(modelData.probability * 100).toFixed(1).toString() + "%")
                                    anchors.centerIn: parent
                                    font.family: App.Constants.fontFamily
                                    font.pixelSize: 14; font.bold: true
                                    color: App.Constants.textSecondary
                                }
                            }
                            Text {
                                text: modelData.diagnosis
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                font.family: App.Constants.fontFamily
                                font.pixelSize: 15
                                color: App.Constants.textPrimary
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            } // End internalScrollableContent
        } // End contentWrapper
    } // End scrollView
}