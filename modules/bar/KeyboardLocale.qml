import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    property string currentKeymap: "Unknown"
    readonly property string shortKeymap: getShortLayoutName(currentKeymap)
    readonly property bool expanded: hoverHandler.hovered

    // Position & Size Layout
    anchors {
        left: workspaces.right
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        leftMargin: Appearance.widgetMarginLeft
    }

    width: implicitWidth
    height: Appearance.widgetHeight
    implicitWidth: expanded ? expandedLayout.width + Appearance.widgetPaddingHorizontal : collapsedLayout.width + Appearance.widgetPaddingHorizontal
    radius: height / 2
    color: Colours.background
    clip: true

    // Smooth Width Transition behavior matching clock/workspaces
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.resizeDuration
            easing {
                type: Easing.Bezier
                bezierCurve: Appearance.resizeEasing
            }
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            cycleLayoutProcess.start();
        }
    }

    // TODO: fix keyboard layout not cycling on click
    // Process to cycle keyboard layouts
    Process {
        id: cycleLayoutProcess
        command: ["hyprctl", "switchxkblayout", "all", "next"]
    }

    // Process to retrieve initial keyboard layout on startup
    Process {
        id: initLayoutProcess
        command: ["hyprctl", "devices", "-j"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text);
                    if (devices && devices.keyboards) {
                        // Look for the main keyboard device
                        let mainKb = devices.keyboards.find(kb => kb.main === true);
                        if (!mainKb) {
                            // Fallback to any keyboard device with a configured layout
                            mainKb = devices.keyboards.find(kb => kb.layout && kb.layout.length > 0);
                        }
                        if (mainKb) {
                            root.currentKeymap = mainKb.active_keymap;
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse initial Hyprland devices list:", e);
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const parts = event.data.split(",");
                if (parts.length >= 2) {
                    root.currentKeymap = parts[1];
                }
            }
        }
    }

    // Collapsed View: Keyboard Icon + Short Code (e.g. US, ES)
    Row {
        id: collapsedLayout
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing
        opacity: root.expanded ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.textFadeDuration
            }
        }

        MaterialIcon {
            icon: "keyboard"
            color: clickArea.pressed ? Colours.subtle : (hoverHandler.hovered ? Colours.text : Colours.foam)
            opticalSize: Appearance.fontSizeMedium + 2
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        StyledText {
            text: root.shortKeymap
            color: clickArea.pressed ? Colours.subtle : (hoverHandler.hovered ? Colours.text : Colours.foam)
            font {
                pixelSize: Appearance.fontSizeMedium
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // Expanded View: Keyboard Icon + Full Keymap Name (e.g. English (US))
    Row {
        id: expandedLayout
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing
        opacity: root.expanded ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.textFadeDuration
            }
        }

        MaterialIcon {
            icon: "keyboard"
            color: clickArea.pressed ? Colours.subtle : Colours.foam
            opticalSize: Appearance.fontSizeMedium + 2
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: root.currentKeymap
            color: clickArea.pressed ? Colours.subtle : Colours.text
            font {
                pixelSize: Appearance.fontSizeMedium
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Helper to map long keymap names to clean 2-letter codes
    function getShortLayoutName(keymapName) {
        if (!keymapName || keymapName === "Unknown") return "??";
        const name = keymapName.toLowerCase();
        if (name.includes("english") || name.includes("us")) return "EN";
        if (name.includes("spanish") || name.includes("latam") || name.includes("latin")) return "ES";
        if (name.includes("french") || name.includes("fr")) return "FR";
        if (name.includes("german") || name.includes("de")) return "DE";
        if (name.includes("russian") || name.includes("ru")) return "RU";
        if (name.includes("japanese") || name.includes("jp")) return "JP";
        return keymapName.substring(0, 2).toUpperCase();
    }
}
