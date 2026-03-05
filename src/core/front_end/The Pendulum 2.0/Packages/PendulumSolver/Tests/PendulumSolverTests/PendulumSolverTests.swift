import XCTest
@testable import PendulumSolver

final class PendulumSolverTests: XCTestCase {

    // MARK: - MPC Controller Tests

    func testMPCControllerInitialization() {
        let physics = HybridPendulumSolver.PhysicsConfig()
        let mpc = HybridPendulumSolver.MPCConfig()

        let controller = MPCController(physics: physics, mpc: mpc)
        XCTAssertNotNil(controller)
    }

    func testMPCControllerSolve() {
        let physics = HybridPendulumSolver.PhysicsConfig()
        let mpc = HybridPendulumSolver.MPCConfig()
        let controller = MPCController(physics: physics, mpc: mpc)

        // Test with pendulum slightly off vertical
        let state = HybridPendulumSolver.PendulumState(theta: .pi + 0.1, thetaDot: 0)
        let control = controller.solve(state: state)

        // Control should be negative (push left to correct right lean)
        XCTAssertLessThan(control, 0, "Control should push to correct angle")
        XCTAssertGreaterThanOrEqual(control, -mpc.uMax, "Control should respect constraints")
    }

    func testMPCControllerSymmetry() {
        let physics = HybridPendulumSolver.PhysicsConfig()
        let mpc = HybridPendulumSolver.MPCConfig()
        let controller = MPCController(physics: physics, mpc: mpc)

        let statePositive = HybridPendulumSolver.PendulumState(theta: .pi + 0.1, thetaDot: 0)
        let stateNegative = HybridPendulumSolver.PendulumState(theta: .pi - 0.1, thetaDot: 0)

        let controlPositive = controller.solve(state: statePositive)
        let controlNegative = controller.solve(state: stateNegative)

        // Control should be symmetric
        XCTAssertEqual(controlPositive, -controlNegative, accuracy: 0.01, "Control should be symmetric")
    }

    // MARK: - Hybrid Solver Tests

    func testHybridSolverInitialization() {
        let solver = HybridPendulumSolver()
        XCTAssertNotNil(solver)
        XCTAssertEqual(solver.currentMode, .demo)
    }

    func testHybridSolverModeChange() {
        let solver = HybridPendulumSolver()

        solver.setMode(.opponent, difficulty: 0.7)
        XCTAssertEqual(solver.currentMode, .opponent)
        XCTAssertEqual(solver.difficulty, 0.7, accuracy: 0.01)

        solver.setMode(.assistant, difficulty: 0.3)
        XCTAssertEqual(solver.currentMode, .assistant)
        XCTAssertEqual(solver.difficulty, 0.3, accuracy: 0.01)
    }

    func testHybridSolverDifficultyBounds() {
        let solver = HybridPendulumSolver()

        solver.setMode(.opponent, difficulty: 1.5)  // Above max
        XCTAssertEqual(solver.difficulty, 1.0, accuracy: 0.01)

        solver.setMode(.opponent, difficulty: -0.5)  // Below min
        XCTAssertEqual(solver.difficulty, 0.0, accuracy: 0.01)
    }

    func testHybridSolverComputeControl() {
        let solver = HybridPendulumSolver()
        solver.setMode(.demo)

        let control = solver.computeControl(theta: .pi + 0.1, thetaDot: 0)

        // Should return non-zero control for off-balance state
        XCTAssertNotEqual(control, 0, accuracy: 0.001, "Should provide correction")
    }

    // MARK: - State Tests

    func testPendulumStateAngleFromVertical() {
        let state1 = HybridPendulumSolver.PendulumState(theta: .pi, thetaDot: 0)
        XCTAssertEqual(state1.angleFromVertical, 0, accuracy: 0.001, "Upright should be 0")

        let state2 = HybridPendulumSolver.PendulumState(theta: .pi + 0.5, thetaDot: 0)
        XCTAssertEqual(state2.angleFromVertical, 0.5, accuracy: 0.001)

        let state3 = HybridPendulumSolver.PendulumState(theta: .pi - 0.5, thetaDot: 0)
        XCTAssertEqual(state3.angleFromVertical, -0.5, accuracy: 0.001)
    }

    func testPendulumStateIsBalanced() {
        let balanced = HybridPendulumSolver.PendulumState(theta: .pi + 0.1, thetaDot: 0)
        XCTAssertTrue(balanced.isBalanced(threshold: 0.3))

        let unbalanced = HybridPendulumSolver.PendulumState(theta: .pi + 0.5, thetaDot: 0)
        XCTAssertFalse(unbalanced.isBalanced(threshold: 0.3))
    }

    // MARK: - Mode Tests

    func testAIOpponentMode() {
        let physics = HybridPendulumSolver.PhysicsConfig()
        let mpc = HybridPendulumSolver.MPCConfig()
        let controller = MPCController(physics: physics, mpc: mpc)
        let learning = AdaptiveLearningManager()

        let opponent = AIOpponentMode(mpc: controller, learning: learning)

        // At difficulty 0, should have high error rate
        opponent.setDifficulty(0.0)
        let state = HybridPendulumSolver.PendulumState(theta: .pi + 0.2, thetaDot: 0)

        var controls: [Double] = []
        for _ in 0..<10 {
            controls.append(opponent.computeControl(state: state))
        }

        // At low difficulty, controls should vary (noise)
        let variance = controls.map { ($0 - controls.reduce(0, +) / 10) * ($0 - controls.reduce(0, +) / 10) }.reduce(0, +) / 10
        XCTAssertGreaterThan(variance, 0, "Low difficulty should have variance")
    }

    func testAIAssistantMode() {
        let physics = HybridPendulumSolver.PhysicsConfig()
        let mpc = HybridPendulumSolver.MPCConfig()
        let controller = MPCController(physics: physics, mpc: mpc)
        let learning = AdaptiveLearningManager()

        let assistant = AIAssistantMode(mpc: controller, learning: learning)

        // When player needs help (large angle)
        let criticalState = HybridPendulumSolver.PendulumState(theta: .pi + 0.6, thetaDot: 0)
        let assistance = assistant.computeAssistance(state: criticalState, playerInput: nil)

        XCTAssertNotEqual(assistance, 0, "Should provide assistance when needed")
        XCTAssertTrue(assistant.playerNeedsHelp, "Should detect player needs help")
    }

    func testTutorialMode() {
        let physics = HybridPendulumSolver.PhysicsConfig()
        let mpc = HybridPendulumSolver.MPCConfig()
        let controller = MPCController(physics: physics, mpc: mpc)

        let tutorial = TutorialMode(mpc: controller)

        XCTAssertEqual(tutorial.currentPhase, .observation)
        XCTAssertEqual(tutorial.currentLessonIndex, 0)

        tutorial.advanceLesson()
        XCTAssertEqual(tutorial.currentPhase, .guidedPractice)
    }

    // MARK: - Data Collection Tests

    func testDataCollector() {
        let collector = SolverDataCollector()

        let state = HybridPendulumSolver.PendulumState(theta: .pi + 0.1, thetaDot: 0.5)

        collector.record(
            state: state,
            control: 0.3,
            playerInput: nil,
            mode: .demo,
            solveTimeMs: 2.5
        )

        XCTAssertEqual(collector.recordCount, 1)
    }

    // MARK: - Learning Tests

    func testAdaptiveLearningManager() {
        let manager = AdaptiveLearningManager()

        let metrics = PlayerMetrics(
            stabilityScore: 60,
            averageReactionTime: 0.25,
            forceEfficiency: 0.7,
            overcorrectionRate: 0.2,
            sessionDuration: 120,
            currentLevel: 3
        )

        manager.updateFromMetrics(metrics)

        let weights = manager.getOptimalWeights()
        XCTAssertNotNil(weights)

        let style = manager.getPlayerStyle()
        XCTAssertNotNil(style)
    }

    func testPlayerMetricsSkillEstimate() {
        let goodPlayer = PlayerMetrics(
            stabilityScore: 90,
            averageReactionTime: 0.15,
            forceEfficiency: 0.9,
            overcorrectionRate: 0.1
        )

        let badPlayer = PlayerMetrics(
            stabilityScore: 30,
            averageReactionTime: 0.5,
            forceEfficiency: 0.3,
            overcorrectionRate: 0.6
        )

        XCTAssertGreaterThan(goodPlayer.skillEstimate, badPlayer.skillEstimate)
    }

    // MARK: - Performance Tests

    func testMPCSolvePerformance() {
        let solver = HybridPendulumSolver()
        solver.setMode(.demo)

        let state = HybridPendulumSolver.PendulumState(theta: .pi + 0.1, thetaDot: 0.2)

        measure {
            for _ in 0..<100 {
                _ = solver.computeControl(state: state)
            }
        }

        // Check last solve time is reasonable
        XCTAssertLessThan(solver.lastSolveTimeMs, 5.0, "Solve time should be under 5ms")
    }
}
