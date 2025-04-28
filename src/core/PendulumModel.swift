import Foundation

// State of the pendulum system
struct PendulumState {
    var theta: Double      // Angle from vertical (radians)
    var thetaDot: Double   // Angular velocity (radians/second)
    var time: Double       // Current simulation time (seconds)
    
    static let zero = PendulumState(theta: 0, thetaDot: 0, time: 0)
}

// Inverted pendulum physical model
class InvertedPendulumModel {
    // Physical parameters
    var mass: Double           // Mass of pendulum bob (kg)
    var length: Double         // Length of pendulum (m)
    var gravity: Double        // Acceleration due to gravity (m/s^2)
    var damping: Double        // Damping coefficient (kg·m^2/s)
    var springConstant: Double // Torsional spring constant (N·m/rad)
    var momentOfInertia: Double// Moment of inertia (kg·m^2)
    var driveFrequency: Double // External drive frequency (Hz)
    var driveAmplitude: Double // External drive amplitude (N·m)
    
    // Current state
    private(set) var currentState: PendulumState
    
    // Initialize with default values
    init(mass: Double = 1.0,
         length: Double = 1.0,
         gravity: Double = 9.81,
         damping: Double = 0.5,
         springConstant: Double = 0.0,
         momentOfInertia: Double = 1.0,
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
    
    // Calculate derivatives for ODE solver
    func derivatives(_ t: Double, _ state: [Double]) -> [(Double, [Double]) -> Double] {
        return [
            // θ' = ω (angular velocity)
            { (_, state) in state[1] },
            
            // ω' = acceleration
            { (t, state) in
                let theta = state[0]
                let omega = state[1]
                
                // Constants derived from physics equations
                let inertia = self.mass * self.length * self.length + self.momentOfInertia
                
                // Gravitational torque = m * g * L * sin(θ)
                let gravityTorque = (self.mass * self.gravity * self.length * sin(theta)) / inertia
                
                // Spring torque = -k * θ
                let springTorque = -self.springConstant * theta / inertia
                
                // Damping torque = -b * ω
                let dampingTorque = -self.damping * omega / inertia
                
                // External driving torque = A * sin(2π * f * t)
                let driveTorque = self.driveAmplitude * sin(2.0 * .pi * self.driveFrequency * t) / inertia
                
                // Sum all torques to get angular acceleration
                return gravityTorque + springTorque + dampingTorque + driveTorque
            }
        ]
    }
    
    // Step simulation forward using Runge-Kutta 4th order method
    func step(dt: Double) {
        let solver = rungeKutta4
        let currentValues = [currentState.theta, currentState.thetaDot]
        let newValues = solver(dt, currentState.time, currentValues, derivatives(currentState.time, currentValues))
        
        currentState = PendulumState(
            theta: newValues[0],
            thetaDot: newValues[1],
            time: currentState.time + dt
        )
    }
    
    // Apply external force (adding to angular velocity)
    func applyForce(_ magnitude: Double) {
        currentState.thetaDot += magnitude
    }
    
    // Reset the simulation
    func reset() {
        currentState = .zero
    }
}

// Runge-Kutta 4th order method for solving ODEs
func rungeKutta4(
    _ dt: Double,
    _ t: Double,
    _ y: [Double],
    _ derivs: [(Double, [Double]) -> Double]
) -> [Double] {
    let n = y.count
    var k1 = [Double](repeating: 0, count: n)
    var k2 = [Double](repeating: 0, count: n)
    var k3 = [Double](repeating: 0, count: n)
    var k4 = [Double](repeating: 0, count: n)
    var yTemp = [Double](repeating: 0, count: n)
    var yOut = [Double](repeating: 0, count: n)
    
    // k1 = f(t, y)
    for i in 0..<n {
        k1[i] = dt * derivs[i](t, y)
    }
    
    // k2 = f(t + dt/2, y + k1/2)
    for i in 0..<n {
        yTemp[i] = y[i] + k1[i] / 2.0
    }
    for i in 0..<n {
        k2[i] = dt * derivs[i](t + dt / 2.0, yTemp)
    }
    
    // k3 = f(t + dt/2, y + k2/2)
    for i in 0..<n {
        yTemp[i] = y[i] + k2[i] / 2.0
    }
    for i in 0..<n {
        k3[i] = dt * derivs[i](t + dt / 2.0, yTemp)
    }
    
    // k4 = f(t + dt, y + k3)
    for i in 0..<n {
        yTemp[i] = y[i] + k3[i]
    }
    for i in 0..<n {
        k4[i] = dt * derivs[i](t + dt, yTemp)
    }
    
    // y(t+dt) = y(t) + (k1 + 2*k2 + 2*k3 + k4)/6
    for i in 0..<n {
        yOut[i] = y[i] + (k1[i] + 2.0 * k2[i] + 2.0 * k3[i] + k4[i]) / 6.0
    }
    
    return yOut
}