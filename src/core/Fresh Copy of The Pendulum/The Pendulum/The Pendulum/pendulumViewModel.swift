// PendulumViewModel.swift
import SwiftUI
import SpriteKit

class PendulumViewModel: ObservableObject {
    @Published var currentState = PendulumState(theta: Double.pi + 0.1, thetaDot: 0, time: 0)
    @Published var simulationError: Double = 0
    @Published var isSimulating = false // Changed from isRunning to isSimulating
    
    // Game state properties
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var isGameActive: Bool = false
    @Published var gameOverReason: String?
    @Published var balanceStartTime: Date?
    @Published var totalBalanceTime: TimeInterval = 0
    
    // Level system properties
    @Published var currentLevel: Int = 1
    @Published var levelPerturbation: Double = 0.1
    @Published var consecutiveBalanceTime: TimeInterval = 0 // Time spent continuously balanced
    @Published var levelSuccessTime: TimeInterval = 3.0 // Time required to pass a level (seconds)
    @Published var levelStats: [String: Double] = [:] // Statistics for dashboard
    
    // Constants for balance detection
    private let balanceAngleThreshold = 0.15  // Radians from vertical considered "balanced" (~8.6 degrees)
    private let failureAngleThreshold = 1.57  // Radians from vertical considered "fallen" (~90 degrees)
    private let scoreUpdateInterval: TimeInterval = 0.1  // How often to update score
    private var lastScoreUpdate: Date?
    private var lastForceAppliedTime: Double = 0
    
    // Parameter properties with reactive updating
    @Published var mass: Double = 1.0 {
        didSet {
            updatePhysicsParameters()
        }
    }
    
    @Published var length: Double = 1.0 {
        didSet {
            updatePhysicsParameters()
        }
    }
    
    @Published var damping: Double = 0.0 {  // Zero damping to allow completely natural falling
        didSet {
            updatePhysicsParameters()
        }
    }
    
    @Published var gravity: Double = 15.0 {  // Increased gravity significantly for more pronounced falling behavior
        didSet {
            updatePhysicsParameters()
        }
    }
    
    // Additional parameters that might be needed
    @Published var springConstant: Double = 0.1 {  // Small spring constant for slight stabilization
        didSet {
            updatePhysicsParameters()
        }
    }
    
    // Moment of inertia parameter
    @Published var momentOfInertia: Double = 0.5 {  // Default moment of inertia
        didSet {
            updatePhysicsParameters()
        }
    }
    
    // Force strength parameter for push buttons
    @Published var forceStrength: Double = 5.0  // Further increased force strength for immediate visual effect
    
    // Initial perturbation amount (in degrees)
    @Published var initialPerturbation: Double = 20.0  // Default ~20 degrees of initial perturbation
    
    private let simulation = PendulumSimulation()
    var timer: Timer? // Changed from private for use in extensions
    
    // Reference to the scene for visual updates
    weak var scene: PendulumScene?
    
    init() {
        // Set initial default values before loading from simulation
        // This ensures UI displays non-zero values even before loadInitialParameters completes
        mass = 1.0
        length = 1.0
        damping = 0.1  // Small damping for better playability
        gravity = 15.0
        springConstant = 0.1  // Small spring constant for slight stabilization
        momentOfInertia = 0.5
        forceStrength = 5.0
        initialPerturbation = 20.0
        
        // Initial state setup for inverted pendulum
        currentState = PendulumState(theta: Double.pi + 0.05, thetaDot: 0, time: 0)
        
        // Load high score from UserDefaults if available
        highScore = UserDefaults.standard.integer(forKey: "PendulumHighScore")
        
        // Initialize based on simulation's defaults
        loadInitialParameters()
        
        // Ensure the simulation has our values
        updateSimulationParameters()
    }
    
    private func loadInitialParameters() {
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
        // Reset game state
        score = 0
        gameOverReason = nil
        isGameActive = true
        balanceStartTime = Date()
        lastScoreUpdate = Date()
        totalBalanceTime = 0
        consecutiveBalanceTime = 0
        
        // Reset level information
        currentLevel = 1
        levelPerturbation = 0.1 
        levelSuccessTime = 3.0
        
        // Initialize stats dictionary
        levelStats = [
            "currentLevel": 1.0,
            "levelsCompleted": 0.0,
            "maxAngle": 0.0,
            "currentAngle": 0.0,
            "lastAttemptTime": 0.0
        ]
        
        // Create an initial perturbation based on the level and adjustable parameter
        let degreesOffset = initialPerturbation * levelPerturbation
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
        gameOverReason = "Level \(currentLevel)"
        
        // Print debug info
        print("Starting game with perturbation:")
        print("Direction: \(direction > 0 ? "right" : "left")")
        print("Perturbation: \(degreesOffset) degrees (\(radianOffset) radians)")
        print("Initial position: theta = \(initialTheta) (\(initialTheta * 180/Double.pi - 180) degrees from vertical)")
        print("Initial velocity: thetaDot = \(initialThetaDot)")
        print("Balance threshold: \(balanceAngleThreshold) radians (\(balanceAngleThreshold * 180/Double.pi) degrees)")
        print("Failure threshold: \(failureAngleThreshold) radians (\(failureAngleThreshold * 180/Double.pi) degrees)")
        print("Level success time: \(levelSuccessTime) seconds")
        
        // Start simulation, but delay the game over check for a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.startSimulation()
        }
    }
    
    // Function called when a level is completed successfully
    private func levelCompleted() {
        // Increase level
        currentLevel += 1
        
        // Add bonus points for completing level
        score += currentLevel * 100
        
        // Reset consecutive balance time
        consecutiveBalanceTime = 0
        
        // Increase difficulty with each level
        levelPerturbation = min(0.1 * Double(currentLevel), 0.5) // Increase perturbation with level, max 0.5
        
        // Update level success time (gets shorter with each level)
        levelSuccessTime = max(5.0 - (Double(currentLevel) * 0.3), 1.5) 
        
        // Update stats
        levelStats["levelsCompleted"] = Double(currentLevel - 1)
        levelStats["currentLevel"] = Double(currentLevel)
        
        // Announce level completion
        gameOverReason = "Level \(currentLevel-1) completed!"
        
        // Brief pause before starting new level
        let wasSimulating = isSimulating
        stopSimulation()
        
        // Restart with increased difficulty after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.gameOverReason = "Level \(self.currentLevel)"
            
            // Create a new perturbed state with increased difficulty
            let degreesOffset = self.initialPerturbation * self.levelPerturbation
            let radianOffset = degreesOffset * Double.pi / 180.0
            let direction = Bool.random() ? 1.0 : -1.0
            let initialTheta = Double.pi + (direction * radianOffset)
            let initialThetaDot = direction * radianOffset * 0.02
            
            // Reset to new level state
            self.currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
            self.simulation.setInitialState(state: self.currentState)
            
            // Start new level
            if wasSimulating {
                self.startSimulation()
            }
        }
    }
    
    func endGame(reason: String) {
        isGameActive = false
        gameOverReason = reason
        stopSimulation()
        
        // Update high score if needed
        if score > highScore {
            highScore = score
            // Save high score to UserDefaults
            UserDefaults.standard.set(highScore, forKey: "PendulumHighScore")
        }
        
        // Reset level on game end
        levelStats["finalLevel"] = Double(currentLevel)
        levelStats["finalScore"] = Double(score)
        
        // Reset level for next game
        currentLevel = 1
        levelPerturbation = 0.1
        levelSuccessTime = 3.0
    }
    
    // Helper to normalize angle to [-π, π]
    private func normalizeAngle(_ angle: Double) -> Double {
        return atan2(sin(angle), cos(angle))
    }
    
    func startSimulation() {
        isSimulating = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true) { [weak self] _ in
            self?.step()
        }
    }
    
    private func step() {
        // Step the simulation
        currentState = simulation.step()
        simulationError = simulation.compareWithReference()
        
        // Add game logic
        if isGameActive {
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
            
            // Print debug info occasionally - reduced frequency
            if Int(currentState.time * 100) % 200 == 0 {  // Every 2 seconds instead of 0.5 seconds
                print("Time: \(String(format: "%.2f", currentState.time)), " +
                      "Angle: \(String(format: "%.2f", normalizedAngle)), " +
                      "From Top: \(String(format: "%.2f", angleFromTop))")
            }
            
            // Check for fallen state, but only after allowing time to get started
            // Add a grace period after applying force (0.5 seconds)
            let forceGracePeriod = 0.5
            let isInGracePeriod = currentState.time - lastForceAppliedTime < forceGracePeriod
            
            if currentState.time > 0.5 && angleFromTop > failureAngleThreshold && !isInGracePeriod {
                // Pendulum has fallen too far from vertical
                print("FALLEN! Angle from top: \(angleFromTop), threshold: \(failureAngleThreshold)")
                endGame(reason: "Pendulum fell!")
                
                // Update stats for dashboard
                let failTime = Date().timeIntervalSince(balanceStartTime ?? Date())
                levelStats["lastAttemptTime"] = failTime
                levelStats["maxAngle"] = Double(angleFromTop)
                
                // Reset consecutive balance time
                consecutiveBalanceTime = 0
                
            } else if angleFromTop < balanceAngleThreshold {
                // Pendulum is balanced near vertical
                if let lastUpdate = lastScoreUpdate, Date().timeIntervalSince(lastUpdate) >= scoreUpdateInterval {
                    // Update score based on balance quality - how close to perfectly vertical
                    let balanceQuality = 1.0 - (angleFromTop / balanceAngleThreshold)
                    let pointsToAdd = Int(10 * balanceQuality)
                    score += pointsToAdd
                    
                    // Update balance time
                    totalBalanceTime += scoreUpdateInterval
                    lastScoreUpdate = Date()
                    
                    // Accumulate consecutive balance time
                    consecutiveBalanceTime += scoreUpdateInterval
                    
                    // Update stats
                    levelStats["currentAngle"] = Double(angleFromTop)
                    
                    // Check if level is completed
                    if consecutiveBalanceTime >= levelSuccessTime {
                        levelCompleted()
                    }
                }
            } else {
                // Not balanced - reset consecutive balance time
                consecutiveBalanceTime = 0
            }
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
    }
    
    func applyForce(_ magnitude: Double) {
        print("*** FORCE BUTTON PRESSED ***")
        
        // If game is not active but there's a game over reason, restart on push
        if !isGameActive && gameOverReason != nil {
            print("Game not active, restarting...")
            resetAndStart()
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
        
        print("AFTER force application - theta: \(currentState.theta), thetaDot: \(currentState.thetaDot)")
    }
    
    func reset() {
        // Stop any existing simulation first
        stopSimulation()
        
        // Reset to initial state for inverted pendulum
        currentState = PendulumState(theta: Double.pi + 0.1, thetaDot: 0, time: 0)
        simulationError = 0
        
        // Reset game state
        score = 0
        gameOverReason = nil
        isGameActive = false
        totalBalanceTime = 0
        
        // Get current parameters before reset for logging
        let oldMass = mass
        let oldLength = length
        let oldDamping = damping
        let oldGravity = gravity
        let oldSpringConstant = springConstant
        
        // Reset parameters to default values ONLY if user wants default parameters
        // Otherwise keep current parameter values that user has set via sliders
        
        // Reset parameters to recommended defaults for better balancing playability
        mass = 1.0
        length = 1.0
        damping = 0.1  // Small damping for slight stabilization
        gravity = 15.0  // High gravity for pronounced falling
        springConstant = 0.1  // Small spring force to make balancing possible
        momentOfInertia = 0.5  // Default moment of inertia
        forceStrength = 5.0  // Increased force strength for immediate visual effect
        initialPerturbation = 20.0  // Default initial perturbation in degrees
        
        // Log parameter values before and after reset
        print("Reset parameters:")
        print("  - Previous mass: \(oldMass), Current mass: \(mass)")
        print("  - Previous length: \(oldLength), Current length: \(length)")
        print("  - Previous damping: \(oldDamping), Current damping: \(damping)")
        print("  - Previous gravity: \(oldGravity), Current gravity: \(gravity)")
        print("  - Previous spring constant: \(oldSpringConstant), Current spring constant: \(springConstant)")
        
        // Make sure simulation has latest parameter values
        updateSimulationParameters()
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
}