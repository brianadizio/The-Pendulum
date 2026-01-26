// CSVMetricsCalculator.swift
// The Pendulum 2.0
// Calculate dashboard metrics from CSV session data

import Foundation
import SwiftUI
import Combine

// MARK: - Data Structures

struct BasicMetrics {
    var stabilityScore: Double = 0.0
    var efficiencyRating: Double = 0.0
    var totalSessionTime: TimeInterval = 0
    var totalPushes: Int = 0
    var maxLevel: Int = 0
    var sessionsPlayed: Int = 0
}

struct LevelCompletionPoint: Identifiable {
    let id = UUID()
    let date: Date
    let level: Int
}

struct AngularDeviationPoint: Identifiable {
    let id = UUID()
    let time: Double
    let angleDegrees: Double
}

struct LearningCurvePoint: Identifiable {
    let id = UUID()
    let sessionNumber: Int
    let skillPercentage: Double
}

// MARK: - CSV Metrics Calculator

class CSVMetricsCalculator: ObservableObject {
    @Published var basicMetrics = BasicMetrics()
    @Published var levelCompletionData: [LevelCompletionPoint] = []
    @Published var angularDeviationData: [AngularDeviationPoint] = []
    @Published var learningCurveData: [LearningCurvePoint] = []
    @Published var directionalBias: Double = 0.0

    // Maximum data points to display (for interpolation)
    private let maxDisplayPoints = 30

    func calculateMetrics(from sessionManager: CSVSessionManager, timeRange: AnalyticsTimeRange) {
        let sessionUrls = sessionManager.getSessions(in: timeRange)

        // Reset metrics
        basicMetrics = BasicMetrics()
        levelCompletionData = []
        angularDeviationData = []
        learningCurveData = []
        directionalBias = 0.0

        guard !sessionUrls.isEmpty else { return }

        basicMetrics.sessionsPlayed = sessionUrls.count

        var allAngles: [(time: Double, angle: Double)] = []
        var leftPushes = 0
        var rightPushes = 0
        var balancedFrames = 0
        var totalFrames = 0
        var levelsCompleted: [Date: Int] = [:]

        // Process each session
        for url in sessionUrls {
            guard let data = sessionManager.readSessionData(from: url) else { continue }

            // Get metadata for this session
            let metadata = sessionManager.getMetadata(for: url)
            basicMetrics.totalSessionTime += metadata?.totalDuration ?? 0
            basicMetrics.totalPushes += metadata?.totalPushes ?? 0

            if let maxLevel = metadata?.maxLevel, maxLevel > basicMetrics.maxLevel {
                basicMetrics.maxLevel = maxLevel
            }

            // Track levels completed
            if let meta = metadata, let levels = meta.levelsCompleted as [Int]? {
                for level in levels {
                    levelsCompleted[meta.startTime] = max(levelsCompleted[meta.startTime] ?? 0, level)
                }
            }

            // Process CSV rows
            for row in data {
                // Parse angle
                if let angleStr = row["angle"], let angle = Double(angleStr) {
                    if let timeStr = row["timestamp"], let time = Double(timeStr) {
                        allAngles.append((time: time, angle: angle * 180 / .pi)) // Convert to degrees
                    }

                    // Check if balanced (within ~20 degrees)
                    let isBalanced = row["isBalanced"] == "true"
                    if isBalanced {
                        balancedFrames += 1
                    }
                    totalFrames += 1
                }

                // Parse push direction
                if let dirStr = row["pushDirection"], let dir = Int(dirStr) {
                    if dir == -1 {
                        leftPushes += 1
                    } else if dir == 1 {
                        rightPushes += 1
                    }
                }
            }
        }

        // Calculate stability score (% of time balanced)
        if totalFrames > 0 {
            basicMetrics.stabilityScore = Double(balancedFrames) / Double(totalFrames) * 100
        }

        // Calculate efficiency rating (inverse of pushes per minute)
        if basicMetrics.totalSessionTime > 0 {
            let pushesPerMinute = Double(basicMetrics.totalPushes) / (basicMetrics.totalSessionTime / 60)
            // Lower pushes = higher efficiency (capped at 100%)
            basicMetrics.efficiencyRating = max(0, min(100, 100 - pushesPerMinute * 2))
        }

        // Calculate directional bias (-1 to 1)
        let totalDirectionalPushes = leftPushes + rightPushes
        if totalDirectionalPushes > 0 {
            directionalBias = Double(rightPushes - leftPushes) / Double(totalDirectionalPushes)
        }

        // Interpolate angular deviation data to maxDisplayPoints
        angularDeviationData = interpolateAngularData(allAngles)

        // Create level completion timeline
        levelCompletionData = levelsCompleted
            .sorted { $0.key < $1.key }
            .map { LevelCompletionPoint(date: $0.key, level: $0.value) }

        // Calculate learning curve (skill improvement over sessions)
        calculateLearningCurve(sessionUrls: sessionUrls, sessionManager: sessionManager)
    }

    private func interpolateAngularData(_ data: [(time: Double, angle: Double)]) -> [AngularDeviationPoint] {
        guard data.count > 1 else {
            return data.map { AngularDeviationPoint(time: $0.time, angleDegrees: $0.angle) }
        }

        // If less than maxDisplayPoints, return as-is
        if data.count <= maxDisplayPoints {
            return data.map { AngularDeviationPoint(time: $0.time, angleDegrees: $0.angle) }
        }

        // Interpolate to maxDisplayPoints
        var interpolated: [AngularDeviationPoint] = []
        let step = Double(data.count - 1) / Double(maxDisplayPoints - 1)

        for i in 0..<maxDisplayPoints {
            let index = Int(Double(i) * step)
            let safeIndex = min(index, data.count - 1)
            interpolated.append(AngularDeviationPoint(
                time: data[safeIndex].time,
                angleDegrees: data[safeIndex].angle
            ))
        }

        return interpolated
    }

    private func calculateLearningCurve(sessionUrls: [URL], sessionManager: CSVSessionManager) {
        // Sort sessions by date
        let sortedUrls = sessionUrls.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 < date2
        }

        learningCurveData = []

        for (index, url) in sortedUrls.enumerated() {
            guard let metadata = sessionManager.getMetadata(for: url) else { continue }

            // Skill percentage based on max level reached and time
            let levelScore = Double(metadata.maxLevel) * 10 // 10 points per level
            let timeBonus = min(metadata.totalDuration / 60, 10) // Up to 10 points for playing time
            let skillPercentage = min(levelScore + timeBonus, 100)

            learningCurveData.append(LearningCurvePoint(
                sessionNumber: index + 1,
                skillPercentage: skillPercentage
            ))
        }

        // Interpolate to max display points if needed
        if learningCurveData.count > maxDisplayPoints {
            let step = Double(learningCurveData.count - 1) / Double(maxDisplayPoints - 1)
            var interpolated: [LearningCurvePoint] = []

            for i in 0..<maxDisplayPoints {
                let index = Int(Double(i) * step)
                let safeIndex = min(index, learningCurveData.count - 1)
                interpolated.append(LearningCurvePoint(
                    sessionNumber: i + 1,
                    skillPercentage: learningCurveData[safeIndex].skillPercentage
                ))
            }

            learningCurveData = interpolated
        }
    }
}
