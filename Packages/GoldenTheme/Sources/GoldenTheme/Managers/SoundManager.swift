// SoundManager.swift
// Golden Enterprises Theme System
// Audio feedback management for soothing, meditative sounds

import SwiftUI
import AVFoundation

// MARK: - Sound Types

/// Types of sound effects available
public enum SoundType: String, CaseIterable {
    case tap           // Button tap sound
    case success       // Success/completion sound
    case error         // Error sound
    case navigation    // Tab/navigation change
    case selection     // Selection change
    case notification  // Alert/notification

    /// System sound ID for fallback sounds
    var systemSoundID: SystemSoundID {
        switch self {
        case .tap: return 1104
        case .success: return 1025
        case .error: return 1053
        case .navigation: return 1105
        case .selection: return 1156
        case .notification: return 1007
        }
    }
}

// MARK: - Sound Manager

/// Manages audio feedback across the application
@MainActor
public class SoundManager {
    public static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    /// Whether sound effects are enabled (user preference)
    @AppStorage("goldenSoundsEnabled") public var isEnabled: Bool = true

    /// Volume level (0.0 to 1.0)
    @AppStorage("goldenSoundsVolume") public var volume: Double = 0.5

    private init() {
        configureAudioSession()
    }

    // MARK: - Configuration

    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }

    // MARK: - Sound Loading

    /// Load a custom sound from the app bundle
    public func loadSound(named name: String, extension ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound file not found: \(name).\(ext)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = Float(volume)
            audioPlayers[name] = player
        } catch {
            print("Failed to load sound \(name): \(error)")
        }
    }

    /// Load multiple sounds at once
    public func loadSounds(_ names: [String], extension ext: String = "wav") {
        for name in names {
            loadSound(named: name, extension: ext)
        }
    }

    // MARK: - Playback

    /// Play a custom sound by name
    public func play(_ name: String) {
        guard isEnabled else { return }

        if let player = audioPlayers[name] {
            player.volume = Float(volume)
            player.currentTime = 0
            player.play()
        }
    }

    /// Play a system sound type
    public func play(_ type: SoundType) {
        guard isEnabled else { return }

        // Try custom sound first
        if let player = audioPlayers[type.rawValue] {
            player.volume = Float(volume)
            player.currentTime = 0
            player.play()
            return
        }

        // Fall back to system sound
        #if os(iOS)
        AudioServicesPlaySystemSound(type.systemSoundID)
        #endif
    }

    /// Update volume for all loaded sounds
    public func updateVolume(_ newVolume: Double) {
        volume = newVolume
        for player in audioPlayers.values {
            player.volume = Float(volume)
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Add sound feedback on tap
    func soundOnTap(_ type: SoundType = .tap) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                SoundManager.shared.play(type)
            }
        )
    }

    /// Add both haptic and sound feedback on tap
    func feedbackOnTap(haptic: HapticType = .medium, sound: SoundType = .tap) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticManager.shared.play(haptic)
                SoundManager.shared.play(sound)
            }
        )
    }
}
