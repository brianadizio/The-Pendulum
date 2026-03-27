// GoldenTheme.swift
// Golden Enterprises Theme System
// A topologically-grounded design language for 50+ interconnected mathematical applications

import SwiftUI

/// The core entry point for the Golden Theme system
/// Every UI element is a section of a sheaf over application state space
public struct GoldenTheme {

    // MARK: - Constants

    /// The golden ratio - fundamental to all proportions
    public static let phi: CGFloat = 1.618033988749895

    /// Base unit for spacing (8pt grid)
    public static let baseUnit: CGFloat = 8

    /// Base font size for typography scaling
    public static let baseFontSize: CGFloat = 17

    /// Seven-fold symmetry angle (for Suite navigation)
    public static let sevenFoldAngle: CGFloat = 360.0 / 7.0 // 51.428571°

    // MARK: - Computed Proportions

    /// Phi-scaled spacing values
    public static var spacing: GoldenSpacing { GoldenSpacing() }

    /// Current theme configuration
    @MainActor
    public static var current: ThemeConfiguration {
        ThemeManager.shared.currentTheme
    }

    // MARK: - Initialization

    /// Initialize the theme system with optional customization
    @MainActor
    public static func configure(
        season: Season? = nil,
        location: GeographicContext? = nil,
        timeOfDay: TimeOfDay? = nil
    ) {
        if let season = season {
            ThemeManager.shared.season = season
        }
        if let location = location {
            ThemeManager.shared.location = location
        }
        if let timeOfDay = timeOfDay {
            ThemeManager.shared.timeOfDay = timeOfDay
        }
        ThemeManager.shared.updateTheme()
    }
}

// MARK: - Supporting Types

/// Seasons affect color saturation and dominant hues
public enum Season: String, CaseIterable, Codable {
    case spring  // Fresh greens, light warmth
    case summer  // Vibrant, high saturation
    case autumn  // Warm oranges and browns
    case winter  // Cool, desaturated, silvers

    /// Saturation multiplier for the season
    public var saturationMultiplier: CGFloat {
        switch self {
        case .spring: return 1.1
        case .summer: return 1.3
        case .autumn: return 1.0
        case .winter: return 0.7
        }
    }

    /// Dominant hue shift (in degrees on color wheel)
    public var hueShift: CGFloat {
        switch self {
        case .spring: return 90   // Toward green
        case .summer: return 45   // Toward gold
        case .autumn: return 30   // Toward orange
        case .winter: return 210  // Toward blue
        }
    }
}

/// Geographic context influences color temperature
public enum GeographicContext: String, CaseIterable, Codable {
    case coastal     // Cool blues, oceanic
    case mountain    // Clear, high contrast
    case forest      // Deep greens, earth tones
    case desert      // Warm, sandy tones
    case urban       // Neutral, sophisticated
    case arctic      // White, silver, minimal color

    /// Color temperature adjustment (-1 to 1, negative = cooler)
    public var temperatureAdjustment: CGFloat {
        switch self {
        case .coastal: return -0.2
        case .mountain: return 0.0
        case .forest: return -0.1
        case .desert: return 0.3
        case .urban: return 0.0
        case .arctic: return -0.4
        }
    }
}

/// Time of day affects brightness and warmth
public enum TimeOfDay: String, CaseIterable, Codable {
    case dawn      // Soft pinks and oranges
    case morning   // Clear, neutral
    case noon      // Bright, slightly warm
    case afternoon // Golden hour approaching
    case dusk      // Rich oranges and purples
    case evening   // Deep blues, warm lights
    case night     // Dark mode

    /// Brightness multiplier
    public var brightnessMultiplier: CGFloat {
        switch self {
        case .dawn: return 0.85
        case .morning: return 1.0
        case .noon: return 1.1
        case .afternoon: return 1.0
        case .dusk: return 0.9
        case .evening: return 0.75
        case .night: return 0.5
        }
    }

    /// Whether to use dark mode appearance
    public var prefersDarkMode: Bool {
        switch self {
        case .evening, .night: return true
        default: return false
        }
    }
}

// MARK: - Spacing System

/// Phi-based spacing values
public struct GoldenSpacing {
    /// 4pt - Minimal gaps, icon padding
    public let micro: CGFloat = GoldenTheme.baseUnit / 2

    /// 8pt - Tight spacing, compact layouts
    public let small: CGFloat = GoldenTheme.baseUnit

    /// 13pt - Standard element spacing
    public let medium: CGFloat = GoldenTheme.baseUnit * pow(GoldenTheme.phi, 0.5)

    /// 21pt - Section spacing, generous padding
    public let large: CGFloat = GoldenTheme.baseUnit * GoldenTheme.phi

    /// 34pt - Major section breaks
    public let xlarge: CGFloat = GoldenTheme.baseUnit * pow(GoldenTheme.phi, 2)

    /// 55pt - Screen-level spacing
    public let xxlarge: CGFloat = GoldenTheme.baseUnit * pow(GoldenTheme.phi, 3)
}

// MARK: - View Modifiers

public extension View {
    /// Apply golden theme styling to a view
    func goldenTheme() -> some View {
        self.modifier(GoldenThemeModifier())
    }

    /// Apply a glass/frosted effect for text containers over backgrounds
    func liquidGlass(
        cornerRadius: CGFloat = 16,
        opacity: CGFloat = 0.8
    ) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }

    /// Apply the shimmer loading effect (like Claude/ChatGPT)
    func shimmerLoading(isLoading: Bool) -> some View {
        self.modifier(ShimmerModifier(isLoading: isLoading))
    }
}

// MARK: - View Modifiers Implementation

struct GoldenThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.font, .custom("Times New Roman", size: GoldenTheme.baseFontSize))
    }
}

struct LiquidGlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: CGFloat

    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
    }
}

struct ShimmerModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isLoading {
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: phase)
                        .mask(content)
                    }
                }
            )
            .onAppear {
                if isLoading {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 400
                    }
                }
            }
    }
}
