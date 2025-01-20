extension PendulumSimulation {
    func parseCSV(from data: String) -> [[String: Double]] {
        var results: [[String: Double]] = []
        let rows = data.components(separatedBy: .newlines)
        
        guard let headerRow = rows.first else { return [] }
        let headers = headerRow.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        for row in rows.dropFirst() {
            let values = row.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            var rowDict: [String: Double] = [:]
            for (index, value) in values.enumerated() {
                if index < headers.count {
                    rowDict[headers[index]] = Double(value) ?? 0.0
                }
            }
            if !rowDict.isEmpty {
                results.append(rowDict)
            }
        }
        
        return results
    }
    
    func loadSimulationData() {
        guard let inputURL = Bundle.main.url(forResource: "inputPendulumSim", withExtension: "csv"),
              let outputURL = Bundle.main.url(forResource: "OutputPendulumSim", withExtension: "csv"),
              let inputData = try? String(contentsOf: inputURL),
              let outputData = try? String(contentsOf: outputURL) else {
            return
        }
        
        let inputRows = parseCSV(from: inputData)
        let outputRows = parseCSV(from: outputData)
        
        // Parse input commands
        inputCommands = inputRows.compactMap { row in
            guard let time = row["Time"],
                  let command = row["Command"] else {
                return nil
            }
            return PendulumSimData(time: time, position: 0, velocity: 0, command: command)
        }
        
        // Parse output reference data
        referenceData = outputRows.compactMap { row in
            guard let time = row["Time"],
                  let position = row["Position"],
                  let velocity = row["Velocity"] else {
                return nil
            }
            return PendulumSimData(time: time, position: position, velocity: velocity)
        }
        
        // Extract kj if present
        if let firstRow = inputRows.first {
            kj = firstRow["kj"] ?? 0.0
        }
    }
}
