// GoldenModeClassifier.swift
// PendulumSolver
// Tier 3: CoreML classifier wrapper + sample collection for Golden Mode
//
// Note: CreateML training (MLBoostedTreeClassifier) requires the CreateML framework,
// which is only available in app targets, not Swift packages. This class handles:
// - Sample collection and storage
// - Prediction from a compiled .mlmodelc loaded at runtime
// - Model loading/saving
// Training is deferred to GoldenModeManager in the app target.

import Foundation
import CoreML

/// Tier 3 recommendation engine — CoreML classifier wrapper
///
/// Collects training samples from outcomes and predicts FocusArea from feature vectors
/// using a compiled CoreML model. Training is handled by the app layer (GoldenModeManager).
/// Active after 20+ outcomes. Blends with Tier 2 when confidence < 0.6.
public class GoldenModeClassifier {

  // MARK: - Types

  /// Training sample for the classifier
  public struct ClassifierSample: Codable {
    public let features: [Double]    // Normalized feature vector
    public let label: String         // FocusArea.rawValue
    public let quality: Double       // Outcome quality (0-1)

    public init(features: [Double], label: String, quality: Double) {
      self.features = features
      self.label = label
      self.quality = quality
    }
  }

  /// Prediction result from the classifier
  public struct Prediction {
    public let focusArea: FocusArea
    public let confidence: Double
    public let allProbabilities: [FocusArea: Double]
  }

  /// Training result metadata
  public struct TrainingResult: Codable {
    public let date: Date
    public let sampleCount: Int
    public let accuracy: Double
    public let featureDimensions: Int
  }

  // MARK: - Properties

  /// Compiled CoreML model (nil until loaded from trained .mlmodelc)
  private var model: MLModel?

  /// Collected training samples
  public private(set) var samples: [ClassifierSample] = []

  /// Training history
  public private(set) var trainingHistory: [TrainingResult] = []

  /// Minimum samples required to train
  public let minimumSamples: Int = 20

  /// Retrain interval (every N new samples)
  public let retrainInterval: Int = 10

  /// Whether a trained model is loaded
  public var isModelAvailable: Bool { model != nil }

  /// Number of collected samples
  public var sampleCount: Int { samples.count }

  // MARK: - Initialization

  public init() {}

  // MARK: - Prediction

  /// Predict the best FocusArea from a feature vector
  /// - Parameter features: Current feature vector
  /// - Returns: Prediction with focus area, confidence, and probabilities, or nil if no model
  public func predict(from features: GoldenModeFeatureVector) -> Prediction? {
    guard let model = model else { return nil }

    let normalized = features.toNormalizedArray()

    do {
      let input = try createMLInput(from: normalized)
      let output = try model.prediction(from: input)

      // Extract predicted class
      guard let classLabel = output.featureValue(for: "label")?.stringValue,
            let focusArea = FocusArea(rawValue: classLabel) else {
        return nil
      }

      // Extract probabilities if available
      var probabilities: [FocusArea: Double] = [:]
      if let probs = output.featureValue(for: "labelProbability")?.dictionaryValue {
        for (key, value) in probs {
          if let keyStr = key as? String,
             let area = FocusArea(rawValue: keyStr),
             let prob = value as? Double {
            probabilities[area] = prob
          }
        }
      }

      let confidence = probabilities[focusArea] ?? 0.5

      return Prediction(
        focusArea: focusArea,
        confidence: confidence,
        allProbabilities: probabilities
      )
    } catch {
      print("GoldenModeClassifier: Prediction failed: \(error)")
      return nil
    }
  }

  /// Generate a recommendation using the ML model
  /// - Parameter features: Current feature vector
  /// - Returns: Recommendation or nil if model unavailable
  public func recommend(from features: GoldenModeFeatureVector) -> GoldenModeRecommendation? {
    guard let prediction = predict(from: features) else { return nil }

    let config = prediction.focusArea.gameConfig(skillEstimate: features.skillEstimate)

    return GoldenModeRecommendation(
      focusArea: prediction.focusArea,
      config: config,
      confidenceScore: prediction.confidence,
      reasoning: "ML classifier selected \(prediction.focusArea.displayName) (confidence: \(String(format: "%.0f%%", prediction.confidence * 100)))",
      tier: .mlClassifier
    )
  }

  // MARK: - Sample Collection

  /// Add a training sample from a completed session
  /// - Parameter outcome: Session outcome with features and quality
  public func addSample(from outcome: GoldenModeOutcome) {
    guard let recommendation = outcome.recommendation,
          outcome.wasRecommendationFollowed else { return }

    let sample = ClassifierSample(
      features: outcome.preSessionFeatures.toNormalizedArray(),
      label: recommendation.focusArea.rawValue,
      quality: outcome.outcomeQuality
    )
    samples.append(sample)
  }

  /// Whether the classifier should retrain (checked by app layer)
  public var shouldRetrain: Bool {
    samples.count >= minimumSamples &&
    samples.count % retrainInterval == 0
  }

  /// Get positive-quality samples for training
  /// - Returns: Samples with quality > 0.4
  public func getTrainingSamples() -> [ClassifierSample] {
    samples.filter { $0.quality > 0.4 }
  }

  /// Record a training result (called by app layer after CreateML training)
  /// - Parameter result: Training metadata
  public func recordTrainingResult(_ result: TrainingResult) {
    trainingHistory.append(result)
  }

  // MARK: - Model Loading

  /// Load a compiled CoreML model from URL
  /// - Parameter url: URL to .mlmodelc directory
  public func loadCompiledModel(from url: URL) throws {
    let config = MLModelConfiguration()
    config.computeUnits = .cpuAndGPU
    model = try MLModel(contentsOf: url, configuration: config)
  }

  /// Set the model directly (e.g., after app-layer training)
  /// - Parameter model: Compiled MLModel
  public func setModel(_ newModel: MLModel) {
    model = newModel
  }

  // MARK: - Persistence

  /// Export samples and training history to JSON data
  public func exportData() throws -> Data {
    let exportData = ClassifierExportData(
      samples: samples,
      trainingHistory: trainingHistory
    )
    return try JSONEncoder().encode(exportData)
  }

  /// Import samples and training history from JSON data
  public func importData(from data: Data) throws {
    let exportData = try JSONDecoder().decode(ClassifierExportData.self, from: data)
    samples = exportData.samples
    trainingHistory = exportData.trainingHistory
  }

  // MARK: - Errors

  public enum ClassifierError: Error, LocalizedError {
    case insufficientSamples(have: Int, need: Int)
    case insufficientPositiveSamples
    case noModelAvailable
    case trainingFailed(String)

    public var errorDescription: String? {
      switch self {
      case .insufficientSamples(let have, let need):
        return "Need \(need) samples, have \(have)"
      case .insufficientPositiveSamples:
        return "Not enough positive outcomes for training"
      case .noModelAvailable:
        return "No trained model available"
      case .trainingFailed(let reason):
        return "Training failed: \(reason)"
      }
    }
  }

  // MARK: - Private Types

  private struct ClassifierExportData: Codable {
    let samples: [ClassifierSample]
    let trainingHistory: [TrainingResult]
  }

  // MARK: - Private Methods

  private func createMLInput(from features: [Double]) throws -> MLFeatureProvider {
    var dict: [String: MLFeatureValue] = [:]
    for (i, value) in features.enumerated() {
      dict["f\(i)"] = MLFeatureValue(double: value)
    }
    return try MLDictionaryFeatureProvider(dictionary: dict)
  }
}
