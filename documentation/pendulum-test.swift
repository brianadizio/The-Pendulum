import Foundation

class PendulumTester {
    static func validateSimulation() {
        // Load and parse input parameters
        guard let inputPath = Bundle.main.path(forResource: "InputPendulumSim", ofType: "csv") else {
            print("Error: Could not find InputPendulumSim.csv")
            return
        }
        
        do {
            let inputContent = try String(contentsOfFile: inputPath, encoding: .utf8)
            let rows = inputContent.components(separatedBy: .newlines)
                                 .filter { !$0.isEmpty }
            
            // Parse input parameters
            let parameters = rows.compactMap { row -> Double? in
                let components = row.components(separatedBy: ",")
                guard let firstValue = components.first else { return nil }
                return Double(firstValue)
            }
            
            print("Loaded parameters:", parameters)
            
            // Create pendulum simulation
            var pendulum = InvertedPendulum(parameters: parameters)
            
            // Load output data for comparison
            guard let outputPath = Bundle.main.path(forResource: "OutputPendulumSim", ofType: "csv") else {
                print("Error: Could not find OutputPendulumSim.csv")
                return
            }
            
            let outputContent = try String(contentsOfFile: outputPath, encoding: .utf8)
            let outputRows = outputContent.components(separatedBy: .newlines)
                                        .filter { !$0.isEmpty }
                                        .dropFirst() // Skip header
            
            // Compare simulation results with reference data
            var maxError = 0.0
            var totalError = 0.0
            var sampleCount = 0
            
            for row in outputRows {
                let values = row.components(separatedBy: ",")
                guard values.count >= 4,
                      let time = Double(values[0]),
                      let refPosition = Double(values[1]),
                      let refVelocity = Double(values[2]),
                      let command = Double(values[3]) else {
                    continue
                }
                
                // Run simulation step
                let (simPosition, simVelocity) = pendulum.step(command: command)
                
                // Calculate error
                let posError = abs(simPosition - refPosition)
                let velError = abs(simVelocity - refVelocity)
                
                maxError = max(maxError, max(posError, velError))
                totalError += posError + velError
                sampleCount += 1
                
                // Print periodic comparison
                if sampleCount % 50 == 0 {
                    print("Time: \(time)")
                    print("Reference - Pos: \(refPosition), Vel: \(refVelocity)")
                    print("Simulation - Pos: \(simPosition), Vel: \(simVelocity)")
                    print("Error - Pos: \(posError), Vel: \(velError)")
                    print("---")
                }
            }
            
            print("Validation complete:")
            print("Max error: \(maxError)")
            print("Average error: \(totalError / Double(sampleCount * 2))")
            
        } catch {
            print("Error reading files: \(error)")
        }
    }
}
