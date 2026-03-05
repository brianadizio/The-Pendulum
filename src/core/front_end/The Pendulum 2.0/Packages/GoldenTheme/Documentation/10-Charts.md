# Charts & SciChart Integration

Golden Theme provides styling helpers for SciChart, ensuring your 2D/3D plots are beautiful, detailed, and coordinate with the golden color theme.

---

## Overview

SciChart is a high-performance charting library. Golden Theme provides:
- Coordinated color palettes
- Theme configuration objects
- Container components
- Legends and tooltips
- Time range selectors

---

## Chart Color Palette

### Series Colors

Eight colors for data series, optimized for visibility:

```swift
GoldenChartColors.series[0]  // Gold (primary)
GoldenChartColors.series[1]  // Azure
GoldenChartColors.series[2]  // Green
GoldenChartColors.series[3]  // Rose
GoldenChartColors.series[4]  // Violet
GoldenChartColors.series[5]  // Orange
GoldenChartColors.series[6]  // Teal
GoldenChartColors.series[7]  // Indigo
```

### Heatmap Gradient

For surface plots and heatmaps:

```swift
GoldenChartColors.heatmapGradient
// Blue → Cyan → Green → Yellow → Orange → Red
```

### Semantic Colors

```swift
GoldenChartColors.positive  // Green - gains, success
GoldenChartColors.negative  // Red - losses, errors
GoldenChartColors.neutral   // Silver - unchanged
```

### Axis Colors

```swift
GoldenChartColors.Axis.majorGrid   // Titanium light
GoldenChartColors.Axis.minorGrid   // Lead light @ 50%
GoldenChartColors.Axis.line        // Iron base
GoldenChartColors.Axis.labels      // Iron dark
GoldenChartColors.Axis.title       // Iron dark
```

### Background Colors

```swift
GoldenChartColors.Background.light        // Parchment
GoldenChartColors.Background.dark         // Golden dark
GoldenChartColors.Background.plotArea     // White @ 90%
GoldenChartColors.Background.plotAreaDark // Black @ 30%
```

---

## Theme Configuration

Create a configuration object for SciChart:

```swift
// Light mode
let lightConfig = SciChartThemeConfig(isDarkMode: false)

// Dark mode
let darkConfig = SciChartThemeConfig(isDarkMode: true)

// Access properties
lightConfig.backgroundColor
lightConfig.plotAreaColor
lightConfig.axisColor
lightConfig.gridColor
lightConfig.labelColor
lightConfig.seriesColors
```

---

## Chart Container

Wrap SciChart views with consistent styling:

```swift
GoldenChartContainer(
    title: "Phase Space Trajectory",
    subtitle: "Last 24 hours"
) {
    // Your SciChartSurface here
    SciChartSurfaceView(...)
}
```

**Appearance:**
- Header with title and subtitle
- Rounded corners
- Card-style background
- Consistent padding

---

## Legend Component

Custom styled legend:

```swift
GoldenChartLegend(
    items: [
        ("Position X", GoldenChartColors.series[0]),
        ("Position Y", GoldenChartColors.series[1]),
        ("Velocity", GoldenChartColors.series[2])
    ],
    orientation: .horizontal
)

// Vertical layout
GoldenChartLegend(items: items, orientation: .vertical)
```

---

## Time Range Selector

Select data time windows:

```swift
@State private var timeRange: ChartTimeRangeSelector.TimeRange = .daily

ChartTimeRangeSelector(selected: $timeRange)

// Filter data based on selection
switch timeRange {
case .session: // Current session data
case .daily:   // Last 24 hours
case .weekly:  // Last 7 days
case .monthly: // Last 30 days
case .yearly:  // Last 365 days
}
```

---

## Chart Type Selector

Switch between visualization types:

```swift
@State private var chartType: ChartTypeSelector.ChartType = .line

ChartTypeSelector(selected: $chartType)

// Available types: .line, .bar, .scatter, .area
```

**Appearance:**
- Icon buttons in a row
- Highlighted background on selection
- SF Symbols for each type

---

## Tooltip Component

Display data point information:

```swift
ChartTooltip(
    title: "Point 47",
    values: [
        ("X", "1.234"),
        ("Y", "5.678"),
        ("Time", "12:34:56")
    ]
)
```

**Appearance:**
- Compact card style
- Title + key-value pairs
- Monospace values
- Shadow for visibility

---

## Complete Dashboard Example

```swift
struct AnalyticsDashboardView: View {
    @State private var timeRange: ChartTimeRangeSelector.TimeRange = .daily
    @State private var chartType: ChartTypeSelector.ChartType = .line

    var body: some View {
        ScrollView {
            VStack(spacing: GoldenTheme.spacing.medium) {
                // Controls
                HStack {
                    ChartTimeRangeSelector(selected: $timeRange)
                    Spacer()
                    ChartTypeSelector(selected: $chartType)
                }
                .padding(.horizontal)

                // Main chart
                GoldenChartContainer(
                    title: "Trajectory Analysis",
                    subtitle: timeRange.rawValue
                ) {
                    // SciChart view
                    TrajectoryChartView(
                        data: filteredData,
                        type: chartType
                    )
                    .frame(height: 300)
                }

                // Legend
                GoldenChartLegend(
                    items: [
                        ("X Position", GoldenChartColors.series[0]),
                        ("Y Position", GoldenChartColors.series[1])
                    ]
                )
                .padding(.horizontal)

                // Stats cards
                HStack {
                    StatisticCard(
                        title: "Max Amplitude",
                        value: "2.34",
                        trend: .up("+0.12")
                    )
                    StatisticCard(
                        title: "Frequency",
                        value: "1.618 Hz",
                        trend: .neutral("φ")
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
```

---

## SciChart Setup

### Basic Surface Setup

```swift
import SciChart

class TrajectoryChartView: UIViewRepresentable {
    let data: [DataPoint]

    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()

        // Apply golden theme colors
        let config = SciChartThemeConfig(isDarkMode: false)

        surface.backgroundColor = UIColor(config.backgroundColor)

        // Configure axes
        let xAxis = SCINumericAxis()
        xAxis.axisTitle = "Time"
        // Apply config.axisColor, config.labelColor, etc.

        let yAxis = SCINumericAxis()
        yAxis.axisTitle = "Value"

        surface.xAxes.add(xAxis)
        surface.yAxes.add(yAxis)

        // Add data series with golden colors
        let lineSeries = SCIFastLineRenderableSeries()
        lineSeries.strokeStyle = SCISolidPenStyle(
            color: UIColor(GoldenChartColors.series[0]),
            thickness: 2
        )

        surface.renderableSeries.add(lineSeries)

        return surface
    }
}
```

---

## Best Practices

1. **Consistent colors** - Use `GoldenChartColors.series` for all data
2. **Container for context** - Wrap charts with title/subtitle
3. **Legends for clarity** - Always label multi-series charts
4. **Time ranges** - Let users explore different windows
5. **Tooltips for detail** - Show exact values on interaction
6. **Theme matching** - Use config for light/dark modes
7. **Performance** - SciChart handles large datasets well
