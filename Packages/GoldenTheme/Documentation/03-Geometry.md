# Geometry

The Golden Theme geometry system provides φ-based spacing, sizing, and layout helpers for consistent proportions throughout your app.

---

## Spacing Scale

All spacing derives from an 8pt base unit, scaled by φ:

| Name    | Value | Formula     | Use Case                    |
|---------|-------|-------------|-----------------------------|
| micro   | 4pt   | base ÷ 2    | Icon padding, minimal gaps  |
| small   | 8pt   | base         | Tight spacing, compact      |
| medium  | 13pt  | base × √φ   | Standard element spacing    |
| large   | 21pt  | base × φ    | Section spacing, padding    |
| xlarge  | 34pt  | base × φ²   | Major section breaks        |
| xxlarge | 55pt  | base × φ³   | Screen-level spacing        |

---

## Usage

### Direct Access

```swift
// Access spacing values
GoldenTheme.spacing.micro    // 4
GoldenTheme.spacing.small    // 8
GoldenTheme.spacing.medium   // 13
GoldenTheme.spacing.large    // 21
GoldenTheme.spacing.xlarge   // 34
GoldenTheme.spacing.xxlarge  // 55
```

### Padding Modifier

```swift
// Apply golden padding
Text("Hello")
    .goldenPadding(.all, scale: .medium)

// Specific edges
VStack {
    content
}
.goldenPadding(.horizontal, scale: .large)
.goldenPadding(.vertical, scale: .medium)
```

---

## Corner Radii

Consistent corner radii for rounded elements:

| Name    | Value | Use Case                  |
|---------|-------|---------------------------|
| small   | 8pt   | Small chips, tags         |
| medium  | 12pt  | Buttons, inputs           |
| large   | 16pt  | Cards, panels             |
| xlarge  | 24pt  | Large containers, modals  |

```swift
RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium)
```

---

## Component Sizes

Standard sizes for common components:

| Component          | Size   | Notes                    |
|--------------------|--------|--------------------------|
| Button height      | 44pt   | Apple HIG minimum        |
| Button height (lg) | ~71pt  | 44 × φ                   |
| Icon small         | 20pt   | Inline icons             |
| Icon medium        | 24pt   | Button icons             |
| Icon large         | 32pt   | Feature icons            |
| Tab bar icon       | 30pt   | Navigation tabs          |

```swift
Image(systemName: "star")
    .frame(width: GoldenGeometry.iconMedium,
           height: GoldenGeometry.iconMedium)
```

---

## Proportions

Golden rectangle and common aspect ratios:

| Name            | Ratio    | Use Case               |
|-----------------|----------|------------------------|
| Golden rectangle| 1.618:1  | Cards, images, panels  |
| Square          | 1:1      | Icons, avatars         |
| Double square   | 2:1      | Headers, banners       |

### Golden Rectangle Modifier

```swift
// Width-based golden rectangle
Image("photo")
    .goldenRectangle(width: 300)
// Results in 300 × 185 (300 ÷ φ)

// Height-based golden rectangle
Image("photo")
    .goldenRectangleByHeight(200)
// Results in 323 × 200 (200 × φ)
```

---

## Layout Components

### GoldenVStack

Vertical stack with φ-based spacing:

```swift
GoldenVStack(alignment: .leading, spacing: .medium) {
    Text("Item 1")
    Text("Item 2")
    Text("Item 3")
}
```

### GoldenHStack

Horizontal stack with φ-based spacing:

```swift
GoldenHStack(alignment: .center, spacing: .small) {
    Image(systemName: "star")
    Text("Label")
}
```

### GoldenGrid

Lazy vertical grid with golden proportions:

```swift
GoldenGrid(columns: 2, spacing: .medium) {
    ForEach(items) { item in
        GridCard(title: item.name)
    }
}
```

---

## Grid Calculations

Calculate column widths for grids:

```swift
let columnWidth = GoldenGeometry.columnWidth(
    totalWidth: screenWidth,
    columns: 2,
    spacing: GoldenTheme.spacing.medium
)
// Returns width for each column accounting for spacing
```

---

## Safe Areas

Approximate safe area insets (use GeometryReader for actual values):

```swift
GoldenGeometry.SafeArea.topIPhone    // 47pt
GoldenGeometry.SafeArea.bottomIPhone // 34pt
GoldenGeometry.SafeArea.topIPad      // 20pt
GoldenGeometry.SafeArea.bottomIPad   // 20pt
```

---

## Animations

φ-based spring animations:

```swift
// Standard golden spring
withAnimation(.goldenSpring) {
    isExpanded.toggle()
}

// Quick spring (for feedback)
withAnimation(.goldenSpringQuick) {
    isPressed = false
}

// Slow spring (for emphasis)
withAnimation(.goldenSpringSlow) {
    showContent = true
}
```

### Animation Parameters

| Animation         | Response | Damping       |
|-------------------|----------|---------------|
| goldenSpring      | 0.5s     | 1/φ ≈ 0.618   |
| goldenSpringQuick | 0.3s     | 1/φ ≈ 0.618   |
| goldenSpringSlow  | 0.8s     | 1/φ ≈ 0.618   |

---

## Button Sizing

Apply standard button dimensions:

```swift
Text("Continue")
    .goldenButtonSize()
// Sets height to 44pt
```

---

## Best Practices

1. **Use the spacing scale** - Avoid arbitrary padding values
2. **Golden rectangles for images** - Photos and cards look better
3. **Consistent corner radii** - Pick a level and stick to it per component type
4. **Let spacing breathe** - Large spacing for section breaks
5. **Responsive grids** - Use `columnWidth()` calculation for adaptive layouts
6. **Golden springs** - The φ-based damping feels natural
