// GoldenModeManager.swift
// The Pendulum 2.0
// Singleton orchestrator for The Golden Mode — recommendation, adaptation, coherence, persistence

import Foundation
import Combine
import PendulumSolver
import FirebaseStorage

// MARK: - Golden Mode Manager

class GoldenModeManager: ObservableObject {
  static let shared = GoldenModeManager()

  // MARK: - Published State

  @Published var currentRecommendation: GoldenModeRecommendation?
  @Published var coherenceScore: Double = 0.0
  @Published var coherenceLabel: String = "No Data"
  @Published var isGoldenModeActive: Bool = false
  @Published var outcomeCount: Int = 0
  @Published var currentTier: String = "Rule Engine"

  /// The current focus area name as a plain String (avoids PendulumSolver import in other files)
  var currentFocusAreaName: String? {
    currentRecommendation?.focusArea.rawValue
  }

  /// Public read-only access to recent outcomes for the dashboard
  var recentOutcomes: [GoldenModeOutcome] {
    outcomes.suffix(50).reversed()
  }

  /// Public read-only access to adaptation count for HUD display
  var adaptationCountPublic: Int { adaptationCount }

  // MARK: - Recommendation Engine

  private let ruleEngine = GoldenModeRuleEngine()
  private var scorer = GoldenModeScorer()
  private let classifier = GoldenModeClassifier()

  // MARK: - Session State

  private var preSessionFeatures: GoldenModeFeatureVector?
  private var preSessionStability: Double = 0.0
  private var preSessionReactionTime: Double = 0.3
  private var sessionStartTime: Date?
  private var adaptationCount: Int = 0
  private var lastAdaptationTime: TimeInterval = 0
  private let adaptationInterval: TimeInterval = 30.0

  // MARK: - Outcomes

  private var outcomes: [GoldenModeOutcome] = []
  private let maxStoredOutcomes: Int = 200

  // MARK: - Initialization

  private init() {
    loadLocalState()
  }

  // MARK: - Feature Vector Building

  /// Build the current feature vector from all data sources
  func buildFeatureVector() -> GoldenModeFeatureVector {
    var fv = GoldenModeFeatureVector()

    // Health data (from HealthKitManager)
    if let snapshot = HealthKitManager.shared.latestHealthSnapshot {
      fv.restingHeartRate = snapshot.restingHeartRate
      fv.heartRateVariability = snapshot.heartRateVariability
      fv.sleepDuration = snapshot.sleepDuration.map { $0 / 3600.0 } // Convert seconds to hours
      fv.steps = snapshot.steps
      fv.activeCalories = snapshot.activeCalories
      fv.mindfulMinutesLogged = snapshot.mindfulMinutesLogged
    }

    // Player skill — pull from last known session metrics
    // Note: CSVMetricsCalculator and CSVSessionManager are not singletons;
    // we use session file count and AI summary as proxies.
    let sessionFiles = getSessionFileCount()
    fv.sessionCount = sessionFiles

    // Player metrics from AI manager's solver
    fv.forceEfficiency = 0.5
    fv.overcorrectionRate = 0.3
    fv.currentMaxLevel = 1
    fv.playerStyle = "balanced"

    // Session recency
    if let latestDate = getLatestSessionDate() {
      let days = Calendar.current.dateComponents([.day], from: latestDate, to: Date()).day ?? 0
      fv.daysSinceLastSession = days
    }

    // Learning curve and retention
    fv.learningCurveSlope = 0.0
    fv.skillRetention = 0.5

    // Cross-app: The Maze (from App Group)
    if let mazeData = AppGroupManager.shared.loadMazeData() {
      if let latest = mazeData.sessions.last {
        fv.mazeMotorScore = latest.motorScore
        fv.mazeCognitiveScore = latest.cognitiveScore
        fv.mazeFlowState = latest.flowStateScore
        fv.mazeFrustration = latest.frustrationLevel
        fv.mazeConfidence = latest.confidenceScore
        fv.mazeFocusLevel = latest.focusLevel
        fv.mazeDecisionLatency = latest.decisionLatencyAvg
        fv.mazeEfficiency = latest.movementEfficiency
        fv.mazeEmotionalState = latest.emotionalState
      }
      fv.mazeSessionCount = mazeData.sessions.count
      fv.mazeDigitalSignature = mazeData.digitalSignature?.dimensions
    }

    // Profile & context
    if let profile = ProfileManager.shared.currentProfile {
      fv.trainingGoal = profile.trainingGoal.rawValue
    }
    let now = Calendar.current.dateComponents([.hour, .weekday], from: Date())
    fv.timeOfDay = now.hour ?? 12
    fv.dayOfWeek = now.weekday ?? 1

    // Health-performance correlations
    let correlations = ProfileManager.shared.getHealthCorrelations(limit: 20)
    if correlations.count >= 5 {
      fv.hrvPerformanceCorrelation = computeCorrelation(
        correlations.compactMap { $0.healthSnapshot.heartRateVariability },
        correlations.map { Double($0.sessionScore) }
      )
      fv.sleepPerformanceCorrelation = computeCorrelation(
        correlations.compactMap { $0.healthSnapshot.sleepDuration }.map { $0 / 3600.0 },
        correlations.map { Double($0.sessionScore) }
      )
    }

    return fv
  }

  // MARK: - Recommendation Generation

  /// Generate a recommendation using the tiered system
  func generateRecommendation() -> GoldenModeRecommendation {
    let features = buildFeatureVector()
    preSessionFeatures = features

    let sessionCount = features.sessionCount

    // Tier selection based on session count
    if sessionCount < 5 {
      // Tier 1: Pure rule engine
      currentTier = "Rule Engine"
      let rec = ruleEngine.recommend(from: features)
      currentRecommendation = rec
      return rec
    }

    if sessionCount < 20 || !classifier.isModelAvailable {
      // Tier 2: Weighted scorer (blended with rules)
      currentTier = "Weighted Scorer"
      let scorerRec = scorer.recommend(from: features)
      let ruleRec = ruleEngine.recommend(from: features)

      // Blend: alpha increases from 0 to 1 as session count goes from 5 to 20
      let alpha = min(Double(sessionCount - 5) / 15.0, 1.0)

      // Use scorer if alpha > 0.5, otherwise rules
      let rec = alpha > 0.5 ? scorerRec : ruleRec
      currentRecommendation = rec
      return rec
    }

    // Tier 3: ML classifier (blended with scorer)
    currentTier = "ML Classifier"
    if let mlRec = classifier.recommend(from: features) {
      if mlRec.confidenceScore >= 0.6 {
        currentRecommendation = mlRec
        return mlRec
      }
      // Low confidence: fall back to scorer
      let scorerRec = scorer.recommend(from: features)
      currentRecommendation = scorerRec
      return scorerRec
    }

    // Fallback to scorer
    let scorerRec = scorer.recommend(from: features)
    currentRecommendation = scorerRec
    return scorerRec
  }

  // MARK: - Coherence Score

  /// Compute the coherence score (0-100)
  func computeCoherence(features: GoldenModeFeatureVector? = nil) -> Double {
    let fv = features ?? buildFeatureVector()
    var score = 0.0

    let hasMaze = fv.hasMazeData

    // Dynamic weights based on data availability
    let wHealthFresh:  Double = hasMaze ? 0.15 : 0.20
    let wHealthAlign:  Double = hasMaze ? 0.20 : 0.25
    let wSkillTraject: Double = hasMaze ? 0.15 : 0.20
    let wCrossApp:     Double = hasMaze ? 0.30 : 0.15
    let wConsistency:  Double = 0.20

    // Health freshness (decays over 24h)
    if let snapshot = HealthKitManager.shared.latestHealthSnapshot {
      let hoursSinceSync = Date().timeIntervalSince(snapshot.date) / 3600.0
      let freshness = max(0, 1.0 - hoursSinceSync / 24.0)
      score += freshness * 100 * wHealthFresh
    }

    // Health-performance alignment
    if let hrv = fv.hrvPerformanceCorrelation {
      let alignment = (hrv + 1.0) / 2.0 // Map -1..1 to 0..1
      score += alignment * 100 * wHealthAlign
    } else {
      score += 50 * wHealthAlign // Neutral when no data
    }

    // Skill trajectory alignment
    let trajectoryScore = min(max(fv.learningCurveSlope + 0.5, 0), 1.0)
    score += trajectoryScore * 100 * wSkillTraject

    // Cross-app coherence
    if hasMaze, let sig = fv.mazeDigitalSignature, !sig.isEmpty {
      // Use digital signature strength as coherence proxy
      let sigStrength = sig.map { abs($0) }.reduce(0, +) / Double(sig.count)
      score += min(sigStrength * 100, 100) * wCrossApp
    } else if hasMaze {
      // Have maze data but no signature — use flow + confidence as proxy
      let flow = fv.mazeFlowState ?? 0.5
      let confidence = fv.mazeConfidence ?? 0.5
      score += ((flow + confidence) / 2.0) * 100 * wCrossApp
    } else {
      score += 30 * wCrossApp // Low baseline without cross-app data
    }

    // Session consistency
    let consistency = max(0, 1.0 - fv.overcorrectionRate)
    score += consistency * 100 * wConsistency

    let finalScore = min(max(score, 0), 100)
    coherenceScore = finalScore
    coherenceLabel = coherenceLabelFor(finalScore)
    return finalScore
  }

  private func coherenceLabelFor(_ score: Double) -> String {
    switch score {
    case 0..<31:  return "Diverging"
    case 31..<61: return "Aligning"
    case 61..<86: return "Resonant"
    default:      return "Coherent"
    }
  }

  // MARK: - Mid-Session Adaptation

  /// Called every frame from PendulumViewModel — returns parameter deltas if adaptation needed
  func onFrameUpdate(
    theta: Double,
    thetaDot: Double,
    elapsedTime: TimeInterval,
    recentStability: Double
  ) -> AdaptationDelta? {
    guard isGoldenModeActive else { return nil }
    guard elapsedTime - lastAdaptationTime >= adaptationInterval else { return nil }

    lastAdaptationTime = elapsedTime
    adaptationCount += 1

    // Evaluate recent performance trend
    let stabilityTrend = recentStability - preSessionStability

    var dampingDelta: Double = 0
    var perturbationScale: Double = 1.0
    var thresholdDelta: Double = 0

    // Damping: easier if struggling, harder if cruising
    if stabilityTrend < -10 {
      dampingDelta = 0.03    // Slight ease
    } else if stabilityTrend > 10 {
      dampingDelta = -0.03   // Slight challenge
    }

    // Perturbation intensity
    if recentStability > 70 {
      perturbationScale = 1.05  // Slight increase
    } else if recentStability < 30 {
      perturbationScale = 0.95  // Slight decrease
    }

    // Balance threshold
    if recentStability < 25 {
      thresholdDelta = 0.015    // Widen (easier)
    } else if recentStability > 80 {
      thresholdDelta = -0.015   // Narrow (harder)
    }

    // Only return if there's actually a change
    let hasChange = dampingDelta != 0 || perturbationScale != 1.0 || thresholdDelta != 0
    guard hasChange else { return nil }

    return AdaptationDelta(
      dampingDelta: dampingDelta,
      perturbationScale: perturbationScale,
      thresholdDelta: thresholdDelta
    )
  }

  struct AdaptationDelta {
    let dampingDelta: Double          // Added to current damping
    let perturbationScale: Double     // Multiplied with current perturbation intensity
    let thresholdDelta: Double        // Added to current balance threshold (radians)
  }

  // MARK: - Session Lifecycle

  func onGoldenSessionStart(recommendation: GoldenModeRecommendation) {
    isGoldenModeActive = true
    sessionStartTime = Date()
    adaptationCount = 0
    lastAdaptationTime = 0
    preSessionFeatures = buildFeatureVector()
    preSessionStability = preSessionFeatures?.stabilityScore ?? 50
    preSessionReactionTime = preSessionFeatures?.averageReactionTime ?? 0.3
    _ = computeCoherence(features: preSessionFeatures)
  }

  func onGoldenSessionEnd(
    sessionDuration: TimeInterval,
    sessionCompleted: Bool,
    levelsCompleted: Int,
    finalStability: Double,
    finalReactionTime: Double,
    score: Int
  ) {
    guard isGoldenModeActive else { return }
    isGoldenModeActive = false

    let coherenceEnd = computeCoherence()

    // Compute improvements
    let stabilityImprovement = finalStability - preSessionStability
    let reactionImprovement = preSessionReactionTime - finalReactionTime

    // Enjoyment proxy: normalized duration × completion
    let targetDuration = currentRecommendation?.config.targetDurationMinutes ?? 10.0
    let durationRatio = min(sessionDuration / 60.0 / targetDuration, 1.5)
    let enjoymentProxy = sessionCompleted ? durationRatio : durationRatio * 0.6

    // Create outcome
    let outcome = GoldenModeOutcome(
      recommendation: currentRecommendation,
      wasRecommendationFollowed: true,
      actualGameMode: currentRecommendation?.config.gameMode ?? "Free Play",
      actualAIMode: currentRecommendation?.config.aiMode ?? "Off",
      preSessionFeatures: preSessionFeatures ?? GoldenModeFeatureVector(),
      sessionDuration: sessionDuration,
      sessionCompleted: sessionCompleted,
      stabilityImprovement: stabilityImprovement,
      reactionTimeImprovement: reactionImprovement,
      levelsCompleted: levelsCompleted,
      enjoymentProxy: enjoymentProxy,
      coherenceScoreEnd: coherenceEnd
    )

    recordOutcome(outcome)
  }

  // MARK: - Outcome Recording

  private func recordOutcome(_ outcome: GoldenModeOutcome) {
    outcomes.append(outcome)
    if outcomes.count > maxStoredOutcomes {
      outcomes.removeFirst(outcomes.count - maxStoredOutcomes)
    }
    outcomeCount = outcomes.count

    // Update Tier 2 scorer weights
    scorer.updateFromOutcome(outcome)

    // Add sample to Tier 3 classifier
    classifier.addSample(from: outcome)

    // Check if classifier should retrain
    if classifier.shouldRetrain {
      print("GoldenModeManager: Classifier should retrain (\(classifier.sampleCount) samples)")
      // Training deferred — CreateML is only available in app targets
      // Future: call CreateML training here when running in app context
    }

    // Persist state
    saveLocalState()

    // Upload outcome to Firebase
    Task {
      await uploadOutcome(outcome)
    }
  }

  // MARK: - Data Readiness

  /// Check which data sources are connected
  var dataReadiness: DataReadiness {
    let hasHealth = HealthKitManager.shared.isAuthorized
    let hasProfile = ProfileManager.shared.hasCompletedProfile
    let hasSessions = getSessionFileCount() > 0
    let hasMaze = AppGroupManager.shared.loadMazeData() != nil

    return DataReadiness(
      healthConnected: hasHealth,
      profileComplete: hasProfile,
      hasPlayHistory: hasSessions,
      mazeConnected: hasMaze,
      sessionCount: preSessionFeatures?.sessionCount ?? 0
    )
  }

  struct DataReadiness {
    let healthConnected: Bool
    let profileComplete: Bool
    let hasPlayHistory: Bool
    let mazeConnected: Bool
    let sessionCount: Int

    var isReady: Bool {
      // Minimum requirement: at least some play history
      hasPlayHistory
    }

    var connectedSourceCount: Int {
      var count = 0
      if healthConnected { count += 1 }
      if profileComplete { count += 1 }
      if hasPlayHistory { count += 1 }
      if mazeConnected { count += 1 }
      return count
    }
  }

  // MARK: - Local Persistence

  private let scorerKey = "GoldenMode_ScorerWeights"
  private let outcomesKey = "GoldenMode_Outcomes"
  private let classifierKey = "GoldenMode_ClassifierData"

  private func saveLocalState() {
    // Save scorer weights
    if let data = try? scorer.exportWeights() {
      UserDefaults.standard.set(data, forKey: scorerKey)
    }

    // Save outcomes (last 50 for local, all uploaded to Firebase)
    let recentOutcomes = Array(outcomes.suffix(50))
    if let data = try? JSONEncoder().encode(recentOutcomes) {
      UserDefaults.standard.set(data, forKey: outcomesKey)
    }

    // Save classifier samples
    if let data = try? classifier.exportData() {
      UserDefaults.standard.set(data, forKey: classifierKey)
    }
  }

  private func loadLocalState() {
    // Load scorer weights
    if let data = UserDefaults.standard.data(forKey: scorerKey),
       let loaded = try? GoldenModeScorer.importWeights(from: data) {
      scorer = loaded
    }

    // Load outcomes
    if let data = UserDefaults.standard.data(forKey: outcomesKey),
       let loaded = try? JSONDecoder().decode([GoldenModeOutcome].self, from: data) {
      outcomes = loaded
      outcomeCount = loaded.count
    }

    // Load classifier data
    if let data = UserDefaults.standard.data(forKey: classifierKey) {
      try? classifier.importData(from: data)
    }
  }

  // MARK: - Firebase Persistence

  private func uploadOutcome(_ outcome: GoldenModeOutcome) async {
    guard let uid = FirebaseManager.shared.uid else { return }

    do {
      let data = try JSONEncoder().encode(outcome)
      let path = "users/\(uid)/\(FirebaseManager.goldenModePath)/outcomes/\(outcome.id.uuidString).json"
      let storageRef = FirebaseManager.shared.storageRef(for: path)
      let metadata = FirebaseManager.shared.jsonMetadata()
      _ = try await storageRef.putDataAsync(data, metadata: metadata)
      print("GoldenModeManager: Uploaded outcome \(outcome.id.uuidString)")
    } catch {
      print("GoldenModeManager: Failed to upload outcome: \(error)")
    }
  }

  func uploadModelState() async {
    guard let uid = FirebaseManager.shared.uid else { return }

    do {
      let state = ModelState(
        version: 1,
        lastTrainedDate: classifier.trainingHistory.last?.date ?? Date(),
        sessionCount: preSessionFeatures?.sessionCount ?? 0,
        outcomeCount: outcomeCount,
        classifierAvailable: classifier.isModelAvailable,
        trainingHistory: classifier.trainingHistory.map {
          ModelState.TrainingEntry(date: $0.date, samples: $0.sampleCount, accuracy: $0.accuracy)
        }
      )

      let data = try JSONEncoder().encode(state)
      let path = "users/\(uid)/\(FirebaseManager.goldenModePath)/model_state.json"
      let storageRef = FirebaseManager.shared.storageRef(for: path)
      let metadata = FirebaseManager.shared.jsonMetadata()
      _ = try await storageRef.putDataAsync(data, metadata: metadata)
      print("GoldenModeManager: Uploaded model state")

      // Also upload scorer weights
      let scorerData = try scorer.exportWeights()
      let scorerPath = "users/\(uid)/\(FirebaseManager.goldenModePath)/scorer_weights.json"
      let scorerRef = FirebaseManager.shared.storageRef(for: scorerPath)
      _ = try await scorerRef.putDataAsync(scorerData, metadata: metadata)
    } catch {
      print("GoldenModeManager: Failed to upload model state: \(error)")
    }
  }

  /// Sync model state and outcomes from Firebase (call on app launch after sign-in)
  func syncFromFirebase() async {
    guard let uid = FirebaseManager.shared.uid else { return }

    // Download scorer weights
    do {
      let scorerPath = "users/\(uid)/\(FirebaseManager.goldenModePath)/scorer_weights.json"
      let scorerRef = FirebaseManager.shared.storageRef(for: scorerPath)
      let data = try await scorerRef.data(maxSize: 1 * 1024 * 1024)
      if let loaded = try? GoldenModeScorer.importWeights(from: data) {
        await MainActor.run {
          scorer = loaded
          print("GoldenModeManager: Synced scorer weights from Firebase")
        }
      }
    } catch {
      print("GoldenModeManager: No scorer weights in Firebase (first run): \(error.localizedDescription)")
    }

    // Download model state (for metadata)
    do {
      let statePath = "users/\(uid)/\(FirebaseManager.goldenModePath)/model_state.json"
      let stateRef = FirebaseManager.shared.storageRef(for: statePath)
      let data = try await stateRef.data(maxSize: 1 * 1024 * 1024)
      let state = try JSONDecoder().decode(ModelState.self, from: data)
      await MainActor.run {
        // Only update if remote has more data
        if state.outcomeCount > outcomeCount {
          print("GoldenModeManager: Remote has \(state.outcomeCount) outcomes vs local \(outcomeCount)")
        }
      }
    } catch {
      print("GoldenModeManager: No model state in Firebase: \(error.localizedDescription)")
    }

    // Upload current model state (ensures Firebase is up-to-date)
    await uploadModelState()
  }

  // MARK: - Helper Types

  private struct ModelState: Codable {
    let version: Int
    let lastTrainedDate: Date
    let sessionCount: Int
    let outcomeCount: Int
    let classifierAvailable: Bool
    let trainingHistory: [TrainingEntry]

    struct TrainingEntry: Codable {
      let date: Date
      let samples: Int
      let accuracy: Double
    }
  }

  // MARK: - Correlation Helper

  private func computeCorrelation(_ x: [Double], _ y: [Double]) -> Double? {
    guard x.count == y.count, x.count >= 5 else { return nil }
    let n = Double(x.count)
    let meanX = x.reduce(0, +) / n
    let meanY = y.reduce(0, +) / n
    var cov = 0.0, varX = 0.0, varY = 0.0
    for i in 0..<x.count {
      let dx = x[i] - meanX
      let dy = y[i] - meanY
      cov += dx * dy
      varX += dx * dx
      varY += dy * dy
    }
    guard varX > 0, varY > 0 else { return nil }
    return cov / sqrt(varX * varY)
  }

  // MARK: - Session File Helpers (avoid singleton dependency on CSVSessionManager)

  /// Count session CSV files in the Documents/Sessions directory
  private func getSessionFileCount() -> Int {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let sessionsPath = documentsPath.appendingPathComponent("Sessions", isDirectory: true)
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: sessionsPath, includingPropertiesForKeys: nil
    ) else { return 0 }
    return files.filter { $0.pathExtension == "csv" }.count
  }

  /// Get the creation date of the most recent session file
  private func getLatestSessionDate() -> Date? {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let sessionsPath = documentsPath.appendingPathComponent("Sessions", isDirectory: true)
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: sessionsPath, includingPropertiesForKeys: [.creationDateKey]
    ) else { return nil }

    let csvFiles = files.filter { $0.pathExtension == "csv" }
    let dates = csvFiles.compactMap {
      try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate
    }
    return dates.max()
  }
}
