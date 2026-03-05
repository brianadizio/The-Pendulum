// GoldenModeRecommendation.swift
// PendulumSolver
// Focus area classification target and recommendation output for Golden Mode

import Foundation

// MARK: - Focus Area (Classification Target)

/// The 12 focus areas that Golden Mode can recommend
/// Each maps deterministically to a game configuration
public enum FocusArea: String, Codable, CaseIterable, Identifiable {
  case mindfulness
  case stressRelief
  case focusTraining
  case reactionSpeed
  case precisionControl
  case adaptability
  case endurance
  case chaosResilience
  case skillBuilding
  case competition
  case deepFocus
  case recovery

  public var id: String { rawValue }

  /// Human-readable display name
  public var displayName: String {
    switch self {
    case .mindfulness:      return "Mindfulness"
    case .stressRelief:     return "Stress Relief"
    case .focusTraining:    return "Focus Training"
    case .reactionSpeed:    return "Reaction Speed"
    case .precisionControl: return "Precision Control"
    case .adaptability:     return "Adaptability"
    case .endurance:        return "Endurance"
    case .chaosResilience:  return "Chaos Resilience"
    case .skillBuilding:    return "Skill Building"
    case .competition:      return "Competition"
    case .deepFocus:        return "Deep Focus"
    case .recovery:         return "Recovery"
    }
  }

  /// SF Symbol icon name
  public var icon: String {
    switch self {
    case .mindfulness:      return "leaf.fill"
    case .stressRelief:     return "heart.fill"
    case .focusTraining:    return "scope"
    case .reactionSpeed:    return "bolt.fill"
    case .precisionControl: return "target"
    case .adaptability:     return "arrow.triangle.2.circlepath"
    case .endurance:        return "figure.walk"
    case .chaosResilience:  return "waveform.path.ecg"
    case .skillBuilding:    return "graduationcap.fill"
    case .competition:      return "figure.fencing"
    case .deepFocus:        return "brain.head.profile"
    case .recovery:         return "bed.double.fill"
    }
  }

  /// Short benefit description
  public var benefit: String {
    switch self {
    case .mindfulness:      return "Calm, deliberate balancing"
    case .stressRelief:     return "Easy balance with AI support"
    case .focusTraining:    return "Progressive holds sharpen focus"
    case .reactionSpeed:    return "Beat the clock"
    case .precisionControl: return "Tight zones, fine motor"
    case .adaptability:     return "Randomized physics, flexible control"
    case .endurance:        return "Extended sustained concentration"
    case .chaosResilience:  return "Balance through chaos"
    case .skillBuilding:    return "Guided lessons"
    case .competition:      return "Challenge the AI"
    case .deepFocus:        return "Uninterrupted meditation"
    case .recovery:         return "Gentle when energy is low"
    }
  }
}

// MARK: - Game Configuration (output of FocusArea mapping)

/// Physics and gameplay configuration generated from a FocusArea + skill level
public struct GoldenModeGameConfig: Codable {
  /// Game mode to activate (matches GameMode.rawValue)
  public var gameMode: String
  /// AI mode to activate (matches AIMode.rawValue)
  public var aiMode: String
  /// Starting level
  public var suggestedLevel: Int
  /// AI difficulty (0-1)
  public var suggestedDifficulty: Double
  /// Physics overrides (nil = use default)
  public var dampingOverride: Double?
  public var gravityOverride: Double?
  public var massOverride: Double?
  /// Target session duration (minutes)
  public var targetDurationMinutes: Double

  public init(
    gameMode: String,
    aiMode: String,
    suggestedLevel: Int,
    suggestedDifficulty: Double = 0.5,
    dampingOverride: Double? = nil,
    gravityOverride: Double? = nil,
    massOverride: Double? = nil,
    targetDurationMinutes: Double = 10.0
  ) {
    self.gameMode = gameMode
    self.aiMode = aiMode
    self.suggestedLevel = suggestedLevel
    self.suggestedDifficulty = suggestedDifficulty
    self.dampingOverride = dampingOverride
    self.gravityOverride = gravityOverride
    self.massOverride = massOverride
    self.targetDurationMinutes = targetDurationMinutes
  }
}

// MARK: - FocusArea → Game Config Mapping

extension FocusArea {

  /// Generate the game configuration for this focus area at a given skill level
  /// - Parameter skillEstimate: Player skill (0-1), from PlayerMetrics.skillEstimate
  /// - Returns: Complete game configuration
  public func gameConfig(skillEstimate: Double) -> GoldenModeGameConfig {
    let skill = max(0, min(1, skillEstimate))

    switch self {
    case .mindfulness:
      return GoldenModeGameConfig(
        gameMode: "Free Play", aiMode: "Off",
        suggestedLevel: 1,
        dampingOverride: 0.50,
        targetDurationMinutes: 10.0
      )

    case .stressRelief:
      return GoldenModeGameConfig(
        gameMode: "Free Play", aiMode: "Helper",
        suggestedLevel: 1,
        suggestedDifficulty: 0.3,
        dampingOverride: 0.60,
        targetDurationMinutes: 8.0
      )

    case .focusTraining:
      return GoldenModeGameConfig(
        gameMode: "Progressive", aiMode: "Off",
        suggestedLevel: clampLevel(Int(skill * 5) + 1),
        targetDurationMinutes: 12.0
      )

    case .reactionSpeed:
      return GoldenModeGameConfig(
        gameMode: "Timed", aiMode: "Off",
        suggestedLevel: clampLevel(Int(skill * 4) + 1),
        targetDurationMinutes: 10.0
      )

    case .precisionControl:
      return GoldenModeGameConfig(
        gameMode: "Spatial", aiMode: "Off",
        suggestedLevel: clampLevel(Int(skill * 4) + 1),
        targetDurationMinutes: 10.0
      )

    case .adaptability:
      return GoldenModeGameConfig(
        gameMode: "Random", aiMode: "Off",
        suggestedLevel: 1,
        targetDurationMinutes: 10.0
      )

    case .endurance:
      return GoldenModeGameConfig(
        gameMode: "Progressive", aiMode: "Off",
        suggestedLevel: clampLevel(Int(skill * 6)),
        dampingOverride: 0.35,
        targetDurationMinutes: 15.0
      )

    case .chaosResilience:
      return GoldenModeGameConfig(
        gameMode: "Jiggle", aiMode: "Off",
        suggestedLevel: clampLevel(Int(skill * 5) + 1),
        targetDurationMinutes: 10.0
      )

    case .skillBuilding:
      return GoldenModeGameConfig(
        gameMode: "Progressive", aiMode: "Tutorial",
        suggestedLevel: 1,
        suggestedDifficulty: 0.4,
        targetDurationMinutes: 8.0
      )

    case .competition:
      return GoldenModeGameConfig(
        gameMode: "Progressive", aiMode: "Competition",
        suggestedLevel: clampLevel(Int(skill * 5)),
        suggestedDifficulty: 0.5 + skill * 0.3,
        targetDurationMinutes: 12.0
      )

    case .deepFocus:
      return GoldenModeGameConfig(
        gameMode: "Free Play", aiMode: "Off",
        suggestedLevel: 1,
        dampingOverride: 0.45,
        gravityOverride: 9.0,
        targetDurationMinutes: 15.0
      )

    case .recovery:
      return GoldenModeGameConfig(
        gameMode: "Free Play", aiMode: "Helper",
        suggestedLevel: 1,
        suggestedDifficulty: 0.3,
        dampingOverride: 0.55,
        gravityOverride: 8.0,
        targetDurationMinutes: 5.0
      )
    }
  }

  private func clampLevel(_ level: Int) -> Int {
    max(1, min(level, 50))
  }
}

// MARK: - Recommendation

/// A complete recommendation from the Golden Mode engine
public struct GoldenModeRecommendation: Codable, Identifiable {
  public let id: UUID
  public let timestamp: Date
  public let focusArea: FocusArea
  public let config: GoldenModeGameConfig
  public let confidenceScore: Double
  public let reasoning: String
  public let tier: RecommendationTier

  /// Which tier generated this recommendation
  public enum RecommendationTier: String, Codable {
    case ruleEngine     // Tier 1: Deterministic rules
    case weightedScorer // Tier 2: Weighted scoring
    case mlClassifier   // Tier 3: CoreML
    case blended        // Mix of tiers
  }

  public init(
    focusArea: FocusArea,
    config: GoldenModeGameConfig,
    confidenceScore: Double,
    reasoning: String,
    tier: RecommendationTier
  ) {
    self.id = UUID()
    self.timestamp = Date()
    self.focusArea = focusArea
    self.config = config
    self.confidenceScore = confidenceScore
    self.reasoning = reasoning
    self.tier = tier
  }
}
