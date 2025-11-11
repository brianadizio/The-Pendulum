import Testing
@testable import The_Pendulum
import Foundation
import SpriteKit

// Mock PendulumViewModel for testing
class MockPendulumViewModel: PendulumViewModel {
    var appliedForces: [Double] = []
    
    override func applyForce(_ force: Double) {
        appliedForces.append(force)
        super.applyForce(force)
    }
}

// Mock PendulumScene for testing
class MockPendulumScene: PendulumScene {
    var addedChildren: [SKNode] = []
    
    override func addChild(_ node: SKNode) {
        addedChildren.append(node)
        super.addChild(node)
    }
}

@Suite("PerturbationManager Tests")
struct PerturbationManagerTests {
    
    @Test func testInitialization() async throws {
        let manager = PerturbationManager()
        #expect(manager.activeProfile == nil)
    }
    
    @Test func testInitializationWithProfile() async throws {
        let profile = PerturbationProfile.forLevel(1)
        let manager = PerturbationManager(profile: profile)
        
        #expect(manager.activeProfile != nil)
        #expect(manager.activeProfile?.name == profile.name)
    }
    
    @Test func testActivateProfile() async throws {
        let manager = PerturbationManager()
        let profile = PerturbationProfile.forLevel(2)
        
        manager.activateProfile(profile)
        
        #expect(manager.activeProfile?.name == profile.name)
        #expect(manager.activeProfile?.strength == profile.strength)
    }
    
    @Test func testStopAndResume() async throws {
        let manager = PerturbationManager()
        let profile = PerturbationProfile.forLevel(1)
        manager.activateProfile(profile)
        
        // Test stop
        manager.stop()
        
        // Test resume
        manager.resume()
        
        // Manager should still have its profile after stop/resume
        #expect(manager.activeProfile != nil)
    }
    
    @Test func testPerturbationProfileForLevel() async throws {
        // Test level 1
        let level1 = PerturbationProfile.forLevel(1)
        #expect(level1.name == "Gentle Breeze")
        #expect(level1.types == [.impulse])
        #expect(level1.strength == 0.3)
        #expect(level1.showWarnings == true)
        
        // Test level 5
        let level5 = PerturbationProfile.forLevel(5)
        #expect(level5.name == "Stormy Waters")
        #expect(level5.types == [.sine, .impulse])
        #expect(level5.strength == 0.8)
        #expect(level5.frequency == 0.4)
        
        // Test level 7
        let level7 = PerturbationProfile.forLevel(7)
        #expect(level7.name == "Chaotic Turbulence")
        #expect(level7.types == [.random])
        
        // Test compound level (8-10)
        let level9 = PerturbationProfile.forLevel(9)
        #expect(level9.name == "Perfect Storm")
        #expect(level9.types == [.compound])
        #expect(level9.subProfiles != nil)
        #expect(level9.subProfiles?.count == 3)
        
        // Test procedural level (>10)
        let level15 = PerturbationProfile.forLevel(15)
        #expect(level15.name.contains("Extreme Challenge"))
        #expect(level15.types == [.compound])
        #expect(level15.subProfiles?.count == 4)
    }
    
    @Test func testPerturbationProfileForMode() async throws {
        // Test mode 1
        let mode1 = PerturbationProfile.forMode(1)
        #expect(mode1.name == "Joshua Tree")
        #expect(mode1.types == [.sine, .random])
        
        // Test mode 2
        let mode2 = PerturbationProfile.forMode(2)
        #expect(mode2.name == "Zero-G Space")
        #expect(mode2.types == [.impulse, .random])
        
        // Test default mode
        let modeDefault = PerturbationProfile.forMode(99)
        #expect(modeDefault.name == "Experiment")
        #expect(modeDefault.types == [.dataSet])
    }
    
    @Test func testUpdateWithSinePerturbation() async throws {
        let manager = PerturbationManager()
        let viewModel = MockPendulumViewModel()
        manager.viewModel = viewModel
        
        let profile = PerturbationProfile(
            name: "Test Sine",
            types: [.sine],
            strength: 1.0,
            frequency: 1.0, // 1 Hz for easy calculation
            randomInterval: 0...0,
            dataSource: nil,
            showWarnings: false
        )
        manager.activateProfile(profile)
        
        // Update at t=0
        manager.update(currentTime: 0.0)
        #expect(viewModel.appliedForces.isEmpty) // No force at t=0
        
        // Update at t=0.25 (quarter period)
        manager.update(currentTime: 0.25)
        #expect(viewModel.appliedForces.count == 1)
        // At quarter period, sin(π/2) = 1, multiplied by strength * 0.225
        let expectedForce = 1.0 * 1.0 * 0.225
        #expect(abs(viewModel.appliedForces[0] - expectedForce) < 0.01)
    }
    
    @Test func testUpdateWithRandomPerturbation() async throws {
        let manager = PerturbationManager()
        let viewModel = MockPendulumViewModel()
        manager.viewModel = viewModel
        
        let profile = PerturbationProfile(
            name: "Test Random",
            types: [.random],
            strength: 1.0,
            frequency: 0.0,
            randomInterval: 0...0,
            dataSource: nil,
            showWarnings: false
        )
        manager.activateProfile(profile)
        
        // Update multiple times
        for i in 1...5 {
            manager.update(currentTime: Double(i) * 0.1)
        }
        
        // Should have applied 5 forces
        #expect(viewModel.appliedForces.count == 5)
        
        // All forces should be within expected range
        for force in viewModel.appliedForces {
            #expect(abs(force) <= 0.1) // Random * strength * 0.1
        }
    }
    
    @Test func testUpdateWithInactiveManager() async throws {
        let manager = PerturbationManager()
        let viewModel = MockPendulumViewModel()
        manager.viewModel = viewModel
        
        let profile = PerturbationProfile.forLevel(1)
        manager.activateProfile(profile)
        
        // Stop the manager
        manager.stop()
        
        // Update should not apply forces
        manager.update(currentTime: 1.0)
        #expect(viewModel.appliedForces.isEmpty)
    }
    
    @Test func testNotificationHandling() async throws {
        let manager = PerturbationManager()
        let profile = PerturbationProfile.forLevel(1)
        manager.activateProfile(profile)
        
        // Send stop notification
        NotificationCenter.default.post(
            name: NSNotification.Name("StopAllPerturbations"),
            object: nil
        )
        
        // Give notification time to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Manager should be stopped (we can't directly test isActive, but we can test behavior)
        let viewModel = MockPendulumViewModel()
        manager.viewModel = viewModel
        manager.update(currentTime: 1.0)
        #expect(viewModel.appliedForces.isEmpty)
        
        // Send resume notification
        NotificationCenter.default.post(
            name: NSNotification.Name("ResumeAllPerturbations"),
            object: nil
        )
        
        // Give notification time to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }
    
    @Test func testGenerateVisualEffect() async throws {
        let manager = PerturbationManager()
        let scene = MockPendulumScene()
        scene.size = CGSize(width: 768, height: 1024)
        manager.scene = scene
        
        // Test small magnitude effect
        manager.generateVisualEffect(magnitude: 0.3)
        
        // Should have added a particle node
        #expect(scene.addedChildren.count >= 1)
        
        // Test large magnitude effect (should add screen shake)
        scene.addedChildren.removeAll()
        manager.generateVisualEffect(magnitude: 0.8)
        
        // Should have added a particle node
        #expect(scene.addedChildren.count >= 1)
    }
    
    @Test func testCompoundPerturbationProfile() async throws {
        let profile = PerturbationProfile.forLevel(10)
        
        #expect(profile.types == [.compound])
        #expect(profile.subProfiles != nil)
        
        let subProfiles = profile.subProfiles!
        #expect(subProfiles.count == 3)
        
        // Check sub-profile types
        let types = subProfiles.flatMap { $0.types }
        #expect(types.contains(.sine))
        #expect(types.contains(.impulse))
        #expect(types.contains(.random))
    }
    
    @Test func testProceduralLevelGeneration() async throws {
        // Test procedural levels have reasonable parameters
        let levels = [15, 25, 50, 100]
        
        for level in levels {
            let profile = PerturbationProfile.forLevel(level)
            
            #expect(profile.name.contains("Extreme Challenge"))
            #expect(profile.types == [.compound])
            #expect(profile.subProfiles != nil)
            #expect(profile.subProfiles!.count == 4)
            
            // Check strength is capped
            #expect(profile.strength <= 2.0)
            
            // Check frequency is capped
            #expect(profile.frequency <= 1.0)
            
            // Check interval bounds
            #expect(profile.randomInterval.lowerBound >= 0.5)
        }
    }
    
    @Test func testDataSetPerturbation() async throws {
        let manager = PerturbationManager()
        let viewModel = MockPendulumViewModel()
        manager.viewModel = viewModel
        
        // Note: This test will fail if PerturbationData.csv doesn't exist
        // For unit testing, we're testing the logic flow
        let profile = PerturbationProfile(
            name: "Test DataSet",
            types: [.dataSet],
            strength: 1.0,
            frequency: 0.0,
            randomInterval: 0...0,
            dataSource: "TestData.csv", // This file probably doesn't exist
            showWarnings: false
        )
        manager.activateProfile(profile)
        
        // Update - should handle missing file gracefully
        manager.update(currentTime: 1.0)
        
        // No forces should be applied if data file is missing
        #expect(viewModel.appliedForces.isEmpty)
    }
    
    @Test func testImpulsePerturbationTiming() async throws {
        let manager = PerturbationManager()
        let viewModel = MockPendulumViewModel()
        manager.viewModel = viewModel
        
        let profile = PerturbationProfile(
            name: "Test Impulse",
            types: [.impulse],
            strength: 1.0,
            frequency: 0.0,
            randomInterval: 0.5...1.0, // Very short for testing
            dataSource: nil,
            showWarnings: false
        )
        manager.activateProfile(profile)
        
        // Update for 2 seconds with small time steps
        var currentTime = 0.0
        let timeStep = 0.1
        
        for _ in 0..<20 {
            manager.update(currentTime: currentTime)
            currentTime += timeStep
        }
        
        // Should have applied at least one impulse in 2 seconds
        #expect(!viewModel.appliedForces.isEmpty)
        
        // All impulses should be within expected range
        for force in viewModel.appliedForces {
            #expect(abs(force) >= 0.8)  // At least 0.8 * strength
            #expect(abs(force) <= 1.2)  // At most 1.2 * strength
        }
    }
}