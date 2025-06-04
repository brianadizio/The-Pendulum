import Foundation
import Accelerate

// MARK: - Metrics Calculator
class MetricsCalculator {
    
    // MARK: - Properties
    internal var angleHistory: [(time: Double, angle: Double)] = []
    private var velocityHistory: [(time: Double, velocity: Double)] = []
    private var forceHistory: [(time: Double, force: Double, direction: String)] = []
    private var energyHistory: [(time: Double, kinetic: Double, potential: Double)] = []
    internal var phaseSpaceHistory: [(theta: Double, omega: Double)] = []
    
    private let maxHistorySize = 10000
    private var sessionStartTime: Date = Date()
    
    // System parameters
    internal var mass: Double = 1.0
    internal var length: Double = 1.0
    internal var gravity: Double = 9.81
    
    // MARK: - Initialization
    init() {
        reset()
    }
    
    func reset() {
        angleHistory.removeAll()
        velocityHistory.removeAll()
        forceHistory.removeAll()
        energyHistory.removeAll()
        phaseSpaceHistory.removeAll()
        sessionStartTime = Date()
    }
    
    func updateSystemParameters(mass: Double, length: Double, gravity: Double) {
        self.mass = mass
        self.length = length
        self.gravity = gravity
    }
    
    // MARK: - Data Collection
    func recordState(time: Double, angle: Double, velocity: Double) {
        // Store state data
        angleHistory.append((time: time, angle: angle))
        velocityHistory.append((time: time, velocity: velocity))
        phaseSpaceHistory.append((theta: angle, omega: velocity))
        
        // Calculate and store energy
        let kinetic = 0.5 * mass * pow(length * velocity, 2)
        let potential = mass * gravity * length * (1 - cos(angle))
        energyHistory.append((time: time, kinetic: kinetic, potential: potential))
        
        // Maintain history size
        trimHistory()
    }
    
    func recordForce(time: Double, force: Double, direction: String) {
        forceHistory.append((time: time, force: force, direction: direction))
        
        // Maintain history size
        if forceHistory.count > maxHistorySize {
            forceHistory.removeFirst()
        }
    }
    
    private func trimHistory() {
        if angleHistory.count > maxHistorySize {
            angleHistory.removeFirst()
            velocityHistory.removeFirst()
            phaseSpaceHistory.removeFirst()
            energyHistory.removeFirst()
        }
    }
    
    // MARK: - Basic Metrics
    
    func calculateBalanceDuration(threshold: Double = 0.1) -> Double {
        guard !angleHistory.isEmpty else { return 0 }
        
        var totalBalanceTime = 0.0
        var inBalance = false
        var balanceStartTime = 0.0
        
        for (i, entry) in angleHistory.enumerated() {
            let angleFromVertical = abs(normalizeAngle(entry.angle - Double.pi))
            
            if angleFromVertical <= threshold {
                if !inBalance {
                    inBalance = true
                    balanceStartTime = entry.time
                }
            } else {
                if inBalance {
                    totalBalanceTime += entry.time - balanceStartTime
                    inBalance = false
                }
            }
            
            // Handle case where still in balance at end
            if i == angleHistory.count - 1 && inBalance {
                totalBalanceTime += entry.time - balanceStartTime
            }
        }
        
        return totalBalanceTime
    }
    
    func calculatePushCount() -> Int {
        return forceHistory.count
    }
    
    func calculateSessionTime() -> Double {
        return Date().timeIntervalSince(sessionStartTime)
    }
    
    // MARK: - Advanced Metrics
    
    func calculateResponseDelay() -> Double {
        guard angleHistory.count > 10 && forceHistory.count > 0 else { return 0 }
        
        var delays: [Double] = []
        let instabilityThreshold = 0.2 // radians
        
        // Find moments of instability and subsequent corrections
        for i in 1..<angleHistory.count {
            let angle = angleHistory[i].angle
            let prevAngle = angleHistory[i-1].angle
            let angleFromVertical = abs(normalizeAngle(angle - Double.pi))
            
            // Detect when pendulum starts becoming unstable
            if angleFromVertical > instabilityThreshold && abs(normalizeAngle(prevAngle - Double.pi)) <= instabilityThreshold {
                let instabilityTime = angleHistory[i].time
                
                // Find next force application
                if let nextForce = forceHistory.first(where: { $0.time > instabilityTime }) {
                    let delay = nextForce.time - instabilityTime
                    if delay < 2.0 { // Reasonable response time
                        delays.append(delay)
                    }
                }
            }
        }
        
        return delays.isEmpty ? 0 : delays.reduce(0, +) / Double(delays.count)
    }
    
    func calculateForceDistribution() -> [Double] {
        // Removed debug print - force history count
        guard !forceHistory.isEmpty else {
            // Removed debug print
            return []
        }
        let magnitudes = forceHistory.map { abs($0.force) }
        // Removed debug print - force magnitudes
        let distribution = createHistogram(data: magnitudes, bins: 20)
        // Removed debug print
        return distribution
    }
    
    func calculateInputFrequencySpectrum() -> [Double] {
        guard forceHistory.count > 10 else { return [] }
        
        // Create time series of force applications
        let sampleRate = 60.0 // Hz
        let duration = (forceHistory.last?.time ?? 0) - (forceHistory.first?.time ?? 0)
        let sampleCount = Int(duration * sampleRate)
        
        guard sampleCount > 0 else { return [] }
        
        var timeSeries = [Double](repeating: 0, count: sampleCount)
        
        // Fill time series
        for force in forceHistory {
            let index = Int((force.time - (forceHistory.first?.time ?? 0)) * sampleRate)
            if index >= 0 && index < sampleCount {
                timeSeries[index] = force.force
            }
        }
        
        // Perform FFT
        return performFFT(timeSeries)
    }
    
    // MARK: - Scientific Metrics
    
    func calculatePhaseSpaceCoverage() -> Double {
        // Removed debug print - phase space history count
        guard phaseSpaceHistory.count > 100 else {
            // Removed debug print - insufficient data
            return 0
        }
        
        // Define phase space bounds
        let thetaBounds = (-Double.pi, Double.pi)
        let omegaBounds = (-10.0, 10.0)
        
        // Create 2D grid
        let gridSize = 50
        var grid = [[Bool]](repeating: [Bool](repeating: false, count: gridSize), count: gridSize)
        
        // Mark visited cells
        for point in phaseSpaceHistory {
            // Skip invalid points
            guard !point.theta.isNaN && !point.theta.isInfinite &&
                  !point.omega.isNaN && !point.omega.isInfinite else { continue }
            
            let thetaNorm = (point.theta - thetaBounds.0) / (thetaBounds.1 - thetaBounds.0)
            let omegaNorm = (point.omega - omegaBounds.0) / (omegaBounds.1 - omegaBounds.0)
            
            // Ensure normalized values are valid
            guard thetaNorm >= 0 && thetaNorm <= 1 &&
                  omegaNorm >= 0 && omegaNorm <= 1 else { continue }
            
            let i = Int(thetaNorm * Double(gridSize - 1)).clamped(to: 0...(gridSize-1))
            let j = Int(omegaNorm * Double(gridSize - 1)).clamped(to: 0...(gridSize-1))
            
            grid[i][j] = true
        }
        
        // Calculate coverage
        let visitedCells = grid.flatMap { $0 }.filter { $0 }.count
        let totalCells = gridSize * gridSize
        
        let coverage = Double(visitedCells) / Double(totalCells) * 100.0
        // Removed debug print - phase space coverage
        
        // Validate result
        if coverage.isNaN || coverage.isInfinite {
            print("ERROR: calculatePhaseSpaceCoverage produced NaN/Infinite: \(coverage)")
            return 0.0
        }
        
        return coverage
    }
    
    func calculateEnergyManagementEfficiency() -> Double {
        // Removed debug print - energy history count
        guard energyHistory.count > 10 else {
            // Removed debug print - insufficient energy data
            return 0
        }
        
        // Calculate total energy at each time point
        let totalEnergies = energyHistory.map { $0.kinetic + $0.potential }
        
        // Calculate energy variance (lower is better)
        let meanEnergy = totalEnergies.reduce(0, +) / Double(totalEnergies.count)
        
        // Handle edge case where mean energy is zero or very small
        guard meanEnergy > 0.001 else { return 100.0 } // Perfect efficiency if no energy
        
        let variance = totalEnergies.map { pow($0 - meanEnergy, 2) }.reduce(0, +) / Double(totalEnergies.count)
        
        // Convert to efficiency score (0-100)
        let normalizedVariance = min(variance / (meanEnergy * meanEnergy), 1.0)
        let efficiency = (1.0 - normalizedVariance) * 100.0
        
        // Removed debug print
        
        // Validate result
        if efficiency.isNaN || efficiency.isInfinite {
            print("ERROR: calculateEnergyManagementEfficiency produced NaN/Infinite: \(efficiency)")
            return 0.0
        }
        
        return efficiency
    }
    
    func calculateLyapunovExponent() -> Double {
        // Removed debug print - angle history count
        guard angleHistory.count > 1000 else {
            // Removed debug print - insufficient lyapunov data
            return 0
        }
        
        // Simplified Lyapunov exponent calculation
        var lyapunovSum = 0.0
        var validCount = 0
        let dt = 0.01
        
        for i in 1..<angleHistory.count-1 {
            let angle = angleHistory[i].angle
            let velocity = velocityHistory[i].velocity
            
            // Calculate local divergence rate
            let jacobian = calculateJacobian(angle: angle, velocity: velocity)
            let eigenvalue = maxEigenvalue(jacobian)
            
            // Only include positive eigenvalues for log calculation
            if eigenvalue > 0.0001 { // Small positive threshold to avoid log(0)
                let logValue = log(eigenvalue)
                // Check for NaN before accumulating
                if !logValue.isNaN && !logValue.isInfinite {
                    lyapunovSum += logValue
                    validCount += 1
                } else {
                    print("WARNING: calculateLyapunovExponent - log produced NaN/Infinite for eigenvalue: \(eigenvalue)")
                }
            }
        }
        
        // Return 0 if no valid eigenvalues were found
        guard validCount > 0 else {
            // Removed debug print
            return 0
        }
        
        let exponent = lyapunovSum / Double(validCount) / dt
        // Removed debug print
        
        // Validate result
        if exponent.isNaN || exponent.isInfinite {
            print("ERROR: calculateLyapunovExponent produced NaN/Infinite: \(exponent)")
            return 0.0
        }
        
        return exponent
    }
    
    func identifyControlStrategy() -> String {
        guard forceHistory.count > 20 else { return "Insufficient Data" }
        
        // Analyze force patterns
        let forceMagnitudes = forceHistory.map { abs($0.force) }
        let meanForce = forceMagnitudes.reduce(0, +) / Double(forceMagnitudes.count)
        let forceVariance = forceMagnitudes.map { pow($0 - meanForce, 2) }.reduce(0, +) / Double(forceMagnitudes.count)
        
        // Analyze timing patterns
        var forceIntervals: [Double] = []
        for i in 1..<forceHistory.count {
            forceIntervals.append(forceHistory[i].time - forceHistory[i-1].time)
        }
        let meanInterval = forceIntervals.reduce(0, +) / Double(forceIntervals.count)
        let intervalVariance = forceIntervals.map { pow($0 - meanInterval, 2) }.reduce(0, +) / Double(forceIntervals.count)
        
        // Classify strategy
        if forceVariance < 0.1 && intervalVariance < 0.1 {
            return "Steady Rhythm"
        } else if forceVariance > 0.5 && intervalVariance < 0.2 {
            return "Variable Force"
        } else if forceVariance < 0.2 && intervalVariance > 0.5 {
            return "Reactive Timing"
        } else if meanForce < 0.3 {
            return "Gentle Touch"
        } else if meanForce > 0.7 {
            return "Aggressive Control"
        } else {
            return "Adaptive Mixed"
        }
    }
    
    func calculateStateTransitionFrequency() -> Double {
        guard angleHistory.count > 100 else { return 0 }
        
        // Define state regions
        let states = definePhaseSpaceStates()
        var currentState = getState(angle: angleHistory[0].angle, velocity: velocityHistory[0].velocity, states: states)
        var transitionCount = 0
        
        for i in 1..<angleHistory.count {
            let newState = getState(angle: angleHistory[i].angle, velocity: velocityHistory[i].velocity, states: states)
            if newState != currentState {
                transitionCount += 1
                currentState = newState
            }
        }
        
        let duration = angleHistory.last!.time - angleHistory.first!.time
        return Double(transitionCount) / duration
    }
    
    func calculateAngularDeviation() -> Double {
        guard !angleHistory.isEmpty else { return 0 }
        
        // Calculate standard deviation from vertical
        let verticalAngles = angleHistory.map { abs(normalizeAngle($0.angle - Double.pi)) }
        let mean = verticalAngles.reduce(0, +) / Double(verticalAngles.count)
        let variance = verticalAngles.map { pow($0 - mean, 2) }.reduce(0, +) / Double(verticalAngles.count)
        
        return sqrt(variance)
    }
    
    // MARK: - Educational Metrics
    
    func calculateLearningCurve(sessions: [SessionData]) -> Double {
        guard sessions.count >= 3 else { return 0 }
        
        // Extract stability scores over time
        let scores = sessions.map { $0.stabilityScore }
        let times = sessions.enumerated().map { Double($0.offset) }
        
        // Calculate linear regression slope
        return calculateLinearRegressionSlope(x: times, y: scores)
    }
    
    func calculateAdaptationRate(parameterChanges: [(time: Double, parameter: String, oldValue: Double, newValue: Double)]) -> Double {
        guard parameterChanges.count > 0 && angleHistory.count > 100 else { return 0 }
        
        var adaptationRates: [Double] = []
        
        for change in parameterChanges {
            // Find stability before and after parameter change
            let windowSize = 5.0 // seconds
            
            let beforeStability = calculateWindowedStability(
                around: change.time - windowSize/2,
                window: windowSize
            )
            
            let afterStability = calculateWindowedStability(
                around: change.time + windowSize/2,
                window: windowSize
            )
            
            if beforeStability > 0 {
                let adaptationRate = afterStability / beforeStability
                adaptationRates.append(adaptationRate)
            }
        }
        
        return adaptationRates.isEmpty ? 0 : adaptationRates.reduce(0, +) / Double(adaptationRates.count)
    }
    
    func analyzeFailureModes() -> [String: Int] {
        guard angleHistory.count > 100 else { return [:] }
        
        var failureModes: [String: Int] = [:]
        let failureThreshold = Double.pi / 3 // 60 degrees
        
        for i in 1..<angleHistory.count {
            let angle = angleHistory[i].angle
            let prevAngle = angleHistory[i-1].angle
            let velocity = velocityHistory[i].velocity
            
            // Check if this is a failure point
            if abs(normalizeAngle(angle - Double.pi)) > failureThreshold &&
               abs(normalizeAngle(prevAngle - Double.pi)) <= failureThreshold {
                
                // Classify failure mode
                let mode: String
                if abs(velocity) > 5.0 {
                    mode = "Excessive Velocity"
                } else if forceHistory.last(where: { $0.time < angleHistory[i].time })?.force ?? 0 > 0.8 {
                    mode = "Overcorrection"
                } else if i > 10 && analyzeOscillationPattern(endIndex: i) {
                    mode = "Unstable Oscillation"
                } else {
                    mode = "Gradual Drift"
                }
                
                failureModes[mode, default: 0] += 1
            }
        }
        
        return failureModes
    }
    
    // MARK: - Detailed Metrics
    
    func calculateControlEffort() -> Double {
        guard !forceHistory.isEmpty else { return 0 }
        
        // Integrate absolute force over time
        var totalEffort = 0.0
        
        for i in 1..<forceHistory.count {
            let dt = forceHistory[i].time - forceHistory[i-1].time
            let avgForce = (abs(forceHistory[i].force) + abs(forceHistory[i-1].force)) / 2.0
            totalEffort += avgForce * dt
        }
        
        return totalEffort
    }
    
    func calculateForceTimingAccuracy() -> Double {
        guard angleHistory.count > 100 && forceHistory.count > 10 else { return 0 }
        
        var correlations: [Double] = []
        
        for force in forceHistory {
            // Find pendulum state at force time
            if let stateIndex = angleHistory.firstIndex(where: { $0.time >= force.time }) {
                let angle = angleHistory[stateIndex].angle
                let velocity = velocityHistory[stateIndex].velocity
                
                // Calculate optimal force direction
                let optimalDirection = velocity > 0 ? "left" : "right"
                let actualDirection = force.direction
                
                // Calculate timing score based on angle and velocity
                let angleFromVertical = normalizeAngle(angle - Double.pi)
                let timingScore = actualDirection == optimalDirection ? 1.0 : -1.0
                
                // Weight by how critical the timing was
                let weight = abs(angleFromVertical)
                correlations.append(timingScore * weight)
            }
        }
        
        return correlations.isEmpty ? 0 : correlations.reduce(0, +) / Double(correlations.count)
    }
    
    func analyzeCorrectionPatterns() -> [String: Double] {
        guard forceHistory.count > 20 else { return [:] }
        
        var patterns: [String: Int] = [:]
        
        for i in 2..<forceHistory.count {
            let f1 = forceHistory[i-2]
            let f2 = forceHistory[i-1]
            let f3 = forceHistory[i]
            
            let pattern: String
            
            // Identify pattern
            if f1.direction == f2.direction && f2.direction == f3.direction {
                pattern = "Sustained \(f1.direction)"
            } else if f1.direction != f2.direction && f2.direction != f3.direction {
                pattern = "Alternating"
            } else if abs(f2.force) > abs(f1.force) && abs(f3.force) > abs(f2.force) {
                pattern = "Escalating"
            } else if abs(f2.force) < abs(f1.force) && abs(f3.force) < abs(f2.force) {
                pattern = "De-escalating"
            } else {
                pattern = "Mixed"
            }
            
            patterns[pattern, default: 0] += 1
        }
        
        // Convert to percentages
        let total = patterns.values.reduce(0, +)
        var percentages: [String: Double] = [:]
        for (pattern, count) in patterns {
            percentages[pattern] = Double(count) / Double(total) * 100.0
        }
        
        return percentages
    }
    
    // MARK: - Performance Metrics
    
    func calculateRealtimeStability() -> Double {
        guard angleHistory.count > 10 else { return 0 }
        
        // Use last 1 second of data
        let currentTime = angleHistory.last?.time ?? 0
        let recentAngles = angleHistory.filter { currentTime - $0.time < 1.0 }.map { $0.angle }
        
        guard !recentAngles.isEmpty else { return 0 }
        
        // Calculate variance
        let mean = recentAngles.reduce(0, +) / Double(recentAngles.count)
        let variance = recentAngles.map { pow($0 - mean, 2) }.reduce(0, +) / Double(recentAngles.count)
        
        return variance
    }
    
    // MARK: - Helper Functions
    
    internal func normalizeAngle(_ angle: Double) -> Double {
        return atan2(sin(angle), cos(angle))
    }
    
    private func createHistogram(data: [Double], bins: Int) -> [Double] {
        // Removed debug print
        guard !data.isEmpty && bins > 0 else {
            // Removed debug print
            return []
        }
        
        let minValue = data.min() ?? 0
        let maxValue = data.max() ?? 1
        // Removed debug print
        
        // Handle case where all values are the same
        if maxValue == minValue {
            var histogram = [Double](repeating: 0, count: bins)
            histogram[bins/2] = 1.0 // Put all data in middle bin
            return histogram
        }
        
        let binWidth = (maxValue - minValue) / Double(bins)
        // Removed debug print
        
        // Check for NaN in binWidth
        if binWidth.isNaN || binWidth.isInfinite || binWidth == 0 {
            print("ERROR: createHistogram - invalid binWidth: \(binWidth)")
            return [Double](repeating: 0, count: bins)
        }
        
        var histogram = [Double](repeating: 0, count: bins)
        
        for value in data {
            // Validate value before calculation
            if value.isNaN || value.isInfinite {
                print("WARNING: createHistogram - skipping NaN/Infinite value: \(value)")
                continue
            }
            
            let binIndex = min(Int((value - minValue) / binWidth), bins - 1)
            if binIndex >= 0 && binIndex < bins {
                histogram[binIndex] += 1
            } else {
                print("WARNING: createHistogram - invalid binIndex: \(binIndex) for value: \(value)")
            }
        }
        
        // Normalize
        let total = Double(data.count)
        if total > 0 {
            let normalized = histogram.map { $0 / total }
            // Removed debug print
            return normalized
        } else {
            print("WARNING: createHistogram - total is 0, returning zeros")
            return [Double](repeating: 0, count: bins)
        }
    }
    
    private func performFFT(_ data: [Double]) -> [Double] {
        // Simplified FFT using vDSP
        let n = data.count
        let log2n = Int(log2(Double(n)))
        let fftSize = 1 << log2n
        
        // Pad to power of 2
        var paddedData = data
        if fftSize > n {
            paddedData.append(contentsOf: [Double](repeating: 0, count: fftSize - n))
        }
        
        // Perform FFT (simplified - would use vDSP in production)
        var spectrum = [Double](repeating: 0, count: fftSize/2)
        
        for k in 0..<fftSize/2 {
            var real = 0.0
            var imag = 0.0
            
            for n in 0..<fftSize {
                let angle = -2.0 * Double.pi * Double(k) * Double(n) / Double(fftSize)
                real += paddedData[n] * cos(angle)
                imag += paddedData[n] * sin(angle)
            }
            
            spectrum[k] = sqrt(real * real + imag * imag) / Double(fftSize)
        }
        
        return spectrum
    }
    
    private func calculateJacobian(angle: Double, velocity: Double) -> [[Double]] {
        // Jacobian matrix for pendulum dynamics
        let a = gravity / length
        
        return [
            [0, 1],
            [-a * cos(angle), 0]
        ]
    }
    
    private func maxEigenvalue(_ matrix: [[Double]]) -> Double {
        // For 2x2 matrix, calculate eigenvalues analytically
        let a = matrix[0][0]
        let b = matrix[0][1]
        let c = matrix[1][0]
        let d = matrix[1][1]
        
        let trace = a + d
        let det = a * d - b * c
        
        let discriminant = trace * trace - 4 * det
        guard discriminant >= 0 else { return 0 }
        
        let lambda1 = (trace + sqrt(discriminant)) / 2
        let lambda2 = (trace - sqrt(discriminant)) / 2
        
        return max(abs(lambda1), abs(lambda2))
    }
    
    private func calculateLinearRegressionSlope(x: [Double], y: [Double]) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0 }
        
        // Filter out any NaN or infinite values
        let validPairs = zip(x, y).filter { !$0.0.isNaN && !$0.0.isInfinite && !$0.1.isNaN && !$0.1.isInfinite }
        guard validPairs.count > 1 else { return 0 }
        
        let validX = validPairs.map { $0.0 }
        let validY = validPairs.map { $0.1 }
        
        let n = Double(validX.count)
        let sumX = validX.reduce(0, +)
        let sumY = validY.reduce(0, +)
        let sumXY = zip(validX, validY).map(*).reduce(0, +)
        let sumXSquare = validX.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = n * sumXSquare - sumX * sumX
        
        // Check for near-zero denominator to avoid division by zero
        guard abs(denominator) > 0.0001 else { return 0 }
        
        return numerator / denominator
    }
    
    private func definePhaseSpaceStates() -> [(name: String, thetaRange: ClosedRange<Double>, omegaRange: ClosedRange<Double>)] {
        return [
            ("Stable Upright", (Double.pi - 0.2)...(Double.pi + 0.2), -1.0...1.0),
            ("Swinging Left", 0.0...(Double.pi - 0.2), -5.0...0.0),
            ("Swinging Right", (Double.pi + 0.2)...(2 * Double.pi), 0.0...5.0),
            ("Fast Rotation", (-Double.pi)...Double.pi, 5.0...10.0),
            ("Chaotic", (-Double.pi)...Double.pi, -10.0...10.0)
        ]
    }
    
    private func getState(angle: Double, velocity: Double, states: [(name: String, thetaRange: ClosedRange<Double>, omegaRange: ClosedRange<Double>)]) -> String {
        let normalizedAngle = normalizeAngle(angle)
        
        for state in states {
            if state.thetaRange.contains(normalizedAngle) && state.omegaRange.contains(velocity) {
                return state.name
            }
        }
        
        return "Unknown"
    }
    
    private func calculateWindowedStability(around time: Double, window: Double) -> Double {
        let relevantAngles = angleHistory.filter {
            abs($0.time - time) <= window / 2
        }.map { $0.angle }
        
        guard !relevantAngles.isEmpty else { return 0 }
        
        let verticalAngles = relevantAngles.map { abs(normalizeAngle($0 - Double.pi)) }
        let mean = verticalAngles.reduce(0, +) / Double(verticalAngles.count)
        
        return 1.0 / (1.0 + mean) // Higher stability for lower deviation
    }
    
    private func analyzeOscillationPattern(endIndex: Int) -> Bool {
        guard endIndex > 20 else { return false }
        
        // Check for growing oscillations
        let windowSize = 10
        var amplitudes: [Double] = []
        
        for i in (endIndex - windowSize)...endIndex {
            let angle = angleHistory[i].angle
            amplitudes.append(abs(normalizeAngle(angle - Double.pi)))
        }
        
        // Check if amplitudes are increasing
        let firstHalf = Array(amplitudes[0..<windowSize/2])
        let secondHalf = Array(amplitudes[windowSize/2..<windowSize])
        
        let firstMean = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondMean = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        return secondMean > firstMean * 1.2 // 20% growth indicates unstable oscillation
    }
    
}

// MARK: - Supporting Types
struct SessionData {
    let sessionId: UUID
    let timestamp: Date
    let stabilityScore: Double
    let duration: Double
    let level: Int
}

// MARK: - Extensions
extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.max(range.lowerBound, Swift.min(self, range.upperBound))
    }
}