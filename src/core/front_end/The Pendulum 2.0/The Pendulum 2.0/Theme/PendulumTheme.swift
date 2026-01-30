// PendulumTheme.swift
// The Pendulum 2.0
// Golden Theme integration and app-specific colors

import SwiftUI
import GoldenTheme

// MARK: - Pendulum Theme Colors

/// App-specific color definitions using Golden Theme as base
struct PendulumColors {

    // MARK: - Background Colors (from Golden Theme)

    /// Primary background - cream/parchment
    static var background: Color {
        Color(red: 0.97, green: 0.95, blue: 0.91) // #F8F3E8
    }

    /// Secondary background - slightly darker cream
    static var backgroundSecondary: Color {
        Color(red: 0.94, green: 0.91, blue: 0.85) // #F0E7D9
    }

    /// Tertiary background - for cards
    static var backgroundTertiary: Color {
        Color.white
    }

    // MARK: - Text Colors

    /// Primary text - near black
    static var text: Color {
        Color(red: 0.10, green: 0.10, blue: 0.10) // #1A1A1A
    }

    /// Secondary text
    static var textSecondary: Color {
        Color(red: 0.40, green: 0.40, blue: 0.40) // #666666
    }

    /// Tertiary text - labels, captions
    static var textTertiary: Color {
        Color(red: 0.55, green: 0.55, blue: 0.55) // #8C8C8C
    }

    // MARK: - Metal Colors (from Golden Theme)

    /// Gold - primary accent
    static var gold: Color {
        Color(red: 0.85, green: 0.65, blue: 0.13) // #DAA520
    }

    /// Gold light - highlights
    static var goldLight: Color {
        Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700
    }

    /// Gold dark - shadows, emphasis
    static var goldDark: Color {
        Color(red: 0.72, green: 0.53, blue: 0.04) // #B8860B
    }

    /// Bronze - secondary accent
    static var bronze: Color {
        Color(red: 0.55, green: 0.41, blue: 0.08) // #8B6914
    }

    /// Iron - neutral, text-like
    static var iron: Color {
        Color(red: 0.29, green: 0.29, blue: 0.29) // #4A4A4A
    }

    /// Silver - subtle accents
    static var silver: Color {
        Color(red: 0.75, green: 0.75, blue: 0.75) // #C0C0C0
    }

    // MARK: - Semantic Colors

    /// Success/balanced state
    static var success: Color {
        Color(red: 0.30, green: 0.69, blue: 0.31) // Green
    }

    /// Warning state
    static var warning: Color {
        Color(red: 0.95, green: 0.77, blue: 0.06) // Yellow
    }

    /// Caution state
    static var caution: Color {
        Color(red: 0.95, green: 0.55, blue: 0.13) // Orange
    }

    /// Danger/error state
    static var danger: Color {
        Color(red: 0.80, green: 0.20, blue: 0.15) // Red
    }

    // MARK: - UIColor versions for SpriteKit

    static var backgroundUI: UIColor {
        UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)
    }

    static var goldUI: UIColor {
        UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
    }

    static var bronzeUI: UIColor {
        UIColor(red: 0.55, green: 0.41, blue: 0.08, alpha: 1.0)
    }

    static var ironUI: UIColor {
        UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
    }

    static var successUI: UIColor {
        UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
    }
}

// MARK: - View Extension for Theme

extension View {
    /// Apply parchment background
    func parchmentBackground() -> some View {
        self.background(PendulumColors.background)
    }

    /// Apply card styling
    func cardStyle() -> some View {
        self
            .background(PendulumColors.backgroundTertiary)
            .cornerRadius(12)
            .shadow(color: PendulumColors.iron.opacity(0.1), radius: 4, y: 2)
    }

    /// Apply section header styling
    func sectionHeader() -> some View {
        self
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(PendulumColors.textTertiary)
    }
}

// MARK: - Button Styles

struct GoldButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isEnabled ? PendulumColors.gold : PendulumColors.silver)
            )
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(PendulumColors.gold, lineWidth: 1.5)
            )
            .foregroundStyle(PendulumColors.gold)
            .font(.system(size: 14, weight: .medium))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Gradients

struct PendulumGradients {
    /// Golden hour gradient
    static var goldenHour: LinearGradient {
        LinearGradient(
            colors: [PendulumColors.goldLight, PendulumColors.bronze],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle parchment gradient
    static var parchment: LinearGradient {
        LinearGradient(
            colors: [
                PendulumColors.background,
                PendulumColors.backgroundSecondary
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Danger zone gradient (for pendulum zones)
    static var dangerZone: LinearGradient {
        LinearGradient(
            colors: [
                PendulumColors.success,
                PendulumColors.warning,
                PendulumColors.caution,
                PendulumColors.danger
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
