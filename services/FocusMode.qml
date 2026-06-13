pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool active: false

    IpcHandler {
        target: "focusMode"

        function toggle(): void {
            root.active = !root.active;
        }

        function setActive(value: bool): void {
            root.active = value;
        }

        function getActive(): bool {
            return root.active;
        }
    }

    GlobalShortcut {
        name: "focus-toggle"
        onPressed: {
            root.active = !root.active;
        }
    }
}
