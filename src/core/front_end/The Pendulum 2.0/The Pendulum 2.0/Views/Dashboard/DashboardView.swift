// DashboardView.swift
// The Pendulum 2.0
// CSV-based analytics dashboard with time filtering

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedTimeRange: AnalyticsTimeRange = .daily
    @StateObject private var metricsCalculator = CSVMetricsCalculator()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            DashboardHeader()

            // Time range selector
            TimeRangeSelector(selected: $selectedTimeRange)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            // Metrics content
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Metrics Section
                    BasicMetricsSection(metrics: metricsCalculator.basicMetrics)

                    Divider().padding(.horizontal, 16)

                    // Charts Section
                    ChartsSection(metricsCalculator: metricsCalculator)

                    Divider().padding(.horizontal, 16)

                    // Advanced Metrics (placeholder for future)
                    AdvancedMetricsSection(metricsCalculator: metricsCalculator)
                }
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            loadMetrics()
        }
        .onChange(of: selectedTimeRange) { _, newRange in
            loadMetrics()
        }
    }

    private func loadMetrics() {
        if let csvManager = gameState.csvSessionManager {
            metricsCalculator.calculateMetrics(from: csvManager, timeRange: selectedTimeRange)
        }
    }
}

// MARK: - Dashboard Header
struct DashboardHeader: View {
    var body: some View {
        HStack {
            Text("Dashboard")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Time Range Selector
struct TimeRangeSelector: View {
    @Binding var selected: AnalyticsTimeRange

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AnalyticsTimeRange.allCases) { range in
                    TimeRangeButton(
                        range: range,
                        isSelected: selected == range
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = range
                        }
                    }
                }
            }
        }
    }
}

struct TimeRangeButton: View {
    let range: AnalyticsTimeRange
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(range.rawValue)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemBackground))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Basic Metrics Section
struct BasicMetricsSection: View {
    let metrics: BasicMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BASIC METRICS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricCard(title: "Stability Score", value: String(format: "%.1f%%", metrics.stabilityScore))
                MetricCard(title: "Efficiency Rating", value: String(format: "%.1f%%", metrics.efficiencyRating))
                MetricCard(title: "Total Session Time", value: formatDuration(metrics.totalSessionTime))
                MetricCard(title: "Total Pushes", value: "\(metrics.totalPushes)")
                MetricCard(title: "Max Level Reached", value: "\(metrics.maxLevel)")
                MetricCard(title: "Sessions Played", value: "\(metrics.sessionsPlayed)")
            }
            .padding(.horizontal, 16)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm %ds", minutes, Int(seconds) % 60)
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - Charts Section
struct ChartsSection: View {
    @ObservedObject var metricsCalculator: CSVMetricsCalculator

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("VISUALIZATIONS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            // Levels Completion Over Time
            if !metricsCalculator.levelCompletionData.isEmpty {
                ChartCard(title: "Levels Completed Over Time") {
                    Chart(metricsCalculator.levelCompletionData) { point in
                        LineMark(
                            x: .value("Time", point.date),
                            y: .value("Level", point.level)
                        )
                        .foregroundStyle(Color.accentColor)
                    }
                    .chartYScale(domain: 0...max(10, metricsCalculator.levelCompletionData.map(\.level).max() ?? 10))
                }
            }

            // Angular Deviation Distribution
            if !metricsCalculator.angularDeviationData.isEmpty {
                ChartCard(title: "Angular Deviation (degrees)") {
                    Chart(metricsCalculator.angularDeviationData) { point in
                        LineMark(
                            x: .value("Time", point.time),
                            y: .value("Angle", point.angleDegrees)
                        )
                        .foregroundStyle(Color.orange)
                    }
                    .chartYScale(domain: -90...90)
                }
            }

            // Directional Bias
            DirectionalBiasCard(bias: metricsCalculator.directionalBias)

            // Learning Curve
            if !metricsCalculator.learningCurveData.isEmpty {
                ChartCard(title: "Learning Curve (% skill)") {
                    Chart(metricsCalculator.learningCurveData) { point in
                        LineMark(
                            x: .value("Session", point.sessionNumber),
                            y: .value("Skill", point.skillPercentage)
                        )
                        .foregroundStyle(Color.green)
                    }
                    .chartYScale(domain: 0...100)
                }
            }
        }
    }
}

// MARK: - Chart Card
struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)

            content()
                .frame(height: 200)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Directional Bias Card
struct DirectionalBiasCard: View {
    let bias: Double // -1 = full left, 0 = neutral, 1 = full right

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Directional Bias")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)

            HStack {
                Text("Left")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray4))
                            .frame(height: 8)

                        // Bias indicator
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 16, height: 16)
                            .offset(x: CGFloat(bias) * (geometry.size.width / 2 - 8))

                        // Center line
                        Rectangle()
                            .fill(Color(uiColor: .systemGray2))
                            .frame(width: 2, height: 16)
                    }
                }
                .frame(height: 20)

                Text("Right")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Text(biasDescription)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal, 16)
    }

    private var biasDescription: String {
        if abs(bias) < 0.1 {
            return "Neutral - balanced pushes in both directions"
        } else if bias < 0 {
            return "Left bias - you push left more often (coefficient: \(String(format: "%.2f", bias)))"
        } else {
            return "Right bias - you push right more often (coefficient: \(String(format: "%.2f", bias)))"
        }
    }
}

// MARK: - Advanced Metrics Section
struct AdvancedMetricsSection: View {
    @ObservedObject var metricsCalculator: CSVMetricsCalculator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOPOLOGY METRICS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                PlaceholderMetricRow(title: "Winding Number", message: "Coming Soon - requires TDA microservice")
                PlaceholderMetricRow(title: "Betti Numbers", message: "Coming Soon - requires TDA microservice")
                PlaceholderMetricRow(title: "Persistent Homology", message: "Coming Soon - requires TDA microservice")
            }
            .padding(.horizontal, 16)
        }
    }
}

struct PlaceholderMetricRow: View {
    let title: String
    let message: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "clock")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - Preview
#Preview {
    DashboardView(gameState: GameState())
}
