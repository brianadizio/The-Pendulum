# Inputs

Golden Theme provides normalized, canonical form inputs that are robust across iOS and function consistently for all Solutions.

---

## Text Field

Single-line text input:

```swift
@State private var username = ""

GoldenTextField("Username", text: $username)

// With keyboard type
GoldenTextField("Email", text: $email, keyboardType: .emailAddress)
```

**Appearance:**
- Tertiary background
- Medium corner radius
- Border highlight on focus (accent color)
- Times New Roman font

**Keyboard Types:**
- `.default`
- `.emailAddress`
- `.numberPad`
- `.phonePad`
- `.URL`

---

## Text Editor

Multi-line text input:

```swift
@State private var notes = ""

GoldenTextEditor("Enter your notes...", text: $notes)

// With custom minimum height
GoldenTextEditor("Description", text: $description, minHeight: 150)
```

**Appearance:**
- Placeholder text when empty
- Expands vertically with content
- Focus border animation
- Default 100pt minimum height

---

## Search Field

Search input with icon and clear button:

```swift
@State private var searchText = ""

GoldenSearchField("Search modes", text: $searchText)
```

**Appearance:**
- Magnifying glass icon
- Clear button when text present
- Secondary background
- Rounded corners

---

## Slider

Value slider with label and current value display:

```swift
@State private var volume = 0.5

GoldenSlider(
    "Volume",
    value: $volume,
    in: 0...1
)

// With step increments
GoldenSlider(
    "Difficulty",
    value: $difficulty,
    in: 1...10,
    step: 1
)

// With custom formatting
GoldenSlider(
    "Temperature",
    value: $temp,
    in: 0...100,
    format: { "\(Int($0))°" }
)
```

**Appearance:**
- Title on left, value on right
- Slider below
- Accent-colored track
- Monospace value display
- Haptic feedback on change

---

## Stepper

Integer value stepper:

```swift
@State private var quantity = 1

GoldenStepper("Quantity", value: $quantity, in: 1...99)
```

**Appearance:**
- Title on left
- Value and stepper on right
- Monospace value display
- Container background

---

## Segmented Picker

Horizontal selection control:

```swift
enum TimeRange: String, CaseIterable {
    case session, daily, weekly, monthly
}

@State private var selectedRange: TimeRange = .daily

GoldenSegmentedPicker(
    "Time Range",  // Optional title
    selection: $selectedRange,
    options: TimeRange.allCases,
    label: { $0.rawValue.capitalized }
)
```

**Appearance:**
- Pill-shaped segments
- Highlighted background on selection
- Caption title above (optional)
- Haptic feedback on selection

---

## Date Picker Row

Date selection in settings style:

```swift
@State private var startDate = Date()

GoldenDatePickerRow("Start Date", selection: $startDate)
```

**Appearance:**
- Settings row style
- System date picker on right
- Accent tint color

---

## Form Layout

Combine inputs in a form:

```swift
VStack(spacing: GoldenTheme.spacing.medium) {
    GoldenTextField("Name", text: $name)
    GoldenTextField("Email", text: $email, keyboardType: .emailAddress)

    GoldenSlider("Age", value: $age, in: 18...100, step: 1) {
        "\(Int($0)) years"
    }

    GoldenSegmentedPicker(
        "Gender",
        selection: $gender,
        options: Gender.allCases,
        label: { $0.rawValue }
    )

    GoldenTextEditor("Bio", text: $bio, minHeight: 100)

    GoldenPrimaryButton("Save") {
        save()
    }
}
.padding(GoldenTheme.spacing.medium)
```

---

## Settings-Style Inputs

For inputs within settings views:

```swift
GoldenButtonGroup {
    GoldenSlider("Volume", value: $volume, in: 0...1)
    GoldenStepper("Max Items", value: $maxItems, in: 1...50)
    GoldenToggleRow("Auto-play", isOn: $autoPlay)
}
```

---

## Focus Management

Text fields support focus state:

```swift
@FocusState private var isUsernameFocused: Bool

GoldenTextField("Username", text: $username)
    // Focus state is managed internally
    // Border color changes on focus
```

---

## Validation Styling

Apply validation states manually:

```swift
GoldenTextField("Email", text: $email)
    .overlay(
        RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium)
            .stroke(isValidEmail ? Color.clear : SpectrumColor.red.base, lineWidth: 2)
    )

if !isValidEmail {
    CaptionText("Please enter a valid email")
        .foregroundStyle(SpectrumColor.red.base)
}
```

---

## Haptic Feedback

Inputs provide automatic haptic feedback:

| Input     | Trigger         | Haptic    |
|-----------|-----------------|-----------|
| Slider    | Value change    | Selection |
| Stepper   | Value change    | Selection |
| Picker    | Selection       | Selection |
| Search    | Clear button    | Light     |

---

## Best Practices

1. **Use appropriate keyboard** - Email fields should use email keyboard
2. **Provide placeholders** - Help users understand expected input
3. **Format slider values** - Show units and formatting
4. **Step for integers** - Use step parameter for whole numbers
5. **Group related inputs** - Use consistent spacing
6. **Validate inline** - Show errors near the input
7. **Min height for editors** - Set reasonable minimum for multi-line
