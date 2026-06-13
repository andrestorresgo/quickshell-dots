pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Singleton {
    id: root

    // Window Properties
    readonly property int windowHeight: 160
    readonly property int exclusiveZone: widgetHeight + widgetMarginTop + widgetMarginBottom

    // Standard Widget Dimensions & Spacing
    readonly property int widgetHeight: 36
    readonly property int widgetPaddingHorizontal: 32
    readonly property int widgetMarginTop: 12
    readonly property int widgetMarginBottom: 6
    readonly property int widgetMarginLeft: 6
    readonly property int widgetMarginRight: 6

    // Clock Dimensions (Expanded)
    readonly property int clockWidthExpanded: 340
    readonly property int clockHeightExpanded: 120

    // Corner Radii
    readonly property int maxCornerRadius: 26
    readonly property int widgetCornerRadius: widgetHeight / 2

    // Animations (Durations in ms)
    readonly property int resizeDuration: 500
    readonly property int textFadeDuration: 150
    readonly property int columnFadeDuration: 200
    readonly property int osdTimer: 1000

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
    readonly property int fontSizeMediumLarge: 16
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeXLarge: 22
    readonly property int fontSizeXXLarge: 28

    // Spacing
    readonly property int columnSpacing: 6
    readonly property int iconTextSpacing: 8
}
