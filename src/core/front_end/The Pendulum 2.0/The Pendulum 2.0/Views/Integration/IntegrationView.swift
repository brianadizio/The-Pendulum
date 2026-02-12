// IntegrationView.swift
// The Pendulum 2.0
// Cross-solution connections and Apple Health integration

import SwiftUI

struct IntegrationView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var metricsCalculator = CSVMetricsCalculator()
    @State private var showingHealthExplanation = false
    @State private var showingHealthSettings = false
    @State private var showingMazeConnection = false
    @State private var showingAIChat = false
    @State private var isMazeConnected = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            IntegrationHeader()

            ScrollView {
                VStack(spacing: 24) {
                    // AI Insights Section - "Your Play Style, Decoded"
                    AIInsightsSection(onChatTapped: { showingAIChat = true })

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Golden Solutions Section
                    GoldenSolutionsSection(
                        isMazeConnected: isMazeConnected,
                        onMazeTapped: { showingMazeConnection = true }
                    )

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
        .onAppear {
            isMazeConnected = AppGroupManager.shared.loadMazeData() != nil
            // Load metrics for AI context
            if let sessionManager = CSVSessionManager() as CSVSessionManager? {
                metricsCalculator.calculateMetrics(from: sessionManager, timeRange: .allTime)
            }
        }
        .sheet(isPresented: $showingHealthExplanation) {
            HealthExplanationSheet(
                healthKitManager: healthKitManager,
                onDismiss: { showingHealthExplanation = false }
            )
        }
        .sheet(isPresented: $showingHealthSettings) {
            HealthSettingsView()
        }
        .sheet(isPresented: $showingMazeConnection) {
            MazeConnectionSheet(
                isMazeConnected: $isMazeConnected,
                onDismiss: { showingMazeConnection = false }
            )
        }
        .sheet(isPresented: $showingAIChat) {
            ChatView(metricsCalculator: metricsCalculator)
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

// MARK: - AI Insights Section
struct AIInsightsSection: View {
    var onChatTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI INSIGHTS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            Button(action: onChatTapped) {
                HStack(spacing: 12) {
                    // Sparkle icon with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [PendulumColors.goldLight, PendulumColors.gold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)

                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Play Style, Decoded")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PendulumColors.text)

                        Text("Ask AI about your gameplay patterns and cognitive style")
                            .font(.system(size: 12))
                            .foregroundStyle(PendulumColors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PendulumColors.gold)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PendulumColors.backgroundTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [PendulumColors.goldLight.opacity(0.4), PendulumColors.gold.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Golden Solutions Section
struct GoldenSolutionsSection: View {
    var isMazeConnected: Bool = false
    var onMazeTapped: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GOLDEN SOLUTIONS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                Button(action: { onMazeTapped?() }) {
                    IntegrationCard(
                        title: "The Maze",
                        description: "Connect balance patterns to maze navigation",
                        iconName: "square.grid.3x3",
                        isConnected: isMazeConnected
                    )
                }
                .buttonStyle(PlainButtonStyle())

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

// MARK: - Maze Connection Sheet
struct MazeConnectionSheet: View {
    @Binding var isMazeConnected: Bool
    var onDismiss: () -> Void

    @State private var isChecking = false
    @State private var mazeData: MazeSharedData?
    @State private var checkComplete = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(PendulumColors.gold)
                    .padding(.top, 32)

                // Title
                Text("Connect The Maze")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(PendulumColors.text)

                // Explanation
                VStack(alignment: .leading, spacing: 16) {
                    ExplanationRow(
                        icon: "arrow.triangle.branch",
                        title: "Balance patterns",
                        description: "Your pendulum control data flows into maze navigation analysis"
                    )

                    ExplanationRow(
                        icon: "chart.dots.scatter",
                        title: "Maze performance",
                        description: "Motor scores, cognitive metrics, and decision latency from The Maze"
                    )

                    ExplanationRow(
                        icon: "sun.max.fill",
                        title: "Golden Mode enhancement",
                        description: "Combined data powers smarter difficulty adaptation"
                    )
                }
                .padding(.horizontal, 24)

                // Connection status
                if let data = mazeData {
                    MazeDataSummary(data: data)
                        .padding(.horizontal, 24)
                } else if checkComplete {
                    VStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(PendulumColors.caution)

                        Text("No maze data found yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PendulumColors.text)

                        Text("Play a session in The Maze first, then come back to connect.")
                            .font(.system(size: 14))
                            .foregroundStyle(PendulumColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Check button
                Button(action: checkForMazeData) {
                    HStack {
                        if isChecking {
                            ProgressView()
                                .tint(.white)
                        } else if isMazeConnected {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Connected")
                        } else {
                            Text("Check for The Maze")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isMazeConnected ? PendulumColors.success : PendulumColors.gold)
                    )
                }
                .disabled(isChecking)
                .padding(.horizontal, 24)

                Text("Data is shared securely via App Group between The Pendulum and The Maze.")
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
                    Button("Done") { onDismiss() }
                        .foregroundStyle(PendulumColors.textSecondary)
                }
            }
            .onAppear {
                // Auto-check on appear
                checkForMazeData()
            }
        }
    }

    private func checkForMazeData() {
        isChecking = true
        // Small delay for UX feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mazeData = AppGroupManager.shared.loadMazeData()
            isMazeConnected = mazeData != nil
            checkComplete = true
            isChecking = false
        }
    }
}

// MARK: - Maze Data Summary
struct MazeDataSummary: View {
    let data: MazeSharedData

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(PendulumColors.success)

                Text("Connected to The Maze")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PendulumColors.text)
            }

            HStack(spacing: 16) {
                MazeMetricBadge(
                    value: "\(data.sessions.count)",
                    label: "sessions"
                )

                if let latest = data.sessions.last {
                    MazeMetricBadge(
                        value: String(format: "%.0f", latest.motorScore * 100),
                        label: "motor"
                    )

                    MazeMetricBadge(
                        value: String(format: "%.0f", latest.flowStateScore * 100),
                        label: "flow"
                    )
                }
            }

            Text("Last updated: \(data.lastUpdated, style: .relative) ago")
                .font(.system(size: 11))
                .foregroundStyle(PendulumColors.textTertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.success.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.success.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MazeMetricBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(PendulumColors.text)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(PendulumColors.textTertiary)
        }
    }
}

// MARK: - Preview
#Preview {
    IntegrationView()
}
