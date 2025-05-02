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
    @Published var springConstant: Double = 0.0 {  // Must be zero to avoid any stabilizing effect at upright
        didSet {
            updatePhysicsParameters()
        }
    }
    
    // Force strength parameter for push buttons
    @Published var forceStrength: Double = 0.5  // Reduced to allow for more precise control (approx 5-10 degrees per push)
    
    // Initial perturbation amount (in degrees)
    @Published var initialPerturbation: Double = 20.0  // Default ~20 degrees of initial perturbation
    
    private let simulation = PendulumSimulation()
    var timer: Timer? // Changed from private for use in extensions
    
    // Reference to the scene for visual updates
    weak var scene: PendulumScene?
    
    init() {
        // Initial state setup for inverted pendulum
        currentState = PendulumState(theta: Double.pi + 0.05, thetaDot: 0, time: 0)
        
        // Load high score from UserDefaults if available
        highScore = UserDefaults.standard.integer(forKey: "PendulumHighScore")
        
        // Initialize based on simulation's defaults
        loadInitialParameters()
    }
    
    private func loadInitialParameters() {
        // Get current parameters from the simulation
        let params = simulation.getCurrentParameters()
        
        // Update our published properties with simulation values
        mass = params.mass
        length = params.length
        damping = params.damping 
        gravity = params.gravity
        springConstant = params.springConstant
        
        print("Loaded initial parameters: mass=\(mass), length=\(length), damping=\(damping), gravity=\(gravity)")
    }
    
    private func updatePhysicsParameters() {
        // Use the simulation's parameter update methods
        let wasSimulating = isSimulating
        
        // Temporarily pause simulation during parameter updates
        if wasSimulating {
            stopSimulation()
        }
        
        // Update the simulation parameters
        simulation.setMass(mass)
        simulation.setLength(length)
        simulation.setDamping(damping)
        simulation.setGravity(gravity)
        simulation.setSpringConstant(springConstant)
        
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
        
        // Create an initial perturbation based on the adjustable parameter
        // Use initialPerturbation parameter instead of random value
        let degreesOffset = initialPerturbation
        let radianOffset = degreesOffset * Double.pi / 180.0
        
        // Randomly decide left or right tilt
        let direction: Double = Bool.random() ? 1.0 : -1.0
        
        // Calculate initial theta (start position) and thetaDot (velocity)
        // Use a larger offset to make the falling motion clearly visible
        let initialTheta = Double.pi + (direction * radianOffset * 0.15) // Small but noticeable offset from vertical
        let initialThetaDot = direction * radianOffset * 0.02 // Small initial velocity
        
        // Create the pendulum state with random oscillation
        currentState = PendulumState(theta: initialTheta, thetaDot: initialThetaDot, time: 0)
        
        // Get a handle to the simulation and force it to use our state
        simulation.setInitialState(state: currentState)
        
        // Print debug info
        print("Starting game with perturbation:")
        print("Direction: \(direction > 0 ? "right" : "left")")
        print("Perturbation: \(degreesOffset) degrees (\(radianOffset) radians)")
        print("Initial position: theta = \(initialTheta) (\(initialTheta * 180/Double.pi - 180) degrees from vertical)")
        print("Initial velocity: thetaDot = \(initialThetaDot)")
        print("Failure threshold: \(failureAngleThreshold) radians (\(failureAngleThreshold * 180/Double.pi) degrees)")
        
        // Start simulation, but delay the game over check for a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.startSimulation()
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
                }
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
        // Reset to initial state for inverted pendulum
        currentState = PendulumState(theta: Double.pi + 0.1, thetaDot: 0, time: 0)
        simulationError = 0
        
        // Reset game state
        score = 0
        gameOverReason = nil
        isGameActive = false
        totalBalanceTime = 0
        
        // Reset parameters to match our current settings
        mass = 1.0
        length = 1.0
        damping = 0.0  // Zero damping to allow completely natural falling
        gravity = 15.0  // Keep high gravity for pronounced falling
        springConstant = 0.0  // No spring force to avoid any stabilizing effect
        forceStrength = 0.5  // Force strength for control
        initialPerturbation = 20.0  // Default initial perturbation in degrees
        
        // Stop any existing simulation
        stopSimulation()
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
    }
}