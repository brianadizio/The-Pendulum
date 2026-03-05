import Foundation
import CoreML

/// Main interface for the Hybrid MPC + Learning Pendulum Solver
///
/// This solver combines physics-based Model Predictive Control (MPC) with
/// adaptive machine learning to provide optimal pendulum control across
/// three modes: AI Opponent, AI Assistant, and Tutorial.
///
/// Usage:
/// ```swift
/// let solver = HybridPendulumSolver()
/// solver.setMode(.opponent, difficulty: 0.7)
/// let control = solver.computeControl(theta: currentAngle, thetaDot: velocity)
/// ```
public class HybridPendulumSolver {

    // MARK: - Types

    /// Operating mode for the solver
    public enum Mode: String, CaseIterable {
        case opponent   // Compete against player
        case assistant  // Help struggling player
        case tutorial   // Teach player how to balance
        case demo       // Pure demonstration
    }

    /// Pendulum state representation
    public struct PendulumState {
        public var theta: Double      // Angle (radians), pi = upright
        public var thetaDot: Double   // Angular velocity (rad/s)
        public var time: Double       // Current time

        public init(theta: Double = .pi, thetaDot: Double = 0, time: Double = 0) {
            self.theta = theta
            self.thetaDot = thetaDot
            self.time = time
        }

        /// Angle deviation from upright position
        public var angleFromVertical: Double {
            var delta = theta - .pi
            // Wrap to [-pi, pi]
            while delta > .pi { delta -= 2 * .pi }
            while delta < -.pi { delta += 2 * .pi }
            return delta
        }

        /// Whether the pendulum is within balance threshold
        public func isBalanced(threshold: Double = 0.3) -> Bool {
            return abs(angleFromVertical) < threshold
        }
    }

    /// Physics configuration for the pendulum
    public struct PhysicsConfig {
        public var mass: Double = 1.0
        public var length: Double = 1.0
        public var gravity: Double = 9.81
        public var damping: Double = 0.3
        public var springConstant: Double = 0.1
        public var momentOfInertia: Double = 0.5
        public var forceScale: Double = 1.0

        public init() {}
    }

    /// MPC configuration
    public struct MPCConfig {
        public var horizonSteps: Int = 30
        public var dt: Double = 0.016
        public var qAngle: Double = 100.0
        public var qVelocity: Double = 10.0
        public var rControl: Double = 0.1
        public var uMax: Double = 1.0

        public init() {}
    }

    // MARK: - Properties

    /// Current operating mode
    public private(set) var currentMode: Mode = .demo

    /// Current difficulty level (0.0 = easy, 1.0 = hard)
    public private(set) var difficulty: Double = 0.5

    /// Physics configuration
    public var physicsConfig: PhysicsConfig

    /// MPC configuration
    public var mpcConfig: MPCConfig

    /// MPC controller
    private let mpcController: MPCController

    /// Learning manager for adaptive behavior
    private let learningManager: AdaptiveLearningManager

    /// Mode-specific handlers
    private var opponentMode: AIOpponentMode?
    private var assistantMode: AIAssistantMode?
    private var tutorialMode: TutorialMode?

    /// Data collector for training
    private let dataCollector: SolverDataCollector

    /// Performance statistics
    public private(set) var lastSolveTimeMs: Double = 0
    public private(set) var totalControlCalls: Int = 0

    // MARK: - Initialization

    public init(physicsConfig: PhysicsConfig = PhysicsConfig(),
                mpcConfig: MPCConfig = MPCConfig()) {
        self.physicsConfig = physicsConfig
        self.mpcConfig = mpcConfig

        // Initialize components
        self.mpcController = MPCController(physics: physicsConfig, mpc: mpcConfig)
        self.learningManager = AdaptiveLearningManager()
        self.dataCollector = SolverDataCollector()

        // Initialize mode handlers
        self.opponentMode = AIOpponentMode(mpc: mpcController, learning: learningManager)
        self.assistantMode = AIAssistantMode(mpc: mpcController, learning: learningManager)
        self.tutorialMode = TutorialMode(mpc: mpcController)
    }

    // MARK: - Public Interface

    /// Set the operating mode and difficulty
    /// - Parameters:
    ///   - mode: The mode to operate in
    ///   - difficulty: Difficulty level from 0.0 (easy) to 1.0 (hard)
    public func setMode(_ mode: Mode, difficulty: Double = 0.5) {
        self.currentMode = mode
        self.difficulty = max(0, min(1, difficulty))

        // Configure mode-specific settings
        switch mode {
        case .opponent:
            opponentMode?.setDifficulty(self.difficulty)
        case .assistant:
            assistantMode?.setAssistanceLevel(1.0 - self.difficulty)
        case .tutorial:
            tutorialMode?.reset()
        case .demo:
            break
        }
    }

    /// Compute the optimal control action for the current state
    /// - Parameters:
    ///   - theta: Current angle (radians), where pi is upright
    ///   - thetaDot: Current angular velocity (rad/s)
    ///   - playerInput: Optional player control input (for assistant mode)
    /// - Returns: Control force to apply
    public func computeControl(theta: Double, thetaDot: Double, playerInput: Double? = nil) -> Double {
        let state = PendulumState(theta: theta, thetaDot: thetaDot)
        return computeControl(state: state, playerInput: playerInput)
    }

    /// Compute the optimal control action for the current state
    /// - Parameters:
    ///   - state: Current pendulum state
    ///   - playerInput: Optional player control input
    /// - Returns: Control force to apply
    public func computeControl(state: PendulumState, playerInput: Double? = nil) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()

        let control: Double

        switch currentMode {
        case .opponent:
            control = opponentMode?.computeControl(state: state) ?? fallbackControl(state: state)
        case .assistant:
            control = assistantMode?.computeAssistance(state: state, playerInput: playerInput) ?? 0
        case .tutorial:
            control = tutorialMode?.computeControl(state: state) ?? fallbackControl(state: state)
        case .demo:
            control = mpcController.solve(state: state)
        }

        // Record statistics
        lastSolveTimeMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        totalControlCalls += 1

        // Collect data for learning
        dataCollector.record(
            state: state,
            control: control,
            playerInput: playerInput,
            mode: currentMode,
            solveTimeMs: lastSolveTimeMs
        )

        return control
    }

    /// Get a hint for the tutorial mode
    /// - Parameter state: Current pendulum state
    /// - Returns: Tutorial hint if available
    public func getTutorialHint(state: PendulumState) -> TutorialMode.Hint? {
        return tutorialMode?.getHint(state: state)
    }

    // MARK: - Tutorial Lesson API

    /// Current tutorial lesson (nil if not in tutorial mode)
    public var currentTutorialLesson: TutorialMode.Lesson? {
        guard currentMode == .tutorial else { return nil }
        return tutorialMode?.currentLesson
    }

    /// Current tutorial phase
    public var tutorialPhase: TutorialMode.Phase? {
        guard currentMode == .tutorial else { return nil }
        return tutorialMode?.currentPhase
    }

    /// Progress through current lesson (0.0–1.0)
    public var tutorialLessonProgress: Double {
        return tutorialMode?.lessonProgress ?? 0
    }

    /// Whether the current lesson's success criteria are met
    public var isTutorialLessonComplete: Bool {
        return tutorialMode?.isLessonComplete ?? false
    }

    /// Total lesson count
    public var tutorialLessonCount: Int {
        return tutorialMode?.lessons.count ?? 0
    }

    /// Current lesson index (0-based)
    public var tutorialLessonIndex: Int {
        return tutorialMode?.currentLessonIndex ?? 0
    }

    /// Advance to the next tutorial lesson
    public func advanceTutorialLesson() {
        tutorialMode?.advanceLesson()
    }

    /// Update tutorial timers (call every frame with dt)
    public func updateTutorial(dt: Double, isBalanced: Bool) {
        tutorialMode?.update(dt: dt)
        if isBalanced {
            tutorialMode?.recordBalanceTime(dt)
        }
    }

    /// Record that the player followed a tutorial hint
    public func recordTutorialHintFollowed() {
        tutorialMode?.recordHintFollowed()
    }

    /// Update the solver with player performance data for adaptive learning
    /// - Parameter metrics: Player performance metrics
    public func updateFromPlayerMetrics(_ metrics: PlayerMetrics) {
        learningManager.updateFromMetrics(metrics)

        // Adjust MPC weights based on learned parameters
        if let adjustedWeights = learningManager.getOptimalWeights() {
            mpcConfig.qAngle = adjustedWeights.qAngle
            mpcConfig.qVelocity = adjustedWeights.qVelocity
            mpcConfig.rControl = adjustedWeights.rControl
            mpcController.updateConfig(mpcConfig)
        }

        // Update opponent difficulty based on player skill
        if currentMode == .opponent {
            opponentMode?.updateDifficulty(playerPerformance: metrics.skillEstimate)
        }
    }

    /// Export collected data for training
    /// - Parameter url: File URL to export to
    public func exportTrainingData(to url: URL) throws {
        try dataCollector.export(to: url)
    }

    /// Train on-device models
    public func trainOnDevice() async throws {
        try await learningManager.trainOnDevice()
    }

    // MARK: - Private Methods

    private func fallbackControl(state: PendulumState) -> Double {
        // Simple PD controller as fallback
        let delta = state.angleFromVertical
        let kp = 10.0
        let kd = 3.0
        var u = -kp * delta - kd * state.thetaDot
        u = max(-mpcConfig.uMax, min(mpcConfig.uMax, u))
        return u
    }
}

// MARK: - Player Metrics

/// Metrics about player performance for adaptive learning
public struct PlayerMetrics {
    public var stabilityScore: Double      // 0-100
    public var averageReactionTime: Double // seconds
    public var forceEfficiency: Double     // 0-1
    public var overcorrectionRate: Double  // 0-1
    public var sessionDuration: Double     // seconds
    public var currentLevel: Int

    /// Estimated skill level (0-1)
    public var skillEstimate: Double {
        let normalized = stabilityScore / 100.0
        let reactionScore = max(0, 1 - averageReactionTime / 0.5) // Better if < 500ms
        return (normalized * 0.5 + forceEfficiency * 0.3 + reactionScore * 0.2)
    }

    public init(stabilityScore: Double = 50,
                averageReactionTime: Double = 0.3,
                forceEfficiency: Double = 0.5,
                overcorrectionRate: Double = 0.3,
                sessionDuration: Double = 0,
                currentLevel: Int = 1) {
        self.stabilityScore = stabilityScore
        self.averageReactionTime = averageReactionTime
        self.forceEfficiency = forceEfficiency
        self.overcorrectionRate = overcorrectionRate
        self.sessionDuration = sessionDuration
        self.currentLevel = currentLevel
    }
}
