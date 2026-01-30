// GoldenModeHeroCard.swift
// The Pendulum 2.0
// Featured card for Golden Mode in the Modes tab

import SwiftUI

struct GoldenModeHeroCard: View {
  @ObservedObject var gameState: GameState
  @ObservedObject var goldenManager = GoldenModeManager.shared
  @State private var showSetup = false

  private var isSelected: Bool { gameState.gameMode == .golden }

  var body: some View {
    Button {
      if isSelected {
        showSetup = true
      } else {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          gameState.gameMode = .golden
        }
        showSetup = true
      }
    } label: {
      VStack(spacing: 0) {
        // Top: gradient banner
        ZStack(alignment: .topTrailing) {
          LinearGradient(
            colors: [PendulumColors.goldLight, PendulumColors.gold, PendulumColors.goldDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .frame(height: 80)

          // Status badge
          if goldenManager.outcomeCount > 0 {
            Text("\(goldenManager.outcomeCount) sessions")
              .font(.system(size: 10, weight: .semibold))
              .foregroundStyle(.white)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Capsule().fill(Color.black.opacity(0.25)))
              .padding(10)
          }

          // Icon
          VStack(spacing: 4) {
            Image(systemName: "sun.max.fill")
              .font(.system(size: 32))
              .foregroundStyle(.white)

            Text("GOLDEN MODE")
              .font(.system(size: 11, weight: .bold, design: .rounded))
              .foregroundStyle(.white.opacity(0.9))
              .tracking(1.5)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        // Bottom: info
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("The Golden Mode")
              .font(.system(size: 18, weight: .bold, design: .serif))
              .foregroundStyle(PendulumColors.text)

            Spacer()

            if isSelected {
              Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(PendulumColors.gold)
            }
          }

          Text("Reactive mode shaped by your health, skills & data across apps")
            .font(.system(size: 13))
            .foregroundStyle(PendulumColors.textSecondary)
            .lineLimit(2)

          // Mini coherence + data indicators
          HStack(spacing: 12) {
            ResonanceMeterView(
              score: goldenManager.coherenceScore,
              label: goldenManager.coherenceLabel,
              compact: true
            )

            VStack(alignment: .leading, spacing: 4) {
              DataSourceRow(icon: "heart.fill", label: "Health", connected: goldenManager.dataReadiness.healthConnected)
              DataSourceRow(icon: "person.fill", label: "Profile", connected: goldenManager.dataReadiness.profileComplete)
              DataSourceRow(icon: "chart.bar.fill", label: "Sessions", connected: goldenManager.dataReadiness.hasPlayHistory)
              DataSourceRow(icon: "square.grid.3x3.fill", label: "The Maze", connected: goldenManager.dataReadiness.mazeConnected)
            }
          }
          .padding(.top, 4)
        }
        .padding(16)
        .background(isSelected ? PendulumColors.goldLight.opacity(0.08) : Color.white)
      }
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(isSelected ? PendulumColors.gold : PendulumColors.bronze.opacity(0.3), lineWidth: isSelected ? 2 : 1)
      )
      .shadow(color: PendulumColors.gold.opacity(isSelected ? 0.25 : 0.1), radius: isSelected ? 8 : 4, y: 3)
    }
    .buttonStyle(PlainButtonStyle())
    .sheet(isPresented: $showSetup) {
      GoldenModeSetupSheet(gameState: gameState)
    }
  }
}

// MARK: - Data Source Row
private struct DataSourceRow: View {
  let icon: String
  let label: String
  let connected: Bool

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: connected ? "checkmark.circle.fill" : "circle")
        .font(.system(size: 10))
        .foregroundStyle(connected ? PendulumColors.success : PendulumColors.silver)

      Text(label)
        .font(.system(size: 11))
        .foregroundStyle(connected ? PendulumColors.text : PendulumColors.textTertiary)
    }
  }
}

#Preview {
  GoldenModeHeroCard(gameState: GameState())
    .padding()
    .background(PendulumColors.background)
}
