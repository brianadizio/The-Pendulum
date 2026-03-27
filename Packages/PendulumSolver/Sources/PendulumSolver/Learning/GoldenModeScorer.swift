// GoldenModeScorer.swift
// PendulumSolver
// Tier 2: Weighted scoring model with EMA weight updates for Golden Mode

import Foundation

/// Tier 2 recommendation engine — weighted scoring model
///
/// Each FocusArea has a weight vector. Scores are computed as dot(weights, features).
/// Weights are initialized from hand-tuned defaults and updated via EMA from session outcomes.
/// Active from session 5–20, then blends with Tier 3.
public class GoldenModeScorer: Codable {

  // MARK: - Types

  /// Weight vector for a single FocusArea
  public struct FocusWeights: Codable {
    public var weights: [Double]
    public var updateCount: Int

    public init(weights: [Double], updateCount: Int = 0) {
      self.weights = weights
      self.updateCount = updateCount
    }
  }

  // MARK: - Properties

  /// Weight vectors per FocusArea
  public var focusWeights: [String: FocusWeights]

  /// EMA smoothing factor (higher = more weight on recent outcomes)
  public var emaSmoothingFactor: Double = 0.15

  /// Feature dimension count (must match GoldenModeFeatureVector.toNormalizedArray())
  public let featureDimensions: Int = 29

  // MARK: - Initialization

  public init() {
    focusWeights = [:]
    initializeDefaultWeights()
  }

  // MARK: - Public API

  /// Score all focus areas and return the best recommendation
  /// - Parameter features: Current feature vector
  /// - Returns: Recommendation with scored FocusArea
  public func recommend(from features: GoldenModeFeatureVector) -> GoldenModeRecommendation {
    let normalized = features.toNormalizedArray()
    let scores = scoreAllFocusAreas(normalized)

    // Pick the highest-scoring area
    let best = scores.max(by: { $0.value < $1.value })!
    let focusArea = FocusArea(rawValue: best.key) ?? .skillBuilding

    // Confidence from score margin over second-best
    let sortedScores = scores.values.sorted(by: >)
    let margin = sortedScores.count >= 2 ? sortedScores[0] - sortedScores[1] : 0.0
    let confidence = min(0.4 + margin * 0.5, 0.8)

    let config = focusArea.gameConfig(skillEstimate: features.skillEstimate)

    return GoldenModeRecommendation(
      focusArea: focusArea,
      config: config,
      confidenceScore: confidence,
      reasoning: "Weighted scorer selected \(focusArea.displayName) (score: \(String(format: "%.2f", best.value)))",
      tier: .weightedScorer
    )
  }

  /// Score all focus areas against a normalized feature vector
  /// - Parameter features: Normalized feature array (0-1)
  /// - Returns: Dictionary of FocusArea rawValue → score
  public func scoreAllFocusAreas(_ features: [Double]) -> [String: Double] {
    var scores: [String: Double] = [:]
    for area in FocusArea.allCases {
      guard let fw = focusWeights[area.rawValue] else {
        scores[area.rawValue] = 0.0
        continue
      }
      scores[area.rawValue] = dotProduct(fw.weights, features)
    }
    return scores
  }

  /// Update weights for a focus area based on session outcome
  /// - Parameters:
  ///   - focusArea: Which focus area was used
  ///   - features: Pre-session feature vector (normalized)
  ///   - quality: Outcome quality signal (0-1)
  public func updateWeights(focusArea: FocusArea, features: [Double], quality: Double) {
    guard var fw = focusWeights[focusArea.rawValue] else { return }
    guard fw.weights.count == features.count else { return }

    let alpha = emaSmoothingFactor
    let reward = quality - 0.5 // Center around 0: positive = reinforce, negative = reduce

    // EMA update: w_new = w_old + alpha * reward * features
    for i in 0..<fw.weights.count {
      fw.weights[i] += alpha * reward * features[i]
      // Clamp to prevent runaway weights
      fw.weights[i] = max(-3.0, min(3.0, fw.weights[i]))
    }

    fw.updateCount += 1
    focusWeights[focusArea.rawValue] = fw
  }

  /// Update weights from a complete outcome
  /// - Parameter outcome: Completed session outcome
  public func updateFromOutcome(_ outcome: GoldenModeOutcome) {
    guard let recommendation = outcome.recommendation else { return }
    let features = outcome.preSessionFeatures.toNormalizedArray()
    updateWeights(
      focusArea: recommendation.focusArea,
      features: features,
      quality: outcome.outcomeQuality
    )
  }

  // MARK: - Serialization

  /// Export weights to JSON data
  public func exportWeights() throws -> Data {
    try JSONEncoder().encode(self)
  }

  /// Import weights from JSON data
  public static func importWeights(from data: Data) throws -> GoldenModeScorer {
    try JSONDecoder().decode(GoldenModeScorer.self, from: data)
  }

  // MARK: - Private Methods

  private func dotProduct(_ a: [Double], _ b: [Double]) -> Double {
    let len = min(a.count, b.count)
    var sum = 0.0
    for i in 0..<len {
      sum += a[i] * b[i]
    }
    return sum
  }

  /// Initialize hand-tuned default weights for each FocusArea
  /// Weight positions match GoldenModeFeatureVector.toNormalizedArray() order:
  /// [0-5: health, 6-15: pendulum skill, 16-23: maze, 24-26: context, 27-28: correlations]
  private func initializeDefaultWeights() {
    let dim = featureDimensions
    let zero = [Double](repeating: 0.0, count: dim)

    for area in FocusArea.allCases {
      var w = zero

      switch area {
      case .mindfulness:
        // Favors: low stress, good sleep, evening, good stability
        w[2] = 0.5   // sleep
        w[6] = 0.4   // stability
        w[24] = -0.3  // time of day (prefers evening)

      case .stressRelief:
        // Favors: high HR, low HRV, frustration from Maze
        w[0] = 0.5   // resting HR (high = stressed)
        w[1] = -0.5  // HRV (low = stressed)
        w[19] = 0.5  // maze frustration

      case .focusTraining:
        // Favors: morning, good HRV, moderate stability, focus from Maze
        w[1] = 0.3   // HRV
        w[6] = 0.3   // stability
        w[21] = 0.4  // maze focus level
        w[24] = -0.2 // time of day (prefers morning)

      case .reactionSpeed:
        // Favors: high energy, good reaction time potential, steps
        w[3] = 0.3   // steps
        w[4] = 0.3   // calories
        w[7] = -0.5  // reaction time (lower = ready for speed challenge)

      case .precisionControl:
        // Favors: good efficiency, low overcorrection, maze motor skills
        w[8] = 0.5   // force efficiency
        w[9] = -0.5  // overcorrection (less = more precise)
        w[16] = 0.4  // maze motor score

      case .adaptability:
        // Favors: balanced play style, varied experience
        w[11] = 0.3  // player style (balanced ~0.5)
        w[12] = 0.3  // session count (more = more adaptable)

      case .endurance:
        // Favors: good sleep, high stability, good retention
        w[2] = 0.4   // sleep
        w[6] = 0.5   // stability
        w[14] = 0.4  // skill retention

      case .chaosResilience:
        // Favors: high stability, experience, good maze cognition
        w[6] = 0.5   // stability
        w[10] = 0.3  // max level
        w[17] = 0.3  // maze cognitive score

      case .skillBuilding:
        // Favors: low session count, low stability, new players
        w[6] = -0.3  // stability (lower = needs building)
        w[12] = -0.4 // session count (fewer = newer)

      case .competition:
        // Favors: high stability, good efficiency, experienced
        w[6] = 0.5   // stability
        w[8] = 0.3   // efficiency
        w[10] = 0.3  // max level
        w[20] = 0.3  // maze confidence

      case .deepFocus:
        // Favors: flow state, focus, good HRV, high stability
        w[1] = 0.3   // HRV
        w[6] = 0.4   // stability
        w[18] = 0.5  // maze flow state
        w[21] = 0.4  // maze focus level

      case .recovery:
        // Favors: poor sleep, low energy, low HRV
        w[0] = 0.4   // resting HR (high = stressed)
        w[1] = -0.4  // HRV (low = needs recovery)
        w[2] = -0.5  // sleep (less = needs recovery)
        w[15] = 0.3  // days since last session (more = rusty)
      }

      focusWeights[area.rawValue] = FocusWeights(weights: w)
    }
  }
}

