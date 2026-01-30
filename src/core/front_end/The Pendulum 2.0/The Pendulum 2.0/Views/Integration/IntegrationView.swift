// IntegrationView.swift
// The Pendulum 2.0
// Cross-solution connections and Apple Health integration

import SwiftUI

struct IntegrationView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var showingHealthExplanation = false
    @State private var showingHealthSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            IntegrationHeader()

            ScrollView {
                VStack(spacing: 24) {
                    // Golden Solutions Section
                    GoldenSolutionsSection()

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // External Services Section (Apple Health)
                    ExternalServicesSection(
                        healthKitManager: healthKitManager,
                        onConnectTapped: { showingHealthExplanation = true },
                        onSettingsTapped: { showingHealthSettings = true }
                    )

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // The Hypergraph Link
                    HypergraphSection()
                }
                .padding(.vertical, 16)
            }
        }
        .background(PendulumColors.background)
        .sheet(isPresented: $showingHealthExplanation) {
            HealthExplanationSheet(
                healthKitManager: healthKitManager,
                onDismiss: { showingHealthExplanation = false }
            )
        }
        .sheet(isPresented: $showingHealthSettings) {
            HealthSettingsView()
        }
    }
}

// MARK: - Integration Header
struct IntegrationHeader: View {
    var body: some View {
        HStack {
            Text("Integration")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PendulumColors.background)
    }
}

// MARK: - Golden Solutions Section
struct GoldenSolutionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GOLDEN SOLUTIONS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                IntegrationCard(
                    title: "The Maze",
                    description: "Connect balance patterns to maze navigation",
                    iconName: "square.grid.3x3",
                    isConnected: false
                )

                IntegrationCard(
                    title: "Focus Calendar",
                    description: "Sync focus sessions with balance training",
                    iconName: "calendar",
                    isConnected: false,
                    comingSoon: true
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - External Services Section
struct ExternalServicesSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    var onConnectTapped: () -> Void
    var onSettingsTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXTERNAL SERVICES")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                AppleHealthCard(
                    healthKitManager: healthKitManager,
                    onConnectTapped: onConnectTapped,
                    onSettingsTapped: onSettingsTapped
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Apple Health Card
struct AppleHealthCard: View {
    @ObservedObject var healthKitManager: HealthKitManager
    var onConnectTapped: () -> Void
    var onSettingsTapped: () -> Void

    private var statusDescription: String {
        if healthKitManager.isAuthorized {
            return "Connected - logging sessions as mindfulness"
        } else if !healthKitManager.isHealthKitAvailable {
            return "Apple Health not available on this device"
        } else {
            return "Log sessions as mindfulness minutes"
        }
    }

    var body: some View {
        Button(action: {
            if healthKitManager.isAuthorized {
                onSettingsTapped()
            } else if healthKitManager.isHealthKitAvailable {
                onConnectTapped()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(PendulumColors.danger)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Health")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text(statusDescription)
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                        .lineLimit(2)

                    // Show health summary when connected
                    if healthKitManager.isAuthorized,
                       let snapshot = healthKitManager.latestHealthSnapshot,
                       snapshot.hasData {
                        HealthSnapshotSummary(snapshot: snapshot)
                            .padding(.top, 8)
                    }
                }

                Spacer()

                if healthKitManager.isAuthorized {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PendulumColors.success)
                } else if healthKitManager.isHealthKitAvailable {
                    Text("Connect")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(PendulumColors.gold))
                } else {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(PendulumColors.textTertiary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        healthKitManager.isAuthorized
                            ? PendulumColors.success.opacity(0.3)
                            : PendulumColors.bronze.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!healthKitManager.isHealthKitAvailable)
        .opacity(healthKitManager.isHealthKitAvailable ? 1.0 : 0.6)
    }
}

// MARK: - Health Snapshot Summary
struct HealthSnapshotSummary: View {
    let snapshot: HealthSnapshot

    var body: some View {
        HStack(spacing: 16) {
            if let steps = snapshot.steps {
                HealthMetricBadge(
                    icon: "figure.walk",
                    value: "\(steps)",
                    label: "steps"
                )
            }

            if let hr = snapshot.restingHeartRate {
                HealthMetricBadge(
                    icon: "heart.fill",
                    value: "\(Int(hr))",
                    label: "BPM"
                )
            }

            if snapshot.mindfulMinutesLogged > 0 {
                HealthMetricBadge(
                    icon: "brain.head.profile",
                    value: "\(snapshot.mindfulMinutesLogged)",
                    label: "min"
                )
            }
        }
    }
}

struct HealthMetricBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(PendulumColors.gold)

            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(PendulumColors.text)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(PendulumColors.textTertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

// MARK: - Health Explanation Sheet
struct HealthExplanationSheet: View {
    @ObservedObject var healthKitManager: HealthKitManager
    var onDismiss: () -> Void

    @State private var isConnecting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(PendulumColors.danger)
                    .padding(.top, 32)

                // Title
                Text("Connect Apple Health")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(PendulumColors.text)

                // Explanation
                VStack(alignment: .leading, spacing: 16) {
                    ExplanationRow(
                        icon: "pencil.and.outline",
                        title: "We'll log your sessions",
                        description: "Training sessions are saved as mindfulness minutes"
                    )

                    ExplanationRow(
                        icon: "book.pages",
                        title: "We'll read health metrics",
                        description: "Steps, heart rate, sleep, and activity data"
                    )

                    ExplanationRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Find correlations",
                        description: "See how health affects your focus performance"
                    )
                }
                .padding(.horizontal, 24)

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(PendulumColors.danger)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // Connect button
                Button(action: connectToHealth) {
                    HStack {
                        if isConnecting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Connect to Apple Health")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(PendulumColors.danger)
                    )
                }
                .disabled(isConnecting)
                .padding(.horizontal, 24)

                // Privacy note
                Text("Your data is stored securely by The Spiral's Eye and is never shared with third parties.")
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .background(PendulumColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(PendulumColors.textSecondary)
                }
            }
        }
    }

    private func connectToHealth() {
        isConnecting = true
        errorMessage = nil

        Task {
            do {
                let success = try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    isConnecting = false
                    if success {
                        // Update profile consent
                        ProfileManager.shared.setHealthIntegrationConsent(true)
                        onDismiss()
                    } else {
                        errorMessage = "Authorization was not granted. You can enable it in Settings."
                    }
                }
            } catch {
                await MainActor.run {
                    isConnecting = false
                    errorMessage = "Failed to connect: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ExplanationRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PendulumColors.text)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
            }
        }
    }
}

// MARK: - Hypergraph Section
struct HypergraphSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE HYPERGRAPH")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            Button(action: {
                if let url = URL(string: "https://www.golden-enterprises.net") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 24))
                        .foregroundStyle(PendulumColors.gold)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Visit The Hypergraph")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PendulumColors.text)

                        Text("golden-enterprises.net")
                            .font(.system(size: 12))
                            .foregroundStyle(PendulumColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16))
                        .foregroundStyle(PendulumColors.bronze)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PendulumColors.backgroundTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PendulumColors.gold.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Integration Card
struct IntegrationCard: View {
    let title: String
    let description: String
    let iconName: String
    var iconColor: Color = PendulumColors.gold
    var isConnected: Bool = false
    var comingSoon: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    if comingSoon {
                        Text("Coming Soon")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(PendulumColors.caution))
                    }
                }

                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(PendulumColors.success)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PendulumColors.bronze)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
        )
        .opacity(comingSoon ? 0.6 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    IntegrationView()
}
