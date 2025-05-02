import Foundation

struct PendulumSimData {
    var time: Double
    var position: Double
    var velocity: Double
    var command: Double?
}

class PendulumSimulation {
    // Parameters
    private var timeStep: Double = 0.002  // From myiptype8.m
    private var kj: Double = 1.0          // Default value
    private var currentTime: Double = 0.0
    
    // Model parameters
    private var mass: Double = 1.0
    private var length: Double = 1.0
    private var gravity: Double = 15.0  // Increased gravity to make falling motion more pronounced
    private var damping: Double = 0.0  // Zero damping to allow completely natural falling
    private var springConstant: Double = 0.0  // No spring force to avoid accidental stabilization
    private var momentOfInertia: Double = 0.5  // Reduced inertia for faster response to gravity
    
    // State
    private var currentState: PendulumState
    private var referenceData: [PendulumSimData] = []
    private var inputCommands: [PendulumSimData] = []
    
    init() {
        // Initial conditions for inverted pendulum (starting SLIGHTLY offset from exact top position)
        currentState = PendulumState(
            theta: Double.pi + 0.1,  // Offset from top position to clearly demonstrate falling
            thetaDot: 0,             // Initial velocity
            time: 0
        )
        
        // Load data synchronously in init
        loadSimulationData()
    }
    
    func loadSimulationData() {
        // Try to load reference data
        if let path = Bundle.main.path(forResource: "OutputPendulumSim", ofType: "csv") {
            referenceData = parseCSV(at: path).compactMap { row in
                guard row.count >= 3,
                      let time = Double(row[0]),
                      let position = Double(row[1]),
                      let velocity = Double(row[2]) else {
                    return nil
                }
                return PendulumSimData(time: time, position: position, velocity: velocity)
            }
            print("Loaded \(referenceData.count) reference data points")
        }
        
        // Try to load input parameters and commands
        if let path = Bundle.main.path(forResource: "InputPendulumSim", ofType: "csv") {
            let rows = parseCSV(at: path)
            
            // Parse commands (for multi-row command files)
            if rows.count > 9 { // If file has more than just parameters
                inputCommands = rows.dropFirst(9).compactMap { row in
                    guard row.count >= 2 else { return nil }
                    
                    // Skip rows with empty entries
                    if row[0].isEmpty || row[1].isEmpty { return nil }
                    
                    guard let time = parseExpression(row[0]),
                          let command = parseExpression(row[1]) else {
                        print("Failed to parse command row: \(row)")
                        return nil
                    }
                    return PendulumSimData(time: time, position: 0, velocity: 0, command: command)
                }
                print("Loaded \(inputCommands.count) input commands")
            }
            
            // Parse model parameters from the first 9 rows
            if rows.count >= 9 {
                // Process each row, skipping empty or malformed ones
                for (index, row) in rows.prefix(9).enumerated() {
                    guard row.count > 0 && !row[0].isEmpty else { continue }
                    
                    if let value = parseExpression(row[0]) {
                        switch index {
                        case 0: // 1st row: mass
                            mass = value
                            print("Set mass: \(mass)")
                            
                        case 2: // 3rd row: length
                            length = value
                            print("Set length: \(length)")
                            
                        case 3: // 4th row: gravity
                            gravity = value
                            print("Set gravity: \(gravity)")
                            
                        case 6: // 7th row: time step
                            timeStep = value
                            print("Set time step: \(timeStep)")
                            
                        case 7: // 8th row: initial theta
                            currentState = PendulumState(
                                theta: value,
                                thetaDot: currentState.thetaDot,
                                time: currentState.time
                            )
                            print("Set initial theta: \(value)")
                            
                        case 8: // 9th row: damping
                            damping = value
                            print("Set damping: \(damping)")
                            
                        default:
                            break
                        }
                    } else {
                        print("Failed to parse parameter at row \(index): \(row[0])")
                    }
                }
            }
        }
    }
    
    // Basic CSV parser
    private func parseCSV(at path: String) -> [[String]] {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            var results: [[String]] = []
            
            // Split by newlines
            let rows = content.components(separatedBy: .newlines)
            
            for row in rows {
                // Skip empty rows
                if row.isEmpty { continue }
                
                // Split by comma
                let columns = row.components(separatedBy: ",")
                results.append(columns.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            }
            
            return results
        } catch {
            print("Error parsing CSV: \(error)")
            return []
        }
    }
    
    // Helper to parse mathematical expressions like "pi/2"
    private func parseExpression(_ expression: String) -> Double? {
        // Try simple Double conversion first
        if let value = Double(expression) {
            return value
        }
        
        // Handle special cases
        let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Handle pi
        if trimmed == "pi" {
            return Double.pi
        }
        
        // Handle pi/2
        if trimmed == "pi/2" {
            return Double.pi / 2
        }
        
        // Handle pi/4
        if trimmed == "pi/4" {
            return Double.pi / 4
        }
        
        // Handle pi/3
        if trimmed == "pi/3" {
            return Double.pi / 3
        }
        
        // Handle pi/6
        if trimmed == "pi/6" {
            return Double.pi / 6
        }
        
        // Handle 2*pi or 2pi
        if trimmed == "2*pi" || trimmed == "2pi" {
            return 2 * Double.pi
        }
        
        // Log for debugging
        print("Could not parse expression: \(expression)")
        return nil
    }
    
    func step() -> PendulumState {
        // Find current command
        let command = inputCommands.first { data in
            abs(data.time - currentTime) < timeStep/2
        }?.command ?? 0.0
        
        // Update velocity with command
        currentState.thetaDot += command * kj / timeStep
        
        // Use RK4 solver for next position and velocity
        let solver = rK4
        let currentValues = [currentState.theta, currentState.thetaDot]
        let derivs: [(Double, [Double]) -> Double] = [
            // Return dθ/dt = ω (angular velocity)
            { (_, state) in state[1] },
            
            // Return dω/dt = acceleration
            { (t, state) in
                let theta = state[0]
                let omega = state[1]
                
                let inertia = self.mass * self.length * self.length + self.momentOfInertia
                let ka = (self.mass * self.length * self.gravity) / inertia
                let ks = self.springConstant / inertia
                let kb = self.damping / inertia
                
                // CORRECTED Inverted pendulum physics: 
                // For angle θ, with θ = π being the upright position:
                //
                // 1. The gravitational torque is proportional to sin(θ):
                //    - At θ = π (upright): sin(π) = 0, so no torque when perfectly balanced
                //    - At θ = π + small: sin(π + small) ≈ -small
                //    - With a negative multiplier (-ka), this makes the pendulum fall away
                //      from the upright position when disturbed
                //
                // 2. The standard torque equation for a pendulum is τ = -mgL*sin(θ)
                //    - For regular pendulum: stable at θ = 0 (bottom)
                //    - For inverted pendulum: unstable at θ = π (top)
                //
                // 3. The negative sign before sin(theta) creates the correct instability
                //    that makes the pendulum fall toward 90° when disturbed from upright
                //
                // 4. The ks*θ term is set to zero to avoid stabilization
                //
                // 5. The -kb*ω term is velocity-dependent damping (also set to zero)
                // For inverted pendulum, need negative value to produce instability at π
                // Force = -m*g*L*sin(theta) in physics, but our equation has positive ka
                // So for correct inverted pendulum physics, we need to negate sin(theta)
                return -ka * sin(theta) + ks * theta - kb * omega
            }
        ]
        
        let newValues = solver(timeStep, currentTime, currentValues, derivs)
        
        currentTime += timeStep
        currentState = PendulumState(
            theta: newValues[0],
            thetaDot: newValues[1],
            time: currentTime
        )
        
        return currentState
    }
    
    // Runge-Kutta 4th order method
    private func rungeKutta4(
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
    
    func compareWithReference() -> Double {
        // Find corresponding reference state
        guard let refState = referenceData.first(where: { data in
            abs(data.time - currentTime) < timeStep/2
        }) else {
            return 0
        }
        
        // Calculate RMS error
        let posError = pow(currentState.theta - refState.position, 2)
        let velError = pow(currentState.thetaDot - refState.velocity, 2)
        return sqrt((posError + velError) / 2)
    }
    
    // MARK: - Parameter Update Methods
    
    // Method to update mass parameter
    func setMass(_ newMass: Double) {
        mass = newMass
        print("Updated mass to \(mass)")
    }
    
    // Method to update length parameter
    func setLength(_ newLength: Double) {
        length = newLength
        print("Updated length to \(length)")
    }
    
    // Method to update gravity parameter
    func setGravity(_ newGravity: Double) {
        gravity = newGravity
        print("Updated gravity to \(gravity)")
    }
    
    // Method to update damping parameter
    func setDamping(_ newDamping: Double) {
        damping = newDamping
        print("Updated damping to \(damping)")
    }
    
    // Method to update spring constant parameter
    func setSpringConstant(_ newSpringConstant: Double) {
        springConstant = newSpringConstant
        print("Updated spring constant to \(springConstant)")
    }
    
    // Method to get all current parameters
    func getCurrentParameters() -> (mass: Double, length: Double, gravity: Double, damping: Double, springConstant: Double) {
        return (mass, length, gravity, damping, springConstant)
    }
    
    // Method to set initial state directly (for guaranteed start position)
    func setInitialState(state: PendulumState) {
        self.currentState = state
        self.currentTime = state.time
        
        // Reset internal time tracking to ensure consistent behavior on restart
        self.timeStep = 0.002
        
        print("Simulation state fully reset: theta = \(state.theta), omega = \(state.thetaDot), time = \(state.time)")
    }
    
    // Method to apply an external force to the pendulum
    func applyExternalForce(magnitude: Double) {
        // Update angular velocity directly - use a stronger force multiplier to make control more obvious
        let amplifiedForce = magnitude * 1.5  // Amplify force effect to make control more responsive
        currentState.thetaDot += amplifiedForce
        // Minimal logging for external force
        print("Force: \(String(format: "%.2f", magnitude)), amplified: \(String(format: "%.2f", amplifiedForce)), new vel: \(String(format: "%.2f", currentState.thetaDot))")
    }
}
