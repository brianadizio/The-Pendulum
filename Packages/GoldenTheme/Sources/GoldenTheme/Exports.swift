// Exports.swift
// Golden Enterprises Theme System
// Public API exports

// Re-export all public types for convenience

// MARK: - Core
@_exported import struct SwiftUI.Color
@_exported import struct SwiftUI.Font
@_exported import struct SwiftUI.Image

// MARK: - Colors
public typealias Spectrum = SpectrumColor
public typealias Metal = MetalColor

// MARK: - Convenience Type Aliases
public typealias GS = GoldenSpacing
public typealias GG = GoldenGeometry
public typealias GT = GoldenTypography

// MARK: - View Type Aliases (for cleaner code)
public typealias PrimaryButton = GoldenPrimaryButton
public typealias SecondaryButton = GoldenSecondaryButton
public typealias TextButton = GoldenTextButton
public typealias SettingsButton = GoldenSettingsButton
public typealias ToggleRow = GoldenToggleRow

public typealias TextField = GoldenTextField
public typealias Slider = GoldenSlider
public typealias SearchField = GoldenSearchField

public typealias TabBar = GoldenTabBar
public typealias NavigationHeader = GoldenNavigationHeader

public typealias Card = GoldenCard
public typealias StatCard = StatisticCard
public typealias MetricCard = MetricRowCard

public typealias Spinner = GoldenSpinner
public typealias LoadingOverlay = GoldenLoadingOverlay

public typealias ChatView = GoldenChatView
public typealias ChatInput = ChatInputField
