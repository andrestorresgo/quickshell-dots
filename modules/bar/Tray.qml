import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    required property var window

    anchors {
        right: connectivity.left
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        rightMargin: Appearance.widgetMarginRight
        bottomMargin: Appearance.widgetMarginBottom
    }

    width: implicitWidth
    height: implicitHeight

    visible: (repeater.count > 0) && (opacity > 0.0 || implicitWidth > 0)
    readonly property int targetWidth: repeater.count > 0 ? (mainLayout.width + Appearance.widgetPaddingHorizontal) : 0
    implicitWidth: FocusMode.active ? 0 : targetWidth
    implicitHeight: Appearance.widgetHeight

    radius: Appearance.widgetCornerRadius
    color: Colours.background

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

    opacity: FocusMode.active ? 0.0 : 1.0

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: root.useFocusTransitionDelay ? (FocusMode.active ? root.focusDelay : root.normalDelay) : 0 }
            NumberAnimation { duration: 200 }
        }
    }

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

    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            id: repeater
            model: SystemTray.items
            delegate: MouseArea {
                id: itemMouseArea
                width: Appearance.widgetHeight - 12
                height: Appearance.widgetHeight - 12
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                // Platform context menu anchor
                // TODO: fix alignment and theme
                QsMenuAnchor {
                    id: menuAnchor
                    menu: modelData.menu
                    anchor {
                        window: root.window
                        rect: {
                            var pos = itemMouseArea.mapToItem(null, 0, 0);
                            return Qt.rect(pos.x, pos.y, itemMouseArea.width, itemMouseArea.height);
                        }
                    }
                }

                Rectangle {
                    id: hoverBg
                    anchors.fill: parent
                    radius: 8
                    color: Colours.overlay
                    opacity: itemMouseArea.containsMouse ? (itemMouseArea.pressed ? 0.8 : 0.4) : 0.0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                // Tray icon wrapper using specialized Quickshell IconImage
                // TODO: investigate why icon is different in waybar vs quickshell
                IconImage {
                    id: iconImg
                    source: modelData.icon
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                }

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu) {
                            menuAnchor.open();
                        }
                    } else {
                        if (modelData.onlyMenu && modelData.hasMenu) {
                            menuAnchor.open();
                        } else {
                            modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
