// SettingsTemplate.swift
// Golden Enterprises Theme System
// Complete settings view template for Solutions

import SwiftUI

// MARK: - Settings Section

/// A section in the settings view
public struct SettingsSection {
    public let title: String
    public let items: [SettingsItem]

    public init(title: String, items: [SettingsItem]) {
        self.title = title
        self.items = items
    }
}

/// A single item in a settings section
public enum SettingsItem {
    case navigation(title: String, subtitle: String?, action: () -> Void)
    case toggle(title: String, subtitle: String?, binding: Binding<Bool>)
    case value(title: String, value: String, action: (() -> Void)?)
    case destructive(title: String, action: () -> Void)

    public var title: String {
        switch self {
        case .navigation(let title, _, _): return title
        case .toggle(let title, _, _): return title
        case .value(let title, _, _): return title
        case .destructive(let title, _): return title
        }
    }
}

// MARK: - Settings Item Row

struct SettingsItemRow: View {
    let item: SettingsItem

    @Environment(\.goldenTheme) var theme

    var body: some View {
        switch item {
        case .navigation(let title, let subtitle, let action):
            GoldenSettingsButton(title, subtitle: subtitle, showDisclosure: true, action: action)

        case .toggle(let title, let subtitle, let binding):
            GoldenToggleRow(title, subtitle: subtitle, isOn: binding)

        case .value(let title, let value, let action):
            Button(action: { action?() }) {
                HStack {
                    Text(title)
                        .font(.golden(.body))
                        .foregroundStyle(theme.text)

                    Spacer()

                    Text(value)
                        .font(.golden(.body))
                        .foregroundStyle(theme.textSecondary)

                    if action != nil {
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
            .disabled(action == nil)

        case .destructive(let title, let action):
            Button(action: {
                HapticManager.shared.play(.heavy)
                action()
            }) {
                Text(title)
                    .font(.golden(.body))
                    .foregroundStyle(SpectrumColor.red.dark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, GoldenTheme.spacing.medium)
                    .background(theme.backgroundTertiary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Settings Section View

struct SettingsSectionView: View {
    let section: SettingsSection

    var body: some View {
        VStack(spacing: 0) {
            GoldenSectionHeader(section.title)

            GoldenButtonGroup {
                ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                    SettingsItemRow(item: item)

                    if item.title != section.items.last?.title {
                        Divider()
                            .padding(.leading, GoldenTheme.spacing.medium)
                    }
                }
            }
            .padding(.horizontal, GoldenTheme.spacing.medium)
        }
    }
}

// MARK: - Complete Settings View Template

/// Template for creating settings views
public struct GoldenSettingsView: View {
    let title: String
    let logoImage: Image?
    let sections: [SettingsSection]
    let footerText: String?

    @Environment(\.goldenTheme) var theme

    public init(
        title: String = "Settings",
        logo: Image? = nil,
        sections: [SettingsSection],
        footer: String? = nil
    ) {
        self.title = title
        self.logoImage = logo
        self.sections = sections
        self.footerText = footer
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            GoldenNavigationHeader(title, logo: logoImage)

            // Content
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        SettingsSectionView(section: section)
                    }

                    // Footer
                    if let footer = footerText {
                        Text(footer)
                            .font(.golden(.caption))
                            .foregroundStyle(theme.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, GoldenTheme.spacing.large)
                            .padding(.vertical, GoldenTheme.spacing.xlarge)
                    }
                }
            }
        }
        .background(theme.background)
    }
}

// MARK: - Standard Settings Sections

/// Pre-built standard settings sections that most apps will use
public struct StandardSettingsSections {

    /// Experience section (backgrounds, sounds, haptics)
    public static func experience(
        backgroundsAction: @escaping () -> Void,
        soundsEnabled: Binding<Bool>,
        hapticsEnabled: Binding<Bool>
    ) -> SettingsSection {
        SettingsSection(title: "Experience", items: [
            .navigation(title: "Backgrounds", subtitle: "Customize appearance", action: backgroundsAction),
            .toggle(title: "Sounds", subtitle: "Enable sound effects", binding: soundsEnabled),
            .toggle(title: "Haptics", subtitle: "Enable haptic feedback", binding: hapticsEnabled)
        ])
    }

    /// Data section (export, import, reset)
    public static func data(
        exportAction: @escaping () -> Void,
        importAction: @escaping () -> Void,
        resetAction: @escaping () -> Void
    ) -> SettingsSection {
        SettingsSection(title: "Data", items: [
            .navigation(title: "Export Data", subtitle: nil, action: exportAction),
            .navigation(title: "Import Data", subtitle: nil, action: importAction),
            .destructive(title: "Reset All Data", action: resetAction)
        ])
    }

    /// Account section
    public static func account(
        signedIn: Bool,
        userName: String?,
        signInAction: @escaping () -> Void,
        signOutAction: @escaping () -> Void
    ) -> SettingsSection {
        if signedIn {
            return SettingsSection(title: "Account", items: [
                .value(title: "Signed in as", value: userName ?? "User", action: nil),
                .destructive(title: "Sign Out", action: signOutAction)
            ])
        } else {
            return SettingsSection(title: "Account", items: [
                .navigation(title: "Sign In", subtitle: "Sync your data", action: signInAction)
            ])
        }
    }

    /// About section
    public static func about(
        version: String,
        privacyAction: @escaping () -> Void,
        supportAction: @escaping () -> Void
    ) -> SettingsSection {
        SettingsSection(title: "About", items: [
            .value(title: "Version", value: version, action: nil),
            .navigation(title: "Privacy Policy", subtitle: nil, action: privacyAction),
            .navigation(title: "Support", subtitle: nil, action: supportAction)
        ])
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct SettingsTemplate_Previews: PreviewProvider {
    static var previews: some View {
        GoldenSettingsView(
            title: "Settings",
            sections: [
                StandardSettingsSections.experience(
                    backgroundsAction: {},
                    soundsEnabled: .constant(true),
                    hapticsEnabled: .constant(true)
                ),
                StandardSettingsSections.data(
                    exportAction: {},
                    importAction: {},
                    resetAction: {}
                ),
                StandardSettingsSections.about(
                    version: "1.0.0",
                    privacyAction: {},
                    supportAction: {}
                )
            ],
            footer: "Made with love by Golden Enterprises"
        )
    }
}
#endif
