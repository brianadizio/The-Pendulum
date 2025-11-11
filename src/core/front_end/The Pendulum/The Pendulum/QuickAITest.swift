// QuickAITest.swift
// Quick verification that AI system compiles and runs

import Foundation

class QuickAITest {
    
    static func verifyAISystem() {
        print("🧪 Quick AI System Verification...")
        
        // Test 1: Verify AI skill levels
        print("\n1️⃣ Testing AI Skill Levels:")
        for skill in AISkillLevel.allCases {
            print("  • \(skill.rawValue): Reaction \(skill.reactionTimeRange), Error Rate \(skill.errorRate)")
        }
        
        // Test 2: Create AI Player
        print("\n2️⃣ Creating AI Player:")
        let aiPlayer = PendulumAIPlayer(skillLevel: .intermediate)
        print("  ✅ AI Player created successfully")
        
        // Test 3: Test AI Testing System
        print("\n3️⃣ Testing AI System:")
        let testSystem = AITestingSystem()
        print("  ✅ AI Testing System created successfully")
        
        // Test 4: Test Data Simulator
        print("\n4️⃣ Testing Data Simulator:")
        let simulator = GameplayDataSimulator()
        print("  ✅ Gameplay Data Simulator created successfully")
        
        // Test 5: Test Comprehensive Suite
        print("\n5️⃣ Testing Comprehensive Suite:")
        let suite = ComprehensiveTestingSuite.shared
        print("  ✅ Comprehensive Testing Suite accessed successfully")
        
        print("\n✅ All AI System Components Verified!")
        print("🚀 Ready to generate months of gameplay data!")
    }
    
    static func runQuickDataGeneration() {
        print("\n🚀 Running Quick Data Generation Test...")
        
        // Generate a small amount of test data
        let simulator = GameplayDataSimulator()
        let sessionId = simulator.simulateGameplay(
            profile: .intermediate,
            duration: 60, // 1 minute
            levels: 1
        )
        
        print("✅ Generated test session: \(sessionId)")
        
        // Verify data was created
        let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
        if !metrics.isEmpty {
            print("✅ Session data generated successfully!")
            print("  Score: \(metrics["finalScore"] ?? "N/A")")
            print("  Duration: \(metrics["totalPlayTime"] ?? "N/A")")
        } else {
            print("⚠️ No data generated - check implementation")
        }
    }
}