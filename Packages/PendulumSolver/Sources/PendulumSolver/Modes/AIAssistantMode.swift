import Foundation

/// AI Assistant mode - helps struggling players with adaptive assistance
public class AIAssistantMode {

    // MARK: - Properties

    private let mpc: MPCController
    private let learning: AdaptiveLearningManager

    /// Current assistance level (0.0 = no help, 1.0 = full control)
    public private(set) var assistanceLevel: Double = 0.3

    /// Threshold for intervention
    public var criticalAngle: Double = 0.5       // ~28 degrees
    public var criticalVelocity: Double = 2.0    // rad/s

    /// Whether player currently needs help
    public private(set) var playerNeedsHelp: Bool = false

    /// Fade rate for reducing assistance over time
    public var assistanceFadeRate: Double = 0.01

    // MARK: - Initialization

    public init(mpc: MPCController, learning: AdaptiveLearningManager) {
        self.mpc = mpc
        self.learning = learning
    }

    // MARK: - Public Methods

    /// Set the assistance level
    /// - Parameter level: 0.0 (no assistance) to 1.0 (full control)
    public func setAssistanceLevel(_ level: Double) {
        assistanceLevel = max(0.1, min(1.0, level))
    }

    /// Compute assistance blended with player input
    /// - Parameters:
    ///   - state: Current pendulum state
    ///   - playerInput: Optional player control input
    /// - Returns: Blended control force
    public func computeAssistance(state: HybridPendulumSolver.PendulumState,
                                   playerInput: Double?) -> Double {
        let angleFromVertical = abs(state.angleFromVertical)
        let velocity = abs(state.thetaDot)

        // Determine if player needs help
        playerNeedsHelp = angleFromVertical > criticalAngle ||
                          velocity > criticalVelocity

        // If player is doing fine, return minimal or no assistance
        guard playerNeedsHelp else {
            // Maybe provide very subtle guidance
            let optimalControl = mpc.solve(state: state)
            return optimalControl * assistanceLevel * 0.1
        }

        // Compute optimal correction
        let optimalControl = mpc.solve(state: state)

        // Blend with player input
        if let playerInput = playerInput, abs(playerInput) > 0.01 {
            // Check if player is pushing in the right direction
            let sameDirection = (playerInput > 0) == (optimalControl > 0)

            if sameDirection {
                // Help player in their chosen direction
                // Amplify their input slightly
                let blended = playerInput + (optimalControl - playerInput) * assistanceLevel
                return blended
            } else {
                // Player is pushing wrong way - gentle correction
                // Don't fight them completely, but guide towards correct direction
                let correction = playerInput * (1 - assistanceLevel * 0.5) +
                                 optimalControl * assistanceLevel * 0.5
                return correction
            }
        }

        // No player input - provide full assistance scaled by level
        return optimalControl * assistanceLevel
    }

    /// Get a hint about what the player should do
    /// - Parameter state: Current pendulum state
    /// - Returns: Suggested direction and urgency
    public func getHint(state: HybridPendulumSolver.PendulumState) -> AssistanceHint {
        let optimalControl = mpc.solve(state: state)
        let angleFromVertical = abs(state.angleFromVertical)

        let direction: AssistanceHint.Direction
        if abs(optimalControl) < 0.05 {
            direction = .none
        } else if optimalControl > 0 {
            direction = .right
        } else {
            direction = .left
        }

        let urgency = min(angleFromVertical / criticalAngle, 1.0)

        return AssistanceHint(direction: direction, urgency: urgency)
    }

    /// Adapt assistance level based on player performance
    /// - Parameter metrics: Player performance metrics
    public func adaptAssistanceLevel(metrics: PlayerMetrics) {
        // Reduce assistance as player improves
        let skillEstimate = metrics.skillEstimate
        let newLevel = max(0.1, 0.5 - skillEstimate * 0.4)
        assistanceLevel = assistanceLevel * 0.9 + newLevel * 0.1  // Smooth transition
    }
}

// MARK: - Supporting Types

public struct AssistanceHint {
    public enum Direction {
        case left, right, none
    }

    public var direction: Direction
    public var urgency: Double  // 0.0 (low) to 1.0 (critical)
}
