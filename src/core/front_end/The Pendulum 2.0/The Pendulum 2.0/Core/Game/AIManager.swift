// AIManager.swift
// The Pendulum 2.0
// Singleton wrapper for HybridPendulumSolver — manages AI modes, per-frame control, and adaptive learning

import Foundation
import Combine
import PendulumSolver
import FirebaseStorage

// MARK: - AI Mode (User-Facing)

enum AIMode: String, CaseIterable, Identifiable {
  case off = "Off"
  case competition = "Competition"
  case helper = "Helper"
  case tutorial = "Tutorial"
  case demo = "Demo"

  var id: String { rawValue }

  var icon: String {
    switch self {
    case .off:         return "sparkles"
    case .competition: return "figure.fencing"
    case .helper:      return "hands.sparkles"
    case .tutorial:    return "lightbulb"
    case .demo:        return "play.display"
    }
  }

  var description: String {
    switch self {
    case .off:         return "AI disabled"
    case .competition: return "AI opponent tries to knock you off balance"
    case .helper:      return "AI assists when you struggle"
    case .tutorial:    return "Step-by-step lessons with guided hints"
    case .demo:        return "AI fully controls the pendulum"
    }
  }

  /// Map to solver's internal Mode enum
  var solverMode: HybridPendulumSolver.Mode? {
    switch self {
    case .off:         return nil
    case .competition: return .opponent
    case .helper:      return .assistant
    case .tutorial:    return .tutorial
    case .demo:        return .demo
    }
  }
}

// MARK: - AI Manager

class AIManager: ObservableObject {
  static let shared = AIManager()

  // MARK: - Published State

  @Published var currentMode: AIMode = .off
  @Published var isActive: Bool = false
  @Published var difficulty: Double = 0.5
  @Published var currentHint: TutorialMode.Hint?
  @Published var lastAIForce: Double = 0.0

  // MARK: - Callback

  /// Called per-frame when AI wants to apply force. Wire to viewModel.applyExternalForce()
  var onApplyForce: ((Double) -> Void)?

  // MARK: - Private Properties

  private let solver: HybridPendulumSolver
  private var metricsBuffer: [(theta: Double, thetaDot: Double, playerForce: Double, timestamp: TimeInterval)] = []
  private var lastMetricsFlush: TimeInterval = 0
  private let metricsFlushInterval: TimeInterval = 1.0  // Flush every ~1 second
  private let metricsBufferMaxSize: Int = 300           // ~5 seconds at 60fps

  // Session tracking
  private var sessionStartTime: Date?
  private var totalControlCalls: Int = 0
  private var totalInterventions: Int = 0  // Frames where AI applied non-zero force

  // MARK: - Initialization

  private init() {
    solver = HybridPendulumSolver()
  }

  // MARK: - Physics Configuration

  /// Sync solver physics config with game physics. Called from PendulumViewModel.updateParameters().
  func configurePhysics(mass: Double, length: Double, gravity: Double, damping: Double, springConstant: Double, momentOfInertia: Double) {
    var config = HybridPendulumSolver.PhysicsConfig()
    config.mass = mass
    config.length = length
    config.gravity = gravity
    config.damping = damping
    config.springConstant = springConstant
    config.momentOfInertia = momentOfInertia
    solver.physicsConfig = config
  }

  // MARK: - Mode Management

  /// Activate or deactivate an AI mode.
  func setMode(_ mode: AIMode, difficulty: Double) {
    self.currentMode = mode
    self.difficulty = difficulty

    if let solverMode = mode.solverMode {
      solver.setMode(solverMode, difficulty: difficulty)
      isActive = true
    } else {
      isActive = false
      currentHint = nil
      lastAIForce = 0.0
    }
  }

  // MARK: - Per-Frame Update

  /// Called every frame from the game loop, after physics step, before perturbation.
  ///
  /// - Parameters:
  ///   - theta: Current angle (radians), pi = upright
  ///   - thetaDot: Current angular velocity (rad/s)
  ///   - time: Current simulation elapsed time
  ///   - playerForce: Force the player applied this frame (0 if none)
  ///   - balanceThreshold: Current balance threshold from level config
  func update(theta: Double, thetaDot: Double, time: TimeInterval, playerForce: Double, balanceThreshold: Double) {
    guard isActive, currentMode != .off else {
      lastAIForce = 0.0
      currentHint = nil
      return
    }

    // 1. Compute AI control
    let aiForce = solver.computeControl(theta: theta, thetaDot: thetaDot, playerInput: playerForce != 0 ? playerForce : nil)

    // 2. Apply force via callback
    if abs(aiForce) > 0.001 {
      onApplyForce?(aiForce)
      totalInterventions += 1
    }
    totalControlCalls += 1
    lastAIForce = aiForce

    // 3. Tutorial hint (only in tutorial mode)
    if currentMode == .tutorial {
      let state = HybridPendulumSolver.PendulumState(theta: theta, thetaDot: thetaDot, time: time)
      currentHint = solver.getTutorialHint(state: state)
    } else {
      currentHint = nil
    }

    // 4. Buffer metrics for adaptive learning
    metricsBuffer.append((theta: theta, thetaDot: thetaDot, playerForce: playerForce, timestamp: time))
    if metricsBuffer.count > metricsBufferMaxSize {
      metricsBuffer.removeFirst(metricsBuffer.count - metricsBufferMaxSize)
    }

    // 5. Flush metrics to solver every ~1 second
    if time - lastMetricsFlush >= metricsFlushInterval {
      flushMetrics(currentTime: time, balanceThreshold: balanceThreshold)
      lastMetricsFlush = time
    }
  }

  // MARK: - Metrics Computation

  private func flushMetrics(currentTime: TimeInterval, balanceThreshold: Double) {
    guard !metricsBuffer.isEmpty else { return }

    // Stability: % of buffered frames within balance threshold
    let balancedCount = metricsBuffer.filter { abs($0.theta - .pi) < balanceThreshold }.count
    let stabilityScore = Double(balancedCount) / Double(metricsBuffer.count) * 100.0

    // Reaction time: average time from imbalance to player push
    var reactionTimes: [Double] = []
    var imbalanceStart: Double?
    for sample in metricsBuffer {
      let deviation = abs(sample.theta - .pi)
      if deviation > balanceThreshold && imbalanceStart == nil {
        imbalanceStart = sample.timestamp
      }
      if let start = imbalanceStart, abs(sample.playerForce) > 0.01 {
        reactionTimes.append(sample.timestamp - start)
        imbalanceStart = nil
      }
    }
    let avgReaction = reactionTimes.isEmpty ? 0.3 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)

    // Force efficiency: pushes that moved pendulum toward upright / total pushes
    var effectivePushes = 0
    var totalPushes = 0
    for sample in metricsBuffer where abs(sample.playerForce) > 0.01 {
      totalPushes += 1
      let deviation = sample.theta - .pi
      // Push is effective if its sign opposes the deviation
      if (deviation > 0 && sample.playerForce < 0) || (deviation < 0 && sample.playerForce > 0) {
        effectivePushes += 1
      }
    }
    let forceEfficiency = totalPushes > 0 ? Double(effectivePushes) / Double(totalPushes) : 0.5

    // Overcorrection: pushes that overshoot past upright
    var overcorrections = 0
    for i in 1..<metricsBuffer.count {
      let prev = metricsBuffer[i - 1]
      let curr = metricsBuffer[i]
      if abs(prev.playerForce) > 0.01 {
        let prevDev = prev.theta - .pi
        let currDev = curr.theta - .pi
        // Sign flip = overshoot
        if prevDev * currDev < 0 && abs(currDev) > balanceThreshold * 0.5 {
          overcorrections += 1
        }
      }
    }
    let overcorrectionRate = totalPushes > 0 ? Double(overcorrections) / Double(totalPushes) : 0.3

    let sessionDuration = sessionStartTime.map { Date().timeIntervalSince($0) } ?? currentTime

    let metrics = PlayerMetrics(
      stabilityScore: stabilityScore,
      averageReactionTime: avgReaction,
      forceEfficiency: forceEfficiency,
      overcorrectionRate: overcorrectionRate,
      sessionDuration: sessionDuration,
      currentLevel: 1  // Will be updated by caller if needed
    )

    solver.updateFromPlayerMetrics(metrics)
  }

  // MARK: - Session Lifecycle

  func onSessionStart() {
    sessionStartTime = Date()
    totalControlCalls = 0
    totalInterventions = 0
    metricsBuffer.removeAll()
    lastMetricsFlush = 0
  }

  func onSessionEnd() {
    // Export training data if AI was active during session
    guard isActive, totalControlCalls > 0 else { return }

    let tempDir = FileManager.default.temporaryDirectory
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let exportURL = tempDir.appendingPathComponent("training_\(timestamp).json")

    do {
      try solver.exportTrainingData(to: exportURL)
      print("AIManager: Exported training data to \(exportURL.lastPathComponent)")

      // Upload to Firebase Storage
      Task {
        await uploadTrainedModel(dataURL: exportURL, timestamp: Date())
      }
    } catch {
      print("AIManager: Failed to export training data: \(error)")
    }

    // Reset session state
    sessionStartTime = nil
    metricsBuffer.removeAll()
    lastMetricsFlush = 0
  }

  // MARK: - Firebase Model Upload

  private func uploadTrainedModel(dataURL: URL, timestamp: Date) async {
    guard let uid = FirebaseManager.shared.uid else {
      print("AIManager: Cannot upload model — not signed in")
      return
    }

    do {
      let data = try Data(contentsOf: dataURL)
      let iso = ISO8601DateFormatter().string(from: timestamp)
      let path = "users/\(uid)/\(FirebaseManager.aiModelsPath)/training_\(iso).json"

      let storageRef = FirebaseManager.shared.storageRef(for: path)
      let metadata = FirebaseManager.shared.jsonMetadata()
      _ = try await storageRef.putDataAsync(data, metadata: metadata)

      print("AIManager: Uploaded trained model to \(path)")

      // Clean up temp file
      try? FileManager.default.removeItem(at: dataURL)
    } catch {
      print("AIManager: Failed to upload trained model: \(error)")
    }
  }

  // MARK: - Session Summary

  /// Summary data for CSV metadata
  var sessionSummary: (controlCalls: Int, interventions: Int, mode: String, difficulty: Double) {
    (totalControlCalls, totalInterventions, currentMode.rawValue, difficulty)
  }
}
