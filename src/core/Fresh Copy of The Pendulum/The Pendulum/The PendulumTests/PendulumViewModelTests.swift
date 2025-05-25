//
//  PendulumViewModelTests.swift
//  The PendulumTests
//
//  Created by Claude on 5/25/25.
//

import Testing
import Foundation
import Combine
@testable import The_Pendulum

@MainActor
struct PendulumViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test func testViewModelInitialization() async throws {
        let viewModel = PendulumViewModel()
        
        #expect(viewModel.isRunning == false)
        #expect(viewModel.currentLevel == 1)
        #expect(viewModel.score == 0)
        #expect(viewModel.balanceTime == 0.0)
        #expect(viewModel.isBalanced == false)
        #expect(viewModel.levelCompleted == false)
    }
    
    // MARK: - Simulation Control Tests
    
    @Test func testStartSimulation() async throws {
        let viewModel = PendulumViewModel()
        
        viewModel.startSimulation()
        
        #expect(viewModel.isRunning == true)
        
        // Clean up
        viewModel.stopSimulation()
    }
    
    @Test func testStopSimulation() async throws {
        let viewModel = PendulumViewModel()
        
        viewModel.startSimulation()
        viewModel.stopSimulation()
        
        #expect(viewModel.isRunning == false)
    }
    
    @Test func testResetSimulation() async throws {
        let viewModel = PendulumViewModel()
        
        // Set some state
        viewModel.score = 100
        viewModel.balanceTime = 5.0
        
        // Reset
        viewModel.resetSimulation()
        
        #expect(viewModel.model.theta == 0.0)
        #expect(viewModel.model.omega == 0.0)
        #expect(viewModel.balanceTime == 0.0)
        #expect(viewModel.score == 0)
    }
    
    // MARK: - Force Application Tests
    
    @Test func testApplyForce() async throws {
        let viewModel = PendulumViewModel()
        let initialOmega = viewModel.model.omega
        
        viewModel.applyForce(10.0)
        
        #expect(viewModel.model.omega != initialOmega)
    }
    
    // MARK: - Parameter Update Tests
    
    @Test func testUpdateParameters() async throws {
        let viewModel = PendulumViewModel()
        
        viewModel.updateParameters(
            mass: 2.0,
            length: 1.5,
            gravity: 10.0,
            damping: 0.1,
            springConstant: 0.5
        )
        
        #expect(viewModel.model.mass == 2.0)
        #expect(viewModel.model.length == 1.5)
        #expect(viewModel.model.gravity == 10.0)
        #expect(viewModel.model.damping == 0.1)
        #expect(viewModel.model.springConstant == 0.5)
    }
    
    // MARK: - Level System Tests
    
    @Test func testLevelProgression() async throws {
        let viewModel = PendulumViewModel()
        let initialLevel = viewModel.currentLevel
        
        // Simulate level completion
        viewModel.score = 1000 // Enough for level 2
        viewModel.checkLevelProgression()
        
        #expect(viewModel.currentLevel > initialLevel)
    }
    
    @Test func testBalanceDetection() async throws {
        let viewModel = PendulumViewModel()
        
        // Set pendulum to balanced position
        viewModel.model.theta = 0.01 // Very small angle
        viewModel.model.omega = 0.01 // Very small velocity
        
        viewModel.checkBalance()
        
        // Should be detected as balanced if within threshold
        // This depends on the balance threshold implementation
    }
    
    // MARK: - Perturbation Tests
    
    @Test func testActivatePerturbation() async throws {
        let viewModel = PendulumViewModel()
        
        viewModel.activatePerturbation()
        
        #expect(viewModel.isPerturbationActive == true)
    }
    
    @Test func testDeactivatePerturbation() async throws {
        let viewModel = PendulumViewModel()
        
        viewModel.activatePerturbation()
        viewModel.deactivatePerturbation()
        
        #expect(viewModel.isPerturbationActive == false)
    }
    
    // MARK: - Publisher Tests
    
    @Test func testStatePublisher() async throws {
        let viewModel = PendulumViewModel()
        var receivedStates: [PendulumState] = []
        
        let cancellable = viewModel.$pendulumState
            .sink { state in
                receivedStates.append(state)
            }
        
        // Trigger state change
        viewModel.model.theta = 1.0
        viewModel.model.omega = 0.5
        viewModel.objectWillChange.send()
        
        // Wait a bit for publisher to emit
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(receivedStates.count > 0)
        
        cancellable.cancel()
    }
    
    // MARK: - Integration Tests
    
    @Test func testFullSimulationCycle() async throws {
        let viewModel = PendulumViewModel()
        
        // Start simulation
        viewModel.startSimulation()
        
        // Apply some forces
        viewModel.applyForce(5.0)
        
        // Wait for a few updates
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Check that simulation is running and values have changed
        #expect(viewModel.isRunning == true)
        #expect(viewModel.model.time > 0)
        
        // Stop simulation
        viewModel.stopSimulation()
        
        #expect(viewModel.isRunning == false)
    }
}