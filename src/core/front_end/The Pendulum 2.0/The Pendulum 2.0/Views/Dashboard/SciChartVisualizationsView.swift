// SciChartVisualizationsView.swift
// The Pendulum 2.0
// Swift Charts-based visualizations for Angular Deviation and Learning Curve
// (Using Swift Charts instead of SciChart to avoid Metal rendering issues)

import SwiftUI
import Charts

// MARK: - Angular Deviation Chart Card
struct AngularDeviationSciChartCard: View {
    let data: [AngularDeviationPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Angular Deviation")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Text("θ over time")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            AngularDeviationChartView(data: data)
                .frame(height: 200)
                .clipped()

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(PendulumColors.caution)
                        .frame(width: 8, height: 8)
                    Text("Angle from upright")
                        .font(.system(size: 10))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                HStack(spacing: 4) {
                    Rectangle()
                        .fill(PendulumColors.success.opacity(0.3))
                        .frame(width: 16, height: 8)
                    Text("Balance zone (±20°)")
                        .font(.system(size: 10))
                        .foregroundStyle(PendulumColors.textSecondary)
                }
            }
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

// MARK: - Angular Deviation Swift Chart View
struct AngularDeviationChartView: View {
    let data: [AngularDeviationPoint]

    private var xRange: ClosedRange<Double> {
        guard !data.isEmpty else { return 0...10 }
        let maxTime = data.map { $0.time }.max() ?? 10
        return 0...max(maxTime * 1.1, 5)
    }

    private var yRange: ClosedRange<Double> {
        guard !data.isEmpty else { return -45...45 }
        let maxAngle = data.map { abs($0.angleDegrees) }.max() ?? 45
        // At minimum show ±30, but expand if data goes beyond
        let range = max(maxAngle * 1.2, 30)
        return -range...range
    }

    var body: some View {
        Chart {
            // Balance zone band (-20 to +20 degrees) - always visible
            RectangleMark(
                xStart: .value("Start", xRange.lowerBound),
                xEnd: .value("End", xRange.upperBound),
                yStart: .value("Lower", -20),
                yEnd: .value("Upper", 20)
            )
            .foregroundStyle(PendulumColors.success.opacity(0.15))

            // Zero line (equilibrium)
            RuleMark(y: .value("Zero", 0))
                .foregroundStyle(PendulumColors.success)
                .lineStyle(StrokeStyle(lineWidth: 1.5))

            // Angular deviation line (draw line first, then area for proper layering)
            ForEach(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Angle", point.angleDegrees)
                )
                .foregroundStyle(PendulumColors.caution)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartXScale(domain: xRange)
        .chartYScale(domain: yRange)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(PendulumColors.bronze.opacity(0.15))
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(PendulumColors.textTertiary)
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(PendulumColors.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(PendulumColors.bronze.opacity(0.15))
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(PendulumColors.textTertiary)
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(PendulumColors.textTertiary)
            }
        }
        .chartXAxisLabel("Time (s)", position: .bottom, alignment: .center)
        .chartYAxisLabel("Angle (°)", position: .leading, alignment: .center)
    }
}

// MARK: - Learning Curve Chart Card
struct LearningCurveSciChartCard: View {
    let data: [LearningCurvePoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Learning Curve")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Text("Skill progression")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            LearningCurveChartView(data: data)
                .frame(height: 200)
                .clipped()

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(PendulumColors.success)
                        .frame(width: 8, height: 8)
                    Text("Skill level")
                        .font(.system(size: 10))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(PendulumColors.gold)
                        .frame(width: 6, height: 6)
                    Text("Session markers")
                        .font(.system(size: 10))
                        .foregroundStyle(PendulumColors.textSecondary)
                }
            }
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

// MARK: - Learning Curve Swift Chart View
struct LearningCurveChartView: View {
    let data: [LearningCurvePoint]

    private var xRange: ClosedRange<Double> {
        guard !data.isEmpty else { return 0.5...10.5 }
        let maxSession = Double(data.map { $0.sessionNumber }.max() ?? 10)
        return 0.5...(maxSession + 0.5)
    }

    var body: some View {
        Chart {
            // Mastery threshold line at 80%
            RuleMark(y: .value("Mastery", 80))
                .foregroundStyle(PendulumColors.gold.opacity(0.6))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                .annotation(position: .topLeading, alignment: .leading) {
                    Text("Mastery")
                        .font(.system(size: 9))
                        .foregroundStyle(PendulumColors.gold)
                        .padding(.leading, 4)
                }

            // Area under the curve
            ForEach(data) { point in
                AreaMark(
                    x: .value("Session", point.sessionNumber),
                    y: .value("Skill", point.skillPercentage)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            PendulumColors.success.opacity(0.3),
                            PendulumColors.success.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Line
            ForEach(data) { point in
                LineMark(
                    x: .value("Session", point.sessionNumber),
                    y: .value("Skill", point.skillPercentage)
                )
                .foregroundStyle(PendulumColors.success)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
            }

            // Session points
            ForEach(data) { point in
                PointMark(
                    x: .value("Session", point.sessionNumber),
                    y: .value("Skill", point.skillPercentage)
                )
                .foregroundStyle(PendulumColors.gold)
                .symbolSize(40)
            }
        }
        .chartXScale(domain: xRange)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(PendulumColors.bronze.opacity(0.15))
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(PendulumColors.textTertiary)
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(PendulumColors.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(PendulumColors.bronze.opacity(0.15))
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(PendulumColors.textTertiary)
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(PendulumColors.textTertiary)
            }
        }
        .chartXAxisLabel("Session #", position: .bottom, alignment: .center)
        .chartYAxisLabel("Skill (%)", position: .leading, alignment: .center)
    }
}

// MARK: - Previews
#Preview("Angular Deviation") {
    let sampleData: [AngularDeviationPoint] = (0..<50).map { i in
        let t = Double(i) * 0.2
        let angle = sin(t * 0.5) * 30 + Double.random(in: -5...5)
        return AngularDeviationPoint(time: t, angleDegrees: angle)
    }

    return AngularDeviationSciChartCard(data: sampleData)
        .padding()
        .background(PendulumColors.background)
}

#Preview("Learning Curve") {
    let sampleData: [LearningCurvePoint] = (1...10).map { i in
        let skill = min(100, Double(i) * 8 + Double.random(in: 0...10))
        return LearningCurvePoint(sessionNumber: i, skillPercentage: skill)
    }

    return LearningCurveSciChartCard(data: sampleData)
        .padding()
        .background(PendulumColors.background)
}
