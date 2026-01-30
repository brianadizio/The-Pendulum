// ResonanceMeterView.swift
// The Pendulum 2.0
// Animated arc meter showing Coherence Score (0-100)

import SwiftUI

struct ResonanceMeterView: View {
  let score: Double       // 0-100
  let label: String       // e.g. "Resonant"
  let compact: Bool

  init(score: Double, label: String, compact: Bool = false) {
    self.score = score
    self.label = label
    self.compact = compact
  }

  private var fraction: Double { min(max(score / 100.0, 0), 1) }

  private var arcColor: Color {
    switch score {
    case 0..<31:  return PendulumColors.danger
    case 31..<61: return PendulumColors.caution
    case 61..<86: return PendulumColors.gold
    default:      return PendulumColors.success
    }
  }

  var body: some View {
    let size: CGFloat = compact ? 64 : 120
    let lineWidth: CGFloat = compact ? 5 : 8

    VStack(spacing: compact ? 2 : 8) {
      ZStack {
        // Track
        Arc()
          .stroke(PendulumColors.silver.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
          .frame(width: size, height: size * 0.6)

        // Filled arc
        Arc()
          .trim(from: 0, to: fraction)
          .stroke(arcColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
          .frame(width: size, height: size * 0.6)
          .animation(.easeInOut(duration: 0.8), value: fraction)

        // Score text
        Text("\(Int(score))")
          .font(.system(size: compact ? 16 : 28, weight: .bold, design: .rounded))
          .foregroundStyle(PendulumColors.text)
          .offset(y: compact ? 4 : 8)
      }
      .frame(height: size * 0.6 + lineWidth)

      if !compact {
        Text(label)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(arcColor)
      }
    }
  }
}

// MARK: - Arc Shape
private struct Arc: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.maxY)
    let radius = min(rect.width, rect.height * 2) / 2
    path.addArc(
      center: center,
      radius: radius,
      startAngle: .degrees(180),
      endAngle: .degrees(0),
      clockwise: false
    )
    return path
  }
}

#Preview {
  VStack(spacing: 24) {
    ResonanceMeterView(score: 72, label: "Resonant")
    ResonanceMeterView(score: 45, label: "Aligning", compact: true)
  }
  .padding()
  .background(PendulumColors.background)
}
