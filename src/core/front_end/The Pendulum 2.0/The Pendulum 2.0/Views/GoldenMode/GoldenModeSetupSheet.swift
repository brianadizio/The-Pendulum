// GoldenModeSetupSheet.swift
// The Pendulum 2.0
// Bottom sheet for Golden Mode pre-session setup and recommendation

import SwiftUI
import PendulumSolver

struct GoldenModeSetupSheet: View {
  @ObservedObject var gameState: GameState
  @ObservedObject var goldenManager = GoldenModeManager.shared
  @Environment(\.dismiss) private var dismiss

  @State private var recommendation: GoldenModeRecommendation?
  @State private var isGenerating = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Coherence header
          coherenceSection

          // Recommendation card
          if let rec = recommendation {
            recommendationCard(rec)
          } else if isGenerating {
            ProgressView("Analyzing your data...")
              .padding(32)
          }

          // Data readiness
          dataReadinessSection

          // Action button
          if recommendation != nil {
            Button {
              gameState.gameMode = .golden
              dismiss()
            } label: {
              HStack {
                Image(systemName: "play.fill")
                Text("Start Golden Session")
              }
              .frame(maxWidth: .infinity)
            }
            .buttonStyle(GoldButtonStyle())
            .padding(.horizontal, 16)
          }
        }
        .padding(.vertical, 16)
      }
      .background(PendulumColors.background)
      .navigationTitle("Golden Mode")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
            .foregroundStyle(PendulumColors.gold)
        }
      }
    }
    .onAppear {
      generateRecommendation()
    }
  }

  // MARK: - Sections

  private var coherenceSection: some View {
    VStack(spacing: 8) {
      ResonanceMeterView(
        score: goldenManager.coherenceScore,
        label: goldenManager.coherenceLabel
      )

      Text("Coherence Score")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)

      Text("Measures alignment between your health, skills, and context")
        .font(.system(size: 12))
        .foregroundStyle(PendulumColors.textTertiary)
        .multilineTextAlignment(.center)
    }
    .padding(16)
  }

  private func recommendationCard(_ rec: GoldenModeRecommendation) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: rec.focusArea.icon)
          .font(.system(size: 20))
          .foregroundStyle(PendulumColors.gold)

        Text(rec.focusArea.displayName)
          .font(.system(size: 18, weight: .bold, design: .serif))
          .foregroundStyle(PendulumColors.text)

        Spacer()

        Text(goldenManager.currentTier)
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(PendulumColors.textTertiary)
          .padding(.horizontal, 8)
          .padding(.vertical, 3)
          .background(Capsule().fill(PendulumColors.backgroundSecondary))
      }

      Text(rec.focusArea.benefit)
        .font(.system(size: 13))
        .foregroundStyle(PendulumColors.textSecondary)

      Divider()

      // Config details
      VStack(alignment: .leading, spacing: 6) {
        configRow("Mode", rec.config.gameMode)
        configRow("AI", rec.config.aiMode)
        configRow("Level", "\(rec.config.suggestedLevel)")
        configRow("Duration", "\(Int(rec.config.targetDurationMinutes)) min")
        configRow("Confidence", String(format: "%.0f%%", rec.confidenceScore * 100))
      }

      Text(rec.reasoning)
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(PendulumColors.textTertiary)
        .padding(.top, 4)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(PendulumColors.gold.opacity(0.3), lineWidth: 1)
    )
    .padding(.horizontal, 16)
  }

  private func configRow(_ label: String, _ value: String) -> some View {
    HStack {
      Text(label)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)
        .frame(width: 80, alignment: .leading)

      Text(value)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(PendulumColors.text)
    }
  }

  private var dataReadinessSection: some View {
    let readiness = goldenManager.dataReadiness

    return VStack(alignment: .leading, spacing: 8) {
      Text("DATA SOURCES")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)

      HStack(spacing: 16) {
        dataChip("Health", icon: "heart.fill", connected: readiness.healthConnected)
        dataChip("Profile", icon: "person.fill", connected: readiness.profileComplete)
        dataChip("Sessions", icon: "chart.bar.fill", connected: readiness.hasPlayHistory)
        dataChip("Maze", icon: "square.grid.3x3.fill", connected: readiness.mazeConnected)
      }
    }
    .padding(.horizontal, 16)
  }

  private func dataChip(_ label: String, icon: String, connected: Bool) -> some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .font(.system(size: 14))
        .foregroundStyle(connected ? PendulumColors.gold : PendulumColors.silver)

      Text(label)
        .font(.system(size: 9, weight: .medium))
        .foregroundStyle(connected ? PendulumColors.text : PendulumColors.textTertiary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(connected ? PendulumColors.goldLight.opacity(0.1) : PendulumColors.backgroundSecondary)
    )
  }

  // MARK: - Actions

  private func generateRecommendation() {
    isGenerating = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      let rec = goldenManager.generateRecommendation()
      _ = goldenManager.computeCoherence()
      recommendation = rec
      isGenerating = false
    }
  }
}

#Preview {
  GoldenModeSetupSheet(gameState: GameState())
}
