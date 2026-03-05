// ThemeConfiguration.swift
// Golden Enterprises Theme System
// Complete theme configuration combining colors, typography, and geometry

import SwiftUI

/// Complete theme configuration for an application
public struct ThemeConfiguration: Equatable {
    public let name: String
    public let colors: SemanticColors
    public let isDarkMode: Bool

    // MARK: - Computed Colors

    public var background: Color { colors.backgroundPrimary }
    public var backgroundSecondary: Color { colors.backgroundSecondary }
    public var backgroundTertiary: Color { colors.backgroundTertiary }

    public var text: Color { colors.textPrimary }
    public var textSecondary: Color { colors.textSecondary }
    public var textTertiary: Color { colors.textTertiary }

    public var accent: Color { colors.accentPrimary }
    public var accentSecondary: Color { colors.accentSecondary }

    // MARK: - Initialization

    public init(
        name: String,
        season: Season = .summer,
        location: GeographicContext = .coastal,
        timeOfDay: TimeOfDay = .morning
    ) {
        self.name = name
        self.colors = SemanticColors(season: season, location: location, timeOfDay: timeOfDay)
        self.isDarkMode = timeOfDay.prefersDarkMode
    }

    // MARK: - Preset Themes

    /// Light parchment theme (default daytime)
    public static var parchment: ThemeConfiguration {
        ThemeConfiguration(name: "Parchment", season: .summer, timeOfDay: .morning)
    }

    /// Dark navy theme (default nighttime)
    public static var navyNight: ThemeConfiguration {
        ThemeConfiguration(name: "Navy Night", season: .winter, timeOfDay: .night)
    }

    /// Spring morning theme
    public static var springMorning: ThemeConfiguration {
        ThemeConfiguration(name: "Spring Morning", season: .spring, timeOfDay: .morning)
    }

    /// Summer noon theme
    public static var summerNoon: ThemeConfiguration {
        ThemeConfiguration(name: "Summer Noon", season: .summer, timeOfDay: .noon)
    }

    /// Autumn dusk theme
    public static var autumnDusk: ThemeConfiguration {
        ThemeConfiguration(name: "Autumn Dusk", season: .autumn, timeOfDay: .dusk)
    }

    /// Winter evening theme
    public static var winterEvening: ThemeConfiguration {
        ThemeConfiguration(name: "Winter Evening", season: .winter, timeOfDay: .evening)
    }

    // MARK: - Equatable

    public static func == (lhs: ThemeConfiguration, rhs: ThemeConfiguration) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Theme Manager

/// Manages the current theme state and updates
@MainActor
@Observable
public class ThemeManager {
    public static let shared = ThemeManager()

    public var season: Season = .summer
    public var location: GeographicContext = .coastal
    public var timeOfDay: TimeOfDay = .morning

    public private(set) var currentTheme: ThemeConfiguration

    private init() {
        self.currentTheme = ThemeConfiguration(
            name: "Default",
            season: .summer,
            location: .coastal,
            timeOfDay: .morning
        )
    }

    /// Update theme based on current context
    public func updateTheme() {
        currentTheme = ThemeConfiguration(
            name: generateThemeName(),
            season: season,
            location: location,
            timeOfDay: timeOfDay
        )
    }

    /// Auto-detect time of day from system
    public func syncWithSystemTime() {
        let hour = Calendar.current.component(.hour, from: Date())

        timeOfDay = switch hour {
        case 5..<7: .dawn
        case 7..<12: .morning
        case 12..<14: .noon
        case 14..<17: .afternoon
        case 17..<19: .dusk
        case 19..<22: .evening
        default: .night
        }

        updateTheme()
    }

    /// Auto-detect season from system date
    public func syncWithSystemSeason() {
        let month = Calendar.current.component(.month, from: Date())

        season = switch month {
        case 3...5: .spring
        case 6...8: .summer
        case 9...11: .autumn
        default: .winter
        }

        updateTheme()
    }

    private func generateThemeName() -> String {
        "\(season.rawValue.capitalized) \(timeOfDay.rawValue.capitalized)"
    }
}

// MARK: - Environment Key

private struct ThemeEnvironmentKey: EnvironmentKey {
    @MainActor static var defaultValue: ThemeConfiguration {
        ThemeManager.shared.currentTheme
    }
}

public extension EnvironmentValues {
    var goldenTheme: ThemeConfiguration {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Inject the golden theme into the environment
    @MainActor
    func withGoldenTheme(_ theme: ThemeConfiguration? = nil) -> some View {
        self.environment(\.goldenTheme, theme ?? ThemeManager.shared.currentTheme)
    }
}
