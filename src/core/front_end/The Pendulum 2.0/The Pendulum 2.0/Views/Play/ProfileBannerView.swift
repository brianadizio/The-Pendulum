// ProfileBannerView.swift
// The Pendulum 2.0
// Gentle 3-day prompt banner for profile creation

import SwiftUI

struct ProfileBannerView: View {
    let onCreateProfile: () -> Void
    let onDismiss: () -> Void

    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 24))
                    .foregroundStyle(PendulumColors.gold)

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("You've been training for 3 days!")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text("Create a profile to track your progress")
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                Spacer()

                // Dismiss button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(PendulumColors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(PendulumColors.backgroundSecondary)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Action buttons
            HStack(spacing: 12) {
                // Maybe Later
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDismiss()
                    }
                }) {
                    Text("Maybe Later")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(PendulumColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                // Create Profile
                Button(action: {
                    onCreateProfile()
                }) {
                    Text("Create Profile")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(PendulumColors.gold)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PendulumColors.backgroundTertiary)
                .shadow(color: PendulumColors.iron.opacity(0.1), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PendulumColors.gold.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        PendulumColors.background
            .ignoresSafeArea()

        VStack {
            ProfileBannerView(
                onCreateProfile: { print("Create profile") },
                onDismiss: { print("Dismissed") }
            )

            Spacer()
        }
    }
}
