// GoldenModeFeatureVector.swift
// PendulumSolver
// Feature vector for Golden Mode recommendation system (~35 dimensions)

import Foundation

/// Complete feature vector capturing health, skill, cross-app, and context data
/// Used by all three recommendation tiers (Rule Engine, Weighted Scorer, CoreML Classifier)
public struct GoldenModeFeatureVector: Codable {

  // MARK: - Health (from HealthKit, all optional)

  /// Resting heart rate (bpm)
  public var restingHeartRate: Double?
  /// Heart rate variability SDNN (ms)
  public var heartRateVariability: Double?
  /// Sleep duration (hours)
  public var sleepDuration: Double?
  /// Step count today
  public var steps: Int?
  /// Active calories burned today
  public var activeCalories: Double?
  /// Mindful minutes logged today
  public var mindfulMinutesLogged: Int

  // MARK: - Player Skill (from Pendulum CSV session history)

  /// Average stability score (0-100)
  public var stabilityScore: Double
  /// Average reaction time (seconds)
  public var averageReactionTime: Double
  /// Push effectiveness ratio (0-1)
  public var forceEfficiency: Double
  /// Overcorrection frequency (0-1)
  public var overcorrectionRate: Double
  /// Highest level reached
  public var currentMaxLevel: Int
  /// Detected play style (aggressive/cautious/balanced/erratic)
  public var playerStyle: String
  /// Total Pendulum sessions played
  public var sessionCount: Int
  /// Slope of improvement over recent sessions
  public var learningCurveSlope: Double
  /// Skill retention between sessions (0-1)
  public var skillRetention: Double
  /// Days since last Pendulum session
  public var daysSinceLastSession: Int

  // MARK: - Cross-App: The Maze (from App Group, all optional)

  /// Overall motor score from most recent Maze session (0-100)
  public var mazeMotorScore: Double?
  /// Overall cognitive score from most recent Maze session (0-100)
  public var mazeCognitiveScore: Double?
  /// Flow state score (0-1)
  public var mazeFlowState: Double?
  /// Frustration level (0-1)
  public var mazeFrustration: Double?
  /// Confidence score (0-1)
  public var mazeConfidence: Double?
  /// Focus level (0-1)
  public var mazeFocusLevel: Double?
  /// Average decision latency between swipes (seconds)
  public var mazeDecisionLatency: Double?
  /// Movement efficiency: optimal/actual moves (0-1)
  public var mazeEfficiency: Double?
  /// Emotional state label (calm, focused, stressed, etc.)
  public var mazeEmotionalState: String?
  /// Total Maze sessions played
  public var mazeSessionCount: Int?
  /// 10-dimensional digital signature vector
  public var mazeDigitalSignature: [Double]?

  // MARK: - Profile & Context

  /// User's training goal (Relaxation, Focus, Research, Curious, etc.)
  public var trainingGoal: String
  /// Hour of day (0-23)
  public var timeOfDay: Int
  /// Day of week (1 = Sunday, 7 = Saturday)
  public var dayOfWeek: Int
  /// Average session duration (minutes)
  public var sessionDurationMinutes: Double

  // MARK: - Health-Performance Correlations (computed over time)

  /// Correlation between HRV and stability score
  public var hrvPerformanceCorrelation: Double?
  /// Correlation between sleep hours and stability score
  public var sleepPerformanceCorrelation: Double?

  // MARK: - Initialization

  public init(
    restingHeartRate: Double? = nil,
    heartRateVariability: Double? = nil,
    sleepDuration: Double? = nil,
    steps: Int? = nil,
    activeCalories: Double? = nil,
    mindfulMinutesLogged: Int = 0,
    stabilityScore: Double = 50.0,
    averageReactionTime: Double = 0.3,
    forceEfficiency: Double = 0.5,
    overcorrectionRate: Double = 0.3,
    currentMaxLevel: Int = 1,
    playerStyle: String = "balanced",
    sessionCount: Int = 0,
    learningCurveSlope: Double = 0.0,
    skillRetention: Double = 0.5,
    daysSinceLastSession: Int = 0,
    mazeMotorScore: Double? = nil,
    mazeCognitiveScore: Double? = nil,
    mazeFlowState: Double? = nil,
    mazeFrustration: Double? = nil,
    mazeConfidence: Double? = nil,
    mazeFocusLevel: Double? = nil,
    mazeDecisionLatency: Double? = nil,
    mazeEfficiency: Double? = nil,
    mazeEmotionalState: String? = nil,
    mazeSessionCount: Int? = nil,
    mazeDigitalSignature: [Double]? = nil,
    trainingGoal: String = "Curious",
    timeOfDay: Int = 12,
    dayOfWeek: Int = 1,
    sessionDurationMinutes: Double = 0.0,
    hrvPerformanceCorrelation: Double? = nil,
    sleepPerformanceCorrelation: Double? = nil
  ) {
    self.restingHeartRate = restingHeartRate
    self.heartRateVariability = heartRateVariability
    self.sleepDuration = sleepDuration
    self.steps = steps
    self.activeCalories = activeCalories
    self.mindfulMinutesLogged = mindfulMinutesLogged
    self.stabilityScore = stabilityScore
    self.averageReactionTime = averageReactionTime
    self.forceEfficiency = forceEfficiency
    self.overcorrectionRate = overcorrectionRate
    self.currentMaxLevel = currentMaxLevel
    self.playerStyle = playerStyle
    self.sessionCount = sessionCount
    self.learningCurveSlope = learningCurveSlope
    self.skillRetention = skillRetention
    self.daysSinceLastSession = daysSinceLastSession
    self.mazeMotorScore = mazeMotorScore
    self.mazeCognitiveScore = mazeCognitiveScore
    self.mazeFlowState = mazeFlowState
    self.mazeFrustration = mazeFrustration
    self.mazeConfidence = mazeConfidence
    self.mazeFocusLevel = mazeFocusLevel
    self.mazeDecisionLatency = mazeDecisionLatency
    self.mazeEfficiency = mazeEfficiency
    self.mazeEmotionalState = mazeEmotionalState
    self.mazeSessionCount = mazeSessionCount
    self.mazeDigitalSignature = mazeDigitalSignature
    self.trainingGoal = trainingGoal
    self.timeOfDay = timeOfDay
    self.dayOfWeek = dayOfWeek
    self.sessionDurationMinutes = sessionDurationMinutes
    self.hrvPerformanceCorrelation = hrvPerformanceCorrelation
    self.sleepPerformanceCorrelation = sleepPerformanceCorrelation
  }

  // MARK: - Derived Properties

  /// Whether health data is available and recent
  public var hasHealthData: Bool {
    restingHeartRate != nil || heartRateVariability != nil || sleepDuration != nil
  }

  /// Whether cross-app Maze data is available
  public var hasMazeData: Bool {
    mazeMotorScore != nil || mazeCognitiveScore != nil || mazeFlowState != nil
  }

  /// Whether the Maze digital signature is available
  public var hasMazeSignature: Bool {
    guard let sig = mazeDigitalSignature else { return false }
    return !sig.isEmpty && sig.contains(where: { $0 != 0.0 })
  }

  /// Skill estimate (0-1) matching PlayerMetrics.skillEstimate formula
  public var skillEstimate: Double {
    let normalized = stabilityScore / 100.0
    let reactionScore = max(0, 1 - averageReactionTime / 0.5)
    return normalized * 0.5 + forceEfficiency * 0.3 + reactionScore * 0.2
  }

  /// Number of feature dimensions with actual data (for confidence weighting)
  public var populatedDimensionCount: Int {
    var count = 6 // Always have: stabilityScore, reactionTime, efficiency, overcorrection, maxLevel, playerStyle
    count += 4    // Always have: trainingGoal, timeOfDay, dayOfWeek, sessionDuration
    if restingHeartRate != nil { count += 1 }
    if heartRateVariability != nil { count += 1 }
    if sleepDuration != nil { count += 1 }
    if steps != nil { count += 1 }
    if activeCalories != nil { count += 1 }
    if mindfulMinutesLogged > 0 { count += 1 }
    if mazeMotorScore != nil { count += 1 }
    if mazeCognitiveScore != nil { count += 1 }
    if mazeFlowState != nil { count += 1 }
    if mazeFrustration != nil { count += 1 }
    if mazeConfidence != nil { count += 1 }
    if mazeFocusLevel != nil { count += 1 }
    if mazeDecisionLatency != nil { count += 1 }
    if mazeEfficiency != nil { count += 1 }
    if mazeEmotionalState != nil { count += 1 }
    if hrvPerformanceCorrelation != nil { count += 1 }
    if sleepPerformanceCorrelation != nil { count += 1 }
    return count
  }

  /// Data richness score (0-1) — proportion of total dimensions populated
  public var dataRichness: Double {
    Double(populatedDimensionCount) / 35.0
  }

  // MARK: - Normalization for ML

  /// Normalized feature array for ML input (all values 0-1)
  public func toNormalizedArray() -> [Double] {
    var features: [Double] = []

    // Health (normalized to typical ranges)
    features.append(normalize(restingHeartRate, min: 40, max: 100))
    features.append(normalize(heartRateVariability, min: 10, max: 120))
    features.append(normalize(sleepDuration, min: 0, max: 12))
    features.append(normalize(steps.map(Double.init), min: 0, max: 15000))
    features.append(normalize(activeCalories, min: 0, max: 800))
    features.append(Double(min(mindfulMinutesLogged, 60)) / 60.0)

    // Pendulum skill
    features.append(stabilityScore / 100.0)
    features.append(min(averageReactionTime, 1.0))
    features.append(forceEfficiency)
    features.append(overcorrectionRate)
    features.append(min(Double(currentMaxLevel), 50.0) / 50.0)
    features.append(playerStyleNumeric)
    features.append(min(Double(sessionCount), 100.0) / 100.0)
    features.append(clamp(learningCurveSlope, min: -1, max: 1) * 0.5 + 0.5)
    features.append(skillRetention)
    features.append(min(Double(daysSinceLastSession), 30.0) / 30.0)

    // Maze cross-app
    features.append(normalize(mazeMotorScore, min: 0, max: 100))
    features.append(normalize(mazeCognitiveScore, min: 0, max: 100))
    features.append(mazeFlowState ?? 0.5)
    features.append(mazeFrustration ?? 0.0)
    features.append(mazeConfidence ?? 0.5)
    features.append(mazeFocusLevel ?? 0.5)
    features.append(normalize(mazeDecisionLatency, min: 0, max: 5))
    features.append(mazeEfficiency ?? 0.5)

    // Context
    features.append(Double(timeOfDay) / 23.0)
    features.append(Double(dayOfWeek - 1) / 6.0)
    features.append(min(sessionDurationMinutes, 30.0) / 30.0)

    // Correlations
    features.append(normalize(hrvPerformanceCorrelation, min: -1, max: 1))
    features.append(normalize(sleepPerformanceCorrelation, min: -1, max: 1))

    return features
  }

  // MARK: - Private Helpers

  private func normalize(_ value: Double?, min: Double, max: Double) -> Double {
    guard let v = value else { return 0.5 }
    return clamp((v - min) / (max - min), min: 0, max: 1)
  }

  private func clamp(_ value: Double, min: Double, max: Double) -> Double {
    Swift.min(Swift.max(value, min), max)
  }

  private var playerStyleNumeric: Double {
    switch playerStyle.lowercased() {
    case "aggressive": return 0.8
    case "cautious":   return 0.3
    case "balanced":   return 0.5
    case "erratic":    return 0.9
    default:           return 0.5
    }
  }
}

// MARK: - Training Goal Constants

extension GoldenModeFeatureVector {
  public static let trainingGoals = [
    "Relaxation",
    "Focus",
    "Research",
    "Rehabilitation",
    "Curious"
  ]
}
