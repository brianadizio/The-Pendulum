// DayComparisonView.swift
// The Pendulum 2.0
// Stacked Day 1 vs Day 2 waveforms with delta metrics

import SwiftUI

struct DayComparisonView: View {
  let currentData: NatureData
  let previousData: NatureData
  let animationProgress: Double
  let drawComplete: Bool

  private var stabilityDelta: Double {
    currentData.stabilityScore - previousData.stabilityScore
  }

  private var archetypeChanged: Bool {
    currentData.archetypeResult.archetype != previousData.archetypeResult.archetype
  }

  var body: some View {
    VStack(spacing: 16) {
      // Day 1 waveform (smaller)
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 6) {
          Text("Day 1")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(PendulumColors.silver)
          Text("Score: \(Int(previousData.stabilityScore))")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(PendulumColors.textTertiary)
          Spacer()
        }
        .padding(.horizontal, 16)

        BalanceTimelineView(
          natureData: previousData,
          animationProgress: 1.0, // Show fully drawn
          drawComplete: true
        )
        .frame(height: UIScreen.main.bounds.height * 0.18)
        .opacity(0.7)
        .padding(.horizontal, 16)
      }

      // Arrow separator
      Image(systemName: "arrow.down")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(PendulumColors.gold.opacity(0.5))

      // Day 2 waveform (larger, animated)
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 6) {
          Text("Day 2")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(PendulumColors.gold)
          Text("Score: \(Int(currentData.stabilityScore))")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(PendulumColors.textTertiary)
          Spacer()
        }
        .padding(.horizontal, 16)

        BalanceTimelineView(
          natureData: currentData,
          animationProgress: animationProgress,
          drawComplete: drawComplete
        )
        .frame(height: UIScreen.main.bounds.height * 0.28)
        .padding(.horizontal, 16)
      }

      // Delta metrics row
      deltaMetricsRow
        .padding(.horizontal, 20)

      // Narrative
      Text("Your vestibular system is adapting. Most users see the shift to predictive control between Day 3 and Day 5.")
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(PendulumColors.textSecondary)
        .lineSpacing(3)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }
  }

  private var deltaMetricsRow: some View {
    HStack(spacing: 20) {
      // Stability delta
      VStack(spacing: 4) {
        HStack(spacing: 4) {
          Image(systemName: stabilityDelta >= 0 ? "arrow.up.right" : "arrow.down.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(stabilityDelta >= 0 ? PendulumColors.success : PendulumColors.caution)
          Text(String(format: "%+.0f", stabilityDelta))
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(stabilityDelta >= 0 ? PendulumColors.success : PendulumColors.caution)
        }
        Text("Stability")
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(PendulumColors.textTertiary)
      }

      // Archetype shift
      if archetypeChanged {
        VStack(spacing: 4) {
          HStack(spacing: 4) {
            Image(systemName: previousData.archetypeResult.archetype.icon)
              .font(.system(size: 12))
              .foregroundStyle(PendulumColors.textTertiary)
            Image(systemName: "arrow.right")
              .font(.system(size: 10))
              .foregroundStyle(PendulumColors.silver)
            Image(systemName: currentData.archetypeResult.archetype.icon)
              .font(.system(size: 12))
              .foregroundStyle(PendulumColors.gold)
          }
          Text("Style Shift")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(PendulumColors.textTertiary)
        }
      }

      // Duration improvement
      let prevAvg = previousData.attempts.map(\.duration).reduce(0, +) / max(Double(previousData.attempts.count), 1)
      let currAvg = currentData.attempts.map(\.duration).reduce(0, +) / max(Double(currentData.attempts.count), 1)
      let durationDelta = currAvg - prevAvg

      VStack(spacing: 4) {
        HStack(spacing: 4) {
          Image(systemName: durationDelta >= 0 ? "arrow.up.right" : "arrow.down.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(durationDelta >= 0 ? PendulumColors.success : PendulumColors.caution)
          Text(String(format: "%+.1fs", durationDelta))
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(durationDelta >= 0 ? PendulumColors.success : PendulumColors.caution)
        }
        Text("Avg Duration")
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(PendulumColors.textTertiary)
      }
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 16)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(PendulumColors.backgroundTertiary)
    )
  }
}
