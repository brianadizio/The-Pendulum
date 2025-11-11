// AnalyticsModelAdditions.swift
// This file contains code entities that correspond to the Core Data model changes
// needed for the analytics system. Import these into Xcode's Core Data Model Editor.

import Foundation
import CoreData


/* The following Core Data entities should be added to the existing
 PendulumScoreData.xcdatamodeld model:
 
 Entity: InteractionEvent
 - sessionId: UUID
 - timestamp: Date
 - eventType: String (push, correction, etc.)
 - angle: Double (pendulum angle at time of interaction)
 - angleVelocity: Double (angular velocity at time of interaction)
 - magnitude: Double (force magnitude applied)
 - direction: String (left/right)
 - reactionTime: Double (time since instability detected)
 - relationship: belongsTo -> PlaySession
 
 Entity: PerformanceMetrics
 - sessionId: UUID
 - timestamp: Date
 - stabilityScore: Double (based on angle variance)
 - efficiencyRating: Double (force vs stability gained)
 - averageCorrectionTime: Double
 - directionalBias: Double (-1.0 to 1.0, negative=left, positive=right)
 - overcorrectionRate: Double (percentage of overcorrections)
 - playerStyle: String (classification of play style)
 - relationship: belongsTo -> PlaySession
 
 Entity: AggregatedAnalytics
 - startDate: Date
 - endDate: Date
 - period: String (daily, weekly, monthly)
 - sessionCount: Int32
 - totalPlayTime: Double
 - averageStabilityScore: Double
 - averageEfficiencyRating: Double
 - learningCurveSlope: Double (improvement rate)
 - playerStyleTrend: String
 - relationship: hasMany -> PerformanceMetrics
 
 Update Entity: PlaySession (add relationships)
 - interactions: hasMany -> InteractionEvent
 - metrics: hasOne -> PerformanceMetrics
 

// Swift class extensions that will be used to interact with the CoreData model
// These use the CoreData generated classes that will be created when the model is updated
// IMPORTANT: Uncomment these extensions once the Core Data model is updated in Xcode

*/
extension InteractionEvent {
    static func createInteraction(in context: NSManagedObjectContext,
                                  sessionId: UUID,
                                  eventType: String,
                                  angle: Double,
                                  angleVelocity: Double,
                                  magnitude: Double,
                                  direction: String,
                                  reactionTime: Double) -> InteractionEvent {
        let event = InteractionEvent(context: context)
        event.sessionId = sessionId
        event.timestamp = Date()
        event.eventType = eventType
        event.angle = angle
        event.angleVelocity = angleVelocity
        event.magnitude = magnitude
        event.direction = direction
        event.reactionTime = reactionTime
        return event
    }
}

extension PerformanceMetrics {
    static func createMetrics(in context: NSManagedObjectContext,
                              sessionId: UUID,
                              stabilityScore: Double,
                              efficiencyRating: Double,
                              averageCorrectionTime: Double,
                              directionalBias: Double,
                              overcorrectionRate: Double,
                              playerStyle: String) -> PerformanceMetrics {
        let metrics = PerformanceMetrics(context: context)
        metrics.sessionId = sessionId
        metrics.timestamp = Date()
        metrics.stabilityScore = stabilityScore
        metrics.efficiencyRating = efficiencyRating
        metrics.averageCorrectionTime = averageCorrectionTime
        metrics.directionalBias = directionalBias
        metrics.overcorrectionRate = overcorrectionRate
        metrics.playerStyle = playerStyle
        return metrics
    }
}

extension AggregatedAnalytics {
    static func createAggregation(in context: NSManagedObjectContext,
                                 startDate: Date,
                                 endDate: Date,
                                 period: String,
                                 sessionCount: Int,
                                 totalPlayTime: Double,
                                 averageStabilityScore: Double,
                                 averageEfficiencyRating: Double,
                                 learningCurveSlope: Double,
                                 playerStyleTrend: String) -> AggregatedAnalytics {
        let aggregation = AggregatedAnalytics(context: context)
        aggregation.startDate = startDate
        aggregation.endDate = endDate
        aggregation.period = period
        aggregation.sessionCount = Int32(sessionCount)
        aggregation.totalPlayTime = totalPlayTime
        aggregation.averageStabilityScore = averageStabilityScore
        aggregation.averageEfficiencyRating = averageEfficiencyRating
        aggregation.learningCurveSlope = learningCurveSlope
        aggregation.playerStyleTrend = playerStyleTrend
        return aggregation
    }
}


// Note: The above model needs to be implemented in Xcode's Core Data Model Editor.
// This file serves as a reference for the needed model changes and extensions.
