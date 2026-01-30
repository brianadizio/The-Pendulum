// AIStatusBadge.swift
// The Pendulum 2.0
// Small HUD badge showing active AI mode

import SwiftUI

struct AIStatusBadge: View {
  @ObservedObject var aiManager: AIManager

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: aiManager.currentMode.icon)
        .font(.system(size: 12))
      Text(aiManager.currentMode.rawValue)
        .font(.system(size: 12, weight: .semibold))
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(
      Capsule()
        .fill(PendulumColors.gold.opacity(0.9))
    )
  }
}

#Preview {
  AIStatusBadge(aiManager: AIManager.shared)
}
