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

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Phase Space Chart (SciChart) - SKView is paused when on Dashboard
                    PhaseSpaceSciChartCard(data: metricsCalculator.phaseSpaceData)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Charts Section
                    ChartsSection(metricsCalculator: metricsCalculator)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Advanced Metrics
                    AdvancedMetricsSection(metricsCalculator: metricsCalculator)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Scientific Metrics
                    ScientificMetricsSection(metricsCalculator: metricsCalculator)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Topology Metrics
                    TopologyMetricsSection(metricsCalculator: metricsCalculator)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Educational Metrics
                    EducationalMetricsSection(metricsCalculator: metricsCalculator)

                    // Health Correlations (visible when Apple Health connected + enough data)
                    if HealthKitManager.shared.isAuthorized {
                        let correlations = ProfileManager.shared.getHealthCorrelations(limit: 50)
                        if correlations.count >= 5 {
                            Divider()
                                .background(PendulumColors.bronze.opacity(0.3))
                                .padding(.horizontal, 16)

                            HealthCorrelationSection(correlations: correlations)
                        }
                    }

                    // AI Metrics (visible only when AI data exists)
                    if metricsCalculator.aiMetrics.hasAIData {
                        Divider()
                            .background(PendulumColors.bronze.opacity(0.3))
                            .padding(.horizontal, 16)

                        AIMetricsSection(metricsCalculator: metricsCalculator)
                    }

                    // Golden Mode Metrics (visible when golden sessions exist)
                    if GoldenModeManager.shared.outcomeCount > 0 {
                        Divider()
                            .background(PendulumColors.bronze.opacity(0.3))
                            .padding(.horizontal, 16)

                        GoldenModeDashboardSection()
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .background(PendulumColors.background)
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
                .foregroundStyle(PendulumColors.text)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PendulumColors.background)
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
                .foregroundStyle(isSelected ? .white : PendulumColors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? PendulumColors.gold : PendulumColors.backgroundSecondary)
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
                .foregroundStyle(PendulumColors.textTertiary)
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
                .foregroundStyle(PendulumColors.textSecondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(PendulumColors.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
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
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            // Levels Completion Over Time (bar chart)
            if !metricsCalculator.levelCompletionData.isEmpty {
                ChartCard(title: "Levels Completed Over Time") {
                    Chart(metricsCalculator.levelCompletionData) { point in
                        BarMark(
                            x: .value("Time", point.date, unit: .hour),
                            y: .value("Level", point.level)
                        )
                        .foregroundStyle(PendulumColors.gold.gradient)
                        .cornerRadius(4)
                    }
                    .chartYScale(domain: 0...max(10, metricsCalculator.levelCompletionData.map(\.level).max() ?? 10))
                    .chartXAxisLabel("Date", position: .bottom, alignment: .center)
                    .chartYAxisLabel("Level", position: .leading, alignment: .center)
                }
            }

            // Angular Deviation - SciChart version
            AngularDeviationSciChartCard(data: metricsCalculator.angularDeviationData)

            // Directional Bias
            DirectionalBiasCard(bias: metricsCalculator.directionalBias)

            // Learning Curve - SciChart version
            LearningCurveSciChartCard(data: metricsCalculator.learningCurveData)
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
                .foregroundStyle(PendulumColors.text)

            content()
                .frame(height: 200)
                .clipped()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
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
                .foregroundStyle(PendulumColors.text)

            HStack {
                Text("Left")
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)

                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PendulumColors.backgroundSecondary)
                            .frame(height: 8)

                        // Bias indicator
                        Circle()
                            .fill(PendulumColors.gold)
                            .frame(width: 16, height: 16)
                            .offset(x: CGFloat(bias) * (geometry.size.width / 2 - 8))

                        // Center line
                        Rectangle()
                            .fill(PendulumColors.bronze)
                            .frame(width: 2, height: 16)
                    }
                }
                .frame(height: 20)

                Text("Right")
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            Text(biasDescription)
                .font(.system(size: 12))
                .foregroundStyle(PendulumColors.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
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
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Advanced Section Header
            CollapsibleSectionHeader(
                title: "ADVANCED METRICS",
                isExpanded: $isExpanded
            )
            .padding(.horizontal, 16)

            if isExpanded {
                VStack(spacing: 8) {
                    MetricRow(
                        title: "Directional Bias",
                        value: formatDirectionalBias(metricsCalculator.advancedMetrics.directionalBias),
                        icon: "arrow.left.and.right"
                    )
                    MetricRow(
                        title: "Overcorrection Rate",
                        value: String(format: "%.1f%%", metricsCalculator.advancedMetrics.overcorrectionRate),
                        icon: "arrow.uturn.left"
                    )
                    MetricRow(
                        title: "Avg Reaction Time",
                        value: String(format: "%.2fs", metricsCalculator.advancedMetrics.averageReactionTime),
                        icon: "bolt"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func formatDirectionalBias(_ bias: Double) -> String {
        if abs(bias) < 0.1 {
            return "Neutral"
        } else if bias < 0 {
            return String(format: "%.0f%% Left", abs(bias) * 100)
        } else {
            return String(format: "%.0f%% Right", bias * 100)
        }
    }
}

// MARK: - Scientific Metrics Section
struct ScientificMetricsSection: View {
    @ObservedObject var metricsCalculator: CSVMetricsCalculator
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionHeader(
                title: "SCIENTIFIC METRICS",
                isExpanded: $isExpanded
            )
            .padding(.horizontal, 16)

            if isExpanded {
                VStack(spacing: 8) {
                    MetricRow(
                        title: "Phase Space Coverage",
                        value: String(format: "%.1f%%", metricsCalculator.scientificMetrics.phaseSpaceCoverage),
                        icon: "square.grid.3x3"
                    )
                    MetricRow(
                        title: "Energy Management",
                        value: String(format: "%.1f%%", metricsCalculator.scientificMetrics.energyManagement),
                        icon: "bolt.fill"
                    )
                    MetricRow(
                        title: "Lyapunov Exponent",
                        value: String(format: "%.3f", metricsCalculator.scientificMetrics.lyapunovExponent),
                        icon: "waveform.path.ecg"
                    )
                    MetricRow(
                        title: "Angular Deviation σ",
                        value: String(format: "%.1f°", metricsCalculator.scientificMetrics.angularDeviationStdDev),
                        icon: "angle"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Topology Metrics Section
struct TopologyMetricsSection: View {
    @ObservedObject var metricsCalculator: CSVMetricsCalculator
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionHeader(
                title: "TOPOLOGY METRICS",
                isExpanded: $isExpanded
            )
            .padding(.horizontal, 16)

            if isExpanded {
                VStack(spacing: 8) {
                    MetricRow(
                        title: "Winding Number",
                        value: String(format: "%.1f", metricsCalculator.topologyMetrics.windingNumber),
                        icon: "arrow.triangle.2.circlepath"
                    )
                    MetricRow(
                        title: "Basin Stability",
                        value: String(format: "%.1f%%", metricsCalculator.topologyMetrics.basinStability),
                        icon: "scope"
                    )
                    MetricRow(
                        title: "Periodic Orbits",
                        value: "\(metricsCalculator.topologyMetrics.periodicOrbitCount)",
                        icon: "circle.dashed"
                    )
                    MetricRow(
                        title: "Betti Numbers",
                        value: "[\(metricsCalculator.topologyMetrics.bettiNumbers[0]), \(metricsCalculator.topologyMetrics.bettiNumbers[1])]",
                        icon: "number"
                    )
                    MetricRow(
                        title: "Separatrix Crossings",
                        value: "\(metricsCalculator.topologyMetrics.separatrixCrossings)",
                        icon: "arrow.up.arrow.down"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Educational Metrics Section
struct EducationalMetricsSection: View {
    @ObservedObject var metricsCalculator: CSVMetricsCalculator
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionHeader(
                title: "EDUCATIONAL METRICS",
                isExpanded: $isExpanded
            )
            .padding(.horizontal, 16)

            if isExpanded {
                VStack(spacing: 8) {
                    MetricRow(
                        title: "Learning Curve Slope",
                        value: String(format: "%+.1f%%/sess", metricsCalculator.educationalMetrics.learningCurveSlope),
                        icon: "chart.line.uptrend.xyaxis"
                    )
                    MetricRow(
                        title: "Skill Retention",
                        value: formatSkillRetention(metricsCalculator.educationalMetrics.skillRetention),
                        icon: "brain.head.profile"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func formatSkillRetention(_ value: Double) -> String {
        if value < 0 {
            return "Need 2+ sessions"
        }
        return String(format: "%.0f%%", value)
    }
}

// MARK: - AI Metrics Section
struct AIMetricsSection: View {
    @ObservedObject var metricsCalculator: CSVMetricsCalculator
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionHeader(
                title: "AI METRICS",
                isExpanded: $isExpanded
            )
            .padding(.horizontal, 16)

            if isExpanded {
                VStack(spacing: 8) {
                    MetricRow(
                        title: "AI Mode",
                        value: metricsCalculator.aiMetrics.aiMode,
                        icon: "sparkles"
                    )
                    MetricRow(
                        title: "Difficulty",
                        value: metricsCalculator.aiMetrics.aiDifficulty.isEmpty ? "—" : metricsCalculator.aiMetrics.aiDifficulty,
                        icon: "slider.horizontal.3"
                    )
                    MetricRow(
                        title: "Assistance",
                        value: String(format: "%.1f%%", metricsCalculator.aiMetrics.assistancePercent),
                        icon: "hands.sparkles"
                    )
                    MetricRow(
                        title: "Avg AI Force",
                        value: String(format: "%.3f", metricsCalculator.aiMetrics.aiAvgForce),
                        icon: "bolt.fill"
                    )
                    MetricRow(
                        title: "AI Interventions",
                        value: "\(metricsCalculator.aiMetrics.totalInterventions)",
                        icon: "hand.raised"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Collapsible Section Header
struct CollapsibleSectionHeader: View {
    let title: String
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PendulumColors.textTertiary)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PendulumColors.bronze)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Metric Row
struct MetricRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.bronze)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PendulumColors.text)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(PendulumColors.gold)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

// MARK: - Health Correlation Section

private struct HealthInsight: Identifiable {
    let id = UUID()
    let metricName: String
    let icon: String
    let correlation: Double
    let description: String
    let color: Color
}

struct HealthCorrelationSection: View {
    let correlations: [HealthCorrelation]
    @State private var isExpanded = false
    @State private var insights: [HealthInsight] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionHeader(
                title: "HEALTH & PERFORMANCE",
                isExpanded: $isExpanded
            )
            .padding(.horizontal, 16)

            if isExpanded {
                VStack(spacing: 8) {
                    if insights.isEmpty {
                        HStack {
                            Image(systemName: "heart.text.square")
                                .font(.system(size: 14))
                                .foregroundStyle(PendulumColors.bronze)
                                .frame(width: 24)

                            Text("Keep playing to discover patterns")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(PendulumColors.textSecondary)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(PendulumColors.backgroundSecondary)
                        )
                    } else {
                        ForEach(insights) { insight in
                            HStack {
                                Image(systemName: insight.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(insight.color)
                                    .frame(width: 24)

                                Text(insight.description)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(PendulumColors.text)

                                Spacer()

                                Text(insight.metricName)
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(insight.color)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(PendulumColors.backgroundSecondary)
                            )
                        }
                    }

                    // Session count subtitle
                    Text("Based on \(correlations.count) sessions")
                        .font(.system(size: 11))
                        .foregroundStyle(PendulumColors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear { computeInsights() }
    }

    // MARK: - Correlation Computation

    private func computeInsights() {
        let scores = correlations.map { Double($0.sessionScore) }

        var candidates: [(name: String, icon: String, r: Double)] = []

        // HRV vs Score
        let hrvPairs = correlations.compactMap { c -> (Double, Double)? in
            guard let hrv = c.healthSnapshot.heartRateVariability else { return nil }
            return (hrv, Double(c.sessionScore))
        }
        if hrvPairs.count >= 5 {
            let r = pearsonR(hrvPairs.map(\.0), hrvPairs.map(\.1))
            candidates.append(("HRV", HealthDataType.heartRateVariability.icon, r))
        }

        // Sleep vs Score
        let sleepPairs = correlations.compactMap { c -> (Double, Double)? in
            guard let sleep = c.healthSnapshot.sleepDuration else { return nil }
            return (sleep / 3600.0, Double(c.sessionScore))
        }
        if sleepPairs.count >= 5 {
            let r = pearsonR(sleepPairs.map(\.0), sleepPairs.map(\.1))
            candidates.append(("Sleep", HealthDataType.sleep.icon, r))
        }

        // Steps vs Score
        let stepPairs = correlations.compactMap { c -> (Double, Double)? in
            guard let steps = c.healthSnapshot.steps else { return nil }
            return (Double(steps), Double(c.sessionScore))
        }
        if stepPairs.count >= 5 {
            let r = pearsonR(stepPairs.map(\.0), stepPairs.map(\.1))
            candidates.append(("Steps", HealthDataType.steps.icon, r))
        }

        // Resting HR vs Score
        let hrPairs = correlations.compactMap { c -> (Double, Double)? in
            guard let hr = c.healthSnapshot.restingHeartRate else { return nil }
            return (hr, Double(c.sessionScore))
        }
        if hrPairs.count >= 5 {
            let r = pearsonR(hrPairs.map(\.0), hrPairs.map(\.1))
            candidates.append(("Resting HR", HealthDataType.restingHeartRate.icon, r))
        }

        // Active Calories vs Score
        let calPairs = correlations.compactMap { c -> (Double, Double)? in
            guard let cal = c.healthSnapshot.activeCalories else { return nil }
            return (cal, Double(c.sessionScore))
        }
        if calPairs.count >= 5 {
            let r = pearsonR(calPairs.map(\.0), calPairs.map(\.1))
            candidates.append(("Calories", HealthDataType.activeCalories.icon, r))
        }

        // Filter to moderate+ (|r| >= 0.3), sort by strength, take top 3
        insights = candidates
            .filter { abs($0.r) >= 0.3 }
            .sorted { abs($0.r) > abs($1.r) }
            .prefix(3)
            .map { candidate in
                let strength = abs(candidate.r) >= 0.5 ? "Strong" : "Moderate"
                let color: Color = abs(candidate.r) >= 0.5 ? PendulumColors.gold : PendulumColors.bronze
                let direction = candidate.r > 0 ? "higher" : "lower"
                let moreOrLess = candidate.r > 0 ? "More" : "Less"
                let description = "\(moreOrLess) \(candidate.name.lowercased()) → \(direction) scores (\(strength.lowercased()))"

                return HealthInsight(
                    metricName: String(format: "r=%.2f", candidate.r),
                    icon: candidate.icon,
                    correlation: candidate.r,
                    description: description,
                    color: color
                )
            }
    }

    private func pearsonR(_ x: [Double], _ y: [Double]) -> Double {
        guard x.count == y.count, x.count >= 5 else { return 0 }
        let n = Double(x.count)
        let meanX = x.reduce(0, +) / n
        let meanY = y.reduce(0, +) / n
        var cov = 0.0, varX = 0.0, varY = 0.0
        for i in 0..<x.count {
            let dx = x[i] - meanX
            let dy = y[i] - meanY
            cov += dx * dy
            varX += dx * dx
            varY += dy * dy
        }
        guard varX > 0, varY > 0 else { return 0 }
        return cov / sqrt(varX * varY)
    }
}

// MARK: - Preview
#Preview {
    DashboardView(gameState: GameState())
}
