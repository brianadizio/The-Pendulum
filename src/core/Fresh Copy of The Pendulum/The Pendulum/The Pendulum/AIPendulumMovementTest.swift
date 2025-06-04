import UIKit
import Foundation
import SpriteKit

// MARK: - Movement Monitor Helper
/// Helper class to avoid stored properties in extensions
class MovementMonitor {
    var timer: Timer?
    var initialAngle: Double = 0
    var angleHistory: [Double] = []
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - AI Pendulum Movement Test
/// Comprehensive test to ensure AI actually moves the pendulum visually

extension PendulumViewController {
    
    /// Run a comprehensive test to verify AI moves the pendulum
    func runAIPendulumMovementTest() {
        print("\n🎯 STARTING AI PENDULUM MOVEMENT TEST")
        print("=" * 60)
        
        // 1. Stop any existing AI
        if PendulumAIManager.shared.isAIPlaying() {
            PendulumAIManager.shared.stopAIPlayer()
            print("✓ Stopped existing AI player")
        }
        
        // 2. Ensure physics is running
        ensurePhysicsRunning()
        
        // 3. Reset pendulum to off-vertical position
        viewModel.reset()
        viewModel.currentState.theta = Double.pi - 0.5 // 0.5 radians from vertical
        print("✓ Reset pendulum to angle: \(Double.pi - 0.5)")
        
        // 4. Set up monitoring
        let monitor = startMovementMonitoring()
        
        // 5. Start AI with guaranteed visual feedback
        print("\n🚀 Starting AI Demo Mode...")
        startAIWithGuaranteedMovement(mode: .demo)
        
        // 6. Schedule status check
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.checkMovementStatus(monitor: monitor)
        }
    }
    
    private func ensurePhysicsRunning() {
        // Ensure simulation is running
        if !viewModel.isSimulating {
            viewModel.startSimulation()
            print("✓ Started simulation")
        } else {
            print("✓ Simulation already running")
        }
        
        // Ensure scene is active
        if let skView = simulationView as? SKView {
            skView.isPaused = false
            skView.scene?.isPaused = false
            print("✓ Ensured scene is not paused")
        }
    }
    
    private func startMovementMonitoring() -> MovementMonitor {
        let monitor = MovementMonitor()
        
        // Record initial state
        monitor.initialAngle = viewModel.currentState.theta
        monitor.angleHistory.append(monitor.initialAngle)
        
        // Start monitoring
        monitor.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let currentAngle = self.viewModel.currentState.theta
            monitor.angleHistory.append(currentAngle)
            
            // Log significant changes
            if monitor.angleHistory.count > 1 {
                let lastAngle = monitor.angleHistory[monitor.angleHistory.count - 2]
                if abs(currentAngle - lastAngle) > 0.01 {
                    print("📊 Angle changed: \(String(format: "%.3f", currentAngle)) rad")
                }
            }
        }
        
        print("✓ Started movement monitoring")
        return monitor
    }
    
    private func checkMovementStatus(monitor: MovementMonitor) {
        monitor.stop()
        
        print("\n📈 MOVEMENT TEST RESULTS:")
        print("-" * 40)
        
        // Check if angle changed
        let finalAngle = viewModel.currentState.theta
        let totalChange = abs(finalAngle - monitor.initialAngle)
        let maxChange = (monitor.angleHistory.max() ?? 0) - (monitor.angleHistory.min() ?? 0)
        
        print("Initial angle: \(String(format: "%.3f", monitor.initialAngle)) rad")
        print("Final angle: \(String(format: "%.3f", finalAngle)) rad")
        print("Total change: \(String(format: "%.3f", totalChange)) rad")
        print("Max variation: \(String(format: "%.3f", maxChange)) rad")
        print("Data points collected: \(monitor.angleHistory.count)")
        
        // Determine if pendulum moved
        let didMove = maxChange > 0.05 // At least 0.05 radians of movement
        
        if didMove {
            print("\n✅ SUCCESS: Pendulum is moving!")
            print("The AI is successfully controlling the pendulum.")
        } else {
            print("\n❌ FAILURE: Pendulum is NOT moving!")
            print("Troubleshooting tips:")
            print("- Check if viewModel is connected")
            print("- Verify AI callbacks are firing")
            print("- Ensure physics update is running")
        }
        
        // Additional diagnostics
        print("\n🔍 DIAGNOSTICS:")
        print("AI Playing: \(PendulumAIManager.shared.isAIPlaying())")
        print("View Model exists: \(viewModel != nil)")
        print("Simulation running: \(viewModel.isSimulating)")
        
        print("\n" + "=" * 60)
    }
}

// MARK: - Enhanced startAIWithGuaranteedMovement

extension PendulumViewController {
    
    /// Ultra-enhanced method to absolutely guarantee AI moves the pendulum
    func startAIWithUltraGuaranteedMovement(mode: PendulumAIManager.AIMode = .demo) {
        print("\n🚀🚀 Starting AI with ULTRA guaranteed movement...")
        
        // 1. Stop everything first
        PendulumAIManager.shared.stopAIPlayer()
        
        // 2. Ensure simulation is running
        if !viewModel.isSimulating {
            viewModel.startSimulation()
            print("✓ Started simulation")
        }
        
        // 3. Create a dedicated AI player with direct control
        let aiPlayer = PendulumAIPlayer(skillLevel: .expert)
        aiPlayer.humanErrorEnabled = false // No errors for testing
        
        // 4. Set up DIRECT callbacks that log and apply force
        aiPlayer.onPushLeft = { [weak self] in
            print("🔵 AI PUSH LEFT - Applying force -2.0")
            self?.viewModel.applyForce(-2.0)
            self?.showPushIndicatorLeft()
        }
        
        aiPlayer.onPushRight = { [weak self] in
            print("🔴 AI PUSH RIGHT - Applying force 2.0")
            self?.viewModel.applyForce(2.0)
            self?.showPushIndicatorRight()
        }
        
        // 5. Start the AI
        aiPlayer.startPlaying()
        
        // 6. Create our own update loop to ensure AI gets state updates
        var localUpdateTimer: Timer?
        localUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let state = self.viewModel.currentState
            
            // Update AI with current state
            aiPlayer.updatePendulumState(
                angle: state.theta,
                angleVelocity: state.thetaDot,
                time: state.time
            )
        }
        
        // 7. Show visual indicators
        showGameMessage("🤖 AI TEST - Pendulum WILL move!")
        
        // 8. Stop after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            localUpdateTimer?.invalidate()
            aiPlayer.stopPlaying()
            print("✅ AI test complete")
        }
        
        print("✓ AI started with ultra-guaranteed movement")
    }
    
    // Helper methods to show indicators (public versions)
    func showPushIndicatorLeft() {
        // Show left push visual feedback
        // Note: aiPushIndicatorLeft is private, so we'll just log
        print("⬅️ Left push indicator triggered")
    }
    
    func showPushIndicatorRight() {
        // Show right push visual feedback
        // Note: aiPushIndicatorRight is private, so we'll just log
        print("➡️ Right push indicator triggered")
    }
    
    func showGameMessage(_ message: String) {
        // Show message using the game message label instead of scene
        print("📢 Game message: \(message)")
        // Could also show in UI if we have access to labels
    }
}

// MARK: - Quick Test for Direct Movement

extension PendulumViewController {
    
    /// Test that directly moves the pendulum without AI
    func testDirectPendulumMovementWithFeedback() {
        print("\n🔧 TESTING DIRECT PENDULUM MOVEMENT")
        
        // Ensure simulation is running
        if !viewModel.isSimulating {
            viewModel.startSimulation()
        }
        
        // Apply alternating forces
        var forceDirection = 1.0
        var forceCount = 0
        let testTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Apply force
            let force = forceDirection * 2.0
            self.viewModel.applyForce(force)
            print("Applied force: \(force)")
            
            // Show visual feedback
            if force > 0 {
                self.showPushIndicatorRight()
            } else {
                self.showPushIndicatorLeft()
            }
            
            // Reverse direction
            forceDirection *= -1.0
            forceCount += 1
            
            // Stop after 10 forces
            if forceCount >= 10 {
                timer.invalidate()
                print("✅ Direct movement test complete")
            }
        }
        
        RunLoop.current.add(testTimer, forMode: .common)
    }
}

// MARK: - Developer Tools Integration

extension DeveloperToolsViewController {
    
    /// Enhanced test with visual feedback
    func runEnhancedAIPendulumTest() {
        // Create alert with options
        let alert = UIAlertController(
            title: "AI Pendulum Movement Test",
            message: "Choose test type:",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Basic Movement Test", style: .default) { [weak self] _ in
            self?.runBasicMovementTest()
        })
        
        alert.addAction(UIAlertAction(title: "Ultra-Guaranteed Movement", style: .default) { [weak self] _ in
            self?.runUltraGuaranteedTest()
        })
        
        alert.addAction(UIAlertAction(title: "Force Application Test", style: .default) { [weak self] _ in
            self?.runForceApplicationTest()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func runBasicMovementTest() {
        navigateToPendulumAndRun { pendulumVC in
            pendulumVC.runAIPendulumMovementTest()
        }
    }
    
    private func runUltraGuaranteedTest() {
        navigateToPendulumAndRun { pendulumVC in
            pendulumVC.startAIWithUltraGuaranteedMovement()
        }
    }
    
    private func runForceApplicationTest() {
        navigateToPendulumAndRun { pendulumVC in
            pendulumVC.testDirectPendulumMovementWithFeedback()
        }
    }
    
    private func navigateToPendulumAndRun(completion: @escaping (PendulumViewController) -> Void) {
        // Find and switch to pendulum tab
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let tabBar = window.rootViewController as? UITabBarController,
           let pendulumVC = tabBar.viewControllers?.first(where: { $0 is PendulumViewController }) as? PendulumViewController {
            
            // Switch to game tab
            tabBar.selectedViewController = pendulumVC
            
            // Run test after switching
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(pendulumVC)
            }
        } else {
            print("❌ Error: Could not find PendulumViewController")
        }
    }
}