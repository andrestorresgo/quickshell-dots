import QtQuick
import Quickshell.Hyprland
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    // Position Anchors
    anchors {
        left: clock.right
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        leftMargin: Appearance.widgetMarginLeft
        bottomMargin: Appearance.widgetMarginBottom
    }

    // Dynamic Size Layout
    width: implicitWidth
    height: implicitHeight
    readonly property int targetWidth: mainLayout.width + Appearance.widgetPaddingHorizontal
    implicitWidth: FocusMode.active ? 0 : targetWidth
    implicitHeight: Appearance.widgetHeight

    // Delays for outside-in transition
    readonly property int focusDelay: 100
    readonly property int normalDelay: 200

    property bool useFocusTransitionDelay: false

    Timer {
        id: delayResetTimer
        interval: 1000
        onTriggered: root.useFocusTransitionDelay = false
    }

    Connections {
        target: FocusMode
        function onActiveChanged(): void {
            root.useFocusTransitionDelay = true;
            delayResetTimer.restart();
        }
    }

    // Styling
    radius: Appearance.widgetCornerRadius
    color: Colours.background

    opacity: FocusMode.active ? 0.0 : 1.0
    visible: opacity > 0.0 || implicitWidth > 0

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: root.useFocusTransitionDelay ? (FocusMode.active ? root.focusDelay : root.normalDelay) : 0 }
            NumberAnimation { duration: 200 }
        }
    }

    // Smooth Width Resize Behavior
    Behavior on implicitWidth {
        SequentialAnimation {
            PauseAnimation { duration: root.useFocusTransitionDelay ? (FocusMode.active ? root.focusDelay : root.normalDelay) : 0 }
            NumberAnimation {
                duration: Appearance.resizeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: Appearance.resizeEasing
                }
            }
        }
    }

    readonly property var activeWorkspaces: {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return [];
        return Hyprland.workspaces.values
            .filter(w => w && w.id > 0 && (w.focused || (w.toplevels && w.toplevels.values.length > 0)))
            .sort((a, b) => a.id - b.id);
    }

    readonly property var workspaceMap: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    function getWorkspaceDisplay(id) {
        if (id >= 1 && id <= 10) {
            return workspaceMap[id - 1];
        }
        return id.toString();
    }

    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing

        Repeater {
            model: root.activeWorkspaces
            delegate: MouseArea {
                id: wsButton
                width: textItem.width + 12
                height: root.height
                hoverEnabled: true

                StyledText {
                    id: textItem
                    anchors.centerIn: parent
                    text: root.getWorkspaceDisplay(modelData.id)
                    color: modelData.focused ? Colours.text : (wsButton.containsMouse ? Colours.text : Colours.muted)
                    font.family: Appearance.fontFamilyWorkspaces
                    font.pixelSize: Appearance.fontSizeMedium
                    font.weight: Appearance.fontWeightBold

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                onClicked: {
                    modelData.activate();
                }
            }
        }
    }
}

