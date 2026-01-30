// SettingsView.swift
// The Pendulum 2.0
// User preferences and app configuration

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var profileManager = ProfileManager.shared
    @State private var showingExportSheet = false
    @State private var showingClearConfirmation = false
    @State private var showingProfileSheet = false
    @State private var exportMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            SettingsHeader()

            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section (at top)
                    ProfileSection(
                        profile: profileManager.currentProfile,
                        onCreateProfile: { showingProfileSheet = true },
                        onEditProfile: { showingProfileSheet = true }
                    )

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Appearance Section
                    AppearanceSection(gameState: gameState)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Gameplay Section
                    GameplaySection(gameState: gameState)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Data Section
                    DataSection(
                        gameState: gameState,
                        showingExportSheet: $showingExportSheet,
                        showingClearConfirmation: $showingClearConfirmation,
                        exportMessage: $exportMessage
                    )

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // About Section
                    AboutSection()
                }
                .padding(.vertical, 16)
            }
        }
        .background(PendulumColors.background)
        .alert("Export Complete", isPresented: $showingExportSheet) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportMessage)
        }
        .alert("Clear All Data?", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all session data and your profile. This action cannot be undone.")
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSetupView(existingProfile: profileManager.currentProfile)
        }
    }

    private func clearAllData() {
        gameState.csvSessionManager?.clearAllSessions()
        profileManager.clearAllData()
    }
}

// MARK: - Profile Section
struct ProfileSection: View {
    let profile: UserProfile?
    let onCreateProfile: () -> Void
    let onEditProfile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PROFILE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            if let profile = profile {
                // Profile exists - show summary
                Button(action: onEditProfile) {
                    HStack(spacing: 16) {
                        // Avatar circle with initial
                        ZStack {
                            Circle()
                                .fill(PendulumColors.gold.opacity(0.2))
                                .frame(width: 50, height: 50)

                            Text(String(profile.displayName.prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(PendulumColors.gold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.displayName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(PendulumColors.text)

                            Text(profile.trainingGoal.rawValue)
                                .font(.system(size: 12))
                                .foregroundStyle(PendulumColors.textSecondary)
                        }

                        Spacer()

                        Text("Edit")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(PendulumColors.gold)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PendulumColors.bronze)
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
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
            } else {
                // No profile - show create prompt
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create a profile to personalize your training experience")
                        .font(.system(size: 14))
                        .foregroundStyle(PendulumColors.textSecondary)

                    Button(action: onCreateProfile) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 18))
                            Text("Create Profile")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(PendulumColors.gold)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Settings Header
struct SettingsHeader: View {
    var body: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PendulumColors.background)
    }
}

// MARK: - Appearance Section
struct AppearanceSection: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APPEARANCE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                // Theme Picker
                SettingsRow(
                    title: "Theme",
                    subtitle: "Visual style of the app"
                ) {
                    Picker("Theme", selection: $gameState.selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(PendulumColors.gold)
                }

                // Background Picker
                SettingsRow(
                    title: "Background",
                    subtitle: "Pendulum scene background"
                ) {
                    Picker("Background", selection: $gameState.selectedBackground) {
                        ForEach(BackgroundStyle.allCases) { bg in
                            Text(bg.rawValue).tag(bg)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(PendulumColors.gold)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Gameplay Section
struct GameplaySection: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GAMEPLAY")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                // Control Sensitivity
                SettingsSliderRow(
                    title: "Control Sensitivity",
                    value: $gameState.controlSensitivity,
                    range: 0.5...2.0
                )

                // Sound Toggle
                SettingsToggleRow(
                    title: "Sound Effects",
                    subtitle: "Play sounds during gameplay",
                    isOn: $gameState.soundEnabled
                )

                // Haptics Toggle
                SettingsToggleRow(
                    title: "Haptic Feedback",
                    subtitle: "Vibration on interactions",
                    isOn: $gameState.hapticsEnabled
                )

                // Show Tutorial
                SettingsToggleRow(
                    title: "Show Hints",
                    subtitle: "Display helpful tips during play",
                    isOn: $gameState.showHints
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Data Section
struct DataSection: View {
    @ObservedObject var gameState: GameState
    @Binding var showingExportSheet: Bool
    @Binding var showingClearConfirmation: Bool
    @Binding var exportMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATA")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                // Session Count Info
                SettingsInfoRow(
                    title: "Total Sessions",
                    value: "\(gameState.csvSessionManager?.getAllSessions().count ?? 0)"
                )

                // Export CSV Button
                SettingsButtonRow(
                    title: "Export All Data",
                    subtitle: "Save sessions as CSV to Files app",
                    iconName: "square.and.arrow.up"
                ) {
                    exportData()
                }

                // Clear Data Button
                SettingsButtonRow(
                    title: "Clear All Data",
                    subtitle: "Permanently delete all sessions",
                    iconName: "trash",
                    isDestructive: true
                ) {
                    showingClearConfirmation = true
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func exportData() {
        guard let manager = gameState.csvSessionManager else {
            exportMessage = "No session manager available"
            showingExportSheet = true
            return
        }

        let sessions = manager.getAllSessions()
        if sessions.isEmpty {
            exportMessage = "No sessions to export"
            showingExportSheet = true
            return
        }

        // Export to Documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let exportPath = documentsPath.appendingPathComponent("PendulumExport_\(Date().ISO8601Format()).csv")

            var combinedData = "session_id,timestamp,angle,angleVelocity,pushDirection,pushMagnitude,isBalanced,level,energy\n"

            for (index, sessionUrl) in sessions.enumerated() {
                if let data = manager.readSessionData(from: sessionUrl) {
                    for row in data {
                        let line = "\(index),\(row["timestamp"] ?? ""),\(row["angle"] ?? ""),\(row["angleVelocity"] ?? ""),\(row["pushDirection"] ?? ""),\(row["pushMagnitude"] ?? ""),\(row["isBalanced"] ?? ""),\(row["level"] ?? ""),\(row["energy"] ?? "")\n"
                        combinedData += line
                    }
                }
            }

            do {
                try combinedData.write(to: exportPath, atomically: true, encoding: .utf8)
                exportMessage = "Exported \(sessions.count) sessions to Documents folder"
            } catch {
                exportMessage = "Export failed: \(error.localizedDescription)"
            }
        }

        showingExportSheet = true
    }
}

// MARK: - About Section
struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                SettingsInfoRow(title: "Version", value: "2.0.0")
                SettingsInfoRow(title: "Build", value: "1")

                SettingsLinkRow(
                    title: "Privacy Policy",
                    url: "https://www.golden-enterprises.net/privacy"
                )

                SettingsLinkRow(
                    title: "Terms of Service",
                    url: "https://www.golden-enterprises.net/terms"
                )

                // Credits
                VStack(alignment: .leading, spacing: 8) {
                    Text("Credits")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(PendulumColors.text)

                    Text("Physics simulation based on rigorous inverted pendulum dynamics. Developed as part of Golden Enterprise Solutions.")
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(PendulumColors.backgroundSecondary)
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Settings Row Components

struct SettingsRow<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            Spacer()

            content()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow(title: title, subtitle: subtitle) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(PendulumColors.gold)
        }
    }
}

struct SettingsSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Text(String(format: "%.1fx", value))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            Slider(value: $value, in: range)
                .tint(PendulumColors.gold)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PendulumColors.text)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(PendulumColors.textSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SettingsButtonRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isDestructive ? PendulumColors.danger : PendulumColors.text)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                Spacer()

                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(isDestructive ? PendulumColors.danger : PendulumColors.gold)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsLinkRow: View {
    let title: String
    let url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.bronze)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Enums

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case golden = "Golden"

    var id: String { rawValue }
}

enum BackgroundStyle: String, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case gradient = "Gradient"
    case topology = "Topology"
    case parchment = "Parchment"
    case outerSpace = "Outer Space"

    var id: String { rawValue }
}

// MARK: - Preview
#Preview {
    SettingsView(gameState: GameState())
}
