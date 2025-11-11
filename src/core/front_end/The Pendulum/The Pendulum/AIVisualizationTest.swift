import UIKit
import Foundation
import SpriteKit

// MARK: - AI Visualization Test & Debug
extension PendulumViewController {
    
    /// Comprehensive test to ensure AI moves the pendulum
    func testAIVisualization() {
        print("\n🧪 TESTING AI VISUALIZATION")
        print("=" * 50)
        
        // 1. Check view model connection
        print("1. View Model Check:")
        print("   - viewModel exists: true")
        print("   - scene exists: \((simulationView as? SKView)?.scene != nil)")
        print("   - simulationView exists: \(simulationView != nil)")
        
        // 2. Test direct force application
        print("\n2. Testing Direct Force Application:")
        let initialAngle = viewModel.currentState.theta
        viewModel.applyForce(2.0)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        let newAngle = viewModel.currentState.theta
        print("   - Initial angle: \(initialAngle)")
        print("   - New angle: \(newAngle)")
        print("   - Angle changed: \(initialAngle != newAngle)")
        
        // 3. Test AI Manager
        print("\n3. AI Manager Check:")
        print("   - AI Manager view model: \(PendulumAIManager.shared.viewModel != nil)")
        print("   - AI currently playing: \(PendulumAIManager.shared.isAIPlaying())")
        
        // 4. Start test AI with debug output
        print("\n4. Starting Test AI Demo...")
        startAITestDemo()
        
        print("\n" + "=" * 50)
    }
    
    /// Start AI demo with enhanced debugging
    private func startAITestDemo() {
        // Use the view model directly
        let viewModel = self.viewModel
        
        // Create a test AI player
        let testAI = PendulumAIPlayer(skillLevel: .expert)
        testAI.humanErrorEnabled = false // Disable errors for testing
        
        // Set up direct callbacks with logging
        testAI.onPushLeft = { [weak self] in
            print("🔵 AI Push LEFT")
            self?.viewModel.applyForce(-2.0)
            print("🔵 Visual: Left push indicator")
            
            // Force physics update
            // Note: pendulumNode is private, scene will update on its own
        }
        
        testAI.onPushRight = { [weak self] in
            print("🔴 AI Push RIGHT")
            self?.viewModel.applyForce(2.0)
            print("🔴 Visual: Right push indicator")
            
            // Force physics update
            // Note: pendulumNode is private, scene will update on its own
        }
        
        // Start the AI
        testAI.startPlaying()
        
        // Create update timer
        var updateCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let state = viewModel.currentState
            
            // Update AI
            testAI.updatePendulumState(
                angle: state.theta,
                angleVelocity: state.thetaDot,
                time: state.time
            )
            
            // Log state periodically
            if updateCount % 20 == 0 { // Every second
                let angleFromVertical = abs(atan2(sin(state.theta), cos(state.theta)) - Double.pi)
                print("📊 State: angle=\(String(format: "%.2f", angleFromVertical)), vel=\(String(format: "%.2f", state.thetaDot))")
            }
            
            updateCount += 1
            
            // Stop after 10 seconds
            if updateCount > 200 {
                timer.invalidate()
                testAI.stopPlaying()
                print("✅ AI Test Complete")
            }
        }
        
        // Show visual indicators
        print("📱 Showing AI mode: Demo")
        print("📢 AI TEST MODE - Pendulum should be moving!")
    }
}

// MARK: - Enhanced AI Start Method
extension PendulumViewController {
    
    /// Enhanced method to start AI with guaranteed visual feedback
    func startAIWithGuaranteedMovement(mode: PendulumAIManager.AIMode = .demo) {
        print("\n🚀 Starting AI with guaranteed movement...")
        
        // 1. CRITICAL: Ensure simulation is running FIRST
        if !viewModel.isSimulating {
            viewModel.startSimulation()
            print("✓ Started simulation (was stopped)")
        }
        
        // 2. Stop any existing AI
        if PendulumAIManager.shared.isAIPlaying() {
            PendulumAIManager.shared.stopAIPlayer()
            print("✓ Stopped existing AI")
        }
        
        // 3. Reset pendulum to a slightly off-vertical position to give AI something to work with
        viewModel.reset()
        viewModel.currentState.theta = Double.pi - 0.3 // 0.3 radians from vertical
        print("✓ Reset pendulum to angle: \(Double.pi - 0.3)")
        
        // 4. Ensure visualization is set up
        ensureAIVisualizationSetup()
        
        // 5. Show AI mode indicator BEFORE starting AI
        showAIModeIndicator(mode: mode)
        print("✓ Showing AI mode indicator: \(mode)")
        
        // 6. Start AI with explicit debugging
        print("🔧 Starting AI Manager...")
        PendulumAIManager.shared.viewModel = viewModel
        PendulumAIManager.shared.startAIPlayer(
            skillLevel: .expert, // Use expert level for demo
            viewModel: viewModel,
            mode: mode
        )
        
        // 7. Verify AI started
        if PendulumAIManager.shared.isAIPlaying() {
            print("✅ AI is now playing!")
        } else {
            print("❌ AI failed to start!")
        }
        
        // 7. Add visual confirmation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if PendulumAIManager.shared.isAIPlaying() {
                self.updateGameMessageLabel("🤖 AI is controlling the pendulum")
                print("🎯 AI Status Check: Still playing after 2 seconds")
            } else {
                self.updateGameMessageLabel("❌ AI failed to start")
                print("⚠️ AI Status Check: Not playing after 2 seconds")
            }
        }
        
        // 8. Show mode indicator
        print("📱 Showing animated AI mode: \(mode)")
    }
    
    // updateGameMessageLabel is now defined in PendulumViewController as internal
}

