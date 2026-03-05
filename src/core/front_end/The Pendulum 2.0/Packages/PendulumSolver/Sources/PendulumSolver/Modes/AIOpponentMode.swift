import Foundation

/// AI Opponent mode - competes against the player with adjustable difficulty
public class AIOpponentMode {

    // MARK: - Properties

    private let mpc: MPCController
    private let learning: AdaptiveLearningManager

    /// Current difficulty (0.0 = easy, 1.0 = impossible)
    public private(set) var difficulty: Double = 0.5

    /// Target player win rate for dynamic difficulty adjustment
    public var targetWinRate: Double = 0.5

    /// Human-like error simulation settings
    private var errorRate: Double = 0.1
    private var reactionDelay: Double = 0.05  // seconds
    private var noiseScale: Double = 0.1

    /// Previous control for smoothing
    private var previousControl: Double = 0

    // MARK: - Initialization

    public init(mpc: MPCController, learning: AdaptiveLearningManager) {
        self.mpc = mpc
        self.learning = learning
        setDifficulty(0.5)
    }

    // MARK: - Public Methods

    /// Set the difficulty level
    /// - Parameter difficulty: 0.0 (easy) to 1.0 (hard/impossible)
    public func setDifficulty(_ difficulty: Double) {
        self.difficulty = max(0, min(1, difficulty))

        // Adjust parameters based on difficulty
        // Lower difficulty = more errors, slower reactions, more noise
        errorRate = 0.3 * (1 - self.difficulty)      // 0-30% error rate
        reactionDelay = 0.1 * (1 - self.difficulty)  // 0-100ms delay
        noiseScale = 0.3 * (1 - self.difficulty)     // 0-30% noise
    }

    /// Compute control with difficulty-appropriate suboptimality
    /// - Parameter state: Current pendulum state
    /// - Returns: Control force (with intentional imperfections at lower difficulties)
    public func computeControl(state: HybridPendulumSolver.PendulumState) -> Double {
        // Get optimal control from MPC
        var optimalControl = mpc.solve(state: state)

        // Apply difficulty-based modifications

        // 1. Reaction delay simulation (skip updates occasionally)
        if Double.random(in: 0...1) < reactionDelay / 0.016 {
            // Use previous control instead of computing new one
            return previousControl
        }

        // 2. Wrong direction errors (at lower difficulties)
        if Double.random(in: 0...1) < errorRate * 0.3 {
            // Occasionally push the wrong way
            optimalControl = -optimalControl * Double.random(in: 0.3...0.7)
        }

        // 3. Magnitude errors
        if Double.random(in: 0...1) < errorRate {
            // Scale control by random factor
            optimalControl *= Double.random(in: 0.5...1.5)
        }

        // 4. Add noise proportional to (1 - difficulty)
        let noise = Double.random(in: -noiseScale...noiseScale)
        optimalControl += noise

        // 5. Limit control based on difficulty (lower = weaker max force)
        let effectiveMax = 0.3 + 0.7 * difficulty  // 30-100% of max force
        optimalControl = max(-effectiveMax, min(effectiveMax, optimalControl))

        // 6. Smooth rapid changes (human-like)
        let smoothing = 0.7 + 0.3 * difficulty  // More smoothing at low difficulty
        optimalControl = previousControl * (1 - smoothing) + optimalControl * smoothing

        previousControl = optimalControl
        return optimalControl
    }

    /// Update difficulty based on player performance
    /// - Parameter playerPerformance: Player's estimated skill (0-1)
    public func updateDifficulty(playerPerformance: Double) {
        // Dynamic difficulty adjustment to maintain target win rate
        // If player is winning easily, increase AI difficulty
        // If player is struggling, decrease AI difficulty

        let adjustment = (playerPerformance - targetWinRate) * 0.1
        difficulty = max(0, min(1, difficulty + adjustment))
        setDifficulty(difficulty)
    }
}
