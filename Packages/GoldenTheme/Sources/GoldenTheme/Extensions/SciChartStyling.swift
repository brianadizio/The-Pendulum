// SciChartStyling.swift
// Golden Enterprises Theme System
// Styling helpers for SciChart integration

import SwiftUI

// MARK: - Chart Color Palette

/// Color palette optimized for SciChart 2D/3D visualizations
public struct GoldenChartColors {

    /// Primary data series colors (high visibility)
    public static let series: [Color] = [
        SpectrumColor.gold.base,      // Primary series
        SpectrumColor.azure.base,     // Secondary series
        SpectrumColor.green.base,     // Tertiary series
        SpectrumColor.rose.base,      // Fourth series
        SpectrumColor.violet.base,    // Fifth series
        SpectrumColor.orange.base,    // Sixth series
        SpectrumColor.teal.base,      // Seventh series
        SpectrumColor.indigo.base     // Eighth series
    ]

    /// Gradient colors for heatmaps/surface plots
    public static let heatmapGradient: [Color] = [
        SpectrumColor.blue.dark,
        SpectrumColor.cyan.base,
        SpectrumColor.green.base,
        SpectrumColor.yellow.base,
        SpectrumColor.orange.base,
        SpectrumColor.red.dark
    ]

    /// Semantic colors for positive/negative values
    public static let positive = SpectrumColor.green.base
    public static let negative = SpectrumColor.red.base
    public static let neutral = MetalColor.silver.base

    /// Grid and axis colors
    public struct Axis {
        public static var majorGrid: Color { MetalColor.titanium.light }
        public static var minorGrid: Color { MetalColor.lead.light.opacity(0.5) }
        public static var line: Color { MetalColor.iron.base }
        public static var labels: Color { MetalColor.iron.dark }
        public static var title: Color { MetalColor.iron.dark }
    }

    /// Background colors for chart areas
    public struct Background {
        public static var light: Color { Color.parchment }
        public static var dark: Color { Color.goldenDark }
        public static var plotArea: Color { Color.white.opacity(0.9) }
        public static var plotAreaDark: Color { Color.black.opacity(0.3) }
    }
}

// MARK: - Chart Theme Configuration

/// Configuration object for theming SciChart instances
public struct SciChartThemeConfig {
    public let backgroundColor: Color
    public let plotAreaColor: Color
    public let axisColor: Color
    public let gridColor: Color
    public let labelColor: Color
    public let seriesColors: [Color]

    public init(isDarkMode: Bool = false) {
        if isDarkMode {
            backgroundColor = GoldenChartColors.Background.dark
            plotAreaColor = GoldenChartColors.Background.plotAreaDark
            axisColor = MetalColor.silver.base
            gridColor = MetalColor.titanium.dark.opacity(0.3)
            labelColor = MetalColor.silver.light
            seriesColors = GoldenChartColors.series.map { $0.opacity(0.9) }
        } else {
            backgroundColor = GoldenChartColors.Background.light
            plotAreaColor = GoldenChartColors.Background.plotArea
            axisColor = GoldenChartColors.Axis.line
            gridColor = GoldenChartColors.Axis.majorGrid
            labelColor = GoldenChartColors.Axis.labels
            seriesColors = GoldenChartColors.series
        }
    }

    /// Hex string for use with SciChart native API
    public func hexColor(_ color: Color) -> String {
        // Convert Color to hex string
        // Note: In actual implementation, you'd use UIColor conversion
        "#DAA520" // Placeholder - implement proper conversion
    }
}

// MARK: - Chart Container View

/// Container view that provides consistent styling around SciChart views
public struct GoldenChartContainer<Content: View>: View {
    let title: String?
    let subtitle: String?
    let content: () -> Content

    @Environment(\.goldenTheme) var theme

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GoldenTheme.spacing.small) {
            // Header
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 2) {
                    if let title = title {
                        Text(title)
                            .font(.golden(.body))
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.text)
                    }
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.golden(.caption))
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                .padding(.horizontal, GoldenTheme.spacing.medium)
            }

            // Chart content
            content()
                .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
        }
        .padding(GoldenTheme.spacing.medium)
        .background(theme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerLarge, style: .continuous))
    }
}

// MARK: - Legend Component

/// Custom legend component styled for golden theme
public struct GoldenChartLegend: View {
    let items: [(String, Color)]
    let orientation: Axis

    @Environment(\.goldenTheme) var theme

    public enum Axis {
        case horizontal, vertical
    }

    public init(items: [(String, Color)], orientation: Axis = .horizontal) {
        self.items = items
        self.orientation = orientation
    }

    public var body: some View {
        Group {
            if orientation == .horizontal {
                HStack(spacing: GoldenTheme.spacing.medium) {
                    legendItems
                }
            } else {
                VStack(alignment: .leading, spacing: GoldenTheme.spacing.small) {
                    legendItems
                }
            }
        }
    }

    @ViewBuilder
    private var legendItems: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            HStack(spacing: GoldenTheme.spacing.small) {
                Circle()
                    .fill(item.1)
                    .frame(width: 10, height: 10)

                Text(item.0)
                    .font(.golden(.caption))
                    .foregroundStyle(theme.textSecondary)
            }
        }
    }
}

// MARK: - Time Range Selector

/// Selector for chart time ranges (Session, Daily, Weekly, etc.)
public struct ChartTimeRangeSelector: View {
    public enum TimeRange: String, CaseIterable {
        case session = "Session"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }

    @Binding var selected: TimeRange

    public init(selected: Binding<TimeRange>) {
        self._selected = selected
    }

    public var body: some View {
        GoldenSegmentedPicker(
            selection: $selected,
            options: TimeRange.allCases,
            label: { $0.rawValue }
        )
    }
}

// MARK: - Chart Type Selector

/// Selector for switching between chart types
public struct ChartTypeSelector: View {
    public enum ChartType: String, CaseIterable {
        case line = "Line"
        case bar = "Bar"
        case scatter = "Scatter"
        case area = "Area"

        var icon: String {
            switch self {
            case .line: return "chart.xyaxis.line"
            case .bar: return "chart.bar"
            case .scatter: return "circle.grid.2x2"
            case .area: return "chart.line.uptrend.xyaxis"
            }
        }
    }

    @Binding var selected: ChartType

    @Environment(\.goldenTheme) var theme

    public init(selected: Binding<ChartType>) {
        self._selected = selected
    }

    public var body: some View {
        HStack(spacing: GoldenTheme.spacing.small) {
            ForEach(ChartType.allCases, id: \.self) { type in
                Button(action: {
                    selected = type
                    HapticManager.shared.play(.selection)
                }) {
                    Image(systemName: type.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(selected == type ? theme.accent : theme.textTertiary)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: GoldenGeometry.cornerSmall, style: .continuous)
                                .fill(selected == type ? theme.backgroundTertiary : Color.clear)
                        )
                }
            }
        }
    }
}

// MARK: - Data Point Tooltip

/// Tooltip view for displaying data point information
public struct ChartTooltip: View {
    let title: String
    let values: [(String, String)]

    @Environment(\.goldenTheme) var theme

    public init(title: String, values: [(String, String)]) {
        self.title = title
        self.values = values
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GoldenTheme.spacing.micro) {
            Text(title)
                .font(.golden(.caption))
                .fontWeight(.semibold)
                .foregroundStyle(theme.text)

            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                HStack {
                    Text(value.0)
                        .font(.golden(.micro))
                        .foregroundStyle(theme.textSecondary)

                    Spacer()

                    Text(value.1)
                        .font(.goldenMono(size: GoldenTypography.captionSize))
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .padding(GoldenTheme.spacing.small)
        .background(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerSmall, style: .continuous)
                .fill(theme.backgroundTertiary)
                .shadow(color: .black.opacity(0.1), radius: 8)
        )
    }
}
