// GoldenGeometry.swift
// Golden Enterprises Theme System
// Phi-based spacing, sizing, and proportion rules

import SwiftUI

// MARK: - Geometry Constants

public struct GoldenGeometry {
    private static let phi = GoldenTheme.phi
    private static let base = GoldenTheme.baseUnit

    // MARK: - Corner Radii

    /// Small corner radius - 8pt
    public static let cornerSmall: CGFloat = 8

    /// Medium corner radius - 12pt
    public static let cornerMedium: CGFloat = 12

    /// Large corner radius - 16pt
    public static let cornerLarge: CGFloat = 16

    /// Extra large corner radius - 24pt
    public static let cornerXLarge: CGFloat = 24

    // MARK: - Component Sizes

    /// Standard button height - 44pt (Apple HIG minimum)
    public static let buttonHeight: CGFloat = 44

    /// Large button height - 44 × φ ≈ 71pt
    public static let buttonHeightLarge: CGFloat = 44 * phi

    /// Icon size small - 20pt
    public static let iconSmall: CGFloat = 20

    /// Icon size medium - 24pt
    public static let iconMedium: CGFloat = 24

    /// Icon size large - 32pt
    public static let iconLarge: CGFloat = 32

    /// Tab bar icon size - 30pt
    public static let tabBarIcon: CGFloat = 30

    // MARK: - Proportions

    /// Golden rectangle ratio (width:height)
    public static let goldenRectangle: CGFloat = phi  // 1.618:1

    /// Square ratio
    public static let square: CGFloat = 1.0

    /// Double square ratio
    public static let doubleSquare: CGFloat = 2.0

    // MARK: - Safe Areas (approximate, use GeometryReader for actual)

    public struct SafeArea {
        public static let topIPhone: CGFloat = 47
        public static let bottomIPhone: CGFloat = 34
        public static let topIPad: CGFloat = 20
        public static let bottomIPad: CGFloat = 20
    }

    // MARK: - Grid

    /// Calculate grid column width for N columns with spacing
    public static func columnWidth(
        totalWidth: CGFloat,
        columns: Int,
        spacing: CGFloat = GoldenTheme.spacing.medium
    ) -> CGFloat {
        let totalSpacing = spacing * CGFloat(columns - 1)
        return (totalWidth - totalSpacing) / CGFloat(columns)
    }
}

// MARK: - Frame Modifiers

public extension View {
    /// Apply golden rectangle proportions
    func goldenRectangle(width: CGFloat) -> some View {
        self.frame(width: width, height: width / GoldenGeometry.goldenRectangle)
    }

    /// Apply golden rectangle proportions (height-based)
    func goldenRectangleByHeight(_ height: CGFloat) -> some View {
        self.frame(width: height * GoldenGeometry.goldenRectangle, height: height)
    }

    /// Apply standard button sizing
    func goldenButtonSize() -> some View {
        self.frame(height: GoldenGeometry.buttonHeight)
    }

    /// Apply phi-based padding
    func goldenPadding(_ edges: Edge.Set = .all, scale: GoldenPaddingScale = .medium) -> some View {
        self.padding(edges, scale.value)
    }
}

/// Padding scale options based on phi
public enum GoldenPaddingScale {
    case micro
    case small
    case medium
    case large
    case xlarge

    var value: CGFloat {
        switch self {
        case .micro: return GoldenTheme.spacing.micro
        case .small: return GoldenTheme.spacing.small
        case .medium: return GoldenTheme.spacing.medium
        case .large: return GoldenTheme.spacing.large
        case .xlarge: return GoldenTheme.spacing.xlarge
        }
    }
}

// MARK: - Layout Components

/// A stack with phi-based spacing
public struct GoldenVStack<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: GoldenPaddingScale = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing.value
        self.content = content
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content()
        }
    }
}

/// A horizontal stack with phi-based spacing
public struct GoldenHStack<Content: View>: View {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    let content: () -> Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: GoldenPaddingScale = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing.value
        self.content = content
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content()
        }
    }
}

/// A lazy vertical grid with golden proportions
public struct GoldenGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let content: () -> Content

    public init(
        columns: Int = 2,
        spacing: GoldenPaddingScale = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing.value
        self.content = content
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: spacing),
                count: columns
            ),
            spacing: spacing
        ) {
            content()
        }
    }
}

// MARK: - Animation Curves

public extension Animation {
    /// Golden spring animation (response based on phi)
    static var goldenSpring: Animation {
        .spring(response: 0.5, dampingFraction: 1.0 / GoldenTheme.phi)
    }

    /// Quick golden spring
    static var goldenSpringQuick: Animation {
        .spring(response: 0.3, dampingFraction: 1.0 / GoldenTheme.phi)
    }

    /// Slow golden spring for emphasis
    static var goldenSpringSlow: Animation {
        .spring(response: 0.8, dampingFraction: 1.0 / GoldenTheme.phi)
    }
}
