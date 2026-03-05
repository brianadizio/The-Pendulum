# Theming

Golden Theme provides a dynamic theming system that adapts colors based on season, geography, and time of day—creating an experience that reflects Nature based on where you are and when you're using the app.

---

## Overview

The theme system operates at three levels:

1. **Season** - Affects color saturation and dominant hues
2. **Geographic Context** - Affects color temperature
3. **Time of Day** - Affects brightness and light/dark mode

These combine to create a "calm rainbow" that shifts naturally throughout the year.

---

## Theme Manager

The central theme controller:

```swift
// Access the shared manager
let manager = ThemeManager.shared

// Current theme
let theme = manager.currentTheme
```

---

## Configuring the Theme

### Manual Configuration

```swift
// At app launch
GoldenTheme.configure(
    season: .autumn,
    location: .coastal,
    timeOfDay: .afternoon
)
```

### Individual Properties

```swift
ThemeManager.shared.season = .winter
ThemeManager.shared.location = .mountain
ThemeManager.shared.timeOfDay = .evening
ThemeManager.shared.updateTheme()
```

### Auto-Sync with System

```swift
// Sync with device clock
ThemeManager.shared.syncWithSystemTime()

// Sync with calendar date
ThemeManager.shared.syncWithSystemSeason()

// Call both for full auto-sync
func syncTheme() {
    ThemeManager.shared.syncWithSystemTime()
    ThemeManager.shared.syncWithSystemSeason()
}
```

---

## Seasons

| Season | Saturation | Dominant Hue | Character          |
|--------|------------|--------------|---------------------|
| Spring | +10%       | Green        | Fresh, awakening    |
| Summer | +30%       | Gold         | Vibrant, warm       |
| Autumn | Normal     | Orange       | Rich, earthy        |
| Winter | -30%       | Silver/Blue  | Cool, contemplative |

```swift
public enum Season: String, CaseIterable {
    case spring
    case summer
    case autumn
    case winter
}

// Usage
ThemeManager.shared.season = .autumn
```

### Visual Effect

- **Spring**: Colors feel fresh, greens are emphasized
- **Summer**: Peak vibrancy, golden warmth dominates
- **Autumn**: Warm but muted, oranges and browns
- **Winter**: Desaturated, cool, silver tones

---

## Geographic Context

| Location | Temperature | Character              |
|----------|-------------|------------------------|
| Coastal  | -20% cooler | Ocean blues, misty     |
| Mountain | Neutral     | Clear, crisp           |
| Forest   | -10%        | Earthy, green-shifted  |
| Desert   | +30% warmer | Sandy, sun-baked       |
| Urban    | Neutral     | Sophisticated, neutral |
| Arctic   | -40% cooler | Minimal color, white   |

```swift
public enum GeographicContext: String, CaseIterable {
    case coastal
    case mountain
    case forest
    case desert
    case urban
    case arctic
}

// Usage
ThemeManager.shared.location = .coastal
```

### Use Cases

- **coastal**: Beach apps, ocean themes
- **mountain**: Hiking, altitude training
- **forest**: Nature walks, meditation
- **desert**: Hot climate users
- **urban**: City-focused users
- **arctic**: Winter sports, cold regions

---

## Time of Day

| Time      | Brightness | Mode  | Character           |
|-----------|------------|-------|---------------------|
| Dawn      | 85%        | Light | Soft pinks, gentle  |
| Morning   | 100%       | Light | Clear, productive   |
| Noon      | 110%       | Light | Bright, energetic   |
| Afternoon | 100%       | Light | Golden hour ahead   |
| Dusk      | 90%        | Light | Rich oranges/purples|
| Evening   | 75%        | Dark  | Warm lights, cozy   |
| Night     | 50%        | Dark  | Deep, restful       |

```swift
public enum TimeOfDay: String, CaseIterable {
    case dawn
    case morning
    case noon
    case afternoon
    case dusk
    case evening
    case night
}

// Check if dark mode
timeOfDay.prefersDarkMode // true for evening, night
```

---

## Accessing Theme Values

### In Views

```swift
struct MyView: View {
    @Environment(\.goldenTheme) var theme

    var body: some View {
        Text("Hello")
            .foregroundStyle(theme.text)
            .background(theme.background)
    }
}
```

### Available Properties

```swift
// Backgrounds
theme.background          // Primary
theme.backgroundSecondary // Cards, groups
theme.backgroundTertiary  // Inputs, highlights

// Text
theme.text               // Primary text
theme.textSecondary      // Secondary text
theme.textTertiary       // Captions, labels

// Accents
theme.accent             // Primary (gold-based)
theme.accentSecondary    // Seasonal variation

// Metadata
theme.name               // "Summer Morning"
theme.isDarkMode         // true/false
```

---

## Injecting Theme

Apply to view hierarchy:

```swift
MyAppView()
    .withGoldenTheme()

// Or with specific theme
MyAppView()
    .withGoldenTheme(.autumnDusk)
```

---

## Preset Themes

Pre-configured theme combinations:

```swift
ThemeConfiguration.parchment      // Light, summer morning
ThemeConfiguration.navyNight      // Dark, winter night
ThemeConfiguration.springMorning  // Spring, morning
ThemeConfiguration.summerNoon     // Summer, noon
ThemeConfiguration.autumnDusk     // Autumn, dusk
ThemeConfiguration.winterEvening  // Winter, evening
```

---

## Creating Custom Themes

```swift
let customTheme = ThemeConfiguration(
    name: "Desert Sunset",
    season: .summer,
    location: .desert,
    timeOfDay: .dusk
)

// Apply
ContentView()
    .withGoldenTheme(customTheme)
```

---

## Reactive Updates

Components automatically update when theme changes:

```swift
// Theme change notification (if needed)
struct ThemeAwareView: View {
    @Environment(\.goldenTheme) var theme

    var body: some View {
        // Automatically re-renders when theme changes
        Rectangle()
            .fill(theme.accent)
    }
}
```

---

## User Preferences

Let users override automatic theming:

```swift
@AppStorage("useAutoTheme") var useAutoTheme = true
@AppStorage("manualSeason") var manualSeason = Season.summer.rawValue
@AppStorage("manualTimeOfDay") var manualTimeOfDay = TimeOfDay.morning.rawValue

func applyTheme() {
    if useAutoTheme {
        ThemeManager.shared.syncWithSystemTime()
        ThemeManager.shared.syncWithSystemSeason()
    } else {
        ThemeManager.shared.season = Season(rawValue: manualSeason) ?? .summer
        ThemeManager.shared.timeOfDay = TimeOfDay(rawValue: manualTimeOfDay) ?? .morning
    }
    ThemeManager.shared.updateTheme()
}
```

---

## Settings UI for Theme

```swift
SettingsSection(title: "Appearance", items: [
    .toggle(title: "Auto Theme", subtitle: "Adjust to time and season", binding: $useAutoTheme),
    .navigation(title: "Season", subtitle: currentSeason.rawValue.capitalized) {
        showSeasonPicker = true
    },
    .navigation(title: "Time Style", subtitle: currentTimeOfDay.rawValue.capitalized) {
        showTimePicker = true
    }
])
```

---

## Theme in Charts

Apply theme to SciChart:

```swift
let chartConfig = SciChartThemeConfig(isDarkMode: theme.isDarkMode)

// Use chartConfig.backgroundColor, etc.
```

---

## Best Practices

1. **Use semantic colors** - `theme.text` instead of hardcoded colors
2. **Let it adapt** - Default to auto-theming for nature feel
3. **Test combinations** - Verify readability across seasons/times
4. **Respect user preference** - Allow manual override
5. **Sync at app launch** - Call sync methods in `init()`
6. **Update on foreground** - Re-sync when app becomes active

---

## Implementation Example

```swift
@main
struct MySolutionApp: App {
    init() {
        // Auto-sync theme on launch
        Task { @MainActor in
            ThemeManager.shared.syncWithSystemTime()
            ThemeManager.shared.syncWithSystemSeason()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withGoldenTheme()
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification
                )) { _ in
                    // Re-sync when returning to app
                    ThemeManager.shared.syncWithSystemTime()
                }
        }
    }
}
```

---

## The Vision

The goal is for the app to feel like it's reflecting the day you'd see in Nature:

- **Winter morning at the coast**: Cool, desaturated blues with silver accents
- **Summer noon in the desert**: Warm, vibrant golds with high saturation
- **Autumn dusk in the forest**: Rich oranges and browns, slightly dim
- **Spring evening in the city**: Fresh greens shifting to cozy warm lights

This creates a "calm rainbow" that changes naturally, making the app feel alive and connected to the world around you.
