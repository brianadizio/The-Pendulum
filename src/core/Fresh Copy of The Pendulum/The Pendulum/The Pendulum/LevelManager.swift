import Foundation
import UIKit

// MARK: - Level Configuration Structure
struct LevelConfig {
    let number: Int
    let balanceThreshold: Double      // In radians
    let balanceRequiredTime: Double   // Time required to maintain balance
    let initialPerturbation: Double   // In degrees
    let massMultiplier: Double        // Multiplier for base mass
    let lengthMultiplier: Double      // Multiplier for base length
    let dampingValue: Double          // Absolute damping value
    let gravityMultiplier: Double     // Multiplier for gravity
    let springConstantValue: Double   // Absolute spring constant value
    let description: String           // Level description
    
    // Calculated property for balance threshold in degrees
    var balanceThresholdDegrees: Double {
        return balanceThreshold * 180 / Double.pi
    }
}

// MARK: - Level Progression Delegate
protocol LevelProgressionDelegate: AnyObject {
    func didCompleteLevel(_ level: Int, config: LevelConfig)
    func didStartNewLevel(_ level: Int, config: LevelConfig)
    func updateDifficultyParameters(config: LevelConfig)
}

// MARK: - Level Manager
class LevelManager {
    // Constants for base configuration
    static let baseBalanceThreshold = 0.35      // About 20 degrees in radians - extremely forgiving to start
    static let baseBalanceRequiredTime = 0.75   // Just 0.75 second to complete level 1 - much easier
    static let baseMass = 1.0
    static let baseLength = 1.0
    static let baseDamping = 0.4                // Higher damping for much easier control
    static let baseGravity = 9.81               // Standard gravity
    static let baseSpringConstant = 0.2         // Stronger stabilizing force for easier balancing
    static let basePerturbation = 8.0           // Smaller initial perturbation in degrees
    
    // Number of predefined levels (beyond this, levels are procedurally generated)
    private let predefinedLevelCount = 10
    
    // Current level information
    private(set) var currentLevel: Int = 1
    
    // Maximum reached level for this player
    private(set) var maxReachedLevel: Int = 1
    
    // Delegate to notify about level progression
    weak var delegate: LevelProgressionDelegate?
    
    // MARK: - Initialization
    
    init() {
        // Load max level from UserDefaults
        maxReachedLevel = UserDefaults.standard.integer(forKey: "PendulumMaxLevel")
        if maxReachedLevel < 1 {
            maxReachedLevel = 1
        }
    }
    
    // MARK: - Level Management
    
    /// Set the current level
    func setLevel(_ level: Int) {
        guard level > 0 else { return }
        
        currentLevel = level
        
        // Update max reached level if needed
        if level > maxReachedLevel {
            maxReachedLevel = level
            saveMaxLevel()
        }
        
        // Get configuration for this level
        let config = getConfigForLevel(level)
        
        // Notify delegate
        delegate?.didStartNewLevel(level, config: config)
        delegate?.updateDifficultyParameters(config: config)
    }
    
    /// Advance to the next level
    func advanceToNextLevel() {
        let completedLevelConfig = getConfigForLevel(currentLevel)
        
        // Notify delegate about level completion
        delegate?.didCompleteLevel(currentLevel, config: completedLevelConfig)
        
        // Move to next level
        setLevel(currentLevel + 1)
    }
    
    /// Reset to level 1
    func resetToLevel1() {
        setLevel(1)
    }
    
    /// Get configuration for a specific level
    func getConfigForLevel(_ level: Int) -> LevelConfig {
        // For levels beyond predefined ones, use procedural generation
        if level <= predefinedLevelCount {
            return getPredefinedLevelConfig(level)
        } else {
            return generateProceduralLevelConfig(level)
        }
    }
    
    /// Save the maximum reached level
    private func saveMaxLevel() {
        UserDefaults.standard.set(maxReachedLevel, forKey: "PendulumMaxLevel")
    }
    
    // MARK: - Level Configuration Generation
    
    /// Generate predefined level configurations
    private func getPredefinedLevelConfig(_ level: Int) -> LevelConfig {
        // Ensure level is valid
        let safeLevel = max(1, min(level, predefinedLevelCount))
        
        switch safeLevel {
        case 1:
            return LevelConfig(
                number: 1,
                balanceThreshold: LevelManager.baseBalanceThreshold,
                balanceRequiredTime: LevelManager.baseBalanceRequiredTime,
                initialPerturbation: LevelManager.basePerturbation,
                massMultiplier: 1.0,
                lengthMultiplier: 1.0,
                dampingValue: LevelManager.baseDamping,
                gravityMultiplier: 1.0,
                springConstantValue: LevelManager.baseSpringConstant,
                description: "Beginner - Just get upright briefly"
            )
            
        case 2:
            return LevelConfig(
                number: 2,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.98, // Only slightly more difficult
                balanceRequiredTime: 1.0, // Still just 1 second
                initialPerturbation: LevelManager.basePerturbation,
                massMultiplier: 1.0,
                lengthMultiplier: 1.0,
                dampingValue: LevelManager.baseDamping,
                gravityMultiplier: 1.0,
                springConstantValue: LevelManager.baseSpringConstant * 0.95,
                description: "Novice - Getting the hang of it"
            )
            
        case 3:
            return LevelConfig(
                number: 3,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.95,
                balanceRequiredTime: 1.25,
                initialPerturbation: LevelManager.basePerturbation * 1.05,
                massMultiplier: 1.02,
                lengthMultiplier: 1.0,
                dampingValue: LevelManager.baseDamping * 0.95,
                gravityMultiplier: 1.0,
                springConstantValue: LevelManager.baseSpringConstant * 0.9,
                description: "Apprentice - Find your balance"
            )
            
        case 4:
            return LevelConfig(
                number: 4,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.92,
                balanceRequiredTime: 1.5,
                initialPerturbation: LevelManager.basePerturbation * 1.1,
                massMultiplier: 1.05,
                lengthMultiplier: 1.0,
                dampingValue: LevelManager.baseDamping * 0.9,
                gravityMultiplier: 1.02,
                springConstantValue: LevelManager.baseSpringConstant * 0.85,
                description: "Adept - Gentle balancing"
            )
            
        case 5:
            return LevelConfig(
                number: 5,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.89,
                balanceRequiredTime: 1.75,
                initialPerturbation: LevelManager.basePerturbation * 1.15,
                massMultiplier: 1.08,
                lengthMultiplier: 1.02,
                dampingValue: LevelManager.baseDamping * 0.85,
                gravityMultiplier: 1.05,
                springConstantValue: LevelManager.baseSpringConstant * 0.8,
                description: "Practiced - Controlled movement"
            )
            
        case 6:
            return LevelConfig(
                number: 6,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.85,
                balanceRequiredTime: 2.0,
                initialPerturbation: LevelManager.basePerturbation * 1.2,
                massMultiplier: 1.1,
                lengthMultiplier: 1.05,
                dampingValue: LevelManager.baseDamping * 0.8,
                gravityMultiplier: 1.08,
                springConstantValue: LevelManager.baseSpringConstant * 0.75,
                description: "Expert - Steady hands"
            )
            
        case 7:
            return LevelConfig(
                number: 7,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.8,
                balanceRequiredTime: 2.25,
                initialPerturbation: LevelManager.basePerturbation * 1.25,
                massMultiplier: 1.15,
                lengthMultiplier: 1.08,
                dampingValue: LevelManager.baseDamping * 0.75,
                gravityMultiplier: 1.1,
                springConstantValue: LevelManager.baseSpringConstant * 0.7,
                description: "Master - Precise control"
            )
            
        case 8:
            return LevelConfig(
                number: 8,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.75,
                balanceRequiredTime: 2.5,
                initialPerturbation: LevelManager.basePerturbation * 1.3,
                massMultiplier: 1.2,
                lengthMultiplier: 1.1,
                dampingValue: LevelManager.baseDamping * 0.7,
                gravityMultiplier: 1.15,
                springConstantValue: LevelManager.baseSpringConstant * 0.65,
                description: "Champion - Delicate balance"
            )
            
        case 9:
            return LevelConfig(
                number: 9,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.7,
                balanceRequiredTime: 2.75,
                initialPerturbation: LevelManager.basePerturbation * 1.35,
                massMultiplier: 1.25,
                lengthMultiplier: 1.15,
                dampingValue: LevelManager.baseDamping * 0.65,
                gravityMultiplier: 1.2,
                springConstantValue: LevelManager.baseSpringConstant * 0.6,
                description: "Legend - Zen focus"
            )
            
        case 10:
            return LevelConfig(
                number: 10,
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.65,
                balanceRequiredTime: 3.0,
                initialPerturbation: LevelManager.basePerturbation * 1.4,
                massMultiplier: 1.3,
                lengthMultiplier: 1.2,
                dampingValue: LevelManager.baseDamping * 0.6,
                gravityMultiplier: 1.25,
                springConstantValue: LevelManager.baseSpringConstant * 0.55,
                description: "Perfect Balance - Mastery achieved"
            )
            
        default:
            // Fallback for any unexpected cases
            return LevelConfig(
                number: 1,
                balanceThreshold: LevelManager.baseBalanceThreshold,
                balanceRequiredTime: LevelManager.baseBalanceRequiredTime,
                initialPerturbation: LevelManager.basePerturbation,
                massMultiplier: 1.0,
                lengthMultiplier: 1.0,
                dampingValue: LevelManager.baseDamping,
                gravityMultiplier: 1.0,
                springConstantValue: LevelManager.baseSpringConstant,
                description: "Default Level"
            )
        }
    }
    
    /// Generate procedural level configuration for levels beyond predefined ones
    private func generateProceduralLevelConfig(_ level: Int) -> LevelConfig {
        // Base difficulty factor increases with level but at a more gradual rate
        let difficultyFactor = 1.0 + Double(level - predefinedLevelCount) * 0.05
        
        // Cap the difficulty increase at a reasonable maximum
        let cappedDifficultyFactor = min(difficultyFactor, 2.0)
        
        // Calculate scaled parameters - much gentler scaling for balance threshold
        let balanceThreshold = LevelManager.baseBalanceThreshold * (0.6 / cappedDifficultyFactor)
        
        // More gradual scaling for balance time required
        let balanceTime = min(3.5 + (Double(level - predefinedLevelCount) * 0.25), 8.0) // Cap at 8 seconds
        
        // More controlled perturbation increase
        let perturbation = min(LevelManager.basePerturbation * (1.0 + (cappedDifficultyFactor * 0.05)), 
                              LevelManager.basePerturbation * 2.0) // Cap at 2x base
        
        // More gradual scaling of mass and length
        let massMultiplier = 1.3 + (Double(level - predefinedLevelCount) * 0.05)
        let lengthMultiplier = 1.2 + (Double(level - predefinedLevelCount) * 0.03)
        
        // Damping and spring constant decrease with difficulty, but maintain playability
        let dampingValue = max(LevelManager.baseDamping * (0.55 / cappedDifficultyFactor), 0.2)
        let springConstantValue = max(LevelManager.baseSpringConstant * (0.5 / cappedDifficultyFactor), 0.05)
        
        // More gradual gravity increase
        let gravityMultiplier = 1.3 + (Double(level - predefinedLevelCount) * 0.03)
        
        // Create descriptive level names for procedural levels
        let levelDescription: String
        let levelBeyond = level - predefinedLevelCount
        
        if levelBeyond <= 5 {
            levelDescription = "Elite Level \(levelBeyond) - Beyond the basics"
        } else if levelBeyond <= 10 {
            levelDescription = "Pro Level \(levelBeyond) - True dedication"
        } else if levelBeyond <= 20 {
            levelDescription = "Guru Level \(levelBeyond) - Path to enlightenment"
        } else {
            levelDescription = "Legendary \(levelBeyond) - Pendulum whisperer"
        }
        
        return LevelConfig(
            number: level,
            balanceThreshold: balanceThreshold,
            balanceRequiredTime: balanceTime,
            initialPerturbation: perturbation,
            massMultiplier: massMultiplier,
            lengthMultiplier: lengthMultiplier,
            dampingValue: dampingValue,
            gravityMultiplier: gravityMultiplier,
            springConstantValue: springConstantValue,
            description: levelDescription
        )
    }
}

// MARK: - Extensions for Level Transition Animations

extension UIView {
    func levelCompletionAnimation(completion: @escaping () -> Void) {
        // Create a container for the animation
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.layer.cornerRadius = 20
        container.alpha = 0

        // Add to view
        self.addSubview(container)

        // Center constraints and size
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            container.heightAnchor.constraint(equalToConstant: 120)
        ])

        // Create a "Level Complete" label
        let levelCompleteLabel = UILabel()
        levelCompleteLabel.text = "Level Complete!"
        levelCompleteLabel.textAlignment = .center
        levelCompleteLabel.textColor = .white
        levelCompleteLabel.font = UIFont.boldSystemFont(ofSize: 32)
        levelCompleteLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add to container
        container.addSubview(levelCompleteLabel)

        // Center constraints
        NSLayoutConstraint.activate([
            levelCompleteLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            levelCompleteLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        // Fade in container
        UIView.animate(withDuration: 0.2, animations: {
            container.alpha = 1.0
        }, completion: { _ in
            // Flash animation with scale - faster than before
            UIView.animate(withDuration: 0.2, animations: {
                levelCompleteLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, animations: {
                    levelCompleteLabel.transform = CGAffineTransform.identity
                }, completion: { _ in
                    // Hold for shorter time - 0.5 second instead of 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Fade out faster
                        UIView.animate(withDuration: 0.3, animations: {
                            container.alpha = 0
                        }, completion: { _ in
                            container.removeFromSuperview()
                            completion()
                        })
                    }
                })
            })
        })
    }

    func newLevelStartAnimation(level: Int, description: String, completion: @escaping () -> Void) {
        // Create level label
        let levelLabel = UILabel()
        levelLabel.text = "Level \(level)"
        levelLabel.textAlignment = .center
        levelLabel.textColor = .white
        levelLabel.font = UIFont.boldSystemFont(ofSize: 36)
        levelLabel.alpha = 0
        levelLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 20)
        descriptionLabel.alpha = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Container view for labels - improved appearance
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        containerView.alpha = 0
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Add a subtle glow effect
        containerView.layer.shadowColor = UIColor.yellow.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 10

        // Add to view hierarchy
        self.addSubview(containerView)
        containerView.addSubview(levelLabel)
        containerView.addSubview(descriptionLabel)

        // Constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalToConstant: 140), // Slightly taller for better spacing

            levelLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            levelLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            levelLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            levelLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 15),
            descriptionLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])

        // Animate in with more dynamic motion - small zoom and fade
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [], animations: {
            containerView.alpha = 1
            containerView.transform = CGAffineTransform.identity
            levelLabel.alpha = 1
            descriptionLabel.alpha = 1
        }, completion: { _ in
            // Hold for 1 second instead of 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Animate out with slight upward motion
                UIView.animate(withDuration: 0.3, animations: {
                    containerView.alpha = 0
                    containerView.transform = CGAffineTransform(translationX: 0, y: -20)
                }, completion: { _ in
                    containerView.removeFromSuperview()
                    completion()
                })
            }
        })
    }
}