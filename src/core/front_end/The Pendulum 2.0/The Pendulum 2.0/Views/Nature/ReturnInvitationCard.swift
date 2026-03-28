// ReturnInvitationCard.swift
// The Pendulum 2.0
// "Day N of 3" progression card with Play More / Explore Dashboard buttons

import SwiftUI

struct ReturnInvitationCard: View {
  let day: Int
  let onPlayMore: () -> Void
  let onExploreDashboard: () -> Void

  private var headline: String {
    if day >= 3 {
      return "Balance Profile: Complete"
    }
    return "Balance Profile: Day \(day) of 3"
  }

  private var bodyText: String {
    switch day {
    case 1:
      return "Your vestibular signature is just beginning. Play tomorrow to see how your motor control adapts."
    case 2:
      return "Your balance profile is evolving. One more day completes your 3-day vestibular map."
    default:
      return "Your 3-day vestibular profile is complete. Unlock Golden Mode to keep tracking."
    }
  }

  private var progressFraction: Double {
    min(Double(day) / 3.0, 1.0)
  }

  var body: some View {
    VStack(spacing: 16) {
      // Progress bar
      VStack(spacing: 6) {
        HStack {
          Text(headline)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(PendulumColors.text)
          Spacer()
        }

        GeometryReader { geo in
          ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
              .fill(PendulumColors.silver.opacity(0.15))
              .frame(height: 6)

            RoundedRectangle(cornerRadius: 3)
              .fill(
                LinearGradient(
                  colors: [PendulumColors.gold.opacity(0.7), PendulumColors.gold],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .frame(width: geo.size.width * progressFraction, height: 6)
          }
        }
        .frame(height: 6)

        // Day dots
        HStack(spacing: 12) {
          ForEach(1...3, id: \.self) { d in
            HStack(spacing: 4) {
              Image(systemName: d <= day ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundStyle(d <= day ? PendulumColors.gold : PendulumColors.silver.opacity(0.4))
              Text("Day \(d)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(d <= day ? PendulumColors.textSecondary : PendulumColors.silver.opacity(0.4))
            }
          }
          Spacer()
        }
      }

      Text(bodyText)
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(PendulumColors.textSecondary)
        .lineSpacing(3)

      // Buttons
      HStack(spacing: 12) {
        Button(action: onPlayMore) {
          Text("Play More")
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GoldButtonStyle())

        Button(action: onExploreDashboard) {
          Text("Explore Dashboard")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(PendulumColors.gold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .stroke(PendulumColors.gold.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(PendulumColors.backgroundTertiary)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(PendulumColors.gold.opacity(0.15), lineWidth: 1)
    )
    .padding(.horizontal, 20)
  }
}
