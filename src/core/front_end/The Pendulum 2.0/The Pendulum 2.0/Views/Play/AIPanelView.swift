// AIPanelView.swift
// The Pendulum 2.0
// AI mode selection sheet with difficulty slider

import SwiftUI
import PendulumSolver

struct AIPanelView: View {
  @ObservedObject var gameState: GameState
  @ObservedObject var aiManager = AIManager.shared
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // AI Mode Selection
          AIModeSection(gameState: gameState, aiManager: aiManager)

          Divider()
            .background(PendulumColors.bronze.opacity(0.3))
            .padding(.horizontal, 16)

          // Difficulty Slider
          AIDifficultySection(gameState: gameState, aiManager: aiManager)

          // Status (when active)
          if aiManager.isActive {
            Divider()
              .background(PendulumColors.bronze.opacity(0.3))
              .padding(.horizontal, 16)

            AIStatusSection(aiManager: aiManager)
          }
        }
        .padding(.vertical, 16)
      }
      .background(PendulumColors.background)
      .navigationTitle("AI Modes")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .foregroundStyle(PendulumColors.gold)
        }
      }
    }
  }
}

// MARK: - AI Mode Section

struct AIModeSection: View {
  @ObservedObject var gameState: GameState
  @ObservedObject var aiManager: AIManager

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("AI MODE")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)
        .padding(.horizontal, 16)

      VStack(spacing: 8) {
        ForEach(AIMode.allCases) { mode in
          AIModeButton(
            mode: mode,
            isSelected: gameState.aiMode == mode
          ) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
              gameState.aiMode = mode
              aiManager.setMode(mode, difficulty: gameState.aiDifficulty)
            }
          }
        }
      }
      .padding(.horizontal, 16)
    }
  }
}

// MARK: - AI Mode Button

struct AIModeButton: View {
  let mode: AIMode
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
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

// MARK: - AI Difficulty Section

struct AIDifficultySection: View {
  @ObservedObject var gameState: GameState
  @ObservedObject var aiManager: AIManager

  private var difficultyLabel: String {
    switch gameState.aiMode {
    case .off:         return "Difficulty"
    case .competition: return "Opponent Strength"
    case .helper:      return "Assistance Level"
    case .tutorial:    return "Guidance Level"
    case .demo:        return "Control Precision"
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("DIFFICULTY")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)
        .padding(.horizontal, 16)

      VStack(spacing: 8) {
        HStack {
          Text(difficultyLabel)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(PendulumColors.text)

          Spacer()

          Text(String(format: "%.0f%%", gameState.aiDifficulty * 100))
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundStyle(PendulumColors.gold)
        }

        Slider(value: $gameState.aiDifficulty, in: 0.0...1.0, step: 0.05)
          .tint(PendulumColors.gold)
          .onChange(of: gameState.aiDifficulty) { _, newValue in
            aiManager.setMode(gameState.aiMode, difficulty: newValue)
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
      .padding(.horizontal, 16)
    }
    .opacity(gameState.aiMode == .off ? 0.5 : 1.0)
    .disabled(gameState.aiMode == .off)
  }
}

// MARK: - AI Status Section

struct AIStatusSection: View {
  @ObservedObject var aiManager: AIManager

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("STATUS")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)
        .padding(.horizontal, 16)

      VStack(spacing: 8) {
        HStack {
          Text("AI Force")
            .font(.system(size: 14))
            .foregroundStyle(PendulumColors.textSecondary)

          Spacer()

          Text(String(format: "%.3f", aiManager.lastAIForce))
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundStyle(PendulumColors.text)
        }

        HStack {
          Text("Mode")
            .font(.system(size: 14))
            .foregroundStyle(PendulumColors.textSecondary)

          Spacer()

          HStack(spacing: 6) {
            Image(systemName: aiManager.currentMode.icon)
              .font(.system(size: 14))
            Text(aiManager.currentMode.rawValue)
              .font(.system(size: 14, weight: .semibold))
          }
          .foregroundStyle(PendulumColors.gold)
        }
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(PendulumColors.backgroundTertiary)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(PendulumColors.success.opacity(0.3), lineWidth: 1)
      )
      .padding(.horizontal, 16)
    }
  }
}

#Preview {
  AIPanelView(gameState: GameState())
}
