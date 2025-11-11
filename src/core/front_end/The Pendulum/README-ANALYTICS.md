# Pendulum Analytics Dashboard

This document explains the analytics dashboard implementation for The Pendulum application, which uses custom charts instead of external dependencies like DGCharts.

## Components

The analytics system consists of the following key files:

1. **SimpleCharts.swift** - Custom chart implementation using Core Graphics
2. **AnalyticsDashboardViewNative.swift** - The native dashboard implementation
3. **AnalyticsDashboardView.swift** - A compatibility wrapper for API consistency
4. **AnalyticsManager.swift** - Data manager for tracking and retrieving analytics data

## Usage

To integrate the analytics dashboard into a view controller:

```swift
// Create and configure dashboard
let dashboard = AnalyticsDashboardView(frame: view.bounds)
dashboard.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(dashboard)

// Set up constraints
NSLayoutConstraint.activate([
    dashboard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    dashboard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    dashboard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    dashboard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
])

// Update with data
dashboard.updateDashboard(timeRange: .session, sessionId: currentSessionId)
```

## Dashboard Features

The analytics dashboard includes:

- **Time Range Selection**: Choose between session, daily, weekly, or monthly data
- **Summary Metrics**: Display key performance indicators
- **Performance Charts**: 
  - Angle Variance Chart (line chart)
  - Push Frequency Distribution (bar chart)
  - Push Magnitude Distribution (bar chart)
  - Reaction Time Analysis (line chart)
  - Learning Curve Chart (line chart)
  - Directional Bias Chart (pie chart)

## Data Flow

1. **Data Collection**:
   - `AnalyticsManager` tracks pendulum states and user interactions during gameplay
   - Data is stored using Core Data for persistence

2. **Data Processing**:
   - Raw data is processed into meaningful metrics (stability score, efficiency rating, etc.)
   - Time series data is prepared for visualization

3. **Data Visualization**:
   - The dashboard queries `AnalyticsManager` for relevant data
   - Data is formatted and displayed using custom chart implementations

## Custom Charts

The `SimpleCharts.swift` implementation provides three chart types:

1. **SimpleLineChartView**: For time series data like angle variance over time
2. **SimpleBarChartView**: For distribution data like push frequency
3. **SimplePieChartView**: For proportion data like directional bias

Each chart can be customized with:
- Colors
- Titles
- Data points
- Labels

## Integration Notes

- The dashboard is designed to work with the existing `PendulumViewModel` and data structures
- The `AnalyticsDashboardView` wrapper maintains API compatibility with previous implementations
- No external dependencies are required for chart visualization

## Troubleshooting

If you encounter layout issues:

1. Ensure views are added to the view hierarchy before applying constraints
2. Check that labels and charts have valid data to display
3. Verify that the Core Data model is properly loaded and accessible

For data issues:

1. Check that `AnalyticsManager` is correctly tracking gameplay data
2. Ensure the correct sessionId is being passed to the dashboard
3. Verify time range filters are working correctly

## Future Improvements

- Add export functionality for analytics data
- Implement more advanced chart types (scatter plots, heat maps)
- Add user-configurable chart options
- Implement comparative analytics across multiple sessions