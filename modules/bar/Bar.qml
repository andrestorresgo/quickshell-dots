import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services"

Variants {
    model: Quickshell.screens
    Scope {
        id: scope
        required property ShellScreen modelData

        PanelWindow {
            id: rootWindow
            screen: modelData

            // Anchors & Geometry
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Appearance.windowHeight

            // Window Layer & Mask Settings
            exclusionMode: ExclusionMode.Normal
            color: Colours.transparent
            mask: Region {
                item: island
                Region { item: workspaces }
            }

            WlrLayershell.layer: WlrLayershell.Overlay
            WlrLayershell.exclusiveZone: Appearance.exclusiveZone

            Island {
                id: island
            }

            Workspaces {
                id: workspaces
            }
        }
    }
}
