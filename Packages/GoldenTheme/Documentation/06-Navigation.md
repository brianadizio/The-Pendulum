# Navigation

Golden Theme uses a standard 5-tab navigation pattern for all Solutions, with support for topological knot icons and consistent sub-page navigation.

---

## Standard Tab Structure

Every Solution app follows this 5-tab structure:

| Tab         | Purpose                              | Icon Concept      |
|-------------|--------------------------------------|-------------------|
| Play/Use    | Main interaction area                | Torus (loop)      |
| Modes       | Algorithm/mode selection             | Hopf link         |
| Dashboard   | Analytics and statistics             | Trefoil knot      |
| Integration | Connection to other Solutions        | Figure-8 knot     |
| Settings    | App configuration                    | Solomon's knot    |

---

## GoldenTabBar

The tab bar component:

```swift
@State private var selectedTab: GoldenTab = .playUse

GoldenTabBar(selectedTab: $selectedTab)
```

**Appearance:**
- Horizontal layout
- Icon + label for each tab
- Accent color for selected tab
- Secondary background
- Top shadow

---

## GoldenTabView

Complete tab container with content:

```swift
@State private var selectedTab: GoldenTab = .playUse

GoldenTabView(selectedTab: $selectedTab) { tab in
    switch tab {
    case .playUse:
        PlayView()
    case .modes:
        ModesView()
    case .dashboard:
        DashboardView()
    case .integration:
        IntegrationView()
    case .settings:
        SettingsView()
    }
}
```

---

## Custom Tab Labels

Customize labels for your Solution:

```swift
let customTabs = AppTabConfigs(
    playUseLabel: "Simulation",  // Instead of "Play/Use"
    modesLabel: "Algorithms",    // Instead of "Modes"
    dashboardLabel: "Analytics", // Instead of "Dashboard"
    integrationLabel: "Connect", // Instead of "Integration"
    settingsLabel: "Settings"    // Keep default
)

GoldenTabView(selectedTab: $selectedTab, tabs: customTabs.all) { tab in
    // ...
}
```

---

## Custom Tab Icons

Provide custom images for tabs:

```swift
let customTabs = [
    TabConfiguration(.playUse, label: "Play", image: Image("torus-icon")),
    TabConfiguration(.modes, label: "Modes", image: Image("hopf-link-icon")),
    // ...
]

GoldenTabBar(selectedTab: $selectedTab, tabs: customTabs)
```

---

## Navigation Header

Standard page header with logo and title:

```swift
GoldenNavigationHeader("The Maze", logo: Image("maze-logo"))

// Without logo
GoldenNavigationHeader("Settings")

// With back button
GoldenNavigationHeader(
    "Sounds",
    showBackButton: true,
    backAction: { dismiss() }
)
```

**Appearance:**
- Logo image (optional, 44×44)
- Title in large font
- Back chevron (optional)
- Primary background

---

## Sub-Page Navigation

For settings sub-views and detail pages:

```swift
GoldenSubPageView("Sound Settings", onBack: { path.removeLast() }) {
    VStack {
        GoldenToggleRow("Enable Sounds", isOn: $soundsEnabled)
        GoldenSlider("Volume", value: $volume, in: 0...1)
    }
}
```

**Features:**
- Back button in header
- Title displayed
- Scrollable content area
- Consistent styling

---

## Navigation State

For complex navigation, use a state object:

```swift
@Observable
class AppNavigationState {
    var selectedTab: GoldenTab = .playUse
    var settingsPath: [SettingsDestination] = []

    enum SettingsDestination: Hashable {
        case backgrounds
        case sounds
        case haptics
        case account
    }
}

// In your view
@State private var navState = AppNavigationState()

NavigationStack(path: $navState.settingsPath) {
    SettingsView()
        .navigationDestination(for: AppNavigationState.SettingsDestination.self) { dest in
            switch dest {
            case .backgrounds: BackgroundsView()
            case .sounds: SoundsView()
            // ...
            }
        }
}
```

---

## Deep Linking

Tab enum supports deep linking:

```swift
// Each tab has a raw value for URL construction
let url = URL(string: "goldenenterprises://maze/\(GoldenTab.dashboard.rawValue)")

// Handle incoming URL
func handleDeepLink(_ url: URL) {
    if let tabIndex = Int(url.lastPathComponent),
       let tab = GoldenTab(rawValue: tabIndex) {
        selectedTab = tab
    }
}
```

---

## Tab Accessibility

Each tab includes:

```swift
.accessibilityLabel(config.label)
.accessibilityHint(config.tab.accessibilityLabel)
.accessibilityAddTraits(isSelected ? .isSelected : [])
```

Default accessibility hints:
- Play/Use: "Play or use the main feature"
- Modes: "Select modes and algorithms"
- Dashboard: "View analytics dashboard"
- Integration: "Connect with other solutions"
- Settings: "App settings"

---

## Haptic Feedback

Tab selection triggers selection haptic automatically.

---

## Complete Example

```swift
struct MazeApp: App {
    var body: some Scene {
        WindowGroup {
            MazeRootView()
        }
    }
}

struct MazeRootView: View {
    @State private var selectedTab: GoldenTab = .playUse

    let tabs = AppTabConfigs(
        playUseLabel: "The Maze",
        modesLabel: "Maze Modes",
        dashboardLabel: "Stats"
    )

    var body: some View {
        GoldenTabView(selectedTab: $selectedTab, tabs: tabs.all) { tab in
            switch tab {
            case .playUse:
                NavigationStack {
                    MazeGameView()
                }
            case .modes:
                NavigationStack {
                    MazeModesView()
                }
            case .dashboard:
                NavigationStack {
                    MazeDashboardView()
                }
            case .integration:
                NavigationStack {
                    IntegrationView()
                }
            case .settings:
                NavigationStack {
                    MazeSettingsView()
                }
            }
        }
        .withGoldenTheme()
    }
}
```

---

## Best Practices

1. **Keep 5 tabs** - Consistency across all Solutions
2. **Customize labels** - Make them specific to your Solution
3. **Use custom icons** - Topological knots when available
4. **NavigationStack per tab** - Each tab manages its own navigation
5. **Sub-pages for depth** - Settings → Sounds → Sound Pack
6. **Max 2-3 levels** - Don't go too deep in navigation
7. **Back button always visible** - Users need escape routes
