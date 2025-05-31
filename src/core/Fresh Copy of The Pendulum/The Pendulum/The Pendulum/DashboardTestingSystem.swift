// DashboardTestingSystem.swift
// Comprehensive testing system for dashboard data validation and simulation

import Foundation
import CoreData

// MARK: - Dashboard Data Validator

class DashboardDataValidator {
    
    // MARK: - Data Sanity Checks
    
    static func validateMetrics(_ metrics: [String: Any]) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Validate stability score (0-100)
        if let stabilityScore = metrics["stabilityScore"] as? Double {
            if stabilityScore < 0 || stabilityScore > 100 {
                errors.append("Stability score out of range: \(stabilityScore)")
            }
            if stabilityScore.isNaN || stabilityScore.isInfinite {
                errors.append("Stability score is NaN or Infinite")
            }
        } else {
            errors.append("Missing stability score")
        }
        
        // Validate efficiency rating (0-100)
        if let efficiencyRating = metrics["efficiencyRating"] as? Double {
            if efficiencyRating < 0 || efficiencyRating > 100 {
                errors.append("Efficiency rating out of range: \(efficiencyRating)")
            }
            if efficiencyRating.isNaN || efficiencyRating.isInfinite {
                errors.append("Efficiency rating is NaN or Infinite")
            }
        } else {
            errors.append("Missing efficiency rating")
        }
        
        // Validate directional bias (-1.0 to 1.0)
        if let directionalBias = metrics["directionalBias"] as? Double {
            if directionalBias < -1.0 || directionalBias > 1.0 {
                errors.append("Directional bias out of range: \(directionalBias)")
            }
        } else {
            errors.append("Missing directional bias")
        }
        
        // Validate reaction time (positive values)
        if let reactionTime = metrics["averageCorrectionTime"] as? Double {
            if reactionTime < 0 {
                errors.append("Negative reaction time: \(reactionTime)")
            }
            if reactionTime > 5.0 {
                warnings.append("Unusually high reaction time: \(reactionTime)")
            }
        }
        
        // Validate player style
        if let playerStyle = metrics["playerStyle"] as? String {
            let validStyles = [
                "Expert Balancer", "Right-Dominant", "Left-Dominant",
                "Overcorrector", "Methodical", "Quick but Erratic",
                "Proactive Controller", "Reactive Controller",
                "Steady Handler", "Efficient Handler", "Balanced Controller"
            ]
            if !validStyles.contains(playerStyle) {
                warnings.append("Unknown player style: \(playerStyle)")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    static func validateChartData(data: [Double], labels: [String], chartType: String) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Check data and labels count match
        if data.count != labels.count {
            errors.append("\(chartType): Data count (\(data.count)) doesn't match labels count (\(labels.count))")
        }
        
        // Check for NaN or Infinite values
        for (index, value) in data.enumerated() {
            if value.isNaN {
                errors.append("\(chartType): NaN value at index \(index)")
            }
            if value.isInfinite {
                errors.append("\(chartType): Infinite value at index \(index)")
            }
        }
        
        // Chart-specific validations
        switch chartType {
        case "AngleVariance":
            // Angle variance should be positive
            if data.contains(where: { $0 < 0 }) {
                errors.append("Angle variance contains negative values")
            }
            
        case "PushFrequency":
            // Push frequency should be non-negative integers
            if data.contains(where: { $0 < 0 }) {
                errors.append("Push frequency contains negative values")
            }
            
        case "ReactionTime":
            // Reaction times should be positive and reasonable
            if let minTime = data.min(), minTime < 0 {
                errors.append("Negative reaction time found")
            }
            if let maxTime = data.max(), maxTime > 10.0 {
                warnings.append("Extremely high reaction time: \(maxTime)s")
            }
            
        case "LearningCurve":
            // Learning curve should show improvement (generally increasing)
            if data.count > 2 {
                let firstHalf = data.prefix(data.count/2).reduce(0, +) / Double(data.count/2)
                let secondHalf = data.suffix(data.count/2).reduce(0, +) / Double(data.count/2)
                if secondHalf < firstHalf * 0.8 {
                    warnings.append("Learning curve shows significant regression")
                }
            }
            
        default:
            break
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Cross-Validation Methods
    
    static func crossValidateMetrics(
        stabilityScore: Double,
        efficiencyRating: Double,
        totalForceApplied: Double,
        angleVariance: Double
    ) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Cross-check stability vs angle variance
        // High stability should correlate with low variance
        let expectedStability = 100.0 * (1.0 - min(angleVariance / 0.5, 1.0))
        let stabilityDifference = abs(stabilityScore - expectedStability)
        
        if stabilityDifference > 20.0 {
            warnings.append("Stability score (\(stabilityScore)) doesn't match angle variance (\(angleVariance))")
        }
        
        // Cross-check efficiency vs force applied
        // High efficiency means achieving stability with less force
        if efficiencyRating > 80 && totalForceApplied > 50 {
            warnings.append("High efficiency rating with high force usage seems contradictory")
        }
        
        if efficiencyRating < 30 && totalForceApplied < 10 {
            warnings.append("Low efficiency rating with low force usage seems contradictory")
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    struct ValidationResult {
        let isValid: Bool
        let errors: [String]
        let warnings: [String]
        
        func printReport() {
            print("=== Dashboard Data Validation Report ===")
            print("Valid: \(isValid)")
            
            if !errors.isEmpty {
                print("\nERRORS:")
                errors.forEach { print("  ❌ \($0)") }
            }
            
            if !warnings.isEmpty {
                print("\nWARNINGS:")
                warnings.forEach { print("  ⚠️ \($0)") }
            }
            
            if errors.isEmpty && warnings.isEmpty {
                print("  ✅ All checks passed")
            }
            print("=====================================\n")
        }
    }
}

// MARK: - Gameplay Data Simulator

class GameplayDataSimulator {
    
    enum SimulationProfile {
        case beginner
        case intermediate
        case expert
        case erratic
        case improver
        case custom(parameters: SimulationParameters)
    }
    
    struct SimulationParameters {
        var baseStability: Double = 50.0
        var stabilityVariance: Double = 10.0
        var improvementRate: Double = 0.1
        var reactionTimeBase: Double = 0.5
        var reactionTimeVariance: Double = 0.2
        var directionalBias: Double = 0.0
        var overcorrectionProbability: Double = 0.2
        var forceMultiplier: Double = 1.0
    }
    
    private let analyticsManager = AnalyticsManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Simulation Methods
    
    func simulateGameplay(
        profile: SimulationProfile,
        duration: TimeInterval,
        levels: Int,
        startDate: Date = Date()
    ) -> UUID {
        print("Starting gameplay simulation...")
        print("Profile: \(profile), Duration: \(duration)s, Levels: \(levels)")
        
        let parameters = getParameters(for: profile)
        let sessionId = UUID()
        
        // Create a play session
        createPlaySession(
            sessionId: sessionId,
            startDate: startDate,
            duration: duration,
            levels: levels
        )
        
        // Start analytics tracking
        analyticsManager.startTracking(for: sessionId)
        
        // Simulate gameplay for each level
        for level in 1...levels {
            analyticsManager.setCurrentLevel(level)
            simulateLevel(
                level: level,
                parameters: parameters,
                duration: duration / Double(levels)
            )
        }
        
        // Stop tracking and save metrics
        analyticsManager.stopTracking()
        
        print("Simulation completed for session: \(sessionId)")
        return sessionId
    }
    
    func simulateYearOfGameplay(
        profileProgression: [(profile: SimulationProfile, months: Int)]
    ) -> [UUID] {
        print("Simulating year of gameplay...")
        var sessions: [UUID] = []
        var currentDate = Date().addingTimeInterval(-365 * 24 * 60 * 60) // Start 1 year ago
        
        for (profile, months) in profileProgression {
            let daysPerMonth = 30
            let sessionsPerWeek = 3
            let totalSessions = (months * daysPerMonth * sessionsPerWeek) / 7
            
            for _ in 0..<totalSessions {
                // Vary session duration
                let duration = TimeInterval.random(in: 300...1800) // 5-30 minutes
                let levels = Int.random(in: 3...10)
                
                let sessionId = simulateGameplay(
                    profile: profile,
                    duration: duration,
                    levels: levels,
                    startDate: currentDate
                )
                sessions.append(sessionId)
                
                // Advance date by 1-3 days
                currentDate = currentDate.addingTimeInterval(
                    TimeInterval.random(in: 86400...259200)
                )
            }
        }
        
        print("Year simulation completed. Total sessions: \(sessions.count)")
        return sessions
    }
    
    func simulateGameplayWithParameters(
        mass: Double,
        length: Double,
        damping: Double,
        gravity: Double,
        duration: TimeInterval
    ) -> UUID {
        // Create custom simulation parameters for stress testing
        let customParams = SimulationParameters(
            baseStability: max(10.0, min(90.0, 60.0 - abs(mass - 1.0) * 10)), // Adjust stability based on mass
            stabilityVariance: 15.0,
            improvementRate: 0.0, // No improvement during stress test
            reactionTimeBase: 0.5,
            reactionTimeVariance: 0.2,
            directionalBias: 0.0,
            overcorrectionProbability: 0.3,
            forceMultiplier: gravity / 9.81 // Scale force with gravity
        )
        
        return simulateGameplay(
            profile: .custom(parameters: customParams),
            duration: duration,
            levels: max(1, Int(duration / 60)) // 1 level per minute
        )
    }
    
    // MARK: - Private Methods
    
    private func getParameters(for profile: SimulationProfile) -> SimulationParameters {
        switch profile {
        case .beginner:
            return SimulationParameters(
                baseStability: 30.0,
                stabilityVariance: 20.0,
                improvementRate: 0.2,
                reactionTimeBase: 0.8,
                reactionTimeVariance: 0.3,
                directionalBias: 0.2,
                overcorrectionProbability: 0.4,
                forceMultiplier: 1.5
            )
            
        case .intermediate:
            return SimulationParameters(
                baseStability: 60.0,
                stabilityVariance: 15.0,
                improvementRate: 0.1,
                reactionTimeBase: 0.5,
                reactionTimeVariance: 0.2,
                directionalBias: 0.1,
                overcorrectionProbability: 0.2,
                forceMultiplier: 1.2
            )
            
        case .expert:
            return SimulationParameters(
                baseStability: 85.0,
                stabilityVariance: 8.0,
                improvementRate: 0.05,
                reactionTimeBase: 0.3,
                reactionTimeVariance: 0.1,
                directionalBias: 0.02,
                overcorrectionProbability: 0.05,
                forceMultiplier: 0.8
            )
            
        case .erratic:
            return SimulationParameters(
                baseStability: 45.0,
                stabilityVariance: 30.0,
                improvementRate: -0.05,
                reactionTimeBase: 0.4,
                reactionTimeVariance: 0.4,
                directionalBias: -0.3,
                overcorrectionProbability: 0.6,
                forceMultiplier: 2.0
            )
            
        case .improver:
            return SimulationParameters(
                baseStability: 40.0,
                stabilityVariance: 15.0,
                improvementRate: 0.3,
                reactionTimeBase: 0.7,
                reactionTimeVariance: 0.2,
                directionalBias: 0.0,
                overcorrectionProbability: 0.3,
                forceMultiplier: 1.3
            )
            
        case .custom(let parameters):
            return parameters
        }
    }
    
    private func createPlaySession(
        sessionId: UUID,
        startDate: Date,
        duration: TimeInterval,
        levels: Int
    ) {
        let context = coreDataManager.context
        
        context.performAndWait {
            let session = PlaySession(context: context)
            session.sessionId = sessionId
            session.date = startDate
            session.duration = duration
            session.score = Int32.random(in: 1000...10000)
            session.highestLevel = Int32(levels)
            
            do {
                try context.save()
            } catch {
                print("Error creating play session: \(error)")
            }
        }
    }
    
    private func simulateLevel(
        level: Int,
        parameters: SimulationParameters,
        duration: TimeInterval
    ) {
        let frameRate = 60.0
        let totalFrames = Int(duration * frameRate)
        let pushInterval = Int.random(in: 60...180) // Push every 1-3 seconds
        
        // Simulate pendulum state evolution
        var angle = Double.pi + Double.random(in: -0.1...0.1) // Start near vertical
        var angleVelocity = 0.0
        let gravity = 9.81
        let length = 3.0
        let damping = 0.1
        
        for frame in 0..<totalFrames {
            // Physics simulation (simplified)
            let angleAcceleration = -(gravity / length) * sin(angle) - damping * angleVelocity
            angleVelocity += angleAcceleration / frameRate
            angle += angleVelocity / frameRate
            
            // Track pendulum state
            analyticsManager.trackPendulumState(angle: angle, angleVelocity: angleVelocity)
            
            // Track phase space
            analyticsManager.trackPhaseSpacePoint(theta: angle, omega: angleVelocity)
            
            // Simulate push interactions
            if frame % pushInterval == 0 && frame > 0 {
                simulatePush(
                    angle: angle,
                    angleVelocity: angleVelocity,
                    parameters: parameters,
                    level: level
                )
                
                // Apply push effect to physics
                let pushMagnitude = Double.random(in: 0.5...2.0) * parameters.forceMultiplier
                let direction = shouldPushRight(angle: angle, bias: parameters.directionalBias) ? 1.0 : -1.0
                angleVelocity += direction * pushMagnitude / frameRate
            }
            
            // Add some noise to make it realistic
            angle += Double.random(in: -0.01...0.01)
        }
    }
    
    private func simulatePush(
        angle: Double,
        angleVelocity: Double,
        parameters: SimulationParameters,
        level: Int
    ) {
        // Calculate reaction time with improvement
        let levelImprovement = Double(level - 1) * parameters.improvementRate
        let reactionTime = max(0.1, parameters.reactionTimeBase - levelImprovement +
                              Double.random(in: -parameters.reactionTimeVariance...parameters.reactionTimeVariance))
        
        // Determine push direction
        let shouldPushRightFlag = shouldPushRight(angle: angle, bias: parameters.directionalBias)
        let direction = shouldPushRightFlag ? "right" : "left"
        
        // Calculate push magnitude
        let baseMagnitude = abs(angle - Double.pi) * 10.0
        let magnitude = baseMagnitude * parameters.forceMultiplier *
                       Double.random(in: 0.8...1.2)
        
        // Simulate overcorrection
        let isOvercorrection = Double.random(in: 0...1) < parameters.overcorrectionProbability
        let finalMagnitude = isOvercorrection ? magnitude * 1.5 : magnitude
        
        // Track the interaction
        analyticsManager.trackInteraction(
            eventType: "push",
            angle: angle,
            angleVelocity: angleVelocity,
            magnitude: finalMagnitude,
            direction: direction
        )
    }
    
    private func shouldPushRight(angle: Double, bias: Double) -> Bool {
        // Base decision on pendulum state
        let baseDecision = angle < Double.pi
        
        // Apply bias
        if bias == 0 {
            return baseDecision
        }
        
        let biasedProbability = bias > 0 ? 0.5 + abs(bias) / 2 : 0.5 - abs(bias) / 2
        return Double.random(in: 0...1) < biasedProbability
    }
}

// MARK: - Dashboard Testing Coordinator

class DashboardTestingCoordinator {
    
    private let validator = DashboardDataValidator()
    private let simulator = GameplayDataSimulator()
    
    // MARK: - Comprehensive Testing Methods
    
    func runComprehensiveTest() {
        print("\n🧪 Starting Comprehensive Dashboard Testing...\n")
        
        // Test 1: Validate current dashboard data
        testCurrentDashboardData()
        
        // Test 2: Simulate and validate different player profiles
        testPlayerProfiles()
        
        // Test 3: Test edge cases
        testEdgeCases()
        
        // Test 4: Test long-term data
        testLongTermData()
        
        print("\n✅ Dashboard Testing Complete!\n")
    }
    
    private func testCurrentDashboardData() {
        print("📊 Testing Current Dashboard Data...")
        
        let metrics = AnalyticsManager.shared.getPerformanceMetrics()
        let validation = DashboardDataValidator.validateMetrics(metrics)
        validation.printReport()
        
        // Test chart data validation
        let angleData = [12.5, 15.2, 18.7, 10.3, 8.1, 5.6, 7.2, 9.5, 4.8, 3.2]
        let angleLabels = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30"]
        let angleValidation = DashboardDataValidator.validateChartData(
            data: angleData,
            labels: angleLabels,
            chartType: "AngleVariance"
        )
        angleValidation.printReport()
    }
    
    private func testPlayerProfiles() {
        print("👥 Testing Different Player Profiles...")
        
        let profiles: [GameplayDataSimulator.SimulationProfile] = [
            .beginner, .intermediate, .expert, .erratic, .improver
        ]
        
        for profile in profiles {
            print("\nTesting \(profile) profile:")
            
            let sessionId = simulator.simulateGameplay(
                profile: profile,
                duration: 300, // 5 minutes
                levels: 3
            )
            
            // Validate the generated data
            let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
            let validation = DashboardDataValidator.validateMetrics(metrics)
            validation.printReport()
        }
    }
    
    private func testEdgeCases() {
        print("🔍 Testing Edge Cases...")
        
        // Test 1: Very short session
        print("\nTest: Very short session (10 seconds)")
        let shortSession = simulator.simulateGameplay(
            profile: .beginner,
            duration: 10,
            levels: 1
        )
        validateSession(shortSession)
        
        // Test 2: Perfect player (minimal corrections)
        print("\nTest: Perfect player")
        let perfectParams = GameplayDataSimulator.SimulationParameters(
            baseStability: 95.0,
            stabilityVariance: 2.0,
            improvementRate: 0,
            reactionTimeBase: 0.1,
            reactionTimeVariance: 0.05,
            directionalBias: 0.0,
            overcorrectionProbability: 0.0,
            forceMultiplier: 0.5
        )
        let perfectSession = simulator.simulateGameplay(
            profile: .custom(parameters: perfectParams),
            duration: 300,
            levels: 5
        )
        validateSession(perfectSession)
        
        // Test 3: Heavily biased player
        print("\nTest: Heavily biased player")
        let biasedParams = GameplayDataSimulator.SimulationParameters(
            baseStability: 50.0,
            stabilityVariance: 15.0,
            improvementRate: 0,
            reactionTimeBase: 0.5,
            reactionTimeVariance: 0.2,
            directionalBias: 0.9, // Heavy right bias
            overcorrectionProbability: 0.1,
            forceMultiplier: 1.0
        )
        let biasedSession = simulator.simulateGameplay(
            profile: .custom(parameters: biasedParams),
            duration: 300,
            levels: 3
        )
        validateSession(biasedSession)
    }
    
    private func testLongTermData() {
        print("📅 Testing Long-term Data (Year Simulation)...")
        
        // Simulate a year of gameplay with progression
        let yearProgression: [(GameplayDataSimulator.SimulationProfile, Int)] = [
            (.beginner, 2),     // 2 months as beginner
            (.improver, 4),     // 4 months improving
            (.intermediate, 4), // 4 months intermediate
            (.expert, 2)        // 2 months expert
        ]
        
        let sessions = simulator.simulateYearOfGameplay(profileProgression: yearProgression)
        
        print("\nGenerated \(sessions.count) sessions over simulated year")
        
        // Test aggregated analytics
        let periods = ["daily", "weekly", "monthly", "yearly"]
        for period in periods {
            print("\nValidating \(period) aggregated data:")
            let aggregated = AnalyticsManager.shared.getAggregatedAnalytics(period: period)
            if !aggregated.isEmpty {
                print("  Session Count: \(aggregated["sessionCount"] ?? 0)")
                print("  Avg Stability: \(aggregated["averageStabilityScore"] ?? 0)")
                print("  Learning Slope: \(aggregated["learningCurveSlope"] ?? 0)")
            } else {
                print("  No data available for \(period)")
            }
        }
    }
    
    private func validateSession(_ sessionId: UUID) {
        let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
        let validation = DashboardDataValidator.validateMetrics(metrics)
        validation.printReport()
    }
    
    // MARK: - Visual Testing Support
    
    func generateTestReport(for sessionId: UUID? = nil) -> String {
        var report = "=== Dashboard Test Report ===\n"
        report += "Generated: \(Date())\n\n"
        
        // Get metrics
        let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
        
        // Metrics Summary
        report += "📊 METRICS SUMMARY:\n"
        report += "Stability Score: \(metrics["stabilityScore"] ?? "N/A")\n"
        report += "Efficiency Rating: \(metrics["efficiencyRating"] ?? "N/A")\n"
        report += "Player Style: \(metrics["playerStyle"] ?? "N/A")\n"
        report += "Avg Correction Time: \(metrics["averageCorrectionTime"] ?? "N/A")\n"
        report += "Directional Bias: \(metrics["directionalBias"] ?? "N/A")\n"
        report += "Overcorrection Rate: \(metrics["overcorrectionRate"] ?? "N/A")\n\n"
        
        // Data Validation
        report += "✅ VALIDATION:\n"
        let validation = DashboardDataValidator.validateMetrics(metrics)
        report += "Valid: \(validation.isValid)\n"
        report += "Errors: \(validation.errors.count)\n"
        report += "Warnings: \(validation.warnings.count)\n"
        
        if !validation.errors.isEmpty {
            report += "\nErrors:\n"
            validation.errors.forEach { report += "  - \($0)\n" }
        }
        
        if !validation.warnings.isEmpty {
            report += "\nWarnings:\n"
            validation.warnings.forEach { report += "  - \($0)\n" }
        }
        
        report += "\n============================\n"
        
        return report
    }
}

// MARK: - Quick Testing Functions

extension DashboardTestingCoordinator {
    
    /// Quick test for current session
    static func quickTest() {
        let coordinator = DashboardTestingCoordinator()
        coordinator.testCurrentDashboardData()
    }
    
    /// Generate sample data for visual testing
    static func generateSampleData() {
        let simulator = GameplayDataSimulator()
        
        // Generate a variety of sessions
        let profiles: [GameplayDataSimulator.SimulationProfile] = [
            .beginner, .intermediate, .expert
        ]
        
        for profile in profiles {
            _ = simulator.simulateGameplay(
                profile: profile,
                duration: 600,
                levels: 5
            )
        }
        
        print("Sample data generated!")
    }
    
    /// Run all tests
    static func runAllTests() {
        let coordinator = DashboardTestingCoordinator()
        coordinator.runComprehensiveTest()
    }
}