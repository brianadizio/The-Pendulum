# Colors

The Golden Theme color system is based on two complementary palettes: the **Rainbow Spectrum** for dynamic, nature-inspired colors, and **Metal Colors** for UI chrome and accents.

---

## Rainbow Spectrum

Colors sampled from a continuous rainbow colorbar, each with 12 variants from light (desaturated) to dark (saturated).

### Available Colors

| Color    | Hue  | Description                    |
|----------|------|--------------------------------|
| red      | 0°   | Warm, attention-grabbing       |
| orange   | 25°  | Energetic, autumn tones        |
| gold     | 43°  | Primary accent, solar          |
| yellow   | 55°  | Bright, optimistic             |
| lime     | 80°  | Fresh, spring-like             |
| green    | 120° | Nature, success                |
| teal     | 160° | Cool, professional             |
| cyan     | 180° | Ocean, clarity                 |
| azure    | 210° | Sky, calm                      |
| blue     | 230° | Deep, trustworthy              |
| indigo   | 260° | Rich, mysterious               |
| violet   | 280° | Creative, royal                |
| magenta  | 300° | Vibrant, modern                |
| rose     | 330° | Soft, romantic                 |

### Variant Levels (1-12)

```
Level 1  ████  Lightest, most desaturated (top of colorbar)
Level 3  ████  Light variant
Level 6  ████  Base variant (default)
Level 9  ████  Dark variant
Level 12 ████  Darkest, most saturated (bottom of colorbar)
```

### Usage

```swift
// Get a specific variant
Color.spectrum(.gold, level: 6)      // Base gold
Color.spectrum(.azure, level: 3)     // Light azure

// Convenience accessors
SpectrumColor.gold.light             // Level 3
SpectrumColor.gold.base              // Level 6
SpectrumColor.gold.dark              // Level 9
SpectrumColor.gold.veryDark          // Level 11
```

---

## Metal Colors

Precious metal palette inspired by Italian Renaissance flourishes. Used for UI chrome, buttons, and accents.

### Available Metals

| Metal    | Symbol | Use Case                          |
|----------|--------|-----------------------------------|
| gold     | Au     | Primary actions, solar, abundance |
| silver   | Ag     | Secondary actions, lunar          |
| copper   | Cu     | Data flow, conductivity           |
| bronze   | CuSn   | Foundation, durability            |
| platinum | Pt     | Premium, precision                |
| titanium | Ti     | Lightweight, modern               |
| iron     | Fe     | Text, grounding                   |
| lead     | Pb     | Disabled states                   |

### Variants

Each metal has three variants:

```swift
MetalColor.gold.light    // #FFD700 - Highlights
MetalColor.gold.base     // #DAA520 - Primary use
MetalColor.gold.dark     // #B8860B - Shadows, text
```

### Usage

```swift
// Direct access
Color.metal(.gold)           // Base gold
MetalColor.silver.light      // Light silver

// In views
Text("Hello")
    .foregroundStyle(Color.metal(.gold))
```

---

## Semantic Colors

Context-aware colors that adapt to theme settings.

```swift
@Environment(\.goldenTheme) var theme

// Backgrounds
theme.background          // Primary background
theme.backgroundSecondary // Secondary background
theme.backgroundTertiary  // Cards, containers

// Text
theme.text               // Primary text
theme.textSecondary      // Secondary text
theme.textTertiary       // Labels, captions

// Accents
theme.accent             // Primary accent (gold-based)
theme.accentSecondary    // Secondary accent (seasonal)
```

### Light Mode Defaults
- Background: Cream/parchment (#F8F3E8)
- Text: Near-black (#1A1A1A)
- Accent: Golden amber

### Dark Mode Defaults
- Background: Deep navy (#121217)
- Text: Off-white (#F2F2F7)
- Accent: Bright gold

---

## Gradients

Pre-defined gradients for common use cases:

```swift
// Golden hour (gold → bronze)
GoldenGradients.goldenHour

// Full rainbow spectrum
GoldenGradients.spectrum

// Subtle parchment
GoldenGradients.parchment

// Seasonal gradient
GoldenGradients.seasonal(.autumn)
```

---

## Seasonal Modulation

Colors automatically adjust based on season:

| Season | Effect                                    |
|--------|-------------------------------------------|
| Spring | +10% saturation, green-shifted dominant   |
| Summer | +30% saturation, gold dominant            |
| Autumn | Normal saturation, orange/bronze dominant |
| Winter | -30% saturation, silver/blue dominant     |

```swift
// Set season manually
ThemeManager.shared.season = .autumn
ThemeManager.shared.updateTheme()

// Or sync with system date
ThemeManager.shared.syncWithSystemSeason()
```

---

## Geographic Modulation

Colors adapt to geographic context:

| Location | Temperature Shift | Character           |
|----------|-------------------|---------------------|
| coastal  | -20% (cooler)     | Ocean blues         |
| mountain | 0%                | Clear, high contrast|
| forest   | -10%              | Earth tones         |
| desert   | +30% (warmer)     | Sandy, warm         |
| urban    | 0%                | Neutral, sophisticated|
| arctic   | -40% (coldest)    | Minimal color       |

```swift
ThemeManager.shared.location = .coastal
ThemeManager.shared.updateTheme()
```

---

## Time-of-Day Modulation

Brightness and mode adjust automatically:

| Time      | Brightness | Mode  |
|-----------|------------|-------|
| dawn      | 85%        | Light |
| morning   | 100%       | Light |
| noon      | 110%       | Light |
| afternoon | 100%       | Light |
| dusk      | 90%        | Light |
| evening   | 75%        | Dark  |
| night     | 50%        | Dark  |

```swift
// Sync with system time
ThemeManager.shared.syncWithSystemTime()
```

---

## Color Conversion

For use with SciChart or other frameworks requiring hex/RGB:

```swift
// SwiftUI Color to components
let color = SpectrumColor.gold.base
// Use UIColor for conversion in actual implementation

// Chart theme config provides helpers
let chartConfig = SciChartThemeConfig(isDarkMode: false)
// Access pre-configured chart colors
```

---

## Best Practices

1. **Use semantic colors** (`theme.text`, `theme.accent`) over raw colors when possible
2. **Reserve gold** for primary actions and important elements
3. **Use spectrum colors** for data visualization and variety
4. **Let the theme adapt** - avoid hardcoding colors that fight seasonal shifts
5. **Test in both modes** - ensure readability in light and dark
