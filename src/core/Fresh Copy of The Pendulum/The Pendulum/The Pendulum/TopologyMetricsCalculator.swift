import Foundation

// MARK: - Topology Metrics Extension for MetricsCalculator
extension MetricsCalculator {
    
    // MARK: - Winding Number
    /// Calculates the winding number - how many times the pendulum completes a full rotation
    func calculateWindingNumber() -> Double {
        print("DEBUG: calculateWindingNumber - history count: \(angleHistory.count)")
        guard angleHistory.count > 10 else {
            print("DEBUG: calculateWindingNumber - insufficient data, returning 0")
            return 0
        }
        
        var windingNumber = 0.0
        var previousAngle = angleHistory[0].angle
        
        for i in 1..<angleHistory.count {
            let currentAngle = angleHistory[i].angle
            let deltaAngle = currentAngle - previousAngle
            
            // Handle angle wrapping
            if deltaAngle > Double.pi {
                windingNumber -= 1
            } else if deltaAngle < -Double.pi {
                windingNumber += 1
            }
            
            previousAngle = currentAngle
        }
        
        // Add the continuous part
        let totalAngleChange = angleHistory.last!.angle - angleHistory.first!.angle
        windingNumber += totalAngleChange / (2 * Double.pi)
        
        return windingNumber
    }
    
    // MARK: - Rotation Number
    /// Calculates the average rotation rate (asymptotic winding number per unit time)
    func calculateRotationNumber() -> Double {
        print("DEBUG: calculateRotationNumber - history count: \(angleHistory.count)")
        guard angleHistory.count > 100 else {
            print("DEBUG: calculateRotationNumber - insufficient data, returning 0")
            return 0
        }
        
        // Safely get time span
        guard let firstTime = angleHistory.first?.time,
              let lastTime = angleHistory.last?.time else {
            print("ERROR: calculateRotationNumber - no time data available")
            return 0
        }
        
        let timeSpan = lastTime - firstTime
        guard timeSpan > 0 else {
            print("ERROR: calculateRotationNumber - timeSpan is 0 or negative: \(timeSpan)")
            return 0
        }
        
        let windingNumber = calculateWindingNumber()
        let rotationNumber = windingNumber / timeSpan
        print("DEBUG: calculateRotationNumber - winding: \(windingNumber), timeSpan: \(timeSpan), rotation: \(rotationNumber)")
        
        // Validate result
        if rotationNumber.isNaN || rotationNumber.isInfinite {
            print("ERROR: calculateRotationNumber produced NaN/Infinite: \(rotationNumber)")
            return 0.0
        }
        
        return rotationNumber
    }
    
    // MARK: - Homoclinic Tangle Detection
    /// Detects the presence and complexity of homoclinic tangles
    func detectHomoclinicTangle() -> Double {
        guard phaseSpaceHistory.count > 500 else { return 0 }
        
        // Identify the separatrix (stable manifold of the inverted equilibrium)
        let separatrixEnergy = mass * gravity * length * 2 // Energy at inverted position
        
        var tangleComplexity = 0.0
        var crossingPoints: [(theta: Double, omega: Double)] = []
        
        // Find points near the separatrix
        for point in phaseSpaceHistory {
            // Calculate energy with NaN protection
            let kineticEnergy = 0.5 * mass * pow(length * point.omega, 2)
            let cosTheta = cos(point.theta)
            
            // Check for NaN in cos calculation
            if cosTheta.isNaN || cosTheta.isInfinite {
                print("WARNING: detectHomoclinicTangle - cos produced NaN/Infinite for theta: \(point.theta)")
                continue
            }
            
            let potentialEnergy = mass * gravity * length * (1 - cosTheta)
            let energy = kineticEnergy + potentialEnergy
            
            if abs(energy - separatrixEnergy) < 0.1 * separatrixEnergy {
                crossingPoints.append(point)
            }
        }
        
        // Analyze the complexity of crossings
        if crossingPoints.count > 10 {
            // Calculate the fractal dimension of crossing points
            tangleComplexity = calculateBoxCountingDimension(points: crossingPoints)
        }
        
        return tangleComplexity
    }
    
    // MARK: - Periodic Orbit Count
    /// Counts the number of distinct periodic orbits observed
    func countPeriodicOrbits() -> Int {
        guard phaseSpaceHistory.count > 1000 else { return 0 }
        
        var periodicOrbits = 0
        let tolerance = 0.1
        let minPeriod = 10 // Minimum points for a period
        
        // Use a sliding window to detect periodic behavior
        for startIdx in 0..<(phaseSpaceHistory.count - 2 * minPeriod) {
            let startPoint = phaseSpaceHistory[startIdx]
            
            // Look for return to near the starting point
            for endIdx in (startIdx + minPeriod)..<min(startIdx + 1000, phaseSpaceHistory.count) {
                let endPoint = phaseSpaceHistory[endIdx]
                
                let distance = sqrt(pow(endPoint.theta - startPoint.theta, 2) + pow(endPoint.omega - startPoint.omega, 2))
                
                if distance < tolerance {
                    // Check if this is a new periodic orbit
                    if isNewPeriodicOrbit(startIdx: startIdx, period: endIdx - startIdx) {
                        periodicOrbits += 1
                    }
                    break
                }
            }
        }
        
        return periodicOrbits
    }
    
    // MARK: - Basin Stability
    /// Calculates the stability of the basin of attraction
    func calculateBasinStability() -> Double {
        guard angleHistory.count > 100 else { return 0 }
        
        // Define the stable region (pendulum near upright)
        let stableThreshold = 0.5 // radians from vertical
        var timeInStableBasin = 0.0
        
        for i in 1..<angleHistory.count {
            let angle = normalizeAngle(angleHistory[i].angle - Double.pi)
            if abs(angle) < stableThreshold {
                timeInStableBasin += angleHistory[i].time - angleHistory[i-1].time
            }
        }
        
        let totalTime = angleHistory.last!.time - angleHistory.first!.time
        guard totalTime > 0 else { return 0 }
        
        return (timeInStableBasin / totalTime) * 100.0
    }
    
    // MARK: - Topological Entropy
    /// Estimates the topological entropy using symbolic dynamics
    func calculateTopologicalEntropy() -> Double {
        guard phaseSpaceHistory.count > 1000 else { return 0 }
        
        // Partition phase space into regions
        let partitions = createPhaseSpacePartition()
        
        // Create symbolic sequence
        var symbolSequence: [Int] = []
        for point in phaseSpaceHistory {
            let symbol = getSymbol(for: point, partitions: partitions)
            symbolSequence.append(symbol)
        }
        
        // Calculate entropy from symbol sequences
        let entropy = calculateSymbolicEntropy(sequence: symbolSequence)
        
        return entropy
    }
    
    // MARK: - Betti Numbers
    /// Calculates the Betti numbers (topological invariants)
    func calculateBettiNumbers() -> [Int] {
        guard phaseSpaceHistory.count > 500 else { return [0, 0] }
        
        // For a pendulum phase space:
        // β₀ = number of connected components
        // β₁ = number of holes (1D cycles)
        
        var betti0 = 1 // Assume connected
        var betti1 = 0
        
        // Detect if trajectory explores multiple disconnected regions
        let components = findConnectedComponents()
        betti0 = components.count
        
        // Detect holes in phase space coverage
        let holes = detectTopologicalHoles()
        betti1 = holes
        
        return [betti0, betti1]
    }
    
    // MARK: - Persistent Homology
    /// Calculates persistent homology features
    func calculatePersistentHomology() -> [(birth: Double, death: Double, dimension: Int)] {
        guard phaseSpaceHistory.count > 100 else { return [] }
        
        var features: [(birth: Double, death: Double, dimension: Int)] = []
        
        // Build filtration of phase space
        let radii = [0.1, 0.2, 0.5, 1.0, 2.0]
        
        for (i, radius) in radii.enumerated() {
            let components = findComponentsAtScale(radius: radius)
            let holes = findHolesAtScale(radius: radius)
            
            // Track birth and death of features
            if i == 0 {
                for _ in 0..<components {
                    features.append((birth: 0, death: Double.infinity, dimension: 0))
                }
                for _ in 0..<holes {
                    features.append((birth: radius, death: Double.infinity, dimension: 1))
                }
            } else {
                // Update death times based on changes
                // This is simplified - real persistent homology is more complex
                let prevRadius = radii[i-1]
                if components < features.filter({ $0.dimension == 0 && $0.death == Double.infinity }).count {
                    // Component died
                    if let idx = features.firstIndex(where: { $0.dimension == 0 && $0.death == Double.infinity }) {
                        features[idx].death = prevRadius
                    }
                }
            }
        }
        
        return features.filter { $0.death - $0.birth > 0.1 } // Filter out short-lived features
    }
    
    // MARK: - Separatrix Crossings
    /// Counts the number of separatrix crossings
    func countSeparatrixCrossings() -> Int {
        guard phaseSpaceHistory.count > 100 else { return 0 }
        
        var crossings = 0
        let separatrixEnergy = mass * gravity * length * 2
        let tolerance = 0.05 * separatrixEnergy
        
        var wasAboveSeparatrix = false
        let firstEnergy = calculateEnergy(theta: phaseSpaceHistory[0].theta, omega: phaseSpaceHistory[0].omega)
        wasAboveSeparatrix = firstEnergy > separatrixEnergy
        
        for i in 1..<phaseSpaceHistory.count {
            let energy = calculateEnergy(theta: phaseSpaceHistory[i].theta, omega: phaseSpaceHistory[i].omega)
            let isAboveSeparatrix = energy > separatrixEnergy
            
            // Check for crossing
            if isAboveSeparatrix != wasAboveSeparatrix && abs(energy - separatrixEnergy) < tolerance {
                crossings += 1
            }
            
            wasAboveSeparatrix = isAboveSeparatrix
        }
        
        return crossings
    }
    
    // MARK: - Phase Portrait Structure
    /// Identifies the type of phase portrait structure
    func identifyPhasePortraitStructure() -> String {
        guard phaseSpaceHistory.count > 500 else { return "Insufficient Data" }
        
        let windingNumber = calculateWindingNumber()
        let basinStability = calculateBasinStability()
        let periodicOrbits = countPeriodicOrbits()
        let separatrixCrossings = countSeparatrixCrossings()
        
        // Classify based on observed behavior
        if abs(windingNumber) < 0.1 && basinStability > 80 {
            return "Stable Focus"
        } else if abs(windingNumber) < 0.1 && basinStability > 50 {
            return "Stable Node"
        } else if periodicOrbits > 0 && separatrixCrossings == 0 {
            return "Limit Cycle"
        } else if abs(windingNumber) > 5 {
            return "Rotating"
        } else if separatrixCrossings > 10 {
            return "Chaotic"
        } else if basinStability < 20 {
            return "Unstable Saddle"
        } else {
            return "Mixed Dynamics"
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateEnergy(theta: Double, omega: Double) -> Double {
        return 0.5 * mass * pow(length * omega, 2) + mass * gravity * length * (1 - cos(theta))
    }
    
    private func calculateBoxCountingDimension(points: [(theta: Double, omega: Double)]) -> Double {
        guard points.count > 10 else { return 0 }
        
        // Simplified box-counting dimension
        let boxes = [0.1, 0.05, 0.025, 0.0125]
        var counts: [Double] = []
        
        for boxSize in boxes {
            var coveredBoxes = Set<String>()
            
            for point in points {
                let boxI = Int(point.theta / boxSize)
                let boxJ = Int(point.omega / boxSize)
                coveredBoxes.insert("\(boxI),\(boxJ)")
            }
            
            counts.append(Double(coveredBoxes.count))
        }
        
        // Calculate dimension from scaling
        if counts.count >= 2 {
            let logRatio = log(counts[1] / counts[0]) / log(boxes[0] / boxes[1])
            return logRatio
        }
        
        return 1.0
    }
    
    private func isNewPeriodicOrbit(startIdx: Int, period: Int) -> Bool {
        // Simplified check - in practice would need more sophisticated comparison
        return true
    }
    
    private func createPhaseSpacePartition() -> [(thetaRange: ClosedRange<Double>, omegaRange: ClosedRange<Double>)] {
        return [
            ((-Double.pi)...(-Double.pi/2), (-10.0)...(-5.0)),
            ((-Double.pi/2)...0, (-10.0)...(-5.0)),
            (0...(Double.pi/2), (-10.0)...(-5.0)),
            ((Double.pi/2)...Double.pi, (-10.0)...(-5.0)),
            ((-Double.pi)...(-Double.pi/2), (-5.0)...0),
            ((-Double.pi/2)...0, (-5.0)...0),
            (0...(Double.pi/2), (-5.0)...0),
            ((Double.pi/2)...Double.pi, (-5.0)...0),
            ((-Double.pi)...(-Double.pi/2), 0...5.0),
            ((-Double.pi/2)...0, 0...5.0),
            (0...(Double.pi/2), 0...5.0),
            ((Double.pi/2)...Double.pi, 0...5.0),
            ((-Double.pi)...(-Double.pi/2), 5.0...10.0),
            ((-Double.pi/2)...0, 5.0...10.0),
            (0...(Double.pi/2), 5.0...10.0),
            ((Double.pi/2)...Double.pi, 5.0...10.0)
        ]
    }
    
    private func getSymbol(for point: (theta: Double, omega: Double), partitions: [(thetaRange: ClosedRange<Double>, omegaRange: ClosedRange<Double>)]) -> Int {
        for (index, partition) in partitions.enumerated() {
            if partition.thetaRange.contains(point.theta) && partition.omegaRange.contains(point.omega) {
                return index
            }
        }
        return 0
    }
    
    private func calculateSymbolicEntropy(sequence: [Int]) -> Double {
        guard sequence.count > 100 else { return 0 }
        
        // Calculate Shannon entropy of symbol sequences
        var symbolCounts: [Int: Int] = [:]
        
        for symbol in sequence {
            symbolCounts[symbol, default: 0] += 1
        }
        
        let total = Double(sequence.count)
        var entropy = 0.0
        
        for count in symbolCounts.values {
            let probability = Double(count) / total
            if probability > 0 {
                entropy -= probability * log2(probability)
            }
        }
        
        return entropy
    }
    
    private func findConnectedComponents() -> [[Int]] {
        // Simplified connected components - would use union-find in practice
        return [[0]] // Assume single component for now
    }
    
    private func detectTopologicalHoles() -> Int {
        // Detect holes in phase space coverage
        // Simplified - count regions that are surrounded but not visited
        let gridSize = 20
        var grid = [[Bool]](repeating: [Bool](repeating: false, count: gridSize), count: gridSize)
        
        // Mark visited cells
        for point in phaseSpaceHistory {
            let thetaNormalized = (point.theta + Double.pi) / (2 * Double.pi)
            let i = Int(thetaNormalized * Double(gridSize))
            
            let omegaNormalized = (point.omega + 10) / 20.0
            let j = Int(omegaNormalized * Double(gridSize))
            
            if i >= 0 && i < gridSize && j >= 0 && j < gridSize {
                grid[i][j] = true
            }
        }
        
        // Count holes (simplified)
        var holes = 0
        for i in 1..<(gridSize-1) {
            for j in 1..<(gridSize-1) {
                if !grid[i][j] && grid[i-1][j] && grid[i+1][j] && grid[i][j-1] && grid[i][j+1] {
                    holes += 1
                }
            }
        }
        
        return holes
    }
    
    private func findComponentsAtScale(radius: Double) -> Int {
        // Find connected components at given scale
        // Simplified implementation
        return 1
    }
    
    private func findHolesAtScale(radius: Double) -> Int {
        // Find topological holes at given scale
        // Simplified implementation
        return radius < 1.0 ? 1 : 0
    }
}