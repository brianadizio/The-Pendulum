// PaywallView.swift
// The Pendulum 2.0
// Full-screen paywall shown when the 3-day trial expires

import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var purchaseManager: PurchaseManager

    var body: some View {
        ZStack {
            // Background
            PendulumColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // App icon + name
                    VStack(spacing: 12) {
                        Image("PendulumLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: PendulumColors.gold.opacity(0.3), radius: 8)

                        Text("The Pendulum")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(PendulumColors.text)
                    }

                    // Trial ended message
                    Text("Your 3-day trial has ended")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(PendulumColors.textSecondary)

                    // Vestibular progression data (shown when 3+ play days exist)
                    if CSVSessionManager.currentPlayDay >= 3 {
                        vestibularProgressionCard
                    }

                    // Feature highlights
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "waveform.path",
                            title: "Physics Simulation",
                            description: "Rigorous inverted pendulum with real-time controls"
                        )
                        FeatureRow(
                            icon: "slider.horizontal.3",
                            title: "6 Game Modes",
                            description: "Progressive, Spatial, Jiggle, Timed, Random, Golden"
                        )
                        FeatureRow(
                            icon: "chart.bar",
                            title: "Analytics Dashboard",
                            description: "100+ metrics across scientific and educational categories"
                        )
                        FeatureRow(
                            icon: "sun.max.fill",
                            title: "Golden Mode",
                            description: "Adaptive gameplay shaped by your skills and health data"
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(PendulumColors.backgroundTertiary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PendulumColors.gold.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    // Purchase button
                    if purchaseManager.product == nil {
                        // Product still loading or not found
                        Button(action: {
                            Task { await purchaseManager.loadProduct() }
                        }) {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(PendulumColors.bronze)
                                Text("Loading price...")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundStyle(PendulumColors.bronze)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(PendulumColors.backgroundSecondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 32)
                    } else {
                        Button(action: {
                            Task {
                                await purchaseManager.purchase()
                            }
                        }) {
                            HStack(spacing: 10) {
                                if purchaseManager.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text(purchaseButtonLabel)
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [PendulumColors.gold, PendulumColors.goldDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: PendulumColors.gold.opacity(0.3), radius: 6, y: 3)
                        }
                        .disabled(purchaseManager.isPurchasing)
                        .opacity(purchaseManager.isPurchasing ? 0.7 : 1.0)
                        .padding(.horizontal, 32)
                    }

                    // Error message
                    if let error = purchaseManager.purchaseError {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundStyle(PendulumColors.danger)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Restore purchases
                    Button(action: {
                        Task {
                            await purchaseManager.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchase")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(PendulumColors.gold)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .onAppear {
            // Retry loading product if it wasn't ready yet
            if purchaseManager.product == nil {
                Task { await purchaseManager.loadProduct() }
            }
        }
    }

    // MARK: - Vestibular Progression Card

    private var vestibularProgressionCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 16))
                    .foregroundStyle(PendulumColors.gold)

                Text("Your Vestibular Journey")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PendulumColors.text)

                Spacer()
            }

            // Day progress dots
            HStack(spacing: 16) {
                let playDays = CSVSessionManager.getPlayDays()
                ForEach(0..<min(playDays.count, 5), id: \.self) { idx in
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(PendulumColors.gold)
                        Text("Day \(idx + 1)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(PendulumColors.textSecondary)
                    }
                }
                Spacer()
            }

            Text("Continue tracking your vestibular signature and see how your motor control evolves over time.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(PendulumColors.textSecondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.gold.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    private var purchaseButtonLabel: String {
        if let product = purchaseManager.product {
            return "Unlock Lifetime Access - \(product.displayPrice)"
        }
        return "Unlock Lifetime Access"
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PendulumColors.text)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(PendulumColors.textSecondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView(purchaseManager: PurchaseManager.shared)
}
