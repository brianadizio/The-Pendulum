// ModesView.swift
// The Pendulum 2.0
// Two-section layout: Game Modes (top) + Parameters (bottom)

import SwiftUI

struct ModesView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ModesHeader()

            ScrollView {
                VStack(spacing: 24) {
                    // Section 1: Game Modes
                    GameModeSection(gameState: gameState)

                    Divider()
                        .background(PendulumColors.bronze.opacity(0.3))
                        .padding(.horizontal, 16)

                    // Section 2: Physics Parameters
                    ParametersSection(gameState: gameState)
                }
                .padding(.vertical, 16)
            }
        }
        .background(PendulumColors.background)
    }
}

// MARK: - Modes Header
struct ModesHeader: View {
    var body: some View {
        HStack {
            Text("Modes")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PendulumColors.background)
    }
}

// MARK: - Game Mode Section
struct GameModeSection: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GAME MODE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                ForEach(GameMode.allCases) { mode in
                    ModeButton(
                        mode: mode,
                        isSelected: gameState.gameMode == mode
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            gameState.gameMode = mode
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Mode Button
struct ModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Mode icon
                Image(systemName: mode.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .white : PendulumColors.gold)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : PendulumColors.text)

                    Text(mode.description)
                        .font(.system(size: 12))
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : PendulumColors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? PendulumColors.gold : PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : PendulumColors.bronze.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: PendulumColors.iron.opacity(isSelected ? 0.2 : 0.05), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Parameters Section
struct ParametersSection: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PHYSICS PARAMETERS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 16) {
                ParameterSlider(
                    title: "Mass",
                    value: $gameState.mass,
                    range: 0.5...2.0,
                    unit: "kg"
                )

                ParameterSlider(
                    title: "Length",
                    value: $gameState.length,
                    range: 0.5...2.0,
                    unit: "m"
                )

                ParameterSlider(
                    title: "Gravity",
                    value: $gameState.gravity,
                    range: 5.0...15.0,
                    unit: "m/s²"
                )

                ParameterSlider(
                    title: "Damping",
                    value: $gameState.damping,
                    range: 0.0...1.0,
                    unit: ""
                )

                ParameterSlider(
                    title: "Spring",
                    value: $gameState.springConstant,
                    range: 0.0...3.0,
                    unit: ""
                )

                ParameterSlider(
                    title: "Moment of Inertia",
                    value: $gameState.momentOfInertia,
                    range: 0.1...3.0,
                    unit: ""
                )

                ParameterSlider(
                    title: "Force Strength",
                    value: $gameState.forceStrength,
                    range: 1.0...10.0,
                    unit: ""
                )
            }
            .padding(.horizontal, 16)

            // Reset button
            Button(action: {
                withAnimation {
                    gameState.mass = 1.0
                    gameState.length = 1.0
                    gameState.gravity = 9.81
                    gameState.damping = 0.4
                    gameState.springConstant = 0.20
                    gameState.momentOfInertia = 1.0
                    gameState.forceStrength = 3.0
                }
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset to Defaults")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PendulumColors.gold)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

// MARK: - Parameter Slider
struct ParameterSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Text(String(format: "%.2f%@", value, unit.isEmpty ? "" : " \(unit)"))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(PendulumColors.textSecondary)
            }

            Slider(value: $value, in: range)
                .tint(PendulumColors.gold)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

// MARK: - Preview
#Preview {
    ModesView(gameState: GameState())
}
