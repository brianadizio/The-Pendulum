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
    private var fadeTimer: Timer?

    /// Whether sound effects are enabled (bound to gameState.soundEnabled)
    var isEnabled: Bool = false

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

        // Stop any currently playing sound to prevent overlap
        stopAll()

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

            // Auto-fadeout after ~3 seconds to prevent bleeding into next level
            scheduleFadeout(after: 3.0)
        } catch {
            print("SoundManager: Failed to play \(soundName): \(error)")
        }
    }

    /// Stop any currently playing audio
    func stopAll() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }

    /// Schedule a volume fadeout after the given delay
    private func scheduleFadeout(after delay: TimeInterval) {
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.fadeOut()
        }
    }

    /// Quick 0.5s volume ramp-down then stop
    private func fadeOut() {
        guard let player = audioPlayer, player.isPlaying else { return }

        let fadeSteps = 10
        let fadeInterval = 0.5 / Double(fadeSteps)
        let volumeStep = player.volume / Float(fadeSteps)

        fadeTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            player.volume -= volumeStep
            if player.volume <= 0.05 {
                timer.invalidate()
                self.stopAll()
            }
        }
    }
}
