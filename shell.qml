import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: rootWindow

    // Anchors & Geometry
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: theme.windowHeight

    // Window Layer & Mask Settings
    exclusionMode: Quickshell.Normal
    color: theme.transparent
    mask: Region { item: island }

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: theme.exclusiveZone

    Theme {
        id: theme
    }

    Rectangle {
        id: island

        // Component Configuration Properties
        readonly property bool expanded: hover.hovered

        // Position & Size Layout
        anchors {
            // horizontalCenter: parent.horizontalCenter
            left: parent.left
            top: parent.top
            topMargin: theme.islandMarginTop
            leftMargin: theme.leftMargin
        }
        width: implicitWidth
        height: implicitHeight
        implicitWidth: expanded ? theme.islandWidthExpanded : theme.islandWidthCollapsed
        implicitHeight: expanded ? theme.islandHeightExpanded : theme.islandHeightCollapsed
        radius: Math.min(height / 2, theme.maxCornerRadius)

        // Styling
        color: theme.background
        clip: true

        // Size Transition Behaviors
        Behavior on implicitWidth {
            NumberAnimation {
                duration: theme.resizeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: theme.resizeEasing
                }
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: theme.resizeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: theme.resizeEasing
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
            spacing: theme.iconTextSpacing
            opacity: island.expanded ? 0.0 : 1.0

            Behavior on opacity {
                NumberAnimation {
                    duration: theme.textFadeDuration
                }
            }

            Text {
                id: collapsedIcon
                text: "schedule"
                color: theme.gold
                font {
                    family: "Material Symbols Rounded"
                    pixelSize: theme.fontSizeMedium + 2
                }
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: collapsedTime
                text: Qt.formatDateTime(clock.date, "hh:mm")
                color: theme.gold
                font {
                    pixelSize: theme.fontSizeMedium
                    weight: theme.fontWeightBold
                }
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Expanded View (Clock and Date)
        Column {
            id: expandedView
            anchors.centerIn: parent
            spacing: theme.columnSpacing
            opacity: island.expanded ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: theme.columnFadeDuration
                    easing {
                        type: Easing.Bezier
                        bezierCurve: theme.fadeEasing
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "hh:mm")
                color: theme.gold
                font {
                    pixelSize: theme.fontSizeLarge
                    weight: theme.fontWeightBold
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "dddd, MMMM dd")
                color: theme.text
                font {
                    pixelSize: theme.fontSizeSmall
                    weight: theme.fontWeightBold
                }
            }
        }
    }
}
