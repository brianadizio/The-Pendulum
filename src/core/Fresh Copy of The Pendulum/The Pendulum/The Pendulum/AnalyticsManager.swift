// AnalyticsManager.swift
import Foundation
import CoreData
import UIKit

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    // MARK: - Properties
    
    private let coreDataManager = CoreDataManager.shared
    private var context: NSManagedObjectContext {
        return coreDataManager.context
    }
    
    // Tracking state
    private var isTracking: Bool = false
    
    // Current session tracking
    private var currentSessionId: UUID?
    private var sessionStartTime: Date?
    private var lastPushTime: Date?
    private var lastInstabilityTime: Date?
    private var instabilityThreshold: Double = 0.2 // Radians from vertical when instability is considered
    
    // Interaction buffers for batch processing
    private var pendingInteractions: [InteractionEventData] = []
    private var interactionHistory: [InteractionEventData] = []
    private var pushFrequencyBuffer: [TimeInterval] = []
    private var pushMagnitudeBuffer: [Double] = []
    var directionalPushes: [String: Int] = ["left": 0, "right": 0]
    
    // Performance tracking
    private var angleBuffer: [Double] = [] // For variance calculation
    private var totalForceApplied: Double = 0
    private var correctionEfficiency: [Double] = [] // Force applied vs. stability gained
    private var reactionTimes: [Double] = [] // Time from instability to correction
    
    // MARK: - Data Models
    
    struct InteractionEventData {
        let timestamp: Date
        let eventType: String
        let angle: Double
        let angleVelocity: Double
        let magnitude: Double
        let direction: String
        let reactionTime: Double
    }
    
    // MARK: - Session Management
    
    func startTracking(for sessionId: UUID) {
        currentSessionId = sessionId
        sessionStartTime = Date()
        isTracking = true
        
        // Reset all tracking buffers
        pendingInteractions = []
        interactionHistory = []
        pushFrequencyBuffer = []
        pushMagnitudeBuffer = []
        directionalPushes = ["left": 0, "right": 0]
        angleBuffer = []
        totalForceApplied = 0
        correctionEfficiency = []
        reactionTimes = []
        
        print("Analytics tracking started for session \(sessionId)")
    }
    
    func stopTracking() {
        // Calculate final metrics before ending
        if let sessionId = currentSessionId {
            calculateAndSavePerformanceMetrics(for: sessionId)
        }
        
        // Clear tracking state
        isTracking = false
        currentSessionId = nil
        sessionStartTime = nil
        lastPushTime = nil
        lastInstabilityTime = nil
        
        print("Analytics tracking stopped")
    }
    
    // MARK: - Interaction Tracking
    
    func trackPendulumState(angle: Double, angleVelocity: Double) {
        guard isTracking, currentSessionId != nil else {
            // Skip tracking if not actively tracking
            return
        }
        
        // Store angle for variance calculation
        angleBuffer.append(angle)
        
        // Keep buffer size manageable by trimming oldest values if too large
        if angleBuffer.count > 1000 {
            angleBuffer.removeFirst(angleBuffer.count - 1000)
        }
        
        // Check for instability
        let angleFromVertical = abs(normalizeAngle(angle - Double.pi))
        if angleFromVertical > instabilityThreshold && lastInstabilityTime == nil {
            lastInstabilityTime = Date()
        } else if angleFromVertical <= instabilityThreshold && lastInstabilityTime != nil {
            // Reset instability tracking once stabilized
            lastInstabilityTime = nil
        }
    }
    
    func trackInteraction(eventType: String, angle: Double, angleVelocity: Double, magnitude: Double, direction: String) {
        guard isTracking, let sessionId = currentSessionId else {
            print("Cannot track interaction: Analytics tracking not active")
            return
        }
        
        // Calculate reaction time if this is a correction
        var reactionTime = 0.0
        if eventType == "push" && lastInstabilityTime != nil {
            reactionTime = Date().timeIntervalSince(lastInstabilityTime!)
            reactionTimes.append(reactionTime)
        }
        
        // Track push frequency
        if eventType == "push" {
            if let lastPush = lastPushTime {
                let timeSinceLastPush = Date().timeIntervalSince(lastPush)
                pushFrequencyBuffer.append(timeSinceLastPush)
            }
            lastPushTime = Date()
            
            // Track directional bias
            directionalPushes[direction, default: 0] += 1
            
            // Track magnitude for distribution analysis
            pushMagnitudeBuffer.append(abs(magnitude))
            
            // Track total force applied
            totalForceApplied += abs(magnitude)
        }
        
        // Create and store the interaction data
        let interaction = InteractionEventData(
            timestamp: Date(),
            eventType: eventType,
            angle: angle,
            angleVelocity: angleVelocity,
            magnitude: magnitude,
            direction: direction,
            reactionTime: reactionTime
        )
        
        // Add to pending interactions
        pendingInteractions.append(interaction)
        
        // Keep a history for analysis
        interactionHistory.append(interaction)
        
        // If we have enough pending interactions, save them in batches
        if pendingInteractions.count >= 10 {
            saveInteractionBatch()
        }
    }
    
    private func saveInteractionBatch() {
        guard let sessionId = currentSessionId else { return }
        
        // Begin batch update
        context.performAndWait {
            // Find the PlaySession for this sessionId
            let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
            
            do {
                let playSession = try context.fetch(fetchRequest).first
                
                // For each pending interaction, create a Core Data record
                for interaction in pendingInteractions {
                    let event = InteractionEvent(context: context)
                    event.sessionId = sessionId
                    event.timestamp = interaction.timestamp
                    event.eventType = interaction.eventType
                    event.angle = interaction.angle
                    event.angleVelocity = interaction.angleVelocity
                    event.magnitude = interaction.magnitude
                    event.direction = interaction.direction
                    event.reactionTime = interaction.reactionTime
                    
                    // Link to play session if it exists
                    if let playSession = playSession {
                        event.playSession = playSession
                    }
                }
                
                // Save context
                try context.save()
                
                // Clear the pending interactions
                pendingInteractions.removeAll()
            } catch {
                print("Error saving interaction batch: \(error)")
            }
        }
    }
    
    // MARK: - Metrics Calculation
    
    func calculateAndSavePerformanceMetrics(for sessionId: UUID) {
        // First make sure all pending interactions are saved
        if !pendingInteractions.isEmpty {
            saveInteractionBatch()
        }
        
        // Calculate stability score (inverse of angle variance, normalized 0-100)
        let stabilityScore = calculateStabilityScore()
        
        // Calculate energy efficiency (stability gained per unit of force)
        let efficiencyRating = calculateEfficiencyRating()
        
        // Calculate average correction time
        let averageCorrectionTime = reactionTimes.isEmpty ? 0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        
        // Calculate directional bias (-1.0 to 1.0, negative = left bias, positive = right bias)
        let directionalBias = calculateDirectionalBias()
        
        // Calculate overcorrection rate
        let overcorrectionRate = calculateOvercorrectionRate()
        
        // Determine player style
        let playerStyle = determinePlayerStyle(
            stabilityScore: stabilityScore,
            efficiencyRating: efficiencyRating,
            directionalBias: directionalBias,
            overcorrectionRate: overcorrectionRate
        )
        
        // Save metrics to Core Data
        context.performAndWait {
            // Find the PlaySession for this sessionId
            let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
            
            do {
                if let playSession = try context.fetch(fetchRequest).first {
                    // Create performance metrics
                    let metrics = PerformanceMetrics(context: context)
                    metrics.sessionId = sessionId
                    metrics.timestamp = Date()
                    metrics.stabilityScore = stabilityScore
                    metrics.efficiencyRating = efficiencyRating
                    metrics.averageCorrectionTime = averageCorrectionTime
                    metrics.directionalBias = directionalBias
                    metrics.overcorrectionRate = overcorrectionRate
                    metrics.playerStyle = playerStyle
                    
                    // Link to play session
                    metrics.playSession = playSession
                    
                    // Save context
                    try context.save()
                    
                    print("Performance metrics saved for session \(sessionId)")
                }
            } catch {
                print("Error saving performance metrics: \(error)")
            }
        }
        
        // Trigger aggregation update
        updateAggregatedAnalytics()
    }
    
    // MARK: - Analytics Calculation Methods
    
    private func calculateStabilityScore() -> Double {
        guard !angleBuffer.isEmpty else { return 0 }
        
        // Calculate variance of angles
        let mean = angleBuffer.reduce(0, +) / Double(angleBuffer.count)
        let sumSquaredDifferences = angleBuffer.reduce(0) { sum, angle in
            sum + pow(angle - mean, 2)
        }
        let variance = sumSquaredDifferences / Double(angleBuffer.count)
        
        // Convert variance to a stability score (inverse relationship)
        // Lower variance = higher stability
        let maxVariance = 0.5 // Calibration constant
        let normalizedVariance = min(variance / maxVariance, 1.0)
        let stabilityScore = 100.0 * (1.0 - normalizedVariance)
        
        return stabilityScore
    }
    
    private func calculateEfficiencyRating() -> Double {
        // If no force applied, return 0
        guard totalForceApplied > 0 && !angleBuffer.isEmpty else { return 0 }
        
        // Calculate stability (inverse of angle variance)
        let stability = calculateStabilityScore()
        
        // Efficiency is stability achieved per unit of force
        let normalizedForce = min(totalForceApplied, 100) / 100
        let efficiencyRating = stability / normalizedForce
        
        // Normalize to 0-100 scale
        return min(efficiencyRating, 100)
    }
    
    private func calculateDirectionalBias() -> Double {
        let leftCount = directionalPushes["left"] ?? 0
        let rightCount = directionalPushes["right"] ?? 0
        let total = leftCount + rightCount
        
        guard total > 0 else { return 0 }
        
        // Calculate bias from -1.0 (completely left) to 1.0 (completely right)
        return Double(rightCount - leftCount) / Double(total)
    }
    
    private func calculateOvercorrectionRate() -> Double {
        guard !interactionHistory.isEmpty else { return 0 }
        
        // Analyze sequential pushes to detect overcorrections
        // (defined as pushes in opposite directions within a short time window)
        var overcorrectionCount = 0
        let overcorrectionTimeWindow = 0.5 // seconds
        
        var previousPush: InteractionEventData?
        
        for interaction in interactionHistory where interaction.eventType == "push" {
            if let previous = previousPush {
                // Check if this is a push in the opposite direction
                let isOppositeDirection = previous.direction != interaction.direction
                
                // Check if it's within the overcorrection time window
                let timeDifference = interaction.timestamp.timeIntervalSince(previous.timestamp)
                let isWithinTimeWindow = timeDifference < overcorrectionTimeWindow
                
                if isOppositeDirection && isWithinTimeWindow {
                    overcorrectionCount += 1
                }
            }
            previousPush = interaction
        }
        
        // Calculate as a percentage of total interactions
        let pushCount = interactionHistory.filter { $0.eventType == "push" }.count
        return pushCount > 1 ? Double(overcorrectionCount) / Double(pushCount - 1) : 0
    }
    
    private func determinePlayerStyle(stabilityScore: Double, efficiencyRating: Double, directionalBias: Double, overcorrectionRate: Double) -> String {
        // Categorize player style based on metrics
        
        // Check for specific patterns
        if stabilityScore > 85 && efficiencyRating > 80 {
            return "Expert Balancer"
        }
        
        if abs(directionalBias) > 0.6 {
            return directionalBias > 0 ? "Right-Dominant" : "Left-Dominant"
        }
        
        if overcorrectionRate > 0.3 {
            return "Overcorrector"
        }
        
        if reactionTimes.isEmpty {
            // No reaction time data
            return "Methodical"
        }
        
        let avgReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        
        if avgReactionTime < 0.3 && stabilityScore < 60 {
            return "Quick but Erratic"
        }
        
        if avgReactionTime < 0.3 && stabilityScore > 60 {
            return "Proactive Controller"
        }
        
        if avgReactionTime > 0.7 {
            return "Reactive Controller"
        }
        
        // Default style based on stability and efficiency
        if stabilityScore > 70 {
            return "Steady Handler"
        } else if efficiencyRating > 70 {
            return "Efficient Handler"
        } else {
            return "Balanced Controller"
        }
    }
    
    // MARK: - Long-term Analytics
    
    private func updateAggregatedAnalytics() {
        // This method will be called periodically to update aggregated statistics
        updateDailyAnalytics()
        updateWeeklyAnalytics()
        updateMonthlyAnalytics()
    }
    
    private func updateDailyAnalytics() {
        aggregateAnalytics(for: "daily", timeFrame: -86400) // Last 24 hours
    }
    
    private func updateWeeklyAnalytics() {
        aggregateAnalytics(for: "weekly", timeFrame: -604800) // Last 7 days
    }
    
    private func updateMonthlyAnalytics() {
        aggregateAnalytics(for: "monthly", timeFrame: -2592000) // Last 30 days
    }
    
    private func aggregateAnalytics(for period: String, timeFrame: TimeInterval) {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(timeFrame)
        
        context.performAndWait {
            // Fetch metrics within the time frame
            let metricsFetch: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
            metricsFetch.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as NSDate, endDate as NSDate)
            
            do {
                let metrics = try context.fetch(metricsFetch)
                
                // Skip if no metrics found
                guard !metrics.isEmpty else { return }
                
                // Calculate aggregated values
                let sessionCount = metrics.count
                
                // Fetch play sessions to calculate total play time
                let sessionIds = metrics.compactMap { $0.sessionId }
                let sessionFetch: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
                sessionFetch.predicate = NSPredicate(format: "sessionId IN %@", sessionIds)
                
                let sessions = try context.fetch(sessionFetch)
                let totalPlayTime = sessions.reduce(0.0) { $0 + $1.duration }
                
                // Calculate averages
                let avgStabilityScore = metrics.reduce(0.0) { $0 + $1.stabilityScore } / Double(metrics.count)
                let avgEfficiencyRating = metrics.reduce(0.0) { $0 + $1.efficiencyRating } / Double(metrics.count)
                
                // Calculate learning curve (improvement rate over time)
                let learningCurveSlope = calculateLearningCurve(metrics: metrics)
                
                // Determine dominant player style
                let styleFrequency = Dictionary(grouping: metrics, by: { $0.playerStyle ?? "Unknown" })
                    .mapValues { $0.count }
                let playerStyleTrend = styleFrequency
                    .sorted { $0.value > $1.value }
                    .first?.key ?? "Mixed"
                
                // Create or update aggregation record
                let aggregationFetch: NSFetchRequest<AggregatedAnalytics> = AggregatedAnalytics.fetchRequest()
                aggregationFetch.predicate = NSPredicate(format: "period == %@ AND startDate == %@", period, startDate as NSDate)
                
                let existingAggregation = try context.fetch(aggregationFetch).first
                
                let aggregation: AggregatedAnalytics
                if let existing = existingAggregation {
                    aggregation = existing
                } else {
                    aggregation = AggregatedAnalytics(context: context)
                    aggregation.period = period
                    aggregation.startDate = startDate
                }
                
                // Update properties
                aggregation.endDate = endDate
                aggregation.sessionCount = Int32(sessionCount)
                aggregation.totalPlayTime = totalPlayTime
                aggregation.averageStabilityScore = avgStabilityScore
                aggregation.averageEfficiencyRating = avgEfficiencyRating
                aggregation.learningCurveSlope = learningCurveSlope
                aggregation.playerStyleTrend = playerStyleTrend
                
                // Save context
                try context.save()
                
                print("Updated \(period) analytics aggregation")
            } catch {
                print("Error aggregating \(period) analytics: \(error)")
            }
        }
    }
    
    private func calculateLearningCurve(metrics: [PerformanceMetrics]) -> Double {
        // Sort metrics by timestamp
        let sortedMetrics = metrics.sorted { $0.timestamp! < $1.timestamp! }
        
        // Need at least 2 metrics to calculate a slope
        guard sortedMetrics.count >= 2 else { return 0 }
        
        // Extract stability scores and normalize time
        var x: [Double] = [] // Normalized time
        var y: [Double] = [] // Stability scores
        
        let firstTime = sortedMetrics.first!.timestamp!.timeIntervalSince1970
        let lastTime = sortedMetrics.last!.timestamp!.timeIntervalSince1970
        let timeRange = lastTime - firstTime
        
        // Prevent division by zero
        guard timeRange > 0 else { return 0 }
        
        for metric in sortedMetrics {
            let normalizedTime = (metric.timestamp!.timeIntervalSince1970 - firstTime) / timeRange
            x.append(normalizedTime)
            y.append(metric.stabilityScore)
        }
        
        // Calculate linear regression slope
        return calculateLinearRegressionSlope(x: x, y: y)
    }
    
    private func calculateLinearRegressionSlope(x: [Double], y: [Double]) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0 }
        
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumXSquare = x.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = n * sumXSquare - sumX * sumX
        
        // Prevent division by zero
        guard denominator != 0 else { return 0 }
        
        return numerator / denominator
    }
    
    // MARK: - Helper Methods
    
    private func normalizeAngle(_ angle: Double) -> Double {
        // Normalize angle to [-π, π]
        return atan2(sin(angle), cos(angle))
    }
    
    // MARK: - Data Retrieval for Dashboard
    
    func getRecentInteractions(limit: Int = 100) -> [InteractionEventData] {
        // First, include any pending interactions
        var results = pendingInteractions
        
        // Then fetch from Core Data
        guard let sessionId = currentSessionId else {
            return results
        }
        
        let fetchRequest: NSFetchRequest<InteractionEvent> = InteractionEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = limit - results.count
        
        if fetchRequest.fetchLimit > 0 {
            do {
                let events = try context.fetch(fetchRequest)
                
                // Convert to our data model
                let fetchedEvents = events.map { event in
                    InteractionEventData(
                        timestamp: event.timestamp ?? Date(),
                        eventType: event.eventType ?? "unknown",
                        angle: event.angle,
                        angleVelocity: event.angleVelocity,
                        magnitude: event.magnitude,
                        direction: event.direction ?? "unknown",
                        reactionTime: event.reactionTime
                    )
                }
                
                results.append(contentsOf: fetchedEvents)
            } catch {
                print("Error fetching recent interactions: \(error)")
            }
        }
        
        return results.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getPerformanceMetrics(for sessionId: UUID? = nil) -> [String: Any] {
        let targetSessionId = sessionId ?? currentSessionId
        
        guard let sessionId = targetSessionId else {
            return [:]
        }
        
        let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let metrics = try context.fetch(fetchRequest).first {
                return [
                    "stabilityScore": metrics.stabilityScore,
                    "efficiencyRating": metrics.efficiencyRating,
                    "averageCorrectionTime": metrics.averageCorrectionTime,
                    "directionalBias": metrics.directionalBias,
                    "overcorrectionRate": metrics.overcorrectionRate,
                    "playerStyle": metrics.playerStyle ?? "Unknown"
                ]
            }
        } catch {
            print("Error fetching performance metrics: \(error)")
        }
        
        // If no saved metrics yet, calculate from current session
        return [
            "stabilityScore": calculateStabilityScore(),
            "efficiencyRating": calculateEfficiencyRating(),
            "averageCorrectionTime": reactionTimes.isEmpty ? 0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count),
            "directionalBias": calculateDirectionalBias(),
            "overcorrectionRate": calculateOvercorrectionRate(),
            "playerStyle": determinePlayerStyle(
                stabilityScore: calculateStabilityScore(),
                efficiencyRating: calculateEfficiencyRating(),
                directionalBias: calculateDirectionalBias(),
                overcorrectionRate: calculateOvercorrectionRate()
            )
        ]
    }
    
    func getAggregatedAnalytics(period: String) -> [String: Any] {
        let fetchRequest: NSFetchRequest<AggregatedAnalytics> = AggregatedAnalytics.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "period == %@", period)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let aggregation = try context.fetch(fetchRequest).first {
                return [
                    "period": aggregation.period ?? period,
                    "startDate": aggregation.startDate ?? Date(),
                    "endDate": aggregation.endDate ?? Date(),
                    "sessionCount": aggregation.sessionCount,
                    "totalPlayTime": aggregation.totalPlayTime,
                    "averageStabilityScore": aggregation.averageStabilityScore,
                    "averageEfficiencyRating": aggregation.averageEfficiencyRating,
                    "learningCurveSlope": aggregation.learningCurveSlope,
                    "playerStyleTrend": aggregation.playerStyleTrend ?? "Unknown"
                ]
            }
        } catch {
            print("Error fetching aggregated analytics for \(period): \(error)")
        }
        
        return [:]
    }
    
    func getInteractionTimeSeries(timeframe: TimeInterval = -3600) -> [[String: Any]] {
        // Get interactions within the specified timeframe
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(timeframe)
        
        let fetchRequest: NSFetchRequest<InteractionEvent> = InteractionEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let events = try context.fetch(fetchRequest)
            
            return events.map { event in
                [
                    "timestamp": event.timestamp ?? Date(),
                    "angle": event.angle,
                    "angleVelocity": event.angleVelocity,
                    "magnitude": event.magnitude,
                    "direction": event.direction ?? "",
                    "eventType": event.eventType ?? ""
                ]
            }
        } catch {
            print("Error fetching interaction time series: \(error)")
        }
        
        return []
    }
    
    func getPushFrequencyDistribution() -> [TimeInterval: Int] {
        var distribution: [TimeInterval: Int] = [:]
        
        // Bin the push frequency data (rounded to nearest 100ms)
        for interval in pushFrequencyBuffer {
            let roundedInterval = round(interval * 10) / 10
            distribution[roundedInterval, default: 0] += 1
        }
        
        return distribution
    }
    
    func getPushMagnitudeDistribution() -> [Double: Int] {
        var distribution: [Double: Int] = [:]
        
        // Bin the magnitude data (rounded to nearest 0.1)
        for magnitude in pushMagnitudeBuffer {
            let roundedMagnitude = round(magnitude * 10) / 10
            distribution[roundedMagnitude, default: 0] += 1
        }
        
        return distribution
    }
}