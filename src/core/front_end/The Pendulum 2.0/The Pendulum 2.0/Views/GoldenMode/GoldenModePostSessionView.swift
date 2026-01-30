// GoldenModePostSessionView.swift
// The Pendulum 2.0
// Post-session summary sheet for Golden Mode

import SwiftUI

struct GoldenModePostSessionView: View {
  @ObservedObject var gameState: GameState
  @ObservedObject var goldenManager = GoldenModeManager.shared
  @Environment(\.dismiss) private var dismiss

  let sessionDuration: TimeInterval
  let levelsCompleted: Int
  let sessionScore: Int

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Result header
          resultHeader

          // Session stats grid
          statsGrid

          // Coherence update
          coherenceSection

          // Next session hint
          nextSessionHint

          // Done button
          Button {
            dismiss()
          } label: {
            Text("Done")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(GoldButtonStyle())
          .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
      }
      .background(PendulumColors.background)
      .navigationTitle("Session Complete")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
            .foregroundStyle(PendulumColors.gold)
        }
      }
    }
  }

  // MARK: - Result Header

  private var resultHeader: some View {
    VStack(spacing: 12) {
      Image(systemName: "sun.max.fill")
        .font(.system(size: 48))
        .foregroundStyle(PendulumColors.gold)

      Text(resultTitle)
        .font(.system(size: 22, weight: .bold, design: .serif))
        .foregroundStyle(PendulumColors.text)

      if let focusName = goldenManager.currentFocusAreaName {
        Text("Focus: \(focusName)")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(PendulumColors.textSecondary)
      }
    }
    .padding(16)
  }

  private var resultTitle: String {
    if sessionDuration < 60 {
      return "Keep Going"
    } else if sessionScore > 500 {
      return "Excellent Session"
    } else if sessionScore > 200 {
      return "Good Session"
    } else {
      return "Session Complete"
    }
  }

  // MARK: - Stats Grid

  private var statsGrid: some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
      statCard("Duration", value: formatDuration(sessionDuration), icon: "clock.fill")
      statCard("Score", value: "\(sessionScore)", icon: "star.fill")
      statCard("Levels", value: "\(levelsCompleted)", icon: "chart.bar.fill")
      statCard("Adaptations", value: "\(goldenManager.adaptationCountPublic)", icon: "arrow.triangle.2.circlepath")
    }
    .padding(.horizontal, 16)
  }

  private func statCard(_ title: String, value: String, icon: String) -> some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 18))
        .foregroundStyle(PendulumColors.gold)

      Text(value)
        .font(.system(size: 20, weight: .bold, design: .rounded))
        .foregroundStyle(PendulumColors.text)

      Text(title)
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(PendulumColors.backgroundSecondary)
    )
  }

  // MARK: - Coherence Section

  private var coherenceSection: some View {
    VStack(spacing: 8) {
      ResonanceMeterView(
        score: goldenManager.coherenceScore,
        label: goldenManager.coherenceLabel
      )

      Text("Coherence Score")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)

      Text("Session \(goldenManager.outcomeCount) of your Golden Mode journey")
        .font(.system(size: 12))
        .foregroundStyle(PendulumColors.textTertiary)
    }
    .padding(16)
  }

  // MARK: - Next Session Hint

  private var nextSessionHint: some View {
    HStack(spacing: 10) {
      Image(systemName: "lightbulb.fill")
        .font(.system(size: 16))
        .foregroundStyle(PendulumColors.gold)

      Text(nextHintText)
        .font(.system(size: 13))
        .foregroundStyle(PendulumColors.textSecondary)
        .multilineTextAlignment(.leading)

      Spacer()
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(PendulumColors.goldLight.opacity(0.08))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(PendulumColors.gold.opacity(0.2), lineWidth: 1)
    )
    .padding(.horizontal, 16)
  }

  private var nextHintText: String {
    let count = goldenManager.outcomeCount
    if count < 5 {
      return "Keep playing to improve recommendations. \(5 - count) more sessions unlock the weighted scorer."
    } else if count < 20 {
      return "Recommendations are improving with your data. \(20 - count) more sessions unlock ML-based predictions."
    } else {
      return "Full ML predictions active. Your sessions are shaping a personalized experience."
    }
  }

  // MARK: - Helpers

  private func formatDuration(_ seconds: TimeInterval) -> String {
    let mins = Int(seconds) / 60
    let secs = Int(seconds) % 60
    return String(format: "%d:%02d", mins, secs)
  }
}

#Preview {
  GoldenModePostSessionView(
    gameState: GameState(),
    sessionDuration: 185,
    levelsCompleted: 3,
    sessionScore: 420
  )
}
