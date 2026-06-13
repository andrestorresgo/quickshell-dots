import QtQuick
import Quickshell
import Quickshell.Io
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    anchors {
        right: battery.left
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        rightMargin: Appearance.widgetMarginRight
        bottomMargin: Appearance.widgetMarginBottom
    }

    width: implicitWidth
    readonly property int targetWidth: mainLayout.width + Appearance.widgetPaddingHorizontal
    implicitWidth: FocusMode.active ? 0 : targetWidth
    implicitHeight: Appearance.widgetHeight

    radius: Appearance.widgetCornerRadius
    color: Colours.background

    // Delays for outside-in transition
    readonly property int focusDelay: 200
    readonly property int normalDelay: 100

    property bool useFocusTransitionDelay: false

    Timer {
        id: delayResetTimer
        interval: 1000
        onTriggered: root.useFocusTransitionDelay = false
    }

    opacity: FocusMode.active ? 0.0 : 1.0
    visible: opacity > 0.0 || implicitWidth > 0

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

    // State Variables
    property string wifiIcon: "wifi_off"
    property string wifiText: "OFFLINE"
    property string wifiSsid: ""
    property string wifiState: "disconnected"

    property bool btEnabled: false
    property bool btConnected: false
    property string btIcon: "bluetooth_disabled"
    property string btText: "OFF"
    property string btDeviceName: ""

    readonly property string scriptPath: {
        var url = Qt.resolvedUrl("connectivity_status.sh").toString();
        if (url.indexOf("file://") === 0) {
            return url.substring(7);
        }
        return url;
    }

    Process {
        id: statusProcess
        command: [root.scriptPath]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const cleanedText = text.trim();
                if (!cleanedText) return;
                try {
                    const data = JSON.parse(cleanedText);
                    if (data) {
                        root.wifiIcon = data.network.icon || "wifi_off";
                        root.wifiText = data.network.text || "OFFLINE";
                        root.wifiSsid = data.network.ssid || "";
                        root.wifiState = data.network.state || "disconnected";

                        root.btEnabled = data.bluetooth.enabled || false;
                        root.btConnected = data.bluetooth.connected || false;
                        root.btIcon = data.bluetooth.icon || "bluetooth_disabled";
                        root.btText = data.bluetooth.text || "OFF";
                        root.btDeviceName = data.bluetooth.device_name || "";
                    }
                } catch (e) {
                    console.error("Failed to parse connectivity status JSON:", e, "Raw output:", cleanedText);
                }
            }
        }
    }

    Process {
        id: wifiToggleProcess
        property string targetState: "on"
        command: ["nmcli", "radio", "wifi", targetState]
        onRunningChanged: {
            if (!running) {
                statusProcess.running = false;
                statusProcess.running = true;
            }
        }
    }

    Process {
        id: btToggleProcess
        property string targetState: "on"
        command: ["bluetoothctl", "power", targetState]
        onRunningChanged: {
            if (!running) {
                statusProcess.running = false;
                statusProcess.running = true;
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 3000
        running: !FocusMode.active
        repeat: true
        onTriggered: {
            statusProcess.running = false;
            statusProcess.running = true;
        }
    }

    Connections {
        target: FocusMode
        function onActiveChanged(): void {
            root.useFocusTransitionDelay = true;
            delayResetTimer.restart();
            if (!FocusMode.active) {
                statusProcess.running = false;
                statusProcess.running = true;
            }
        }
    }

    Component.onCompleted: {
        statusProcess.running = true;
    }

    // Widget UI Layout
    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 12

        MouseArea {
            id: networkArea
            width: networkLayout.width
            height: root.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                wifiToggleProcess.targetState = (root.wifiIcon === "wifi_off") ? "on" : "off";
                wifiToggleProcess.running = false;
                wifiToggleProcess.running = true;
            }

            Row {
                id: networkLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.iconTextSpacing

                MaterialIcon {
                    icon: root.wifiIcon
                    color: networkArea.containsMouse ? Colours.text : Colours.love
                    opticalSize: Appearance.fontSizeLarge + 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                StyledText {
                    text: root.wifiText
                    color: networkArea.containsMouse ? Colours.text : Colours.love
                    font {
                        pixelSize: Appearance.fontSizeMediumLarge
                        weight: Appearance.fontWeightBold
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }

        Rectangle {
            id: separator
            width: 1
            height: 12
            color: Colours.muted
            opacity: 0.5
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: bluetoothArea
            width: bluetoothLayout.width
            height: root.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                btToggleProcess.targetState = root.btEnabled ? "off" : "on";
                btToggleProcess.running = false;
                btToggleProcess.running = true;
            }

            Row {
                id: bluetoothLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.iconTextSpacing

                MaterialIcon {
                    icon: root.btIcon
                    color: bluetoothArea.containsMouse ? Colours.text : Colours.gold
                    opticalSize: Appearance.fontSizeLarge + 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                StyledText {
                    text: root.btText
                    color: bluetoothArea.containsMouse ? Colours.text : Colours.gold
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
}

