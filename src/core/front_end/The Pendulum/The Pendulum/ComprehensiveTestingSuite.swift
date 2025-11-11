// ComprehensiveTestingSuite.swift
// Unified testing suite that combines all testing capabilities

import Foundation
import UIKit

class ComprehensiveTestingSuite {
    
    static let shared = ComprehensiveTestingSuite()
    
    private let dashboardValidator = DashboardDataValidator()
    private let aiTestingSystem = AITestingSystem()
    private let dataSimulator = GameplayDataSimulator()
    
    // MARK: - Full Testing Suite
    
    /// Run the complete testing suite
    func runCompleteSuite(completion: @escaping (TestResults) -> Void) {
        print("🧪 Starting Comprehensive Testing Suite...")
        
        var results = TestResults()
        let testGroup = DispatchGroup()
        
        // Test 1: Generate Historical Data (3 months)
        testGroup.enter()
        generateHistoricalData { success in
            results.historicalDataGenerated = success
            testGroup.leave()
        }
        
        // Test 2: Validate Dashboard Metrics
        testGroup.enter()
        validateDashboardData { validation in
            results.dashboardValidation = validation
            testGroup.leave()
        }
        
        // Test 3: Run AI Performance Tests
        testGroup.enter()
        runAIPerformanceTests { aiResults in
            results.aiPerformance = aiResults
            testGroup.leave()
        }
        
        // Test 4: Stress Test with Edge Cases
        testGroup.enter()
        runStressTests { stressResults in
            results.stressTestPassed = stressResults
            testGroup.leave()
        }
        
        // Test 5: Visual Dashboard Test
        testGroup.enter()
        generateVisualTestData { visualResults in
            results.visualTestCompleted = visualResults
            testGroup.leave()
        }
        
        // Wait for all tests to complete
        testGroup.notify(queue: .main) {
            print("\n✅ Testing Suite Complete!")
            self.printTestSummary(results)
            completion(results)
        }
    }
    
    // MARK: - Individual Test Components
    
    /// Generate 3 months of realistic gameplay data
    private func generateHistoricalData(completion: @escaping (Bool) -> Void) {
        print("\n📅 Test 1: Generating 3 months of historical data...")
        
        AITestingSystem.generateMonthsOfGameplayData(months: 3) { success in
            if success {
                print("✓ Historical data generated successfully")
            } else {
                print("✗ Historical data generation failed")
            }
            completion(success)
        }
    }
    
    /// Validate all dashboard metrics
    private func validateDashboardData(completion: @escaping (DashboardDataValidator.ValidationResult) -> Void) {
        print("\n📊 Test 2: Validating dashboard metrics...")
        
        // Get current metrics
        let metrics = AnalyticsManager.shared.getPerformanceMetrics()
        
        // Validate metrics
        let validation = DashboardDataValidator.validateMetrics(metrics)
        
        print("✓ Metrics validation: \(validation.isValid ? "PASSED" : "FAILED")")
        if !validation.errors.isEmpty {
            print("  Errors: \(validation.errors.joined(separator: ", "))")
        }
        
        completion(validation)
    }
    
    /// Run AI performance tests across all skill levels
    private func runAIPerformanceTests(completion: @escaping (AIPerformanceResults) -> Void) {
        print("\n🤖 Test 3: Running AI performance tests...")
        
        var results = AIPerformanceResults()
        let skillLevels: [AISkillLevel] = [.beginner, .intermediate, .advanced, .expert, .perfect]
        
        for skill in skillLevels {
            // Run quick test for each skill level
            let config = AITestConfiguration(
                skillLevel: skill,
                duration: 300, // 5 minutes
                perturbationModes: ["Primary"],
                parameterVariations: false,
                numberOfSessions: 1,
                timeBetweenSessions: 0
            )
            
            aiTestingSystem.runTest(configuration: config) { testResults in
                results.skillLevelResults[skill] = testResults
                print("✓ \(skill) AI test complete - Avg Score: \(testResults.averageScore)")
            }
        }
        
        completion(results)
    }
    
    /// Stress test with edge cases
    private func runStressTests(completion: @escaping (Bool) -> Void) {
        print("\n💪 Test 4: Running stress tests...")
        
        // Test extreme parameters
        let extremeTests = [
            (mass: 0.1, length: 0.1, damping: 10.0, gravity: 50.0),
            (mass: 10.0, length: 5.0, damping: 0.0, gravity: 1.0),
            (mass: 5.0, length: 3.0, damping: 5.0, gravity: 9.81)
        ]
        
        var allPassed = true
        
        for (index, params) in extremeTests.enumerated() {
            print("  Testing extreme case \(index + 1)...")
            
            // Simulate with extreme parameters
            let sessionId = dataSimulator.simulateGameplayWithParameters(
                mass: params.mass,
                length: params.length,
                damping: params.damping,
                gravity: params.gravity,
                duration: 60 // 1 minute test
            )
            
            // Check if simulation completed without crashes
            let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
            if metrics.isEmpty {
                print("  ✗ Extreme case \(index + 1) failed")
                allPassed = false
            } else {
                print("  ✓ Extreme case \(index + 1) passed")
            }
        }
        
        completion(allPassed)
    }
    
    /// Generate visual test data for manual inspection
    private func generateVisualTestData(completion: @escaping (Bool) -> Void) {
        print("\n🎨 Test 5: Generating visual test data...")
        
        // Generate data for each chart type
        let testProfiles = [
            GameplayDataSimulator.SimulationProfile.beginner,
            GameplayDataSimulator.SimulationProfile.intermediate,
            GameplayDataSimulator.SimulationProfile.expert,
            GameplayDataSimulator.SimulationProfile.erratic,
            GameplayDataSimulator.SimulationProfile.improver
        ]
        
        for profile in testProfiles {
            _ = dataSimulator.simulateGameplay(
                profile: profile,
                duration: 600, // 10 minutes
                levels: 3,
                startDate: Date()
            )
            print("✓ Generated data for \(profile) profile")
        }
        
        completion(true)
    }
    
    // MARK: - Test Results
    
    struct TestResults {
        var historicalDataGenerated = false
        var dashboardValidation: DashboardDataValidator.ValidationResult?
        var aiPerformance: AIPerformanceResults?
        var stressTestPassed = false
        var visualTestCompleted = false
        
        var overallSuccess: Bool {
            return historicalDataGenerated &&
                   (dashboardValidation?.isValid ?? false) &&
                   stressTestPassed &&
                   visualTestCompleted
        }
    }
    
    struct AIPerformanceResults {
        var skillLevelResults: [AISkillLevel: AITestingSystem.TestResults] = [:]
    }
    
    // MARK: - Summary Reporting
    
    private func printTestSummary(_ results: TestResults) {
        print("\n" + String(repeating: "=", count: 50))
        print("📋 COMPREHENSIVE TEST SUMMARY")
        print(String(repeating: "=", count: 50))
        
        print("\n✅ Overall Result: \(results.overallSuccess ? "PASSED" : "FAILED")")
        
        print("\n📊 Individual Test Results:")
        print("  • Historical Data Generation: \(results.historicalDataGenerated ? "✓" : "✗")")
        print("  • Dashboard Validation: \(results.dashboardValidation?.isValid ?? false ? "✓" : "✗")")
        print("  • AI Performance Tests: \(results.aiPerformance != nil ? "✓" : "✗")")
        print("  • Stress Tests: \(results.stressTestPassed ? "✓" : "✗")")
        print("  • Visual Tests: \(results.visualTestCompleted ? "✓" : "✗")")
        
        if let validation = results.dashboardValidation, !validation.errors.isEmpty {
            print("\n⚠️ Validation Errors:")
            validation.errors.forEach { print("  • \($0)") }
        }
        
        if let aiResults = results.aiPerformance {
            print("\n🤖 AI Performance Summary:")
            for (skill, result) in aiResults.skillLevelResults {
                print("  • \(skill): Avg Score \(result.averageScore), Levels/Session: \(result.averageLevelsPerSession)")
            }
        }
        
        print("\n" + String(repeating: "=", count: 50))
    }
}

// MARK: - Convenience Methods

extension ComprehensiveTestingSuite {
    
    /// Quick method to populate empty dashboard
    static func populateEmptyDashboard() {
        print("🚀 Populating empty dashboard with test data...")
        
        // Generate 1 week of data quickly
        AITestingSystem.generateMonthsOfGameplayData(months: 0) { _ in
            // Instead generate just a week
            let tester = AITestingSystem()
            let weekConfig = AITestConfiguration(
                skillLevel: .intermediate,
                duration: 600,
                perturbationModes: ["Primary", "Progressive", "Random Impulses"],
                parameterVariations: true,
                numberOfSessions: 21, // 3 per day for 7 days
                timeBetweenSessions: 0
            )
            
            tester.runTest(configuration: weekConfig) { _ in
                print("✅ Dashboard populated with 1 week of data")
            }
        }
    }
    
    /// Run continuous testing in background
    static func runContinuousBackgroundTesting() {
        print("🔄 Starting continuous background testing...")
        
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            // Every 5 minutes, generate a new AI session
            let quickConfig = AITestConfiguration(
                skillLevel: [.beginner, .intermediate, .advanced].randomElement()!,
                duration: 180, // 3 minute sessions
                perturbationModes: ["Primary", "Progressive", "Random Impulses"].randomElement().map { [$0] } ?? [],
                parameterVariations: Bool.random(),
                numberOfSessions: 1,
                timeBetweenSessions: 0
            )
            
            AITestingSystem().runTest(configuration: quickConfig) { _ in
                print("🔄 Background test session completed")
            }
        }
    }
}