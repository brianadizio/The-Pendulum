// GoldenTypography.swift
// Golden Enterprises Theme System
// Phi-scaled typography system with Times New Roman for academic feel

import SwiftUI

// MARK: - Typography Scale

/// Typography system based on golden ratio scaling
/// Base size: 17pt, scaled by powers of phi
public struct GoldenTypography {
    private static let phi: CGFloat = GoldenTheme.phi
    private static let baseSize: CGFloat = 17

    // MARK: - Font Sizes (Phi-Scaled)

    /// Display size: base × φ³ ≈ 72pt - Hero headlines, splash screens
    public static let displaySize: CGFloat = baseSize * pow(phi, 3)  // ~72pt

    /// Title size: base × φ² ≈ 44pt - Page titles, major sections
    public static let titleSize: CGFloat = baseSize * pow(phi, 2)    // ~44pt

    /// Headline size: base × φ ≈ 27pt - Section headers, card titles
    public static let headlineSize: CGFloat = baseSize * phi         // ~27pt

    /// Body size: base = 17pt - Body text, primary content
    public static let bodySize: CGFloat = baseSize                   // 17pt

    /// Caption size: base ÷ φ ≈ 10.5pt - Captions, helper text
    public static let captionSize: CGFloat = baseSize / phi          // ~10.5pt

    /// Micro size: base ÷ φ² ≈ 6.5pt - Fine print, legal text
    public static let microSize: CGFloat = baseSize / pow(phi, 2)    // ~6.5pt

    // MARK: - Font Family

    /// Primary font family - Times New Roman for academic feel
    public static let primaryFamily = "Times New Roman"

    /// Monospace font for code/data - SF Mono
    public static let monoFamily = "SF Mono"

    /// System font fallback
    public static let systemFamily = ".SF Pro"
}

// MARK: - Text Styles

/// Predefined text styles using Times New Roman with phi scaling
public enum GoldenTextStyle {
    case display
    case title
    case headline
    case body
    case caption
    case micro
    case monospace

    public var font: Font {
        switch self {
        case .display:
            return .custom(GoldenTypography.primaryFamily, size: GoldenTypography.displaySize)
                .weight(.bold)
        case .title:
            return .custom(GoldenTypography.primaryFamily, size: GoldenTypography.titleSize)
                .weight(.semibold)
        case .headline:
            return .custom(GoldenTypography.primaryFamily, size: GoldenTypography.headlineSize)
                .weight(.semibold)
        case .body:
            return .custom(GoldenTypography.primaryFamily, size: GoldenTypography.bodySize)
                .weight(.regular)
        case .caption:
            return .custom(GoldenTypography.primaryFamily, size: GoldenTypography.captionSize)
                .weight(.regular)
        case .micro:
            return .custom(GoldenTypography.primaryFamily, size: GoldenTypography.microSize)
                .weight(.regular)
        case .monospace:
            return .custom(GoldenTypography.monoFamily, size: GoldenTypography.bodySize)
                .weight(.regular)
        }
    }

    /// Line height multiplier
    public var lineHeight: CGFloat {
        switch self {
        case .display: return 1.1
        case .title: return 1.15
        case .headline: return 1.2
        case .body: return 1.5  // Academic readability
        case .caption: return 1.3
        case .micro: return 1.2
        case .monospace: return 1.4
        }
    }

    /// Letter spacing
    public var letterSpacing: CGFloat {
        switch self {
        case .display: return -0.5
        case .title: return -0.3
        case .headline: return 0
        case .body: return 0.3  // Slight tracking for readability
        case .caption: return 0.2
        case .micro: return 0.3
        case .monospace: return 0
        }
    }
}

// MARK: - Font Extension

public extension Font {
    /// Golden theme text styles
    static func golden(_ style: GoldenTextStyle) -> Font {
        style.font
    }

    /// Custom Times New Roman at specific size
    static func timesNewRoman(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(GoldenTypography.primaryFamily, size: size).weight(weight)
    }

    /// Monospace font for data/code display
    static func goldenMono(size: CGFloat = GoldenTypography.bodySize) -> Font {
        .custom(GoldenTypography.monoFamily, size: size)
    }
}

// MARK: - Text View Modifier

/// Apply golden typography styling to text
public struct GoldenTextModifier: ViewModifier {
    let style: GoldenTextStyle
    @Environment(\.goldenTheme) var theme

    public func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.letterSpacing)
            .lineSpacing((style.lineHeight - 1) * fontSize(for: style))
    }

    private func fontSize(for style: GoldenTextStyle) -> CGFloat {
        switch style {
        case .display: return GoldenTypography.displaySize
        case .title: return GoldenTypography.titleSize
        case .headline: return GoldenTypography.headlineSize
        case .body: return GoldenTypography.bodySize
        case .caption: return GoldenTypography.captionSize
        case .micro: return GoldenTypography.microSize
        case .monospace: return GoldenTypography.bodySize
        }
    }
}

public extension View {
    /// Apply golden typography style
    func goldenText(_ style: GoldenTextStyle) -> some View {
        self.modifier(GoldenTextModifier(style: style))
    }
}

// MARK: - Styled Text Views

/// Pre-styled text components for common use cases
public struct GoldenText: View {
    let content: String
    let style: GoldenTextStyle
    let color: Color?

    public init(_ content: String, style: GoldenTextStyle = .body, color: Color? = nil) {
        self.content = content
        self.style = style
        self.color = color
    }

    @Environment(\.goldenTheme) var theme

    public var body: some View {
        Text(content)
            .goldenText(style)
            .foregroundStyle(color ?? theme.text)
    }
}

/// Display text for hero sections
public struct DisplayText: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        GoldenText(content, style: .display)
    }
}

/// Title text for page headers
public struct TitleText: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        GoldenText(content, style: .title)
    }
}

/// Headline text for sections
public struct HeadlineText: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        GoldenText(content, style: .headline)
    }
}

/// Body text for main content
public struct BodyText: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        GoldenText(content, style: .body)
    }
}

/// Caption text for labels and helper text
public struct CaptionText: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    @Environment(\.goldenTheme) var theme

    public var body: some View {
        GoldenText(content, style: .caption, color: theme.textSecondary)
    }
}
