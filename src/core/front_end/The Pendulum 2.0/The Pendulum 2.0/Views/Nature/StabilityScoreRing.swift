// StabilityScoreRing.swift
// The Pendulum 2.0
// Apple Watch-style circular progress ring for stability score

import SwiftUI

struct StabilityScoreRing: View {
  let score: Double
  @State private var animatedFraction: Double = 0.0

  private var fraction: Double { min(max(score / 100.0, 0), 1) }

  private var ringColor: Color {
    if score >= 70 {
      return Color(red: 0.30, green: 0.69, blue: 0.31)
    } else if score >= 40 {
      return Color(red: 0.95, green: 0.77, blue: 0.06)
    } else {
      return Color(red: 0.80, green: 0.20, blue: 0.15)
    }
  }

  private var ringGradient: AngularGradient {
    AngularGradient(
      gradient: Gradient(colors: [
        Color(red: 0.80, green: 0.20, blue: 0.15),
        Color(red: 0.95, green: 0.77, blue: 0.06),
        Color(red: 0.30, green: 0.69, blue: 0.31),
      ]),
      center: .center,
      startAngle: .degrees(-90),
      endAngle: .degrees(-90 + 360 * animatedFraction)
    )
  }

  var body: some View {
    VStack(spacing: 6) {
      ZStack {
        // Full ghost track showing 0-100 spectrum
        Circle()
          .stroke(
            AngularGradient(
              gradient: Gradient(colors: [
                Color(red: 0.80, green: 0.20, blue: 0.15).opacity(0.08),
                Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.08),
                Color(red: 0.30, green: 0.69, blue: 0.31).opacity(0.08),
              ]),
              center: .center,
              startAngle: .degrees(-90),
              endAngle: .degrees(270)
            ),
            style: StrokeStyle(lineWidth: 8, lineCap: .round)
          )

        // Track outline
        Circle()
          .stroke(PendulumColors.silver.opacity(0.12), lineWidth: 8)

        // Filled ring
        Circle()
          .trim(from: 0, to: animatedFraction)
          .stroke(
            ringGradient,
            style: StrokeStyle(lineWidth: 8, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))

        // Score text
        VStack(spacing: 0) {
          Text("\(Int(score))")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(PendulumColors.text)

          Text("/100")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(PendulumColors.textSecondary)
        }
      }

      Text("Stability")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)
    }
    .onAppear {
      withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
        animatedFraction = fraction
      }
    }
  }
}
