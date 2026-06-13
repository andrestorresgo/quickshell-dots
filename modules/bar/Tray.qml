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

    visible: (repeater.count > 0) && (opacity > 0.0)
    implicitWidth: repeater.count > 0 ? (mainLayout.width + Appearance.widgetPaddingHorizontal) : 0
    implicitHeight: Appearance.widgetHeight

    radius: Appearance.widgetCornerRadius
    color: Colours.background

    opacity: FocusMode.active ? 0.0 : 1.0

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.resizeDuration
            easing {
                type: Easing.Bezier
                bezierCurve: Appearance.resizeEasing
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
