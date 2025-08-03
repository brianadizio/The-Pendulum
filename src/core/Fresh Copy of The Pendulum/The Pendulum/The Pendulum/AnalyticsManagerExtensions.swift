import Foundation
import UIKit
import CoreData

// MARK: - Analytics Manager Extensions for Enhanced Metrics
extension AnalyticsManager {
    
    // MARK: - Properties
    private static let metricsCalculatorKey = UnsafeRawPointer(UnsafeMutablePointer<Int8>.allocate(capacity: 1))
    
    private var metricsCalculator: MetricsCalculator {
        get {
            if let calculator = objc_getAssociatedObject(self, AnalyticsManager.metricsCalculatorKey) as? MetricsCalculator {
                return calculator
            } else {
                let calculator = MetricsCalculator()
                objc_setAssociatedObject(self, AnalyticsManager.metricsCalculatorKey, calculator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                print("📊 Created new MetricsCalculator instance")
                return calculator
            }
        }
    }
    
    // Session data storage for educational metrics
    private static var sessionHistory: [SessionData] = []
    static var parameterChangeHistory: [(time: Double, parameter: String, oldValue: Double, newValue: Double)] = []
    
    // Performance monitoring
    private static var performanceMonitor = PerformanceMonitor()
    
    // MARK: - Utility Methods
    
    func getTimeframeForRange() -> TimeInterval {
        // Return timeframe based on current time range selection
        switch currentTimeRange {
        case .session:
            return -3600 // 1 hour
        case .daily:
            return -86400 // 24 hours
        case .weekly:
            return -604800 // 7 days
        case .monthly:
            return -2629746 // ~30 days
        case .yearly:
            return -31556952 // ~365 days
        }
    }
    
    // MARK: - Enhanced Tracking Methods
    
    func trackEnhancedPendulumState(time: Double, angle: Double, angleVelocity: Double) {
        // Track in base analytics
        trackPendulumState(angle: angle, angleVelocity: angleVelocity)
        
        // Track phase space point for trajectory visualization
        trackPhaseSpacePoint(theta: angle, omega: angleVelocity)
        
        // Track in metrics calculator
        metricsCalculator.recordState(time: time, angle: angle, velocity: angleVelocity)
        
        // Debug: Log every 1000th data point
        let timeValue = time * 100
        if !timeValue.isNaN && !timeValue.isInfinite && Int(timeValue) % 1000 == 0 {
            // Suppressed: Tracked state debug output
        }
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
        AnalyticsManager.parameterChangeQueue.async(flags: .barrier) {
            AnalyticsManager.parameterChangeHistory.append((time: time, parameter: parameter, oldValue: oldValue, newValue: newValue))
        }
        
        print("📊 Parameter change tracked: \(parameter) from \(oldValue) to \(newValue) at time \(time)")
    }
    
    func trackInitialParameters(mass: Double, length: Double, gravity: Double, damping: Double, forceMultiplier: Double) {
        let currentTime = Date().timeIntervalSince1970
        
        // Track initial values for all parameters at session start - thread safe
        AnalyticsManager.parameterChangeQueue.async(flags: .barrier) {
            AnalyticsManager.parameterChangeHistory.append((time: currentTime, parameter: "mass", oldValue: 0, newValue: mass))
            AnalyticsManager.parameterChangeHistory.append((time: currentTime, parameter: "length", oldValue: 0, newValue: length))
            AnalyticsManager.parameterChangeHistory.append((time: currentTime, parameter: "gravity", oldValue: 0, newValue: gravity))
            AnalyticsManager.parameterChangeHistory.append((time: currentTime, parameter: "damping", oldValue: 0, newValue: damping))
            AnalyticsManager.parameterChangeHistory.append((time: currentTime, parameter: "forceMultiplier", oldValue: 0, newValue: forceMultiplier))
        }
        
        print("📊 Initial parameters tracked at session start")
    }
    
    // MARK: - Time-Based Data Filtering
    
    /// Structure to hold filtered data based on time range
    struct FilteredAnalyticsData {
        let forceHistory: [(time: Double, force: Double, direction: String, timestamp: Date)]
        let reactionTimeHistory: [(time: Double, timestamp: Date)]
        let directionalPushes: [String: Int]
        let timeRange: AnalyticsTimeRange
    }
    
    /// Get data filtered by the current time range
    private func getFilteredData(for timeRange: AnalyticsTimeRange) -> FilteredAnalyticsData {
        let now = Date()
        let timeLimit: TimeInterval
        
        switch timeRange {
        case .session:
            // Session data - use current session only
            timeLimit = 24 * 60 * 60 // Last 24 hours as fallback
        case .daily:
            timeLimit = 24 * 60 * 60 // 24 hours
        case .weekly:
            timeLimit = 7 * 24 * 60 * 60 // 7 days
        case .monthly:
            timeLimit = 30 * 24 * 60 * 60 // 30 days
        case .yearly:
            timeLimit = 365 * 24 * 60 * 60 // 365 days
        }
        
        let cutoffDate = now.addingTimeInterval(-timeLimit)
        
        // Filter force history - use timestamped data when available, otherwise estimate
        let filteredForceHistory: [(time: Double, force: Double, direction: String, timestamp: Date)]
        
        if !forceHistoryWithTimestamps.isEmpty {
            // Use real timestamped data
            filteredForceHistory = forceHistoryWithTimestamps.filter { $0.timestamp >= cutoffDate }
        } else {
            // Fall back to estimated timestamps for existing data
            filteredForceHistory = forceHistory.compactMap { forceData -> (time: Double, force: Double, direction: String, timestamp: Date)? in
                let estimatedTimestamp = now.addingTimeInterval(-TimeInterval.random(in: 0...timeLimit))
                if estimatedTimestamp >= cutoffDate {
                    return (forceData.time, forceData.force, forceData.direction, estimatedTimestamp)
                }
                return nil
            }
        }
        
        // Filter reaction time history - use timestamped data when available, otherwise estimate
        let filteredReactionTimeHistory: [(time: Double, timestamp: Date)]
        
        if !reactionTimeHistory.isEmpty {
            // Use real timestamped data
            filteredReactionTimeHistory = reactionTimeHistory.filter { $0.timestamp >= cutoffDate }
        } else {
            // Fall back to estimated timestamps for existing data
            filteredReactionTimeHistory = reactionTimes.compactMap { reactionTime -> (time: Double, timestamp: Date)? in
                let estimatedTimestamp = now.addingTimeInterval(-TimeInterval.random(in: 0...timeLimit))
                if estimatedTimestamp >= cutoffDate {
                    return (reactionTime, estimatedTimestamp)
                }
                return nil
            }
        }
        
        // Calculate directional pushes from filtered force history
        var filteredDirectionalPushes: [String: Int] = ["left": 0, "right": 0]
        for forceData in filteredForceHistory {
            filteredDirectionalPushes[forceData.direction, default: 0] += 1
        }
        
        return FilteredAnalyticsData(
            forceHistory: filteredForceHistory,
            reactionTimeHistory: filteredReactionTimeHistory,
            directionalPushes: filteredDirectionalPushes,
            timeRange: timeRange
        )
    }
    
    /// Calculate force distribution from filtered force history
    private func calculateForceDistributionFromFilteredData(_ forceHistory: [(time: Double, force: Double, direction: String, timestamp: Date)]) -> [Double] {
        guard !forceHistory.isEmpty else { return [] }
        
        let forces = forceHistory.map { abs($0.force) }
        let maxForce = forces.max() ?? 1.0
        let minForce = forces.min() ?? 0.0
        
        // Create 10 bins for distribution
        let binCount = 10
        let binSize = (maxForce - minForce) / Double(binCount)
        var distribution = Array(repeating: 0.0, count: binCount)
        
        for force in forces {
            let binValue = (force - minForce) / binSize
            
            // Validate before Int conversion
            guard !binValue.isNaN && !binValue.isInfinite else {
                print("⚠️ AnalyticsManagerExtensions: Skipping invalid force bin calculation - force: \(force), minForce: \(minForce), binSize: \(binSize)")
                continue
            }
            
            let binIndex = min(Int(binValue), binCount - 1)
            distribution[binIndex] += 1.0
        }
        
        return distribution
    }
    
    /// Calculate push magnitude distribution from filtered force history
    private func calculatePushMagnitudeDistributionFromFilteredData(_ forceHistory: [(time: Double, force: Double, direction: String, timestamp: Date)]) -> [Double] {
        guard !forceHistory.isEmpty else { return [] }
        
        let magnitudes = forceHistory.map { abs($0.force) }
        
        // Create magnitude ranges: 0-0.5, 0.5-1.0, 1.0-2.0, 2.0-3.0, 3.0+
        let ranges = [(0.0, 0.5), (0.5, 1.0), (1.0, 2.0), (2.0, 3.0), (3.0, Double.infinity)]
        var distribution = Array(repeating: 0.0, count: ranges.count)
        
        for magnitude in magnitudes {
            for (index, range) in ranges.enumerated() {
                if magnitude >= range.0 && magnitude < range.1 {
                    distribution[index] += 1.0
                    break
                }
            }
        }
        
        return distribution
    }
    
    /// Calculate total play time from filtered data
    private func calculateTotalPlayTimeFromFilteredData(_ filteredData: FilteredAnalyticsData) -> Double {
        // Calculate based on the time span of the filtered data
        guard !filteredData.forceHistory.isEmpty else { return 0.0 }
        
        let timestamps = filteredData.forceHistory.map { $0.timestamp }
        guard let earliest = timestamps.min(), let latest = timestamps.max() else { return 0.0 }
        
        return latest.timeIntervalSince(earliest)
    }
    
    /// Calculate directional bias from filtered directional pushes
    private func calculateDirectionalBiasFromFilteredData(_ directionalPushes: [String: Int]) -> Double {
        let leftCount = Double(directionalPushes["left"] ?? 0)
        let rightCount = Double(directionalPushes["right"] ?? 0)
        let totalCount = leftCount + rightCount
        
        guard totalCount > 0 else { return 0.0 }
        
        // Calculate bias as difference from 50/50 split
        let leftRatio = leftCount / totalCount
        let rightRatio = rightCount / totalCount
        
        // Return bias as percentage deviation from center (-50 to +50)
        return (leftRatio - rightRatio) * 50.0
    }
    
    // MARK: - Metric Calculation Methods by Group
    
    func calculateMetrics(for group: MetricGroupType) -> [MetricValue] {
        let metricTypes = MetricGroupDefinition.metrics(for: group)
        var metricValues: [MetricValue] = []
        
        for metricType in metricTypes {
            if let value = calculateMetric(type: metricType) {
                metricValues.append(value)
            }
            // Skip metrics with no data instead of showing "Not enough data"
        }
        
        return metricValues
    }
    
    private func calculateMetric(type: MetricType) -> MetricValue? {
        let timestamp = Date()
        
        // Get filtered data based on current time range
        let filteredData = getFilteredData(for: currentTimeRange)
        
        // Removed debug print - calculating metric
        
        // Add debugging to catch NaN at the source
        defer {
            // Check after calculation
            // Removed debug print - finished calculating metric
        }
        
        // Create a metric value and check for NaN before returning
        func createMetricValue(_ value: Any, confidence: Double? = nil) -> MetricValue {
            let metricValue = MetricValue(type: type, value: value, timestamp: timestamp, confidence: confidence)
            
            // Check for NaN in the value
            switch value {
            case let doubleValue as Double:
                if doubleValue.isNaN || doubleValue.isInfinite {
                    print("ERROR: NaN/Infinite metric value created for \(type.rawValue): \(doubleValue)")
                    // Removed debug print - creating metric from group
                }
            case let distribution as [Double]:
                for (index, val) in distribution.enumerated() {
                    if val.isNaN || val.isInfinite {
                        print("ERROR: NaN/Infinite in distribution for \(type.rawValue) at index \(index): \(val)")
                        // Removed debug print - creating metric from group
                    }
                }
            case let timeSeries as [(Date, Double)]:
                for (index, point) in timeSeries.enumerated() {
                    if point.1.isNaN || point.1.isInfinite {
                        print("ERROR: NaN/Infinite in time series for \(type.rawValue) at index \(index): \(point.1)")
                        // Removed debug print - creating metric from group
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
            // Removed debug print - stability score calculated
            if score.isNaN || score.isInfinite {
                print("ERROR: NaN/Infinite stability score detected: \(score)")
                return createMetricValue(0.0)
            }
            return createMetricValue(score)
            
        case .balanceDuration:
            let duration = metricsCalculator.calculateBalanceDuration()
            return createMetricValue(duration)
            
        case .pushCount:
            // Calculate push count from filtered data
            let count = filteredData.forceHistory.count
            return createMetricValue(count)
            
        case .currentLevel:
            return createMetricValue(getCurrentLevel())
            
        case .sessionTime:
            // Use different calculation based on time range
            let time: Double
            if currentTimeRange == .session {
                // For session view, use the captured session time or calculate from current session
                time = metricsCalculator.calculateSessionTime()
            } else {
                // For other time ranges, calculate total play time from filtered data
                time = calculateTotalPlayTimeFromFilteredData(filteredData)
            }
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
            // Removed debug print - efficiency rating calculated
            if rating.isNaN || rating.isInfinite {
                print("ERROR: NaN/Infinite efficiency rating detected: \(rating)")
                return createMetricValue(0.0)
            }
            return createMetricValue(rating)
            
        case .directionalBias:
            let bias = calculateDirectionalBiasFromFilteredData(filteredData.directionalPushes)
            if bias.isNaN || bias.isInfinite {
                print("ERROR: NaN/Infinite directional bias detected: \(bias)")
                return createMetricValue(0.0)
            }
            return createMetricValue(bias)
            
        case .averageCorrectionTime:
            let reactionTimesArray = filteredData.reactionTimeHistory.map { $0.time }
            let avgTime = reactionTimesArray.isEmpty ? 0 : reactionTimesArray.reduce(0, +) / Double(reactionTimesArray.count)
            if avgTime.isNaN || avgTime.isInfinite {
                print("ERROR: NaN/Infinite average correction time detected: \(avgTime)")
                return createMetricValue(0.0)
            }
            return createMetricValue(avgTime)
            
        case .overcorrectionRate:
            let rate = calculateOvercorrectionRate()
            return createMetricValue(rate)
            
        case .forceDistribution:
            // Calculate force distribution from filtered data
            let forceDistribution = calculateForceDistributionFromFilteredData(filteredData.forceHistory)
            guard !forceDistribution.isEmpty else {
                return nil // Return nil for "No Data Available" message
            }
            // Check for NaN in distribution
            let cleanDistribution = forceDistribution.filter { !$0.isNaN && !$0.isInfinite }
            if cleanDistribution.count != forceDistribution.count {
                print("WARNING: Filtered out \(forceDistribution.count - cleanDistribution.count) NaN/Infinite values from force distribution")
            }
            return createMetricValue(cleanDistribution)
            
        case .pushMagnitudeDistribution:
            // Calculate push magnitude distribution from filtered data
            let magnitudeDistribution = calculatePushMagnitudeDistributionFromFilteredData(filteredData.forceHistory)
            guard !magnitudeDistribution.isEmpty else {
                return nil // Return nil for "No Data Available" message
            }
            return createMetricValue(magnitudeDistribution)
            
        case .reactionTimeAnalysis:
            // Return reaction times with proper timestamps from filtered data
            let reactionTimeSeries = filteredData.reactionTimeHistory.map { reactionData in
                (reactionData.timestamp, reactionData.time)
            }
            guard !reactionTimeSeries.isEmpty else {
                return nil // Return nil for "No Data Available" message
            }
            return createMetricValue(reactionTimeSeries)
            
        case .levelCompletionsOverTime:
            // Get level completions by time period with current time scale
            let completions = getLevelCompletionsByTimePeriod(timeScale: currentTimeRange)
            return createMetricValue(completions)
            
        case .pendulumParametersOverTime:
            // Return parameter changes over time for the selected parameter
            let parameterData = getParameterHistoryTimeSeries(parameter: currentSelectedParameter, timeScale: currentTimeRange)
            return createMetricValue(parameterData)
            
        case .fullDirectionalBias:
            // Return directional bias from filtered data
            let leftCount = Double(filteredData.directionalPushes["left"] ?? 0)
            let rightCount = Double(filteredData.directionalPushes["right"] ?? 0)
            
            // Return nil if no data for "No Data Available" message
            guard leftCount > 0 || rightCount > 0 else {
                return nil
            }
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
            // Check if we have sufficient phase space data
            guard phaseSpacePoints.count > 50 else {
                print("📊 Phase Space Coverage: Insufficient data (\(phaseSpacePoints.count) points, need >50)")
                return nil
            }
            print("📊 Calculating Phase Space Coverage - Calculator: \(Unmanaged.passUnretained(metricsCalculator).toOpaque())")
            let coverage = metricsCalculator.calculatePhaseSpaceCoverage()
            print("📊 Phase Space Coverage Result: \(coverage)")
            return createMetricValue(coverage)
            
        case .energyManagement:
            // Check if we have sufficient interaction data
            guard !angleBuffer.isEmpty && !velocityBuffer.isEmpty && angleBuffer.count > 100 else {
                print("📊 Energy Management: Insufficient data (angles: \(angleBuffer.count), velocities: \(velocityBuffer.count), need >100)")
                return nil
            }
            let efficiency = metricsCalculator.calculateEnergyManagementEfficiency()
            return createMetricValue(efficiency, confidence: 0.9)
            
        case .lyapunovExponent:
            // Check if we have sufficient time series data for chaos analysis
            guard angleBuffer.count > 200 && phaseSpacePoints.count > 100 else {
                print("📊 Lyapunov Exponent: Insufficient data (angles: \(angleBuffer.count), phase points: \(phaseSpacePoints.count), need >200 & >100)")
                return nil
            }
            let exponent = metricsCalculator.calculateLyapunovExponent()
            return createMetricValue(exponent, confidence: 0.7)
            
        case .controlStrategy:
            // Check if we have sufficient interaction data to identify strategy
            guard forceHistory.count > 20 && !reactionTimes.isEmpty else {
                print("📊 Control Strategy: Insufficient data (forces: \(forceHistory.count), reactions: \(reactionTimes.count), need >20 & >0)")
                return nil
            }
            let strategy = metricsCalculator.identifyControlStrategy()
            return createMetricValue(strategy)
            
        case .stateTransitionFreq:
            // Check if we have sufficient phase space data for state transitions
            guard phaseSpacePoints.count > 30 else {
                print("📊 State Transition Frequency: Insufficient data (\(phaseSpacePoints.count) points, need >30)")
                return nil
            }
            let freq = metricsCalculator.calculateStateTransitionFrequency()
            return createMetricValue(freq)
            
        case .angularDeviation:
            // Check if we have sufficient angle data
            guard !angleBuffer.isEmpty && angleBuffer.count > 10 else {
                // Suppressed: Angular Deviation insufficient data message
                return nil
            }
            
            // Return time series data for angular deviation with proper timeframe
            let timeframe = getTimeframeForRange() // Use proper time range instead of hard-coded 5 minutes  
            let timeSeriesData = getInteractionTimeSeries(timeframe: timeframe)
            let angleTimeSeries = timeSeriesData.map { data -> (Date, Double) in
                let timestamp = data["timestamp"] as? Date ?? Date()
                let angle = data["angle"] as? Double ?? 0
                return (timestamp, angle)
            }
            
            // Check if we have meaningful time series data
            guard angleTimeSeries.count > 5 else {
                print("📊 Angular Deviation: Insufficient time series data (\(angleTimeSeries.count) points, need >5)")
                return nil
            }
            
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
            
            // Combine all level data into a single trajectory
            var combinedTrajectory: [(theta: Double, omega: Double)] = []
            
            // If we have saved average data, use it
            if !averagePhaseData.isEmpty {
                // Combine trajectories from all levels
                for level in averagePhaseData.keys.sorted() {
                    if let levelData = averagePhaseData[level] {
                        combinedTrajectory.append(contentsOf: levelData)
                    }
                }
            }
            
            // If no saved data, use current session data
            if combinedTrajectory.isEmpty {
                // Use current phase space points if available
                combinedTrajectory = Array(phaseSpacePoints.suffix(200))
            }
            
            // Check if we have sufficient data for meaningful phase trajectory
            guard combinedTrajectory.count > 20 else {
                print("📊 Phase Trajectory: Insufficient data (\(combinedTrajectory.count) points, need >20)")
                return nil
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
            
            // Check if we have sufficient learning data
            guard learningData.count > 0 else {
                print("📊 Learning Curve: Insufficient data (no learning data points)")
                return nil
            }
            
            return createMetricValue(learningData, confidence: 0.85)
            
        case .adaptationRate:
            let rate = metricsCalculator.calculateAdaptationRate(parameterChanges: AnalyticsManager.parameterChangeHistory)
            return createMetricValue(rate)
            
        case .skillRetention:
            let retention = calculateSkillRetention()
            return createMetricValue(retention, confidence: 0.75)
            
        case .failureModeAnalysis:
            // Check if we have sufficient interaction data for failure analysis
            guard !reactionTimes.isEmpty && forceHistory.count > 10 else {
                print("📊 Failure Mode Analysis: Insufficient data (reactions: \(reactionTimes.count), forces: \(forceHistory.count), need >0 & >10)")
                return nil
            }
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

// MARK: - Data Management Extensions

extension AnalyticsManager {
    
    /// Clear all analytics data
    func clearAllData() {
        // Clear all buffers
        angleBuffer.removeAll()
        velocityBuffer.removeAll()
        phaseSpaceHistory.removeAll()
        forceHistory.removeAll()
        reactionTimes.removeAll()
        directionalPushes.removeAll()
        directionalChanges.removeAll()
        
        // Clear session data
        sessions.removeAll()
        currentSessionId = nil
        currentSessionMetrics = nil
        isTracking = false
        
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("analytics_") }
        keys.forEach { defaults.removeObject(forKey: $0) }
        
        print("✅ All analytics data cleared")
    }
    
    /// Get debug info about current buffers
    func getDebugInfo() -> [String: Int] {
        return [
            "angleBuffer": angleBuffer.count,
            "velocityBuffer": velocityBuffer.count,
            "phaseSpaceHistory": phaseSpaceHistory.count,
            "forceHistory": forceHistory.count,
            "reactionTimes": reactionTimes.count,
            "directionalPushes": directionalPushes.count,
            "sessions": sessions.count
        ]
    }
    
    /// Track reaction time for corrections
    func trackReactionTime(_ time: Double) {
        // Validate reaction time before storing
        guard !time.isNaN && !time.isInfinite && time >= 0 else {
            print("⚠️ Analytics: Invalid reaction time: \(time)")
            return
        }
        
        reactionTimes.append(time)
        
        // Track reaction time with timestamp
        reactionTimeHistory.append((time: time, timestamp: Date()))
        
        // Keep buffer size manageable
        if reactionTimes.count > 1000 {
            reactionTimes.removeFirst()
        }
        if reactionTimeHistory.count > 1000 {
            reactionTimeHistory.removeFirst()
        }
    }
}