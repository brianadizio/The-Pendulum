import AVFoundation
import UIKit

// Sound Manager for Pendulum Game
class PendulumSoundManager {
    
    // Singleton instance
    static let shared = PendulumSoundManager()
    
    // Sound settings from the Settings menu
    enum SoundMode: String {
        case standard = "Standard"
        case music = "Music"
        case immersive = "Immersive"
        case minimal = "Minimal"
        case silent = "Silent"
    }
    
    // Current sound mode
    var currentMode: SoundMode = .standard
    
    // Audio players for different sounds
    private var swingPlayer: AVAudioPlayer?
    private var collisionPlayer: AVAudioPlayer?
    private var achievementPlayer: AVAudioPlayer?
    private var failurePlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    private var buttonPlayer: AVAudioPlayer?
    private var levelStartPlayer: AVAudioPlayer?
    
    // Cached system sound data for volume control
    private var systemSoundPlayers: [SystemSoundID: AVAudioPlayer] = [:]
    
    // Sound types enum
    enum SoundType {
        case windGentle
        case windStrong
        case impulseWeak
        case impulseStrong
    }
    
    // Haptic feedback generator
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare haptic feedback
        impactFeedback.prepare()
        selectionFeedback.prepare()
        
        // Initialize audio session
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    
    // Play pendulum swing sound (varies by position/speed)
    func playSwingSound(angle: CGFloat, velocity: CGFloat) {
        guard currentMode != .silent else { return }
        
        switch currentMode {
        case .standard:
            // Placeholder: Play a simple swing sound
            playSystemSound(1104) // Tock sound
            
        case .music:
            // Play musical tones based on pendulum motion
            let pitch = mapValueToRange(abs(velocity), inputMin: 0, inputMax: 10, outputMin: 0.8, outputMax: 1.2)
            playSystemSound(1105) // Tick sound
            // In a real implementation, you'd adjust pitch here
            
        case .immersive:
            // Enhanced sound with environmental effects
            let intensity = min(abs(velocity) / 5.0, 1.0)
            if intensity > 0.2 {
                playSystemSound(1107) // Tock sound
                impactFeedback.impactOccurred(intensity: CGFloat(intensity))
            }
            
            
        case .minimal:
            // Play only on significant swings
            if abs(velocity) > 2.0 {
                playSystemSound(1103) // Tink sound
            }
            
        case .silent:
            break
        }
    }
    
    // Play collision/boundary hit sound
    func playCollisionSound() {
        guard currentMode != .silent else { return }
        
        switch currentMode {
        case .standard, .music, .immersive:
            playSystemSound(1108) // Pop sound
            impactFeedback.impactOccurred()
            
        case .minimal:
            impactFeedback.impactOccurred(intensity: 0.5)
            
        case .silent:
            break
        }
    }
    
    // Play achievement/level complete sound
    func playAchievementSound() {
        guard currentMode != .silent else { return }
        
        switch currentMode {
        case .standard, .minimal:
            playSystemSound(1025) // Success sound
            
        case .music, .immersive:
            playSystemSound(1025) // Success sound
            selectionFeedback.selectionChanged()
            
        case .silent:
            break
        }
    }
    
    // Play failure/game over sound
    func playFailureSound() {
        guard currentMode != .silent else { return }
        
        switch currentMode {
        case .standard, .minimal:
            playSystemSound(1053) // Failure sound
            
        case .music, .immersive:
            playSystemSound(1053) // Failure sound
            impactFeedback.impactOccurred(intensity: 0.8)
            
        case .silent:
            break
        }
    }
    
    // Play button tap sound
    func playButtonTapSound() {
        guard currentMode != .silent else { return }
        
        if currentMode != .minimal {
            playSystemSound(1104) // Click sound
            selectionFeedback.selectionChanged()
        }
    }
    
    // Play level start sound
    func playLevelStartSound() {
        guard currentMode != .silent else { return }
        
        switch currentMode {
        case .standard, .music, .immersive:
            playSystemSound(1113) // Begin recording sound
            
        case .minimal, .silent:
            break
        }
    }
    
    // Play perturbation sounds
    func playSound(_ soundType: SoundType) {
        guard currentMode != .silent else { return }
        
        switch soundType {
        case .windGentle:
            // Gentle wind sound - use a soft whoosh
            playSystemSound(1050) // Whoosh sound
            if currentMode == .music || currentMode == .immersive {
                impactFeedback.impactOccurred(intensity: 0.3)
            }
            
        case .windStrong:
            // Strong wind sound - use a more intense sound
            playSystemSound(1051) // Stronger whoosh
            if currentMode == .music || currentMode == .immersive {
                impactFeedback.impactOccurred(intensity: 0.6)
            }
            
        case .impulseWeak:
            // Weak impulse - light hit
            playSystemSound(1105) // Tick sound
            if currentMode != .minimal {
                impactFeedback.impactOccurred(intensity: 0.4)
            }
            
        case .impulseStrong:
            // Strong impulse - heavy hit
            playSystemSound(1108) // Pop sound
            impactFeedback.impactOccurred(intensity: 0.8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        // For now, still use system sounds but with volume-aware session
        // In future, could replace with custom AVAudioPlayer sounds
        AudioServicesPlaySystemSound(soundID)
    }
    
    // Play a sound file through AVAudioPlayer (respects volume)
    private func playSoundFile(named fileName: String, withExtension ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            // Fallback to system sound if custom file not found
            playSystemSound(1104)
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 1.0 // Will respect system volume
            player.play()
        } catch {
            print("Error playing sound file: \(error)")
            // Fallback to system sound
            playSystemSound(1104)
        }
    }
    
    private func mapValueToRange(_ value: CGFloat, inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat) -> CGFloat {
        let clampedValue = min(max(value, inputMin), inputMax)
        let inputRange = inputMax - inputMin
        let outputRange = outputMax - outputMin
        let scaledValue = (clampedValue - inputMin) / inputRange
        return outputMin + (scaledValue * outputRange)
    }
    
    // Update sound mode from settings
    func updateSoundMode(_ mode: String) {
        currentMode = SoundMode(rawValue: mode) ?? .standard
    }
    
    // Preload sounds for better performance
    func preloadSounds() {
        // In a real implementation, you would load custom sound files here
        // For now, we're using system sounds as placeholders
    }
    
    // Clean up resources
    func cleanup() {
        swingPlayer?.stop()
        collisionPlayer?.stop()
        achievementPlayer?.stop()
        failurePlayer?.stop()
        ambientPlayer?.stop()
    }
}