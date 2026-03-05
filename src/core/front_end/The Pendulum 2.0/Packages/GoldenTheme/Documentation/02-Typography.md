# Typography

The Golden Theme typography system uses Times New Roman as the primary font family, with sizes scaled by powers of the golden ratio (φ).

---

## Font Family

| Purpose   | Font              | Notes                      |
|-----------|-------------------|----------------------------|
| Primary   | Times New Roman   | Academic, scholarly feel   |
| Monospace | SF Mono           | Code, data, statistics     |
| System    | SF Pro            | Fallback                   |

---

## Type Scale

All sizes derive from a 17pt base, scaled by φ = 1.618:

| Style    | Size    | Formula      | Weight   | Use Case                    |
|----------|---------|--------------|----------|-----------------------------|
| Display  | ~72pt   | base × φ³    | Bold     | Hero headlines, splash      |
| Title    | ~44pt   | base × φ²    | Semibold | Page titles, major sections |
| Headline | ~27pt   | base × φ¹    | Semibold | Section headers, card titles|
| Body     | 17pt    | base × φ⁰    | Regular  | Body text, primary content  |
| Caption  | ~10.5pt | base ÷ φ¹    | Regular  | Captions, helper text       |
| Micro    | ~6.5pt  | base ÷ φ²    | Regular  | Fine print, legal           |

---

## Usage

### Text Styles

```swift
// Using the golden text style modifier
Text("Welcome")
    .font(.golden(.display))

Text("Page Title")
    .font(.golden(.title))

Text("Section Header")
    .font(.golden(.headline))

Text("Body content goes here...")
    .font(.golden(.body))

Text("Helper text")
    .font(.golden(.caption))

Text("Legal fine print")
    .font(.golden(.micro))
```

### Pre-styled Components

```swift
// Convenience text views
DisplayText("Welcome")
TitleText("Page Title")
HeadlineText("Section")
BodyText("Content here...")
CaptionText("Helper text")
```

### Custom Sizing

```swift
// Times New Roman at custom size
Text("Custom")
    .font(.timesNewRoman(size: 24, weight: .semibold))

// Monospace for data
Text("1,234.56")
    .font(.goldenMono(size: 17))
```

---

## Line Height & Spacing

Each style has optimized line height and letter spacing:

| Style    | Line Height | Letter Spacing |
|----------|-------------|----------------|
| Display  | 1.1         | -0.5           |
| Title    | 1.15        | -0.3           |
| Headline | 1.2         | 0              |
| Body     | 1.5         | +0.3           |
| Caption  | 1.3         | +0.2           |
| Micro    | 1.2         | +0.3           |

The body text uses 1.5 line height for academic readability, with slight positive tracking (+0.3) to improve legibility.

---

## Platform Adaptation

Font sizes automatically scale for different devices:

| Platform | Multiplier | Notes                          |
|----------|------------|--------------------------------|
| iPhone   | 1.0×       | Base sizes                     |
| iPad     | 1.15×      | Slightly larger for distance   |
| visionOS | 1.3×       | Larger for spatial viewing     |
| watchOS  | 0.7×       | Smaller for wrist display      |
| macOS    | 0.95×      | Optimized for desktop          |

---

## GoldenText Component

The `GoldenText` component automatically applies theme colors:

```swift
// Basic usage
GoldenText("Hello", style: .body)

// With custom color
GoldenText("Warning", style: .body, color: .red)

// Automatically uses theme.text color
GoldenText("Themed text", style: .headline)
```

---

## Modifier Usage

Apply the golden text modifier to any view:

```swift
Text("Custom text")
    .goldenText(.headline)
```

This applies:
- Correct font and size
- Letter spacing (tracking)
- Line spacing

---

## Monospace for Data

Use monospace font for numerical data, code, or technical readouts:

```swift
// Statistics display
HStack {
    Text("Score:")
        .font(.golden(.body))
    Text("1,234")
        .font(.goldenMono())
}

// Tabular data alignment
Text("00:15:32")
    .font(.goldenMono(size: 24))
```

---

## Accessibility

- All text respects Dynamic Type settings
- Minimum touch targets (44pt) maintained
- High contrast ratios between text and backgrounds
- VoiceOver labels on all text components

---

## Best Practices

1. **Use semantic styles** - Prefer `.headline` over arbitrary sizes
2. **Body for reading** - Long-form content should use body style
3. **Monospace for numbers** - Especially in tables/statistics
4. **Don't fight the scale** - The φ-based sizes are harmonious together
5. **Caption for labels** - Form labels, axis labels, metadata
6. **Display sparingly** - Reserve for splash screens and heroes
