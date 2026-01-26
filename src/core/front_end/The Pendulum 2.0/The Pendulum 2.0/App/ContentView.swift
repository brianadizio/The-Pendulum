// ContentView.swift
// The Pendulum 2.0
// Root view with 5-tab navigation using GoldenTheme

import SwiftUI
import Combine

// MARK: - Tab Enum
enum PendulumTab: Int, CaseIterable, Identifiable {
    case play = 0
    case modes = 1
    case dashboard = 2
    case integration = 3
    case settings = 4

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

    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            TabContent(selectedTab: selectedTab, gameState: gameState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            PendulumTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Tab Content
struct TabContent: View {
    let selectedTab: PendulumTab
    @ObservedObject var gameState: GameState

    var body: some View {
        switch selectedTab {
        case .play:
            PlayView(gameState: gameState)
        case .modes:
            ModesView(gameState: gameState)
        case .dashboard:
            DashboardView(gameState: gameState)
        case .integration:
            IntegrationView()
        case .settings:
            SettingsView(gameState: gameState)
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
            Color(uiColor: .systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
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
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                        .frame(width: 30, height: 30)
                }

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
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
    @Published var gameMode: GameMode = .classic
    @Published var isPlaying: Bool = false

    // Physics parameters (user adjustable) - defaults from original app
    @Published var mass: Double = 1.0
    @Published var length: Double = 1.0
    @Published var gravity: Double = 9.81
    @Published var damping: Double = 0.4           // Higher damping for easier control
    @Published var springConstant: Double = 0.0    // No artificial stabilization - player must balance!
    @Published var momentOfInertia: Double = 1.0   // Increased for more stability
    @Published var forceStrength: Double = 3.0     // Push force multiplier

    // Settings - Appearance
    @Published var selectedTheme: AppTheme = .system
    @Published var selectedBackground: BackgroundStyle = .minimal

    // Settings - Gameplay
    @Published var controlSensitivity: Double = 1.0
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var showHints: Bool = true

    // Score tracking
    @Published var currentScore: Int = 0
    @Published var currentSessionTime: TimeInterval = 0
    @Published var pushCount: Int = 0

    init() {
        csvSessionManager = CSVSessionManager()

        // Wire up level manager callback
        levelManager.onLevelChange = { [weak self] level in
            self?.csvSessionManager?.updateLevel(level)
        }
    }

    func startNewSession() {
        csvSessionManager?.startSession(mode: gameMode)
        currentScore = 0
        currentSessionTime = 0
        pushCount = 0
        isPlaying = true

        // Activate perturbation based on mode
        if gameMode == .zen {
            perturbationManager.activateProfile(.zen)
        } else if gameMode == .classic || gameMode == .progressive {
            perturbationManager.activateProfile(PerturbationProfile.forLevel(levelManager.currentLevel))
        }
    }

    func endSession() {
        csvSessionManager?.endSession()
        perturbationManager.stop()
        isPlaying = false
    }

    func recordPush(direction: PushDirection, magnitude: Double) {
        pushCount += 1
        csvSessionManager?.recordPush(direction: direction, magnitude: magnitude)
    }
}

// MARK: - Game Mode
enum GameMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case progressive = "Progressive"
    case freePlay = "Free Play"
    case challenge = "Challenge"
    case zen = "Zen"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .classic: return "Standard level progression"
        case .progressive: return "Continuous difficulty increase"
        case .freePlay: return "No levels, just balance"
        case .challenge: return "Time-limited challenges"
        case .zen: return "No perturbations, relaxed"
        }
    }
}

// MARK: - Push Direction
enum PushDirection: Int {
    case left = -1
    case right = 1
    case none = 0
}

// MARK: - Preview
#Preview {
    ContentView()
}
