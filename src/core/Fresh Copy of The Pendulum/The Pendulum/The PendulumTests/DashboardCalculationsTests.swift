// DashboardCalculationsTests.swift
// Unit tests for dashboard metric calculations

import XCTest
@testable import The_Pendulum

class DashboardCalculationsTests: XCTestCase {
    
    var analyticsManager: AnalyticsManager!
    
    override func setUp() {
        super.setUp()
        analyticsManager = AnalyticsManager.shared
    }
    
    override func tearDown() {
        analyticsManager = nil
        super.tearDown()
    }
    
    // MARK: - Stability Score Tests
    
    func testStabilityScoreCalculation() {
        // Test with known angle buffer
        analyticsManager.angleBuffer = [
            Double.pi, Double.pi + 0.1, Double.pi - 0.1,
            Double.pi + 0.05, Double.pi - 0.05
        ]
        
        let stabilityScore = analyticsManager.calculateStabilityScore()
        
        // Verify score is in valid range
        XCTAssertGreaterThanOrEqual(stabilityScore, 0)
        XCTAssertLessThanOrEqual(stabilityScore, 100)
        XCTAssertFalse(stabilityScore.isNaN)
        XCTAssertFalse(stabilityScore.isInfinite)
    }
    
    func testStabilityScoreWithPerfectStability() {
        // All angles are exactly vertical
        analyticsManager.angleBuffer = Array(repeating: Double.pi, count: 100)
        
        let stabilityScore = analyticsManager.calculateStabilityScore()
        
        // Perfect stability should give high score
        XCTAssertEqual(stabilityScore, 100.0, accuracy: 0.1)
    }
    
    func testStabilityScoreWithHighVariance() {
        // High variance angles
        analyticsManager.angleBuffer = [
            Double.pi - 0.5, Double.pi + 0.5,
            Double.pi - 0.4, Double.pi + 0.4
        ]
        
        let stabilityScore = analyticsManager.calculateStabilityScore()
        
        // High variance should give low score
        XCTAssertLessThan(stabilityScore, 50)
    }
    
    func testStabilityScoreWithEmptyBuffer() {
        analyticsManager.angleBuffer = []
        
        let stabilityScore = analyticsManager.calculateStabilityScore()
        
        // Empty buffer should return 0
        XCTAssertEqual(stabilityScore, 0)
    }
    
    // MARK: - Efficiency Rating Tests
    
    func testEfficiencyRatingCalculation() {
        // Set up test data
        analyticsManager.angleBuffer = [Double.pi, Double.pi + 0.05, Double.pi - 0.05]
        analyticsManager.totalForceApplied = 10.0
        
        let efficiencyRating = analyticsManager.calculateEfficiencyRating()
        
        // Verify rating is in valid range
        XCTAssertGreaterThanOrEqual(efficiencyRating, 0)
        XCTAssertLessThanOrEqual(efficiencyRating, 100)
        XCTAssertFalse(efficiencyRating.isNaN)
        XCTAssertFalse(efficiencyRating.isInfinite)
    }
    
    func testEfficiencyRatingWithNoForce() {
        analyticsManager.angleBuffer = [Double.pi, Double.pi + 0.1]
        analyticsManager.totalForceApplied = 0
        
        let efficiencyRating = analyticsManager.calculateEfficiencyRating()
        
        // No force applied should return 0
        XCTAssertEqual(efficiencyRating, 0)
    }
    
    func testEfficiencyRatingWithMinimalForce() {
        // High stability with minimal force = high efficiency
        analyticsManager.angleBuffer = Array(repeating: Double.pi, count: 50)
        analyticsManager.totalForceApplied = 5.0
        
        let efficiencyRating = analyticsManager.calculateEfficiencyRating()
        
        // Should have high efficiency
        XCTAssertGreaterThan(efficiencyRating, 80)
    }
    
    // MARK: - Directional Bias Tests
    
    func testDirectionalBiasBalanced() {
        analyticsManager.directionalPushes = ["left": 50, "right": 50]
        
        let bias = analyticsManager.calculateDirectionalBias()
        
        XCTAssertEqual(bias, 0.0, accuracy: 0.001)
    }
    
    func testDirectionalBiasLeftHeavy() {
        analyticsManager.directionalPushes = ["left": 75, "right": 25]
        
        let bias = analyticsManager.calculateDirectionalBias()
        
        // Negative bias for left-heavy
        XCTAssertLessThan(bias, 0)
        XCTAssertEqual(bias, -0.5, accuracy: 0.001)
    }
    
    func testDirectionalBiasRightHeavy() {
        analyticsManager.directionalPushes = ["left": 20, "right": 80]
        
        let bias = analyticsManager.calculateDirectionalBias()
        
        // Positive bias for right-heavy
        XCTAssertGreaterThan(bias, 0)
        XCTAssertEqual(bias, 0.6, accuracy: 0.001)
    }
    
    func testDirectionalBiasNoPushes() {
        analyticsManager.directionalPushes = ["left": 0, "right": 0]
        
        let bias = analyticsManager.calculateDirectionalBias()
        
        XCTAssertEqual(bias, 0.0)
    }
    
    // MARK: - Overcorrection Rate Tests
    
    func testOvercorrectionRateCalculation() {
        // Create test interaction history with overcorrections
        let now = Date()
        analyticsManager.interactionHistory = [
            AnalyticsManager.InteractionEventData(
                timestamp: now,
                eventType: "push",
                angle: Double.pi + 0.1,
                angleVelocity: 0.1,
                magnitude: 1.0,
                direction: "left",
                reactionTime: 0.3
            ),
            AnalyticsManager.InteractionEventData(
                timestamp: now.addingTimeInterval(0.3), // Quick opposite push
                eventType: "push",
                angle: Double.pi - 0.1,
                angleVelocity: -0.1,
                magnitude: 1.0,
                direction: "right",
                reactionTime: 0.2
            ),
            AnalyticsManager.InteractionEventData(
                timestamp: now.addingTimeInterval(2.0), // Not an overcorrection (too much time)
                eventType: "push",
                angle: Double.pi + 0.05,
                angleVelocity: 0.05,
                magnitude: 0.5,
                direction: "left",
                reactionTime: 0.4
            )
        ]
        
        let overcorrectionRate = analyticsManager.calculateOvercorrectionRate()
        
        // Should detect 1 overcorrection out of 2 possible pairs
        XCTAssertEqual(overcorrectionRate, 0.5, accuracy: 0.01)
    }
    
    func testOvercorrectionRateNoOvercorrections() {
        // All pushes in same direction
        let now = Date()
        analyticsManager.interactionHistory = [
            AnalyticsManager.InteractionEventData(
                timestamp: now,
                eventType: "push",
                angle: Double.pi + 0.1,
                angleVelocity: 0.1,
                magnitude: 1.0,
                direction: "left",
                reactionTime: 0.3
            ),
            AnalyticsManager.InteractionEventData(
                timestamp: now.addingTimeInterval(1.0),
                eventType: "push",
                angle: Double.pi + 0.15,
                angleVelocity: 0.1,
                magnitude: 1.0,
                direction: "left",
                reactionTime: 0.3
            )
        ]
        
        let overcorrectionRate = analyticsManager.calculateOvercorrectionRate()
        
        XCTAssertEqual(overcorrectionRate, 0.0)
    }
    
    // MARK: - Player Style Tests
    
    func testPlayerStyleExpert() {
        let style = analyticsManager.determinePlayerStyle(
            stabilityScore: 90,
            efficiencyRating: 85,
            directionalBias: 0.05,
            overcorrectionRate: 0.05
        )
        
        XCTAssertEqual(style, "Expert Balancer")
    }
    
    func testPlayerStyleRightDominant() {
        let style = analyticsManager.determinePlayerStyle(
            stabilityScore: 60,
            efficiencyRating: 60,
            directionalBias: 0.7,
            overcorrectionRate: 0.1
        )
        
        XCTAssertEqual(style, "Right-Dominant")
    }
    
    func testPlayerStyleOvercorrector() {
        let style = analyticsManager.determinePlayerStyle(
            stabilityScore: 50,
            efficiencyRating: 40,
            directionalBias: 0.1,
            overcorrectionRate: 0.4
        )
        
        XCTAssertEqual(style, "Overcorrector")
    }
    
    func testPlayerStyleQuickButErratic() {
        // Set up reaction times for quick responses
        analyticsManager.reactionTimes = [0.2, 0.25, 0.2, 0.15]
        
        let style = analyticsManager.determinePlayerStyle(
            stabilityScore: 45,
            efficiencyRating: 50,
            directionalBias: 0.0,
            overcorrectionRate: 0.2
        )
        
        XCTAssertEqual(style, "Quick but Erratic")
    }
    
    // MARK: - Data Validation Tests
    
    func testMetricsValidation() {
        let validMetrics: [String: Any] = [
            "stabilityScore": 75.5,
            "efficiencyRating": 82.1,
            "playerStyle": "Balanced Controller",
            "averageCorrectionTime": 0.45,
            "directionalBias": 0.12,
            "overcorrectionRate": 0.15
        ]
        
        let validation = DashboardDataValidator.validateMetrics(validMetrics)
        
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.errors.isEmpty)
    }
    
    func testMetricsValidationWithInvalidData() {
        let invalidMetrics: [String: Any] = [
            "stabilityScore": 150.0, // Out of range
            "efficiencyRating": -10.0, // Negative
            "playerStyle": "Unknown Style",
            "averageCorrectionTime": -0.5, // Negative time
            "directionalBias": 2.0 // Out of range
        ]
        
        let validation = DashboardDataValidator.validateMetrics(invalidMetrics)
        
        XCTAssertFalse(validation.isValid)
        XCTAssertFalse(validation.errors.isEmpty)
    }
    
    func testChartDataValidation() {
        let data = [1.2, 2.3, 3.4, 4.5, 5.6]
        let labels = ["A", "B", "C", "D", "E"]
        
        let validation = DashboardDataValidator.validateChartData(
            data: data,
            labels: labels,
            chartType: "TestChart"
        )
        
        XCTAssertTrue(validation.isValid)
    }
    
    func testChartDataValidationMismatchedCounts() {
        let data = [1.2, 2.3, 3.4]
        let labels = ["A", "B", "C", "D", "E"] // More labels than data
        
        let validation = DashboardDataValidator.validateChartData(
            data: data,
            labels: labels,
            chartType: "TestChart"
        )
        
        XCTAssertFalse(validation.isValid)
        XCTAssertTrue(validation.errors.contains { $0.contains("doesn't match") })
    }
    
    // MARK: - Cross-Validation Tests
    
    func testCrossValidationConsistent() {
        let validation = DashboardDataValidator.crossValidateMetrics(
            stabilityScore: 80.0,
            efficiencyRating: 85.0,
            totalForceApplied: 15.0,
            angleVariance: 0.1
        )
        
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.warnings.isEmpty)
    }
    
    func testCrossValidationInconsistent() {
        // High efficiency but high force usage
        let validation = DashboardDataValidator.crossValidateMetrics(
            stabilityScore: 50.0,
            efficiencyRating: 90.0,
            totalForceApplied: 80.0,
            angleVariance: 0.4
        )
        
        XCTAssertTrue(validation.isValid) // Still valid, just has warnings
        XCTAssertFalse(validation.warnings.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testStabilityScorePerformance() {
        // Test with large buffer
        analyticsManager.angleBuffer = (0..<10000).map { _ in
            Double.pi + Double.random(in: -0.2...0.2)
        }
        
        measure {
            _ = analyticsManager.calculateStabilityScore()
        }
    }
    
    func testOvercorrectionRatePerformance() {
        // Create large interaction history
        let now = Date()
        analyticsManager.interactionHistory = (0..<1000).map { i in
            AnalyticsManager.InteractionEventData(
                timestamp: now.addingTimeInterval(Double(i) * 0.5),
                eventType: "push",
                angle: Double.pi + Double.random(in: -0.2...0.2),
                angleVelocity: Double.random(in: -0.5...0.5),
                magnitude: Double.random(in: 0.5...2.0),
                direction: Bool.random() ? "left" : "right",
                reactionTime: Double.random(in: 0.2...0.8)
            )
        }
        
        measure {
            _ = analyticsManager.calculateOvercorrectionRate()
        }
    }
}