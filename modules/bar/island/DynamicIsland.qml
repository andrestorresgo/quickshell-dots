import QtQuick
import Quickshell
import "../../../config"
import "../../../services"
import "../../../components"

Rectangle {
    id: root

    // Position centered on the status bar
    anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.top
        topMargin: Appearance.widgetMarginTop
    }

    height: Appearance.widgetHeight
    radius: Appearance.widgetCornerRadius
    color: Colours.background
    clip: true

    // State machine to drive layout and content states
    state: "hidden"

    states: [
        State {
            name: "hidden"
            when: !FocusMode.active
            PropertyChanges { root.opacity: 0.0 }
            PropertyChanges { root.visible: false }
            PropertyChanges { root.implicitWidth: 0 }
        },
        State {
            name: "announcement"
            when: FocusMode.active && !announcementTimer.finished
            PropertyChanges { root.opacity: 1.0 }
            PropertyChanges { root.visible: true }
            PropertyChanges { root.implicitWidth: announcementLayout.width + Appearance.widgetPaddingHorizontal }
        },
        State {
            name: "active"
            when: FocusMode.active && announcementTimer.finished
            PropertyChanges { root.opacity: 1.0 }
            PropertyChanges { root.visible: true }
            PropertyChanges { root.implicitWidth: clockLayout.width + Appearance.widgetPaddingHorizontal }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"; to: "announcement"
            NumberAnimation {
                properties: "opacity,implicitWidth"
                duration: Appearance.resizeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: Appearance.resizeEasing
                }
            }
        },
        Transition {
            from: "announcement"; to: "active"
            NumberAnimation {
                properties: "implicitWidth"
                duration: Appearance.resizeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: Appearance.resizeEasing
                }
            }
        },
        Transition {
            from: "*"; to: "hidden"
            NumberAnimation {
                properties: "opacity,implicitWidth"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    ]

    // Phase timer to control the announcement duration (Phase 1 to Phase 3 transition)
    Timer {
        id: announcementTimer
        property bool finished: false
        interval: 1200 // 1.2 seconds announcement
        
        onTriggered: {
            finished = true;
        }
    }

    Connections {
        target: FocusMode
        function onActiveChanged(): void {
            if (FocusMode.active) {
                announcementTimer.finished = false;
                announcementTimer.restart();
            } else {
                announcementTimer.stop();
                announcementTimer.finished = false;
            }
        }
    }

    // Time DataSource
    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    // Phase 1 View: Announcement Text ("Focus Mode")
    Row {
        id: announcementLayout
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing
        opacity: root.state === "announcement" ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.textFadeDuration
            }
        }

        MaterialIcon {
            icon: "lens"
            color: Colours.love
            opticalSize: Appearance.fontSizeLarge + 2
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: "Focus Mode"
            color: Colours.text
            font {
                pixelSize: Appearance.fontSizeMediumLarge
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Phase 3 View: Distraction-free Clock
    Row {
        id: clockLayout
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing
        opacity: root.state === "active" ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.textFadeDuration
            }
        }

        MaterialIcon {
            icon: "schedule"
            color: Colours.gold
            opticalSize: Appearance.fontSizeLarge + 2
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: Qt.formatDateTime(systemClock.date, "hh:mm")
            color: Colours.gold
            font {
                pixelSize: Appearance.fontSizeMediumLarge
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
