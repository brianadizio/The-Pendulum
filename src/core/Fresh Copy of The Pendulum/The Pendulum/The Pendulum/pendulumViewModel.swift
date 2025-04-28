// PendulumViewModel.swift
import SwiftUI
import SpriteKit

class PendulumViewModel: ObservableObject {
    @Published var currentState = PendulumState(theta: 0.05, thetaDot: 0, time: 0)
    @Published var simulationError: Double = 0
    @Published var isSimulating = false // Changed from isRunning to isSimulating
    
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
    
    @Published var damping: Double = 0.1 {
        didSet {
            updatePhysicsParameters()
        }
    }
    
    @Published var gravity: Double = 9.81 {
        didSet {
            updatePhysicsParameters()
        }
    }
    
    // Additional parameters that might be needed
    @Published var springConstant: Double = 0.0 {
        didSet {
            updatePhysicsParameters()
        }
    }
    
    // Force strength parameter for push buttons
    @Published var forceStrength: Double = 2.5
    
    private let simulation = PendulumSimulation()
    var timer: Timer? // Changed from private for use in extensions
    
    // Reference to the scene for visual updates
    weak var scene: PendulumScene?
    
    init() {
        // Initial state setup
        currentState = PendulumState(theta: 0.05, thetaDot: 0, time: 0)
        
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
    
    func startSimulation() {
        isSimulating = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true) { [weak self] _ in
            self?.step()
        }
    }
    
    private func step() {
        currentState = simulation.step()
        simulationError = simulation.compareWithReference()
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
    }
    
    func applyForce(_ magnitude: Double) {
        // Apply external force using the adjustable force strength parameter
        let scaledMagnitude = magnitude * forceStrength
        
        print("Applying force: \(scaledMagnitude) to pendulum with current velocity \(currentState.thetaDot)")
        
        // Update the state with the new angular velocity
        let newState = PendulumState(
            theta: currentState.theta,
            thetaDot: currentState.thetaDot + scaledMagnitude,
            time: currentState.time
        )
        
        // Apply the new state
        currentState = newState
        
        // If simulation is not running, start it briefly to show effect
        let wasNotSimulating = !isSimulating
        if wasNotSimulating {
            // Start simulation temporarily to show effect of push
            startSimulation()
            
            // Optionally, stop simulation after a delay if it wasn't running before
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self, wasNotSimulating, self.isSimulating else { return }
                self.stopSimulation()
            }
        }
    }
    
    func reset() {
        // Reset to initial state
        currentState = PendulumState(theta: 0.05, thetaDot: 0, time: 0)
        simulationError = 0
        
        // Reset parameters to defaults
        mass = 1.0
        length = 1.0
        damping = 0.1
        gravity = 9.81
        springConstant = 0.0
        forceStrength = 2.5
    }
}