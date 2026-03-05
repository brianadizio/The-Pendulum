# Templates

Golden Theme provides complete templates for rapidly building new Solutions with consistent structure and styling.

---

## App Template

The `GoldenAppRoot` template provides a complete 5-tab app scaffold.

### Quick Start

```swift
import SwiftUI
import GoldenTheme

@main
struct MySolutionApp: App {
    var body: some Scene {
        WindowGroup {
            GoldenAppQuickStart.minimalApp(name: "My Solution")
                .withGoldenTheme()
        }
    }
}
```

This creates a working app with:
- 5 tabs with placeholder content
- Loading animation on launch
- AI chat button
- Proper theming

---

### Full Configuration

```swift
@main
struct ThePendulumApp: App {
    init() {
        // Configure theme
        GoldenTheme.configure(
            season: .summer,
            location: .coastal,
            timeOfDay: .morning
        )
    }

    var body: some Scene {
        WindowGroup {
            PendulumRootView()
                .withGoldenTheme()
        }
    }
}

struct PendulumRootView: View {
    var body: some View {
        GoldenAppRoot(
            config: GoldenAppConfig(
                name: "The Pendulum",
                shortName: "Pendulum",
                version: "1.0.0",
                logo: Image("pendulum-logo"),
                loadingVideo: "pendulum_morph",
                primaryColor: .azure  // Solution-specific accent
            ),
            tabs: AppTabConfigs(
                playUseLabel: "Simulation",
                modesLabel: "Parameters",
                dashboardLabel: "Analytics"
            ),
            playUse: { SimulationView() },
            modes: { ParametersView() },
            dashboard: { AnalyticsView() },
            integration: { IntegrationView() },
            settings: { SettingsView() }
        )
    }
}
```

---

## App Configuration

```swift
GoldenAppConfig(
    name: String,           // Full app name
    shortName: String?,     // Tab bar, loading message
    version: String,        // Shown in settings
    logo: Image?,           // Header logo
    loadingVideo: String?,  // Bundle video name
    primaryColor: SpectrumColor  // Accent variation
)
```

---

## Tab Configurations

Customize tab labels:

```swift
AppTabConfigs(
    playUseLabel: "Game",       // Default: "Play/Use"
    modesLabel: "Levels",       // Default: "Modes"
    dashboardLabel: "Stats",    // Default: "Dashboard"
    integrationLabel: "Share",  // Default: "Integration"
    settingsLabel: "Options"    // Default: "Settings"
)
```

---

## View Templates

### Play/Use View Template

```swift
PlayUseViewTemplate(appName: "The Maze", logo: Image("maze-logo")) {
    // Your main content
    MazeGameView()
}
```

### Modes View Template

```swift
ModesViewTemplate(title: "Game Modes") {
    GoldenGrid(columns: 2) {
        ForEach(modes) { mode in
            GridCard(title: mode.name, image: mode.thumbnail) {
                selectMode(mode)
            }
        }
    }
}
```

### Dashboard View Template

```swift
DashboardViewTemplate(
    title: "Analytics",
    metrics: [
        MetricRowCard(title: "Sessions", value: "47"),
        MetricRowCard(title: "Best Time", value: "2:34"),
        MetricRowCard(title: "Accuracy", value: "94%")
    ],
    timeRange: $selectedTimeRange
)
```

### Integration View Template

```swift
IntegrationViewTemplate(
    solutions: [
        (name: "The Pendulum", icon: Image("pendulum"), isConnected: true, action: { }),
        (name: "The Spiral", icon: Image("spiral"), isConnected: false, action: { })
    ],
    external: [
        (name: "Apple Health", icon: Image(systemName: "heart"), action: { }),
        (name: "iCloud Sync", icon: Image(systemName: "cloud"), action: { })
    ]
)
```

---

## Settings Template

Complete settings view with standard sections:

```swift
GoldenSettingsView(
    title: "Settings",
    logo: Image("maze-logo"),
    sections: [
        // Experience section
        StandardSettingsSections.experience(
            backgroundsAction: { showBackgrounds = true },
            soundsEnabled: $soundsEnabled,
            hapticsEnabled: $hapticsEnabled
        ),

        // Custom section
        SettingsSection(title: "Gameplay", items: [
            .navigation(title: "Difficulty", subtitle: "Easy") { showDifficulty = true },
            .toggle(title: "Auto-save", subtitle: nil, binding: $autoSave),
            .value(title: "High Score", value: "1,234", action: nil)
        ]),

        // Data section
        StandardSettingsSections.data(
            exportAction: { export() },
            importAction: { import() },
            resetAction: { showResetAlert = true }
        ),

        // Account section
        StandardSettingsSections.account(
            signedIn: isSignedIn,
            userName: userName,
            signInAction: { signIn() },
            signOutAction: { signOut() }
        ),

        // About section
        StandardSettingsSections.about(
            version: "1.0.0",
            privacyAction: { openPrivacy() },
            supportAction: { openSupport() }
        )
    ],
    footer: "Made with ♥ by Golden Enterprises"
)
```

---

## Standard Settings Sections

Pre-built sections for common settings:

### Experience

```swift
StandardSettingsSections.experience(
    backgroundsAction: () -> Void,
    soundsEnabled: Binding<Bool>,
    hapticsEnabled: Binding<Bool>
)
```

### Data

```swift
StandardSettingsSections.data(
    exportAction: () -> Void,
    importAction: () -> Void,
    resetAction: () -> Void
)
```

### Account

```swift
StandardSettingsSections.account(
    signedIn: Bool,
    userName: String?,
    signInAction: () -> Void,
    signOutAction: () -> Void
)
```

### About

```swift
StandardSettingsSections.about(
    version: String,
    privacyAction: () -> Void,
    supportAction: () -> Void
)
```

---

## Custom Settings Sections

Create custom sections:

```swift
SettingsSection(
    title: "Custom Section",
    items: [
        .navigation(title: "Title", subtitle: "Subtitle") { /* action */ },
        .toggle(title: "Toggle", subtitle: nil, binding: $value),
        .value(title: "Display Only", value: "Value", action: nil),
        .destructive(title: "Dangerous Action") { /* action */ }
    ]
)
```

### Item Types

| Type        | Parameters                               |
|-------------|------------------------------------------|
| navigation  | title, subtitle?, action                 |
| toggle      | title, subtitle?, binding                |
| value       | title, value, action? (nil = display only)|
| destructive | title, action                            |

---

## Placeholder View

For tabs in development:

```swift
PlaceholderView(
    title: "Coming Soon",
    message: "This feature is under development"
)
```

---

## Complete New Solution Checklist

1. **Create Xcode project**
2. **Add GoldenTheme package**
3. **Create root view with GoldenAppRoot**
4. **Configure app settings (name, logo, etc.)**
5. **Implement Play/Use view** (main functionality)
6. **Implement Modes view** (if applicable)
7. **Implement Dashboard view** (analytics)
8. **Configure Integration connections**
9. **Customize Settings sections**
10. **Add loading video** (optional)
11. **Configure AI chat** (optional)

---

## Best Practices

1. **Use templates** - Don't rebuild the scaffold
2. **Standard sections first** - Use pre-built settings sections
3. **Customize labels** - Make tabs specific to your Solution
4. **Placeholder early** - Ship with placeholder for future features
5. **Loading video per-app** - Each Solution gets its own logo morph
6. **Version in settings** - Always show current version
