//
//  PendulumModelTests.swift
//  The PendulumTests
//
//  Created by Claude on 5/25/25.
//

import Testing
import Foundation
@testable import The_Pendulum

struct PendulumModelTests {
    
    // MARK: - Initialization Tests
    
    @Test func testDefaultInitialization() async throws {
        let model = PendulumModel()
        
        #expect(model.mass == 1.0)
        #expect(model.length == 1.0)
        #expect(model.gravity == 9.81)
        #expect(model.damping == 0.0)
        #expect(model.springConstant == 0.0)
        #expect(model.timeStep == 0.01)
        #expect(model.theta == 0.0)
        #expect(model.omega == 0.0)
        #expect(model.momentOfInertia == 1.0)
    }
    
    @Test func testCustomInitialization() async throws {
        let model = PendulumModel(
            mass: 2.0,
            length: 1.5,
            gravity: 10.0,
            damping: 0.1,
            springConstant: 0.5,
            timeStep: 0.02
        )
        
        #expect(model.mass == 2.0)
        #expect(model.length == 1.5)
        #expect(model.gravity == 10.0)
        #expect(model.damping == 0.1)
        #expect(model.springConstant == 0.5)
        #expect(model.timeStep == 0.02)
    }
    
    // MARK: - Parameter Update Tests
    
    @Test func testUpdateParameters() async throws {
        let model = PendulumModel()
        
        model.updateParameters(
            mass: 3.0,
            length: 2.0,
            gravity: 9.8,
            damping: 0.2,
            springConstant: 1.0,
            momentOfInertia: 2.0
        )
        
        #expect(model.mass == 3.0)
        #expect(model.length == 2.0)
        #expect(model.gravity == 9.8)
        #expect(model.damping == 0.2)
        #expect(model.springConstant == 1.0)
        #expect(model.momentOfInertia == 2.0)
    }
    
    // MARK: - State Reset Tests
    
    @Test func testReset() async throws {
        let model = PendulumModel()
        
        // Change state
        model.theta = 1.5
        model.omega = 2.0
        model.alpha = 0.5
        model.time = 10.0
        
        // Reset
        model.reset()
        
        #expect(model.theta == 0.0)
        #expect(model.omega == 0.0)
        #expect(model.alpha == 0.0)
        #expect(model.time == 0.0)
    }
    
    @Test func testResetWithInitialTheta() async throws {
        let model = PendulumModel()
        let initialTheta = Double.pi / 4
        
        model.reset(initialTheta: initialTheta)
        
        #expect(model.theta == initialTheta)
        #expect(model.omega == 0.0)
        #expect(model.alpha == 0.0)
        #expect(model.time == 0.0)
    }
    
    // MARK: - Physics Calculation Tests
    
    @Test func testStepCalculation() async throws {
        let model = PendulumModel()
        model.theta = Double.pi / 6 // 30 degrees
        
        let initialTheta = model.theta
        let initialOmega = model.omega
        
        model.step()
        
        // After one step, theta and omega should have changed
        #expect(model.theta != initialTheta)
        #expect(model.omega != initialOmega)
        #expect(model.time == model.timeStep)
    }
    
    @Test func testApplyForce() async throws {
        let model = PendulumModel()
        let initialOmega = model.omega
        let force = 5.0
        
        model.applyForce(force)
        
        // Force should change angular velocity
        #expect(model.omega != initialOmega)
        
        // The change should be proportional to force/momentOfInertia
        let expectedChange = force * model.timeStep / model.momentOfInertia
        #expect(abs(model.omega - initialOmega - expectedChange) < 0.0001)
    }
    
    @Test func testPendulumEnergy() async throws {
        let model = PendulumModel()
        model.theta = Double.pi / 4
        model.omega = 1.0
        
        // Kinetic energy = 0.5 * I * omega^2
        let kineticEnergy = 0.5 * model.momentOfInertia * model.omega * model.omega
        
        // Potential energy = m * g * L * (1 - cos(theta))
        let potentialEnergy = model.mass * model.gravity * model.length * (1 - cos(model.theta))
        
        let totalEnergy = kineticEnergy + potentialEnergy
        
        // Energy should be conserved (with no damping)
        model.damping = 0.0
        model.step()
        
        let newKE = 0.5 * model.momentOfInertia * model.omega * model.omega
        let newPE = model.mass * model.gravity * model.length * (1 - cos(model.theta))
        let newTotalEnergy = newKE + newPE
        
        // Energy should be approximately conserved (small numerical error is ok)
        #expect(abs(totalEnergy - newTotalEnergy) < 0.01)
    }
    
    // MARK: - Edge Case Tests
    
    @Test func testZeroGravity() async throws {
        let model = PendulumModel(gravity: 0.0)
        model.theta = Double.pi / 4
        
        let initialTheta = model.theta
        model.step()
        
        // With no gravity and no initial velocity, pendulum shouldn't move
        #expect(model.theta == initialTheta)
    }
    
    @Test func testHighDamping() async throws {
        let model = PendulumModel(damping: 10.0)
        model.theta = Double.pi / 4
        model.omega = 5.0
        
        // Step multiple times
        for _ in 0..<100 {
            model.step()
        }
        
        // With high damping, velocity should approach zero
        #expect(abs(model.omega) < 0.1)
    }
    
    @Test func testSpringForce() async throws {
        let model = PendulumModel(springConstant: 2.0)
        model.theta = Double.pi / 4
        
        let initialTheta = model.theta
        
        // Spring should pull pendulum back toward equilibrium
        model.step()
        
        #expect(abs(model.theta) < abs(initialTheta))
    }
}