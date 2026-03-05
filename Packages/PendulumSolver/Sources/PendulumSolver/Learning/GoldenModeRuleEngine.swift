// GoldenModeRuleEngine.swift
// PendulumSolver
// Tier 1: Deterministic rule engine for Golden Mode recommendations

import Foundation

/// Tier 1 recommendation engine — deterministic rules that work from session 0
///
/// Priority order: Cross-app override rules (1-5), Health rules (6-9),
/// Goal-based rules (10-18), Default fallback
public class GoldenModeRuleEngine {

  // MARK: - Rule Result

  /// Result of rule evaluation with reasoning
  public struct RuleResult {
    public let focusArea: FocusArea
    public let confidence: Double
    public let reasoning: String
    public let ruleIndex: Int
  }

  // MARK: - Initialization

  public init() {}

  // MARK: - Public API

  /// Generate a recommendation from the feature vector using deterministic rules
  /// - Parameter features: Current feature vector
  /// - Returns: Recommendation with focus area, config, confidence, and reasoning
  public func recommend(from features: GoldenModeFeatureVector) -> GoldenModeRecommendation {
    let result = evaluateRules(features)
    let config = result.focusArea.gameConfig(skillEstimate: features.skillEstimate)

    return GoldenModeRecommendation(
      focusArea: result.focusArea,
      config: config,
      confidenceScore: result.confidence,
      reasoning: result.reasoning,
      tier: .ruleEngine
    )
  }

  // MARK: - Rule Evaluation

  /// Evaluate all rules in priority order, returning the first match
  public func evaluateRules(_ features: GoldenModeFeatureVector) -> RuleResult {
    // Cross-app override rules (highest priority, when Maze data available)
    if let result = crossAppRules(features) { return result }

    // Health-based rules
    if let result = healthRules(features) { return result }

    // Goal-based rules
    if let result = goalRules(features) { return result }

    // Default fallback
    return RuleResult(
      focusArea: .skillBuilding,
      confidence: 0.3,
      reasoning: "Default recommendation — building foundational skills",
      ruleIndex: 18
    )
  }

  // MARK: - Cross-App Override Rules (1-5)

  private func crossAppRules(_ f: GoldenModeFeatureVector) -> RuleResult? {
    guard f.hasMazeData else { return nil }

    // Confidence bonus when Maze data is present (recency checked at manager level)
    let confidenceBonus = 0.1

    // Rule 1: High Maze frustration → ease into Pendulum
    if let frustration = f.mazeFrustration, frustration > 0.7 {
      return RuleResult(
        focusArea: .stressRelief,
        confidence: 0.45 + confidenceBonus,
        reasoning: "Recent maze session showed high frustration (\(String(format: "%.0f%%", frustration * 100))) — easing into pendulum with AI support",
        ruleIndex: 1
      )
    }

    // Rule 2: Maze stressed + low HRV → recovery
    if f.mazeEmotionalState?.lowercased() == "stressed",
       let hrv = f.heartRateVariability, hrv < 30 {
      return RuleResult(
        focusArea: .recovery,
        confidence: 0.5 + confidenceBonus,
        reasoning: "Maze emotional state is stressed and HRV is low (\(String(format: "%.0f", hrv))ms) — gentle recovery session recommended",
        ruleIndex: 2
      )
    }

    // Rule 3: High Maze flow + good Pendulum stability → ride momentum
    if let flow = f.mazeFlowState, flow > 0.8, f.stabilityScore > 60 {
      return RuleResult(
        focusArea: .deepFocus,
        confidence: 0.45 + confidenceBonus,
        reasoning: "High flow state from maze (\(String(format: "%.0f%%", flow * 100))) and solid stability — ride the momentum with deep focus",
        ruleIndex: 3
      )
    }

    // Rule 4: Strong Maze cognitive + weak Pendulum stability → skill building
    if let cognitive = f.mazeCognitiveScore, cognitive > 75, f.stabilityScore < 40 {
      return RuleResult(
        focusArea: .skillBuilding,
        confidence: 0.4 + confidenceBonus,
        reasoning: "Strong cognitive score from maze (\(String(format: "%.0f", cognitive))) but Pendulum stability is low — motor skills need work",
        ruleIndex: 4
      )
    }

    // Rule 5: Maze focus high + morning → amplify focus
    if let focus = f.mazeFocusLevel, focus > 0.7, f.timeOfDay >= 6 && f.timeOfDay <= 9 {
      return RuleResult(
        focusArea: .focusTraining,
        confidence: 0.4 + confidenceBonus,
        reasoning: "Morning session with high maze focus (\(String(format: "%.0f%%", focus * 100))) — amplifying with focus training",
        ruleIndex: 5
      )
    }

    return nil
  }

  // MARK: - Health-Based Rules (6-9)

  private func healthRules(_ f: GoldenModeFeatureVector) -> RuleResult? {
    // Rule 6: Low HRV or high resting HR → stress relief
    if let hrv = f.heartRateVariability, hrv < 30 {
      return RuleResult(
        focusArea: .stressRelief,
        confidence: 0.4,
        reasoning: "Low heart rate variability (\(String(format: "%.0f", hrv))ms) indicates stress — gentle balancing with AI help",
        ruleIndex: 6
      )
    }
    if let rhr = f.restingHeartRate, rhr > 80 {
      return RuleResult(
        focusArea: .stressRelief,
        confidence: 0.35,
        reasoning: "Elevated resting heart rate (\(String(format: "%.0f", rhr)) bpm) — stress relief session",
        ruleIndex: 6
      )
    }

    // Rule 7: Poor sleep → recovery
    if let sleep = f.sleepDuration, sleep < 6 {
      return RuleResult(
        focusArea: .recovery,
        confidence: 0.4,
        reasoning: "Only \(String(format: "%.1f", sleep)) hours of sleep — gentle recovery session",
        ruleIndex: 7
      )
    }

    // Rule 8: Late night → mindfulness
    if f.timeOfDay >= 22 || f.timeOfDay < 6 {
      return RuleResult(
        focusArea: .mindfulness,
        confidence: 0.35,
        reasoning: "Late night session — calm mindful balancing",
        ruleIndex: 8
      )
    }

    // Rule 9: Morning → focus training
    if f.timeOfDay >= 6 && f.timeOfDay <= 9 {
      return RuleResult(
        focusArea: .focusTraining,
        confidence: 0.35,
        reasoning: "Morning session — sharpen focus for the day ahead",
        ruleIndex: 9
      )
    }

    return nil
  }

  // MARK: - Goal-Based Rules (10-18)

  private func goalRules(_ f: GoldenModeFeatureVector) -> RuleResult? {
    let goal = f.trainingGoal.lowercased()

    switch goal {
    case "relaxation":
      // Rule 10: Relaxation + stability > 50 → mindfulness
      if f.stabilityScore > 50 {
        return RuleResult(
          focusArea: .mindfulness,
          confidence: 0.4,
          reasoning: "Relaxation goal with good stability — mindful balancing",
          ruleIndex: 10
        )
      }
      // Rule 11: Relaxation + stability ≤ 50 → stress relief
      return RuleResult(
        focusArea: .stressRelief,
        confidence: 0.4,
        reasoning: "Relaxation goal — easy balancing with AI support to build comfort",
        ruleIndex: 11
      )

    case "focus":
      // Rule 12: Focus + < 3 sessions → skill building
      if f.sessionCount < 3 {
        return RuleResult(
          focusArea: .skillBuilding,
          confidence: 0.35,
          reasoning: "Focus goal, early sessions — building foundation first",
          ruleIndex: 12
        )
      }
      // Rule 13: Focus + stability > 60 → focus training
      if f.stabilityScore > 60 {
        return RuleResult(
          focusArea: .focusTraining,
          confidence: 0.4,
          reasoning: "Focus goal with solid stability — progressive focus challenges",
          ruleIndex: 13
        )
      }
      // Rule 14: Focus + stability ≤ 60 → skill building
      return RuleResult(
        focusArea: .skillBuilding,
        confidence: 0.35,
        reasoning: "Focus goal — strengthening core skills before focus challenges",
        ruleIndex: 14
      )

    case "research":
      // Rule 15: Research + stability > 70 → chaos resilience
      if f.stabilityScore > 70 {
        return RuleResult(
          focusArea: .chaosResilience,
          confidence: 0.4,
          reasoning: "Research goal with high stability — exploring chaos dynamics",
          ruleIndex: 15
        )
      }
      // Rule 16: Research → adaptability
      return RuleResult(
        focusArea: .adaptability,
        confidence: 0.35,
        reasoning: "Research goal — randomized physics for exploration",
        ruleIndex: 16
      )

    case "rehabilitation":
      // Rehabilitation: always gentle with support
      if f.stabilityScore > 40 {
        return RuleResult(
          focusArea: .precisionControl,
          confidence: 0.4,
          reasoning: "Rehabilitation goal with developing stability — precision motor control exercises",
          ruleIndex: 17
        )
      }
      return RuleResult(
        focusArea: .recovery,
        confidence: 0.4,
        reasoning: "Rehabilitation goal — gentle exercises with AI support",
        ruleIndex: 17
      )

    case "curious":
      // Rule 17: Curious → rotate through focus areas by session count
      let allAreas = FocusArea.allCases
      let index = f.sessionCount % allAreas.count
      return RuleResult(
        focusArea: allAreas[index],
        confidence: 0.35,
        reasoning: "Curious goal — exploring \(allAreas[index].displayName) (session \(f.sessionCount + 1))",
        ruleIndex: 17
      )

    default:
      return nil
    }
  }
}
