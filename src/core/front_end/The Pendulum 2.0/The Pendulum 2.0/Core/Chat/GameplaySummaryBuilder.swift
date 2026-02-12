// GameplaySummaryBuilder.swift
// The Pendulum 2.0
// Builds comprehensive gameplay context for AI chat from multiple data sources

import Foundation

/// Builds a GameplaySummary by aggregating data from:
/// - CSVMetricsCalculator (gameplay metrics)
/// - HealthKitManager (health data)
/// - ProfileManager (user profile)
/// - AppGroupManager (cross-app Maze data)
class GameplaySummaryBuilder {

    /// Build a complete gameplay summary from all available data sources
    /// - Parameters:
    ///   - metricsCalculator: The metrics calculator with gameplay data
    ///   - timeRange: The time range to consider for metrics
    /// - Returns: A complete GameplaySummary for AI context
    static func build(
        from metricsCalculator: CSVMetricsCalculator,
        timeRange: AnalyticsTimeRange = .allTime
    ) -> GameplaySummary {

        let basic = metricsCalculator.basicMetrics
        let advanced = metricsCalculator.advancedMetrics
        let scientific = metricsCalculator.scientificMetrics
        let topology = metricsCalculator.topologyMetrics
        let educational = metricsCalculator.educationalMetrics
        let ai = metricsCalculator.aiMetrics

        // Health data
        let healthSnapshot = HealthKitManager.shared.latestHealthSnapshot
        let healthSteps = healthSnapshot?.steps
        let healthRestingHR = healthSnapshot?.restingHeartRate
        let healthHRV = healthSnapshot?.heartRateVariability
        let healthSleepHours: Double? = {
            if let duration = healthSnapshot?.sleepDuration {
                return duration / 3600.0
            }
            return nil
        }()

        // Profile data
        let profile = ProfileManager.shared.currentProfile
        let trainingGoal = profile?.trainingGoal.rawValue  // trainingGoal is not optional
        let ageRange = profile?.ageRange?.rawValue
        let dominantHand = profile?.dominantHand?.rawValue

        // Maze data
        let mazeData = AppGroupManager.shared.loadMazeData()
        let mazeSessions = mazeData?.sessions.count
        let latestMazeSession = mazeData?.sessions.last
        let mazeMotorScore = latestMazeSession?.motorScore
        let mazeFlowScore = latestMazeSession?.flowStateScore
        let mazeCognitiveScore = latestMazeSession?.cognitiveScore

        return GameplaySummary(
            // Basic
            sessionsPlayed: basic.sessionsPlayed,
            totalPlayTime: basic.totalSessionTime,
            maxLevel: basic.maxLevel,
            stabilityScore: basic.stabilityScore,
            efficiencyRating: basic.efficiencyRating,
            totalPushes: basic.totalPushes,

            // Advanced
            directionalBias: advanced.directionalBias,
            overcorrectionRate: advanced.overcorrectionRate,
            averageReactionTime: advanced.averageReactionTime,

            // Scientific
            phaseSpaceCoverage: scientific.phaseSpaceCoverage,
            lyapunovExponent: scientific.lyapunovExponent,
            angularDeviationStdDev: scientific.angularDeviationStdDev,
            energyManagement: scientific.energyManagement,

            // Topology
            windingNumber: topology.windingNumber,
            basinStability: topology.basinStability,
            periodicOrbitCount: topology.periodicOrbitCount,

            // Educational
            learningCurveSlope: educational.learningCurveSlope,
            skillRetention: educational.skillRetention,

            // AI
            aiModeUsed: ai.hasAIData ? ai.aiMode : nil,
            aiAssistancePercent: ai.hasAIData ? ai.assistancePercent : nil,

            // Health
            healthSteps: healthSteps,
            healthRestingHR: healthRestingHR,
            healthHRV: healthHRV,
            healthSleepHours: healthSleepHours,

            // Profile
            trainingGoal: trainingGoal,
            ageRange: ageRange,
            dominantHand: dominantHand,

            // Maze
            mazeSessions: mazeSessions,
            mazeMotorScore: mazeMotorScore,
            mazeFlowScore: mazeFlowScore,
            mazeCognitiveScore: mazeCognitiveScore,

            // Timestamp
            generatedAt: Date()
        )
    }

    /// Build a summary from a CSVSessionManager (useful when metrics calculator hasn't been populated)
    static func build(
        from sessionManager: CSVSessionManager,
        timeRange: AnalyticsTimeRange = .allTime
    ) -> GameplaySummary {
        let calculator = CSVMetricsCalculator()
        calculator.calculateMetrics(from: sessionManager, timeRange: timeRange)
        return build(from: calculator, timeRange: timeRange)
    }

    /// Quick check: does the user have health data available?
    static var hasHealthData: Bool {
        HealthKitManager.shared.isAuthorized &&
        HealthKitManager.shared.latestHealthSnapshot?.hasData == true
    }

    /// Quick check: does the user have Maze data available?
    static var hasMazeData: Bool {
        if let mazeData = AppGroupManager.shared.loadMazeData() {
            return !mazeData.sessions.isEmpty
        }
        return false
    }
}
