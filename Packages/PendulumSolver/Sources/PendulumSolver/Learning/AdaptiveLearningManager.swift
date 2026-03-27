import Foundation
import CoreML

/// Manages adaptive learning components for the pendulum solver
///
/// Handles:
/// - Loading and using pre-trained Core ML models
/// - On-device training with collected gameplay data
/// - Adapting MPC weights based on player behavior
public class AdaptiveLearningManager {

    // MARK: - Types

    public struct OptimalWeights {
        public var qAngle: Double
        public var qVelocity: Double
        public var rControl: Double
    }

    public enum PlayerStyle: String, CaseIterable {
        case aggressive   // Quick, strong movements
        case cautious     // Slow, gentle corrections
        case balanced     // Mix of approaches
        case erratic      // Unpredictable
    }

    // MARK: - Properties

    /// Gains optimizer model (Core ML)
    private var gainsModel: MLModel?

    /// Player style classifier (Core ML)
    private var styleModel: MLModel?

    /// Collected training samples
    private var trainingSamples: [TrainingSample] = []

    /// Minimum samples before training
    public var minTrainingSamples: Int = 100

    /// Current estimated player style
    public private(set) var currentPlayerStyle: PlayerStyle = .balanced

    /// Current optimal weights (updated by learning)
    private var currentWeights: OptimalWeights

    /// Last player metrics for inference
    private var lastMetrics: PlayerMetrics?

    // MARK: - Initialization

    public init() {
        // Default weights (will be updated by learning)
        currentWeights = OptimalWeights(
            qAngle: 100.0,
            qVelocity: 10.0,
            rControl: 0.1
        )

        // Try to load pre-trained models
        loadModels()
    }

    // MARK: - Public Methods

    /// Update learning from player performance metrics
    /// - Parameter metrics: Player's performance metrics
    public func updateFromMetrics(_ metrics: PlayerMetrics) {
        lastMetrics = metrics

        // Classify player style
        classifyPlayerStyle(metrics)

        // Add training sample
        addTrainingSample(metrics)

        // If using Core ML model, get optimal weights
        if gainsModel != nil {
            inferOptimalWeights(from: metrics)
        } else {
            // Fallback: heuristic-based adaptation
            adaptWeightsHeuristically(metrics)
        }
    }

    /// Get the current optimal MPC weights
    /// - Returns: Optimal weights for MPC configuration
    public func getOptimalWeights() -> OptimalWeights? {
        return currentWeights
    }

    /// Get the current player style classification
    /// - Returns: Current player style
    public func getPlayerStyle() -> PlayerStyle {
        return currentPlayerStyle
    }

    /// Train on-device using collected samples
    public func trainOnDevice() async throws {
        guard trainingSamples.count >= minTrainingSamples else {
            print("Not enough training samples: \(trainingSamples.count)/\(minTrainingSamples)")
            return
        }

        // Note: Full on-device training requires Create ML framework
        // This is a placeholder for the training logic
        print("Training on-device with \(trainingSamples.count) samples...")

        // For now, use simple averaging to update weights
        let avgStability = trainingSamples.map { $0.stabilityScore }.reduce(0, +) / Double(trainingSamples.count)

        // Adjust weights based on aggregate performance
        if avgStability < 50 {
            // Players struggling - increase angle weight
            currentWeights.qAngle *= 1.1
        } else if avgStability > 80 {
            // Players doing well - can reduce assistance
            currentWeights.qAngle *= 0.95
        }

        // Clear old samples after training
        let recentCount = min(50, trainingSamples.count)
        trainingSamples = Array(trainingSamples.suffix(recentCount))

        print("Training complete. Updated weights: Q_angle=\(currentWeights.qAngle)")
    }

    /// Export training samples for cloud training
    /// - Parameter url: File URL to export to
    public func exportTrainingSamples(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(trainingSamples)
        try data.write(to: url)
    }

    // MARK: - Private Methods

    private func loadModels() {
        // Try to load bundled Core ML models
        // These would be pre-trained on MARS data

        // Look for AdaptiveGains.mlmodel
        if let modelURL = Bundle.main.url(forResource: "AdaptiveGains", withExtension: "mlmodelc") {
            do {
                gainsModel = try MLModel(contentsOf: modelURL)
                print("Loaded AdaptiveGains model")
            } catch {
                print("Failed to load AdaptiveGains model: \(error)")
            }
        }

        // Look for PlayerStyle.mlmodel
        if let modelURL = Bundle.main.url(forResource: "PlayerStyle", withExtension: "mlmodelc") {
            do {
                styleModel = try MLModel(contentsOf: modelURL)
                print("Loaded PlayerStyle model")
            } catch {
                print("Failed to load PlayerStyle model: \(error)")
            }
        }
    }

    private func classifyPlayerStyle(_ metrics: PlayerMetrics) {
        // Heuristic classification (would be replaced by ML model)
        let reactionTime = metrics.averageReactionTime
        let forceEfficiency = metrics.forceEfficiency
        let overcorrection = metrics.overcorrectionRate

        if reactionTime < 0.2 && overcorrection > 0.4 {
            currentPlayerStyle = .aggressive
        } else if reactionTime > 0.4 && forceEfficiency > 0.7 {
            currentPlayerStyle = .cautious
        } else if overcorrection > 0.5 && forceEfficiency < 0.4 {
            currentPlayerStyle = .erratic
        } else {
            currentPlayerStyle = .balanced
        }
    }

    private func addTrainingSample(_ metrics: PlayerMetrics) {
        let sample = TrainingSample(
            timestamp: Date(),
            stabilityScore: metrics.stabilityScore,
            reactionTime: metrics.averageReactionTime,
            forceEfficiency: metrics.forceEfficiency,
            overcorrectionRate: metrics.overcorrectionRate,
            level: metrics.currentLevel,
            playerStyle: currentPlayerStyle.rawValue,
            optimalQAngle: currentWeights.qAngle,
            optimalQVelocity: currentWeights.qVelocity,
            optimalRControl: currentWeights.rControl
        )

        trainingSamples.append(sample)

        // Limit memory usage
        if trainingSamples.count > 1000 {
            trainingSamples.removeFirst(100)
        }
    }

    private func inferOptimalWeights(from metrics: PlayerMetrics) {
        guard let model = gainsModel else { return }

        // Prepare input features
        // This would use the actual model input format
        // For now, use placeholder logic

        do {
            // Create input dictionary based on model schema
            let input = try MLDictionaryFeatureProvider(dictionary: [
                "stabilityScore": metrics.stabilityScore as NSNumber,
                "avgReactionTime": metrics.averageReactionTime as NSNumber,
                "forceEfficiency": metrics.forceEfficiency as NSNumber,
                "overcorrectionRate": metrics.overcorrectionRate as NSNumber,
                "currentLevel": metrics.currentLevel as NSNumber
            ])

            // Get prediction
            let output = try model.prediction(from: input)

            // Extract weights from output
            if let qAngle = output.featureValue(for: "q_angle")?.doubleValue,
               let qVelocity = output.featureValue(for: "q_velocity")?.doubleValue,
               let rControl = output.featureValue(for: "r_control")?.doubleValue {
                currentWeights = OptimalWeights(
                    qAngle: qAngle,
                    qVelocity: qVelocity,
                    rControl: rControl
                )
            }
        } catch {
            print("ML inference failed: \(error)")
        }
    }

    private func adaptWeightsHeuristically(_ metrics: PlayerMetrics) {
        // Fallback heuristic adaptation when no ML model is available

        // If player has poor stability, increase angle weight
        if metrics.stabilityScore < 40 {
            currentWeights.qAngle = min(200, currentWeights.qAngle * 1.05)
        } else if metrics.stabilityScore > 70 {
            currentWeights.qAngle = max(50, currentWeights.qAngle * 0.98)
        }

        // If player overcorrects, increase control cost
        if metrics.overcorrectionRate > 0.5 {
            currentWeights.rControl = min(1.0, currentWeights.rControl * 1.1)
        } else if metrics.overcorrectionRate < 0.2 {
            currentWeights.rControl = max(0.01, currentWeights.rControl * 0.95)
        }

        // Adapt based on player style
        switch currentPlayerStyle {
        case .aggressive:
            currentWeights.qVelocity = min(20, currentWeights.qVelocity * 1.05)
        case .cautious:
            currentWeights.qAngle = min(150, currentWeights.qAngle * 1.03)
        case .erratic:
            currentWeights.rControl = min(0.5, currentWeights.rControl * 1.1)
        case .balanced:
            break
        }
    }
}

// MARK: - Training Sample

/// Training sample for on-device learning
public struct TrainingSample: Codable {
    public var timestamp: Date
    public var stabilityScore: Double
    public var reactionTime: Double
    public var forceEfficiency: Double
    public var overcorrectionRate: Double
    public var level: Int
    public var playerStyle: String
    public var optimalQAngle: Double
    public var optimalQVelocity: Double
    public var optimalRControl: Double
}
