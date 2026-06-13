import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../config"
import "../../services"
import "../../components"

Rectangle {
    id: root

    color: Colours.background
    radius: Appearance.widgetCornerRadius

    opacity: FocusMode.active ? 0.0 : 1.0
    visible: opacity > 0.0 || implicitWidth > 0

    // Delays for outside-in transition
    readonly property int focusDelay: 0
    readonly property int normalDelay: 300

    property bool useFocusTransitionDelay: false

    Timer {
        id: delayResetTimer
        interval: 1000
        onTriggered: root.useFocusTransitionDelay = false
    }

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: root.useFocusTransitionDelay ? (FocusMode.active ? root.focusDelay : root.normalDelay) : 0 }
            NumberAnimation { duration: 200 }
        }
    }

    anchors {
        right: parent.right
        top: parent.top
        topMargin: Appearance.widgetMarginTop
        rightMargin: Appearance.widgetMarginLeft
        bottomMargin: Appearance.widgetMarginBottom
    }

    width: implicitWidth
    height: implicitHeight
    readonly property int targetWidth: mainLayout.width + Appearance.widgetPaddingHorizontal
    implicitWidth: FocusMode.active ? 0 : targetWidth
    implicitHeight: Appearance.widgetHeight

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
    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    property int brightnessPercent: 0

    // OSD State Management
    property string state: "normal"
    property bool isReady: false

    Timer {
        id: startupTimer
        interval: 1500
        running: true
        onTriggered: root.isReady = true
    }

    Timer {
        id: osdTimer
        interval: Appearance.osdTimer
        onTriggered: root.state = "normal"
    }

    // Change listeners to trigger OSD state
    onVolumeChanged: {
        if (root.isReady) {
            root.state = "volume";
            osdTimer.restart();
        }
    }

    onMutedChanged: {
        if (root.isReady) {
            root.state = "volume";
            osdTimer.restart();
        }
    }

    onBrightnessPercentChanged: {
        if (root.isReady) {
            root.state = "brightness";
            osdTimer.restart();
        }
    }

    PwObjectTracker {
        id: audioTracker
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

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

    Process {
        id: monitorBrightnessProcess
        command: ["udevadm", "monitor", "--subsystem=backlight"]
        running: !FocusMode.active

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                getBrightnessProcess.running = false;
                getBrightnessProcess.running = true;
            }
        }
    }

    Connections {
        target: FocusMode
        function onActiveChanged(): void {
            root.useFocusTransitionDelay = true;
            delayResetTimer.restart();
            if (!FocusMode.active) {
                getBrightnessProcess.running = false;
                getBrightnessProcess.running = true;
            }
        }
    }

    Process {
        id: setBrightnessProcess
        property string change: ""
        command: ["brightnessctl", "set", change]
    }

    // Widget UI Layout
    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: root.state === "normal" ? 12 : 0

        Behavior on spacing { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

        MouseArea {
            id: volumeArea
            width: root.state === "brightness" ? 0 : volumeLayout.width
            height: root.height
            opacity: root.state === "brightness" ? 0 : 1
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            clip: true

            Behavior on width {
                enabled: root.state === "brightness" || volumeArea.width === 0
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            onClicked: {
                root.toggleMute();
                if (root.isReady) {
                    root.state = "volume";
                    osdTimer.restart();
                }
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    root.adjustVolume(0.02); // 2% increments
                } else if (wheel.angleDelta.y < 0) {
                    root.adjustVolume(-0.02);
                }
                if (root.isReady) {
                    root.state = "volume";
                    osdTimer.restart();
                }
            }

            Row {
                id: volumeLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                MaterialIcon {
                    id: volumeIcon
                    icon: root.muted ? "volume_off" : (root.volume === 0 ? "volume_mute" : (root.volume < 0.5 ? "volume_down" : "volume_up"))
                    color: volumeArea.containsMouse ? Colours.text : Colours.gold
                    opticalSize: Appearance.fontSizeLarge + 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Item {
                    width: root.state === "volume" ? 8 : Appearance.iconTextSpacing
                    height: 1
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                Rectangle {
                    id: volumeProgressBar
                    width: root.state === "volume" ? 120 : 0
                    height: 8
                    radius: 4
                    color: Colours.overlay
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: root.state === "volume" ? 1 : 0

                    Rectangle {
                        id: volumeProgressFill
                        width: parent.width * root.volume
                        height: parent.height
                        radius: parent.radius
                        color: root.muted ? Colours.muted : Colours.iris
                    }

                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Item {
                    width: root.state === "volume" ? 8 : 0
                    height: 1
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                StyledText {
                    text: `${Math.round(root.volume * 100)}%`
                    color: volumeArea.containsMouse ? Colours.text : Colours.iris
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
            width: root.state === "normal" ? 1 : 0
            height: 12
            color: Colours.muted
            opacity: root.state === "normal" ? 0.5 : 0
            anchors.verticalCenter: parent.verticalCenter

            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            id: brightnessArea
            width: root.state === "volume" ? 0 : brightnessLayout.width
            height: root.height
            opacity: root.state === "volume" ? 0 : 1
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            clip: true

            Behavior on width {
                enabled: root.state === "volume" || brightnessArea.width === 0
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    root.adjustBrightness("+5%");
                } else if (wheel.angleDelta.y < 0) {
                    root.adjustBrightness("5%-");
                }
                if (root.isReady) {
                    root.state = "brightness";
                    osdTimer.restart();
                }
            }

            Row {
                id: brightnessLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                MaterialIcon {
                    icon: getBrightnessIcon()
                    color: brightnessArea.containsMouse ? Colours.text : Colours.foam
                    opticalSize: Appearance.fontSizeLarge + 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Item {
                    width: root.state === "brightness" ? 8 : Appearance.iconTextSpacing
                    height: 1
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                Rectangle {
                    id: brightnessProgressBar
                    width: root.state === "brightness" ? 120 : 0
                    height: 8
                    radius: 4
                    color: Colours.overlay
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: root.state === "brightness" ? 1 : 0

                    Rectangle {
                        id: brightnessProgressFill
                        width: parent.width * (root.brightnessPercent / 100.0)
                        height: parent.height
                        radius: parent.radius
                        color: Colours.foam
                    }

                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Item {
                    width: root.state === "brightness" ? 8 : 0
                    height: 1
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                StyledText {
                    text: `${root.brightnessPercent}%`
                    color: brightnessArea.containsMouse ? Colours.text : Colours.foam
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

