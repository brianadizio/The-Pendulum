// LevelManager.swift
// The Pendulum 2.0
// Level progression system - mode-aware level generation

import Foundation
import Combine

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

    // Mode-specific fields
    let countdownTime: TimeInterval?  // For Timed mode - seconds to complete level
    let jiggleIntensity: Double       // For Jiggle mode - noise amplitude (0 = none)

    // Calculated property for balance threshold in degrees
    var balanceThresholdDegrees: Double {
        return balanceThreshold * 180 / Double.pi
    }

    // Convenience initializer with defaults for new fields
    init(number: Int, balanceThreshold: Double, balanceRequiredTime: Double,
         initialPerturbation: Double, massMultiplier: Double, lengthMultiplier: Double,
         dampingValue: Double, gravityMultiplier: Double, springConstantValue: Double,
         description: String, countdownTime: TimeInterval? = nil, jiggleIntensity: Double = 0.0) {
        self.number = number
        self.balanceThreshold = balanceThreshold
        self.balanceRequiredTime = balanceRequiredTime
        self.initialPerturbation = initialPerturbation
        self.massMultiplier = massMultiplier
        self.lengthMultiplier = lengthMultiplier
        self.dampingValue = dampingValue
        self.gravityMultiplier = gravityMultiplier
        self.springConstantValue = springConstantValue
        self.description = description
        self.countdownTime = countdownTime
        self.jiggleIntensity = jiggleIntensity
    }
}

// MARK: - Level Progression Delegate
protocol LevelProgressionDelegate: AnyObject {
    func didCompleteLevel(_ level: Int, config: LevelConfig)
    func didStartNewLevel(_ level: Int, config: LevelConfig)
    func updateDifficultyParameters(config: LevelConfig)
}

// MARK: - Level Manager
class LevelManager: ObservableObject {
    // Constants for base configuration
    static let baseBalanceThreshold = 0.35      // About 20 degrees in radians
    static let baseBalanceRequiredTime = 1.5    // 1.5 seconds
    static let baseMass = 1.0
    static let baseLength = 1.0
    static let baseDamping = 0.4                // Higher damping for easier control
    static let baseGravity = 9.81               // Standard gravity
    static let baseSpringConstant = 0.2         // Stabilizing force
    static let basePerturbation = 8.0           // Initial perturbation in degrees

    // Number of predefined levels (beyond this, levels are procedurally generated)
    private let predefinedLevelCount = 10

    // Current level information
    @Published private(set) var currentLevel: Int = 1

    // Maximum reached level for this player
    @Published private(set) var maxReachedLevel: Int = 1

    // Active game mode - determines how level configs are generated
    var activeMode: GameMode = .freePlay

    // Delegate to notify about level progression
    weak var delegate: LevelProgressionDelegate?

    // Callback for level changes (used by CSVSessionManager)
    var onLevelChange: ((Int) -> Void)?

    // MARK: - Initialization

    init() {
        // Load max level from UserDefaults
        maxReachedLevel = UserDefaults.standard.integer(forKey: "Pendulum2MaxLevel")
        if maxReachedLevel < 1 {
            maxReachedLevel = 1
        }
    }

    /// Get configuration for the current level using the active mode
    func getConfigForCurrentLevel() -> LevelConfig {
        return getConfigForLevel(currentLevel, mode: activeMode)
    }

    // MARK: - Level Management

    /// Set the current level
    func setLevel(_ level: Int) {
        guard level > 0 else { return }

        currentLevel = level

        // Notify via callback (for CSV tracking)
        onLevelChange?(level)

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

    /// Demote one level (floor at 1) — used on fall to continue session
    func demoteOneLevel() {
        if currentLevel > 1 {
            setLevel(currentLevel - 1)
        }
    }

    /// Get configuration for a specific level (uses active mode)
    func getConfigForLevel(_ level: Int) -> LevelConfig {
        return getConfigForLevel(level, mode: activeMode)
    }

    /// Get configuration for a specific level and mode
    func getConfigForLevel(_ level: Int, mode: GameMode) -> LevelConfig {
        switch mode {
        case .freePlay:
            return getFreePlayConfig()
        case .progressive:
            return getProgressiveConfig(level)
        case .spatial:
            return getSpatialConfig(level)
        case .jiggle:
            return getJiggleConfig(level)
        case .timed:
            return getTimedConfig(level)
        case .random:
            return getRandomConfig(level)
        case .golden:
            return getGoldenConfig(level)
        }
    }

    /// Save the maximum reached level
    private func saveMaxLevel() {
        UserDefaults.standard.set(maxReachedLevel, forKey: "Pendulum2MaxLevel")
    }

    // MARK: - Level Configuration Generation

    /// Generate predefined level configurations
    private func getPredefinedLevelConfig(_ level: Int) -> LevelConfig {
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
                balanceThreshold: LevelManager.baseBalanceThreshold * 0.98,
                balanceRequiredTime: 1.0,
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
        let difficultyFactor = 1.0 + Double(level - predefinedLevelCount) * 0.05
        let cappedDifficultyFactor = min(difficultyFactor, 2.0)

        let balanceThreshold = LevelManager.baseBalanceThreshold * (0.6 / cappedDifficultyFactor)
        let balanceTime = min(3.5 + (Double(level - predefinedLevelCount) * 0.25), 8.0)
        let perturbation = min(LevelManager.basePerturbation * (1.0 + (cappedDifficultyFactor * 0.05)),
                              LevelManager.basePerturbation * 2.0)

        let massMultiplier = 1.3 + (Double(level - predefinedLevelCount) * 0.05)
        let lengthMultiplier = 1.2 + (Double(level - predefinedLevelCount) * 0.03)
        let dampingValue = max(LevelManager.baseDamping * (0.55 / cappedDifficultyFactor), 0.2)
        let springConstantValue = max(LevelManager.baseSpringConstant * (0.5 / cappedDifficultyFactor), 0.05)
        let gravityMultiplier = 1.3 + (Double(level - predefinedLevelCount) * 0.03)

        let levelBeyond = level - predefinedLevelCount
        let levelDescription: String

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

    // MARK: - Mode-Specific Level Generators

    /// Free Play: No levels, base config, no perturbations
    private func getFreePlayConfig() -> LevelConfig {
        LevelConfig(
            number: 1,
            balanceThreshold: LevelManager.baseBalanceThreshold,
            balanceRequiredTime: LevelManager.baseBalanceRequiredTime,
            initialPerturbation: 5.0,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: LevelManager.baseDamping,
            gravityMultiplier: 1.0,
            springConstantValue: LevelManager.baseSpringConstant,
            description: "Free Play - Balance freely"
        )
    }

    /// Progressive: Balance time increases each level, perturbations get stronger
    /// Level N: balanceTime = 1.5 + (N-1) * 0.5s, threshold stays base
    private func getProgressiveConfig(_ level: Int) -> LevelConfig {
        let balanceTime = LevelManager.baseBalanceRequiredTime + Double(level - 1) * 0.5

        return LevelConfig(
            number: level,
            balanceThreshold: LevelManager.baseBalanceThreshold,
            balanceRequiredTime: balanceTime,
            initialPerturbation: 5.0,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: LevelManager.baseDamping,
            gravityMultiplier: 1.0,
            springConstantValue: LevelManager.baseSpringConstant,
            description: "Level \(level) - Hold balance for \(String(format: "%.1f", balanceTime))s"
        )
    }

    /// Spatial: Green zone shrinks each level, balance time stays constant
    /// Level N: threshold = max(0.10, 0.35 - (N-1) * 0.04) rad
    private func getSpatialConfig(_ level: Int) -> LevelConfig {
        let threshold = max(0.10, LevelManager.baseBalanceThreshold - Double(level - 1) * 0.04)
        let thresholdDeg = Int(threshold * 180.0 / .pi)

        return LevelConfig(
            number: level,
            balanceThreshold: threshold,
            balanceRequiredTime: 2.0,
            initialPerturbation: 5.0,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: LevelManager.baseDamping,
            gravityMultiplier: 1.0,
            springConstantValue: LevelManager.baseSpringConstant,
            description: "Level \(level) - Balance within \(thresholdDeg)°"
        )
    }

    /// Jiggle: Random noise perturbations increase each level
    /// Level N: jiggleIntensity = min(1.5, 0.3 + (N-1) * 0.2), balanceTime scales like progressive
    private func getJiggleConfig(_ level: Int) -> LevelConfig {
        let balanceTime = LevelManager.baseBalanceRequiredTime + Double(level - 1) * 0.5
        let intensity = min(1.5, 0.3 + Double(level - 1) * 0.2)

        return LevelConfig(
            number: level,
            balanceThreshold: LevelManager.baseBalanceThreshold,
            balanceRequiredTime: balanceTime,
            initialPerturbation: 5.0,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: LevelManager.baseDamping,
            gravityMultiplier: 1.0,
            springConstantValue: LevelManager.baseSpringConstant,
            description: "Level \(level) - Jiggle intensity \(String(format: "%.1f", intensity))",
            jiggleIntensity: intensity
        )
    }

    /// Timed: Countdown timer per level, decreases with level
    /// Level N: countdown = max(10, 30 - (N-1) * 3)s
    private func getTimedConfig(_ level: Int) -> LevelConfig {
        let countdown = max(10.0, 30.0 - Double(level - 1) * 3.0)
        let balanceTime = level < 4 ? 1.5 : 2.0
        let threshold = max(0.20, LevelManager.baseBalanceThreshold - Double(level - 1) * 0.02)

        return LevelConfig(
            number: level,
            balanceThreshold: threshold,
            balanceRequiredTime: balanceTime,
            initialPerturbation: 5.0,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: LevelManager.baseDamping,
            gravityMultiplier: 1.0,
            springConstantValue: LevelManager.baseSpringConstant,
            description: "Level \(level) - \(Int(countdown))s countdown",
            countdownTime: countdown
        )
    }

    /// Random: Physics parameters randomized each level
    /// Mass, gravity, damping, spring constant vary uniformly within ranges
    private func getRandomConfig(_ level: Int) -> LevelConfig {
        let massMultiplier = Double.random(in: 0.7...1.5)
        let lengthMultiplier = Double.random(in: 0.7...1.5)
        let gravityMultiplier = Double.random(in: 7.0...13.0) / LevelManager.baseGravity
        let dampingValue = Double.random(in: 0.15...0.6)
        let springConstantValue = Double.random(in: 0.05...0.35)

        return LevelConfig(
            number: level,
            balanceThreshold: LevelManager.baseBalanceThreshold,
            balanceRequiredTime: 2.0,
            initialPerturbation: LevelManager.basePerturbation,
            massMultiplier: massMultiplier,
            lengthMultiplier: lengthMultiplier,
            dampingValue: dampingValue,
            gravityMultiplier: gravityMultiplier,
            springConstantValue: springConstantValue,
            description: "Level \(level) - Randomized physics"
        )
    }

    /// Golden: Adaptive config based on GoldenModeManager recommendation.
    /// Uses progressive-style scaling as baseline; actual physics may be
    /// overridden by the recommendation's GameConfig at session start.
    private func getGoldenConfig(_ level: Int) -> LevelConfig {
        // Gentle progressive curve — Golden Mode overrides physics
        // parameters via GameState.startNewSession(), so this provides
        // sensible defaults if no recommendation is active.
        let balanceTime = LevelManager.baseBalanceRequiredTime + Double(level - 1) * 0.4
        let threshold = max(0.15, LevelManager.baseBalanceThreshold - Double(level - 1) * 0.025)

        return LevelConfig(
            number: level,
            balanceThreshold: threshold,
            balanceRequiredTime: balanceTime,
            initialPerturbation: LevelManager.basePerturbation,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: LevelManager.baseDamping,
            gravityMultiplier: 1.0,
            springConstantValue: LevelManager.baseSpringConstant,
            description: "Golden Level \(level)"
        )
    }
}
