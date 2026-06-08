pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Singleton {
    id: root

    // Window Properties
    readonly property int windowHeight: 160
    readonly property int exclusiveZone: widgetHeight + widgetMarginTop

    // Standard Widget Dimensions & Spacing
    readonly property int widgetHeight: 40
    readonly property int widgetPaddingHorizontal: 24
    readonly property int widgetMarginTop: 8
    readonly property int widgetMarginLeft: 8
    readonly property int widgetMarginRight: 8

    // Island Dimensions (Expanded)
    readonly property int islandWidthExpanded: 340
    readonly property int islandHeightExpanded: 120

    // Corner Radii
    readonly property int maxCornerRadius: 26

    // Animations (Durations in ms)
    readonly property int resizeDuration: 500
    readonly property int textFadeDuration: 150
    readonly property int columnFadeDuration: 200

    // Animation Easing Curves
    readonly property var resizeEasing: [0.38, 1.21, 0.22, 1.0, 1.0, 1.0]
    readonly property var fadeEasing: [0.34, 0.8, 0.34, 1.0, 1.0, 1.0]

    // Typography
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
    readonly property string fontFamilyWorkspaces: "" // Empty string defaults to system default font
    readonly property int fontWeightBold: Font.DemiBold
    readonly property int fontSizeTiny: 10
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeXLarge: 22
    readonly property int fontSizeXXLarge: 28

    // Spacing
    readonly property int columnSpacing: 2
    readonly property int iconTextSpacing: 6
}
