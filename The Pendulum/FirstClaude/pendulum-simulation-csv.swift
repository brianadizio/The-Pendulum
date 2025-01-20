import Foundation
//import Papa

struct PendulumSimData {
    var time: Double
    var position: Double
    var velocity: Double
    var command: Double?
}

class PendulumSimulation {
    private let timeStep: Double = 0.002
    private var kj: Double = 0.0
    private var currentTime: Double = 0.0
    
    private var currentState: PendulumState
    private var referenceData: [PendulumSimData] = []
    private var inputCommands: [PendulumSimData] = []
    
    init() {
        currentState = PendulumState(
            theta: 0.05,
            thetaDot: 0,
            time: 0
        )
    }
    
//    func loadSimulationData() async throws {
//        // Load reference data
//      if let outputData = try? await window.fs.readFile("OutputPendulumSim.csv", { encoding: "utf8" }) {
//            let outputParsed = Papa.parse(outputData, {
//                header: true,
//                dynamicTyping: true,
//                skipEmptyLines: true
//            })
//            
//            referenceData = outputParsed.data.compactMap { row in
//                guard let time = row[0] as? Double,
//                      let position = row[1] as? Double,
//                      let velocity = row[2] as? Double else {
//                    return nil
//                }
//                return PendulumSimData(time: time, position: position, velocity: velocity)
//            }
//        }
//        
//        // Load input commands
//      if let inputData = try? await window.fs.readFile("inputPendulumSim.csv", { encoding: "utf8" }) {
//            let inputParsed = Papa.parse(inputData, {
//                header: true,
//                dynamicTyping: true,
//                skipEmptyLines: true
//            })
//            
//            inputCommands = inputParsed.data.compactMap { row in
//                guard let time = row["Time"] as? Double,
//                      let command = row["Command"] as? Double else {
//                    return nil
//                }
//                return PendulumSimData(time: time, position: 0, velocity: 0, command: command)
//            }
//            
//            // Extract kj parameter if present
//            if let firstRow = inputParsed.data.first,
//               let kjValue = firstRow["kj"] as? Double {
//                kj = kjValue
//            }
//        }
//    }
    
    func step() -> PendulumState {
        let command = inputCommands.first { data in
            abs(data.time - currentTime) < timeStep/2
        }?.command ?? 0.0
        
        // Update velocity with command
        currentState.thetaDot += command * kj / timeStep
        
        // RK4 step
        let solver = ODEScheme.rungeKutta.scheme
        let currentValues = [currentState.theta, currentState.thetaDot]
        let newValues = solver(timeStep, currentTime, currentValues, derivatives(currentTime, currentValues))
        
        currentTime += timeStep
        currentState = PendulumState(
            theta: newValues[0],
            thetaDot: newValues[1],
            time: currentTime
        )
        
        return currentState
    }
    
    private func derivatives(_ t: Double, _ state: [Double]) -> [(Double, [Double]) -> Double] {
        let ka = (mass * length * gravity) / (mass * length * length + momentOfInertia)
        let ks = springConstant / (mass * length * length + momentOfInertia)
        let kb = damping / (mass * length * length + momentOfInertia)
        
        return [
            { (_, state) in state[1] },
            { (_, state) in 
                ka * sin(state[0]) - ks * state[0] - kb * state[1]
            }
        ]
    }
    
    func compareWithReference() -> Double {
        guard let refState = referenceData.first(where: { data in
            abs(data.time - currentTime) < timeStep/2
        }) else {
            return 0
        }
        
        let posError = pow(currentState.theta - refState.position, 2)
        let velError = pow(currentState.thetaDot - refState.velocity, 2)
        return sqrt((posError + velError) / 2)
    }
}
