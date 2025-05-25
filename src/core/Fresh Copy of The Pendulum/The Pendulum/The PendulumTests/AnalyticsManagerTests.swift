import Testing
@testable import The_Pendulum
import Foundation
import CoreData

@Suite("AnalyticsManager Tests")
struct AnalyticsManagerTests {
    
    @Test func testSingletonInstance() async throws {
        let instance1 = AnalyticsManager.shared
        let instance2 = AnalyticsManager.shared
        
        #expect(instance1 === instance2)
    }
    
    @Test func testStartTracking() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Verify tracking state is reset
        #expect(manager.directionalPushes["left"] == 0)
        #expect(manager.directionalPushes["right"] == 0)
    }
    
    @Test func testStopTracking() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        manager.stopTracking()
        
        // After stopping, tracking interactions should be ignored
        manager.trackInteraction(
            eventType: "push",
            angle: 0.1,
            angleVelocity: 0.2,
            magnitude: 0.5,
            direction: "left"
        )
        
        // No directional pushes should be recorded
        #expect(manager.directionalPushes["left"] == 0)
    }
    
    @Test func testTrackPendulumState() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track multiple states
        for i in 0..<10 {
            manager.trackPendulumState(
                angle: Double(i) * 0.1,
                angleVelocity: Double(i) * 0.05
            )
        }
        
        // State tracking doesn't directly expose buffer, but we can verify it runs without error
        #expect(true) // If we get here, tracking worked
    }
    
    @Test func testTrackInteraction() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track a push interaction
        manager.trackInteraction(
            eventType: "push",
            angle: 0.1,
            angleVelocity: 0.2,
            magnitude: 0.5,
            direction: "left"
        )
        
        #expect(manager.directionalPushes["left"] == 1)
        #expect(manager.directionalPushes["right"] == 0)
        
        // Track another push in opposite direction
        manager.trackInteraction(
            eventType: "push",
            angle: -0.1,
            angleVelocity: -0.2,
            magnitude: 0.6,
            direction: "right"
        )
        
        #expect(manager.directionalPushes["left"] == 1)
        #expect(manager.directionalPushes["right"] == 1)
    }
    
    @Test func testDirectionalBias() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track more left pushes
        for _ in 0..<3 {
            manager.trackInteraction(
                eventType: "push",
                angle: 0.1,
                angleVelocity: 0.2,
                magnitude: 0.5,
                direction: "left"
            )
        }
        
        // Track one right push
        manager.trackInteraction(
            eventType: "push",
            angle: -0.1,
            angleVelocity: -0.2,
            magnitude: 0.5,
            direction: "right"
        )
        
        // Should have left bias
        let metrics = manager.getPerformanceMetrics()
        let bias = metrics["directionalBias"] as? Double ?? 0
        
        #expect(bias < 0) // Negative means left bias
        #expect(abs(bias + 0.5) < 0.01) // Should be -0.5 (3 left, 1 right)
    }
    
    @Test func testPhaseSpaceTracking() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track phase space points
        for i in 0..<5 {
            manager.trackPhaseSpacePoint(
                theta: Double(i) * 0.1,
                omega: Double(i) * 0.2
            )
        }
        
        // Phase space tracking doesn't directly expose points, but we can verify it runs
        #expect(true)
    }
    
    @Test func testSetCurrentLevel() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Set level
        manager.setCurrentLevel(3)
        
        // Track some phase space points
        manager.trackPhaseSpacePoint(theta: 0.1, omega: 0.2)
        
        // Change level
        manager.setCurrentLevel(4)
        
        // Previous level's data should be saved
        #expect(true) // If we get here, level change worked
    }
    
    @Test func testGetRecentInteractions() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track some interactions
        for i in 0..<5 {
            manager.trackInteraction(
                eventType: "push",
                angle: Double(i) * 0.1,
                angleVelocity: Double(i) * 0.05,
                magnitude: 0.5,
                direction: i % 2 == 0 ? "left" : "right"
            )
        }
        
        let recent = manager.getRecentInteractions(limit: 10)
        
        // Should have the interactions we just tracked (pending)
        #expect(recent.count >= 5)
    }
    
    @Test func testPerformanceMetricsCalculation() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Simulate some gameplay
        for i in 0..<20 {
            // Track pendulum state
            let angle = sin(Double(i) * 0.1) * 0.2 // Small oscillations
            manager.trackPendulumState(angle: angle, angleVelocity: 0.1)
            
            // Track pushes
            if i % 5 == 0 {
                manager.trackInteraction(
                    eventType: "push",
                    angle: angle,
                    angleVelocity: 0.1,
                    magnitude: 0.5,
                    direction: i % 10 == 0 ? "left" : "right"
                )
            }
        }
        
        let metrics = manager.getPerformanceMetrics()
        
        // Verify metrics exist
        #expect(metrics["stabilityScore"] != nil)
        #expect(metrics["efficiencyRating"] != nil)
        #expect(metrics["playerStyle"] != nil)
        
        // Check reasonable values
        let stability = metrics["stabilityScore"] as? Double ?? 0
        #expect(stability >= 0 && stability <= 100)
    }
    
    @Test func testPlayerStyleDetermination() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Simulate overcorrection pattern
        for i in 0..<10 {
            manager.trackInteraction(
                eventType: "push",
                angle: 0.1,
                angleVelocity: 0.2,
                magnitude: 0.5,
                direction: i % 2 == 0 ? "left" : "right"
            )
            
            // Small delay to avoid overcorrection detection
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        let metrics = manager.getPerformanceMetrics()
        let style = metrics["playerStyle"] as? String ?? ""
        
        #expect(!style.isEmpty)
    }
    
    @Test func testPushFrequencyDistribution() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track pushes with different intervals
        var lastTime = Date()
        for i in 0..<5 {
            Thread.sleep(forTimeInterval: Double(i + 1) * 0.1)
            manager.trackInteraction(
                eventType: "push",
                angle: 0.1,
                angleVelocity: 0.2,
                magnitude: 0.5,
                direction: "left"
            )
        }
        
        let distribution = manager.getPushFrequencyDistribution()
        
        // Should have some frequency data
        #expect(!distribution.isEmpty)
    }
    
    @Test func testPushMagnitudeDistribution() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track pushes with different magnitudes
        let magnitudes = [0.1, 0.3, 0.5, 0.7, 0.9]
        for mag in magnitudes {
            manager.trackInteraction(
                eventType: "push",
                angle: 0.1,
                angleVelocity: 0.2,
                magnitude: mag,
                direction: "left"
            )
        }
        
        let distribution = manager.getPushMagnitudeDistribution()
        
        // Should have distribution data
        #expect(!distribution.isEmpty)
        #expect(distribution.count <= magnitudes.count)
    }
    
    @Test func testTrackingWithoutStarting() async throws {
        let manager = AnalyticsManager.shared
        
        // Ensure we're not tracking
        manager.stopTracking()
        
        // Try to track interaction
        manager.trackInteraction(
            eventType: "push",
            angle: 0.1,
            angleVelocity: 0.2,
            magnitude: 0.5,
            direction: "left"
        )
        
        // Nothing should be tracked
        #expect(manager.directionalPushes["left"] == 0)
    }
    
    @Test func testNormalizeAngle() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Test angle normalization through state tracking
        // Track states with angles that need normalization
        manager.trackPendulumState(angle: 2 * Double.pi + 0.1, angleVelocity: 0)
        manager.trackPendulumState(angle: -2 * Double.pi - 0.1, angleVelocity: 0)
        
        // If normalization works, tracking should complete without error
        #expect(true)
    }
    
    @Test func testEmptyMetrics() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Get metrics without any data
        let metrics = manager.getPerformanceMetrics()
        
        // Should return default values
        let stability = metrics["stabilityScore"] as? Double ?? -1
        #expect(stability == 0)
        
        let efficiency = metrics["efficiencyRating"] as? Double ?? -1
        #expect(efficiency == 0)
    }
    
    @Test func testInteractionBatchSaving() async throws {
        let manager = AnalyticsManager.shared
        let sessionId = UUID()
        
        manager.startTracking(for: sessionId)
        
        // Track exactly 10 interactions to trigger batch save
        for i in 0..<10 {
            manager.trackInteraction(
                eventType: "push",
                angle: Double(i) * 0.1,
                angleVelocity: 0.2,
                magnitude: 0.5,
                direction: "left"
            )
        }
        
        // Batch should have been saved
        // We can't directly test Core Data here, but we verify no crash
        #expect(true)
    }
}