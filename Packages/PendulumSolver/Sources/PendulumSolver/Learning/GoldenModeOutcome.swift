// GoldenModeOutcome.swift
// PendulumSolver
// Training feedback from completed Golden Mode sessions

import Foundation

/// Records the outcome of a Golden Mode session for training the recommendation system
public struct GoldenModeOutcome: Codable, Identifiable {
  public let id: UUID
  public let timestamp: Date

  // MARK: - What was recommended

  /// The recommendation that was generated (nil if user overrode)
  public let recommendation: GoldenModeRecommendation?
  /// Whether the user followed the recommendation as-is
  public let wasRecommendationFollowed: Bool

  // MARK: - What actually happened

  /// Game mode used (matches GameMode.rawValue)
  public let actualGameMode: String
  /// AI mode used (matches AIMode.rawValue)
  public let actualAIMode: String

  // MARK: - Pre-session state

  /// Feature vector at session start (for ML training input)
  public let preSessionFeatures: GoldenModeFeatureVector

  // MARK: - Session results

  /// Total session duration (seconds)
  public let sessionDuration: TimeInterval
  /// Whether the session ran to completion (vs user quit early)
  public let sessionCompleted: Bool
  /// Change in stability score from recent average (positive = improved)
  public let stabilityImprovement: Double
  /// Change in reaction time from recent average (negative = improved)
  public let reactionTimeImprovement: Double
  /// Levels completed during this session
  public let levelsCompleted: Int
  /// Enjoyment proxy: duration-normalized completion (higher = better engagement)
  public let enjoymentProxy: Double
  /// Final coherence score at session end
  public let coherenceScoreEnd: Double

  // MARK: - Computed Quality Signal

  /// Overall outcome quality (0-1) used as the training signal
  /// Combines completion, improvement, and engagement metrics
  public var outcomeQuality: Double {
    var score = 0.0

    // Completion bonus (0.3 max)
    if sessionCompleted {
      score += 0.3
    } else {
      // Partial credit for sessions > 2 minutes
      score += min(sessionDuration / 300.0, 1.0) * 0.15
    }

    // Stability improvement (0.25 max)
    let stabilitySignal = max(0, min(stabilityImprovement / 20.0, 1.0))
    score += stabilitySignal * 0.25

    // Reaction time improvement (0.15 max) — negative is better
    let reactionSignal = max(0, min(-reactionTimeImprovement / 0.1, 1.0))
    score += reactionSignal * 0.15

    // Engagement proxy (0.3 max)
    score += min(enjoymentProxy, 1.0) * 0.3

    return min(score, 1.0)
  }

  /// Whether this outcome is "positive" (worth reinforcing)
  public var isPositiveOutcome: Bool {
    outcomeQuality > 0.5
  }

  // MARK: - Initialization

  public init(
    recommendation: GoldenModeRecommendation?,
    wasRecommendationFollowed: Bool,
    actualGameMode: String,
    actualAIMode: String,
    preSessionFeatures: GoldenModeFeatureVector,
    sessionDuration: TimeInterval,
    sessionCompleted: Bool,
    stabilityImprovement: Double,
    reactionTimeImprovement: Double,
    levelsCompleted: Int,
    enjoymentProxy: Double,
    coherenceScoreEnd: Double
  ) {
    self.id = UUID()
    self.timestamp = Date()
    self.recommendation = recommendation
    self.wasRecommendationFollowed = wasRecommendationFollowed
    self.actualGameMode = actualGameMode
    self.actualAIMode = actualAIMode
    self.preSessionFeatures = preSessionFeatures
    self.sessionDuration = sessionDuration
    self.sessionCompleted = sessionCompleted
    self.stabilityImprovement = stabilityImprovement
    self.reactionTimeImprovement = reactionTimeImprovement
    self.levelsCompleted = levelsCompleted
    self.enjoymentProxy = enjoymentProxy
    self.coherenceScoreEnd = coherenceScoreEnd
  }
}

// MARK: - Outcome Summary (for dashboard)

extension GoldenModeOutcome {
  /// Compact summary for display
  public var summary: String {
    let area = recommendation?.focusArea.displayName ?? "Custom"
    let quality = outcomeQuality >= 0.7 ? "Strong" : outcomeQuality >= 0.4 ? "Moderate" : "Weak"
    return "\(area) — \(quality) outcome"
  }

  /// Duration formatted for display
  public var formattedDuration: String {
    let minutes = Int(sessionDuration) / 60
    let seconds = Int(sessionDuration) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }

  /// Focus area from the recommendation (convenience accessor)
  public var focusArea: FocusArea {
    recommendation?.focusArea ?? .skillBuilding
  }

  /// Session score (computed from outcome quality and duration)
  public var score: Int? {
    guard sessionDuration > 10 else { return nil }
    return Int(outcomeQuality * 1000.0 * (sessionDuration / 180.0))
  }

  /// Unique session identifier (alias for Identifiable conformance)
  public var sessionId: UUID { id }
}
