// AppGroupManager.swift
// The Pendulum 2.0
// Writes session data to App Group shared container for cross-app integration (The Maze)

import Foundation

// MARK: - Shared Data Contract (must match The Maze's PendulumDataService)

struct PendulumSharedData: Codable {
  let sessions: [PendulumSessionRecord]
  let lastUpdated: Date

  struct PendulumSessionRecord: Codable {
    let sessionId: String
    let date: Date
    let durationSeconds: Double
    let balancePercent: Double       // 0-100
    let averageReactionTime: Double  // seconds
    let angleVariance: Double        // degrees
    let level: Int
    let score: Double
  }
}

// MARK: - App Group Manager

class AppGroupManager {
  static let shared = AppGroupManager()

  private let appGroup = "group.com.goldenenterprise.shared"
  private let filename = "pendulum_sessions.json"

  private init() {}

  /// Write a completed session to the shared App Group container.
  /// Called from GameState.endSession().
  func writeSession(
    sessionId: String,
    duration: TimeInterval,
    balancePercent: Double,
    averageReactionTime: Double,
    angleVariance: Double,
    level: Int,
    score: Int
  ) {
    guard let container = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroup
    ) else {
      print("AppGroupManager: Cannot access shared container")
      return
    }

    let fileURL = container.appendingPathComponent(filename)

    // Load existing sessions (or start fresh)
    var shared: PendulumSharedData
    if let existing = try? Data(contentsOf: fileURL),
       let decoded = try? JSONDecoder().decode(PendulumSharedData.self, from: existing) {
      shared = decoded
    } else {
      shared = PendulumSharedData(sessions: [], lastUpdated: Date())
    }

    // Create new record
    let record = PendulumSharedData.PendulumSessionRecord(
      sessionId: sessionId,
      date: Date(),
      durationSeconds: duration,
      balancePercent: balancePercent,
      averageReactionTime: averageReactionTime,
      angleVariance: angleVariance,
      level: level,
      score: Double(score)
    )

    // Append and write back
    var sessions = shared.sessions
    sessions.append(record)
    shared = PendulumSharedData(sessions: sessions, lastUpdated: Date())

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    if let data = try? encoder.encode(shared) {
      try? data.write(to: fileURL, options: .atomic)
      print("AppGroupManager: Wrote session \(sessionId) (\(sessions.count) total)")
    }
  }
}
