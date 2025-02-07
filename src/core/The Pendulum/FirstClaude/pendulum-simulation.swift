//import SheetJS
//
//struct PendulumSimData {
//    var time: Double
//    var position: Double
//    var velocity: Double
//    var command: Double?
//}
//
//class PendulumSimulation {
//    // Parameters
//    private let timeStep: Double = 0.002  // From myiptype8.m
//    private var kj: Double = 0.0          // From input file
//    private var currentTime: Double = 0.0
//    
//    // State
//    private var currentState: PendulumState
//    private var referenceData: [PendulumSimData] = []
//    private var inputCommands: [PendulumSimData] = []
//    
//    init() {
//        // Initial conditions
//        currentState = PendulumState(
//            theta: 0.05,  // Initial position
//            thetaDot: 0,  // Initial velocity
//            time: 0
//        )
//    }
//    
//    func loadSimulationData() async throws {
//        // Load reference data
//        if let outputData = try? await loadExcelFile(named: "OutputPendulumSim") {
//            referenceData = outputData.compactMap { row in
//                guard let time = row["Time"] as? Double,
//                      let position = row["Position"] as? Double,
//                      let velocity = row["Velocity"] as? Double else {
//                    return nil
//                }
//                return PendulumSimData(time: time, position: position, velocity: velocity)
//            }
//        }
//        
//        // Load input commands
//        if let inputData = try? await loadExcelFile(named: "inputPendulumSim") {
//            inputCommands = inputData.compactMap { row in
//                guard let time = row["Time"] as? Double,
//                      let command = row["Command"] as? Double else {
//                    return nil
//                }
//                return PendulumSimData(time: time, position: 0, velocity: 0, command: command)
//            }
//            
//            // Extract kj parameter if present
//            if let params = inputData.first,
//               let kjValue = params["kj"] as? Double {
//                kj = kjValue
//            }
//        }
//    }
//    
//    private func loadExcelFile(named filename: String) async throws -> [[String: Any]] {
//        guard let url = Bundle.main.url(forResource: filename, withExtension: "xlsx"),
//              let data = try? Data(contentsOf: url) else {
//            throw NSError(domain: "PendulumSim", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found"])
//        }
//        
//        let workbook = try XLSX.read(data, options: XLSXOptions(
//            cellDates: true,
//            cellNF: true,
//            cellStyles: true
//        ))
//        
//        guard let sheet = workbook.sheets.first,
//              let rows = sheet.data else {
//            throw NSError(domain: "PendulumSim", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid sheet data"])
//        }
//        
//        var result: [[String: Any]] = []
//        let headers = rows[0].compactMap { $0.value as? String }
//        
//        for row in rows.dropFirst() {
//            var rowDict: [String: Any] = [:]
//            for (index, cell) in row.enumerated() {
//                if index < headers.count {
//                    rowDict[headers[index]] = cell.value
//                }
//            }
//            result.append(rowDict)
//        }
//        
//        return result
//    }
//    
//    func step() -> PendulumState {
//        // Find current command
//        let command = inputCommands.first { data in
//            abs(data.time - currentTime) < timeStep/2
//        }?.command ?? 0.0
//        
//        // Update velocity with command
//        currentState.thetaDot += command * kj / timeStep
//        
//        // Use RK4 solver for next position and velocity
//        let solver = ODEScheme.rungeKutta.scheme
//        let currentValues = [currentState.theta, currentState.thetaDot]
//        let newValues = solver(timeStep, currentTime, currentValues) { t, state in
//            let ka = (self.mass * self.length * self.gravity) / 
//                    (self.mass * self.length * self.length + self.momentOfInertia)
//            let ks = self.springConstant / 
//                    (self.mass * self.length * self.length + self.momentOfInertia)
//            let kb = self.damping / 
//                    (self.mass * self.length * self.length + self.momentOfInertia)
//            
//            return ka * sin(state[0]) - ks * state[0] - kb * state[1]
//        }
//        
//        currentTime += timeStep
//        currentState = PendulumState(
//            theta: newValues[0],
//            thetaDot: newValues[1],
//            time: currentTime
//        )
//        
//        return currentState
//    }
//    
//    func compareWithReference() -> Double {
//        // Find corresponding reference state
//        guard let refState = referenceData.first(where: { data in
//            abs(data.time - currentTime) < timeStep/2
//        }) else {
//            return 0
//        }
//        
//        // Calculate RMS error
//        let posError = pow(currentState.theta - refState.position, 2)
//        let velError = pow(currentState.thetaDot - refState.velocity, 2)
//        return sqrt((posError + velError) / 2)
//    }
//}
