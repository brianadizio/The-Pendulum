import AVFoundation
import UIKit

// Sound Manager for Pendulum Game
class PendulumSoundManager {
    
    // Singleton instance
    static let shared = PendulumSoundManager()
    
    // Sound settings from the Settings menu
    enum SoundMode: String {
        case standard = "Standard"
        case enhanced = "Enhanced"
        case minimal = "Minimal"
        case realistic = "Realistic"
        case none = "None"
        case educational = "Educational"
    }
    
    // Current sound mode
    var currentMode: SoundMode = .standard
    
    // Audio players for different sounds
    private var swingPlayer: AVAudioPlayer?
    private var collisionPlayer: AVAudioPlayer?
    private var achievementPlayer: AVAudioPlayer?
    private var failurePlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    
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
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    
    // Play pendulum swing sound (varies by position/speed)
    func playSwingSound(angle: CGFloat, velocity: CGFloat) {
        guard currentMode != .none else { return }
        
        switch currentMode {
        case .standard:
            // Placeholder: Play a simple swing sound
            playSystemSound(1104) // Tock sound
            
        case .enhanced:
            // Placeholder: Play a more complex sound with pitch variation
            let pitch = mapValueToRange(abs(velocity), inputMin: 0, inputMax: 10, outputMin: 0.8, outputMax: 1.2)
            playSystemSound(1105) // Tick sound
            // In a real implementation, you'd adjust pitch here
            
        case .minimal:
            // Placeholder: Play only on significant swings
            if abs(velocity) > 2.0 {
                playSystemSound(1103) // Tink sound
            }
            
        case .realistic:
            // Placeholder: Physics-based sound calculation
            let intensity = min(abs(velocity) / 5.0, 1.0)
            if intensity > 0.3 {
                playSystemSound(1107) // Tock sound
                impactFeedback.impactOccurred(intensity: CGFloat(intensity))
            }
            
        case .educational:
            // Placeholder: Play sounds that indicate physics concepts
            if angle > 0 {
                playSystemSound(1104) // Right side
            } else {
                playSystemSound(1105) // Left side
            }
            
        case .none:
            break
        }
    }
    
    // Play collision/boundary hit sound
    func playCollisionSound() {
        guard currentMode != .none else { return }
        
        switch currentMode {
        case .standard, .enhanced, .realistic:
            playSystemSound(1108) // Pop sound
            impactFeedback.impactOccurred()
            
        case .minimal:
            impactFeedback.impactOccurred(intensity: 0.5)
            
        case .educational:
            playSystemSound(1109) // Different pop sound
            
        case .none:
            break
        }
    }
    
    // Play achievement/level complete sound
    func playAchievementSound() {
        guard currentMode != .none else { return }
        
        switch currentMode {
        case .standard, .minimal:
            playSystemSound(1025) // Success sound
            
        case .enhanced, .realistic:
            playSystemSound(1025) // Success sound
            selectionFeedback.selectionChanged()
            
        case .educational:
            playSystemSound(1025) // Success sound
            // Could add voice saying "Level Complete" in real implementation
            
        case .none:
            break
        }
    }
    
    // Play failure/game over sound
    func playFailureSound() {
        guard currentMode != .none else { return }
        
        switch currentMode {
        case .standard, .minimal:
            playSystemSound(1053) // Failure sound
            
        case .enhanced, .realistic:
            playSystemSound(1053) // Failure sound
            impactFeedback.impactOccurred(intensity: 0.8)
            
        case .educational:
            playSystemSound(1053) // Failure sound
            // Could add voice explaining the physics in real implementation
            
        case .none:
            break
        }
    }
    
    // Play button tap sound
    func playButtonTapSound() {
        guard currentMode != .none else { return }
        
        if currentMode != .minimal {
            playSystemSound(1104) // Click sound
            selectionFeedback.selectionChanged()
        }
    }
    
    // Play level start sound
    func playLevelStartSound() {
        guard currentMode != .none else { return }
        
        switch currentMode {
        case .standard, .enhanced, .realistic:
            playSystemSound(1113) // Begin recording sound
            
        case .educational:
            playSystemSound(1113)
            // Could add voice saying "Level X" in real implementation
            
        case .minimal, .none:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
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