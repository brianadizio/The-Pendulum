# Cards

Golden Theme provides card components for displaying statistics, metrics, and content in dashboard and list views.

---

## Card Types

| Type       | Use Case                              |
|------------|---------------------------------------|
| Basic      | Generic content container             |
| Statistic  | Single metric with trend              |
| MetricRow  | Dashboard-style metric row            |
| Info       | Expandable information                |
| Action     | Content with CTA button               |
| Grid       | Selection grid item                   |

---

## Basic Card

Generic container with golden styling:

```swift
GoldenCard {
    VStack(alignment: .leading) {
        Text("Custom Content")
        Text("Goes here")
    }
}
```

**Appearance:**
- Medium padding
- Tertiary background
- Medium corner radius

---

## Statistic Card

Display a single statistic with optional trend:

```swift
StatisticCard(
    title: "Phase Space Coverage",
    value: "73.2%",
    subtitle: "of possible states explored",
    icon: Image(systemName: "chart.xyaxis.line"),
    trend: .up("+12%")
)

// Without trend
StatisticCard(
    title: "Total Sessions",
    value: "847",
    subtitle: "all time"
)

// With down trend
StatisticCard(
    title: "Error Rate",
    value: "0.3%",
    trend: .down("-0.1%")  // Green because down is good for errors
)
```

**Trend Types:**
- `.up(String)` - Arrow up, green color
- `.down(String)` - Arrow down, red color
- `.neutral(String)` - Arrow right, gray color

**Appearance:**
- Icon and title in header
- Large value in accent color
- Subtitle and trend in footer

---

## Metric Row Card

Dashboard-style metric display (like your Analytics Dashboard):

```swift
MetricRowCard(
    title: "Lyapunov Exponent",
    description: "Measure of system chaos - higher values mean less predictable dynamics",
    value: "0.847",
    icon: Image(systemName: "waveform")
)

// Minimal version
MetricRowCard(
    title: "Control Strategy",
    value: "Insufficient Data"
)
```

**Appearance:**
- Icon on left (40×40)
- Title and description stacked
- Value in accent color below description

---

## Info Card

Information display with optional expand/collapse:

```swift
// Static info card
InfoCard(
    title: "About Phase Space",
    content: "Phase space is the mathematical space containing all possible states of a dynamical system."
)

// Expandable
InfoCard(
    title: "How to Play",
    content: "Navigate through the maze by swiping in the direction you want to move. Avoid walls and find the exit to complete each level.",
    isExpandable: true
)
```

**Appearance:**
- Title in semibold
- Content in secondary color
- Chevron indicator when expandable
- Smooth expand/collapse animation

---

## Action Card

Content with a call-to-action button:

```swift
ActionCard(
    title: "Connect to The Pendulum",
    description: "Share your maze trajectory data with The Pendulum for cross-solution analysis.",
    buttonTitle: "Connect",
    action: { showPendulumConnection = true }
)
```

**Appearance:**
- Title and description
- Primary button at bottom
- Suitable for integration prompts

---

## Grid Card

Selection card for grid layouts (mode selection, etc.):

```swift
GoldenGrid(columns: 2) {
    ForEach(modes) { mode in
        GridCard(
            title: mode.name,
            image: Image(mode.thumbnail),
            isSelected: selectedMode == mode,
            action: { selectedMode = mode }
        )
    }
}

// Without image
GridCard(
    title: "Classic Mode",
    isSelected: isClassicSelected,
    action: { selectClassic() }
)
```

**Appearance:**
- Image or placeholder area (80pt height)
- Title below
- Selection border in accent color
- Press animation

---

## Dashboard Layout

Combine cards for a dashboard:

```swift
ScrollView {
    VStack(spacing: GoldenTheme.spacing.medium) {
        // Summary stats row
        HStack(spacing: GoldenTheme.spacing.medium) {
            StatisticCard(title: "Sessions", value: "24", trend: .up("+3"))
            StatisticCard(title: "Avg Time", value: "4:32")
        }

        // Detailed metrics
        MetricRowCard(
            title: "Phase Space Coverage",
            description: "Percentage of possible states explored",
            value: "73.2%",
            icon: Image(systemName: "square.grid.3x3")
        )

        MetricRowCard(
            title: "Energy Management",
            description: "Efficiency of kinetic/potential energy balance",
            value: "88.5%",
            icon: Image(systemName: "bolt")
        )

        // Info section
        InfoCard(
            title: "What is Phase Space?",
            content: "Phase space represents all possible states...",
            isExpandable: true
        )
    }
    .padding(GoldenTheme.spacing.medium)
}
```

---

## Mode Selection Layout

Grid of selectable modes:

```swift
GoldenGrid(columns: 2, spacing: .medium) {
    GridCard(title: "Classic", image: classicImage, isSelected: mode == .classic) {
        mode = .classic
    }
    GridCard(title: "Timed", image: timedImage, isSelected: mode == .timed) {
        mode = .timed
    }
    GridCard(title: "Zen", image: zenImage, isSelected: mode == .zen) {
        mode = .zen
    }
    GridCard(title: "Challenge", image: challengeImage, isSelected: mode == .challenge) {
        mode = .challenge
    }
}
```

---

## Skeleton Loading

Show loading states with skeleton cards:

```swift
if isLoading {
    ForEach(0..<3, id: \.self) { _ in
        SkeletonCard()
    }
} else {
    ForEach(metrics) { metric in
        MetricRowCard(...)
    }
}
```

---

## Styling Consistency

All cards share:
- Tertiary background color
- Medium corner radius (12pt)
- Medium padding
- Theme-aware colors

---

## Best Practices

1. **Consistent card types** - Use the same card type for similar content
2. **Trends for changes** - Show how metrics evolved
3. **Icons for recognition** - Help users scan quickly
4. **Grid for selection** - Visual browsing of options
5. **Expandable for details** - Don't overwhelm, let users dig in
6. **Action cards for CTAs** - Clear next step
7. **Skeleton while loading** - Better than spinners for lists
