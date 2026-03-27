# Golden Theme

A topologically-grounded design system for Golden Enterprises Solutions.

## Overview

Golden Theme is a Swift Package that provides a consistent, beautiful design language for 50+ interconnected mathematical applications. Every UI element is conceptualized as a section of a sheaf over application state space, with all proportions following φ (the golden ratio).

## Features

- **Seasonal/Geographic Color Modulation**: Colors adapt based on season, location, and time of day
- **Phi-based Typography**: Times New Roman with golden ratio scaling
- **Text-only Buttons**: Clean, simple interface without icons
- **5-Tab Navigation**: Standard navigation with topological knot icons
- **AI Chat Assistant**: Built-in chat component for app guidance
- **SciChart Integration**: Styling helpers for beautiful data visualization
- **Loading Animations**: Shimmer effects and logo video support
- **Complete Settings Template**: Grouped button settings views

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../golden-theme")
]
```

Or add via Xcode: File → Add Package Dependencies → Add Local

## Quick Start

### 1. Minimal App Setup

```swift
import SwiftUI
import GoldenTheme

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            GoldenAppQuickStart.minimalApp(name: "My Solution")
                .withGoldenTheme()
        }
    }
}
```

### 2. Full App Setup

```swift
import SwiftUI
import GoldenTheme

@main
struct MySolutionApp: App {
    init() {
        // Configure theme based on context
        GoldenTheme.configure(
            season: .summer,
            location: .coastal,
            timeOfDay: .morning
        )
    }

    var body: some Scene {
        WindowGroup {
            GoldenAppRoot(
                config: GoldenAppConfig(
                    name: "My Solution",
                    version: "1.0.0",
                    loadingVideo: "logo_morph"
                ),
                playUse: { MyPlayView() },
                modes: { MyModesView() },
                dashboard: { MyDashboardView() },
                integration: { MyIntegrationView() },
                settings: { MySettingsView() }
            )
            .withGoldenTheme()
        }
    }
}
```

## Core Components

### Colors

```swift
// Spectrum colors (rainbow palette)
Color.spectrum(.gold, level: 6)
Color.spectrum(.azure, level: 3)

// Metal colors (for accents/chrome)
Color.metal(.gold)
Color.metal(.silver)

// Semantic colors via theme
@Environment(\.goldenTheme) var theme
theme.accent
theme.text
theme.background
```

### Typography

```swift
// Phi-scaled text styles
Text("Title").font(.golden(.title))
Text("Body").font(.golden(.body))
Text("Caption").font(.golden(.caption))

// Direct Times New Roman
Text("Custom").font(.timesNewRoman(size: 20, weight: .semibold))
```

### Buttons

```swift
// Primary action (gold background)
GoldenPrimaryButton("Continue") {
    // action
}

// Secondary action (outlined)
GoldenSecondaryButton("Cancel") {
    // action
}

// Settings row (for lists)
GoldenSettingsButton("Sounds", subtitle: "Enable audio feedback") {
    // navigate
}

// Toggle row
GoldenToggleRow("Haptics", isOn: $hapticsEnabled)
```

### Settings View

```swift
GoldenSettingsView(
    title: "Settings",
    sections: [
        StandardSettingsSections.experience(
            backgroundsAction: { /* ... */ },
            soundsEnabled: $sounds,
            hapticsEnabled: $haptics
        ),
        StandardSettingsSections.data(
            exportAction: { /* ... */ },
            importAction: { /* ... */ },
            resetAction: { /* ... */ }
        ),
        StandardSettingsSections.about(
            version: "1.0.0",
            privacyAction: { /* ... */ },
            supportAction: { /* ... */ }
        )
    ],
    footer: "Made with love by Golden Enterprises"
)
```

### Charts (SciChart)

```swift
GoldenChartContainer(title: "Phase Space", subtitle: "Last 24 hours") {
    // Your SciChart view here
}

// Use chart colors
GoldenChartColors.series[0] // Primary series color
GoldenChartColors.heatmapGradient // For heatmaps

// Theme config for SciChart
let config = SciChartThemeConfig(isDarkMode: false)
```

### AI Chat

```swift
@State private var showChat = false
@StateObject private var chatVM = SampleChatViewModel()

MyView()
    .goldenChatSheet(
        isPresented: $showChat,
        viewModel: chatVM,
        title: "Assistant",
        welcomeMessage: "How can I help?"
    )
```

### Loading States

```swift
// Shimmer text (Claude-style)
ShimmerText("Processing...", isLoading: true)

// Full overlay with video
GoldenLoadingOverlay(
    isVisible: isLoading,
    message: "Loading...",
    videoName: "logo_morph"
)

// Simple spinner
GoldenSpinner()
```

## Customization

### Seasonal Themes

The color system automatically adjusts based on season:
- **Spring**: Fresh greens, increased saturation
- **Summer**: Warm golds, high vibrancy
- **Autumn**: Orange/bronze tones
- **Winter**: Cool, desaturated silvers

```swift
ThemeManager.shared.season = .autumn
ThemeManager.shared.updateTheme()
```

### Geographic Context

Colors adapt to geographic context:
- Coastal: Cool blues
- Mountain: High contrast
- Forest: Earth tones
- Desert: Warm, sandy
- Urban: Neutral
- Arctic: Minimal color

### Time of Day

Automatic light/dark mode based on time:
- Dawn through Afternoon: Light mode
- Evening and Night: Dark mode

```swift
// Auto-sync with system
ThemeManager.shared.syncWithSystemTime()
ThemeManager.shared.syncWithSystemSeason()
```

## File Structure

```
GoldenTheme/
├── GoldenTheme.swift          # Core constants and entry point
├── Exports.swift              # Public API exports
├── Colors/
│   ├── GoldenColors.swift     # Color palette
│   └── ThemeConfiguration.swift
├── Typography/
│   └── GoldenTypography.swift
├── Geometry/
│   └── GoldenGeometry.swift
├── Components/
│   ├── Buttons/
│   ├── Inputs/
│   ├── Navigation/
│   ├── Cards/
│   ├── Chat/
│   └── Loading/
├── Managers/
│   ├── HapticManager.swift
│   └── SoundManager.swift
├── Extensions/
│   └── SciChartStyling.swift
└── Templates/
    ├── SettingsTemplate.swift
    └── AppTemplate.swift
```

## Design Principles

1. **φ-based Proportions**: All spacing, sizing, and typography follows golden ratio
2. **Text-only Buttons**: Clean interface without icons
3. **Metal Colors**: Precious metal palette for accents (gold, silver, bronze)
4. **Seasonal Adaptation**: Colors shift with seasons/geography/time
5. **Sheaf Topology**: UI forms coherent sections over state space
6. **Haptic + Sound**: Every interaction has tactile/audio feedback

## Requirements

- iOS 17.0+
- macOS 14.0+
- visionOS 1.0+
- watchOS 10.0+
- Swift 5.9+

## License

Copyright © 2026 Golden Enterprises Solutions Inc. All rights reserved.
