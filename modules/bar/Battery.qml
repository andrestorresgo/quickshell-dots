import QtQuick
import Quickshell.Services.UPower
import "../../config"
import "../../services"
import "../../components"


Rectangle {
    id: root

    property var battery: UPower.displayDevice

    anchors {
        right: volumeAndBrightness.left
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        rightMargin: Appearance.widgetMarginRight
        bottomMargin: Appearance.widgetMarginBottom
    }

    width: implicitWidth
    height: implicitHeight
    readonly property int targetWidth: mainLayout.width + Appearance.widgetPaddingHorizontal
    implicitWidth: FocusMode.active ? 0 : targetWidth
    implicitHeight: Appearance.widgetHeight

    radius: Appearance.widgetCornerRadius
    color: Colours.background

    // Delays for outside-in transition
    readonly property int focusDelay: 100
    readonly property int normalDelay: 200

    opacity: FocusMode.active ? 0.0 : 1.0
    visible: opacity > 0.0 || implicitWidth > 0

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: FocusMode.active ? root.focusDelay : root.normalDelay }
            NumberAnimation { duration: 200 }
        }
    }

    Behavior on implicitWidth {
        SequentialAnimation {
            PauseAnimation { duration: FocusMode.active ? root.focusDelay : root.normalDelay }
            NumberAnimation {
                duration: Appearance.resizeDuration
                easing {
                    type: Easing.Bezier
                    bezierCurve: Appearance.resizeEasing
                }
            }
        }
    }

    function getWidgetColor(): color {
        if (!battery.ready) return Colours.muted;
        
        const pct = battery.percentage * 100;
        const isCharging = (battery.state === 1 || battery.state === 5);
        
        if (isCharging) {
            return clickArea.containsMouse ? Colours.text : Colours.foam;
        }
        
        if (pct <= 20) {
            return clickArea.containsMouse ? Colours.text : Colours.love;
        }
        
        return clickArea.containsMouse ? Colours.text : Colours.foam;
    }

    function getBatteryIcon(): string {
        if (!battery.ready) return "battery_android_question";
        
        const pct = battery.percentage * 100;
        const isCharging = (battery.state === 1 || battery.state === 5);
        
        if (isCharging) return "bolt";
        
        if (pct <= 10) return "battery_android_alert";
        if (pct <= 20) return "battery_android_frame_1";
        if (pct <= 35) return "battery_android_frame_2";
        if (pct <= 50) return "battery_android_frame_3";
        if (pct <= 65) return "battery_android_frame_4";
        if (pct <= 80) return "battery_android_frame_5";
        if (pct <= 90) return "battery_android_frame_6";
        return "battery_android_frame_full";
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: Appearance.iconTextSpacing

        MaterialIcon {
            icon: getBatteryIcon()
            color: getWidgetColor()
            opticalSize: Appearance.fontSizeLarge + 2
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        StyledText {
            text: (battery.ready ? Math.round(battery.percentage * 100) : 0) + "%"
            color: getWidgetColor()
            font {
                pixelSize: Appearance.fontSizeMediumLarge
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
