// TestAISystem.swift
// Simple test harness for AI system functionality

import Foundation

// Test the AI system
func testAISystem() {
    print("🧪 Testing AI System...")
    
    // Test 1: Quick test
    print("\n1️⃣ Running Quick Test...")
    let quickTest = AITestingSystem()
    quickTest.runQuickTest { results in
        print("✅ Quick test complete!")
        print("   Sessions: \(results.totalSessions)")
        print("   Average score: \(results.averageScore)")
        print("   Average levels: \(results.averageLevelsPerSession)")
    }
    
    // Test 2: AI Player
    print("\n2️⃣ Testing AI Player...")
    let aiPlayer = PendulumAIPlayer(skillLevel: .intermediate)
    
    // Simulate pendulum states
    let testStates: [(angle: Double, velocity: Double)] = [
        (3.0, 0.1),    // Slightly tilted left
        (3.2, -0.2),   // Tilting right with velocity
        (3.3, -0.3),   // Further right
        (3.1, 0.2),    // Coming back left
        (3.14, 0.0)    // Near vertical
    ]
    
    aiPlayer.startPlaying()
    
    for (index, state) in testStates.enumerated() {
        print("\n   State \(index): angle=\(state.angle), velocity=\(state.velocity)")
        aiPlayer.updatePendulumState(
            angle: state.angle,
            angleVelocity: state.velocity,
            time: Double(index) * 0.1
        )
    }
    
    aiPlayer.stopPlaying()
    print("\n✅ AI Player test complete!")
}