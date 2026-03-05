# Golden Theme Documentation

## Overview

Golden Theme is a Swift Package design system created for Golden Enterprises Solutions. It provides a unified visual language for 50+ interconnected mathematical applications ("Solutions"), ensuring consistency while allowing per-app variation based on seasonal, geographic, and temporal context.

---

## Philosophy

### Topological Foundation
Every UI element is conceptualized as a **section of a sheaf** over the application's state space. Transitions between states are morphisms that preserve structure. This mathematical grounding ensures the UI behaves coherently and predictably.

### The Golden Ratio (φ)
All proportions in the system follow φ = 1.618033988749895:
- Typography scales by powers of φ
- Spacing follows φ-based increments
- Component proportions use golden rectangles
- Animation timing relates to φ

### Design Principles

1. **Text-Only Buttons** - Clean, readable interfaces without icon clutter
2. **Academic Aesthetic** - Times New Roman typography for scholarly feel
3. **Nature-Inspired Colors** - Rainbow spectrum that shifts with seasons
4. **Metal Accents** - Gold, silver, bronze for precious, Renaissance flourishes
5. **Calm Vibrancy** - A "calm rainbow" that's soothing yet colorful

---

## Architecture

### Three-Tier System

```
┌─────────────────────────────────────────────────────────┐
│                    Golden Suite                          │
│         (Premium integration app, 7-circle nav)          │
├─────────────────────────────────────────────────────────┤
│     Individual Apps (The Maze, The Pendulum, etc.)      │
│              Each imports golden-theme                   │
├─────────────────────────────────────────────────────────┤
│                   golden-theme                           │
│        (Swift Package - shared design system)            │
└─────────────────────────────────────────────────────────┘
```

### Package Structure

```
golden-theme/
├── Package.swift                 # Swift Package manifest
├── README.md                     # Quick start guide
├── Documentation/                # This documentation
└── Sources/GoldenTheme/
    ├── GoldenTheme.swift         # Core entry point
    ├── Exports.swift             # Public API
    ├── Colors/                   # Color system
    ├── Typography/               # Font system
    ├── Geometry/                 # Spacing & proportions
    ├── Components/               # UI components
    ├── Managers/                 # Haptics, sounds
    ├── Extensions/               # SciChart, etc.
    └── Templates/                # App scaffolds
```

---

## Quick Start

### Installation

Add to your Xcode project:
1. File → Add Package Dependencies
2. Click "Add Local..."
3. Navigate to `golden-theme` folder
4. Click "Add Package"

Or in Package.swift:
```swift
dependencies: [
    .package(path: "../golden-theme")
]
```

### Minimal App

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

This creates a complete 5-tab app with placeholder content.

---

## Documentation Index

1. **[Colors](01-Colors.md)** - Spectrum colors, metal palette, seasonal modulation
2. **[Typography](02-Typography.md)** - Times New Roman, φ-scaled text styles
3. **[Geometry](03-Geometry.md)** - Spacing, proportions, layout helpers
4. **[Buttons](04-Buttons.md)** - Primary, secondary, settings buttons
5. **[Inputs](05-Inputs.md)** - Text fields, sliders, pickers
6. **[Navigation](06-Navigation.md)** - Tab bar, headers, sub-pages
7. **[Cards](07-Cards.md)** - Statistics, metrics, info cards
8. **[Loading](08-Loading.md)** - Shimmer effects, spinners, video loading
9. **[Chat](09-Chat.md)** - AI assistant component
10. **[Charts](10-Charts.md)** - SciChart integration
11. **[Templates](11-Templates.md)** - Settings view, app scaffold
12. **[Theming](12-Theming.md)** - Seasonal, geographic, time-based adaptation

---

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 17.0           |
| macOS    | 14.0           |
| visionOS | 1.0            |
| watchOS  | 10.0           |

---

## Key Constants

```swift
// The golden ratio
GoldenTheme.phi = 1.618033988749895

// Base unit for spacing (8pt grid)
GoldenTheme.baseUnit = 8

// Base font size
GoldenTheme.baseFontSize = 17

// Seven-fold symmetry (for Suite navigation)
GoldenTheme.sevenFoldAngle = 51.428571°
```
