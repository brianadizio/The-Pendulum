import Testing
@testable import The_Pendulum
import Foundation

// Mock delegate for testing
class MockLevelProgressionDelegate: LevelProgressionDelegate {
    var didCompleteLevelCalled = false
    var didStartNewLevelCalled = false
    var updateDifficultyParametersCalled = false
    
    var completedLevel: Int?
    var completedLevelConfig: LevelConfig?
    var startedLevel: Int?
    var startedLevelConfig: LevelConfig?
    var updatedConfig: LevelConfig?
    
    func didCompleteLevel(_ level: Int, config: LevelConfig) {
        didCompleteLevelCalled = true
        completedLevel = level
        completedLevelConfig = config
    }
    
    func didStartNewLevel(_ level: Int, config: LevelConfig) {
        didStartNewLevelCalled = true
        startedLevel = level
        startedLevelConfig = config
    }
    
    func updateDifficultyParameters(config: LevelConfig) {
        updateDifficultyParametersCalled = true
        updatedConfig = config
    }
}

@Suite("LevelManager Tests")
struct LevelManagerTests {
    
    @Test func testInitialization() async throws {
        // Clear UserDefaults for clean test
        UserDefaults.standard.removeObject(forKey: "PendulumMaxLevel")
        
        let manager = LevelManager()
        
        #expect(manager.currentLevel == 1)
        #expect(manager.maxReachedLevel == 1)
    }
    
    @Test func testInitializationWithSavedMaxLevel() async throws {
        // Set a saved max level
        UserDefaults.standard.set(5, forKey: "PendulumMaxLevel")
        
        let manager = LevelManager()
        
        #expect(manager.currentLevel == 1)
        #expect(manager.maxReachedLevel == 5)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "PendulumMaxLevel")
    }
    
    @Test func testSetLevel() async throws {
        let manager = LevelManager()
        let delegate = MockLevelProgressionDelegate()
        manager.delegate = delegate
        
        manager.setLevel(3)
        
        #expect(manager.currentLevel == 3)
        #expect(delegate.didStartNewLevelCalled)
        #expect(delegate.startedLevel == 3)
        #expect(delegate.updateDifficultyParametersCalled)
        #expect(delegate.updatedConfig != nil)
    }
    
    @Test func testSetLevelUpdatesMaxLevel() async throws {
        UserDefaults.standard.removeObject(forKey: "PendulumMaxLevel")
        
        let manager = LevelManager()
        #expect(manager.maxReachedLevel == 1)
        
        manager.setLevel(5)
        
        #expect(manager.currentLevel == 5)
        #expect(manager.maxReachedLevel == 5)
        
        // Verify it was saved
        let savedMaxLevel = UserDefaults.standard.integer(forKey: "PendulumMaxLevel")
        #expect(savedMaxLevel == 5)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "PendulumMaxLevel")
    }
    
    @Test func testSetLevelDoesNotDowngradeMaxLevel() async throws {
        let manager = LevelManager()
        manager.setLevel(10)
        #expect(manager.maxReachedLevel == 10)
        
        // Going back to a lower level shouldn't reduce max level
        manager.setLevel(5)
        #expect(manager.currentLevel == 5)
        #expect(manager.maxReachedLevel == 10)
    }
    
    @Test func testAdvanceToNextLevel() async throws {
        let manager = LevelManager()
        let delegate = MockLevelProgressionDelegate()
        manager.delegate = delegate
        
        manager.setLevel(3)
        delegate.didCompleteLevelCalled = false // Reset
        
        manager.advanceToNextLevel()
        
        #expect(manager.currentLevel == 4)
        #expect(delegate.didCompleteLevelCalled)
        #expect(delegate.completedLevel == 3)
        #expect(delegate.didStartNewLevelCalled)
        #expect(delegate.startedLevel == 4)
    }
    
    @Test func testResetToLevel1() async throws {
        let manager = LevelManager()
        manager.setLevel(5)
        
        manager.resetToLevel1()
        
        #expect(manager.currentLevel == 1)
        // Max level should remain unchanged
        #expect(manager.maxReachedLevel == 5)
    }
    
    @Test func testGetConfigForPredefinedLevels() async throws {
        let manager = LevelManager()
        
        // Test level 1
        let level1Config = manager.getConfigForLevel(1)
        #expect(level1Config.number == 1)
        #expect(level1Config.balanceThreshold == LevelManager.baseBalanceThreshold)
        #expect(level1Config.massMultiplier == 1.0)
        #expect(level1Config.description == "Beginner - Just get upright briefly")
        
        // Test level 5
        let level5Config = manager.getConfigForLevel(5)
        #expect(level5Config.number == 5)
        #expect(level5Config.balanceThreshold < LevelManager.baseBalanceThreshold)
        #expect(level5Config.massMultiplier > 1.0)
        #expect(level5Config.balanceRequiredTime > LevelManager.baseBalanceRequiredTime)
        
        // Test level 10
        let level10Config = manager.getConfigForLevel(10)
        #expect(level10Config.number == 10)
        #expect(level10Config.description == "Perfect Balance - Mastery achieved")
    }
    
    @Test func testGetConfigForProceduralLevels() async throws {
        let manager = LevelManager()
        
        // Test level 11 (first procedural level)
        let level11Config = manager.getConfigForLevel(11)
        #expect(level11Config.number == 11)
        #expect(level11Config.description.contains("Elite"))
        
        // Test level 20
        let level20Config = manager.getConfigForLevel(20)
        #expect(level20Config.number == 20)
        #expect(level20Config.balanceThreshold < level11Config.balanceThreshold)
        #expect(level20Config.balanceRequiredTime > level11Config.balanceRequiredTime)
        
        // Test level 50 (should be capped)
        let level50Config = manager.getConfigForLevel(50)
        #expect(level50Config.number == 50)
        #expect(level50Config.description.contains("Legendary"))
    }
    
    @Test func testBalanceThresholdDegrees() async throws {
        let config = LevelConfig(
            number: 1,
            balanceThreshold: Double.pi / 4, // 45 degrees in radians
            balanceRequiredTime: 1.0,
            initialPerturbation: 10.0,
            massMultiplier: 1.0,
            lengthMultiplier: 1.0,
            dampingValue: 0.4,
            gravityMultiplier: 1.0,
            springConstantValue: 0.2,
            description: "Test"
        )
        
        let degrees = config.balanceThresholdDegrees
        #expect(abs(degrees - 45.0) < 0.01)
    }
    
    @Test func testLevelProgressionDifficulty() async throws {
        let manager = LevelManager()
        
        // Get configs for several levels
        let configs = (1...15).map { manager.getConfigForLevel($0) }
        
        // Verify that difficulty generally increases
        for i in 1..<configs.count {
            let prev = configs[i-1]
            let curr = configs[i]
            
            // Balance threshold should decrease (harder to balance)
            #expect(curr.balanceThreshold <= prev.balanceThreshold)
            
            // Balance time should increase (need to balance longer)
            #expect(curr.balanceRequiredTime >= prev.balanceRequiredTime)
            
            // Mass should generally increase
            #expect(curr.massMultiplier >= prev.massMultiplier)
            
            // Damping should decrease (less stable)
            #expect(curr.dampingValue <= prev.dampingValue)
        }
    }
    
    @Test func testProceduralLevelCapping() async throws {
        let manager = LevelManager()
        
        // Test that procedural levels have reasonable caps
        let level100Config = manager.getConfigForLevel(100)
        
        // Balance time should be capped at 8 seconds
        #expect(level100Config.balanceRequiredTime <= 8.0)
        
        // Perturbation should be capped at 2x base
        #expect(level100Config.initialPerturbation <= LevelManager.basePerturbation * 2.0)
        
        // Damping should maintain minimum playability
        #expect(level100Config.dampingValue >= 0.2)
        
        // Spring constant should maintain minimum
        #expect(level100Config.springConstantValue >= 0.05)
    }
    
    @Test func testInvalidLevelHandling() async throws {
        let manager = LevelManager()
        
        // Test zero level
        manager.setLevel(0)
        #expect(manager.currentLevel == 1) // Should remain at 1
        
        // Test negative level
        manager.setLevel(-5)
        #expect(manager.currentLevel == 1) // Should remain at 1
    }
    
    @Test func testDelegateNotifications() async throws {
        let manager = LevelManager()
        let delegate = MockLevelProgressionDelegate()
        manager.delegate = delegate
        
        // Test level change notifications
        manager.setLevel(2)
        #expect(delegate.didStartNewLevelCalled)
        #expect(delegate.updateDifficultyParametersCalled)
        #expect(delegate.startedLevel == 2)
        #expect(delegate.updatedConfig?.number == 2)
        
        // Reset flags
        delegate.didCompleteLevelCalled = false
        delegate.didStartNewLevelCalled = false
        
        // Test advance level notifications
        manager.advanceToNextLevel()
        #expect(delegate.didCompleteLevelCalled)
        #expect(delegate.completedLevel == 2)
        #expect(delegate.didStartNewLevelCalled)
        #expect(delegate.startedLevel == 3)
    }
    
    @Test func testWeakDelegate() async throws {
        let manager = LevelManager()
        var delegate: MockLevelProgressionDelegate? = MockLevelProgressionDelegate()
        
        manager.delegate = delegate
        #expect(manager.delegate != nil)
        
        // Release the delegate
        delegate = nil
        
        // Delegate should be nil (weak reference)
        #expect(manager.delegate == nil)
        
        // Should not crash when calling delegate methods
        manager.setLevel(2)
    }
}