import Foundation
import UIKit
import CoreData

// MARK: - Analytics Manager Extensions for Enhanced Metrics
extension AnalyticsManager {
    
    // MARK: - Properties
    private static let metricsCalculatorKey = "metricsCalculator"
    
    private var metricsCalculator: MetricsCalculator {
        get {
            if let calculator = objc_getAssociatedObject(self, AnalyticsManager.metricsCalculatorKey) as? MetricsCalculator {
                return calculator
            } else {
                let calculator = MetricsCalculator()
                objc_setAssociatedObject(self, AnalyticsManager.metricsCalculatorKey, calculator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return calculator
            }
        }
    }
    
    // Session data storage for educational metrics
    private static var sessionHistory: [SessionData] = []
    private static var parameterChangeHistory: [(time: Double, parameter: String, oldValue: Double, newValue: Double)] = []
    
    // Performance monitoring
    private static var performanceMonitor = PerformanceMonitor()
    
    // MARK: - Enhanced Tracking Methods
    
    func trackEnhancedPendulumState(time: Double, angle: Double, angleVelocity: Double) {
        // Track in base analytics
        trackPendulumState(angle: angle, angleVelocity: angleVelocity)
        
        // Track phase space point for trajectory visualization
        trackPhaseSpacePoint(theta: angle, omega: angleVelocity)
        
        // Track in metrics calculator
        metricsCalculator.recordState(time: time, angle: angle, velocity: angleVelocity)
    }
    
    func trackEnhancedInteraction(time: Double, eventType: String, angle: Double, angleVelocity: Double, magnitude: Double, direction: String) {
        // Track in base analytics
        trackInteraction(eventType: eventType, angle: angle, angleVelocity: angleVelocity, magnitude: magnitude, direction: direction)
        
        // Track force in metrics calculator
        if eventType == "push" {
            metricsCalculator.recordForce(time: time, force: magnitude, direction: direction)
        }
    }
    
    func updateSystemParameters(mass: Double, length: Double, gravity: Double) {
        metricsCalculator.updateSystemParameters(mass: mass, length: length, gravity: gravity)
    }
    
    func trackParameterChange(time: Double, parameter: String, oldValue: Double, newValue: Double) {
        AnalyticsManager.parameterChangeHistory.append((time: time, parameter: parameter, oldValue: oldValue, newValue: newValue))
    }
    
    // MARK: - Metric Calculation Methods by Group
    
    func calculateMetrics(for group: MetricGroupType) -> [MetricValue] {
        let metricTypes = MetricGroupDefinition.metrics(for: group)
        var metricValues: [MetricValue] = []
        
        for metricType in metricTypes {
            if let value = calculateMetric(type: metricType) {
                metricValues.append(value)
            }
        }
        
        return metricValues
    }
    
    private func calculateMetric(type: MetricType) -> MetricValue? {
        let timestamp = Date()
        
        print("DEBUG: Calculating metric: \(type.rawValue)")
        
        // Add debugging to catch NaN at the source
        defer {
            // Check after calculation
            print("DEBUG: Finished calculating metric: \(type.rawValue)")
        }
        
        // Create a metric value and check for NaN before returning
        func createMetricValue(_ value: Any, confidence: Double? = nil) -> MetricValue {
            let metricValue = MetricValue(type: type, value: value, timestamp: timestamp, confidence: confidence)
            
            // Check for NaN in the value
            switch value {
            case let doubleValue as Double:
                if doubleValue.isNaN || doubleValue.isInfinite {
                    print("ERROR: NaN/Infinite metric value created for \(type.rawValue): \(doubleValue)")
                    print("DEBUG: Creating metric from group: \(MetricGroupDefinition.group(for: type)?.rawValue ?? "unknown")")
                }
            case let distribution as [Double]:
                for (index, val) in distribution.enumerated() {
                    if val.isNaN || val.isInfinite {
                        print("ERROR: NaN/Infinite in distribution for \(type.rawValue) at index \(index): \(val)")
                        print("DEBUG: Creating metric from group: \(MetricGroupDefinition.group(for: type)?.rawValue ?? "unknown")")
                    }
                }
            case let timeSeries as [(Date, Double)]:
                for (index, point) in timeSeries.enumerated() {
                    if point.1.isNaN || point.1.isInfinite {
                        print("ERROR: NaN/Infinite in time series for \(type.rawValue) at index \(index): \(point.1)")
                        print("DEBUG: Creating metric from group: \(MetricGroupDefinition.group(for: type)?.rawValue ?? "unknown")")
                    }
                }
            default:
                break
            }
            
            return metricValue
        }
        
        switch type {
        // Basic Metrics
        case .stabilityScore:
            let score = calculateStabilityScore()
            print("DEBUG: Stability score calculated: \(score)")
            if score.isNaN || score.isInfinite {
                print("ERROR: NaN/Infinite stability score detected: \(score)")
                return createMetricValue(0.0)
            }
            return createMetricValue(score)
            
        case .balanceDuration:
            let duration = metricsCalculator.calculateBalanceDuration()
            return createMetricValue(duration)
            
        case .pushCount:
            let count = metricsCalculator.calculatePushCount()
            return createMetricValue(count)
            
        case .currentLevel:
            return createMetricValue(getCurrentLevel())
            
        case .sessionTime:
            let time = metricsCalculator.calculateSessionTime()
            return createMetricValue(time)
            
        case .playerStyle:
            let style = determinePlayerStyle(
                stabilityScore: calculateStabilityScore(),
                efficiencyRating: calculateEfficiencyRating(),
                directionalBias: calculateDirectionalBias(),
                overcorrectionRate: calculateOvercorrectionRate()
            )
            return createMetricValue(style)
            
        // Advanced Metrics
        case .efficiencyRating:
            let rating = calculateEfficiencyRating()
            print("DEBUG: Efficiency rating calculated: \(rating)")
            if rating.isNaN || rating.isInfinite {
                print("ERROR: NaN/Infinite efficiency rating detected: \(rating)")
                return createMetricValue(0.0)
            }
            return createMetricValue(rating)
            
        case .directionalBias:
            let bias = calculateDirectionalBias()
            print("DEBUG: Directional bias calculated: \(bias)")
            if bias.isNaN || bias.isInfinite {
                print("ERROR: NaN/Infinite directional bias detected: \(bias)")
                return createMetricValue(0.0)
            }
            return createMetricValue(bias)
            
        case .averageCorrectionTime:
            let avgTime = reactionTimes.isEmpty ? 0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            print("DEBUG: Average correction time calculated: \(avgTime)")
            if avgTime.isNaN || avgTime.isInfinite {
                print("ERROR: NaN/Infinite average correction time detected: \(avgTime)")
                return createMetricValue(0.0)
            }
            return createMetricValue(avgTime)
            
        case .overcorrectionRate:
            let rate = calculateOvercorrectionRate()
            return createMetricValue(rate)
            
        case .forceDistribution:
            let distribution = metricsCalculator.calculateForceDistribution()
            print("DEBUG: Force distribution calculated: \(distribution)")
            // Check for NaN in distribution
            for (index, value) in distribution.enumerated() {
                if value.isNaN || value.isInfinite {
                    print("ERROR: NaN/Infinite in force distribution at index \(index): \(value)")
                }
            }
            // If distribution contains NaN, return empty array to prevent chart errors
            let cleanDistribution = distribution.filter { !$0.isNaN && !$0.isInfinite }
            if cleanDistribution.count != distribution.count {
                print("WARNING: Filtered out \(distribution.count - cleanDistribution.count) NaN/Infinite values from force distribution")
            }
            return createMetricValue(cleanDistribution)
            
        case .pushMagnitudeDistribution:
            // Get push magnitude distribution
            let magnitudeDistribution = getPushMagnitudeDistribution()
            let values = Array(magnitudeDistribution.values.map { Double($0) })
            return createMetricValue(values)
            
        case .reactionTimeAnalysis:
            // Return reaction times as time series
            let reactionTimeSeries = reactionTimes.enumerated().map { index, time in
                (Date().addingTimeInterval(Double(index) * -10), time) // Spaced 10 seconds apart
            }
            return createMetricValue(reactionTimeSeries)
            
        case .levelCompletionsOverTime:
            // Get level completions by time period
            let completions = getLevelCompletionsByTimePeriod()
            return createMetricValue(completions)
            
        case .pendulumParametersOverTime:
            // Return parameter changes over time
            let parameterData = getParameterHistoryTimeSeries()
            return createMetricValue(parameterData)
            
        case .fullDirectionalBias:
            // Return directional bias as distribution for pie chart
            let leftCount = Double(directionalPushes["left"] ?? 0)
            let rightCount = Double(directionalPushes["right"] ?? 0)
            
            // Debug logging
            print("DEBUG: Full Directional Bias - left: \(leftCount), right: \(rightCount)")
            print("DEBUG: Full Directional Bias - directionalPushes: \(directionalPushes)")
            
            let distribution = [leftCount, rightCount]
            return createMetricValue(distribution)
            
        case .inputFrequencySpectrum:
            let spectrum = metricsCalculator.calculateInputFrequencySpectrum()
            return createMetricValue(spectrum)
            
        case .responseDelay:
            let delay = metricsCalculator.calculateResponseDelay()
            return createMetricValue(delay, confidence: 0.8)
            
        // Scientific Metrics
        case .phaseSpaceCoverage:
            let coverage = metricsCalculator.calculatePhaseSpaceCoverage()
            return createMetricValue(coverage)
            
        case .energyManagement:
            let efficiency = metricsCalculator.calculateEnergyManagementEfficiency()
            return createMetricValue(efficiency, confidence: 0.9)
            
        case .lyapunovExponent:
            let exponent = metricsCalculator.calculateLyapunovExponent()
            return createMetricValue(exponent, confidence: 0.7)
            
        case .controlStrategy:
            let strategy = metricsCalculator.identifyControlStrategy()
            return createMetricValue(strategy)
            
        case .stateTransitionFreq:
            let freq = metricsCalculator.calculateStateTransitionFrequency()
            return createMetricValue(freq)
            
        case .angularDeviation:
            // Return time series data for angular deviation
            let timeSeriesData = getInteractionTimeSeries(timeframe: -300) // Last 5 minutes
            let angleTimeSeries = timeSeriesData.map { data -> (Date, Double) in
                let timestamp = data["timestamp"] as? Date ?? Date()
                let angle = data["angle"] as? Double ?? 0
                return (timestamp, angle)
            }
            print("DEBUG: Angular deviation time series: \(angleTimeSeries.count) points")
            // Check for NaN in time series
            for (index, point) in angleTimeSeries.enumerated() {
                if point.1.isNaN || point.1.isInfinite {
                    print("ERROR: NaN/Infinite in angular deviation at index \(index): \(point.1)")
                }
            }
            return createMetricValue(angleTimeSeries)
            
        case .phaseTrajectory:
            // Get average phase space data across all levels
            let averagePhaseData = getAveragePhaseSpaceData()
            
            // Debug: Log phase space data
            print("DEBUG: Phase trajectory - averagePhaseData levels: \(averagePhaseData.keys.sorted())")
            
            // Combine all level data into a single trajectory
            var combinedTrajectory: [(theta: Double, omega: Double)] = []
            
            // If we have saved average data, use it
            if !averagePhaseData.isEmpty {
                // Combine trajectories from all levels
                for level in averagePhaseData.keys.sorted() {
                    if let levelData = averagePhaseData[level] {
                        combinedTrajectory.append(contentsOf: levelData)
                        print("DEBUG: Phase trajectory - added \(levelData.count) points from level \(level)")
                    }
                }
            }
            
            // If no saved data, use current session data
            if combinedTrajectory.isEmpty {
                // Use current phase space points if available
                combinedTrajectory = Array(phaseSpacePoints.suffix(200))
                print("DEBUG: Phase trajectory - using current session data: \(combinedTrajectory.count) points")
            }
            
            // Limit to reasonable number of points for display
            let maxPoints = 500
            if combinedTrajectory.count > maxPoints {
                // Sample evenly across the trajectory
                let stride = combinedTrajectory.count / maxPoints
                combinedTrajectory = stride > 1 ? 
                    Array(combinedTrajectory.enumerated().compactMap { $0.offset % stride == 0 ? $0.element : nil }) :
                    combinedTrajectory
            }
            
            print("DEBUG: Phase trajectory - returning \(combinedTrajectory.count) total points")
            return createMetricValue(combinedTrajectory)
            
        // Educational Metrics
        case .learningCurve:
            // Return time series of stability scores over time
            let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            fetchRequest.fetchLimit = 50 // Last 50 data points
            
            var learningData: [(Date, Double)] = []
            
            let managedContext = CoreDataManager.shared.context
            managedContext.performAndWait {
                do {
                    let metrics = try managedContext.fetch(fetchRequest)
                    learningData = metrics.compactMap { metric in
                        guard let timestamp = metric.timestamp else { return nil }
                        return (timestamp, metric.stabilityScore)
                    }
                } catch {
                    print("Error fetching learning curve data: \(error)")
                }
            }
            
            // If no saved data, use current session data
            if learningData.isEmpty && !angleBuffer.isEmpty {
                let currentStability = calculateStabilityScore()
                learningData = [(Date(), currentStability)]
            }
            
            return createMetricValue(learningData, confidence: 0.85)
            
        case .adaptationRate:
            let rate = metricsCalculator.calculateAdaptationRate(parameterChanges: AnalyticsManager.parameterChangeHistory)
            return createMetricValue(rate)
            
        case .skillRetention:
            let retention = calculateSkillRetention()
            return createMetricValue(retention, confidence: 0.75)
            
        case .failureModeAnalysis:
            let modes = metricsCalculator.analyzeFailureModes()
            return createMetricValue(modes)
            
        case .challengeThreshold:
            let threshold = AnalyticsManager.sessionHistory.map { $0.level }.max() ?? 1
            return createMetricValue(threshold)
            
        case .persistenceScore:
            let persistence = calculatePersistenceScore()
            return createMetricValue(persistence)
            
        case .improvementRate:
            let rate = calculateImprovementRate()
            return createMetricValue(rate, confidence: 0.8)
            
        // Topology Metrics
        case .windingNumber:
            let winding = metricsCalculator.calculateWindingNumber()
            return createMetricValue(winding)
            
        case .rotationNumber:
            let rotation = metricsCalculator.calculateRotationNumber()
            return createMetricValue(rotation, confidence: 0.95)
            
        case .homoclinicTangle:
            let tangleComplexity = metricsCalculator.detectHomoclinicTangle()
            // Convert complexity score to boolean: presence detected if complexity > threshold
            let hasHomoclinicTangle = tangleComplexity > 1.0
            return createMetricValue(hasHomoclinicTangle, confidence: 0.7)
            
        case .periodicOrbitCount:
            let orbits = metricsCalculator.countPeriodicOrbits()
            return createMetricValue(orbits, confidence: 0.8)
            
        case .basinStability:
            let basin = metricsCalculator.calculateBasinStability()
            return createMetricValue(basin)
            
        case .topologicalEntropy:
            let entropy = metricsCalculator.calculateTopologicalEntropy()
            return createMetricValue(entropy, confidence: 0.75)
            
        case .bettinumbers:
            let betti = metricsCalculator.calculateBettiNumbers()
            return createMetricValue(betti, confidence: 0.85)
            
        case .persistentHomology:
            let homology = metricsCalculator.calculatePersistentHomology()
            return createMetricValue(homology, confidence: 0.7)
            
        case .separatrixCrossings:
            let crossings = metricsCalculator.countSeparatrixCrossings()
            return createMetricValue(crossings)
            
        case .phasePortraitStructure:
            let structure = metricsCalculator.identifyPhasePortraitStructure()
            return createMetricValue(structure, confidence: 0.9)
            
        // Performance Metrics
        case .realtimeStability:
            let stability = metricsCalculator.calculateRealtimeStability()
            return createMetricValue(stability)
            
        case .cpuUsage:
            let cpu = AnalyticsManager.performanceMonitor.cpuUsage
            return createMetricValue(cpu)
            
        case .frameRate:
            let fps = AnalyticsManager.performanceMonitor.frameRate
            return createMetricValue(fps)
            
        case .responseLatency:
            let latency = AnalyticsManager.performanceMonitor.responseLatency
            return createMetricValue(latency)
            
        case .memoryEfficiency:
            let memory = AnalyticsManager.performanceMonitor.memoryUsage
            return createMetricValue(memory)
            
        case .batteryImpact:
            let battery = AnalyticsManager.performanceMonitor.batteryImpact
            return createMetricValue(battery, confidence: 0.7)
        }
    }
    
    // MARK: - Additional Calculation Methods
    
    private func calculateSkillRetention() -> Double {
        guard AnalyticsManager.sessionHistory.count >= 2 else { return 0 }
        
        // Compare performance across sessions with time gaps
        var retentionScores: [Double] = []
        
        for i in 1..<AnalyticsManager.sessionHistory.count {
            let prevSession = AnalyticsManager.sessionHistory[i-1]
            let currentSession = AnalyticsManager.sessionHistory[i]
            
            let timeDiff = currentSession.timestamp.timeIntervalSince(prevSession.timestamp)
            let daysSince = timeDiff / 86400 // Convert to days
            
            if daysSince > 1 { // At least 1 day gap
                let expectedDecay = exp(-0.1 * daysSince) // Exponential decay model
                let actualRetention = currentSession.stabilityScore / prevSession.stabilityScore
                let retentionScore = min(actualRetention / expectedDecay, 1.0) * 100
                retentionScores.append(retentionScore)
            }
        }
        
        return retentionScores.isEmpty ? 100 : retentionScores.reduce(0, +) / Double(retentionScores.count)
    }
    
    private func calculatePersistenceScore() -> Double {
        // Calculate average attempts per level
        var attemptsPerLevel: [Int: Int] = [:]
        var successesPerLevel: [Int: Int] = [:]
        
        // This would need to be tracked in actual gameplay
        // For now, return a placeholder
        return 3.5 // Average attempts
    }
    
    private func calculateImprovementRate() -> Double {
        guard AnalyticsManager.sessionHistory.count >= 3 else { return 0 }
        
        // Calculate rate of improvement over last 5 sessions
        let recentSessions = Array(AnalyticsManager.sessionHistory.suffix(5))
        guard recentSessions.count >= 2 else { return 0 }
        
        let firstScore = recentSessions.first!.stabilityScore
        let lastScore = recentSessions.last!.stabilityScore
        let timeSpan = recentSessions.last!.timestamp.timeIntervalSince(recentSessions.first!.timestamp) / 3600 // Hours
        
        guard timeSpan > 0 else { return 0 }
        
        return ((lastScore - firstScore) / firstScore) / timeSpan * 100 // % improvement per hour
    }
    
    private func calculateParameterAdjustmentFrequency() -> Double {
        let sessionDuration = metricsCalculator.calculateSessionTime() / 60 // Convert to minutes
        guard sessionDuration > 0 else { return 0 }
        
        return Double(AnalyticsManager.parameterChangeHistory.count) / sessionDuration
    }
    
    private func calculateModePreferences() -> [String: Double] {
        // This would track which game modes are selected most often
        // For now, return placeholder data
        return [
            "Classic": 45.0,
            "Joshua Tree": 30.0,
            "Zero-G": 15.0,
            "Experiment": 10.0
        ]
    }
    
    private func calculateSuccessRate() -> Double {
        // Calculate percentage of successful balance attempts
        // This would need level completion tracking
        return 75.0 // Placeholder
    }
    
    private func calculatePrecisionScore() -> Double {
        // Measure how precisely the user maintains balance near vertical
        guard !angleBuffer.isEmpty else { return 0 }
        
        let verticalAngles = angleBuffer.suffix(100).map { abs(atan2(sin($0 - Double.pi), cos($0 - Double.pi))) }
        guard !verticalAngles.isEmpty else { return 0 }
        
        // Calculate precision as inverse of variance
        let mean = verticalAngles.reduce(0, +) / Double(verticalAngles.count)
        let variance = verticalAngles.map { pow($0 - mean, 2) }.reduce(0, +) / Double(verticalAngles.count)
        
        // Convert to 0-100 scale
        let maxVariance = 0.1 // radians squared
        let normalizedVariance = min(variance / maxVariance, 1.0)
        
        return (1.0 - normalizedVariance) * 100.0
    }
    
    // MARK: - Session Management
    
    func completeSession(stabilityScore: Double, level: Int) {
        guard let sessionId = currentSessionId else { return }
        
        let sessionData = SessionData(
            sessionId: sessionId,
            timestamp: Date(),
            stabilityScore: stabilityScore,
            duration: metricsCalculator.calculateSessionTime(),
            level: level
        )
        
        AnalyticsManager.sessionHistory.append(sessionData)
        
        // Keep only last 100 sessions
        if AnalyticsManager.sessionHistory.count > 100 {
            AnalyticsManager.sessionHistory.removeFirst()
        }
    }
    
    // MARK: - Real-time Metric Updates
    
    func startRealtimeMetricUpdates(for group: MetricGroupType, updateHandler: @escaping ([MetricValue]) -> Void) {
        // Create timer for metric updates based on group requirements
        let updateInterval = getUpdateInterval(for: group)
        
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            let metrics = self.calculateMetrics(for: group)
            updateHandler(metrics)
        }
    }
    
    private func getUpdateInterval(for group: MetricGroupType) -> TimeInterval {
        switch group {
        case .performance:
            return 0.1 // 10 Hz for performance metrics
        case .basic:
            return 0.5 // 2 Hz for basic metrics
        case .scientific, .advanced:
            return 1.0 // 1 Hz for complex calculations
        case .educational:
            return 5.0 // Every 5 seconds for trend metrics
        case .topology:
            return 2.0 // Every 2 seconds for topological calculations
        }
    }
}

// MARK: - Performance Monitor
private class PerformanceMonitor {
    var cpuUsage: Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return result == KERN_SUCCESS ? Double(info.resident_size) / Double(1024 * 1024) : 0
    }
    
    var frameRate: Double {
        // This would be updated by the rendering system
        return 60.0 // Placeholder
    }
    
    var responseLatency: Double {
        // Measure input to response latency
        return 16.7 // Placeholder (1 frame at 60fps)
    }
    
    var memoryUsage: Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let totalMemory = ProcessInfo.processInfo.physicalMemory
            let usedMemory = info.resident_size
            return Double(usedMemory) / Double(totalMemory) * 100.0
        }
        
        return 0
    }
    
    var batteryImpact: Double {
        // This would require battery monitoring
        // Return estimated impact based on CPU/GPU usage
        return cpuUsage * 0.8 + frameRate / 60.0 * 20.0
    }
}