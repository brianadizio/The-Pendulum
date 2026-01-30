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
    var totalForceApplied: Double = 0.0  // Sum of all push magnitudes
}

// MARK: - Advanced Metrics
struct AdvancedMetrics {
    var directionalBias: Double = 0.0       // -1 (left) to 1 (right)
    var overcorrectionRate: Double = 0.0    // % of opposite-direction pushes within 0.5s
    var averageReactionTime: Double = 0.0   // Mean time from instability to correction
    var responseDelay: Double = 0.0         // Mean time from threshold breach to push
}

// MARK: - Scientific Metrics
struct ScientificMetrics {
    var phaseSpaceCoverage: Double = 0.0    // % of 50x50 grid cells visited
    var energyManagement: Double = 0.0       // Energy variance efficiency
    var lyapunovExponent: Double = 0.0       // System chaos measure
    var angularDeviationStdDev: Double = 0.0 // Standard deviation in degrees
}

// MARK: - Topology Metrics
struct TopologyMetrics {
    var windingNumber: Double = 0.0          // Full rotations count
    var basinStability: Double = 0.0         // % time in stable region
    var periodicOrbitCount: Int = 0          // Distinct closed loops
    var bettiNumbers: [Int] = [0, 0]         // [β₀, β₁] topological invariants
    var separatrixCrossings: Int = 0         // Energy transitions count
}

// MARK: - Educational Metrics
struct EducationalMetrics {
    var learningCurveSlope: Double = 0.0     // % improvement per session
    var skillRetention: Double = 0.0         // Performance consistency
    var adaptationRate: Double = 0.0         // Improvement after changes
}

// MARK: - AI Metrics
struct AIMetrics {
    var hasAIData: Bool = false              // True if any AI mode was active
    var aiMode: String = ""                  // Most recent AI mode
    var aiDifficulty: String = ""            // Formatted difficulty %
    var assistancePercent: Double = 0.0      // % of frames with non-zero AI force
    var aiAvgForce: Double = 0.0            // Average AI force magnitude
    var totalControlCalls: Int = 0           // Total AI control calls
    var totalInterventions: Int = 0          // Frames where AI applied force
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
    @Published var advancedMetrics = AdvancedMetrics()
    @Published var scientificMetrics = ScientificMetrics()
    @Published var topologyMetrics = TopologyMetrics()
    @Published var educationalMetrics = EducationalMetrics()
    @Published var aiMetrics = AIMetrics()
    @Published var levelCompletionData: [LevelCompletionPoint] = []
    @Published var angularDeviationData: [AngularDeviationPoint] = []
    @Published var learningCurveData: [LearningCurvePoint] = []
    @Published var directionalBias: Double = 0.0
    @Published var phaseSpaceData: [PhaseSpacePoint] = []

    // Maximum data points to display (for interpolation)
    private let maxDisplayPoints = 30

    // Physics parameters for energy/topology calculations
    private let mass: Double = 1.0
    private let length: Double = 1.0
    private let gravity: Double = 9.81

    func calculateMetrics(from sessionManager: CSVSessionManager, timeRange: AnalyticsTimeRange) {
        let sessionUrls = sessionManager.getSessions(in: timeRange)

        // Reset metrics
        basicMetrics = BasicMetrics()
        advancedMetrics = AdvancedMetrics()
        scientificMetrics = ScientificMetrics()
        topologyMetrics = TopologyMetrics()
        educationalMetrics = EducationalMetrics()
        aiMetrics = AIMetrics()
        levelCompletionData = []
        angularDeviationData = []
        learningCurveData = []
        directionalBias = 0.0
        phaseSpaceData = []

        guard !sessionUrls.isEmpty else { return }

        basicMetrics.sessionsPlayed = sessionUrls.count

        var allAngles: [(time: Double, angle: Double)] = []
        var allPhasePoints: [(theta: Double, thetaDot: Double)] = []
        var allEnergies: [Double] = []
        var leftPushes = 0
        var rightPushes = 0
        var balancedFrames = 0
        var totalFrames = 0
        var levelsCompleted: [Date: Int] = [:]
        var totalForceApplied: Double = 0.0
        var pushEvents: [(time: Double, direction: Int, magnitude: Double)] = []
        var instabilityEvents: [(time: Double, angle: Double)] = []
        var lastPushTime: Double = -1.0
        var lastPushDirection: Int = 0
        var overcorrections = 0

        // AI tracking
        var aiForceSum: Double = 0.0
        var aiForceFrames: Int = 0
        var aiActiveFrames: Int = 0
        var lastSeenAIMode: String = ""
        var aggregateControlCalls: Int = 0
        var aggregateInterventions: Int = 0

        // Track cumulative time offset for angular deviation chart
        var cumulativeTimeOffset: Double = 0.0

        // Sort sessions by creation date for cumulative time
        let sortedSessionUrls = sessionUrls.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 < date2
        }

        // Process each session
        for url in sortedSessionUrls {
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

            // Aggregate AI metadata
            if let meta = metadata {
                if let calls = meta.aiControlCalls { aggregateControlCalls += calls }
                if let interventions = meta.aiInterventions { aggregateInterventions += interventions }
            }

            // For cumulative time: add a 0° point at start of session (transition from idle)
            // Only if this isn't the first session and we're in a multi-session view
            if timeRange != .session && cumulativeTimeOffset > 0 && !allAngles.isEmpty {
                // Add brief 0° deviation between sessions
                allAngles.append((time: cumulativeTimeOffset, angle: 0.0))
            }

            // Track max timestamp in this session for cumulative offset
            var sessionMaxTime: Double = 0.0

            // Process CSV rows
            for row in data {
                // Parse angle and angular velocity
                if let angleStr = row["angle"], let angle = Double(angleStr) {
                    // Calculate deviation from upright (π radians)
                    // Positive = tilted right, Negative = tilted left
                    let deviationFromUpright = angle - .pi
                    let deviationDegrees = deviationFromUpright * 180 / .pi

                    if let timeStr = row["timestamp"], let time = Double(timeStr) {
                        // For session view: use relative time
                        // For other views: use cumulative time
                        let displayTime = timeRange == .session ? time : (cumulativeTimeOffset + time)
                        allAngles.append((time: displayTime, angle: deviationDegrees))
                        sessionMaxTime = max(sessionMaxTime, time)
                    }

                    // Parse angular velocity for phase space
                    if let velocityStr = row["angleVelocity"], let velocity = Double(velocityStr) {
                        // Store theta as distance from upright (π) in radians for phase space
                        allPhasePoints.append((theta: deviationFromUpright, thetaDot: velocity))
                    }

                    // Check if balanced (within ~20 degrees)
                    let isBalanced = row["isBalanced"] == "true"
                    if isBalanced {
                        balancedFrames += 1
                    }
                    totalFrames += 1
                }

                // Parse push direction and magnitude
                if let dirStr = row["pushDirection"], let dir = Int(dirStr), dir != 0 {
                    if dir == -1 {
                        leftPushes += 1
                    } else if dir == 1 {
                        rightPushes += 1
                    }

                    // Get push magnitude and track total force
                    let magnitude = Double(row["pushMagnitude"] ?? "0") ?? 0
                    totalForceApplied += magnitude

                    // Track push event for reaction time analysis
                    if let timeStr = row["timestamp"], let time = Double(timeStr) {
                        pushEvents.append((time: time, direction: dir, magnitude: magnitude))

                        // Check for overcorrection (opposite direction within 0.5s)
                        if lastPushTime >= 0 && time - lastPushTime < 0.5 && dir != lastPushDirection && lastPushDirection != 0 {
                            overcorrections += 1
                        }
                        lastPushTime = time
                        lastPushDirection = dir
                    }
                }

                // Track instability events (when angle exceeds threshold)
                if let angleStr = row["angle"], let angle = Double(angleStr) {
                    let deviationFromUpright = abs(angle - .pi)
                    if deviationFromUpright > 0.2 { // ~11.5 degrees
                        if let timeStr = row["timestamp"], let time = Double(timeStr) {
                            instabilityEvents.append((time: time, angle: angle))
                        }
                    }

                    // Calculate and store energy for scientific metrics
                    if let velocityStr = row["angleVelocity"], let velocity = Double(velocityStr) {
                        let kinetic = 0.5 * mass * pow(length * velocity, 2)
                        let potential = mass * gravity * length * (1 - cos(angle))
                        allEnergies.append(kinetic + potential)
                    }
                }

                // Parse AI columns (present in newer CSV format)
                if let aiModeStr = row["aiMode"], !aiModeStr.isEmpty, aiModeStr != "Off" {
                    lastSeenAIMode = aiModeStr
                    aiActiveFrames += 1
                    if let aiForceStr = row["aiForce"], let force = Double(aiForceStr), abs(force) > 0.001 {
                        aiForceSum += abs(force)
                        aiForceFrames += 1
                    }
                }
            }

            // Update cumulative time offset for next session
            // Add the session's max timestamp (or duration from metadata)
            if timeRange != .session {
                let sessionDuration = metadata?.totalDuration ?? sessionMaxTime
                cumulativeTimeOffset += sessionDuration
            }
        }

        // Store total force applied
        basicMetrics.totalForceApplied = totalForceApplied

        // Calculate stability score (% of time balanced)
        if totalFrames > 0 {
            basicMetrics.stabilityScore = Double(balancedFrames) / Double(totalFrames) * 100
        }

        // Calculate efficiency rating using old app formula: stability / sqrt(totalForce) * 10
        // This rewards high stability with low force usage
        if totalForceApplied > 0 {
            let efficiency = basicMetrics.stabilityScore / sqrt(totalForceApplied) * 10
            basicMetrics.efficiencyRating = max(0, min(100, efficiency))
        } else if basicMetrics.stabilityScore > 0 {
            // If no force applied but stable, that's very efficient
            basicMetrics.efficiencyRating = min(100, basicMetrics.stabilityScore)
        }

        // Calculate directional bias (-1 to 1)
        let totalDirectionalPushes = leftPushes + rightPushes
        if totalDirectionalPushes > 0 {
            directionalBias = Double(rightPushes - leftPushes) / Double(totalDirectionalPushes)
        }

        // === ADVANCED METRICS ===
        advancedMetrics.directionalBias = directionalBias

        // Overcorrection rate (requires at least 20 pushes)
        if totalDirectionalPushes >= 20 {
            advancedMetrics.overcorrectionRate = Double(overcorrections) / Double(totalDirectionalPushes) * 100
        }

        // Average reaction time (time from instability to correction)
        if !instabilityEvents.isEmpty && !pushEvents.isEmpty {
            var reactionTimes: [Double] = []
            for instability in instabilityEvents {
                // Find next push after this instability
                if let nextPush = pushEvents.first(where: { $0.time > instability.time }) {
                    let reactionTime = nextPush.time - instability.time
                    if reactionTime < 2.0 { // Reasonable reaction time
                        reactionTimes.append(reactionTime)
                    }
                }
            }
            if !reactionTimes.isEmpty {
                advancedMetrics.averageReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            }
        }

        // === SCIENTIFIC METRICS ===
        if allPhasePoints.count >= 100 {
            scientificMetrics.phaseSpaceCoverage = calculatePhaseSpaceCoverage(allPhasePoints)
        }

        if allEnergies.count >= 50 {
            scientificMetrics.energyManagement = calculateEnergyManagement(allEnergies)
        }

        if allPhasePoints.count >= 200 {
            scientificMetrics.lyapunovExponent = calculateLyapunovExponent(allPhasePoints)
        }

        if !allAngles.isEmpty {
            scientificMetrics.angularDeviationStdDev = calculateAngularDeviationStdDev(allAngles)
        }

        // === TOPOLOGY METRICS ===
        if allPhasePoints.count >= 100 {
            topologyMetrics.windingNumber = calculateWindingNumber(allPhasePoints)
            topologyMetrics.basinStability = calculateBasinStability(allPhasePoints)
            topologyMetrics.separatrixCrossings = calculateSeparatrixCrossings(allPhasePoints)
        }

        if allPhasePoints.count >= 500 {
            topologyMetrics.periodicOrbitCount = countPeriodicOrbits(allPhasePoints)
            topologyMetrics.bettiNumbers = calculateBettiNumbers(allPhasePoints)
        }

        // === AI METRICS ===
        if aiActiveFrames > 0 || aggregateControlCalls > 0 {
            aiMetrics.hasAIData = true
            aiMetrics.aiMode = lastSeenAIMode
            aiMetrics.totalControlCalls = aggregateControlCalls
            aiMetrics.totalInterventions = aggregateInterventions

            // Assistance %: fraction of total frames where AI was active
            if totalFrames > 0 {
                aiMetrics.assistancePercent = Double(aiActiveFrames) / Double(totalFrames) * 100.0
            }

            // Average AI force magnitude (only frames where AI applied force)
            if aiForceFrames > 0 {
                aiMetrics.aiAvgForce = aiForceSum / Double(aiForceFrames)
            }

            // Format difficulty from the most recent session metadata
            if let lastMeta = sessionUrls.compactMap({ sessionManager.getMetadata(for: $0) }).last,
               let diff = lastMeta.aiDifficulty {
                aiMetrics.aiDifficulty = String(format: "%.0f%%", diff * 100)
            }
        }

        // Interpolate angular deviation data to maxDisplayPoints
        // Apply smoothing for longer time ranges (weekly, monthly, yearly, all time)
        let shouldSmooth = timeRange == .weekly || timeRange == .monthly || timeRange == .yearly || timeRange == .allTime
        angularDeviationData = interpolateAngularData(allAngles, applySmoothing: shouldSmooth)

        // Interpolate phase space data
        phaseSpaceData = interpolatePhaseSpaceData(allPhasePoints)

        // Create level completion timeline
        levelCompletionData = levelsCompleted
            .sorted { $0.key < $1.key }
            .map { LevelCompletionPoint(date: $0.key, level: $0.value) }

        // Calculate learning curve (skill improvement over sessions)
        calculateLearningCurve(sessionUrls: sessionUrls, sessionManager: sessionManager)
    }

    private func interpolatePhaseSpaceData(_ data: [(theta: Double, thetaDot: Double)]) -> [PhaseSpacePoint] {
        // Filter out data where pendulum has fallen (deviation > 90° from upright)
        // This keeps only meaningful balance data
        let filteredData = data.filter { abs($0.theta) < .pi / 2 }

        guard filteredData.count > 1 else {
            return filteredData.enumerated().map { PhaseSpacePoint(index: $0.offset, theta: $0.element.theta, thetaDot: $0.element.thetaDot) }
        }

        // Allow more points for phase space (smoother trajectory)
        let maxPhasePoints = 200

        if filteredData.count <= maxPhasePoints {
            return filteredData.enumerated().map { PhaseSpacePoint(index: $0.offset, theta: $0.element.theta, thetaDot: $0.element.thetaDot) }
        }

        // Interpolate to maxPhasePoints
        var interpolated: [PhaseSpacePoint] = []
        let step = Double(filteredData.count - 1) / Double(maxPhasePoints - 1)

        for i in 0..<maxPhasePoints {
            let dataIndex = Int(Double(i) * step)
            let safeIndex = min(dataIndex, filteredData.count - 1)
            interpolated.append(PhaseSpacePoint(
                index: i,
                theta: filteredData[safeIndex].theta,
                thetaDot: filteredData[safeIndex].thetaDot
            ))
        }

        return interpolated
    }

    private func interpolateAngularData(_ data: [(time: Double, angle: Double)], applySmoothing: Bool = false) -> [AngularDeviationPoint] {
        // Filter out extreme values where pendulum has fallen (> 90° from upright)
        // This keeps the chart focused on meaningful balance data
        let filteredData = data.filter { abs($0.angle) <= 90 }

        guard filteredData.count > 1 else {
            return filteredData.map { AngularDeviationPoint(time: $0.time, angleDegrees: $0.angle) }
        }

        // For multiple sessions, use more display points for longer time ranges
        let maxTime = filteredData.map { $0.time }.max() ?? 10
        let displayPoints = maxTime > 60 ? 60 : maxDisplayPoints  // More points for longer sessions

        // If less than displayPoints, return as-is (possibly smoothed)
        if filteredData.count <= displayPoints {
            let result = filteredData.map { AngularDeviationPoint(time: $0.time, angleDegrees: $0.angle) }
            return applySmoothing ? smoothAngularData(result) : result
        }

        // Interpolate to displayPoints
        var interpolated: [AngularDeviationPoint] = []
        let step = Double(filteredData.count - 1) / Double(displayPoints - 1)

        for i in 0..<displayPoints {
            let index = Int(Double(i) * step)
            let safeIndex = min(index, filteredData.count - 1)
            interpolated.append(AngularDeviationPoint(
                time: filteredData[safeIndex].time,
                angleDegrees: filteredData[safeIndex].angle
            ))
        }

        return applySmoothing ? smoothAngularData(interpolated) : interpolated
    }

    /// Apply moving average smoothing to angular deviation data
    private func smoothAngularData(_ data: [AngularDeviationPoint]) -> [AngularDeviationPoint] {
        guard data.count > 5 else { return data }

        let windowSize = 5
        var smoothed: [AngularDeviationPoint] = []

        for i in 0..<data.count {
            let start = max(0, i - windowSize / 2)
            let end = min(data.count - 1, i + windowSize / 2)

            let windowAngles = data[start...end].map { $0.angleDegrees }
            let average = windowAngles.reduce(0, +) / Double(windowAngles.count)

            smoothed.append(AngularDeviationPoint(
                time: data[i].time,
                angleDegrees: average
            ))
        }

        return smoothed
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
            // Try to get metadata, but also calculate from CSV data directly
            let metadata = sessionManager.getMetadata(for: url)
            let csvData = sessionManager.readSessionData(from: url)

            var skillPercentage: Double = 0

            if let data = csvData, !data.isEmpty {
                // Calculate skill from actual gameplay data
                var balancedFrames = 0
                var totalFrames = 0

                for row in data {
                    if row["isBalanced"] == "true" {
                        balancedFrames += 1
                    }
                    if row["angle"] != nil && row["angle"] != "0.0" {
                        totalFrames += 1
                    }
                }

                // Skill = percentage of time balanced (primary metric)
                let balanceRatio = totalFrames > 0 ? Double(balancedFrames) / Double(totalFrames) : 0

                // Time bonus - longer sessions show more skill (up to 30 points for 3+ minutes)
                let duration = metadata?.totalDuration ?? 0
                let timeBonus = min(duration / 6, 30)  // 5 points per 30 seconds, max 30

                // Level bonus if available
                let levelBonus = Double(metadata?.maxLevel ?? 1) * 5

                // Combined skill: balance (60%) + time (30%) + level (10%)
                skillPercentage = min((balanceRatio * 60) + timeBonus + levelBonus, 100)
            } else if let meta = metadata {
                // Fallback to metadata-only calculation
                let levelScore = Double(meta.maxLevel) * 10
                let timeBonus = min(meta.totalDuration / 6, 30)
                skillPercentage = min(levelScore + timeBonus, 100)
            }

            learningCurveData.append(LearningCurvePoint(
                sessionNumber: index + 1,
                skillPercentage: max(skillPercentage, 5)  // Minimum 5% for any session
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

        // Calculate educational metrics
        if learningCurveData.count >= 3 {
            educationalMetrics.learningCurveSlope = calculateLearningCurveSlope()
        }
        // Calculate skill retention (works with 2+ sessions, returns -1 for < 2)
        educationalMetrics.skillRetention = calculateSkillRetention()
    }

    // MARK: - Scientific Metric Calculations

    /// Calculate phase space coverage (% of 50x50 grid cells visited)
    private func calculatePhaseSpaceCoverage(_ data: [(theta: Double, thetaDot: Double)]) -> Double {
        let gridSize = 50
        let thetaBounds = (-Double.pi, Double.pi)
        let omegaBounds = (-10.0, 10.0)

        var grid = [[Bool]](repeating: [Bool](repeating: false, count: gridSize), count: gridSize)

        for point in data {
            guard !point.theta.isNaN && !point.thetaDot.isNaN else { continue }

            let thetaNorm = (point.theta - thetaBounds.0) / (thetaBounds.1 - thetaBounds.0)
            let omegaNorm = (point.thetaDot - omegaBounds.0) / (omegaBounds.1 - omegaBounds.0)

            guard thetaNorm >= 0 && thetaNorm <= 1 && omegaNorm >= 0 && omegaNorm <= 1 else { continue }

            let i = min(Int(thetaNorm * Double(gridSize - 1)), gridSize - 1)
            let j = min(Int(omegaNorm * Double(gridSize - 1)), gridSize - 1)

            grid[i][j] = true
        }

        let visitedCells = grid.flatMap { $0 }.filter { $0 }.count
        let totalCells = gridSize * gridSize

        return Double(visitedCells) / Double(totalCells) * 100.0
    }

    /// Calculate energy management efficiency
    private func calculateEnergyManagement(_ energies: [Double]) -> Double {
        guard !energies.isEmpty else { return 0 }

        let meanEnergy = energies.reduce(0, +) / Double(energies.count)
        guard meanEnergy > 0.001 else { return 100.0 }

        let variance = energies.map { pow($0 - meanEnergy, 2) }.reduce(0, +) / Double(energies.count)
        let normalizedVariance = min(variance / (meanEnergy * meanEnergy), 1.0)

        return (1.0 - normalizedVariance) * 100.0
    }

    /// Calculate Lyapunov exponent (chaos measure)
    private func calculateLyapunovExponent(_ data: [(theta: Double, thetaDot: Double)]) -> Double {
        guard data.count > 200 else { return 0 }

        var lyapunovSum = 0.0
        var validCount = 0
        let dt = 0.01

        // Sample points to reduce computation
        let stride = max(1, data.count / 200)

        for i in Swift.stride(from: 1, to: data.count - 1, by: stride) {
            let theta = data[i].theta
            let omega = data[i].thetaDot

            // Jacobian eigenvalue for pendulum: sqrt(g/L * |cos(θ)|)
            let cosTheta = cos(theta)
            guard !cosTheta.isNaN else { continue }

            let eigenvalue = sqrt(abs(gravity / length * cosTheta))

            if eigenvalue > 0.0001 {
                let logValue = log(eigenvalue)
                if !logValue.isNaN && !logValue.isInfinite {
                    lyapunovSum += logValue
                    validCount += 1
                }
            }
        }

        guard validCount > 0 else { return 0 }
        return lyapunovSum / Double(validCount) / dt
    }

    /// Calculate angular deviation standard deviation in degrees
    private func calculateAngularDeviationStdDev(_ data: [(time: Double, angle: Double)]) -> Double {
        guard !data.isEmpty else { return 0 }

        let deviations = data.map { abs($0.angle) }  // Already deviation from upright
        let mean = deviations.reduce(0, +) / Double(deviations.count)
        let variance = deviations.map { pow($0 - mean, 2) }.reduce(0, +) / Double(deviations.count)

        return sqrt(variance)  // Already in degrees from earlier conversion
    }

    // MARK: - Topology Metric Calculations

    /// Calculate winding number (full rotations)
    private func calculateWindingNumber(_ data: [(theta: Double, thetaDot: Double)]) -> Double {
        guard data.count > 10 else { return 0 }

        var windingNumber = 0.0
        var previousTheta = data[0].theta

        for i in 1..<data.count {
            let currentTheta = data[i].theta
            let deltaTheta = currentTheta - previousTheta

            // Handle angle wrapping (crossing ±π)
            if deltaTheta > Double.pi {
                windingNumber -= 1
            } else if deltaTheta < -Double.pi {
                windingNumber += 1
            }

            previousTheta = currentTheta
        }

        // Add continuous part
        let totalAngleChange = data.last!.theta - data.first!.theta
        windingNumber += totalAngleChange / (2 * Double.pi)

        return windingNumber
    }

    /// Calculate basin stability (% time in stable region)
    private func calculateBasinStability(_ data: [(theta: Double, thetaDot: Double)]) -> Double {
        guard !data.isEmpty else { return 0 }

        let stableThreshold = 0.5  // radians from vertical (~28.6 degrees)
        var stableCount = 0

        for point in data {
            // Theta is already deviation from upright (θ - π)
            if abs(point.theta) < stableThreshold {
                stableCount += 1
            }
        }

        return Double(stableCount) / Double(data.count) * 100.0
    }

    /// Count separatrix crossings (energy transitions)
    private func calculateSeparatrixCrossings(_ data: [(theta: Double, thetaDot: Double)]) -> Int {
        guard data.count > 100 else { return 0 }

        let separatrixEnergy = mass * gravity * length * 2  // Energy at inverted position
        var crossings = 0

        var wasAboveSeparatrix = calculateEnergy(theta: data[0].theta, omega: data[0].thetaDot) > separatrixEnergy

        for i in 1..<data.count {
            let energy = calculateEnergy(theta: data[i].theta, omega: data[i].thetaDot)
            let isAboveSeparatrix = energy > separatrixEnergy

            if isAboveSeparatrix != wasAboveSeparatrix {
                crossings += 1
            }
            wasAboveSeparatrix = isAboveSeparatrix
        }

        return crossings
    }

    /// Count periodic orbits
    private func countPeriodicOrbits(_ data: [(theta: Double, thetaDot: Double)]) -> Int {
        guard data.count > 500 else { return 0 }

        var periodicOrbits = 0
        let tolerance = 0.1
        let minPeriod = 10

        // Check subset of starting points
        let checkPoints = min(data.count / 4, 100)

        for startIdx in stride(from: 0, to: checkPoints, by: 10) {
            let startPoint = data[startIdx]

            // Look for return to near starting point
            for endIdx in (startIdx + minPeriod)..<min(startIdx + 500, data.count) {
                let endPoint = data[endIdx]

                let distance = sqrt(pow(endPoint.theta - startPoint.theta, 2) +
                                   pow(endPoint.thetaDot - startPoint.thetaDot, 2))

                if distance < tolerance {
                    periodicOrbits += 1
                    break
                }
            }
        }

        return periodicOrbits
    }

    /// Calculate Betti numbers [β₀, β₁]
    private func calculateBettiNumbers(_ data: [(theta: Double, thetaDot: Double)]) -> [Int] {
        guard data.count > 500 else { return [0, 0] }

        // β₀ = number of connected components (assume 1 for continuous trajectory)
        let betti0 = 1

        // β₁ = number of holes (detect from grid coverage)
        let gridSize = 20
        var grid = [[Bool]](repeating: [Bool](repeating: false, count: gridSize), count: gridSize)

        for point in data {
            let thetaNorm = (point.theta + Double.pi) / (2 * Double.pi)
            let omegaNorm = (point.thetaDot + 10) / 20.0

            guard thetaNorm >= 0 && thetaNorm <= 1 && omegaNorm >= 0 && omegaNorm <= 1 else { continue }

            let i = min(Int(thetaNorm * Double(gridSize)), gridSize - 1)
            let j = min(Int(omegaNorm * Double(gridSize)), gridSize - 1)

            if i >= 0 && i < gridSize && j >= 0 && j < gridSize {
                grid[i][j] = true
            }
        }

        // Count holes (cells surrounded by visited cells but not visited)
        var holes = 0
        for i in 1..<(gridSize - 1) {
            for j in 1..<(gridSize - 1) {
                if !grid[i][j] && grid[i-1][j] && grid[i+1][j] && grid[i][j-1] && grid[i][j+1] {
                    holes += 1
                }
            }
        }

        return [betti0, holes]
    }

    /// Helper: Calculate pendulum energy
    private func calculateEnergy(theta: Double, omega: Double) -> Double {
        let kinetic = 0.5 * mass * pow(length * omega, 2)
        let potential = mass * gravity * length * (1 - cos(theta))
        return kinetic + potential
    }

    // MARK: - Educational Metric Calculations

    /// Calculate learning curve slope (% improvement per session)
    private func calculateLearningCurveSlope() -> Double {
        guard learningCurveData.count >= 3 else { return 0 }

        // Linear regression: y = mx + b
        let n = Double(learningCurveData.count)
        let x = learningCurveData.map { Double($0.sessionNumber) }
        let y = learningCurveData.map { $0.skillPercentage }

        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumXSquare = x.map { $0 * $0 }.reduce(0, +)

        let denominator = n * sumXSquare - sumX * sumX
        guard abs(denominator) > 0.0001 else { return 0 }

        let slope = (n * sumXY - sumX * sumY) / denominator
        return slope  // % per session
    }

    /// Calculate skill retention (performance consistency)
    /// Returns -1 if insufficient sessions (< 2), which signals "Need 2+ sessions" display
    private func calculateSkillRetention() -> Double {
        guard learningCurveData.count >= 2 else { return -1 }

        let skills = learningCurveData.map { $0.skillPercentage }

        // For 2-4 sessions: Simple comparison of latest vs earliest skill
        if learningCurveData.count < 5 {
            let earliestSkill = skills.first ?? 1
            let latestSkill = skills.last ?? 1

            // If latest >= earliest, retention is good (100%)
            // Otherwise, calculate ratio capped at 100%
            if earliestSkill <= 0.001 {
                return latestSkill > 0 ? 100.0 : 50.0
            }
            return min((latestSkill / earliestSkill) * 100.0, 100.0)
        }

        // For 5+ sessions: Use variance-based calculation
        let mean = skills.reduce(0, +) / Double(skills.count)
        let variance = skills.map { pow($0 - mean, 2) }.reduce(0, +) / Double(skills.count)

        // Lower variance = higher retention (max 100 for variance of 0)
        let maxVariance: Double = 400  // ~20% standard deviation
        let normalizedVariance = min(variance / maxVariance, 1.0)

        return (1.0 - normalizedVariance) * 100.0
    }
}
