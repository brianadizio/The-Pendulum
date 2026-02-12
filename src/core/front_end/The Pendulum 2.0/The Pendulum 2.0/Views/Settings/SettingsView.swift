// SettingsView.swift
// The Pendulum 2.0
// User preferences and app configuration

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var profileManager = ProfileManager.shared
    @State private var showingExportShare = false
    @State private var exportFileURL: URL?
    @State private var showingExportError = false
    @State private var exportErrorMessage = ""
    @State private var showingClearConfirmation = false
    @State private var showingProfileSheet = false
    @State private var showingEmailSignIn = false

    var body: some View {
        NavigationStack {
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

                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACCOUNT")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(PendulumColors.textTertiary)
                                .padding(.horizontal, 16)

                            AccountCard(
                                onShowEmailSignIn: { showingEmailSignIn = true },
                                onAccountDeleted: {
                                    clearAllData()
                                }
                            )
                            .padding(.horizontal, 16)
                        }

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
                            showingExportShare: $showingExportShare,
                            exportFileURL: $exportFileURL,
                            showingExportError: $showingExportError,
                            exportErrorMessage: $exportErrorMessage,
                            showingClearConfirmation: $showingClearConfirmation
                        )

                        Divider()
                            .background(PendulumColors.bronze.opacity(0.3))
                            .padding(.horizontal, 16)

                        #if DEBUG
                        // Developer Tools Section (debug builds only)
                        Divider()
                            .background(PendulumColors.bronze.opacity(0.3))
                            .padding(.horizontal, 16)

                        DebugPurchaseSection()
                        #endif

                        // About Section
                        AboutSection()
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(PendulumColors.background)
            .toolbarVisibility(.hidden, for: .navigationBar)
        .alert("Export Error", isPresented: $showingExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportErrorMessage)
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
        .sheet(isPresented: $showingEmailSignIn) {
            FirebaseSignInSheet(onDismiss: { showingEmailSignIn = false })
        }
        .sheet(isPresented: $showingExportShare) {
            if let url = exportFileURL {
                ShareSheet(items: [url])
            }
        }
        } // NavigationStack
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

    private var currentBackgroundLabel: String {
        if gameState.selectedBackgroundPhoto == "none" {
            return "Default"
        }
        let manager = NatureBackgroundManager.shared
        if let photo = manager.allPhotos.first(where: { $0.id == gameState.selectedBackgroundPhoto }) {
            return photo.displayName
        }
        return "Custom"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APPEARANCE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            SettingsNavigationRow(
                title: "Play Background",
                icon: "photo"
            ) {
                BackgroundPickerView(gameState: gameState)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Background Picker (sub-page)
struct BackgroundPickerView: View {
    @ObservedObject var gameState: GameState
    private let backgroundManager = NatureBackgroundManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // "None" option (default parchment)
                Button {
                    gameState.selectedBackgroundPhoto = "none"
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(PendulumColors.background)
                            .frame(width: 48, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(gameState.selectedBackgroundPhoto == "none"
                                            ? PendulumColors.gold
                                            : PendulumColors.bronze.opacity(0.3),
                                            lineWidth: gameState.selectedBackgroundPhoto == "none" ? 2 : 1)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Default")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(PendulumColors.text)
                            Text("Golden parchment theme")
                                .font(.system(size: 12))
                                .foregroundStyle(PendulumColors.textSecondary)
                        }

                        Spacer()

                        if gameState.selectedBackgroundPhoto == "none" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(PendulumColors.gold)
                                .font(.system(size: 20))
                        }
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

                // Photo backgrounds grouped by location
                ForEach(NatureLocation.allCases) { location in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(location.rawValue.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(PendulumColors.textTertiary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(backgroundManager.photos(for: location)) { photo in
                                    Button {
                                        gameState.selectedBackgroundPhoto = photo.id
                                    } label: {
                                        ZStack(alignment: .bottomTrailing) {
                                            Image(photo.id)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 72, height: 96)
                                                .clipped()
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(gameState.selectedBackgroundPhoto == photo.id
                                                                ? PendulumColors.gold
                                                                : Color.clear,
                                                                lineWidth: 2.5)
                                                )

                                            if gameState.selectedBackgroundPhoto == photo.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(PendulumColors.gold)
                                                    .font(.system(size: 16))
                                                    .background(Circle().fill(.white).padding(2))
                                                    .offset(x: -4, y: -4)
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(PendulumColors.background)
        .navigationTitle("Play Background")
        .navigationBarTitleDisplayMode(.inline)
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
                // Control Style
                SettingsPickerRow(
                    title: "Control Style",
                    subtitle: "How you push the pendulum",
                    selection: $gameState.controlStyle
                )

                // Sound Toggle
                SettingsToggleRow(
                    title: "Sound Effects",
                    subtitle: "Nature sounds on level completion",
                    isOn: $gameState.soundEnabled
                )

                // Haptics Toggle
                SettingsToggleRow(
                    title: "Haptic Feedback",
                    subtitle: "Vibration on push controls",
                    isOn: $gameState.hapticsEnabled
                )

                // Show Hints
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
    @Binding var showingExportShare: Bool
    @Binding var exportFileURL: URL?
    @Binding var showingExportError: Bool
    @Binding var exportErrorMessage: String
    @Binding var showingClearConfirmation: Bool

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
                    subtitle: "Share session summaries as CSV",
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
            exportErrorMessage = "No session manager available"
            showingExportError = true
            return
        }

        let sessions = manager.getAllSessions()
        if sessions.isEmpty {
            exportErrorMessage = "No sessions to export"
            showingExportError = true
            return
        }

        // Build session summary CSV from metadata
        let dateFormatter = ISO8601DateFormatter()
        var csv = "Date,Mode,Duration (s),Score,Max Level,Total Pushes,Levels Completed\n"

        for sessionURL in sessions {
            if let meta = manager.getMetadata(for: sessionURL) {
                let date = dateFormatter.string(from: meta.startTime)
                let mode = meta.gameMode
                let duration = Int(meta.totalDuration)
                let score = meta.maxScore
                let maxLevel = meta.maxLevel
                let pushes = meta.totalPushes
                let levels = meta.levelsCompleted.map { String($0) }.joined(separator: ",")
                csv += "\(date),\(mode),\(duration),\(score),\(maxLevel),\(pushes),\"\(levels)\"\n"
            }
        }

        // Write to temp file
        let tempDir = FileManager.default.temporaryDirectory
        let exportPath = tempDir.appendingPathComponent("PendulumSessions.csv")

        do {
            try csv.write(to: exportPath, atomically: true, encoding: .utf8)
            exportFileURL = exportPath
            showingExportShare = true
        } catch {
            exportErrorMessage = "Export failed: \(error.localizedDescription)"
            showingExportError = true
        }
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
                SettingsInfoRow(title: "Version", value: "1.0")
                SettingsInfoRow(title: "Build", value: "2")

                // Documentation
                SettingsNavigationRow(
                    title: "The Science",
                    icon: "book.closed"
                ) {
                    ScienceDocumentationView()
                }

                SettingsNavigationRow(
                    title: "Metrics Guide",
                    icon: "chart.bar.doc.horizontal"
                ) {
                    MetricsDocumentationView()
                }

                SettingsLinkRow(
                    title: "Privacy Policy",
                    url: "https://app.termly.io/policy-viewer/policy.html?policyUUID=01085dff-568d-49e6-8ed8-87b975ccaea9"
                )

                SettingsLinkRow(
                    title: "Terms of Service",
                    url: "https://app.termly.io/policy-viewer/policy.html?policyUUID=435400bb-d5d1-4f76-a708-607f87e9d5cb"
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

// MARK: - Debug Purchase Section
#if DEBUG
struct DebugPurchaseSection: View {
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DEVELOPER TOOLS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.caution)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                // Current status
                SettingsInfoRow(
                    title: "Trial Active",
                    value: purchaseManager.isTrialActive ? "Yes (\(purchaseManager.trialDaysRemaining)d left)" : "Expired"
                )

                SettingsInfoRow(
                    title: "Purchased",
                    value: purchaseManager.isUnlocked ? "Yes" : "No"
                )

                // Expire trial (set start date 4 days ago)
                SettingsButtonRow(
                    title: "Expire Trial Now",
                    subtitle: "Sets trial start to 4 days ago — shows paywall",
                    iconName: "clock.badge.xmark"
                ) {
                    let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
                    purchaseManager.debugSetTrialStart(fourDaysAgo)
                }

                // Reset trial (set start date to now)
                SettingsButtonRow(
                    title: "Reset Trial to 3 Days",
                    subtitle: "Restarts the trial as if freshly installed",
                    iconName: "arrow.counterclockwise"
                ) {
                    purchaseManager.debugSetTrialStart(Date())
                }

                // Reset purchase
                SettingsButtonRow(
                    title: "Reset Purchase State",
                    subtitle: "Clears purchased flag (keeps trial state)",
                    iconName: "cart.badge.minus",
                    isDestructive: true
                ) {
                    purchaseManager.debugResetPurchase()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
#endif

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

struct SettingsPickerRow<T: Hashable & CaseIterable & RawRepresentable & Identifiable>: View where T.RawValue == String, T.AllCases: RandomAccessCollection {
    let title: String
    let subtitle: String
    @Binding var selection: T

    var body: some View {
        SettingsRow(title: title, subtitle: subtitle) {
            Picker("", selection: $selection) {
                ForEach(T.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
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

struct SettingsNavigationRow<Destination: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.bronze)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
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

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    SettingsView(gameState: GameState())
}
