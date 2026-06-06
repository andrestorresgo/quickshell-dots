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
    }

    width: implicitWidth
    height: implicitHeight
    implicitWidth: mainLayout.width + Appearance.widgetPaddingHorizontal
    implicitHeight: Appearance.widgetHeight

    radius: height / 2
    color: Colours.background

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
                pixelSize: Appearance.fontSizeMedium
                weight: Appearance.fontWeightBold
            }
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
