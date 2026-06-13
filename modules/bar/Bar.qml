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
                item: clock
                Region { item: workspaces }
                Region { item: keyboardLocale }
                Region { item: nowPlaying }
                Region { item: volumeAndBrightness }
                Region { item: battery }
                Region { item: connectivity }
                Region { item: tray }
            }

            WlrLayershell.layer: WlrLayershell.Top
            WlrLayershell.exclusiveZone: Appearance.exclusiveZone

            Clock {
                id: clock
            }

            Workspaces {
                id: workspaces
            }

            KeyboardLocale {
                id: keyboardLocale
            }

            NowPlaying {
                id: nowPlaying
            }

            VolumeAndBrightness {
                id: volumeAndBrightness
            }

            Battery {
                id: battery
            }

            Connectivity {
                id: connectivity
            }

            Tray {
                id: tray
                window: rootWindow
            }
        }
    }
}
