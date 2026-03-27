// GoldenCards.swift
// Golden Enterprises Theme System
// Card components for dashboard statistics and content display

import SwiftUI

// MARK: - Basic Card

/// Basic card container with golden styling
public struct GoldenCard<Content: View>: View {
    let content: () -> Content

    @Environment(\.goldenTheme) var theme

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .padding(GoldenTheme.spacing.medium)
            .background(theme.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
    }
}

// MARK: - Statistic Card

/// Card for displaying a single statistic (like in Dashboard)
public struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: Image?
    let trend: Trend?

    @Environment(\.goldenTheme) var theme

    public enum Trend {
        case up(String)
        case down(String)
        case neutral(String)

        var color: Color {
            switch self {
            case .up: return SpectrumColor.green.base
            case .down: return SpectrumColor.red.base
            case .neutral: return Color.gray
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "arrow.right"
            }
        }

        var text: String {
            switch self {
            case .up(let text), .down(let text), .neutral(let text):
                return text
            }
        }
    }

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: Image? = nil,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.trend = trend
    }

    public var body: some View {
        GoldenCard {
            VStack(alignment: .leading, spacing: GoldenTheme.spacing.small) {
                // Header with icon
                HStack {
                    if let icon = icon {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(theme.accent)
                    }

                    Text(title)
                        .font(.golden(.body))
                        .foregroundStyle(theme.text)

                    Spacer()
                }

                // Value
                Text(value)
                    .font(.golden(.headline))
                    .foregroundStyle(theme.accent)

                // Subtitle and trend
                HStack {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.golden(.caption))
                            .foregroundStyle(theme.textSecondary)
                    }

                    Spacer()

                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.system(size: 12, weight: .medium))
                            Text(trend.text)
                                .font(.golden(.caption))
                        }
                        .foregroundStyle(trend.color)
                    }
                }
            }
        }
    }
}

// MARK: - Metric Row Card

/// Row-style metric display (like Analytics Dashboard items)
public struct MetricRowCard: View {
    let title: String
    let description: String?
    let value: String
    let icon: Image?

    @Environment(\.goldenTheme) var theme

    public init(
        title: String,
        description: String? = nil,
        value: String,
        icon: Image? = nil
    ) {
        self.title = title
        self.description = description
        self.value = value
        self.icon = icon
    }

    public var body: some View {
        GoldenCard {
            HStack(spacing: GoldenTheme.spacing.medium) {
                // Icon
                if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.golden(.body))
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.text)

                    if let description = description {
                        Text(description)
                            .font(.golden(.caption))
                            .foregroundStyle(theme.textSecondary)
                            .lineLimit(2)
                    }

                    Text(value)
                        .font(.golden(.headline))
                        .foregroundStyle(theme.accent)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Info Card

/// Informational card with optional expand/collapse
public struct InfoCard: View {
    let title: String
    let content: String
    let isExpandable: Bool

    @State private var isExpanded = false
    @Environment(\.goldenTheme) var theme

    public init(title: String, content: String, isExpandable: Bool = false) {
        self.title = title
        self.content = content
        self.isExpandable = isExpandable
    }

    public var body: some View {
        GoldenCard {
            VStack(alignment: .leading, spacing: GoldenTheme.spacing.small) {
                // Header
                HStack {
                    Text(title)
                        .font(.golden(.body))
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.text)

                    Spacer()

                    if isExpandable {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textTertiary)
                    }
                }

                // Content
                if !isExpandable || isExpanded {
                    Text(content)
                        .font(.golden(.body))
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(isExpandable ? nil : 3)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isExpandable {
                withAnimation(.goldenSpringQuick) {
                    isExpanded.toggle()
                }
                HapticManager.shared.play(.selection)
            }
        }
    }
}

// MARK: - Action Card

/// Card with primary action button
public struct ActionCard: View {
    let title: String
    let description: String?
    let buttonTitle: String
    let action: () -> Void

    @Environment(\.goldenTheme) var theme

    public init(
        title: String,
        description: String? = nil,
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action
    }

    public var body: some View {
        GoldenCard {
            VStack(alignment: .leading, spacing: GoldenTheme.spacing.medium) {
                Text(title)
                    .font(.golden(.body))
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.text)

                if let description = description {
                    Text(description)
                        .font(.golden(.caption))
                        .foregroundStyle(theme.textSecondary)
                }

                GoldenPrimaryButton(buttonTitle, action: action)
            }
        }
    }
}

// MARK: - Grid Card

/// Card for grid layouts (like mode selection)
public struct GridCard: View {
    let title: String
    let image: Image?
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.goldenTheme) var theme

    public init(
        title: String,
        image: Image? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.play(.selection)
            action()
        }) {
            VStack(spacing: GoldenTheme.spacing.small) {
                // Image or placeholder
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                } else {
                    RoundedRectangle(cornerRadius: GoldenGeometry.cornerSmall, style: .continuous)
                        .fill(theme.backgroundSecondary)
                        .frame(height: 80)
                }

                Text(title)
                    .font(.golden(.caption))
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
            }
            .padding(GoldenTheme.spacing.small)
            .background(theme.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                    .stroke(isSelected ? theme.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(GoldenButtonStyle())
    }
}
