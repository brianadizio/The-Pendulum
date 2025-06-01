// PendulumViewModel.swift
import SwiftUI
import SpriteKit
import CoreData

// MARK: - Particle Effects Delegate Protocol

protocol PendulumParticleDelegate: AnyObject {
    func showLevelCompletionParticles(level: Int)
    func showAchievementParticles()
}

class PendulumViewModel: ObservableObject, LevelProgressionDelegate {
    @Published var currentState = PendulumState(theta: Double.pi + 0.1, thetaDot: 0, time: 0)
    @Published var simulationError: Double = 0
    @Published var isSimulating = false // Changed from isRunning to isSimulating
    
    // Game state properties
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var isGameActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var gameOverReason: String?
    @Published var balanceStartTime: Date?
    @Published var totalBalanceTime: TimeInterval = 0

    // Game mode properties
    @Published var isQuasiPeriodicMode: Bool = false // For Primary mode
    @Published var isProgressiveMode: Bool = false // For Progressive mode
    @Published var totalLevelsCompleted: Int = 0 // Track total levels completed in quasi-periodic mode
    
    // Total completions counter for particle color effects
    @Published var totalCompletions: Int = 0 // Tracks all completions across all modes
    
    // Level system properties
    @Published var currentLevel: Int = 1
    @Published var balanceThreshold: Double = 0.15  // Will be replaced by level manager
    @Published var consecutiveBalanceTime: TimeInterval = 0 // Time spent continuously balanced
    @Published var levelSuccessTime: TimeInterval = 3.0 // Time required to pass a level (seconds)
    @Published var levelStats: [String: Double] = [:] // Statistics for dashboard
    @Published var currentLevelDescription: String = ""
    
    // Level manager
    private let levelManager = LevelManager()
    
    // Score multiplier system
    @Published var scoreMultiplier: Double = 1.0
    @Published var multiplierTimeRemaining: Double = 0.0
    @Published var perfectBalanceStreak: Int = 0
    
    // Achievement tracking
    @Published var unlockedAchievements: [String] = []
    @Published var recentAchievement: (String, String)? // (name, description) for UI display
    @Published var achievementPoints: Int = 0
    
    // Time tracking for no-force achievement
    private var lastForcePressTime: Date?
    
    // Achievement tracking
    private var previousAngle: Double = Double.pi
    private var lastAchievementCheck: Date = Date()
    private let achievementManager = AchievementManager.shared
    
    // Current session ID (made public for analytics dashboard)
    var currentSessionId: UUID?
    
    // Constants for balance detection
    // balanceThreshold is now controlled by LevelManager
    private let perfectBalanceThreshold = 0.07 // Radians for "perfect" balance (~4 degrees) - more forgiving
    private let failureAngleThreshold = 1.57  // Radians from vertical considered "fallen" (90 degrees) - more challenging
    private let scoreUpdateInterval: TimeInterval = 0.05  // How often to update score - more responsive
    private var lastScoreUpdate: Date?
    private var lastForceAppliedTime: Double = 0
    private var maxAngleRecovered: Double = 0.0 // Track max angle successfully recovered from
    
    // Flag to prevent recursive parameter updates
    private var isUpdatingParameters = false
    
    // Parameter properties with reactive updating
    @Published var mass: Double = 1.0 {
        didSet {
            if !isUpdatingParameters {
                updatePhysicsParameters()
            }
        }
    }
    
    @Published var length: Double = 1.0 {
        didSet {
            if !isUpdatingParameters {
                updatePhysicsParameters()
            }
        }
    }
    
    @Published var damping: Double = 0.0 {  // Zero damping to allow completely natural falling
        didSet {
            if !isUpdatingParameters {
                updatePhysicsParameters()
            }
        }
    }
    
    @Published var gravity: Double = 15.0 {  // Increased gravity significantly for more pronounced falling behavior
        didSet {
            if !isUpdatingParameters {
                updatePhysicsParameters()
            }
        }
    }
    
    // Additional parameters that might be needed
    @Published var springConstant: Double = 0.1 {  // Small spring constant for slight stabilization
        didSet {
            if !isUpdatingParameters {
                updatePhysicsParameters()
            }
        }
    }
    
    // Moment of inertia parameter
    @Published var momentOfInertia: Double = 0.5 {  // Default moment of inertia
        didSet {
            if !isUpdatingParameters {
                updatePhysicsParameters()
            }
        }
    }
    
    // Force strength parameter for push buttons
    @Published var forceStrength: Double = 3.0  // Increased force strength but with better control scaling
    
    // Initial perturbation amount (in degrees)
    @Published var initialPerturbation: Double = 15.0  // Default ~15 degrees of initial perturbation
    
    private let simulation = PendulumSimulation()
    var timer: Timer? // Changed from private for use in extensions
    private var multiplierTimer: Timer?
    
    // Reference to the scene for visual updates
    weak var scene: PendulumScene?
    
    // Particle effects delegate
    weak var particleDelegate: PendulumParticleDelegate?
    
    // Core Data manager
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        // Set initial default values before loading from simulation
        // This ensures UI displays non-zero values even before loadInitialParameters completes
        mass = 1.0
        length = 1.0
        damping = 0.4  // Even more damping for better controllability at start
        gravity = 9.81 // Standard gravity
        springConstant = 0.2  // Stronger stabilizing force for easier start
        momentOfInertia = 1.0  // Further increased inertia for more stability
        forceStrength = 3.0    // Higher force strength but with better control scaling
        initialPerturbation = 10.0  // Even smaller initial perturbation for easier start

        // Initial state setup for inverted pendulum - very small perturbation to make it easier to start
        currentState = PendulumState(theta: Double.pi + 0.02, thetaDot: 0, time: 0)

        // Load high score from Core Data
        highScore = coreDataManager.getHighestScore()

        // Setup achievements if needed
        setupAchievements()

        // Set up level manager
        levelManager.delegate = self

        // Initialize based on simulation's defaults
        loadInitialParameters()

        // Get the level configuration from level manager
        applyLevelConfiguration(levelManager.getConfigForLevel(currentLevel))

        // Ensure the simulation has our values
        updateSimulationParameters()

        // Set quasi-periodic mode (Primary mode) as the default
        enableQuasiPeriodicMode()
    }
    
    // MARK: - LevelProgressionDelegate Methods
    
    func didCompleteLevel(_ level: Int, config: LevelConfig) {
        // Celebration animation should be handled in view controller
        print("Level \(level) completed with config: \(config.description)")
    }
    
    func didStartNewLevel(_ level: Int, config: LevelConfig) {
        currentLevel = level
        currentLevelDescription = config.description
        
        // Update the published properties
        balanceThreshold = config.balanceThreshold
        levelSuccessTime = config.balanceRequiredTime
        
        print("Starting level \(level): \(config.description)")
        print("Balance threshold: \(config.balanceThresholdDegrees) degrees")
        print("Required balance time: \(config.balanceRequiredTime) seconds")
    }
    
    func updateDifficultyParameters(config: LevelConfig) {
        // Apply the difficulty parameters from the level configuration
        mass = LevelManager.baseMass * config.massMultiplier
        length = LevelManager.baseLength * config.lengthMultiplier
        damping = config.dampingValue
        gravity = LevelManager.baseGravity * config.gravityMultiplier
        springConstant = config.springConstantValue
        initialPerturbation = config.initialPerturbation
        
        // Update the simulation parameters
        updateSimulationParameters()
        
        print("Updated parameters for level \(config.number):")
        print("Mass: \(mass)")
        print("Length: \(length)")
        print("Damping: \(damping)")
        print("Gravity: \(gravity)")
        print("Spring Constant: \(springConstant)")
        print("Initial Perturbation: \(initialPerturbation) degrees")
    }
    
    private func applyLevelConfiguration(_ config: LevelConfig) {
        // Update level properties
        currentLevel = config.number
        balanceThreshold = config.balanceThreshold
        levelSuccessTime = config.balanceRequiredTime
        currentLevelDescription = config.description
        
        // Update physics parameters
        mass = LevelManager.baseMass * config.massMultiplier
        length = LevelManager.baseLength * config.lengthMultiplier
        damping = config.dampingValue
        gravity = LevelManager.baseGravity * config.gravityMultiplier
        springConstant = config.springConstantValue
        initialPerturbation = config.initialPerturbation
    }
    
    private func setupAchievements() {
        // Initialize achievements in Core Data if needed
        coreDataManager.setupInitialAchievements()
        
        // Load unlocked achievements
        loadUnlockedAchievements()
    }
    
    private func loadUnlockedAchievements() {
        // Get all unlocked achievements from Core Data
        let achievements = coreDataManager.getUnlockedAchievements()
        
        // Track achievement IDs and total points
        unlockedAchievements = achievements.compactMap { $0.value(forKey: "id") as? String }
        achievementPoints = achievements.reduce(0) { result, achievement in
            let points = achievement.value(forKey: "points") as? Int32 ?? 0
            return result + Int(points)
        }
    }
    
    private func loadInitialParameters() {
        // Set flag to prevent recursive updates
        isUpdatingParameters = true
        
        // Get current parameters from the simulation
        let params = simulation.getCurrentParameters()
        
        // Update our published properties with simulation values
        // Only update if values are non-zero to avoid overriding sensible defaults
        if params.mass > 0 { mass = params.mass }
        if params.length > 0 { length = params.length }
        damping = params.damping  // Damping can legitimately be 0
        if params.gravity > 0 { gravity = params.gravity }
        springConstant = params.springConstant  // Spring constant can legitimately be 0
        if params.momentOfInertia > 0 { momentOfInertia = params.momentOfInertia }
        
        print("Loaded initial parameters: mass=\(mass), length=\(length), damping=\(damping), gravity=\(gravity), springConstant=\(springConstant), momentOfInertia=\(momentOfInertia)")
        
        // Clear flag
        isUpdatingParameters = false
    }
    
    private func updatePhysicsParameters() {
        // Use the simulation's parameter update methods
        let wasSimulating = isSimulating
        
        // Temporarily pause simulation during parameter updates
        if wasSimulating {
            stopSimulation()
        }
        
        // Log current parameter values before update for debugging
        print("Updating physics parameters:")
        print("  - Current mass: \(mass)")
        print("  - Current length: \(length)")
        print("  - Current damping: \(damping)")
        print("  - Current gravity: \(gravity)")
        print("  - Current spring constant: \(springConstant)")
        
        // Update the simulation parameters
        simulation.setMass(mass)
        simulation.setLength(length)
        simulation.setDamping(damping)
        simulation.setGravity(gravity)
        simulation.setSpringConstant(springConstant)
        
        // Immediately fetch from simulation to verify parameters were applied
        let verifiedParams = simulation.getCurrentParameters()
        print("Verified parameters from simulation:")
        print("  - Verified mass: \(verifiedParams.mass)")
        print("  - Verified length: \(verifiedParams.length)")
        print("  - Verified damping: \(verifiedParams.damping)")
        print("  - Verified gravity: \(verifiedParams.gravity)")
        print("  - Verified spring constant: \(verifiedParams.springConstant)")
        
        // Restart the simulation if it was running
        if wasSimulating {
            startSimulation()
        }
        
        // Update the scene to reflect new pendulum physics (especially length)
        scene?.updatePendulumAppearance()
    }
    
    func startGame() {
        // Start a new play session in Core Data
        currentSessionId = coreDataManager.startPlaySession()
        
        // Start analytics tracking for this session
        if let sessionId = currentSessionId {
            AnalyticsManager.shared.startTracking(for: sessionId)
        }
        
        // Start session time tracking
        SessionTimeManager.shared.startSession()
        
        // Reset game state
        score = 0
        gameOverReason = nil
        isGameActive = true
        isPaused = false
        balanceStartTime = Date()
        lastScoreUpdate = Date()
        totalBalanceTime = 0
        consecutiveBalanceTime = 0
        
        // Reset score multiplier
        scoreMultiplier = 1.0
        multiplierTimeRemaining = 0.0
        perfectBalanceStreak = 0
        
        // Reset achievement tracking for this session
        lastForcePressTime = Date()
        maxAngleRecovered = 0.0
        
        // Reset to level 1
        levelManager.resetToLevel1()
        
        // Get level configuration
        let config = levelManager.getConfigForLevel(1)
        
        // Initialize stats dictionary
        levelStats = [
            "currentLevel": 1.0,
            "levelsCompleted": 0.0,
            "maxAngle": 0.0,
            "currentAngle": 0.0,
            "lastAttemptTime": 0.0
        ]
        
        // Create an initial perturbation based on the level configuration
        let degreesOffset = config.initialPerturbation
        let radianOffset = degreesOffset * Double.pi / 180.0
        
        // Randomly decide left or right tilt
        let direction: Double = Bool.random() ? 1.0 : -1.0
        
        // Calculate initial theta (start position) and thetaDot (velocity)
        let initialTheta = Double.pi + (direction * radianOffset) // Offset from vertical
        let initialThetaDot = direction * radianOffset * 0.02 // Small initial velocity
        
        // Create the pendulum state with random oscillation
        currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
        
        // Get a handle to the simulation and force it to use our state
        simulation.setInitialState(state: currentState)
        
        // Display level
        gameOverReason = "Level \(currentLevel): \(config.description)"
        
        // Record game start in analytics
        if let sessionId = currentSessionId {
            let normalizedFromVertical = normalizeAngle(initialTheta - Double.pi)
            AnalyticsManager.shared.trackInteraction(
                eventType: "game_start",
                angle: normalizedFromVertical,
                angleVelocity: initialThetaDot,
                magnitude: degreesOffset,
                direction: direction > 0 ? "right" : "left"
            )
        }
        
        // Print debug info
        print("Starting game with perturbation:")
        print("Direction: \(direction > 0 ? "right" : "left")")
        print("Perturbation: \(degreesOffset) degrees (\(radianOffset) radians)")
        print("Initial position: theta = \(initialTheta) (\(initialTheta * 180/Double.pi - 180) degrees from vertical)")
        print("Initial velocity: thetaDot = \(initialThetaDot)")
        print("Balance threshold: \(balanceThreshold) radians (\(balanceThreshold * 180/Double.pi) degrees)")
        print("Failure threshold: \(failureAngleThreshold) radians (\(failureAngleThreshold * 180/Double.pi) degrees)")
        print("Level success time: \(levelSuccessTime) seconds")
        
        // Start simulation, but delay the game over check for a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.startSimulation()
        }
    }
    
    // Function called when a level is completed successfully
    private func levelCompleted() {
        // Check achievement: reach level X
        checkLevelAchievements()

        // Add bonus points for completing level
        let levelBonus = currentLevel * 100
        score += levelBonus

        // Show bonus points notification
        print("Level \(currentLevel) completed! Bonus: \(levelBonus) points")

        // Reset consecutive balance time
        consecutiveBalanceTime = 0

        // Update stats
        levelStats["levelsCompleted"] = Double(currentLevel)
        levelStats["currentLevel"] = Double(currentLevel)

        // Increment total levels completed counter for stats
        totalLevelsCompleted += 1
        levelStats["totalLevelsCompleted"] = Double(totalLevelsCompleted)
        
        // Increment total completions counter (for particle effects)
        totalCompletions += 1

        // Update Core Data session
        if let sessionId = currentSessionId {
            coreDataManager.updatePlaySession(
                sessionId: sessionId,
                score: score,
                level: currentLevel,
                duration: totalBalanceTime,
                maxAngle: maxAngleRecovered
            )
        }

        // Don't announce level completion - players can see their progress

        // Brief pause before starting new level
        let wasSimulating = isSimulating
        stopSimulation()

        // Store completed level for celebration
        let completedLevel = currentLevel
        
        // Show level completion effect using new ViewControllerParticleSystem
        if let delegate = particleDelegate {
            delegate.showLevelCompletionParticles(level: totalCompletions)
        } else {
            // Fallback to SpriteKit scene effect
            self.scene?.showLevelCompletionEffect(at: nil, level: totalCompletions)
        }

        // Handle level progression based on game mode
        if isQuasiPeriodicMode {
            // In quasi-periodic mode, we reset to level 1 after completion
            // This allows the player to keep completing the same level and tracking stats
            handleQuasiPeriodicLevelCompletion()
        } else if isProgressiveMode {
            // In progressive mode, we advance to next level with increasing difficulty
            handleProgressiveLevelCompletion()
        } else {
            // In standard mode, just advance to next level
            levelManager.advanceToNextLevel()

            // Get the config for the next level
            let nextLevelConfig = levelManager.getConfigForLevel(currentLevel)

            // Show level completion animation and start new level - with faster transitions
            if let sceneView = self.scene?.view {
                // Particle effect already shown in levelCompleted()

                sceneView.levelCompletionAnimation {
                    // After completion animation finishes, show new level intro
                    // No new level effect needed - the explosion is sufficient

                    sceneView.newLevelStartAnimation(
                        level: self.currentLevel,
                        description: nextLevelConfig.description
                    ) {
                        // After the new level intro finishes, start the new level

                        // Create a new perturbed state with increased difficulty from config
                        let degreesOffset = nextLevelConfig.initialPerturbation
                        let radianOffset = degreesOffset * Double.pi / 180.0
                        let direction = Bool.random() ? 1.0 : -1.0
                        let initialTheta = Double.pi + (direction * radianOffset)
                        let initialThetaDot = direction * radianOffset * 0.05  // Increased initial velocity for higher levels

                        // Reset to new level state
                        self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
                        self.simulation.setInitialState(state: self.currentState)

                        // Update game over message to show current level
                        self.gameOverReason = "Level \(self.currentLevel): \(nextLevelConfig.description)"

                        // Start new level
                        if wasSimulating {
                            self.startSimulation()
                        }
                    }
                }
            } else {
                // Fallback if no scene view available - just restart after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    guard let self = self else { return }

                    // Get the next level configuration
                    let config = self.levelManager.getConfigForLevel(self.currentLevel)

                    // Create a new perturbed state with increased difficulty from config
                    let degreesOffset = config.initialPerturbation
                    let radianOffset = degreesOffset * Double.pi / 180.0
                    let direction = Bool.random() ? 1.0 : -1.0
                    let initialTheta = Double.pi + (direction * radianOffset)
                    let initialThetaDot = direction * radianOffset * 0.05  // Increased initial velocity for higher levels

                    // Reset to new level state
                    self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
                    self.simulation.setInitialState(state: self.currentState)

                    // Update game over message to show current level
                    self.gameOverReason = "Level \(self.currentLevel): \(config.description)"

                    // Start new level
                    if wasSimulating {
                        self.startSimulation()
                    }
                }
            }
        }
    }
    
    func endGame(reason: String) {
        // If not already ended
        if isGameActive {
            isGameActive = false
            isPaused = false
            gameOverReason = reason
            stopSimulation()
            
            // Update high score if needed
            if score > highScore {
                highScore = score
                
                // Save high score to Core Data
                coreDataManager.saveHighScore(
                    score: score,
                    level: currentLevel,
                    timeBalanced: totalBalanceTime
                )
            }
            
            // Reset level on game end
            levelStats["finalLevel"] = Double(currentLevel)
            levelStats["finalScore"] = Double(score)
            
            // Record game end in analytics
            if let sessionId = currentSessionId {
                // Calculate normalized angle from vertical
                let normalizedFromVertical = normalizeAngle(currentState.theta - Double.pi)
                
                // Track game end in analytics
                AnalyticsManager.shared.trackInteraction(
                    eventType: "game_end",
                    angle: normalizedFromVertical,
                    angleVelocity: currentState.thetaDot,
                    magnitude: 0.0,
                    direction: "none"
                )
                
                // Calculate and save final analytics metrics
                AnalyticsManager.shared.calculateAndSavePerformanceMetrics(for: sessionId)
                
                // Stop analytics tracking
                AnalyticsManager.shared.stopTracking()
            }
            
            // End session time tracking
            SessionTimeManager.shared.endSession()
            
            // Update Core Data session
            if let sessionId = currentSessionId {
                coreDataManager.updatePlaySession(
                    sessionId: sessionId,
                    score: score,
                    level: currentLevel,
                    duration: totalBalanceTime,
                    maxAngle: maxAngleRecovered
                )
                
                // End session with unlocked achievements
                coreDataManager.endPlaySession(
                    sessionId: sessionId,
                    achievements: unlockedAchievements
                )
            }
            
            // Reset level for next game
            levelManager.resetToLevel1()
            let config = levelManager.getConfigForLevel(1)
            applyLevelConfiguration(config)
        }
    }
    
    // Toggle pause state
    func togglePause() {
        if isGameActive {
            if isPaused {
                resumeGame()
            } else {
                pauseGame()
            }
        }
    }
    
    // Pause the current game
    func pauseGame() {
        if isGameActive && !isPaused {
            isPaused = true
            stopSimulation() // Stop the timer
            gameOverReason = "Game Paused"
            
            // Pause session time tracking
            SessionTimeManager.shared.pauseSession()
        }
    }
    
    // Resume from pause
    func resumeGame() {
        if isGameActive && isPaused {
            isPaused = false
            gameOverReason = nil
            startSimulation() // Restart the timer
            
            // Resume session time tracking
            SessionTimeManager.shared.resumeSession()
        }
    }
    
    // Helper to normalize angle to [-π, π]
    private func normalizeAngle(_ angle: Double) -> Double {
        return atan2(sin(angle), cos(angle))
    }
    
    func startSimulation() {
        // If there's already a timer running, invalidate it first to prevent multiple timers
        stopSimulation()
        
        // Now start a fresh timer
        isSimulating = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true) { [weak self] _ in
            self?.step()
        }
        
        // Resume perturbations if they were stopped
        NotificationCenter.default.post(name: NSNotification.Name("ResumeAllPerturbations"), object: nil)
    }
    
    private func step() {
        // Step the simulation
        currentState = simulation.step()
        simulationError = simulation.compareWithReference()
        
        // Update score multiplier time remaining
        if multiplierTimeRemaining > 0 {
            multiplierTimeRemaining -= 0.002 // Same as simulation step time
            if multiplierTimeRemaining <= 0 {
                scoreMultiplier = 1.0
                multiplierTimeRemaining = 0
            }
        }
        
        // Add game logic
        if isGameActive && !isPaused {
            // Calculate angle from top position (π) in a simple, reliable way
            // Break down the normalization calculation into steps
            let twoPi = 2 * Double.pi
            let modResult = currentState.theta.truncatingRemainder(dividingBy: twoPi)
            let positiveMod = modResult + twoPi
            let normalizedAngle = positiveMod.truncatingRemainder(dividingBy: twoPi)
            
            // Then find the shortest distance to π
            let diffFromPi = abs(normalizedAngle - Double.pi)
            let altDiffFromPi = twoPi - diffFromPi
            let angleFromTop = min(diffFromPi, altDiffFromPi)
            
            // Track angle in analytics system
            if let sessionId = currentSessionId {
                // Calculate angle from vertical (normalization handling different from angle from top)
                let normalizedFromVertical = normalizeAngle(currentState.theta - Double.pi)
                
                // Track current pendulum state in analytics
                AnalyticsManager.shared.trackPendulumState(
                    angle: normalizedFromVertical,
                    angleVelocity: currentState.thetaDot
                )
            }
            
            // Track achievements
            checkForAchievements(currentAngle: currentState.theta, previousAngle: previousAngle)
            previousAngle = currentState.theta
            
            // Track max angle for recovery achievement
            if angleFromTop > maxAngleRecovered && angleFromTop < failureAngleThreshold {
                maxAngleRecovered = angleFromTop
            }
            
            // Print debug info occasionally - reduced frequency
            if Int(currentState.time * 100) % 200 == 0 {  // Every 2 seconds instead of 0.5 seconds
                print("Time: \(String(format: "%.2f", currentState.time)), " +
                      "Angle: \(String(format: "%.2f", normalizedAngle)), " +
                      "From Top: \(String(format: "%.2f", angleFromTop))")
            }
            
            // Check for fallen state, but only after allowing time to get started
            if currentState.time > 0.5 && angleFromTop > failureAngleThreshold {
                // Pendulum has fallen too far from vertical
                print("FALLEN! Angle from top: \(angleFromTop), threshold: \(failureAngleThreshold)")
                
                // Track this fall in analytics before ending game
                if let sessionId = currentSessionId {
                    let normalizedFromVertical = normalizeAngle(currentState.theta - Double.pi)
                    AnalyticsManager.shared.trackInteraction(
                        eventType: "fall",
                        angle: normalizedFromVertical,
                        angleVelocity: currentState.thetaDot,
                        magnitude: 0.0,
                        direction: normalizedFromVertical > 0 ? "right" : "left"
                    )
                }
                
                endGame(reason: "Pendulum Fell")
                
                // Update stats for dashboard
                let failTime = Date().timeIntervalSince(balanceStartTime ?? Date())
                levelStats["lastAttemptTime"] = failTime
                levelStats["maxAngle"] = Double(angleFromTop)
                
                // Reset consecutive balance time
                consecutiveBalanceTime = 0
                
            } else if angleFromTop < balanceThreshold {
                // Pendulum is balanced near vertical
                if let lastUpdate = lastScoreUpdate, Date().timeIntervalSince(lastUpdate) >= scoreUpdateInterval {
                    // Check for perfect balance (closer to vertical)
                    let isPerfectBalance = angleFromTop < perfectBalanceThreshold

                    // Update perfect balance streak
                    if isPerfectBalance {
                        perfectBalanceStreak += 1

                        // Show balance particle effect every 5 perfect balances
                        if perfectBalanceStreak % 5 == 0 {
                            scene?.showBalanceEffect()
                        }
                        
                        // Increase multiplier when reaching streak thresholds
                        if perfectBalanceStreak % 10 == 0 {
                            // Increase multiplier at 10, 20, 30... consecutive perfect balances
                            increaseMultiplier(0.25) // Add 0.25x each time (1.25x, 1.5x, 1.75x...)
                            
                            // Track perfect balance streak milestone in analytics
                            if let sessionId = currentSessionId {
                                let normalizedFromVertical = normalizeAngle(currentState.theta - Double.pi)
                                AnalyticsManager.shared.trackInteraction(
                                    eventType: "perfect_streak_\(perfectBalanceStreak)",
                                    angle: normalizedFromVertical,
                                    angleVelocity: currentState.thetaDot,
                                    magnitude: 0.0,
                                    direction: "none"
                                )
                            }
                        }
                    } else {
                        // Not perfect - reset streak only if we drop below regular balance
                        perfectBalanceStreak = 0
                    }
                    
                    // Update score based on balance quality - how close to perfectly vertical
                    let balanceQuality = 1.0 - (angleFromTop / balanceThreshold)
                    let basePoints = Int(10 * balanceQuality)
                    let pointsToAdd = Int(Double(basePoints) * scoreMultiplier)
                    score += pointsToAdd
                    
                    // Update balance time
                    totalBalanceTime += scoreUpdateInterval
                    lastScoreUpdate = Date()
                    
                    // Accumulate consecutive balance time
                    consecutiveBalanceTime += scoreUpdateInterval
                    
                    // Update stats
                    levelStats["currentAngle"] = Double(angleFromTop)
                    
                    // Check time balance achievements
                    if totalBalanceTime >= 5.0 && !unlockedAchievements.contains("balance_5sec") {
                        unlockAchievement(id: "balance_5sec")
                    }
                    if totalBalanceTime >= 30.0 && !unlockedAchievements.contains("balance_30sec") {
                        unlockAchievement(id: "balance_30sec")
                    }
                    if totalBalanceTime >= 60.0 && !unlockedAchievements.contains("balance_60sec") {
                        unlockAchievement(id: "balance_60sec")
                    }
                    
                    // Check if level is completed
                    if consecutiveBalanceTime >= levelSuccessTime {
                        // Check for quick level achievement
                        if levelSuccessTime - consecutiveBalanceTime < 10.0 && !unlockedAchievements.contains("quick_level") {
                            unlockAchievement(id: "quick_level")
                        }

                        // Show an additional balance effect on level completion
                        scene?.showBalanceEffect()

                        // Track level completion in analytics
                        if let sessionId = currentSessionId {
                            let normalizedFromVertical = normalizeAngle(currentState.theta - Double.pi)
                            AnalyticsManager.shared.trackInteraction(
                                eventType: "level_complete_\(currentLevel)",
                                angle: normalizedFromVertical,
                                angleVelocity: currentState.thetaDot,
                                magnitude: 0.0,
                                direction: "none"
                            )
                        }
                        
                        levelCompleted()
                    }
                    
                    // Check for no push time
                    if let lastForce = lastForcePressTime, Date().timeIntervalSince(lastForce) >= 10.0 && !unlockedAchievements.contains("no_push_10sec") {
                        unlockAchievement(id: "no_push_10sec")
                    }
                }
            } else {
                // Not balanced - reset consecutive balance time
                consecutiveBalanceTime = 0
                perfectBalanceStreak = 0
                
                // Check recovery achievement - if we recovered from a steep angle (more than 45 degrees)
                if angleFromTop < balanceThreshold && maxAngleRecovered > 0.8 && !unlockedAchievements.contains("perfect_recovery") {
                    unlockAchievement(id: "perfect_recovery")
                    
                    // Track recovery in analytics
                    if let sessionId = currentSessionId {
                        let normalizedFromVertical = normalizeAngle(currentState.theta - Double.pi)
                        AnalyticsManager.shared.trackInteraction(
                            eventType: "recovery",
                            angle: normalizedFromVertical,
                            angleVelocity: currentState.thetaDot,
                            magnitude: maxAngleRecovered,
                            direction: normalizedFromVertical > 0 ? "right" : "left"
                        )
                    }
                }
            }
            
            // Check for score-based achievements
            checkScoreAchievements()
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
        
        // Ensure pendulum completely stops
        currentState = PendulumState(theta: currentState.theta, thetaDot: 0, time: currentState.time)
        simulation.setInitialState(state: currentState)
        
        // Stop any ongoing perturbations
        NotificationCenter.default.post(name: NSNotification.Name("StopAllPerturbations"), object: nil)
    }
    
    func applyForce(_ magnitude: Double) {
        print("*** FORCE BUTTON PRESSED ***")
        
        // Update last force press time for achievements
        lastForcePressTime = Date()
        
        // If game is not active but there's a game over reason, restart on push
        if !isGameActive && gameOverReason != nil {
            print("Game not active, restarting...")
            resetAndStart()
            return
        }
        
        // If game is paused, resume it
        if isPaused {
            resumeGame()
            return
        }
        
        // If game is not active for other reasons, start it
        if !isGameActive {
            print("Game not active, starting...")
            startGame()
            return // Return here to avoid applying force during game start
        }
        
        // Apply external force using the adjustable force strength parameter
        let scaledMagnitude = magnitude * forceStrength
        
        print("BEFORE force application - theta: \(currentState.theta), thetaDot: \(currentState.thetaDot)")
        print("Applying force: \(scaledMagnitude) to pendulum with current velocity \(currentState.thetaDot)")
        
        // Apply force directly to the simulation
        simulation.applyExternalForce(magnitude: scaledMagnitude)
        
        // Record when force was last applied
        lastForceAppliedTime = currentState.time
        
        // Update our cached state to match simulation WITHOUT adding force again
        // The simulation already applied the force to thetaDot
        let newState = PendulumState(
            theta: currentState.theta,
            thetaDot: currentState.thetaDot,  // Don't add scaledMagnitude again
            time: currentState.time
        )
        currentState = newState
        
        // Track interaction in analytics system
        if let sessionId = currentSessionId {
            // Determine direction based on the sign of magnitude
            let direction = magnitude > 0 ? "left" : "right"
            
            // Calculate angle from vertical (in radians)
            let normalizedAngle = normalizeAngle(currentState.theta - Double.pi)
            
            // Track this push in the analytics system
            AnalyticsManager.shared.trackInteraction(
                eventType: "push",
                angle: normalizedAngle,
                angleVelocity: currentState.thetaDot,
                magnitude: abs(scaledMagnitude),
                direction: direction
            )
        }
        
        print("AFTER force application - theta: \(currentState.theta), thetaDot: \(currentState.thetaDot)")
        
        // Track force efficiency for achievements
        let angleFromVertical = abs(normalizeAngle(currentState.theta - Double.pi))
        let isImprovement = angleFromVertical < 0.3 // Within reasonable balance
        achievementManager.trackForceEfficiency(
            force: abs(scaledMagnitude),
            improvement: isImprovement,
            level: levelManager.currentLevel
        )
    }
    
    // normalizeAngle is already defined above
    
    func reset() {
        // Stop any existing simulation first
        stopSimulation()
        
        // Cancel multiplier timer
        multiplierTimer?.invalidate()
        multiplierTimer = nil
        
        // Reset to initial state for inverted pendulum
        currentState = PendulumState(theta: Double.pi + 0.1, thetaDot: 0, time: 0)
        simulationError = 0
        
        // Reset game state
        score = 0
        gameOverReason = nil
        isGameActive = false
        isPaused = false
        totalBalanceTime = 0
        
        // Reset score multiplier
        scoreMultiplier = 1.0
        multiplierTimeRemaining = 0.0
        perfectBalanceStreak = 0
        
        // Reset to level 1
        levelManager.resetToLevel1()
        
        // Get level 1 configuration
        let config = levelManager.getConfigForLevel(1)
        
        // Apply level 1 configuration
        applyLevelConfiguration(config)
        
        // Make sure simulation has latest parameter values
        updateSimulationParameters()
        
        print("Reset to level 1:")
        print("Balance threshold: \(balanceThreshold * 180 / Double.pi) degrees")
        print("Level success time: \(levelSuccessTime) seconds")
        print("Mass: \(mass)")
        print("Length: \(length)")
        print("Damping: \(damping)")
        print("Gravity: \(gravity)")
        print("Spring constant: \(springConstant)")
    }
    
    // Reset and immediately start a new game
    func resetAndStart() {
        reset()
        startGame()
    }
    
    // Method to update the initial perturbation parameter
    func setInitialPerturbation(_ perturbation: Double) {
        initialPerturbation = perturbation
        print("Set initial perturbation to \(initialPerturbation) degrees")
    }
    
    // Method to update the force strength parameter
    func setForceStrength(_ strength: Double) {
        forceStrength = strength
        print("Set force strength to \(forceStrength)")

        // Immediately update any running simulations
        if isSimulating {
            // Force a parameter update to active simulation
            updateSimulationParameters()
        }
    }

    // MARK: - Game Mode Methods

    /// Enables quasi-periodic mode (Primary mode)
    /// In this mode, the player resets to level 1 after completion, but we track total levels beaten
    func enableQuasiPeriodicMode() {
        isQuasiPeriodicMode = true
        isProgressiveMode = false

        // Reset to level 1
        levelManager.resetToLevel1()

        // Don't show repetitive mode message - players know they selected Primary mode

        // Ensure current display reflects Level 1
        currentLevel = 1

        // Increase the initial perturbation to prevent auto-balancing
        initialPerturbation = 15.0 // Make the pendulum start further from vertical
    }

    /// Handles level completion in quasi-periodic mode (Primary mode)
    private func handleQuasiPeriodicLevelCompletion() {
        // Reset to level 1
        levelManager.resetToLevel1()

        // Show enhanced celebration animation
        if let sceneView = self.scene?.view {
            // Customized animation for quasi-periodic mode
            // Particle effect already shown in levelCompleted()

            sceneView.levelCompletionAnimation {
                // Show a customized message with total levels completed
                // No new level effect needed - the explosion is sufficient

                sceneView.newLevelStartAnimation(
                    level: 1,
                    description: "Total Levels Completed: \(self.totalLevelsCompleted)"
                ) {
                    // After animation, restart level 1
                    let config = self.levelManager.getConfigForLevel(1)

                    // Create a new perturbed state for level 1
                    let degreesOffset = config.initialPerturbation
                    let radianOffset = degreesOffset * Double.pi / 180.0
                    let direction = Bool.random() ? 1.0 : -1.0
                    let initialTheta = Double.pi + (direction * radianOffset)
                    let initialThetaDot = direction * radianOffset * 0.02

                    // Reset to level 1 state
                    self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
                    self.simulation.setInitialState(state: self.currentState)

                    // Don't show mode status - players can see this in the UI

                    // Start simulation
                    self.startSimulation()
                }
            }
        } else {
            // Fallback if no scene view - just restart after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self = self else { return }

                let config = self.levelManager.getConfigForLevel(1)

                // Create a new perturbed state for level 1
                let degreesOffset = config.initialPerturbation
                let radianOffset = degreesOffset * Double.pi / 180.0
                let direction = Bool.random() ? 1.0 : -1.0
                let initialTheta = Double.pi + (direction * radianOffset)
                let initialThetaDot = direction * radianOffset * 0.02

                // Reset to level 1 state
                self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
                self.simulation.setInitialState(state: self.currentState)

                // Don't show mode status - players can see this in the UI

                // Start simulation
                self.startSimulation()
            }
        }
    }

    /// Enables progressive difficulty mode (Progressive mode)
    /// In this mode, difficulty continuously increases with each level completion
    func enableProgressiveMode() {
        isProgressiveMode = true
        isQuasiPeriodicMode = false

        // Reset to level 1
        levelManager.resetToLevel1()

        // Don't show repetitive mode message - players know they selected Progressive mode

        // Ensure current display reflects Level 1
        currentLevel = 1
    }

    /// Handles level completion in progressive mode
    private func handleProgressiveLevelCompletion() {
        // Advance to next level with increased difficulty
        levelManager.advanceToNextLevel()

        // Get the next level configuration
        let nextLevelConfig = levelManager.getConfigForLevel(currentLevel)

        // Show enhanced celebration animation
        if let sceneView = self.scene?.view {
            // Customized animation for progressive mode
            // Particle effect already shown in levelCompleted()

            sceneView.levelCompletionAnimation {
                // Show a level intro with progressive mode indicator
                // No new level effect needed - the explosion is sufficient

                sceneView.newLevelStartAnimation(
                    level: self.currentLevel,
                    description: nextLevelConfig.description + " (Progressive)"
                ) {
                    // After animation, start the new level

                    // Create a new perturbed state with increased difficulty from config
                    let degreesOffset = nextLevelConfig.initialPerturbation
                    let radianOffset = degreesOffset * Double.pi / 180.0
                    let direction = Bool.random() ? 1.0 : -1.0
                    let initialTheta = Double.pi + (direction * radianOffset)
                    let initialThetaDot = direction * radianOffset * 0.05  // Increased initial velocity for higher levels

                    // Reset to new level state
                    self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
                    self.simulation.setInitialState(state: self.currentState)

                    // Don't show mode status - players can see this in the UI

                    // Start simulation
                    self.startSimulation()
                }
            }
        } else {
            // Fallback if no scene view - just restart after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self = self else { return }

                // Create a new perturbed state with increased difficulty from config
                let degreesOffset = nextLevelConfig.initialPerturbation
                let radianOffset = degreesOffset * Double.pi / 180.0
                let direction = Bool.random() ? 1.0 : -1.0
                let initialTheta = Double.pi + (direction * radianOffset)
                let initialThetaDot = direction * radianOffset * 0.05  // Increased initial velocity for higher levels

                // Reset to new level state
                self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
                self.simulation.setInitialState(state: self.currentState)

                // Update game message
                // Don't show mode status - players can see this in the UI

                // Start simulation
                self.startSimulation()
            }
        }
    }

    /// Reset to level 1 while keeping statistics (for Primary mode)
    func resetToLevel1KeepingStats() {
        // Enable quasi-periodic mode
        enableQuasiPeriodicMode()

        // Reset game state but don't reset totalLevelsCompleted
        resetGame(resetStats: false)
    }

    /// Reset to level 1 with progressive difficulty (for Progressive mode)
    func resetToLevel1WithProgressiveDifficulty() {
        // Enable progressive mode
        enableProgressiveMode()

        // Reset game state
        resetGame()
    }

    /// Reset game state, optionally preserving statistics
    func resetGame(resetStats: Bool = true) {
        // Reset game state
        score = 0
        consecutiveBalanceTime = 0

        // Reset the level to 1
        levelManager.resetToLevel1()

        // Clear phase space tracking
        scene?.clearPhaseSpace()

        // Reset total stats only if requested
        if resetStats {
            totalLevelsCompleted = 0
            totalBalanceTime = 0
            levelStats = [:]
            // Don't reset totalCompletions to keep color variety across sessions
            // User will see new colors even when restarting
        }

        // Reset the pendulum to a slightly perturbed upright position
        let initialTheta = Double.pi + 0.1
        currentState = PendulumState(theta: initialTheta, thetaDot: 0, time: 0)
        simulation.setInitialState(state: currentState)
    }
    
    // Apply parameter changes immediately to active simulation
    // This is now public so it can be called from the ViewController
    func updateSimulationParameters() {
        simulation.setMass(mass)
        simulation.setLength(length)
        simulation.setDamping(damping)
        simulation.setGravity(gravity)
        simulation.setSpringConstant(springConstant)
        simulation.setMomentOfInertia(momentOfInertia)
        
        // Log that parameters were directly updated
        print("Parameters directly updated through updateSimulationParameters()")
    }
    
    // Method to update multiple parameters at once without triggering multiple updates
    func updateAllParameters(mass: Double? = nil, 
                           length: Double? = nil, 
                           damping: Double? = nil, 
                           gravity: Double? = nil, 
                           springConstant: Double? = nil,
                           momentOfInertia: Double? = nil) {
        isUpdatingParameters = true
        
        if let mass = mass { self.mass = mass }
        if let length = length { self.length = length }
        if let damping = damping { self.damping = damping }
        if let gravity = gravity { self.gravity = gravity }
        if let springConstant = springConstant { self.springConstant = springConstant }
        if let momentOfInertia = momentOfInertia { self.momentOfInertia = momentOfInertia }
        
        isUpdatingParameters = false
        updatePhysicsParameters()
    }
    
    // MARK: - Score Multiplier System
    
    private func increaseMultiplier(_ amount: Double) {
        // Add to current multiplier
        scoreMultiplier = min(scoreMultiplier + amount, 3.0) // Cap at 3x
        
        // Set duration for multiplier (10 seconds)
        multiplierTimeRemaining = 10.0
        
        print("Score multiplier increased to \(scoreMultiplier)x for 10 seconds")
    }
    
    // MARK: - Achievement System
    
    private func unlockAchievement(id: String) {
        // Check if achievement already unlocked
        if unlockedAchievements.contains(id) {
            return
        }
        
        // Try to unlock via Core Data
        if coreDataManager.unlockAchievement(id: id) {
            // Success - add to our local list
            unlockedAchievements.append(id)
            
            // Get achievement details for display
            let achievements = coreDataManager.getAllAchievements()
            if let achievement = achievements.first(where: { ($0.value(forKey: "id") as? String) == id }) {
                // Update achievement points
                let points = achievement.value(forKey: "points") as? Int32 ?? 0
                achievementPoints += Int(points)
                
                // Store achievement info for UI display
                let name = achievement.value(forKey: "name") as? String ?? "Achievement Unlocked"
                let description = achievement.value(forKey: "achievementDescription") as? String ?? ""
                recentAchievement = (name, description)
                
                // Show achievement notification
                print("Achievement unlocked: \(name) - \(description)")

                // Show achievement particle effect using new ViewControllerParticleSystem
                if let delegate = particleDelegate {
                    delegate.showAchievementParticles()
                } else {
                    // Fallback to scene-based effect
                    scene?.showAchievementEffect()
                }

                // Add bonus points for achievement
                let bonusPoints = Int(points) * 10
                score += bonusPoints
                print("Achievement bonus: +\(bonusPoints) points")
                
                // Clear achievement notification after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    self?.recentAchievement = nil
                }
            }
        }
    }
    
    private func checkScoreAchievements() {
        // Check score-based achievements
        if score >= 500 && !unlockedAchievements.contains("score_500") {
            unlockAchievement(id: "score_500")
        }
        if score >= 1000 && !unlockedAchievements.contains("score_1000") {
            unlockAchievement(id: "score_1000")
        }
        if score >= 5000 && !unlockedAchievements.contains("score_5000") {
            unlockAchievement(id: "score_5000")
        }
    }
    
    private func checkLevelAchievements() {
        // Check level-based achievements
        if currentLevel >= 3 && !unlockedAchievements.contains("reach_level_3") {
            unlockAchievement(id: "reach_level_3")
        }
        if currentLevel >= 5 && !unlockedAchievements.contains("reach_level_5") {
            unlockAchievement(id: "reach_level_5")
        }
        if currentLevel >= 10 && !unlockedAchievements.contains("reach_level_10") {
            unlockAchievement(id: "reach_level_10")
        }
    }
    
    // MARK: - High Score Methods
    
    func getTopHighScores(count: Int = 10) -> [(String, Int, Int, TimeInterval)] {
        let scores = coreDataManager.getTopHighScores(limit: count)
        return scores.map { 
            ($0.playerName ?? "Player", Int($0.score), Int($0.level), $0.timeBalanced)
        }
    }
    
    func saveHighScore(playerName: String = "Player") {
        coreDataManager.saveHighScore(
            score: score,
            level: currentLevel,
            timeBalanced: totalBalanceTime,
            playerName: playerName
        )
    }
    
    // MARK: - Achievement Tracking
    
    private func checkForAchievements(currentAngle: Double, previousAngle: Double) {
        // Only check achievements every 0.1 seconds to avoid spam
        let now = Date()
        guard now.timeIntervalSince(lastAchievementCheck) >= 0.1 else { return }
        lastAchievementCheck = now
        
        let currentAngleFromVertical = abs(normalizeAngle(currentAngle - Double.pi))
        let previousAngleFromVertical = abs(normalizeAngle(previousAngle - Double.pi))
        
        // Track recovery achievements
        if previousAngleFromVertical > currentAngleFromVertical + 0.3 && currentAngleFromVertical < 0.3 {
            achievementManager.trackRecovery(
                fromAngle: previousAngle,
                toAngle: currentAngle,
                level: levelManager.currentLevel
            )
        }
        
        // Track balance achievements
        achievementManager.trackBalance(
            angle: currentAngle,
            time: now,
            level: levelManager.currentLevel
        )
        
        // Track improvement (stability score)
        let currentStability = calculateStabilityScore()
        achievementManager.trackImprovement(
            currentScore: currentStability,
            level: levelManager.currentLevel
        )
    }
    
    private func calculateStabilityScore() -> Double {
        // Simple stability calculation based on current angle
        let angleFromVertical = abs(normalizeAngle(currentState.theta - Double.pi))
        let maxAngle = 1.5 // ~86 degrees
        let stability = max(0, (maxAngle - angleFromVertical) / maxAngle * 100)
        return stability
    }
}