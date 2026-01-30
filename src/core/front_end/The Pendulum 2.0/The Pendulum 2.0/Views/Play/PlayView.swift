// PlayView.swift
// The Pendulum 2.0
// Main gameplay view with SpriteKit pendulum and controls

import SwiftUI
import SpriteKit

struct PlayView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var viewModel = PendulumViewModel()
    @StateObject private var profileManager = ProfileManager.shared
    @State private var showingProfileSheet = false
    @State private var showingAIPanel = false
    @StateObject private var aiManager = AIManager.shared
    var isActive: Bool = true  // Controls whether SKView is paused (for Metal resource management)

    var body: some View {
        VStack(spacing: 0) {
            // Profile prompt banner (if applicable)
            if profileManager.shouldShowProfilePrompt {
                ProfileBannerView(
                    onCreateProfile: { showingProfileSheet = true },
                    onDismiss: { profileManager.dismissPromptTemporarily() }
                )
            }

            // Header
            PlayHeader(gameState: gameState, viewModel: viewModel, showingAIPanel: $showingAIPanel, aiManager: aiManager)

            // Game area
            GeometryReader { geometry in
                ZStack {
                    // Background - parchment color
                    PendulumColors.background
                        .ignoresSafeArea()

                    // SpriteKit Scene - paused when not active to free Metal resources
                    PendulumSceneView(viewModel: viewModel, isPaused: !isActive)
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    // HUD overlay
                    VStack {
                        VStack(spacing: 4) {
                            HUDView(viewModel: viewModel, gameState: gameState)

                            // AI status badge (visible when AI is active)
                            if aiManager.isActive {
                                AIStatusBadge(aiManager: aiManager)
                            }
                        }
                        .padding(.top, 8)

                        Spacer()

                        // Game control buttons (Play/Pause/Reset) - above push buttons
                        GameControlButtons(gameState: gameState, viewModel: viewModel)
                            .padding(.bottom, 16)

                        // Push control buttons (disabled in demo mode — AI controls the pendulum)
                        ControlButtonsView(viewModel: viewModel, gameState: gameState)
                            .padding(.bottom, 16)
                            .disabled(gameState.aiMode == .demo)
                            .opacity(gameState.aiMode == .demo ? 0.4 : 1.0)
                    }

                    // Tutorial hint overlay (centered, above controls)
                    if let hint = aiManager.currentHint {
                        VStack {
                            Spacer()
                            TutorialHintOverlay(hint: hint)
                                .padding(.bottom, 200)
                        }
                    }
                }
            }
        }
        .onAppear {
            setupGame()
            // Record first session for 3-day prompt tracking
            profileManager.recordFirstSessionIfNeeded()
            profileManager.updatePromptState()
        }
        .onDisappear {
            // End session properly when leaving Play tab
            viewModel.pauseSimulation()
            gameState.endSession()
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSetupView(existingProfile: profileManager.currentProfile)
        }
        .sheet(isPresented: $showingAIPanel) {
            AIPanelView(gameState: gameState)
        }
    }

    private func setupGame() {
        // Connect CSV session manager for state recording
        viewModel.csvSessionManager = gameState.csvSessionManager

        // Connect level manager
        viewModel.levelManager = gameState.levelManager

        // Set active game mode on view model
        viewModel.activeGameMode = gameState.gameMode

        // Connect perturbation manager - both the callback and the reference for per-frame updates
        viewModel.perturbationManager = gameState.perturbationManager
        gameState.perturbationManager.onApplyForce = { [weak viewModel] force in
            viewModel?.applyExternalForce(force)
        }

        // Connect AI manager
        viewModel.aiManager = AIManager.shared
        AIManager.shared.onApplyForce = { [weak viewModel] force in
            viewModel?.applyExternalForce(force)
        }
        AIManager.shared.configurePhysics(
            mass: gameState.mass,
            length: gameState.length,
            gravity: gameState.gravity,
            damping: gameState.damping,
            springConstant: gameState.springConstant,
            momentOfInertia: gameState.momentOfInertia
        )
        AIManager.shared.setMode(gameState.aiMode, difficulty: gameState.aiDifficulty)

        // Handle fall - pause game when pendulum falls past 90 degrees
        viewModel.onFall = { [weak gameState] in
            gameState?.endSession()
        }

        // Handle timer expiry (Timed mode) - fail and reset to level 1
        viewModel.onTimerExpired = { [weak gameState, weak viewModel] in
            gameState?.levelManager.resetToLevel1()
            gameState?.endSession()
            // Reset viewModel state
            viewModel?.resetWithPerturbation(degrees: 8.0)
        }

        // Handle level completion - advance to next level
        viewModel.onLevelComplete = { [weak gameState, weak viewModel] completedLevel in
            guard let gs = gameState else { return }
            gs.levelManager.advanceToNextLevel()

            // Apply new level config without resetting pendulum position
            let config = gs.levelManager.getConfigForCurrentLevel()
            viewModel?.applyLevelConfigContinuous(config)

            // Update perturbation for new level
            if gs.gameMode.hasPerturbations {
                if gs.gameMode == .jiggle {
                    gs.perturbationManager.activateProfile(
                        PerturbationProfile.jiggle(intensity: config.jiggleIntensity)
                    )
                } else {
                    gs.perturbationManager.activateProfile(
                        PerturbationProfile.forLevel(gs.levelManager.currentLevel)
                    )
                }
            }

            // Random mode: re-roll physics
            if gs.gameMode == .random {
                gs.applyRandomizedPhysics()
                viewModel?.updateParameters(
                    mass: gs.mass,
                    length: gs.length,
                    gravity: gs.gravity,
                    damping: gs.damping,
                    springConstant: gs.springConstant,
                    momentOfInertia: gs.momentOfInertia
                )
            }
        }

        // Set initial parameters from game state
        viewModel.updateParameters(
            mass: gameState.mass,
            length: gameState.length,
            gravity: gameState.gravity,
            damping: gameState.damping,
            springConstant: gameState.springConstant,
            momentOfInertia: gameState.momentOfInertia
        )

        // Start with small initial perturbation (pendulum slightly off-center)
        viewModel.resetWithPerturbation(degrees: 8.0)
    }
}

// MARK: - Play Header
struct PlayHeader: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var viewModel: PendulumViewModel
    @Binding var showingAIPanel: Bool
    @ObservedObject var aiManager: AIManager

    var body: some View {
        HStack {
            Text("The Pendulum")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Spacer()

            // AI button — sparkles icon, green tint when active
            Button(action: {
                showingAIPanel = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(aiManager.isActive ? PendulumColors.success : PendulumColors.gold)

                    // Active indicator dot
                    if aiManager.isActive {
                        Circle()
                            .fill(PendulumColors.success)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: -2)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PendulumColors.background)
    }
}

// MARK: - Game Control Buttons (Play/Pause/Reset)
struct GameControlButtons: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var viewModel: PendulumViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Reset button
            Button(action: {
                viewModel.resetWithPerturbation(degrees: 8.0)
                gameState.levelManager.resetToLevel1()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Reset")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(PendulumColors.bronze)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PendulumColors.backgroundTertiary.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Play/Pause button
            Button(action: {
                if viewModel.isSimulating {
                    viewModel.pauseSimulation()
                    gameState.endSession()
                } else {
                    // Sync mode and apply level config before starting
                    viewModel.activeGameMode = gameState.gameMode
                    gameState.startNewSession()

                    // Apply level config for the current mode/level
                    if gameState.gameMode.hasLevels {
                        let config = gameState.levelManager.getConfigForCurrentLevel()
                        viewModel.applyLevelConfig(config)
                    }

                    viewModel.startSimulation()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isSimulating ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text(viewModel.isSimulating ? "Pause" : "Start")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.isSimulating ? PendulumColors.caution : PendulumColors.success)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - HUD View
struct HUDView: View {
    @ObservedObject var viewModel: PendulumViewModel
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 8) {
            // Mode badge row
            if gameState.gameMode != .freePlay {
                ModeBadge(mode: gameState.gameMode)
            }

            HStack(spacing: 16) {
                // Score card
                StatCard(title: "Score", value: "\(viewModel.score)")

                // Level card (hide for Free Play)
                if gameState.gameMode.hasLevels {
                    StatCard(title: "Level", value: "\(gameState.levelManager.currentLevel)")
                }

                // Countdown timer (Timed mode)
                if let countdown = viewModel.countdownTimeRemaining {
                    CountdownCard(timeRemaining: countdown)
                } else {
                    // Regular time card
                    StatCard(title: "Time", value: formatTime(viewModel.elapsedTime))
                }

                // Balance indicator
                BalanceIndicator(progress: viewModel.balanceProgress)
            }
        }
        .padding(.horizontal, 16)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Mode Badge
struct ModeBadge: View {
    let mode: GameMode

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mode.icon)
                .font(.system(size: 12))
            Text(mode.rawValue)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(PendulumColors.gold)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(PendulumColors.backgroundTertiary.opacity(0.9))
        )
        .overlay(
            Capsule()
                .stroke(PendulumColors.gold.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Countdown Card
struct CountdownCard: View {
    let timeRemaining: TimeInterval

    private var isLow: Bool { timeRemaining < 5.0 }

    var body: some View {
        VStack(spacing: 4) {
            Text("Timer")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(isLow ? PendulumColors.danger : PendulumColors.textSecondary)

            Text(formatCountdown(timeRemaining))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(isLow ? PendulumColors.danger : PendulumColors.text)
        }
        .frame(minWidth: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isLow
                      ? PendulumColors.danger.opacity(0.1)
                      : PendulumColors.backgroundTertiary.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isLow
                        ? PendulumColors.danger.opacity(0.5)
                        : PendulumColors.bronze.opacity(0.3),
                        lineWidth: 1)
        )
    }

    private func formatCountdown(_ seconds: TimeInterval) -> String {
        let secs = max(0, Int(ceil(seconds)))
        return "\(secs)s"
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(PendulumColors.textSecondary)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(PendulumColors.text)
        }
        .frame(minWidth: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Balance Indicator
struct BalanceIndicator: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 4) {
            Text("Balance")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(PendulumColors.textSecondary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(PendulumColors.backgroundSecondary)
                    .frame(width: 60, height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(progress >= 1.0 ? PendulumColors.success : PendulumColors.gold)
                    .frame(width: 60 * min(progress, 1.0), height: 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Control Buttons View
struct ControlButtonsView: View {
    @ObservedObject var viewModel: PendulumViewModel
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 40) {
            // Push Left (positive force pushes pendulum left in θ = π coordinate system)
            ControlButton(
                label: "Push Left",
                systemImage: "arrow.left.circle.fill",
                color: PendulumColors.gold
            ) {
                viewModel.applyForce(1.0)
                gameState.recordPush(direction: .left, magnitude: 1.0)
            }
            .disabled(!viewModel.isSimulating)

            // Push Right (negative force pushes pendulum right in θ = π coordinate system)
            ControlButton(
                label: "Push Right",
                systemImage: "arrow.right.circle.fill",
                color: PendulumColors.gold
            ) {
                viewModel.applyForce(-1.0)
                gameState.recordPush(direction: .right, magnitude: 1.0)
            }
            .disabled(!viewModel.isSimulating)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Control Button
struct ControlButton: View {
    let label: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 48))
                    .foregroundStyle(color)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)
            }
            .frame(minWidth: 100)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PendulumColors.backgroundTertiary.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Press Events Modifier
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Preview
#Preview {
    PlayView(gameState: GameState())
}
