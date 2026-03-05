# Loading States

Golden Theme provides various loading indicators including the Claude/ChatGPT-style shimmer effect and support for your morphing logo videos.

---

## Loading Types

| Type           | Use Case                              |
|----------------|---------------------------------------|
| Shimmer        | Text highlight sweep                  |
| ShimmerText    | Loading text with sweep effect        |
| Spinner        | Simple circular spinner               |
| PulsingDots    | Three dots animation                  |
| LogoVideo      | Morphing logo video loop              |
| Overlay        | Full-screen loading state             |
| Skeleton       | Placeholder content shapes            |

---

## Shimmer Effect

The signature sweep of color through content (like Claude):

```swift
// As an overlay on any content
Text("Processing your request...")
    .shimmerLoading(isLoading: true)

// The raw effect
ShimmerEffect()
```

**Appearance:**
- Gradient sweep from left to right
- Accent color at 40% opacity
- 1.5 second cycle
- Repeats continuously

---

## Shimmer Text

Text with integrated shimmer effect:

```swift
ShimmerText("Analyzing data...", isLoading: isProcessing)

// When not loading, shows as normal text
ShimmerText("Ready", isLoading: false)
```

**Appearance:**
- Normal text appearance when not loading
- Golden highlight sweeps through text when loading
- 1.2 second cycle

---

## Golden Spinner

Simple circular loading spinner:

```swift
GoldenSpinner()
```

**Appearance:**
- Circular arc (70% of circle)
- Angular gradient in accent color
- Continuous rotation
- 40×40pt size

---

## Pulsing Dots

Three dots that pulse in sequence:

```swift
PulsingDotsLoading()
```

**Appearance:**
- Three circles in a row
- Each pulses in sequence
- Scale up to 130% when active
- Good for chat typing indicators

---

## Logo Video Loading

Play your morphing logo video during loading:

```swift
LogoVideoLoading(videoName: "maze_logo_morph")

// With different extension
LogoVideoLoading(videoName: "logo", extension: "mov")
```

**Requirements:**
- Video file in app bundle
- Loops automatically
- Falls back to spinner if video not found
- Displays in 120×120 circular frame

**Setup:**
1. Add your logo morph video to the app bundle
2. Name it consistently (e.g., `maze_logo_morph.mp4`)
3. Each Solution can have its own variation

---

## Full-Screen Overlay

Loading overlay for transitions and initialization:

```swift
ZStack {
    MainContent()

    GoldenLoadingOverlay(
        isVisible: isLoading,
        message: "Loading The Maze...",
        videoName: "maze_logo_morph"
    )
}

// Without video
GoldenLoadingOverlay(
    isVisible: isLoading,
    message: "Please wait..."
)
```

**Appearance:**
- Dimmed background (90% opacity)
- Centered loading indicator
- Optional message with shimmer
- Fade in/out animation

---

## Skeleton Views

Placeholder shapes while content loads:

### Basic Skeleton

```swift
// Text-like skeleton
SkeletonView(width: 200, height: 20)

// Full-width
SkeletonView(height: 16)
```

### Skeleton Card

```swift
// Pre-built card skeleton
SkeletonCard()

// Multiple for lists
ForEach(0..<5, id: \.self) { _ in
    SkeletonCard()
}
```

**Appearance:**
- Secondary background color
- Shimmer overlay
- Rounded corners matching content

---

## Loading in Lists

Pattern for loading list content:

```swift
ScrollView {
    if isLoading {
        VStack(spacing: GoldenTheme.spacing.medium) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonCard()
            }
        }
    } else {
        VStack(spacing: GoldenTheme.spacing.medium) {
            ForEach(items) { item in
                MetricRowCard(...)
            }
        }
    }
}
```

---

## App Launch Loading

Use the app template's built-in loading:

```swift
GoldenAppRoot(
    config: GoldenAppConfig(
        name: "The Maze",
        loadingVideo: "maze_logo_morph"  // Shows during launch
    ),
    // ...
)
```

The template automatically shows a 1.5-second loading overlay on launch.

---

## Button Loading State

Buttons handle their own loading:

```swift
@State private var isSubmitting = false

GoldenPrimaryButton(isSubmitting ? "Saving..." : "Save") {
    isSubmitting = true
    // ... async work
    isSubmitting = false
}
.disabled(isSubmitting)
```

For more elaborate loading, overlay a spinner:

```swift
ZStack {
    GoldenPrimaryButton("Save") { }
        .opacity(isSubmitting ? 0.5 : 1)
        .disabled(isSubmitting)

    if isSubmitting {
        GoldenSpinner()
    }
}
```

---

## Async/Await Pattern

```swift
@State private var isLoading = true
@State private var data: [Item] = []

var body: some View {
    Group {
        if isLoading {
            GoldenLoadingOverlay(isVisible: true, message: "Loading...")
        } else {
            ContentView(data: data)
        }
    }
    .task {
        data = await fetchData()
        isLoading = false
    }
}
```

---

## Best Practices

1. **Shimmer for text** - Use when generating or processing text
2. **Skeleton for structure** - Show shape of incoming content
3. **Spinner for indeterminate** - When you don't know the shape
4. **Logo video for branding** - App launch and major transitions
5. **Message with shimmer** - Combine for informative loading
6. **Keep it short** - Loading should be brief; optimize your data fetching
7. **Smooth transitions** - Use animation for show/hide
