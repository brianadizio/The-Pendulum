// HealthPromptCard.swift
// The Pendulum 2.0
// "Connect Apple Health" prompt card shown on Day 2

import SwiftUI

struct HealthPromptCard: View {
  @State private var isAuthorized = UserDefaults.standard.bool(forKey: "healthkit_authorization_status")
  @State private var isRequesting = false

  var body: some View {
    if !isAuthorized {
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 8) {
          Image(systemName: "heart.text.square.fill")
            .font(.system(size: 20))
            .foregroundStyle(.red.opacity(0.8))

          Text("Connect Apple Health")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(PendulumColors.text)
        }

        Text("See how sleep, heart rate, and activity affect your balance. Your health data stays on your device.")
          .font(.system(size: 12, weight: .regular))
          .foregroundStyle(PendulumColors.textSecondary)
          .lineSpacing(3)

        Button {
          connectHealth()
        } label: {
          HStack(spacing: 6) {
            if isRequesting {
              ProgressView()
                .tint(.white)
                .scaleEffect(0.8)
            }
            Text(isRequesting ? "Connecting..." : "Connect")
              .font(.system(size: 13, weight: .semibold))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.red.opacity(0.8))
          )
          .foregroundStyle(.white)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isRequesting)
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(PendulumColors.backgroundTertiary)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.red.opacity(0.15), lineWidth: 1)
      )
      .padding(.horizontal, 20)
    }
  }

  private func connectHealth() {
    isRequesting = true
    Task {
      try? await HealthKitManager.shared.requestAuthorization()
      await MainActor.run {
        isAuthorized = UserDefaults.standard.bool(forKey: "healthkit_authorization_status")
        isRequesting = false
      }
    }
  }
}
