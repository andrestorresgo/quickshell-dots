pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Singleton {
    id: root

    // Window Properties
    readonly property int windowHeight: 160
    readonly property int exclusiveZone: 42

    // Island Dimensions (Collapsed)
    readonly property int islandWidthCollapsed: 100
    readonly property int islandHeightCollapsed: 34

    // Island Dimensions (Expanded)
    readonly property int islandWidthExpanded: 340
    readonly property int islandHeightExpanded: 120

    // Margins & Radii
    readonly property int islandMarginTop: 8
    readonly property int maxCornerRadius: 26
    readonly property int leftMargin: 8

    // Animations (Durations in ms)
    readonly property int resizeDuration: 500
    readonly property int textFadeDuration: 150
    readonly property int columnFadeDuration: 200

    // Animation Easing Curves
    readonly property var resizeEasing: [0.38, 1.21, 0.22, 1.0, 1.0, 1.0]
    readonly property var fadeEasing: [0.34, 0.8, 0.34, 1.0, 1.0, 1.0]

    // Typography
    readonly property int fontWeightBold: Font.DemiBold
    readonly property int fontSizeSmall: 13
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 26

    // Spacing
    readonly property int columnSpacing: 2
    readonly property int iconTextSpacing: 6
}
