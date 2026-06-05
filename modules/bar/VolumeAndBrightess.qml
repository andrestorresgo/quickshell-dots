import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    // Color/Radius Styling
    color: Colours.background
    radius: height / 2

    // Placement in the bar (anchored to the top-right corner)
    anchors {
        right: parent.right
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        rightMargin: Appearance.widgetMarginLeft
    }

    // Dynamic Sizing
    width: implicitWidth
    height: implicitHeight
    implicitWidth: mainLayout.width + Appearance.widgetPaddingHorizontal
    implicitHeight: Appearance.widgetHeight

    // State Variables
    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    property int brightnessPercent: 0

    // Tracker to ensure PipeWire sink properties are actively updated
    PwObjectTracker {
        id: audioTracker
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // Volume Interaction Functions
    function toggleMute(): void {
        const audio = Pipewire.defaultAudioSink?.audio;
        if (audio) {
            audio.muted = !audio.muted;
        }
    }

    function adjustVolume(delta: real): void {
        const audio = Pipewire.defaultAudioSink?.audio;
        if (audio) {
            let newVol = audio.volume + delta;
            if (newVol < 0) newVol = 0;
            if (newVol > 1) newVol = 1;
            audio.volume = newVol;
        }
    }

    // Brightness Interaction Functions
    function adjustBrightness(changeStr: string): void {
        setBrightnessProcess.running = false;
        setBrightnessProcess.change = changeStr;
        setBrightnessProcess.running = true;
    }

    function getBrightnessIcon(): string {
    const icons = [
        "brightness_1",
        "brightness_2",
        "brightness_3",
        "brightness_4",
        "brightness_5",
        "brightness_6",
        "brightness_7"
    ];

    if (brightnessPercent <= 0) return icons[0];
    
    let index = Math.ceil(brightnessPercent / 14);
    index = Math.min(index, icons.length - 1);
    
    return icons[index];
}

    // Process to get current brightness
    Process {
        id: getBrightnessProcess
        command: ["brightnessctl", "-m"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(',');
                if (parts.length >= 4) {
                    const percent = parseInt(parts[3]);
                    if (!isNaN(percent)) {
                        root.brightnessPercent = percent;
                    }
                }
            }
        }
    }

    // Process to monitor udev backlight changes (event-driven brightness)
    Process {
        id: monitorBrightnessProcess
        command: ["udevadm", "monitor", "--subsystem=backlight"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                getBrightnessProcess.running = false;
                getBrightnessProcess.running = true;
            }
        }
    }

    // Process to adjust brightness
    Process {
        id: setBrightnessProcess
        property string change: ""
        command: ["brightnessctl", "set", change]
    }

    // Widget UI Layout
    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 12

        // Volume Controller Region
        MouseArea {
            id: volumeArea
            width: volumeLayout.width
            height: root.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.toggleMute();
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    root.adjustVolume(0.02); // 2% increments
                } else if (wheel.angleDelta.y < 0) {
                    root.adjustVolume(-0.02);
                }
            }

            Row {
                id: volumeLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.iconTextSpacing

                MaterialIcon {
                    icon: root.muted ? "volume_off" : (root.volume === 0 ? "volume_mute" : (root.volume < 0.5 ? "volume_down" : "volume_up"))
                    color: volumeArea.containsMouse ? Colours.text : Colours.foam
                    opticalSize: Appearance.fontSizeMedium + 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                StyledText {
                    text: `${Math.round(root.volume * 100)}%`
                    color: volumeArea.containsMouse ? Colours.text : Colours.foam
                    font {
                        pixelSize: Appearance.fontSizeMedium
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

        // Brightness Controller Region
        MouseArea {
            id: brightnessArea
            width: brightnessLayout.width
            height: root.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    root.adjustBrightness("+5%");
                } else if (wheel.angleDelta.y < 0) {
                    root.adjustBrightness("5%-");
                }
            }

            Row {
                id: brightnessLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.iconTextSpacing

                MaterialIcon {
                    icon: getBrightnessIcon()
                    color: brightnessArea.containsMouse ? Colours.text : Colours.foam
                    opticalSize: Appearance.fontSizeMedium + 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                StyledText {
                    text: `${root.brightnessPercent}%`
                    color: brightnessArea.containsMouse ? Colours.text : Colours.foam
                    font {
                        pixelSize: Appearance.fontSizeMedium
                        weight: Appearance.fontWeightBold
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}

