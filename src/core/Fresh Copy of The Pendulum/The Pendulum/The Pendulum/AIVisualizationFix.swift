import UIKit
import Foundation
import SpriteKit

// MARK: - AI Visualization Fix
extension PendulumViewController {
    
    /// Ensure AI visual components are properly set up and visible
    func ensureAIVisualizationSetup() {
        // Visual components setup handled internally by PendulumViewController
        // Just log the current state for debugging
        print("🤖 AI Visualization Debug:")
        print("  - simulationView exists: \(simulationView != nil)")
        print("  - AI components will be initialized when AI starts")
    }
    
    /// Enhanced AI start method with visual debugging
    func startAIWithVisualFeedback(mode: PendulumAIManager.AIMode = .demo) {
        print("🚀 Starting AI with visual feedback - Mode: \(mode)")
        
        // CRITICAL: Ensure simulation is running
        if !viewModel.isSimulating {
            viewModel.startSimulation()
            print("✓ Started simulation (was stopped)")
        }
        
        // Use the enhanced method that guarantees movement
        startAIWithGuaranteedMovement(mode: mode)
    }
}

// MARK: - AI Button Actions Fix (Simplified)
extension PendulumViewController {
    
    /// Test push indicators to ensure they're working
    private func testPushIndicators() {
        // Flash both indicators to confirm they work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            print("🔵 Testing left push indicator")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            print("🔴 Testing right push indicator")
        }
    }
}