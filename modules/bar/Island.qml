import QtQuick
import Quickshell
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    // Component Configuration Properties
    readonly property bool expanded: hover.hovered

    // Position & Size Layout
    anchors {
        left: parent.left
        top: parent.top
        topMargin: Appearance.islandMarginTop
        leftMargin: Appearance.leftMargin
    }
    width: implicitWidth
    height: implicitHeight
    implicitWidth: expanded ? Appearance.islandWidthExpanded : Appearance.islandWidthCollapsed
    implicitHeight: expanded ? Appearance.islandHeightExpanded : Appearance.islandHeightCollapsed
    radius: Math.min(height / 2, Appearance.maxCornerRadius)

    // Styling
    color: Colours.background
    clip: true

    // Size Transition Behaviors
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.resizeDuration
            easing {
                type: Easing.Bezier
                bezierCurve: Appearance.resizeEasing
            }
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.resizeDuration
            easing {
                type: Easing.Bezier
                bezierCurve: Appearance.resizeEasing
            }
        }
    }

    // Interaction Handling
    HoverHandler {
        id: hover
    }

    // Time / Date Data Source
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Collapsed View (Simple Digital Clock & Icon)
    Row {
        id: collapsedView
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing
        opacity: root.expanded ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.textFadeDuration
            }
        }

        MaterialIcon {
            id: collapsedIcon
            icon: "schedule"
            color: Colours.gold
            opticalSize: Appearance.fontSizeMedium + 2
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: collapsedTime
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: Colours.gold
            font {
                pixelSize: Appearance.fontSizeMedium
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Expanded View (Clock and Date)
    Column {
        id: expandedView
        anchors.centerIn: parent
        spacing: Appearance.columnSpacing
        opacity: root.expanded ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.columnFadeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: Appearance.fadeEasing
                }
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: Colours.gold
            font {
                pixelSize: Appearance.fontSizeLarge
                weight: Appearance.fontWeightBold
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, MMMM dd")
            color: Colours.text
            font {
                pixelSize: Appearance.fontSizeSmall
                weight: Appearance.fontWeightBold
            }
        }
    }
}
