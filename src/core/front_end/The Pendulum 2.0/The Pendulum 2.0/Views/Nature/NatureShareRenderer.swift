// NatureShareRenderer.swift
// The Pendulum 2.0
// Renders the Pendulum Nature visualization as a shareable image

import SwiftUI

enum NatureShareRenderer {

  @MainActor
  static func renderShareImage(natureData: NatureData) -> UIImage? {
    let shareView = NatureShareContent(natureData: natureData)
    let renderer = ImageRenderer(content: shareView)
    renderer.scale = 3.0 // Retina quality
    return renderer.uiImage
  }
}

// MARK: - Share Content View

private struct NatureShareContent: View {
  let natureData: NatureData

  var body: some View {
    VStack(spacing: 20) {
      // Header
      Text("YOUR PENDULUM NATURE")
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(.white.opacity(0.6))
        .tracking(3)
        .padding(.top, 24)

      // Waveform visualization
      BalanceTimelineView(
        natureData: natureData,
        animationProgress: 1.0,
        drawComplete: false
      )
      .frame(width: 340, height: 200)

      // Archetype
      VStack(spacing: 6) {
        HStack(spacing: 8) {
          Image(systemName: natureData.archetypeResult.archetype.icon)
            .font(.system(size: 20))
          Text(natureData.archetypeResult.archetype.displayName)
            .font(.system(size: 22, weight: .bold))
        }
        .foregroundStyle(.white)

        Text(String(format: "Stability Score: %.0f/100", natureData.stabilityScore))
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.white.opacity(0.7))
      }

      // Attempt durations
      HStack(spacing: 12) {
        ForEach(Array(natureData.attempts.prefix(5).enumerated()), id: \.offset) { idx, attempt in
          VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
              .fill(attemptColor(for: attempt))
              .frame(width: 24, height: barHeight(for: attempt))
            Text(String(format: "%.1fs", attempt.duration))
              .font(.system(size: 9, weight: .medium))
              .foregroundStyle(.white.opacity(0.5))
          }
        }
      }
      .frame(height: 70)

      // Watermark
      Text("The Pendulum 2.0 by Golden Enterprises")
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.white.opacity(0.3))
        .padding(.bottom, 16)
    }
    .frame(width: 390, height: 480)
    .background(Color(red: 0.051, green: 0.051, blue: 0.102))
  }

  private func attemptColor(for attempt: AttemptData) -> Color {
    if attempt.duration > 10 {
      return Color(red: 0.30, green: 0.69, blue: 0.31)
    } else if attempt.duration > 5 {
      return Color(red: 0.95, green: 0.77, blue: 0.06)
    } else {
      return Color(red: 0.95, green: 0.55, blue: 0.13)
    }
  }

  private func barHeight(for attempt: AttemptData) -> CGFloat {
    let maxDuration = natureData.attempts.map { $0.duration }.max() ?? 1.0
    return max(CGFloat(attempt.duration / maxDuration) * 50.0, 4.0)
  }
}
