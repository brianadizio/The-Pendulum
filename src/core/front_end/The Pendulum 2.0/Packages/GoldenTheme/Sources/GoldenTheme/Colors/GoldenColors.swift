// GoldenColors.swift
// Golden Enterprises Theme System
// Color palette sampled from rainbow colorbar with gray/saturation matrix

import SwiftUI

// MARK: - Rainbow Spectrum Colors

/// Colors sampled from the rainbow colorbar spectrum
/// Each color has 12 variants from light (desaturated) to dark (saturated)
public enum SpectrumColor: String, CaseIterable, Codable {
    case red
    case orange
    case gold
    case yellow
    case lime
    case green
    case teal
    case cyan
    case azure
    case blue
    case indigo
    case violet
    case magenta
    case rose

    /// Base hue value (0-360)
    public var hue: CGFloat {
        switch self {
        case .red:     return 0
        case .orange:  return 25
        case .gold:    return 43
        case .yellow:  return 55
        case .lime:    return 80
        case .green:   return 120
        case .teal:    return 160
        case .cyan:    return 180
        case .azure:   return 210
        case .blue:    return 230
        case .indigo:  return 260
        case .violet:  return 280
        case .magenta: return 300
        case .rose:    return 330
        }
    }

    /// Get a color variant at a specific luminance level (1-12)
    /// Level 1 = lightest/most desaturated (top of matrix)
    /// Level 12 = darkest/most saturated (bottom of matrix)
    public func variant(_ level: Int) -> Color {
        let clampedLevel = max(1, min(12, level))
        let normalizedLevel = CGFloat(clampedLevel - 1) / 11.0

        // Saturation increases from top to bottom (0.1 to 1.0)
        let saturation = 0.1 + (normalizedLevel * 0.9)

        // Brightness decreases slightly from top to bottom (1.0 to 0.6)
        let brightness = 1.0 - (normalizedLevel * 0.4)

        return Color(hue: hue / 360.0, saturation: saturation, brightness: brightness)
    }

    /// Light variant (level 3) - for light mode backgrounds
    public var light: Color { variant(3) }

    /// Base variant (level 6) - primary use
    public var base: Color { variant(6) }

    /// Dark variant (level 9) - for dark mode or emphasis
    public var dark: Color { variant(9) }

    /// Very dark variant (level 11) - for text on light backgrounds
    public var veryDark: Color { variant(11) }
}

// MARK: - Metal-Inspired Colors (for UI chrome)

/// Precious metal colors for buttons, accents, and flourishes
/// Inspired by Italian Renaissance precious metals
public enum MetalColor: String, CaseIterable, Codable {
    case gold
    case silver
    case copper
    case bronze
    case platinum
    case titanium
    case iron
    case lead

    public var light: Color {
        switch self {
        case .gold:     return Color(red: 1.0, green: 0.84, blue: 0.0)       // #FFD700
        case .silver:   return Color(red: 0.91, green: 0.91, blue: 0.91)     // #E8E8E8
        case .copper:   return Color(red: 0.96, green: 0.64, blue: 0.38)     // #F4A460
        case .bronze:   return Color(red: 0.80, green: 0.52, blue: 0.25)     // #CD853F
        case .platinum: return Color(red: 0.94, green: 0.94, blue: 0.94)     // #F0F0F0
        case .titanium: return Color(red: 0.88, green: 0.88, blue: 0.88)     // #E0E0E0
        case .iron:     return Color(red: 0.63, green: 0.62, blue: 0.58)     // #A19D94
        case .lead:     return Color(red: 0.55, green: 0.53, blue: 0.50)     // #8B8680
        }
    }

    public var base: Color {
        switch self {
        case .gold:     return Color(red: 0.85, green: 0.65, blue: 0.13)     // #DAA520
        case .silver:   return Color(red: 0.75, green: 0.75, blue: 0.75)     // #C0C0C0
        case .copper:   return Color(red: 0.72, green: 0.45, blue: 0.20)     // #B87333
        case .bronze:   return Color(red: 0.55, green: 0.41, blue: 0.08)     // #8B6914
        case .platinum: return Color(red: 0.90, green: 0.89, blue: 0.89)     // #E5E4E2
        case .titanium: return Color(red: 0.53, green: 0.53, blue: 0.53)     // #878787
        case .iron:     return Color(red: 0.29, green: 0.29, blue: 0.29)     // #4A4A4A
        case .lead:     return Color(red: 0.44, green: 0.44, blue: 0.43)     // #71706E
        }
    }

    public var dark: Color {
        switch self {
        case .gold:     return Color(red: 0.72, green: 0.53, blue: 0.04)     // #B8860B
        case .silver:   return Color(red: 0.66, green: 0.66, blue: 0.66)     // #A8A8A8
        case .copper:   return Color(red: 0.55, green: 0.27, blue: 0.07)     // #8B4513
        case .bronze:   return Color(red: 0.40, green: 0.26, blue: 0.13)     // #654321
        case .platinum: return Color(red: 0.83, green: 0.83, blue: 0.83)     // #D3D3D3
        case .titanium: return Color(red: 0.36, green: 0.36, blue: 0.36)     // #5C5C5C
        case .iron:     return Color(red: 0.18, green: 0.18, blue: 0.18)     // #2F2F2F
        case .lead:     return Color(red: 0.34, green: 0.34, blue: 0.33)     // #565654
        }
    }
}

// MARK: - Semantic Colors

/// Semantic color definitions that map to spectrum/metal colors
public struct SemanticColors {
    private let season: Season
    private let location: GeographicContext
    private let timeOfDay: TimeOfDay

    public init(
        season: Season = .summer,
        location: GeographicContext = .coastal,
        timeOfDay: TimeOfDay = .morning
    ) {
        self.season = season
        self.location = location
        self.timeOfDay = timeOfDay
    }

    // MARK: - Backgrounds

    /// Primary background - cream/parchment for light, dark navy for dark
    public var backgroundPrimary: Color {
        timeOfDay.prefersDarkMode
            ? Color(red: 0.07, green: 0.07, blue: 0.09)  // #121217
            : Color(red: 0.97, green: 0.95, blue: 0.91)  // #F8F3E8 (cream)
    }

    /// Secondary background - slightly darker/lighter than primary
    public var backgroundSecondary: Color {
        timeOfDay.prefersDarkMode
            ? Color(red: 0.11, green: 0.11, blue: 0.12)  // #1C1C1E
            : Color(red: 0.94, green: 0.91, blue: 0.85)  // #F0E7D9
    }

    /// Tertiary background for cards and containers
    public var backgroundTertiary: Color {
        timeOfDay.prefersDarkMode
            ? Color(red: 0.17, green: 0.17, blue: 0.18)  // #2C2C2E
            : Color.white
    }

    // MARK: - Text Colors

    /// Primary text color
    public var textPrimary: Color {
        timeOfDay.prefersDarkMode
            ? Color(red: 0.95, green: 0.95, blue: 0.97)  // #F2F2F7
            : Color(red: 0.10, green: 0.10, blue: 0.10)  // #1A1A1A
    }

    /// Secondary text color
    public var textSecondary: Color {
        timeOfDay.prefersDarkMode
            ? Color(red: 0.70, green: 0.70, blue: 0.73)  // #B3B3BA
            : Color(red: 0.40, green: 0.40, blue: 0.40)  // #666666
    }

    /// Tertiary text color (labels, captions)
    public var textTertiary: Color {
        timeOfDay.prefersDarkMode
            ? Color(red: 0.55, green: 0.55, blue: 0.58)  // #8C8C94
            : Color(red: 0.55, green: 0.55, blue: 0.55)  // #8C8C8C
    }

    // MARK: - Accent Colors (Seasonally Modulated)

    /// Primary accent - gold-based, seasonally adjusted
    public var accentPrimary: Color {
        let baseColor = SpectrumColor.gold
        return modulateColor(baseColor.base)
    }

    /// Secondary accent - varies by season
    public var accentSecondary: Color {
        let baseColor: SpectrumColor = {
            switch season {
            case .spring: return .green
            case .summer: return .gold
            case .autumn: return .orange
            case .winter: return .azure
            }
        }()
        return modulateColor(baseColor.base)
    }

    /// Success color
    public var success: Color {
        modulateColor(SpectrumColor.green.base)
    }

    /// Warning color
    public var warning: Color {
        modulateColor(SpectrumColor.orange.base)
    }

    /// Error color
    public var error: Color {
        modulateColor(SpectrumColor.red.dark)
    }

    // MARK: - Private Helpers

    private func modulateColor(_ color: Color) -> Color {
        // Apply seasonal saturation
        // Apply geographic temperature
        // Apply time-of-day brightness
        // This is a simplified version - full implementation would use HSB manipulation
        return color.opacity(Double(timeOfDay.brightnessMultiplier))
    }
}

// MARK: - Color Extension

public extension Color {
    /// Access spectrum colors easily
    static func spectrum(_ color: SpectrumColor, level: Int = 6) -> Color {
        color.variant(level)
    }

    /// Access metal colors easily
    static func metal(_ metal: MetalColor) -> Color {
        metal.base
    }

    /// Parchment/cream background
    static var parchment: Color {
        Color(red: 0.97, green: 0.95, blue: 0.91)
    }

    /// Dark background
    static var goldenDark: Color {
        Color(red: 0.07, green: 0.07, blue: 0.09)
    }
}

// MARK: - Gradients

public struct GoldenGradients {
    /// Golden hour gradient (gold to bronze)
    public static var goldenHour: LinearGradient {
        LinearGradient(
            colors: [MetalColor.gold.light, MetalColor.bronze.dark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Rainbow spectrum gradient
    public static var spectrum: LinearGradient {
        LinearGradient(
            colors: SpectrumColor.allCases.map { $0.base },
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Subtle parchment gradient
    public static var parchment: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.96, blue: 0.93),
                Color(red: 0.94, green: 0.91, blue: 0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Seasonal gradient based on current season
    public static func seasonal(_ season: Season) -> LinearGradient {
        let colors: [Color] = {
            switch season {
            case .spring:
                return [SpectrumColor.green.light, SpectrumColor.yellow.light]
            case .summer:
                return [SpectrumColor.gold.light, SpectrumColor.orange.light]
            case .autumn:
                return [SpectrumColor.orange.base, SpectrumColor.red.dark]
            case .winter:
                return [SpectrumColor.azure.light, MetalColor.silver.light]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
