// GoldenButtons.swift
// Golden Enterprises Theme System
// Text-only buttons with no icons - simple, elegant, grouped

import SwiftUI

// MARK: - Primary Button

/// Primary action button - text only, golden accent
public struct GoldenPrimaryButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.goldenTheme) var theme
    @Environment(\.isEnabled) var isEnabled
    @State private var isPressed = false

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.play(.medium)
            action()
        }) {
            Text(title)
                .font(.golden(.body))
                .fontWeight(.semibold)
                .foregroundStyle(buttonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: GoldenGeometry.buttonHeight)
                .background(buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
        }
        .buttonStyle(GoldenButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }

    private var buttonTextColor: Color {
        isEnabled ? MetalColor.bronze.dark : theme.textTertiary
    }

    private var buttonBackground: some View {
        Group {
            if isEnabled {
                LinearGradient(
                    colors: [MetalColor.gold.light, MetalColor.gold.base],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                Color(MetalColor.lead.light)
            }
        }
    }
}

// MARK: - Secondary Button

/// Secondary action button - outlined, text only
public struct GoldenSecondaryButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.goldenTheme) var theme
    @Environment(\.isEnabled) var isEnabled

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.play(.light)
            action()
        }) {
            Text(title)
                .font(.golden(.body))
                .fontWeight(.medium)
                .foregroundStyle(isEnabled ? theme.accent : theme.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: GoldenGeometry.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                        .stroke(isEnabled ? theme.accent : theme.textTertiary, lineWidth: 1.5)
                )
        }
        .buttonStyle(GoldenButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Text Button

/// Minimal text-only button
public struct GoldenTextButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.goldenTheme) var theme
    @Environment(\.isEnabled) var isEnabled

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.play(.selection)
            action()
        }) {
            Text(title)
                .font(.golden(.body))
                .foregroundStyle(isEnabled ? theme.accent : theme.textTertiary)
                .padding(.horizontal, GoldenTheme.spacing.medium)
                .padding(.vertical, GoldenTheme.spacing.small)
        }
        .buttonStyle(GoldenButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Settings Row Button

/// Button styled for settings lists - text only, disclosure indicator
public struct GoldenSettingsButton: View {
    let title: String
    let subtitle: String?
    let showDisclosure: Bool
    let action: () -> Void

    @Environment(\.goldenTheme) var theme

    public init(
        _ title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showDisclosure = showDisclosure
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.play(.selection)
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.golden(.body))
                        .foregroundStyle(theme.text)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.golden(.caption))
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                Spacer()

                if showDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.textTertiary)
                }
            }
            .padding(.horizontal, GoldenTheme.spacing.medium)
            .padding(.vertical, GoldenTheme.spacing.medium)
            .background(theme.backgroundTertiary)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint(subtitle ?? "")
    }
}

// MARK: - Toggle Settings Row

/// Settings row with toggle - text only
public struct GoldenToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    @Environment(\.goldenTheme) var theme

    public init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.golden(.body))
                    .foregroundStyle(theme.text)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.golden(.caption))
                        .foregroundStyle(theme.textSecondary)
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(theme.accent)
                .labelsHidden()
                .onChange(of: isOn) { _, _ in
                    HapticManager.shared.play(.selection)
                }
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.medium)
        .background(theme.backgroundTertiary)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

// MARK: - Destructive Button

/// Destructive action button - red tint
public struct GoldenDestructiveButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.goldenTheme) var theme

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.play(.heavy)
            action()
        }) {
            Text(title)
                .font(.golden(.body))
                .fontWeight(.medium)
                .foregroundStyle(SpectrumColor.red.dark)
                .frame(maxWidth: .infinity)
                .frame(height: GoldenGeometry.buttonHeight)
        }
        .buttonStyle(GoldenButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Button Style

/// Custom button style with press animation
struct GoldenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.goldenSpringQuick, value: configuration.isPressed)
    }
}

// MARK: - Button Group

/// Group multiple settings buttons together with rounded corners
public struct GoldenButtonGroup<Content: View>: View {
    let content: () -> Content

    @Environment(\.goldenTheme) var theme

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 1) {
            content()
        }
        .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                .stroke(theme.backgroundSecondary, lineWidth: 1)
        )
    }
}

// MARK: - Section Header

/// Settings section header - text only, uppercase
public struct GoldenSectionHeader: View {
    let title: String

    @Environment(\.goldenTheme) var theme

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title.uppercased())
            .font(.golden(.caption))
            .fontWeight(.medium)
            .foregroundStyle(theme.textSecondary)
            .tracking(1.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GoldenTheme.spacing.medium)
            .padding(.top, GoldenTheme.spacing.large)
            .padding(.bottom, GoldenTheme.spacing.small)
    }
}
