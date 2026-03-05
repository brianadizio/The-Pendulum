// AppTemplate.swift
// Golden Enterprises Theme System
// Complete app template for rapid Solution deployment

import SwiftUI

// MARK: - App Configuration

/// Configuration for a Golden Solution app
public struct GoldenAppConfig {
    public let name: String
    public let shortName: String
    public let version: String
    public let logoImage: Image?
    public let loadingVideoName: String?
    public let primaryColor: SpectrumColor

    public init(
        name: String,
        shortName: String? = nil,
        version: String = "1.0.0",
        logo: Image? = nil,
        loadingVideo: String? = nil,
        primaryColor: SpectrumColor = .gold
    ) {
        self.name = name
        self.shortName = shortName ?? name
        self.version = version
        self.logoImage = logo
        self.loadingVideoName = loadingVideo
        self.primaryColor = primaryColor
    }
}

// MARK: - Standard Tab Configurations

/// Customizable tab configurations for the standard 5-tab layout
public struct AppTabConfigs {
    public let playUse: TabConfiguration
    public let modes: TabConfiguration
    public let dashboard: TabConfiguration
    public let integration: TabConfiguration
    public let settings: TabConfiguration

    public init(
        playUseLabel: String = "Play/Use",
        modesLabel: String = "Modes",
        dashboardLabel: String = "Dashboard",
        integrationLabel: String = "Integration",
        settingsLabel: String = "Settings",
        playUseImage: Image? = nil,
        modesImage: Image? = nil,
        dashboardImage: Image? = nil,
        integrationImage: Image? = nil,
        settingsImage: Image? = nil
    ) {
        self.playUse = TabConfiguration(.playUse, label: playUseLabel, image: playUseImage)
        self.modes = TabConfiguration(.modes, label: modesLabel, image: modesImage)
        self.dashboard = TabConfiguration(.dashboard, label: dashboardLabel, image: dashboardImage)
        self.integration = TabConfiguration(.integration, label: integrationLabel, image: integrationImage)
        self.settings = TabConfiguration(.settings, label: settingsLabel, image: settingsImage)
    }

    public var all: [TabConfiguration] {
        [playUse, modes, dashboard, settings, integration]
    }
}

// MARK: - App Root View Template

/// Root view template for a Golden Solution app
public struct GoldenAppRoot<
    PlayUseContent: View,
    ModesContent: View,
    DashboardContent: View,
    IntegrationContent: View,
    SettingsContent: View
>: View {
    let config: GoldenAppConfig
    let tabConfigs: AppTabConfigs
    let chatAction: (() -> Void)?

    @State private var selectedTab: GoldenTab = .playUse
    @State private var isLoading: Bool = true
    @State private var showBuiltInChat: Bool = false

    @ViewBuilder let playUseView: () -> PlayUseContent
    @ViewBuilder let modesView: () -> ModesContent
    @ViewBuilder let dashboardView: () -> DashboardContent
    @ViewBuilder let integrationView: () -> IntegrationContent
    @ViewBuilder let settingsView: () -> SettingsContent

    @StateObject private var chatViewModel = SampleChatViewModel()
    @Environment(\.goldenTheme) var theme

    public init(
        config: GoldenAppConfig,
        tabs: AppTabConfigs = AppTabConfigs(),
        chatAction: (() -> Void)? = nil,
        @ViewBuilder playUse: @escaping () -> PlayUseContent,
        @ViewBuilder modes: @escaping () -> ModesContent,
        @ViewBuilder dashboard: @escaping () -> DashboardContent,
        @ViewBuilder integration: @escaping () -> IntegrationContent,
        @ViewBuilder settings: @escaping () -> SettingsContent
    ) {
        self.config = config
        self.tabConfigs = tabs
        self.chatAction = chatAction
        self.playUseView = playUse
        self.modesView = modes
        self.dashboardView = dashboard
        self.integrationView = integration
        self.settingsView = settings
    }

    public var body: some View {
        ZStack {
            // Main tab view
            GoldenTabView(selectedTab: $selectedTab, tabs: tabConfigs.all) { tab in
                switch tab {
                case .playUse:
                    NavigationStack {
                        playUseView()
                            .toolbar { chatToolbarItem }
                    }
                case .modes:
                    NavigationStack { modesView() }
                case .dashboard:
                    NavigationStack { dashboardView() }
                case .integration:
                    NavigationStack { integrationView() }
                case .settings:
                    NavigationStack { settingsView() }
                }
            }

            // Loading overlay
            GoldenLoadingOverlay(
                isVisible: isLoading,
                message: "Loading \(config.shortName)...",
                videoName: config.loadingVideoName
            )
        }
        .onAppear {
            // Simulate loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isLoading = false
                }
            }
        }
        .goldenChatSheet(
            isPresented: $showBuiltInChat,
            viewModel: chatViewModel,
            title: "\(config.shortName) Assistant",
            welcomeMessage: "How can I help you with \(config.name)?"
        )
    }

    private var chatToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button(action: {
                HapticManager.shared.play(.light)
                if let chatAction {
                    chatAction()
                } else {
                    showBuiltInChat = true
                }
            }) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundStyle(theme.accent)
            }
        }
    }
}

// MARK: - Placeholder Views

/// Placeholder view for tabs that are in development
public struct PlaceholderView: View {
    let title: String
    let message: String

    @Environment(\.goldenTheme) var theme

    public init(title: String, message: String = "Coming soon") {
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: GoldenTheme.spacing.large) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.textTertiary)

            Text(title)
                .font(.golden(.headline))
                .foregroundStyle(theme.text)

            Text(message)
                .font(.golden(.body))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }
}

// MARK: - Play/Use View Template

/// Template for the main Play/Use view
public struct PlayUseViewTemplate<Content: View>: View {
    let appName: String
    let logo: Image?
    let content: () -> Content

    @Environment(\.goldenTheme) var theme

    public init(
        appName: String,
        logo: Image? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.appName = appName
        self.logo = logo
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            GoldenNavigationHeader(appName, logo: logo)
            content()
        }
        .background(theme.background)
    }
}

// MARK: - Modes View Template

/// Template for the Modes selection view
public struct ModesViewTemplate<Content: View>: View {
    let title: String
    let content: () -> Content

    @Environment(\.goldenTheme) var theme

    public init(
        title: String = "Modes",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            GoldenNavigationHeader(title)

            ScrollView {
                content()
                    .padding(GoldenTheme.spacing.medium)
            }
        }
        .background(theme.background)
    }
}

// MARK: - Dashboard View Template

/// Template for the Dashboard/Analytics view
public struct DashboardViewTemplate: View {
    let title: String
    let metrics: [MetricRowCard]
    let timeRangeBinding: Binding<ChartTimeRangeSelector.TimeRange>?

    @Environment(\.goldenTheme) var theme

    public init(
        title: String = "Dashboard",
        metrics: [MetricRowCard],
        timeRange: Binding<ChartTimeRangeSelector.TimeRange>? = nil
    ) {
        self.title = title
        self.metrics = metrics
        self.timeRangeBinding = timeRange
    }

    public var body: some View {
        VStack(spacing: 0) {
            GoldenNavigationHeader(title)

            ScrollView {
                VStack(spacing: GoldenTheme.spacing.medium) {
                    // Time range selector
                    if let binding = timeRangeBinding {
                        ChartTimeRangeSelector(selected: binding)
                            .padding(.horizontal, GoldenTheme.spacing.medium)
                    }

                    // Metrics
                    ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                        metric
                            .padding(.horizontal, GoldenTheme.spacing.medium)
                    }
                }
                .padding(.vertical, GoldenTheme.spacing.medium)
            }
        }
        .background(theme.background)
    }
}

// MARK: - Integration View Template

/// Template for the Integration view
public struct IntegrationViewTemplate: View {
    let title: String
    let solutions: [(name: String, icon: Image?, isConnected: Bool, action: () -> Void)]
    let externalIntegrations: [(name: String, icon: Image?, action: () -> Void)]

    @Environment(\.goldenTheme) var theme

    public init(
        title: String = "Integration",
        solutions: [(name: String, icon: Image?, isConnected: Bool, action: () -> Void)] = [],
        external: [(name: String, icon: Image?, action: () -> Void)] = []
    ) {
        self.title = title
        self.solutions = solutions
        self.externalIntegrations = external
    }

    public var body: some View {
        VStack(spacing: 0) {
            GoldenNavigationHeader(title)

            ScrollView {
                VStack(spacing: 0) {
                    // Golden Solutions
                    if !solutions.isEmpty {
                        GoldenSectionHeader("Golden Solutions")

                        GoldenButtonGroup {
                            ForEach(Array(solutions.enumerated()), id: \.offset) { index, solution in
                                Button(action: solution.action) {
                                    HStack {
                                        if let icon = solution.icon {
                                            icon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 32, height: 32)
                                        }

                                        Text(solution.name)
                                            .font(.golden(.body))
                                            .foregroundStyle(theme.text)

                                        Spacer()

                                        if solution.isConnected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(SpectrumColor.green.base)
                                        }

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(theme.textTertiary)
                                    }
                                    .padding(GoldenTheme.spacing.medium)
                                    .background(theme.backgroundTertiary)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if index < solutions.count - 1 {
                                    Divider().padding(.leading, GoldenTheme.spacing.medium)
                                }
                            }
                        }
                        .padding(.horizontal, GoldenTheme.spacing.medium)
                    }

                    // External integrations
                    if !externalIntegrations.isEmpty {
                        GoldenSectionHeader("External Services")

                        GoldenButtonGroup {
                            ForEach(Array(externalIntegrations.enumerated()), id: \.offset) { index, integration in
                                GoldenSettingsButton(
                                    integration.name,
                                    action: integration.action
                                )

                                if index < externalIntegrations.count - 1 {
                                    Divider().padding(.leading, GoldenTheme.spacing.medium)
                                }
                            }
                        }
                        .padding(.horizontal, GoldenTheme.spacing.medium)
                    }
                }
            }
        }
        .background(theme.background)
    }
}

// MARK: - Quick Start Helper

/// Helper to quickly create a basic Golden app
public struct GoldenAppQuickStart {
    /// Create a minimal app with placeholder content
    public static func minimalApp(
        name: String,
        version: String = "1.0.0"
    ) -> some View {
        let config = GoldenAppConfig(name: name, version: version)

        return GoldenAppRoot(
            config: config,
            playUse: { PlaceholderView(title: name, message: "Main content goes here") },
            modes: { PlaceholderView(title: "Modes", message: "Mode selection goes here") },
            dashboard: { PlaceholderView(title: "Dashboard", message: "Analytics go here") },
            integration: { PlaceholderView(title: "Integration", message: "Connections go here") },
            settings: { PlaceholderView(title: "Settings", message: "Settings go here") }
        )
    }
}
