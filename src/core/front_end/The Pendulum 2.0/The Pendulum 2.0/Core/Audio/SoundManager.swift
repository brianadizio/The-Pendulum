// SoundManager.swift
// The Pendulum 2.0
// Singleton audio manager for level-beat nature sounds

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    // All level-beat sound file names (without extension)
    private let levelBeatSounds = [
        "birds_1", "birds_2", "birds_3",
        "gong_rain_1", "gong_rain_2",
        "ocean_waves", "thunder_hole"
    ]

    private var audioPlayer: AVAudioPlayer?

    /// Whether sound effects are enabled (bound to gameState.soundEnabled)
    var isEnabled: Bool = true

    private init() {
        // Configure audio session for playback alongside other audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundManager: Failed to configure audio session: \(error)")
        }
    }

    /// Play a random nature sound when the player beats a level
    func playLevelBeatSound() {
        guard isEnabled else { return }

        // Pick a random sound
        guard let soundName = levelBeatSounds.randomElement() else { return }

        // Load from bundle
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("SoundManager: Could not find \(soundName).mp3 in bundle")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.7
            audioPlayer?.play()
        } catch {
            print("SoundManager: Failed to play \(soundName): \(error)")
        }
    }

    /// Stop any currently playing audio
    func stopAll() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
