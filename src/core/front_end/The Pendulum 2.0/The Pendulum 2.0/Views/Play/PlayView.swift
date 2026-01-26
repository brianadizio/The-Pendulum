// PlayView.swift
// The Pendulum 2.0
// Main gameplay view with SpriteKit pendulum and controls

import SwiftUI
import SpriteKit

struct PlayView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var viewModel = PendulumViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            PlayHeader(gameState: gameState, viewModel: viewModel)

            // Game area
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color(uiColor: .secondarySystemBackground)
                        .ignoresSafeArea()

                    // SpriteKit Scene
                    PendulumSceneView(viewModel: viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    // HUD overlay
                    VStack {
                        HUDView(viewModel: viewModel, gameState: gameState)
                            .padding(.top, 8)

                        Spacer()

                        // Control buttons
                        ControlButtonsView(viewModel: viewModel, gameState: gameState)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
        .onAppear {
            setupGame()
        }
        .onDisappear {
            viewModel.pauseSimulation()
        }
    }

    private func setupGame() {
        // Connect perturbation manager
        gameState.perturbationManager.onApplyForce = { [weak viewModel] force in
            viewModel?.applyExternalForce(force)
        }

        // Handle fall - pause game when pendulum falls past 90 degrees
        viewModel.onFall = { [weak gameState] in
            gameState?.endSession()
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

    var body: some View {
        HStack {
            Text("The Pendulum")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(.primary)

            Spacer()

            // Play/Pause button
            Button(action: {
                if viewModel.isSimulating {
                    viewModel.pauseSimulation()
                    gameState.endSession()
                } else {
                    gameState.startNewSession()
                    viewModel.startSimulation()
                }
            }) {
                Image(systemName: viewModel.isSimulating ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.isSimulating ? .orange : .green)
            }

            // Reset button
            Button(action: {
                viewModel.resetWithPerturbation(degrees: 8.0)
                gameState.levelManager.resetToLevel1()
            }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - HUD View
struct HUDView: View {
    @ObservedObject var viewModel: PendulumViewModel
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 16) {
            // Score card
            StatCard(title: "Score", value: "\(viewModel.score)")

            // Level card
            StatCard(title: "Level", value: "\(gameState.levelManager.currentLevel)")

            // Time card
            StatCard(title: "Time", value: formatTime(viewModel.elapsedTime))

            // Balance indicator
            BalanceIndicator(progress: viewModel.balanceProgress)
        }
        .padding(.horizontal, 16)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
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
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .frame(minWidth: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
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
                .foregroundStyle(.secondary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(progress >= 1.0 ? Color.green : Color.orange)
                    .frame(width: 60 * min(progress, 1.0), height: 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Control Buttons View
struct ControlButtonsView: View {
    @ObservedObject var viewModel: PendulumViewModel
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 40) {
            // Push Left
            ControlButton(
                label: "Push Left",
                systemImage: "arrow.left.circle.fill",
                color: .blue
            ) {
                viewModel.applyForce(-1.0)
                gameState.recordPush(direction: .left, magnitude: 1.0)
            }
            .disabled(!viewModel.isSimulating)

            // Push Right
            ControlButton(
                label: "Push Right",
                systemImage: "arrow.right.circle.fill",
                color: .blue
            ) {
                viewModel.applyForce(1.0)
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
                    .foregroundStyle(.primary)
            }
            .frame(minWidth: 100)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
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
