import QtQuick
import Quickshell
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    // TODO: implement actual widget, this one is just a quick AI generated one
    // Placement in the bar (anchored to the right of keyboardLocale layout)
    anchors {
        left: keyboardLocale.right
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        leftMargin: root.active ? Appearance.widgetMarginLeft : 0
        bottomMargin: Appearance.widgetMarginBottom
    }

    // Expose active state to drive visibility
    readonly property bool active: MediaDataEngine.active

    // Dynamic sizing matching status bar design tokens
    width: implicitWidth
    height: Appearance.widgetHeight
    readonly property int targetWidth: active ? (mainLayout.width + Appearance.widgetPaddingHorizontal) : 0
    implicitWidth: FocusMode.active ? 0 : targetWidth
    radius: Appearance.widgetCornerRadius
    color: Colours.background
    clip: true

    // Delays for outside-in transition
    readonly property int focusDelay: 300
    readonly property int normalDelay: 0

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

    // Hover state to provide visual feedback
    readonly property bool isHovered: mouseArea.containsMouse

    // Smooth width transition matching the other modules
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

    // Smooth hover highlight background
    Rectangle {
        id: hoverOverlay
        anchors.fill: parent
        radius: parent.radius
        color: Colours.foam
        opacity: root.isHovered ? 0.08 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // Collapse to exactly 0 pixels and hide natively when Spotify is not active or Focus Mode is active
    visible: implicitWidth > 0 && opacity > 0.0
    opacity: (active && !FocusMode.active) ? 1.0 : 0.0
    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: root.useFocusTransitionDelay ? (FocusMode.active ? root.focusDelay : root.normalDelay) : 0 }
            NumberAnimation {
                duration: Appearance.textFadeDuration
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Play/Pause execution
        onClicked: {
            if (MediaDataEngine.targetPlayer) {
                MediaDataEngine.targetPlayer.togglePlaying();
            }
        }

        // Skip tracks on scroll events
        onWheel: (wheel) => {
            if (!MediaDataEngine.targetPlayer) return;
            if (wheel.angleDelta.y > 0) {
                MediaDataEngine.targetPlayer.next();
            } else if (wheel.angleDelta.y < 0) {
                MediaDataEngine.targetPlayer.previous();
            }
        }

        // Layout content
        Row {
            id: mainLayout
            anchors.centerIn: parent
            spacing: Appearance.iconTextSpacing

            // Spotify/Music Icon styled dynamically using rose/foam palette
            MaterialIcon {
                id: mediaIcon
                icon: "music_note"
                color: root.isHovered ? Colours.text : Colours.foam
                opticalSize: Appearance.fontSizeLarge + 2
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // Artist and Track display with support for pause icon and ad state
            StyledText {
                id: trackText
                text: MediaDataEngine.playingStateText + MediaDataEngine.formattedTrack
                color: root.isHovered ? Colours.text : Colours.text
                font {
                    pixelSize: Appearance.fontSizeMediumLarge
                    weight: Appearance.fontWeightBold
                }
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
