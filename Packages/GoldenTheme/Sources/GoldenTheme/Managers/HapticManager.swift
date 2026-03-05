// HapticManager.swift
// Golden Enterprises Theme System
// Haptic feedback management for consistent tactile experience

import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Haptic Types

/// Types of haptic feedback available
public enum HapticType {
    case light       // Subtle feedback for selections
    case medium      // Standard feedback for button presses
    case heavy       // Strong feedback for important actions
    case selection   // Selection change feedback
    case success     // Positive outcome notification
    case warning     // Warning notification
    case error       // Error notification
}

// MARK: - Haptic Manager

/// Manages haptic feedback across the application
@MainActor
public class HapticManager {
    public static let shared = HapticManager()

    #if os(iOS)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    #endif

    /// Whether haptics are enabled (user preference)
    @AppStorage("goldenHapticsEnabled") public var isEnabled: Bool = true

    private init() {
        prepare()
    }

    /// Prepare haptic generators for low-latency feedback
    public func prepare() {
        #if os(iOS)
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
        #endif
    }

    /// Play haptic feedback of the specified type
    public func play(_ type: HapticType) {
        guard isEnabled else { return }

        #if os(iOS)
        switch type {
        case .light:
            lightImpact.impactOccurred()
        case .medium:
            mediumImpact.impactOccurred()
        case .heavy:
            heavyImpact.impactOccurred()
        case .selection:
            selectionGenerator.selectionChanged()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
        #endif
    }

    /// Play haptic with custom intensity (0.0 to 1.0)
    public func playWithIntensity(_ intensity: CGFloat) {
        guard isEnabled else { return }

        #if os(iOS)
        if intensity < 0.33 {
            lightImpact.impactOccurred(intensity: intensity * 3)
        } else if intensity < 0.66 {
            mediumImpact.impactOccurred(intensity: (intensity - 0.33) * 3)
        } else {
            heavyImpact.impactOccurred(intensity: (intensity - 0.66) * 3)
        }
        #endif
    }
}

// MARK: - View Extension

public extension View {
    /// Add haptic feedback on tap
    func hapticOnTap(_ type: HapticType = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticManager.shared.play(type)
            }
        )
    }
}
