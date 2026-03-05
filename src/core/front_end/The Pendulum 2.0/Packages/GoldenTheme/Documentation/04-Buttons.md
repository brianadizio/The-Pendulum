# Buttons

Golden Theme buttons are **text-only** by design—no icons, just clean typography. This creates a calm, readable interface that lets your data and transformations speak for themselves.

---

## Button Types

| Type        | Use Case                              | Appearance           |
|-------------|---------------------------------------|----------------------|
| Primary     | Main actions                          | Gold background      |
| Secondary   | Alternative actions                   | Outlined             |
| Text        | Minimal actions                       | Text only            |
| Settings    | List rows with navigation             | Full-width row       |
| Toggle      | On/off settings                       | Row with switch      |
| Destructive | Dangerous actions                     | Red text             |

---

## Primary Button

Main call-to-action with gold gradient background:

```swift
GoldenPrimaryButton("Continue") {
    // Handle tap
}
```

**Appearance:**
- Gold gradient background (light → base)
- Bronze dark text
- 44pt height
- Full width in container
- Rounded corners (12pt)

**States:**
- Default: Gold gradient
- Pressed: Scale down to 97%, slight opacity
- Disabled: Lead gray, muted text

---

## Secondary Button

Alternative action with outline style:

```swift
GoldenSecondaryButton("Cancel") {
    // Handle tap
}
```

**Appearance:**
- Transparent background
- Gold outline (1.5pt)
- Gold text
- 44pt height

---

## Text Button

Minimal button for low-emphasis actions:

```swift
GoldenTextButton("Learn More") {
    // Handle tap
}
```

**Appearance:**
- No background or border
- Accent-colored text
- Padding for touch target

---

## Settings Button

Navigation row for settings lists:

```swift
GoldenSettingsButton("Sounds", subtitle: "Enable audio feedback") {
    // Navigate to sounds settings
}

// Without subtitle
GoldenSettingsButton("Privacy Policy") {
    // Open privacy policy
}

// Without disclosure arrow
GoldenSettingsButton("Version", subtitle: nil, showDisclosure: false) {
    // No navigation
}
```

**Appearance:**
- Full-width with horizontal padding
- Primary text + optional secondary subtitle
- Chevron right indicator (optional)
- Background matches tertiary theme color

---

## Toggle Row

Settings row with switch control:

```swift
@State private var hapticsEnabled = true

GoldenToggleRow(
    "Haptics",
    subtitle: "Enable haptic feedback",
    isOn: $hapticsEnabled
)
```

**Appearance:**
- Same layout as settings button
- Toggle switch on right side
- Tint matches accent color
- Haptic feedback on toggle

---

## Destructive Button

For dangerous actions like delete or reset:

```swift
GoldenDestructiveButton("Delete All Data") {
    // Show confirmation
}
```

**Appearance:**
- Centered red text
- Heavy haptic on tap
- No background

---

## Button Groups

Group multiple settings buttons with rounded corners:

```swift
GoldenButtonGroup {
    GoldenSettingsButton("Backgrounds") { /* ... */ }
    GoldenSettingsButton("Sounds") { /* ... */ }
    GoldenSettingsButton("Haptics") { /* ... */ }
}
```

**Appearance:**
- Buttons stacked vertically
- 1px dividers between buttons
- Rounded corners on group container
- Subtle border around group

---

## Section Headers

Label for groups of settings:

```swift
GoldenSectionHeader("Experience")

GoldenButtonGroup {
    // Buttons...
}
```

**Appearance:**
- Uppercase text
- Caption size with letter spacing
- Secondary text color
- Generous top padding, tight bottom padding

---

## Haptic Feedback

All buttons automatically trigger haptic feedback:

| Button Type  | Haptic     |
|--------------|------------|
| Primary      | Medium     |
| Secondary    | Light      |
| Text         | Selection  |
| Settings     | Selection  |
| Toggle       | Selection  |
| Destructive  | Heavy      |

---

## Custom Button Style

The internal `GoldenButtonStyle` provides press animations:

```swift
Button("Custom") { }
    .buttonStyle(GoldenButtonStyle())
```

**Effects:**
- Scale to 97% on press
- Opacity to 90% on press
- Quick spring animation

---

## Accessibility

All buttons include:
- `.accessibilityLabel()` matching title
- `.accessibilityHint()` for subtitles
- `.accessibilityAddTraits(.isButton)`
- Minimum 44pt touch target

---

## Complete Settings Example

```swift
VStack(spacing: 0) {
    GoldenSectionHeader("Experience")

    GoldenButtonGroup {
        GoldenSettingsButton("Backgrounds", subtitle: "Customize appearance") {
            showBackgrounds = true
        }
        GoldenToggleRow("Sounds", isOn: $soundsEnabled)
        GoldenToggleRow("Haptics", isOn: $hapticsEnabled)
    }
    .padding(.horizontal, GoldenTheme.spacing.medium)

    GoldenSectionHeader("Data")

    GoldenButtonGroup {
        GoldenSettingsButton("Export Data") { exportData() }
        GoldenSettingsButton("Import Data") { importData() }
        GoldenDestructiveButton("Reset All") { showResetConfirmation = true }
    }
    .padding(.horizontal, GoldenTheme.spacing.medium)
}
```

---

## Best Practices

1. **One primary per screen** - Don't compete for attention
2. **Text-only is intentional** - Resist adding icons
3. **Group related settings** - Use `GoldenButtonGroup`
4. **Use section headers** - Organize with clear labels
5. **Destructive at bottom** - Place dangerous actions last
6. **Subtitle for context** - Help users understand what they'll find
