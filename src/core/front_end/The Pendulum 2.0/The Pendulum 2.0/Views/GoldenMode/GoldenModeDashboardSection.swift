// GoldenModeDashboardSection.swift
// The Pendulum 2.0
// Dashboard section showing Golden Mode metrics and history

import SwiftUI
import PendulumSolver

struct GoldenModeDashboardSection: View {
  @ObservedObject var goldenManager = GoldenModeManager.shared
  @State private var isExpanded = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Collapsible header
      Button {
        withAnimation(.easeInOut(duration: 0.25)) {
          isExpanded.toggle()
        }
      } label: {
        HStack {
          Image(systemName: "sun.max.fill")
            .font(.system(size: 14))
            .foregroundStyle(PendulumColors.gold)

          Text("GOLDEN MODE")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(PendulumColors.textTertiary)

          Spacer()

          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(PendulumColors.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
      }
      .buttonStyle(PlainButtonStyle())

      if isExpanded {
        VStack(spacing: 12) {
          // Coherence meter
          coherenceCard

          // Outcome stats
          outcomeStatsGrid

          // Recent outcomes list
          if !goldenManager.recentOutcomes.isEmpty {
            recentOutcomesList
          }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
  }

  // MARK: - Coherence Card

  private var coherenceCard: some View {
    HStack(spacing: 16) {
      ResonanceMeterView(
        score: goldenManager.coherenceScore,
        label: goldenManager.coherenceLabel,
        compact: true
      )

      VStack(alignment: .leading, spacing: 4) {
        Text("Coherence")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(PendulumColors.text)

        Text("Alignment across health, skills & context")
          .font(.system(size: 11))
          .foregroundStyle(PendulumColors.textTertiary)

        Text("Tier: \(goldenManager.currentTier)")
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(PendulumColors.gold)
      }

      Spacer()
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(PendulumColors.backgroundSecondary)
    )
  }

  // MARK: - Outcome Stats Grid

  private var outcomeStatsGrid: some View {
    let outcomes = goldenManager.recentOutcomes

    let totalSessions = outcomes.count
    let avgDuration: Double = outcomes.isEmpty ? 0 :
      outcomes.map(\.sessionDuration).reduce(0, +) / Double(outcomes.count)
    let avgScore: Double = outcomes.isEmpty ? 0 :
      Double(outcomes.compactMap(\.score).reduce(0, +)) / max(1, Double(outcomes.compactMap(\.score).count))
    let completionRate: Double = outcomes.isEmpty ? 0 :
      Double(outcomes.filter(\.sessionCompleted).count) / Double(outcomes.count) * 100

    return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
      goldenMetricRow("Sessions", value: "\(totalSessions)", icon: "play.circle.fill")
      goldenMetricRow("Avg Duration", value: formatDuration(avgDuration), icon: "clock.fill")
      goldenMetricRow("Avg Score", value: String(format: "%.0f", avgScore), icon: "star.fill")
      goldenMetricRow("Completion", value: String(format: "%.0f%%", completionRate), icon: "checkmark.circle.fill")
    }
  }

  private func goldenMetricRow(_ title: String, value: String, icon: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 12))
        .foregroundStyle(PendulumColors.gold)
        .frame(width: 16)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 10))
          .foregroundStyle(PendulumColors.textTertiary)
        Text(value)
          .font(.system(size: 13, weight: .semibold, design: .monospaced))
          .foregroundStyle(PendulumColors.text)
      }

      Spacer()
    }
    .padding(8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(PendulumColors.backgroundSecondary)
    )
  }

  // MARK: - Recent Outcomes List

  private var recentOutcomesList: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Recent Sessions")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)

      ForEach(goldenManager.recentOutcomes.prefix(5), id: \.sessionId) { outcome in
        outcomeRow(outcome)
      }
    }
  }

  private func outcomeRow(_ outcome: GoldenModeOutcome) -> some View {
    HStack(spacing: 8) {
      Circle()
        .fill(outcome.sessionCompleted ? PendulumColors.success : PendulumColors.caution)
        .frame(width: 6, height: 6)

      Text(outcome.focusArea.displayName)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(PendulumColors.text)

      Spacer()

      if let score = outcome.score {
        Text("\(score)")
          .font(.system(size: 11, weight: .medium, design: .monospaced))
          .foregroundStyle(PendulumColors.textSecondary)
      }

      Text(formatDuration(outcome.sessionDuration))
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(PendulumColors.textTertiary)
    }
    .padding(.vertical, 4)
  }

  // MARK: - Helpers

  private func formatDuration(_ seconds: TimeInterval) -> String {
    let mins = Int(seconds) / 60
    let secs = Int(seconds) % 60
    return String(format: "%d:%02d", mins, secs)
  }
}

#Preview {
  ScrollView {
    GoldenModeDashboardSection()
  }
  .background(PendulumColors.background)
}
