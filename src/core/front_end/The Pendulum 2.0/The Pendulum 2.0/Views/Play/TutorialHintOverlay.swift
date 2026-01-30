// TutorialHintOverlay.swift
// The Pendulum 2.0
// Overlay displayed during tutorial mode showing direction, urgency, and explanation

import SwiftUI
import PendulumSolver

struct TutorialHintOverlay: View {
  let hint: TutorialMode.Hint

  var body: some View {
    VStack(spacing: 10) {
      // Direction arrow
      HStack(spacing: 12) {
        directionIcon
          .font(.system(size: 32, weight: .bold))
          .foregroundStyle(urgencyColor)

        VStack(alignment: .leading, spacing: 4) {
          // Direction label
          Text(directionLabel)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(PendulumColors.text)

          // Urgency dots
          HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
              Circle()
                .fill(i < urgencyLevel ? urgencyColor : PendulumColors.backgroundSecondary)
                .frame(width: 8, height: 8)
            }
            Text(urgencyLabel)
              .font(.system(size: 11))
              .foregroundStyle(PendulumColors.textSecondary)
          }
        }
      }

      // Explanation text
      Text(hint.explanation)
        .font(.system(size: 13))
        .foregroundStyle(PendulumColors.textSecondary)
        .multilineTextAlignment(.center)
        .lineLimit(2)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(PendulumColors.backgroundTertiary.opacity(0.95))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(urgencyColor.opacity(0.4), lineWidth: 1.5)
    )
    .shadow(color: PendulumColors.iron.opacity(0.15), radius: 8, y: 4)
    .padding(.horizontal, 24)
    .transition(.opacity.combined(with: .scale(scale: 0.95)))
    .animation(.easeInOut(duration: 0.3), value: hint.explanation)
  }

  // MARK: - Computed Properties

  private var directionIcon: Image {
    switch hint.suggestedDirection {
    case .left:  return Image(systemName: "arrow.left.circle.fill")
    case .right: return Image(systemName: "arrow.right.circle.fill")
    case .none:  return Image(systemName: "checkmark.circle.fill")
    }
  }

  private var directionLabel: String {
    switch hint.suggestedDirection {
    case .left:  return "Push Left"
    case .right: return "Push Right"
    case .none:  return "Hold Steady"
    }
  }

  private var urgencyLevel: Int {
    if hint.urgency < 0.33 { return 1 }
    if hint.urgency < 0.66 { return 2 }
    return 3
  }

  private var urgencyLabel: String {
    switch urgencyLevel {
    case 1:  return "Low urgency"
    case 2:  return "Medium urgency"
    default: return "High urgency"
    }
  }

  private var urgencyColor: Color {
    switch urgencyLevel {
    case 1:  return PendulumColors.success
    case 2:  return PendulumColors.caution
    default: return PendulumColors.danger
    }
  }
}
