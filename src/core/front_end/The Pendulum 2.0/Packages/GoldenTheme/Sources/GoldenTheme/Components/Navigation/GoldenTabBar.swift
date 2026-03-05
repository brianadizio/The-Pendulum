// GoldenTabBar.swift
// Golden Enterprises Theme System
// 5-tab navigation with topological knot icons

import SwiftUI

// MARK: - Tab Definition

/// Standard 5-tab navigation structure for all Solutions
public enum GoldenTab: Int, CaseIterable, Identifiable {
    case playUse = 0      // Torus (single loop) - Play/Use main interaction
    case modes = 1        // Hopf link (two linked loops) - Modes/algorithms
    case dashboard = 2    // Trefoil knot - View/Dashboard analytics
    case integration = 3  // Figure-8 knot - Integration with other Solutions
    case settings = 4     // Solomon's knot (complex) - Settings

    public var id: Int { rawValue }

    /// Default label for the tab
    public var defaultLabel: String {
        switch self {
        case .playUse: return "Play/Use"
        case .modes: return "Modes"
        case .dashboard: return "Dashboard"
        case .integration: return "Integration"
        case .settings: return "Settings"
        }
    }

    /// SF Symbol fallback (when custom images aren't available)
    public var sfSymbol: String {
        switch self {
        case .playUse: return "play.circle"
        case .modes: return "slider.horizontal.3"
        case .dashboard: return "chart.bar"
        case .integration: return "link"
        case .settings: return "gearshape"
        }
    }

    /// Accessibility label
    public var accessibilityLabel: String {
        switch self {
        case .playUse: return "Play or use the main feature"
        case .modes: return "Select modes and algorithms"
        case .dashboard: return "View analytics dashboard"
        case .integration: return "Connect with other solutions"
        case .settings: return "App settings"
        }
    }
}

// MARK: - Custom Tab Configuration

/// Configuration for a single tab
public struct TabConfiguration {
    public let tab: GoldenTab
    public let customLabel: String?
    public let customImage: Image?

    public init(
        _ tab: GoldenTab,
        label: String? = nil,
        image: Image? = nil
    ) {
        self.tab = tab
        self.customLabel = label
        self.customImage = image
    }

    public var label: String {
        customLabel ?? tab.defaultLabel
    }

    public var image: Image {
        customImage ?? Image(systemName: tab.sfSymbol)
    }
}

// MARK: - Tab Bar View

/// Golden themed tab bar with topological icons
public struct GoldenTabBar: View {
    @Binding var selectedTab: GoldenTab
    let tabs: [TabConfiguration]

    @Environment(\.goldenTheme) var theme

    public init(selectedTab: Binding<GoldenTab>, tabs: [TabConfiguration]? = nil) {
        self._selectedTab = selectedTab
        self.tabs = tabs ?? GoldenTab.allCases.map { TabConfiguration($0) }
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tab.id) { config in
                tabButton(for: config)
            }
        }
        .padding(.top, GoldenTheme.spacing.small)
        .padding(.bottom, GoldenTheme.spacing.small)
        .background(
            Rectangle()
                .fill(theme.backgroundSecondary)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
        )
    }

    @ViewBuilder
    private func tabButton(for config: TabConfiguration) -> some View {
        let isSelected = selectedTab == config.tab
        let hasCustomImage = config.customImage != nil

        Button(action: {
            withAnimation(.goldenSpringQuick) {
                selectedTab = config.tab
            }
            HapticManager.shared.play(.selection)
        }) {
            VStack(spacing: 4) {
                if hasCustomImage {
                    // Custom image - show original texture, adjust opacity for selection
                    config.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: GoldenGeometry.tabBarIcon, height: GoldenGeometry.tabBarIcon)
                        .opacity(isSelected ? 1.0 : 0.5)
                } else {
                    // SF Symbol - use template mode with accent color
                    config.image
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? theme.accent : theme.textTertiary)
                        .frame(width: GoldenGeometry.tabBarIcon, height: GoldenGeometry.tabBarIcon)
                }

                Text(config.label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? theme.accent : theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(config.label)
        .accessibilityHint(config.tab.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Tab View Container

/// Container that manages tab view content
public struct GoldenTabView<Content: View>: View {
    @Binding var selectedTab: GoldenTab
    let tabs: [TabConfiguration]
    let content: (GoldenTab) -> Content

    @Environment(\.goldenTheme) var theme

    public init(
        selectedTab: Binding<GoldenTab>,
        tabs: [TabConfiguration]? = nil,
        @ViewBuilder content: @escaping (GoldenTab) -> Content
    ) {
        self._selectedTab = selectedTab
        self.tabs = tabs ?? GoldenTab.allCases.map { TabConfiguration($0) }
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            content(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            GoldenTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
        .background(theme.background)
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Navigation Header

/// Standard navigation header with logo and title
public struct GoldenNavigationHeader: View {
    let title: String
    let logoImage: Image?
    let showBackButton: Bool
    let backAction: (() -> Void)?

    @Environment(\.goldenTheme) var theme

    public init(
        _ title: String,
        logo: Image? = nil,
        showBackButton: Bool = false,
        backAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.logoImage = logo
        self.showBackButton = showBackButton
        self.backAction = backAction
    }

    public var body: some View {
        HStack(spacing: GoldenTheme.spacing.medium) {
            if showBackButton {
                Button(action: {
                    HapticManager.shared.play(.light)
                    backAction?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.text)
                }
            }

            if let logo = logoImage {
                logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }

            Text(title)
                .font(.golden(.title))
                .foregroundStyle(theme.text)

            Spacer()
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.medium)
        .background(theme.background)
    }
}

// MARK: - Sub-page Navigation

/// Navigation for sub-pages within tabs (like settings sub-views)
public struct GoldenSubPageView<Content: View>: View {
    let title: String
    let onBack: () -> Void
    let content: () -> Content

    @Environment(\.goldenTheme) var theme

    public init(
        _ title: String,
        onBack: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.onBack = onBack
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack(spacing: GoldenTheme.spacing.medium) {
                Button(action: {
                    HapticManager.shared.play(.light)
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.text)
                        .frame(width: 44, height: 44)
                }

                Text(title)
                    .font(.golden(.headline))
                    .foregroundStyle(theme.text)

                Spacer()
            }
            .padding(.horizontal, GoldenTheme.spacing.small)
            .background(theme.background)

            Divider()

            // Content
            ScrollView {
                content()
            }
        }
        .background(theme.background)
    }
}
