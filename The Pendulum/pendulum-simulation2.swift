import Foundation

struct InvertedPendulum {
    // System parameters
    let ma: Double      // Mass
    let Iz: Double      // Moment of inertia
    let ln: Double      // Length
    let gr: Double      // Gravity
    let ksp: Double     // Spring constant
    let bv: Double      // Damping coefficient
    let kj: Double      // Joy constant
    let tinc: Double    // Time increment
    let fallBoundary: Double // Fall boundary in radians
    
    // State variables
    private var position: Double
    private var velocity: Double
    
    init(parameters: [Double]) {
        self.ma = parameters[0]
        self.Iz = parameters[1]
        self.ln = parameters[2]
        self.gr = parameters[3]
        self.ksp = parameters[4]
        self.bv = parameters[5]
        self.tinc = parameters[6]
        self.fallBoundary = parameters[7]
        self.kj = parameters[8]  // 9th row is joystick constant
        
        // Set initial conditions to match MATLAB simulation
        self.position = 0.05  // Initial position of 0.05 radians
        self.velocity = 0.0   // Initial velocity of 0 rad/s
    }
    
    // Convert the system into first-order differential equations
    private func derivatives(_ t: Double, _ state: [Double], command: Double) -> [(Double, [Double]) -> Double] {
        return [
            // θ' = velocity
            { (_, _) in state[1] },
            
            // θ'' = ka*sin(θ) - ks*θ - kb*θ' + kj*command
            { (_, _) in
                let ka = (ma * ln * gr) / (ma * ln * ln + Iz)
                let ks = ksp / (ma * ln * ln + Iz)
                let kb = bv / (ma * ln * ln + Iz)
                
                return ka * sin(state[0]) - ks * state[0] - kb * state[1] + kj * command
            }
        ]
    }
    
    mutating func step(command: Double) -> (position: Double, velocity: Double) {
        let appliedForce = command * kj
        print("Step called - Position: \(position), Velocity: \(velocity), Command: \(command), Applied Force: \(appliedForce)")
        let currentState = [position, velocity]
        
        // Use RK4 to integrate one time step
        let nextState = rK4(tinc, 0.0, currentState, functions: derivatives(0.0, currentState, command: command))
        
        // Update state
        position = nextState[0]
        velocity = nextState[1]
        
        // Check fall boundary
        if abs(position) > fallBoundary {
            position = position > 0 ? fallBoundary : -fallBoundary
            velocity = 0
        }
        
        return (position, velocity)
    }
}

// Helper extension
extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180.0
    }
    
    var radiansToDegrees: Double {
        return self * 180.0 / .pi
    }
}
