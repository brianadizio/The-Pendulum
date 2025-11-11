// AnalyticsManager.swift
import Foundation
import CoreData
import UIKit

// MARK: - Seeded Random Generator

struct SeededRandomGenerator {
    private var seed: UInt64
    
    init(seed: Int) {
        self.seed = UInt64(abs(seed))
    }
    
    mutating func nextDouble(min: Double = 0.0, max: Double = 1.0) -> Double {
        // Simple Linear Congruential Generator for deterministic randomness
        seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
        let normalizedValue = Double(seed) / Double(0x7fffffff)
        return min + (normalizedValue * (max - min))
    }
}

// MARK: - Analytics Manager

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    // MARK: - Properties
    
    private let coreDataManager = CoreDataManager.shared
    private var context: NSManagedObjectContext {
        return coreDataManager.context
    }
    
    // Thread safety for parameter changes
    static let parameterChangeQueue = DispatchQueue(label: "com.pendulum.parameterChangeQueue", attributes: .concurrent)
    
    // Tracking state
    internal var isTracking: Bool = false
    
    // Current session tracking
    internal var currentSessionId: UUID?
    internal var currentSessionMetrics: [String: Any]?
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
    internal var directionalChanges: [(time: Double, fromDirection: String, toDirection: String)] = []
    
    // Performance tracking
    internal var angleBuffer: [Double] = [] // For variance calculation
    internal var velocityBuffer: [Double] = [] // For velocity tracking
    internal var phaseSpaceHistory: [(theta: Double, omega: Double)] = [] // Historical phase space points
    internal var forceHistory: [(time: Double, force: Double, direction: String)] = [] // Force application history
    internal var forceHistoryWithTimestamps: [(time: Double, force: Double, direction: String, timestamp: Date)] = [] // Enhanced force history with timestamps
    private var totalForceApplied: Double = 0
    private var correctionEfficiency: [Double] = [] // Force applied vs. stability gained
    internal var reactionTimes: [Double] = [] // Time from instability to correction
    internal var reactionTimeHistory: [(time: Double, timestamp: Date)] = [] // Reaction times with timestamps
    
    // Phase space tracking
    internal var phaseSpacePoints: [(theta: Double, omega: Double)] = []
    private var currentLevel: Int = 0
    private var levelPhaseSpaceData: [Int: [(theta: Double, omega: Double)]] = [:]
    
    // Historical session tracking
    internal var sessions: [UUID: Date] = [:] // Active sessions tracking
    internal var sessionMetrics: [UUID: [String: Any]] = [:]
    private var sessionInteractions: [UUID: [[String: Any]]] = [:]
    private var historicalSessionDates: [UUID: Date] = [:]
    private var totalSessions: Int = 0
    private var totalScore: Int = 0
    private var totalBalanceTime: TimeInterval = 0
    
    // Current time range for dashboard metrics
    internal var currentTimeRange: AnalyticsTimeRange = .daily
    
    // Current selected parameter for parameter history display
    internal var currentSelectedParameter: PendulumParameter = .mass
    
    // Cache for parameter history to prevent constant regeneration
    private var parameterHistoryCache: [String: [(Date, Double)]] = [:]
    
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
        sessions[sessionId] = Date()
        
        // Reset all tracking buffers
        pendingInteractions = []
        interactionHistory = []
        pushFrequencyBuffer = []
        pushMagnitudeBuffer = []
        directionalPushes = ["left": 0, "right": 0]
        angleBuffer = []
        velocityBuffer = []
        phaseSpaceHistory = []
        forceHistory = []
        forceHistoryWithTimestamps = []
        totalForceApplied = 0
        correctionEfficiency = []
        reactionTimes = []
        reactionTimeHistory = []
        
        // Suppressed: Analytics tracking started debug output
    }
    
    func stopTracking() {
        // Calculate final metrics before ending
        if let sessionId = currentSessionId {
            calculateAndSavePerformanceMetrics(for: sessionId)
            
            // Store phase space data for the current level
            if !phaseSpacePoints.isEmpty {
                levelPhaseSpaceData[currentLevel] = phaseSpacePoints
                calculateAndSaveAveragePhaseSpace()
            }
        }
        
        // Clear tracking state
        isTracking = false
        currentSessionId = nil
        sessionStartTime = nil
        lastPushTime = nil
        lastInstabilityTime = nil
        
        // Suppressed: Analytics tracking stopped debug output
    }
    
    // MARK: - Interaction Tracking
    
    // Overloaded method with force parameter (used by debug system)
    func trackInteraction(eventType: String, force: Double, direction: String, angle: Double, velocity: Double, timestamp: Date) {
        guard isTracking else { return }
        
        trackInteraction(
            eventType: eventType,
            angle: angle,
            angleVelocity: velocity,
            magnitude: force,
            direction: direction
        )
    }
    
    func trackPendulumState(angle: Double, angleVelocity: Double) {
        guard isTracking, currentSessionId != nil else {
            // Skip tracking if not actively tracking
            return
        }
        
        // Store angle for variance calculation
        angleBuffer.append(angle)
        
        // Store velocity
        velocityBuffer.append(angleVelocity)
        
        // Keep buffer size manageable by trimming oldest values if too large
        if angleBuffer.count > 1000 {
            angleBuffer.removeFirst(angleBuffer.count - 1000)
        }
        if velocityBuffer.count > 1000 {
            velocityBuffer.removeFirst(velocityBuffer.count - 1000)
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
            // Suppressed: Cannot track interaction debug output
            return
        }
        
        // Comprehensive input validation with detailed logging
        if angle.isNaN {
            print("⚠️ Analytics: CRASH PREVENTION - angle is NaN")
            return
        }
        if angle.isInfinite {
            print("⚠️ Analytics: CRASH PREVENTION - angle is Infinite: \(angle)")
            return
        }
        if angleVelocity.isNaN {
            print("⚠️ Analytics: CRASH PREVENTION - angleVelocity is NaN")
            return
        }
        if angleVelocity.isInfinite {
            print("⚠️ Analytics: CRASH PREVENTION - angleVelocity is Infinite: \(angleVelocity)")
            return
        }
        if magnitude.isNaN {
            print("⚠️ Analytics: CRASH PREVENTION - magnitude is NaN")
            return
        }
        if magnitude.isInfinite {
            print("⚠️ Analytics: CRASH PREVENTION - magnitude is Infinite: \(magnitude)")
            return
        }
        
        print("📊 Analytics: trackInteraction called - angle: \(angle), velocity: \(angleVelocity), mag: \(magnitude), dir: \(direction)")
        
        // Calculate reaction time if this is a correction during unstable period
        var reactionTime = 0.0
        if eventType == "push" {
            print("📊 Analytics: Processing push event")
            
            let angleMinusPi = angle - Double.pi
            print("📊 Analytics: angle - pi = \(angleMinusPi)")
            
            let normalizedAngle = normalizeAngle(angleMinusPi)
            print("📊 Analytics: normalized angle = \(normalizedAngle)")
            
            guard !normalizedAngle.isNaN && !normalizedAngle.isInfinite else {
                print("⚠️ Analytics: Invalid normalized angle: \(normalizedAngle) from angle: \(angle)")
                return
            }
            
            let angleFromVertical = abs(normalizedAngle)
            print("📊 Analytics: angle from vertical = \(angleFromVertical)")
            
            // If we're currently unstable and have a recorded instability time
            if angleFromVertical > instabilityThreshold, let lastInstability = lastInstabilityTime {
                reactionTime = Date().timeIntervalSince(lastInstability)
                print("📊 Analytics: calculated reaction time = \(reactionTime)")
                // Only record reasonable reaction times (0.1 to 3 seconds) and valid values
                if reactionTime >= 0.1 && reactionTime <= 3.0 && !reactionTime.isNaN && !reactionTime.isInfinite {
                    reactionTimes.append(reactionTime)
                    print("📊 Analytics: reaction time recorded")
                }
            }
            
            // If we just became unstable, record the time but don't reset instability tracking yet
            if angleFromVertical > instabilityThreshold && lastInstabilityTime == nil {
                lastInstabilityTime = Date()
                // Removed debug print - instability tracking started
            }
        }
        
        // Track push frequency
        if eventType == "push" {
            if let lastPush = lastPushTime {
                let timeSinceLastPush = Date().timeIntervalSince(lastPush)
                pushFrequencyBuffer.append(timeSinceLastPush)
            }
            lastPushTime = Date()
            
            // Track directional bias - ensure proper categorization
            let normalizedDirection = direction.lowercased().trimmingCharacters(in: .whitespaces)
            // Suppressed: Tracking push direction debug output
            
            if normalizedDirection.contains("left") || normalizedDirection == "left" {
                directionalPushes["left", default: 0] += 1
                // Suppressed: Left push recorded debug output
            } else if normalizedDirection.contains("right") || normalizedDirection == "right" {
                directionalPushes["right", default: 0] += 1
                // Suppressed: Right push recorded debug output
            } else {
                // Fallback for unclear directions
                directionalPushes[normalizedDirection, default: 0] += 1
                // Suppressed: Unknown direction push recorded debug output
            }
            
            // Suppressed: Current directional pushes debug output
            
            // Track magnitude for distribution analysis
            print("📊 Analytics: Processing magnitude tracking")
            let safeMagnitude = abs(magnitude)
            print("📊 Analytics: safe magnitude = \(safeMagnitude)")
            
            if !safeMagnitude.isNaN && !safeMagnitude.isInfinite {
                print("📊 Analytics: Adding to pushMagnitudeBuffer")
                pushMagnitudeBuffer.append(safeMagnitude)
                
                // Track force history
                let sessionStart = sessionStartTime ?? Date()
                let currentTime = Date().timeIntervalSince(sessionStart)
                print("📊 Analytics: calculated currentTime = \(currentTime)")
                
                if !currentTime.isNaN && !currentTime.isInfinite {
                    print("📊 Analytics: Adding to forceHistory")
                    forceHistory.append((time: currentTime, force: safeMagnitude, direction: direction))
                    
                    print("📊 Analytics: Adding to forceHistoryWithTimestamps")
                    forceHistoryWithTimestamps.append((time: currentTime, force: safeMagnitude, direction: direction, timestamp: Date()))
                    
                    print("📊 Analytics: Updating totalForceApplied from \(totalForceApplied) by adding \(safeMagnitude)")
                    let newTotal = totalForceApplied + safeMagnitude
                    if newTotal.isNaN || newTotal.isInfinite {
                        print("⚠️ Analytics: CRASH PREVENTION - totalForceApplied would become NaN/Infinite: \(totalForceApplied) + \(safeMagnitude) = \(newTotal)")
                        return
                    }
                    totalForceApplied = newTotal
                    print("📊 Analytics: New totalForceApplied = \(totalForceApplied)")
                } else {
                    print("⚠️ Analytics: Invalid currentTime calculated: \(currentTime)")
                }
            } else {
                print("⚠️ Analytics: Invalid magnitude value: \(magnitude) -> \(safeMagnitude)")
            }
        }
        
        // Create and store the interaction data with additional validation
        print("📊 Analytics: Creating InteractionEventData")
        let safeAngle = angle.isNaN || angle.isInfinite ? 0.0 : angle
        let safeAngleVelocity = angleVelocity.isNaN || angleVelocity.isInfinite ? 0.0 : angleVelocity
        let safeMagnitude = magnitude.isNaN || magnitude.isInfinite ? 0.0 : magnitude
        let safeReactionTime = reactionTime.isNaN || reactionTime.isInfinite ? 0.0 : reactionTime
        
        print("📊 Analytics: Safe values - angle: \(safeAngle), velocity: \(safeAngleVelocity), magnitude: \(safeMagnitude), reactionTime: \(safeReactionTime)")
        
        print("📊 Analytics: About to create InteractionEventData object")
        let interaction = InteractionEventData(
            timestamp: Date(),
            eventType: eventType,
            angle: safeAngle,
            angleVelocity: safeAngleVelocity,
            magnitude: safeMagnitude,
            direction: direction,
            reactionTime: safeReactionTime
        )
        print("📊 Analytics: InteractionEventData created successfully")
        
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
    
    internal func calculateStabilityScore() -> Double {
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
        
        // Debug check for NaN
        if stabilityScore.isNaN || stabilityScore.isInfinite {
            print("ERROR: NaN/Infinite stability score. Mean: \(mean), Variance: \(variance), AngleBuffer count: \(angleBuffer.count)")
            return 0.0
        }
        
        return stabilityScore
    }
    
    internal func calculateEfficiencyRating() -> Double {
        // If no meaningful force applied, return 0
        guard totalForceApplied > 0.001 && !angleBuffer.isEmpty else { return 0 }
        
        // Calculate stability (inverse of angle variance)
        let stability = calculateStabilityScore()
        guard stability > 0 else { return 0 }
        
        // Efficiency is stability achieved per unit of force
        // Use square root to reduce sensitivity to total force
        let efficiencyRating = stability / sqrt(totalForceApplied)
        
        // Debug logging for troubleshooting
        // Removed debug print - efficiency calculation
        
        // Check for invalid values
        if efficiencyRating.isNaN || efficiencyRating.isInfinite {
            print("ERROR: Invalid efficiency rating. Stability: \(stability), TotalForce: \(totalForceApplied)")
            return 0.0
        }
        
        // Scale appropriately (multiply by 10 to get reasonable range)
        let scaledRating = min(efficiencyRating * 10, 100)
        // Removed debug print - final efficiency
        
        return scaledRating
    }
    
    internal func calculateDirectionalBias() -> Double {
        let leftCount = directionalPushes["left"] ?? 0
        let rightCount = directionalPushes["right"] ?? 0
        let total = leftCount + rightCount
        
        guard total > 0 else { return 0 }
        
        // Calculate bias from -1.0 (completely left) to 1.0 (completely right)
        return Double(rightCount - leftCount) / Double(total)
    }
    
    internal func calculateOvercorrectionRate() -> Double {
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
    
    internal func determinePlayerStyle(stabilityScore: Double, efficiencyRating: Double, directionalBias: Double, overcorrectionRate: Double) -> String {
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
    
    func updateAggregatedAnalytics() {
        // This method will be called periodically to update aggregated statistics
        updateDailyAnalytics()
        updateWeeklyAnalytics()
        updateMonthlyAnalytics()
    }
    
    // MARK: - Historical Data Methods
    
    func createHistoricalSession(
        sessionId: UUID,
        date: Date,
        duration: TimeInterval,
        score: Int,
        levelsCompleted: Int,
        skillLevel: AISkillLevel
    ) {
        // Store the historical date for this session
        historicalSessionDates[sessionId] = date
        
        // Create session metrics with historical context
        sessionMetrics[sessionId] = [
            "sessionId": sessionId.uuidString,
            "startTime": date,
            "duration": duration,
            "score": Double(score),
            "levelsCompleted": Double(levelsCompleted),
            "skillLevel": skillLevel.rawValue
        ]
        
        // Track for aggregation
        totalSessions += 1
        totalScore += score
        totalBalanceTime += duration
    }
    
    func createHistoricalInteraction(
        sessionId: UUID,
        timestamp: Date,
        eventType: String,
        direction: String,
        magnitude: Double
    ) {
        // Create interaction record with historical timestamp
        let interaction: [String: Any] = [
            "sessionId": sessionId.uuidString,
            "timestamp": timestamp,
            "eventType": eventType,
            "direction": direction,
            "magnitude": magnitude,
            "angle": Double.random(in: -0.5...0.5), // Simulate angle data
            "angleVelocity": Double.random(in: -1.0...1.0) // Simulate velocity data
        ]
        
        // Store in session interactions
        if sessionInteractions[sessionId] == nil {
            sessionInteractions[sessionId] = []
        }
        sessionInteractions[sessionId]?.append(interaction)
        
        // Update directional counters
        if direction == "left" {
            directionalPushes["left", default: 0] += 1
        } else if direction == "right" {
            directionalPushes["right", default: 0] += 1
        }
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
        // Validate input first
        guard !angle.isNaN && !angle.isInfinite else {
            print("⚠️ Analytics: Cannot normalize invalid angle: \(angle)")
            return 0.0 // Return safe default
        }
        
        // Normalize angle to [-π, π]
        let result = atan2(sin(angle), cos(angle))
        
        // Validate result
        guard !result.isNaN && !result.isInfinite else {
            print("⚠️ Analytics: Normalization produced invalid result for angle: \(angle)")
            return 0.0 // Return safe default
        }
        
        return result
    }
    
    // MARK: - Phase Space Tracking
    
    func trackPhaseSpacePoint(theta: Double, omega: Double) {
        guard isTracking else { return }
        
        phaseSpacePoints.append((theta: theta, omega: omega))
        phaseSpaceHistory.append((theta: theta, omega: omega))
        
        // Limit the number of points to prevent memory issues
        let maxPoints = 1000
        if phaseSpacePoints.count > maxPoints {
            phaseSpacePoints.removeFirst()
        }
        if phaseSpaceHistory.count > maxPoints {
            phaseSpaceHistory.removeFirst()
        }
    }
    
    func getCurrentLevel() -> Int {
        return currentLevel
    }
    
    func setCurrentLevel(_ level: Int) {
        if currentLevel != level {
            // Save phase space data for the previous level
            if !phaseSpacePoints.isEmpty {
                levelPhaseSpaceData[currentLevel] = phaseSpacePoints
                
                // Calculate and save average phase space data after each level
                calculateAndSaveAveragePhaseSpace()
            }
            
            // Reset for new level
            currentLevel = level
            phaseSpacePoints = []
        }
    }
    
    private func calculateAndSaveAveragePhaseSpace() {
        guard let sessionId = currentSessionId else { return }
        
        // Calculate average phase space for each level
        for (level, points) in levelPhaseSpaceData {
            let averageData = calculateAveragePhaseSpaceData(points: points)
            
            // Convert to a format that can be stored in Core Data
            let dataToStore = encodePhaseSpaceData(averageData)
            
            // Save to Core Data
            context.performAndWait {
                // Find or create performance metrics for this session and level
                let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "sessionId == %@ AND averagePhaseSpaceLevel == %d", sessionId as CVarArg, level)
                
                do {
                    let metrics = try context.fetch(fetchRequest).first ?? PerformanceMetrics(context: context)
                    metrics.sessionId = sessionId
                    metrics.averagePhaseSpaceLevel = Int32(level)
                    metrics.averagePhaseSpaceData = dataToStore
                    metrics.timestamp = Date()
                    
                    try context.save()
                } catch {
                    print("Error saving phase space data: \(error)")
                }
            }
        }
    }
    
    private func calculateAveragePhaseSpaceData(points: [(theta: Double, omega: Double)]) -> [(theta: Double, omega: Double)] {
        guard !points.isEmpty else { return [] }
        
        // Group points into bins for averaging
        let binCount = 100
        let binSize = points.count / binCount
        
        var averagedPoints: [(theta: Double, omega: Double)] = []
        
        for i in 0..<binCount {
            let startIndex = i * binSize
            let endIndex = min((i + 1) * binSize, points.count)
            
            if startIndex < endIndex {
                let binPoints = Array(points[startIndex..<endIndex])
                let avgTheta = binPoints.map { $0.theta }.reduce(0, +) / Double(binPoints.count)
                let avgOmega = binPoints.map { $0.omega }.reduce(0, +) / Double(binPoints.count)
                
                averagedPoints.append((theta: avgTheta, omega: avgOmega))
            }
        }
        
        return averagedPoints
    }
    
    private func encodePhaseSpaceData(_ data: [(theta: Double, omega: Double)]) -> Data? {
        let dictionary = ["points": data.map { ["theta": $0.theta, "omega": $0.omega] }]
        return try? JSONSerialization.data(withJSONObject: dictionary)
    }
    
    func getAveragePhaseSpaceData(for level: Int? = nil) -> [Int: [(theta: Double, omega: Double)]] {
        var result: [Int: [(theta: Double, omega: Double)]] = [:]
        
        let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
        if let level = level {
            fetchRequest.predicate = NSPredicate(format: "averagePhaseSpaceLevel == %d", level)
        } else {
            fetchRequest.predicate = NSPredicate(format: "averagePhaseSpaceData != nil")
        }
        
        context.performAndWait {
            do {
                let metrics = try context.fetch(fetchRequest)
                
                for metric in metrics {
                    if let data = metric.averagePhaseSpaceData,
                       let points = decodePhaseSpaceData(data) {
                        result[Int(metric.averagePhaseSpaceLevel)] = points
                    }
                }
            } catch {
                print("Error fetching average phase space data: \(error)")
            }
        }
        
        return result
    }
    
    private func decodePhaseSpaceData(_ data: Data) -> [(theta: Double, omega: Double)]? {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let points = dictionary["points"] as? [[String: Double]] else {
            return nil
        }
        
        return points.compactMap { point in
            guard let theta = point["theta"],
                  let omega = point["omega"] else { return nil }
            return (theta: theta, omega: omega)
        }
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
    
    // MARK: - Additional Dashboard Statistics
    
    func getTotalLevelsCompleted() -> Int {
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        
        do {
            let sessions = try context.fetch(fetchRequest)
            // Count unique highest levels reached across all sessions
            let maxLevel = sessions.map { Int($0.highestLevel) }.max() ?? 0
            return maxLevel
        } catch {
            print("Error fetching total levels completed: \(error)")
            return 0
        }
    }
    
    func getAverageTimePerLevel() -> Double {
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "highestLevel > 0")
        
        do {
            let sessions = try context.fetch(fetchRequest)
            guard !sessions.isEmpty else { return 0 }
            
            let totalTime = sessions.reduce(0.0) { $0 + $1.duration }
            let totalLevels = sessions.reduce(0) { $0 + Int($1.highestLevel) }
            
            return totalLevels > 0 ? totalTime / Double(totalLevels) : 0
        } catch {
            print("Error calculating average time per level: \(error)")
            return 0
        }
    }
    
    func getLongestBalanceStreak() -> Int {
        // Get all interaction events from current session
        guard let sessionId = currentSessionId else {
            // Try to get from most recent session
            let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                if let metric = try context.fetch(fetchRequest).first {
                    // Estimate based on stability score
                    // Higher stability = longer balance streaks
                    return Int(metric.stabilityScore * 0.5) // Convert to seconds estimate
                }
            } catch {
                print("Error fetching longest balance streak: \(error)")
            }
            return 0
        }
        
        // For current session, analyze angle buffer
        var longestStreak = 0
        var currentStreak = 0
        let stabilityThreshold = 0.3 // Radians from vertical
        
        for angle in angleBuffer {
            let angleFromVertical = abs(normalizeAngle(angle - Double.pi))
            if angleFromVertical < stabilityThreshold {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        // Convert from samples to seconds (assuming 60 fps)
        return longestStreak / 60
    }
    
    func getPlaySessionsLastWeek() -> Int {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-604800) // 7 days ago
        
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Error counting play sessions last week: \(error)")
            return 0
        }
    }
    
    // MARK: - Missing Chart Data Methods
    
    func getLevelCompletionsByTimePeriod(timeScale: AnalyticsTimeRange = .daily) -> [(Date, Double)] {
        // Get actual level completions from Core Data
        let coreDataManager = CoreDataManager.shared
        let calendar = Calendar.current
        let now = Date()
        var timeBins: [(Date, Double)] = []
        
        // Determine the date range based on time scale
        let (startDate, endDate, binComponent) = getDateRangeForTimeScale(timeScale, from: now)
        
        // Fetch level completions within the date range
        let allCompletions = coreDataManager.getLevelCompletions()
        let relevantCompletions = allCompletions.filter { completion in
            guard let completionDate = completion.completionDate else { return false }
            return completionDate >= startDate && completionDate <= endDate
        }
        
        // Group completions by time bins
        switch timeScale {
        case .session:
            // For session view, show last 2 hours in 10-minute intervals
            let sessionStart = now.addingTimeInterval(-2 * 3600) // 2 hours ago
            for i in 0..<12 {
                let binStart = sessionStart.addingTimeInterval(Double(i) * 600) // 10-minute intervals
                let binEnd = binStart.addingTimeInterval(600)
                
                let count = relevantCompletions.filter { completion in
                    guard let date = completion.completionDate else { return false }
                    return date >= binStart && date < binEnd
                }.count
                
                timeBins.append((binStart, Double(count)))
            }
            
        case .daily:
            // Show levels completed by hour of the day
            let startOfDay = calendar.startOfDay(for: now)
            for hour in 0..<24 {
                let binStart = calendar.date(byAdding: .hour, value: hour, to: startOfDay)!
                let binEnd = calendar.date(byAdding: .hour, value: 1, to: binStart)!
                
                let count = relevantCompletions.filter { completion in
                    guard let date = completion.completionDate else { return false }
                    return date >= binStart && date < binEnd
                }.count
                
                timeBins.append((binStart, Double(count)))
            }
            
        case .weekly:
            // Show levels completed by day of the week
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            for day in 0..<7 {
                let binStart = calendar.date(byAdding: .day, value: day, to: startOfWeek)!
                let binEnd = calendar.date(byAdding: .day, value: 1, to: binStart)!
                
                let count = relevantCompletions.filter { completion in
                    guard let date = completion.completionDate else { return false }
                    return date >= binStart && date < binEnd
                }.count
                
                timeBins.append((binStart, Double(count)))
            }
            
        case .monthly:
            // Show levels completed by day for the last 30 days
            for day in 0..<30 {
                let binStart = calendar.date(byAdding: .day, value: -29 + day, to: now)!
                let binEnd = calendar.date(byAdding: .day, value: 1, to: binStart)!
                
                let count = relevantCompletions.filter { completion in
                    guard let date = completion.completionDate else { return false }
                    return date >= binStart && date < binEnd
                }.count
                
                timeBins.append((binStart, Double(count)))
            }
            
        case .yearly:
            // Show levels completed by month of the year
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            for month in 0..<12 {
                let binStart = calendar.date(byAdding: .month, value: month, to: startOfYear)!
                let binEnd = calendar.date(byAdding: .month, value: 1, to: binStart)!
                
                let count = relevantCompletions.filter { completion in
                    guard let date = completion.completionDate else { return false }
                    return date >= binStart && date < binEnd
                }.count
                
                timeBins.append((binStart, Double(count)))
            }
        }
        
        // If no data found, return sample data for visualization
        if timeBins.allSatisfy({ $0.1 == 0 }) {
            return getLevelCompletionsSampleData(timeScale: timeScale)
        }
        
        return timeBins
    }
    
    private func getDateRangeForTimeScale(_ timeScale: AnalyticsTimeRange, from date: Date) -> (startDate: Date, endDate: Date, binComponent: Calendar.Component) {
        let calendar = Calendar.current
        
        switch timeScale {
        case .session:
            return (date.addingTimeInterval(-2 * 3600), date, .minute)
        case .daily:
            return (calendar.startOfDay(for: date), date, .hour)
        case .weekly:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            return (startOfWeek, date, .day)
        case .monthly:
            return (date.addingTimeInterval(-30 * 24 * 3600), date, .day)
        case .yearly:
            let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
            return (startOfYear, date, .month)
        }
    }
    
    private func getLevelCompletionsSampleData(timeScale: AnalyticsTimeRange) -> [(Date, Double)] {
        // Return sample data when no real data is available
        let now = Date()
        var timeBins: [(Date, Double)] = []
        
        switch timeScale {
        case .session:
            for i in 0..<12 {
                let date = now.addingTimeInterval(Double(i - 12) * 600)
                timeBins.append((date, Double.random(in: 0...3)))
            }
        case .daily:
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: now)
            for hour in 0..<24 {
                let date = calendar.date(byAdding: .hour, value: hour, to: startOfDay)!
                let completions = hour >= 8 && hour <= 22 ? Double.random(in: 1...4) : 0
                timeBins.append((date, completions))
            }
        default:
            return []
        }
        
        return timeBins
    }
    
    func getParameterHistoryTimeSeries(parameter: PendulumParameter = .mass, timeScale: AnalyticsTimeRange = .daily) -> [(Date, Double)] {
        // Try to get actual parameter data from level completions
        let coreDataManager = CoreDataManager.shared
        let calendar = Calendar.current
        let now = Date()
        var timeSeries: [(Date, Double)] = []
        
        // Get level completions
        let completions = coreDataManager.getLevelCompletions()
        
        // Extract parameter values based on selected parameter
        let parameterData: [(Date, Double)] = completions.compactMap { completion in
            guard let date = completion.completionDate else { return nil }
            
            let value: Double
            switch parameter {
            case .mass:
                value = completion.massMultiplier
            case .length:
                value = completion.lengthMultiplier
            case .gravity:
                value = completion.gravityMultiplier * 9.81 // Convert multiplier to actual value
            case .damping:
                value = completion.dampingValue
            case .forceMultiplier:
                value = completion.springConstantValue // Spring constant as force multiplier proxy
            }
            
            return (date, value)
        }
        
        // If we have real data, bin it according to time scale
        if !parameterData.isEmpty {
            let (startDate, endDate, _) = getDateRangeForTimeScale(timeScale, from: now)
            let relevantData = parameterData.filter { $0.0 >= startDate && $0.0 <= endDate }
            
            if !relevantData.isEmpty {
                // Bin the data according to time scale
                switch timeScale {
                case .session:
                    // Show last 2 hours in 10-minute intervals
                    let sessionStart = now.addingTimeInterval(-2 * 3600)
                    for i in 0..<12 {
                        let binStart = sessionStart.addingTimeInterval(Double(i) * 600)
                        let binEnd = binStart.addingTimeInterval(600)
                        
                        let binData = relevantData.filter { $0.0 >= binStart && $0.0 < binEnd }
                        if !binData.isEmpty {
                            let avgValue = binData.map { $0.1 }.reduce(0, +) / Double(binData.count)
                            timeSeries.append((binStart, avgValue))
                        }
                    }
                    
                case .daily:
                    // Show by hour
                    let startOfDay = calendar.startOfDay(for: now)
                    for hour in 0..<24 {
                        let binStart = calendar.date(byAdding: .hour, value: hour, to: startOfDay)!
                        let binEnd = calendar.date(byAdding: .hour, value: 1, to: binStart)!
                        
                        let binData = relevantData.filter { $0.0 >= binStart && $0.0 < binEnd }
                        if !binData.isEmpty {
                            let avgValue = binData.map { $0.1 }.reduce(0, +) / Double(binData.count)
                            timeSeries.append((binStart, avgValue))
                        }
                    }
                    
                case .weekly, .monthly, .yearly:
                    // For longer time scales, use daily averages
                    let dayCount = timeScale == .weekly ? 7 : (timeScale == .monthly ? 30 : 365)
                    for day in 0..<dayCount {
                        let binStart = calendar.date(byAdding: .day, value: -dayCount + day + 1, to: now)!
                        let binEnd = calendar.date(byAdding: .day, value: 1, to: binStart)!
                        
                        let binData = relevantData.filter { $0.0 >= binStart && $0.0 < binEnd }
                        if !binData.isEmpty {
                            let avgValue = binData.map { $0.1 }.reduce(0, +) / Double(binData.count)
                            timeSeries.append((binStart, avgValue))
                        }
                    }
                }
                
                if !timeSeries.isEmpty {
                    return timeSeries
                }
            }
        }
        
        // Fall back to cached sample data if no real data available
        let cacheKey = "\(parameter.rawValue)_\(timeScale)"
        if let cachedData = parameterHistoryCache[cacheKey] {
            return cachedData
        }
        
        // Generate sample data
        let (intervalCount, intervalDuration, baseValue, variation) = getParameterTimeScaleSettings(for: parameter, timeScale: timeScale)
        let seed = parameter.rawValue.hash
        var randomGenerator = SeededRandomGenerator(seed: seed)
        
        for i in 0..<intervalCount {
            let date = now.addingTimeInterval(Double(i - intervalCount) * intervalDuration)
            let progressionFactor = Double(i) / Double(intervalCount - 1)
            let noise = randomGenerator.nextDouble(min: -0.1, max: 0.1)
            let value = baseValue + (variation * progressionFactor) + (variation * 0.2 * noise)
            timeSeries.append((date, max(0.1, value)))
        }
        
        parameterHistoryCache[cacheKey] = timeSeries
        return timeSeries
    }
    
    private func getParameterTimeScaleSettings(for parameter: PendulumParameter, timeScale: AnalyticsTimeRange) -> (intervalCount: Int, intervalDuration: TimeInterval, baseValue: Double, variation: Double) {
        // Base values and typical ranges for each parameter
        let (baseValue, variation): (Double, Double) = {
            switch parameter {
            case .mass:
                return (0.8, 0.6) // 0.8kg base, varies by ±0.6kg
            case .length:
                return (0.9, 0.4) // 0.9m base, varies by ±0.4m
            case .gravity:
                return (9.8, 3.0) // 9.8 m/s² base, varies by ±3.0 (for different planets/modes)
            case .damping:
                return (0.15, 0.25) // 0.15 base, varies by ±0.25
            case .forceMultiplier:
                return (1.0, 0.8) // 1.0 base, varies by ±0.8
            }
        }()
        
        // Time scale settings
        let (intervalCount, intervalDuration): (Int, TimeInterval) = {
            switch timeScale {
            case .session:
                return (20, 30) // 20 points, 30 seconds apart
            case .daily:
                return (24, 3600) // 24 points, 1 hour apart
            case .weekly:
                return (14, 43200) // 14 points, 12 hours apart
            case .monthly:
                return (30, 86400) // 30 points, 1 day apart
            case .yearly:
                return (52, 604800) // 52 points, 1 week apart
            }
        }()
        
        return (intervalCount, intervalDuration, baseValue, variation)
    }
    
    // MARK: - Additional Methods for Testing
    
    func getAllSessions() -> [UUID] {
        return Array(sessions.keys)
    }
    
    func trackFailure(reason: String, finalAngle: Double, finalVelocity: Double, level: Int) {
        guard isTracking, let sessionId = currentSessionId else { return }
        
        // Create failure data
        let failureData: [String: Any] = [
            "sessionId": sessionId.uuidString,
            "reason": reason,
            "finalAngle": finalAngle,
            "finalVelocity": finalVelocity,
            "level": level,
            "timestamp": Date(),
            "gameTime": Date().timeIntervalSince(sessionStartTime ?? Date())
        ]
        
        // Store in session metrics
        var currentMetrics = sessionMetrics[sessionId] ?? [:]
        var failures = currentMetrics["failures"] as? [[String: Any]] ?? []
        failures.append(failureData)
        currentMetrics["failures"] = failures
        sessionMetrics[sessionId] = currentMetrics
        
        print("Tracked failure: \(reason) at level \(level)")
    }
    
    func trackLevelCompletion(level: Int, completionTime: Double, score: Int, perturbationType: String) {
        guard isTracking, let sessionId = currentSessionId else { return }
        
        // Validate input values to prevent NaN/Infinite errors
        guard !completionTime.isNaN && !completionTime.isInfinite && completionTime >= 0 else {
            print("⚠️ Analytics: Invalid completion time: \(completionTime), using 0.0")
            return
        }
        
        // Ensure score is valid (Int should not be NaN, but let's be extra safe)
        let safeScore = score < 0 ? 0 : score
        let safeCompletionTime = max(0.0, completionTime)
        
        // Create level completion data with safe values
        let completionData: [String: Any] = [
            "sessionId": sessionId.uuidString,
            "level": level,
            "completionTime": safeCompletionTime,
            "score": safeScore,
            "perturbationType": perturbationType,
            "timestamp": Date()
        ]
        
        // Store in session metrics
        var currentMetrics = sessionMetrics[sessionId] ?? [:]
        var completions = currentMetrics["levelCompletions"] as? [[String: Any]] ?? []
        completions.append(completionData)
        currentMetrics["levelCompletions"] = completions
        sessionMetrics[sessionId] = currentMetrics
        
        print("Tracked level completion: Level \(level) in \(completionTime)s")
    }
    
    func getPerformanceMetrics(for sessionId: UUID) -> [String: Any] {
        // Return stored session metrics or calculate from current data
        if let storedMetrics = sessionMetrics[sessionId] {
            return storedMetrics
        }
        
        // If no stored metrics, create basic metrics from current session data
        guard sessionId == currentSessionId else {
            return [:]
        }
        
        let finalScore = angleBuffer.count * 10 // Simple scoring
        let levelsCompleted = max(currentLevel, 1)
        let totalPlayTime = Date().timeIntervalSince(sessionStartTime ?? Date())
        let stabilityScore = calculateStabilityScore()
        
        return [
            "finalScore": Double(finalScore),
            "levelsCompleted": Double(levelsCompleted),
            "totalPlayTime": totalPlayTime,
            "stabilityScore": stabilityScore,
            "pushCount": Double(directionalPushes.values.reduce(0, +)),
            "averageReactionTime": reactionTimes.isEmpty ? 0.0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        ]
    }
    
    // MARK: - Time Range Management
    
    func setCurrentTimeRange(_ timeRange: AnalyticsTimeRange) {
        currentTimeRange = timeRange
    }
    
    func getCurrentTimeRange() -> AnalyticsTimeRange {
        return currentTimeRange
    }
    
    // MARK: - Parameter Selection Management
    
    func setCurrentSelectedParameter(_ parameter: PendulumParameter) {
        currentSelectedParameter = parameter
        // Clear cache when parameter changes to generate new data
        parameterHistoryCache.removeAll()
    }
    
    func getCurrentSelectedParameter() -> PendulumParameter {
        return currentSelectedParameter
    }
}