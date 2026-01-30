// PhaseSpaceChartView.swift
// The Pendulum 2.0
// Phase Space visualization (θ vs ω) using Swift Charts (CPU-based, no Metal issues)

import SwiftUI
import Charts

// MARK: - Phase Space Data Point
struct PhaseSpacePoint: Identifiable {
    let id = UUID()
    let index: Int         // Sequential index for ordering
    let theta: Double      // Angle in radians (distance from π, normalized to [-π, π])
    let thetaDot: Double   // Angular velocity in rad/s (clamped to reasonable range)

    // Convenience for degrees
    var thetaDegrees: Double { theta * 180.0 / .pi }

    init(index: Int = 0, theta: Double, thetaDot: Double) {
        self.index = index
        // Normalize theta to [-π, π] using atan2 (same as old app)
        self.theta = atan2(sin(theta), cos(theta))
        // Clamp omega to ±10 rad/s to prevent extreme values
        self.thetaDot = max(-10.0, min(10.0, thetaDot))
    }
}

// MARK: - Phase Space Chart Card
struct PhaseSpaceSciChartCard: View {
    let data: [PhaseSpacePoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Phase Space")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Text("θ vs ω")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            PhaseSpaceChartView(data: data)
                .frame(height: 250)
                .clipped()

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(PendulumColors.gold)
                        .frame(width: 8, height: 8)
                    Text("Trajectory")
                        .font(.system(size: 10))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(PendulumColors.success)
                        .frame(width: 8, height: 8)
                    Text("Equilibrium (0,0)")
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

// MARK: - Phase Space Swift Chart View
struct PhaseSpaceChartView: View {
    let data: [PhaseSpacePoint]

    private var xRange: ClosedRange<Double> {
        guard !data.isEmpty else { return -45...45 }
        let maxTheta = data.map { abs($0.thetaDegrees) }.max() ?? 45
        let range = max(maxTheta * 1.2, 30)
        return -range...range
    }

    private var yRange: ClosedRange<Double> {
        guard !data.isEmpty else { return -5...5 }
        let maxOmega = data.map { abs($0.thetaDot) }.max() ?? 5
        let range = max(maxOmega * 1.2, 3)
        return -range...range
    }

    var body: some View {
        Chart {
            // Origin crosshairs (draw first, behind trajectory)
            RuleMark(x: .value("x", 0))
                .foregroundStyle(PendulumColors.bronze.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

            RuleMark(y: .value("y", 0))
                .foregroundStyle(PendulumColors.bronze.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

            // Trajectory as connected line - use index as series to connect points in order
            ForEach(data) { point in
                LineMark(
                    x: .value("θ", point.thetaDegrees),
                    y: .value("ω", point.thetaDot),
                    series: .value("Trajectory", "main")
                )
                .foregroundStyle(PendulumColors.gold.opacity(0.8))
                .lineStyle(StrokeStyle(lineWidth: 2))
            }

            // Show fewer points to reduce clutter (every 5th point)
            ForEach(data.enumerated().filter { $0.offset % 5 == 0 }.map { $0.element }) { point in
                PointMark(
                    x: .value("θ", point.thetaDegrees),
                    y: .value("ω", point.thetaDot)
                )
                .foregroundStyle(PendulumColors.gold)
                .symbolSize(6)
            }

            // Equilibrium point at origin (larger, prominent)
            PointMark(
                x: .value("θ", 0),
                y: .value("ω", 0)
            )
            .foregroundStyle(PendulumColors.success)
            .symbolSize(60)
            .symbol(.circle)
        }
        .chartXScale(domain: xRange)
        .chartYScale(domain: yRange)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(PendulumColors.bronze.opacity(0.2))
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(PendulumColors.textTertiary)
                AxisValueLabel()
                    .font(.system(size: 10))
                    .foregroundStyle(PendulumColors.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(PendulumColors.bronze.opacity(0.2))
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(PendulumColors.textTertiary)
                AxisValueLabel()
                    .font(.system(size: 10))
                    .foregroundStyle(PendulumColors.textTertiary)
            }
        }
        .chartXAxisLabel("Angle θ (°)", position: .bottom, alignment: .center)
        .chartYAxisLabel("Angular Velocity ω (rad/s)", position: .leading, alignment: .center)
        .padding(4)
    }
}

// MARK: - Preview
#Preview {
    // Sample data showing a spiral trajectory (damped oscillation)
    let sampleData: [PhaseSpacePoint] = (0..<100).map { i in
        let t = Double(i) * 0.1
        let decay = exp(-t * 0.1)
        return PhaseSpacePoint(
            index: i,
            theta: decay * sin(t) * 0.5,  // radians (will be normalized)
            thetaDot: decay * cos(t) * 3   // rad/s (will be clamped)
        )
    }

    return PhaseSpaceSciChartCard(data: sampleData)
        .padding()
        .background(PendulumColors.background)
}
