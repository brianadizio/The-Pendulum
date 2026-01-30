// InvertedPendulumModel.swift
import Foundation

struct PendulumState {
    var theta: Double      // Angle from vertical
    var thetaDot: Double   // Angular velocity
    var time: Double       // Current simulation time
    
    static let zero = PendulumState(theta: 0, thetaDot: 0, time: 0)
}

class InvertedPendulumModel {
    // System parameters
    var mass: Double           // Mass at end of pendulum (kg)
    var length: Double         // Length of pendulum (m)
    var gravity: Double        // Acceleration due to gravity (m/s^2)
    var damping: Double        // Damping coefficient
    var springConstant: Double // Torsional spring constant
    var momentOfInertia: Double// Moment of inertia
    var driveFrequency: Double // External drive frequency (Hz)
    var driveAmplitude: Double // External drive amplitude
    
    // Current state
    private(set) var currentState: PendulumState
    
    init(mass: Double = 1.0,
         length: Double = 1.0,
         gravity: Double = 9.81,
         damping: Double = 0.4,          // Higher damping for easier control
         springConstant: Double = 0.20,   // Small stabilization for smoother gameplay
         momentOfInertia: Double = 1.0,   // Increased for more stability
         driveFrequency: Double = 0.0,
         driveAmplitude: Double = 0.0) {
        
        self.mass = mass
        self.length = length
        self.gravity = gravity
        self.damping = damping
        self.springConstant = springConstant
        self.momentOfInertia = momentOfInertia
        self.driveFrequency = driveFrequency
        self.driveAmplitude = driveAmplitude
        self.currentState = .zero
    }
    
    // Compute derivatives for RK4 solver
    func derivatives(_ t: Double, _ state: [Double]) -> [(Double, [Double]) -> Double] {
        return [
            { (_, state) in state[1] },  // θ' = ω
            { (t, state) in              // ω' = acceleration
                let theta = state[0]
                let omega = state[1]
                
                // Constants from myiptype8.m
                let ka = (self.mass * self.length * self.gravity) / 
                        (self.mass * self.length * self.length + self.momentOfInertia)
                let ks = self.springConstant / 
                        (self.mass * self.length * self.length + self.momentOfInertia)
                let kb = self.damping / 
                        (self.mass * self.length * self.length + self.momentOfInertia)
                
                // Driving force
                let drive = self.driveAmplitude * sin(2.0 * .pi * self.driveFrequency * t)
                
                // Angular acceleration for inverted pendulum
                // Negative sign in front of sin(theta) for correct unstable equilibrium
                return -ka * sin(theta) + ks * theta - kb * omega + drive
            }
        ]
    }
    
    // Step simulation forward using RK4
    func step(dt: Double) {
        let solver = ODEScheme.rungeKutta.scheme
        let currentValues = [currentState.theta, currentState.thetaDot]
        let newValues = solver(dt, currentState.time, currentValues, derivatives(currentState.time, currentValues))
        
        currentState = PendulumState(
            theta: newValues[0],
            thetaDot: newValues[1],
            time: currentState.time + dt
        )
    }
    
    // Apply external force to pendulum
    func applyForce(_ magnitude: Double) {
        currentState.thetaDot += magnitude
    }
    
    // Reset simulation
    func reset() {
        currentState = .zero
    }

    // Reset with initial angle
    func reset(withAngle theta: Double) {
        currentState = PendulumState(theta: theta, thetaDot: 0, time: 0)
    }
}
