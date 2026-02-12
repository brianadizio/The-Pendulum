// ContentView.swift
// The Pendulum 2.0
// Root view with 5-tab navigation using GoldenTheme

import SwiftUI
import Combine
import PendulumSolver

// MARK: - Tab Enum
enum PendulumTab: Int, CaseIterable, Identifiable {
    case play = 0
    case modes = 1
    case dashboard = 2
    case settings = 3
    case integration = 4

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .play: return "Play"
        case .modes: return "Modes"
        case .dashboard: return "Dashboard"
        case .integration: return "Integration"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .play: return "TabIconPlay"
        case .modes: return "TabIconModes"
        case .dashboard: return "TabIconDashboard"
        case .integration: return "TabIconIntegration"
        case .settings: return "TabIconSettings"
        }
    }

    var sfSymbol: String {
        switch self {
        case .play: return "play.circle"
        case .modes: return "slider.horizontal.3"
        case .dashboard: return "chart.bar"
        case .integration: return "link"
        case .settings: return "gearshape"
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @State private var selectedTab: PendulumTab = .play
    @StateObject private var gameState = GameState()
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        Group {
            if purchaseManager.canAccessApp {
                VStack(spacing: 0) {
                    // Main content area
                    TabContent(selectedTab: selectedTab, gameState: gameState, isPlayTabActive: selectedTab == .play)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Custom tab bar
                    PendulumTabBar(selectedTab: $selectedTab)
                }
                .edgesIgnoringSafeArea(.bottom)
            } else {
                PaywallView(purchaseManager: purchaseManager)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            purchaseManager.updateTrialStatus()
        }
    }
}

// MARK: - Tab Content
struct TabContent: View {
    let selectedTab: PendulumTab
    @ObservedObject var gameState: GameState
    let isPlayTabActive: Bool

    var body: some View {
        // Only create PlayView when on Play tab to fully release Metal/SpriteKit resources
        Group {
            if selectedTab == .play {
                PlayView(gameState: gameState, isActive: true)
            } else {
                // Non-Play tabs don't need SpriteKit
                switch selectedTab {
                case .modes:
                    ModesView(gameState: gameState)
                case .dashboard:
                    DashboardView(gameState: gameState)
                case .integration:
                    IntegrationView()
                case .settings:
                    SettingsView(gameState: gameState)
                case .play:
                    EmptyView()  // Won't reach here
                }
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct PendulumTabBar: View {
    @Binding var selectedTab: PendulumTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PendulumTab.allCases) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            PendulumColors.background
                .shadow(color: PendulumColors.iron.opacity(0.15), radius: 8, y: -4)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: PendulumTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Try custom image first, fall back to SF Symbol
                if let image = UIImage(named: tab.iconName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .opacity(isSelected ? 1.0 : 0.5)
                } else {
                    Image(systemName: tab.sfSymbol)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? PendulumColors.gold : PendulumColors.iron)
                        .frame(width: 30, height: 30)
                }

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? PendulumColors.text : PendulumColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Game State (Shared across tabs)
class GameState: ObservableObject {
    @Published var levelManager = LevelManager()
    @Published var perturbationManager = PerturbationManager()
    @Published var csvSessionManager: CSVSessionManager?

    // Game mode settings
    @Published var gameMode: GameMode = .freePlay
    @Published var isPlaying: Bool = false

    // Physics parameters (user adjustable) - defaults from original app
    @Published var mass: Double = 1.0
    @Published var length: Double = 1.0
    @Published var gravity: Double = 9.81
    @Published var damping: Double = 0.4           // Higher damping for easier control
    @Published var springConstant: Double = 0.20   // Small stabilization for smoother gameplay
    @Published var momentOfInertia: Double = 1.0   // Increased for more stability
    @Published var forceStrength: Double = 3.0     // Push force multiplier

    // Settings - Appearance
    @Published var selectedBackgroundPhoto: String = "none"  // Asset name or "none" for default parchment

    // Settings - Gameplay
    @Published var soundEnabled: Bool = false
    @Published var hapticsEnabled: Bool = true
    @Published var showHints: Bool = true
    @Published var controlStyle: ControlStyle = .buttons

    // AI settings
    @Published var aiMode: AIMode = .off
    @Published var aiDifficulty: Double = 0.5

    // Score tracking
    @Published var currentScore: Int = 0
    @Published var currentSessionTime: TimeInterval = 0
    @Published var pushCount: Int = 0

    init() {
        csvSessionManager = CSVSessionManager()

        // Wire up level manager callback
        levelManager.onLevelChange = { [weak self] level in
            guard let self = self else { return }
            self.csvSessionManager?.updateLevel(level)
            // Record the config for the new level
            let config = self.levelManager.getConfigForCurrentLevel()
            self.csvSessionManager?.recordLevelConfig(config)
        }
    }

    func startNewSession() {
        csvSessionManager?.startSession(mode: gameMode)
        currentScore = 0
        currentSessionTime = 0
        pushCount = 0
        isPlaying = true

        // Singular attribution tracking
        SingularTracker.trackModeSelected(mode: gameMode.rawValue)
        SingularTracker.trackSessionStart(mode: gameMode.rawValue, level: levelManager.currentLevel)

        // Start AI session
        AIManager.shared.onSessionStart()

        // Golden Mode: apply recommendation config before level/perturbation setup
        if gameMode == .golden, let rec = GoldenModeManager.shared.currentRecommendation {
            GoldenModeManager.shared.onGoldenSessionStart(recommendation: rec)

            // Apply physics overrides
            if let d = rec.config.dampingOverride { damping = d }
            if let g = rec.config.gravityOverride { gravity = g }
            if let m = rec.config.massOverride { mass = m }

            // Apply AI mode from recommendation
            let aiModeStr = rec.config.aiMode
            if let mode = AIMode.allCases.first(where: { $0.rawValue == aiModeStr }) {
                aiMode = mode
                AIManager.shared.setMode(mode, difficulty: rec.config.suggestedDifficulty)
            }
        }

        // Configure level manager for current mode and reset to level 1
        levelManager.activeMode = gameMode
        levelManager.resetToLevel1()

        // For golden mode, jump to recommended level (capped at 3 to prevent impossible starts)
        if gameMode == .golden, let rec = GoldenModeManager.shared.currentRecommendation {
            let cappedLevel = min(rec.config.suggestedLevel, 3)
            for _ in 1..<cappedLevel {
                levelManager.advanceToNextLevel()
            }
        }

        // Record initial level config
        let initialConfig = levelManager.getConfigForCurrentLevel()
        csvSessionManager?.recordLevelConfig(initialConfig)

        // Activate perturbation based on mode
        if gameMode.hasPerturbations {
            if gameMode == .progressive || gameMode == .golden {
                perturbationManager.activateProfile(
                    PerturbationProfile.forProgressiveLevel(levelManager.currentLevel)
                )
            } else if gameMode == .jiggle {
                let config = levelManager.getConfigForCurrentLevel()
                perturbationManager.activateProfile(
                    PerturbationProfile.jiggle(intensity: config.jiggleIntensity)
                )
            } else {
                perturbationManager.activateProfile(
                    PerturbationProfile.forLevel(levelManager.currentLevel)
                )
            }
        } else {
            perturbationManager.activateProfile(.zen)
        }

        // For Random mode, apply randomized physics at level start
        if gameMode == .random {
            applyRandomizedPhysics()
        }
    }

    /// Apply randomized physics parameters for Random mode
    func applyRandomizedPhysics() {
        let config = levelManager.getConfigForCurrentLevel()
        mass = config.massMultiplier * LevelManager.baseMass
        length = config.lengthMultiplier * LevelManager.baseLength
        gravity = config.gravityMultiplier * LevelManager.baseGravity
        damping = config.dampingValue
        springConstant = config.springConstantValue
    }

    func endSession() {
        // Capture session info before ending
        let sessionStartTime = csvSessionManager?.sessionStartTime
        let sessionDuration = csvSessionManager?.sessionDuration ?? 0
        let sessionScore = currentScore

        // Capture file paths before endSession() clears them
        let csvURL = csvSessionManager?.csvFilePath
        let metaURL = csvSessionManager?.metadataFilePath
        let sessionId = csvSessionManager?.currentSessionId

        // Compute metrics for App Group before CSV session closes
        let appGroupMetrics = computeAppGroupMetrics(csvURL: csvURL, sessionDuration: sessionDuration)

        // Singular attribution tracking
        SingularTracker.trackSessionEnd(
            mode: gameMode.rawValue,
            duration: sessionDuration,
            score: sessionScore,
            levelsCompleted: max(0, levelManager.currentLevel - 1)
        )

        // End the CSV session
        csvSessionManager?.endSession()
        perturbationManager.stop()
        isPlaying = false

        // End AI session (exports training data + uploads to Firebase)
        AIManager.shared.onSessionEnd()

        // Golden Mode: record session outcome
        if gameMode == .golden {
            GoldenModeManager.shared.onGoldenSessionEnd(
                sessionDuration: sessionDuration,
                sessionCompleted: sessionDuration >= 60,
                levelsCompleted: levelManager.currentLevel - 1,
                finalStability: appGroupMetrics.balancePercent,
                finalReactionTime: appGroupMetrics.reactionTime,
                score: sessionScore
            )

            // Singular: track golden mode engagement
            SingularTracker.trackGoldenSessionEnd(
                coherenceScore: GoldenModeManager.shared.coherenceScore,
                duration: sessionDuration
            )
        }

        // Write to App Group shared container (for The Maze integration)
        if let sid = sessionId {
            AppGroupManager.shared.writeSession(
                sessionId: sid,
                duration: sessionDuration,
                balancePercent: appGroupMetrics.balancePercent,
                averageReactionTime: appGroupMetrics.reactionTime,
                angleVariance: appGroupMetrics.angleVariance,
                level: levelManager.currentLevel,
                score: sessionScore
            )
        }

        // Upload session data to Firebase Storage
        if let csvURL = csvURL, let metaURL = metaURL, let sessionId = sessionId {
            Task {
                await FirebaseManager.shared.uploadSession(
                    csvURL: csvURL,
                    metadataURL: metaURL,
                    sessionId: sessionId
                )
            }
        }

        // Log to HealthKit if authorized (minimum 1 minute)
        if HealthKitManager.shared.isAuthorized,
           let startTime = sessionStartTime,
           sessionDuration >= 60 {
            Task {
                do {
                    try await HealthKitManager.shared.logMindfulnessSession(
                        startDate: startTime,
                        endDate: Date()
                    )

                    // Store health correlation if profile exists
                    if ProfileManager.shared.hasCompletedProfile {
                        let snapshot = try await HealthKitManager.shared.fetchDailyHealthSnapshot()
                        let correlation = HealthCorrelation(
                            sessionId: UUID(),
                            sessionScore: sessionScore,
                            sessionDuration: sessionDuration,
                            healthSnapshot: snapshot
                        )
                        await MainActor.run {
                            ProfileManager.shared.addHealthCorrelation(correlation)
                        }
                    }
                } catch {
                    print("Failed to log session to HealthKit: \(error)")
                }
            }
        }
    }

    func recordPush(direction: PushDirection, magnitude: Double) {
        pushCount += 1
        csvSessionManager?.recordPush(direction: direction, magnitude: magnitude)
    }

    // MARK: - App Group Metrics

    private func computeAppGroupMetrics(csvURL: URL?, sessionDuration: TimeInterval) -> (balancePercent: Double, reactionTime: Double, angleVariance: Double) {
        guard let url = csvURL,
              let data = csvSessionManager?.readSessionData(from: url),
              !data.isEmpty else {
            return (0, 0, 0)
        }

        // Balance percent: % of frames where isBalanced == true
        var balancedFrames = 0
        var totalFrames = 0
        var angles: [Double] = []

        for row in data {
            if row["isBalanced"] == "true" {
                balancedFrames += 1
            }
            if let angleStr = row["angle"], let angle = Double(angleStr) {
                let deviation = abs(angle - .pi) * 180 / .pi  // degrees from upright
                angles.append(deviation)
                totalFrames += 1
            }
        }

        let balancePercent = totalFrames > 0 ? Double(balancedFrames) / Double(totalFrames) * 100.0 : 0

        // Angle variance (std dev in degrees)
        var angleVariance: Double = 0
        if !angles.isEmpty {
            let mean = angles.reduce(0, +) / Double(angles.count)
            let variance = angles.map { pow($0 - mean, 2) }.reduce(0, +) / Double(angles.count)
            angleVariance = sqrt(variance)
        }

        // Average reaction time from CSV reactionTime column
        var reactionTimes: [Double] = []
        for row in data {
            if let rtStr = row["reactionTime"], let rt = Double(rtStr), rt > 0.01 && rt < 2.0 {
                reactionTimes.append(rt)
            }
        }
        let avgReactionTime = reactionTimes.isEmpty ? 0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)

        return (balancePercent, avgReactionTime, angleVariance)
    }
}

// MARK: - Game Mode
enum GameMode: String, CaseIterable, Identifiable {
    case freePlay = "Free Play"
    case progressive = "Progressive"
    case spatial = "Spatial"
    case jiggle = "Jiggle"
    case timed = "Timed"
    case random = "Random"
    case golden = "Golden"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .freePlay: return "No levels, just balance in the green"
        case .progressive: return "Balance time increases each level"
        case .spatial: return "Green zone shrinks each level"
        case .jiggle: return "Random noise makes balancing harder"
        case .timed: return "Beat each level before time runs out"
        case .random: return "Physics change every level"
        case .golden: return "Reactive mode shaped by your health, skills & data"
        }
    }

    var icon: String {
        switch self {
        case .freePlay: return "infinity"
        case .progressive: return "chart.line.uptrend.xyaxis"
        case .spatial: return "scope"
        case .jiggle: return "waveform"
        case .timed: return "timer"
        case .random: return "dice"
        case .golden: return "sun.max.fill"
        }
    }

    var hasLevels: Bool {
        self != .freePlay && self != .golden
    }

    var hasPerturbations: Bool {
        self != .freePlay
    }

    var hasCountdownTimer: Bool {
        self == .timed
    }

    var hasJiggle: Bool {
        self == .jiggle
    }

    /// Standard modes shown in the regular ForEach (golden gets hero card)
    static var standardModes: [GameMode] {
        allCases.filter { $0 != .golden }
    }
}

// MARK: - Push Direction
enum PushDirection: Int {
    case left = -1
    case right = 1
    case none = 0
}

// MARK: - Control Style
enum ControlStyle: String, CaseIterable, Identifiable {
    case buttons = "Buttons"
    case spectrum = "Spectrum"

    var id: String { rawValue }
}

// MARK: - Preview
#Preview {
    ContentView()
}
