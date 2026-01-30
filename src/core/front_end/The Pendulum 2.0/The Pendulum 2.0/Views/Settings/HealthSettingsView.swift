// HealthSettingsView.swift
// The Pendulum 2.0
// Detailed Apple Health settings and permissions

import SwiftUI

struct HealthSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKitManager = HealthKitManager.shared

    @State private var showingDisconnectAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Connection Status
                    ConnectionStatusCard(healthKitManager: healthKitManager)

                    // Health Data Summary
                    if healthKitManager.isAuthorized {
                        HealthDataSummaryCard(healthKitManager: healthKitManager)
                    }

                    // Data Types Info
                    DataTypesInfoCard()

                    // Privacy Info
                    PrivacyInfoCard()

                    // Disconnect Button
                    if healthKitManager.isAuthorized {
                        DisconnectButton {
                            showingDisconnectAlert = true
                        }
                    }
                }
                .padding(16)
            }
            .background(PendulumColors.background)
            .navigationTitle("Apple Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(PendulumColors.gold)
                }
            }
            .alert("Disconnect Apple Health?", isPresented: $showingDisconnectAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Disconnect", role: .destructive) {
                    disconnectHealth()
                }
            } message: {
                Text("Sessions will no longer be logged as mindfulness minutes. To fully revoke access, go to Settings > Privacy > Health.")
            }
        }
    }

    private func disconnectHealth() {
        healthKitManager.disconnect()
        ProfileManager.shared.setHealthIntegrationConsent(false)
        dismiss()
    }
}

// MARK: - Connection Status Card
struct ConnectionStatusCard: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: healthKitManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(healthKitManager.isAuthorized ? PendulumColors.success : PendulumColors.textTertiary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(healthKitManager.isAuthorized ? "Connected" : "Not Connected")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text(healthKitManager.isAuthorized
                         ? "Sessions are being logged as mindfulness"
                         : "Connect to log sessions and read health data")
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                Spacer()
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
}

// MARK: - Health Data Summary Card
struct HealthDataSummaryCard: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S DATA")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)

            if let snapshot = healthKitManager.latestHealthSnapshot, snapshot.hasData {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    if let steps = snapshot.steps {
                        HealthDataTile(
                            icon: "figure.walk",
                            value: "\(steps.formatted())",
                            label: "Steps"
                        )
                    }

                    if let hr = snapshot.restingHeartRate {
                        HealthDataTile(
                            icon: "heart.fill",
                            value: "\(Int(hr))",
                            label: "Resting HR"
                        )
                    }

                    if let hrv = snapshot.heartRateVariability {
                        HealthDataTile(
                            icon: "waveform.path.ecg",
                            value: "\(Int(hrv)) ms",
                            label: "HRV"
                        )
                    }

                    if let sleep = snapshot.sleepDuration {
                        let hours = Int(sleep) / 3600
                        let mins = (Int(sleep) % 3600) / 60
                        HealthDataTile(
                            icon: "bed.double.fill",
                            value: "\(hours)h \(mins)m",
                            label: "Sleep"
                        )
                    }

                    if let cal = snapshot.activeCalories {
                        HealthDataTile(
                            icon: "flame.fill",
                            value: "\(Int(cal))",
                            label: "Active Cal"
                        )
                    }

                    if snapshot.mindfulMinutesLogged > 0 {
                        HealthDataTile(
                            icon: "brain.head.profile",
                            value: "\(snapshot.mindfulMinutesLogged)",
                            label: "Mindful Min"
                        )
                    }
                }
            } else {
                Text("No health data available yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
    }
}

struct HealthDataTile: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(PendulumColors.gold)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(PendulumColors.text)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(PendulumColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

// MARK: - Data Types Info Card
struct DataTypesInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATA WE ACCESS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)

            VStack(spacing: 8) {
                DataTypeRow(type: .mindfulness, accessType: "Write")
                DataTypeRow(type: .steps, accessType: "Read")
                DataTypeRow(type: .restingHeartRate, accessType: "Read")
                DataTypeRow(type: .heartRateVariability, accessType: "Read")
                DataTypeRow(type: .sleep, accessType: "Read")
                DataTypeRow(type: .activeCalories, accessType: "Read")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
    }
}

struct DataTypeRow: View {
    let type: HealthDataType
    let accessType: String

    var body: some View {
        HStack {
            Image(systemName: type.icon)
                .font(.system(size: 16))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 24)

            Text(type.rawValue)
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.text)

            Spacer()

            Text(accessType)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(accessType == "Write" ? PendulumColors.success : PendulumColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(accessType == "Write"
                              ? PendulumColors.success.opacity(0.1)
                              : PendulumColors.backgroundSecondary)
                )
        }
    }
}

// MARK: - Privacy Info Card
struct PrivacyInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield")
                    .font(.system(size: 20))
                    .foregroundStyle(PendulumColors.gold)

                Text("Privacy")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PendulumColors.text)
            }

            Text("Your session and health data is used by The Spiral's Eye — an independent mathematics research studio — to improve the game experience and support research in psychophysics, AI modeling, neuroscience, and topological data analysis. Your data is stored securely on a private server and is never shared with third parties.")
                .font(.system(size: 13))
                .foregroundStyle(PendulumColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
    }
}

// MARK: - Disconnect Button
struct DisconnectButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "xmark.circle")
                Text("Disconnect Apple Health")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(PendulumColors.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PendulumColors.danger.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    HealthSettingsView()
}
