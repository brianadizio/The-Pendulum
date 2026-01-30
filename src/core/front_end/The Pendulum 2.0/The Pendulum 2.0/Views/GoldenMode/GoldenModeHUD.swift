// GoldenModeHUD.swift
// The Pendulum 2.0
// In-session HUD overlay showing Golden Mode status during gameplay

import SwiftUI

struct GoldenModeHUD: View {
  @ObservedObject var goldenManager = GoldenModeManager.shared

  var body: some View {
    HStack(spacing: 10) {
      // Focus area icon + name
      HStack(spacing: 6) {
        Image(systemName: "sun.max.fill")
          .font(.system(size: 12))
          .foregroundStyle(PendulumColors.gold)

        Text(goldenManager.currentFocusAreaName ?? "Golden")
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(PendulumColors.text)
      }

      // Divider
      Rectangle()
        .fill(PendulumColors.bronze.opacity(0.3))
        .frame(width: 1, height: 16)

      // Tier badge
      Text(goldenManager.currentTier)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(PendulumColors.textTertiary)

      // Divider
      Rectangle()
        .fill(PendulumColors.bronze.opacity(0.3))
        .frame(width: 1, height: 16)

      // Adaptation count
      HStack(spacing: 3) {
        Image(systemName: "arrow.triangle.2.circlepath")
          .font(.system(size: 10))
          .foregroundStyle(PendulumColors.gold)

        Text("\(goldenManager.adaptationCountPublic)")
          .font(.system(size: 11, weight: .medium, design: .monospaced))
          .foregroundStyle(PendulumColors.textSecondary)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white.opacity(0.92))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(PendulumColors.gold.opacity(0.3), lineWidth: 1)
    )
  }
}

#Preview {
  GoldenModeHUD()
    .padding()
    .background(PendulumColors.background)
}
