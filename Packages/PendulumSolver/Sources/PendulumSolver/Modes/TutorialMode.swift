import Foundation

/// Tutorial mode - teaches players how to balance the pendulum
public class TutorialMode {

    // MARK: - Types

    public enum Phase: String, CaseIterable {
        case observation      // Watch AI balance
        case guidedPractice   // AI shows hints, player acts
        case assistedPractice // Player acts, AI helps
        case freePractice     // Player alone with feedback
    }

    public struct Hint {
        public var suggestedDirection: Direction
        public var urgency: Double  // 0-1
        public var explanation: String

        public enum Direction: String {
            case left = "left"
            case right = "right"
            case none = "steady"
        }
    }

    public struct Lesson {
        public var title: String
        public var description: String
        public var phase: Phase
        public var durationSeconds: Double
        public var successCriteria: String
    }

    // MARK: - Properties

    private let mpc: MPCController

    /// Current tutorial phase
    public private(set) var currentPhase: Phase = .observation

    /// Current lesson index
    public private(set) var currentLessonIndex: Int = 0

    /// Time spent in current phase
    public private(set) var phaseTime: Double = 0

    /// Predefined lessons
    public let lessons: [Lesson] = [
        Lesson(
            title: "Watch and Learn",
            description: "Watch how the AI keeps the pendulum balanced.",
            phase: .observation,
            durationSeconds: 10,
            successCriteria: "Watch for 10 seconds"
        ),
        Lesson(
            title: "Follow the Arrows",
            description: "Push in the direction shown by the arrows.",
            phase: .guidedPractice,
            durationSeconds: 30,
            successCriteria: "Follow 10 hints correctly"
        ),
        Lesson(
            title: "Training Wheels",
            description: "You're in control, but we'll help if needed.",
            phase: .assistedPractice,
            durationSeconds: 60,
            successCriteria: "Balance for 30 seconds total"
        ),
        Lesson(
            title: "Solo Flight",
            description: "You're on your own! Balance as long as you can.",
            phase: .freePractice,
            durationSeconds: 0,  // No time limit
            successCriteria: "Balance for 60 seconds"
        )
    ]

    /// Statistics for current lesson
    public private(set) var hintsFollowed: Int = 0
    public private(set) var totalBalanceTime: Double = 0

    // MARK: - Initialization

    public init(mpc: MPCController) {
        self.mpc = mpc
    }

    // MARK: - Public Methods

    /// Reset tutorial to beginning
    public func reset() {
        currentLessonIndex = 0
        currentPhase = .observation
        phaseTime = 0
        hintsFollowed = 0
        totalBalanceTime = 0
    }

    /// Advance to the next lesson
    public func advanceLesson() {
        if currentLessonIndex < lessons.count - 1 {
            currentLessonIndex += 1
            currentPhase = lessons[currentLessonIndex].phase
            phaseTime = 0
            hintsFollowed = 0
            totalBalanceTime = 0
        }
    }

    /// Update phase time
    /// - Parameter dt: Time step
    public func update(dt: Double) {
        phaseTime += dt
    }

    /// Compute control based on current phase
    /// - Parameter state: Current pendulum state
    /// - Returns: Control force
    public func computeControl(state: HybridPendulumSolver.PendulumState) -> Double {
        switch currentPhase {
        case .observation:
            // AI is in full control
            return mpc.solve(state: state)

        case .guidedPractice:
            // Minimal AI control, mostly showing hints
            let optimal = mpc.solve(state: state)
            // Only intervene if critical
            if abs(state.angleFromVertical) > 0.8 {
                return optimal * 0.5
            }
            return 0

        case .assistedPractice:
            // Moderate assistance
            let optimal = mpc.solve(state: state)
            // Help when player is struggling
            if abs(state.angleFromVertical) > 0.5 {
                return optimal * 0.3
            }
            return 0

        case .freePractice:
            // No AI control
            return 0
        }
    }

    /// Get hint for current state
    /// - Parameter state: Current pendulum state
    /// - Returns: Tutorial hint if appropriate for current phase
    public func getHint(state: HybridPendulumSolver.PendulumState) -> Hint? {
        // Only show hints in guided practice
        guard currentPhase == .guidedPractice || currentPhase == .assistedPractice else {
            return nil
        }

        let optimalControl = mpc.solve(state: state)
        let angle = state.angleFromVertical
        let velocity = state.thetaDot

        // Determine suggested direction
        // Note: positive control force pushes the pendulum leftward in the game's frame
        let direction: Hint.Direction
        if abs(optimalControl) < 0.05 {
            direction = .none
        } else if optimalControl > 0 {
            direction = .left
        } else {
            direction = .right
        }

        // Calculate urgency
        let urgency = min(abs(angle) / 0.5, 1.0)

        // Generate explanation
        let explanation = generateExplanation(angle: angle, velocity: velocity, control: optimalControl)

        return Hint(
            suggestedDirection: direction,
            urgency: urgency,
            explanation: explanation
        )
    }

    /// Record that player followed a hint
    public func recordHintFollowed() {
        hintsFollowed += 1
    }

    /// Record balance time
    /// - Parameter dt: Time step while balanced
    public func recordBalanceTime(_ dt: Double) {
        totalBalanceTime += dt
    }

    /// Get current lesson
    public var currentLesson: Lesson {
        return lessons[currentLessonIndex]
    }

    /// Check if current lesson is complete
    public var isLessonComplete: Bool {
        let lesson = currentLesson

        switch lesson.phase {
        case .observation:
            return phaseTime >= lesson.durationSeconds

        case .guidedPractice:
            return hintsFollowed >= 10

        case .assistedPractice:
            return totalBalanceTime >= 30

        case .freePractice:
            return totalBalanceTime >= 60
        }
    }

    /// Get progress in current lesson (0-1)
    public var lessonProgress: Double {
        let lesson = currentLesson

        switch lesson.phase {
        case .observation:
            return min(phaseTime / lesson.durationSeconds, 1.0)

        case .guidedPractice:
            return min(Double(hintsFollowed) / 10.0, 1.0)

        case .assistedPractice:
            return min(totalBalanceTime / 30.0, 1.0)

        case .freePractice:
            return min(totalBalanceTime / 60.0, 1.0)
        }
    }

    // MARK: - Private Methods

    private func generateExplanation(angle: Double, velocity: Double, control: Double) -> String {
        let angleDeg = abs(angle) * 180 / .pi

        if angleDeg > 30 {
            let dir = control > 0 ? "left" : "right"
            return "Quick! Push \(dir) to catch it!"
        } else if angleDeg > 15 {
            let dir = control > 0 ? "left" : "right"
            return "The pendulum is tilting. Push \(dir) to correct."
        } else if abs(velocity) > 1.5 {
            return "It's moving fast! Watch where it's going."
        } else if angleDeg > 5 {
            return "Small adjustment needed."
        } else {
            return "Great job! Keep it steady."
        }
    }
}
