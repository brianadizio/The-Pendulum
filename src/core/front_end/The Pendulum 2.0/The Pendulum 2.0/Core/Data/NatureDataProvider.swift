// NatureDataProvider.swift
// The Pendulum 2.0
// Extracts waveform data and attempt structures from CSV sessions for the Balance Timeline

import Foundation

// MARK: - Data Structures

struct AttemptData: Identifiable {
  let id = UUID()
  let attemptNumber: Int
  let startTime: Double
  let endTime: Double
  let duration: TimeInterval
  let angleSamples: [(time: Double, angle: Double)]
  let correctionEvents: [(time: Double, direction: Int, magnitude: Double)]
  let fellAtEnd: Bool
}

enum AnnotationType: String, Codable {
  case longestStableStreak
  case bestRecovery
  case fallPoint
}

struct WaveformAnnotation: Identifiable {
  let id = UUID()
  let type: AnnotationType
  let time: Double
  let endTime: Double?
  let angle: Double
  let label: String
}

struct NatureData {
  let attempts: [AttemptData]
  let annotations: [WaveformAnnotation]
  let stabilityScore: Double
  let archetypeResult: ArchetypeResult
  let totalDuration: TimeInterval
  let allAngleSamples: [(time: Double, angle: Double)]
}

// MARK: - Provider

enum NatureDataProvider {

  /// Extract nature data from the most recent session(s)
  /// Uses the current/most recent session's CSV data
  static func extractNatureData(from sessionManager: CSVSessionManager) -> NatureData? {
    // Flush current session if recording
    if sessionManager.isRecording {
      sessionManager.flushCurrentSession()
    }

    // Gather session URLs: current + recent saved (up to 5 most recent)
    var sessionURLs: [URL] = []
    let savedSessions = sessionManager.getAllSessions()
    if sessionManager.isRecording, let currentPath = sessionManager.csvFilePath {
      // Current session might also appear in saved list; deduplicate
      sessionURLs.append(currentPath)
      for url in savedSessions where url != currentPath {
        sessionURLs.append(url)
        if sessionURLs.count >= 5 { break }
      }
    } else {
      sessionURLs = Array(savedSessions.prefix(5))
    }

    print("[Nature] Found \(sessionURLs.count) session files to analyze")
    guard !sessionURLs.isEmpty else {
      print("[Nature] FAIL: No sessions found")
      return nil
    }

    // Each session = one attempt (since the game ends the session on fall)
    var allAttempts: [AttemptData] = []
    var allAngleSamples: [(time: Double, angle: Double)] = []
    var allCorrections: [(time: Double, direction: Int, magnitude: Double)] = []
    var allBalanceFlags: [(time: Double, isBalanced: Bool)] = []
    var timeOffset: Double = 0.0

    // Process sessions in chronological order (getAllSessions returns newest first)
    for sessionURL in sessionURLs.reversed() {
      guard let rows = sessionManager.readSessionData(from: sessionURL) else {
        print("[Nature] SKIP \(sessionURL.lastPathComponent): could not read")
        continue
      }
      guard rows.count >= 2 else {
        print("[Nature] SKIP \(sessionURL.lastPathComponent): only \(rows.count) rows")
        continue
      }

      let parsed = parseCSVRows(rows)
      guard parsed.angleSamples.count >= 2 else {
        print("[Nature] SKIP \(sessionURL.lastPathComponent): only \(parsed.angleSamples.count) angle samples")
        continue
      }

      // Filter out initialization frames where angle is near -π (pendulum at bottom)
      let filtered = parsed.angleSamples.filter { abs($0.angle) < 2.0 }
      // Check game mode from CSV
      let gameMode = rows.first?["gameMode"] ?? "unknown"
      print("[Nature] \(sessionURL.lastPathComponent): \(parsed.angleSamples.count) raw -> \(filtered.count) after init filter (first angle: \(String(format: "%.3f", parsed.angleSamples.first?.angle ?? 0)), mode: \(gameMode))")
      guard filtered.count >= 2 else {
        print("[Nature] SKIP \(sessionURL.lastPathComponent): only \(filtered.count) valid samples after filtering")
        continue
      }

      // Offset timestamps so attempts are sequential on the timeline
      let sessionStart = filtered.first!.time
      let sessionEnd = filtered.last!.time
      let duration = sessionEnd - sessionStart
      guard duration > 0.1 else { continue }

      let offsetSamples: [(time: Double, angle: Double)] = filtered.map { s in
        (time: s.time - sessionStart + timeOffset, angle: s.angle)
      }
      let offsetCorrections: [(time: Double, direction: Int, magnitude: Double)] = parsed.corrections.map { c in
        (time: c.time - sessionStart + timeOffset, direction: c.direction, magnitude: c.magnitude)
      }
      let offsetBalance: [(time: Double, isBalanced: Bool)] = parsed.balanceFlags.map { b in
        (time: b.time - sessionStart + timeOffset, isBalanced: b.isBalanced)
      }

      let attempt = AttemptData(
        attemptNumber: allAttempts.count + 1,
        startTime: timeOffset,
        endTime: timeOffset + duration,
        duration: duration,
        angleSamples: offsetSamples,
        correctionEvents: offsetCorrections,
        fellAtEnd: true // Each session ends on a fall
      )

      allAttempts.append(attempt)
      allAngleSamples.append(contentsOf: offsetSamples)
      allCorrections.append(contentsOf: offsetCorrections)
      allBalanceFlags.append(contentsOf: offsetBalance)

      print("[Nature] Session \(sessionURL.lastPathComponent): \(filtered.count) samples, \(String(format: "%.1f", duration))s")

      timeOffset += duration + 0.5 // Small gap between attempts visually
    }

    print("[Nature] Total: \(allAttempts.count) attempts, \(allAngleSamples.count) samples")
    guard !allAttempts.isEmpty else {
      print("[Nature] FAIL: No valid attempts")
      return nil
    }

    // If only 1 valid session, try to split it into sub-attempts
    // by detecting angle resets within the session (e.g., peaks followed by returns to center)
    if allAttempts.count == 1, let singleAttempt = allAttempts.first,
       singleAttempt.angleSamples.count >= 20 {
      let subAttempts = splitSingleSessionIntoAttempts(singleAttempt)
      if subAttempts.count > 1 {
        print("[Nature] Split single session into \(subAttempts.count) sub-attempts: \(subAttempts.map { String(format: "%.1fs", $0.duration) })")
        allAttempts = subAttempts
      }
    }

    // Compute annotations
    let annotations = computeAnnotations(
      attempts: allAttempts,
      angleSamples: allAngleSamples,
      balanceFlags: allBalanceFlags
    )

    // Compute stability score
    let stabilityScore = computeStabilityScore(
      attempts: allAttempts,
      balanceFlags: allBalanceFlags
    )

    // Classify archetype
    let attemptDurations = allAttempts.map { $0.duration }
    let archetypeResult = ArchetypeClassifier.classify(
      angleSamples: allAngleSamples,
      correctionSamples: allCorrections,
      attemptDurations: attemptDurations
    )

    let totalDuration = (allAngleSamples.last?.time ?? 0) - (allAngleSamples.first?.time ?? 0)

    return NatureData(
      attempts: allAttempts,
      annotations: annotations,
      stabilityScore: stabilityScore,
      archetypeResult: archetypeResult,
      totalDuration: totalDuration,
      allAngleSamples: allAngleSamples
    )
  }

  // MARK: - Multi-Day Extraction

  /// Extract nature data grouped by calendar play day
  /// Returns dict keyed by day number (1-based chronological)
  static func extractNatureDataByDay(from sessionManager: CSVSessionManager) -> [Int: NatureData] {
    let playDays = CSVSessionManager.getPlayDays() // sorted yyyy-MM-dd strings
    guard !playDays.isEmpty else { return [:] }

    let allSessions = sessionManager.getAllSessions() // newest first
    var result: [Int: NatureData] = [:]

    for (dayIndex, dayString) in playDays.enumerated() {
      // Find sessions created on this calendar day
      let daySessions = allSessions.filter { url in
        guard let creationDate = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) else { return false }
        return CSVSessionManager.calendarDayString(from: creationDate) == dayString
      }

      guard !daySessions.isEmpty else { continue }

      // Build NatureData from this day's sessions using same logic as extractNatureData
      if let dayData = extractNatureDataFromURLs(daySessions, sessionManager: sessionManager) {
        result[dayIndex + 1] = dayData
      }
    }

    return result
  }

  /// Extract NatureData from a specific set of session URLs
  private static func extractNatureDataFromURLs(_ sessionURLs: [URL], sessionManager: CSVSessionManager) -> NatureData? {
    var allAttempts: [AttemptData] = []
    var allAngleSamples: [(time: Double, angle: Double)] = []
    var allCorrections: [(time: Double, direction: Int, magnitude: Double)] = []
    var allBalanceFlags: [(time: Double, isBalanced: Bool)] = []
    var timeOffset: Double = 0.0

    // Process in chronological order (getAllSessions returns newest first)
    for sessionURL in sessionURLs.reversed() {
      guard let rows = sessionManager.readSessionData(from: sessionURL) else { continue }
      guard rows.count >= 2 else { continue }

      let parsed = parseCSVRows(rows)
      let filtered = parsed.angleSamples.filter { abs($0.angle) < 2.0 }
      guard filtered.count >= 2 else { continue }

      let sessionStart = filtered.first!.time
      let sessionEnd = filtered.last!.time
      let duration = sessionEnd - sessionStart
      guard duration > 0.1 else { continue }

      let offsetSamples: [(time: Double, angle: Double)] = filtered.map { s in
        (time: s.time - sessionStart + timeOffset, angle: s.angle)
      }
      let offsetCorrections: [(time: Double, direction: Int, magnitude: Double)] = parsed.corrections.map { c in
        (time: c.time - sessionStart + timeOffset, direction: c.direction, magnitude: c.magnitude)
      }
      let offsetBalance: [(time: Double, isBalanced: Bool)] = parsed.balanceFlags.map { b in
        (time: b.time - sessionStart + timeOffset, isBalanced: b.isBalanced)
      }

      let attempt = AttemptData(
        attemptNumber: allAttempts.count + 1,
        startTime: timeOffset,
        endTime: timeOffset + duration,
        duration: duration,
        angleSamples: offsetSamples,
        correctionEvents: offsetCorrections,
        fellAtEnd: true
      )

      allAttempts.append(attempt)
      allAngleSamples.append(contentsOf: offsetSamples)
      allCorrections.append(contentsOf: offsetCorrections)
      allBalanceFlags.append(contentsOf: offsetBalance)
      timeOffset += duration + 0.5
    }

    guard !allAttempts.isEmpty else { return nil }

    if allAttempts.count == 1, let singleAttempt = allAttempts.first,
       singleAttempt.angleSamples.count >= 20 {
      let subAttempts = splitSingleSessionIntoAttempts(singleAttempt)
      if subAttempts.count > 1 { allAttempts = subAttempts }
    }

    let annotations = computeAnnotations(attempts: allAttempts, angleSamples: allAngleSamples, balanceFlags: allBalanceFlags)
    let stabilityScore = computeStabilityScore(attempts: allAttempts, balanceFlags: allBalanceFlags)
    let attemptDurations = allAttempts.map { $0.duration }
    let archetypeResult = ArchetypeClassifier.classify(angleSamples: allAngleSamples, correctionSamples: allCorrections, attemptDurations: attemptDurations)
    let totalDuration = (allAngleSamples.last?.time ?? 0) - (allAngleSamples.first?.time ?? 0)

    return NatureData(
      attempts: allAttempts, annotations: annotations, stabilityScore: stabilityScore,
      archetypeResult: archetypeResult, totalDuration: totalDuration, allAngleSamples: allAngleSamples
    )
  }

  // MARK: - CSV Parsing

  private struct ParsedData {
    let angleSamples: [(time: Double, angle: Double)]
    let corrections: [(time: Double, direction: Int, magnitude: Double)]
    let balanceFlags: [(time: Double, isBalanced: Bool)]
    let levelChanges: [(time: Double, fromLevel: Int, toLevel: Int)]
  }

  private static func parseCSVRows(_ rows: [[String: String]]) -> ParsedData {
    var angleSamples: [(time: Double, angle: Double)] = []
    var corrections: [(time: Double, direction: Int, magnitude: Double)] = []
    var balanceFlags: [(time: Double, isBalanced: Bool)] = []
    var levelChanges: [(time: Double, fromLevel: Int, toLevel: Int)] = []
    var lastLevel: Int? = nil

    for row in rows {
      guard let timeStr = row["timestamp"], let time = Double(timeStr) else { continue }
      guard let angleStr = row["angle"], let rawAngle = Double(angleStr) else { continue }

      // Convert from raw theta (upright = π) to deviation from upright
      // So balanced ≈ 0, tilting left/right = positive/negative
      let angle = rawAngle - .pi

      // Only include valid angle data points
      if angle.isFinite {
        angleSamples.append((time: time, angle: angle))
      }

      // Track level changes (demotions = fall boundaries)
      if let levelStr = row["level"], let level = Int(levelStr) {
        if let prev = lastLevel, level != prev {
          levelChanges.append((time: time, fromLevel: prev, toLevel: level))
        }
        lastLevel = level
      }

      // Parse balance flag
      let isBalanced = row["isBalanced"]?.lowercased() == "true"
      balanceFlags.append((time: time, isBalanced: isBalanced))

      // Parse push events
      if let dirStr = row["pushDirection"], let dir = Int(dirStr), dir != 0,
         let magStr = row["pushMagnitude"], let mag = Double(magStr), mag > 0 {
        corrections.append((time: time, direction: dir, magnitude: mag))
      }
    }

    return ParsedData(
      angleSamples: angleSamples,
      corrections: corrections,
      balanceFlags: balanceFlags,
      levelChanges: levelChanges
    )
  }

  // MARK: - Single Session Splitting

  /// Split a single long session into sub-attempts by detecting peaks (loss of control)
  /// followed by returns to center. In Free Play, the session records continuously
  /// through multiple wobble-recovery cycles.
  private static func splitSingleSessionIntoAttempts(_ attempt: AttemptData) -> [AttemptData] {
    let samples = attempt.angleSamples
    guard samples.count >= 20 else { return [attempt] }

    // Find major fall-recovery boundaries: angle exceeds a large threshold
    // (near-fall) then returns close to center. Only split on BIG events,
    // not normal wobbles. Cap at 3 splits max (4 attempts).
    let fallThreshold = 0.7  // ~40 degrees — a serious loss of control
    let recoveryThreshold = 0.15  // ~8.5 degrees — back to near-balanced
    var splitPoints: [Int] = []
    var wasBig = false

    for i in 0..<samples.count {
      let absAngle = abs(samples[i].angle)
      if absAngle > fallThreshold {
        wasBig = true
      } else if wasBig && absAngle < recoveryThreshold {
        wasBig = false
        // Only split if the previous attempt was at least 1 second long
        let lastSplit = splitPoints.last ?? 0
        let timeSinceLast = samples[i].time - samples[lastSplit].time
        if timeSinceLast > 1.0 {
          splitPoints.append(i)
        }
      }
      if splitPoints.count >= 3 { break } // Cap at 3 splits
    }

    // Need at least 1 split point to create 2+ attempts
    guard !splitPoints.isEmpty else { return [attempt] }

    // Build sub-attempts from split points
    var subAttempts: [AttemptData] = []
    var startIdx = 0

    for splitIdx in splitPoints {
      let subSamples = Array(samples[startIdx..<splitIdx])
      guard subSamples.count >= 3 else { startIdx = splitIdx; continue }

      let subCorrections = attempt.correctionEvents.filter { c in
        c.time >= subSamples.first!.time && c.time <= subSamples.last!.time
      }

      subAttempts.append(AttemptData(
        attemptNumber: subAttempts.count + 1,
        startTime: subSamples.first!.time,
        endTime: subSamples.last!.time,
        duration: subSamples.last!.time - subSamples.first!.time,
        angleSamples: subSamples,
        correctionEvents: subCorrections,
        fellAtEnd: true
      ))
      startIdx = splitIdx
    }

    // Final segment (from last split to end)
    let finalSamples = Array(samples[startIdx...])
    if finalSamples.count >= 3 {
      let finalCorrections = attempt.correctionEvents.filter { c in
        c.time >= finalSamples.first!.time && c.time <= finalSamples.last!.time
      }
      subAttempts.append(AttemptData(
        attemptNumber: subAttempts.count + 1,
        startTime: finalSamples.first!.time,
        endTime: finalSamples.last!.time,
        duration: finalSamples.last!.time - finalSamples.first!.time,
        angleSamples: finalSamples,
        correctionEvents: finalCorrections,
        fellAtEnd: true
      ))
    }

    return subAttempts.isEmpty ? [attempt] : subAttempts
  }

  // MARK: - Attempt Splitting

  private static func splitIntoAttempts(
    angleSamples: [(time: Double, angle: Double)],
    corrections: [(time: Double, direction: Int, magnitude: Double)],
    balanceFlags: [(time: Double, isBalanced: Bool)],
    levelChanges: [(time: Double, fromLevel: Int, toLevel: Int)] = []
  ) -> [AttemptData] {
    guard angleSamples.count >= 2 else { return [] }

    // Primary method: use level demotions as fall boundaries
    // A demotion (level decreases) means the player fell
    let demotionTimes = levelChanges
      .filter { $0.toLevel < $0.fromLevel }
      .map { $0.time }

    var boundaries: [Int] = [0]

    if !demotionTimes.isEmpty {
      // Find the sample index closest to each demotion time
      for demotionTime in demotionTimes {
        if let idx = angleSamples.firstIndex(where: { $0.time >= demotionTime }) {
          if idx > boundaries.last! + 2 { // Skip if too close to previous boundary
            boundaries.append(idx)
          }
        }
      }
    } else {
      // Fallback: detect angle resets
      for i in 1..<angleSamples.count {
        let prevAngle = abs(angleSamples[i - 1].angle)
        let currAngle = abs(angleSamples[i].angle)
        let timeGap = angleSamples[i].time - angleSamples[i - 1].time

        let wasFar = prevAngle > 0.3
        let isNearCenter = currAngle < 0.15
        let suddenDrop = (prevAngle - currAngle) > 0.25
        let hasTimeGap = timeGap > 1.0

        if (wasFar && isNearCenter && suddenDrop) || hasTimeGap {
          boundaries.append(i)
        }
      }
    }

    boundaries.append(angleSamples.count)

    // Build attempts from boundaries
    var attempts: [AttemptData] = []
    for b in 0..<(boundaries.count - 1) {
      let startIdx = boundaries[b]
      let endIdx = boundaries[b + 1]
      guard endIdx - startIdx >= 5 else { continue } // Skip tiny fragments

      let attemptSamples = Array(angleSamples[startIdx..<endIdx])
      let startTime = attemptSamples.first!.time
      let endTime = attemptSamples.last!.time
      let duration = endTime - startTime
      guard duration > 0.1 else { continue }

      // Corrections within this attempt's time range
      let attemptCorrections = corrections.filter { $0.time >= startTime && $0.time <= endTime }

      // Did this attempt end in a fall? (angle > ~17 degrees from upright)
      let lastAngle = abs(attemptSamples.last!.angle)
      let fellAtEnd = lastAngle > 0.3

      attempts.append(AttemptData(
        attemptNumber: attempts.count + 1,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        angleSamples: attemptSamples,
        correctionEvents: attemptCorrections,
        fellAtEnd: fellAtEnd
      ))
    }

    return attempts
  }

  // MARK: - Annotations

  private static func computeAnnotations(
    attempts: [AttemptData],
    angleSamples: [(time: Double, angle: Double)],
    balanceFlags: [(time: Double, isBalanced: Bool)]
  ) -> [WaveformAnnotation] {
    var annotations: [WaveformAnnotation] = []

    // 1. Longest stable streak
    if let streak = findLongestStableStreak(balanceFlags: balanceFlags) {
      annotations.append(WaveformAnnotation(
        type: .longestStableStreak,
        time: streak.startTime,
        endTime: streak.endTime,
        angle: 0.0,
        label: String(format: "Best streak: %.1fs", streak.duration)
      ))
    }

    // 2. Best recovery
    if let recovery = findBestRecovery(angleSamples: angleSamples) {
      annotations.append(WaveformAnnotation(
        type: .bestRecovery,
        time: recovery.time,
        endTime: nil,
        angle: recovery.angle,
        label: "Recovery"
      ))
    }

    // 3. Fall points
    for attempt in attempts where attempt.fellAtEnd {
      if let lastSample = attempt.angleSamples.last {
        annotations.append(WaveformAnnotation(
          type: .fallPoint,
          time: lastSample.time,
          endTime: nil,
          angle: lastSample.angle,
          label: ""
        ))
      }
    }

    return annotations
  }

  private static func findLongestStableStreak(
    balanceFlags: [(time: Double, isBalanced: Bool)]
  ) -> (startTime: Double, endTime: Double, duration: Double)? {
    guard !balanceFlags.isEmpty else { return nil }

    var bestStart = balanceFlags[0].time
    var bestDuration = 0.0
    var currentStart = balanceFlags[0].time
    var inStreak = balanceFlags[0].isBalanced

    for i in 1..<balanceFlags.count {
      if balanceFlags[i].isBalanced {
        if !inStreak {
          currentStart = balanceFlags[i].time
          inStreak = true
        }
        let duration = balanceFlags[i].time - currentStart
        if duration > bestDuration {
          bestDuration = duration
          bestStart = currentStart
        }
      } else {
        inStreak = false
      }
    }

    guard bestDuration > 0.3 else { return nil }
    return (startTime: bestStart, endTime: bestStart + bestDuration, duration: bestDuration)
  }

  private static func findBestRecovery(
    angleSamples: [(time: Double, angle: Double)]
  ) -> (time: Double, angle: Double)? {
    guard angleSamples.count >= 20 else { return nil }

    // Find largest rapid correction: angle was >15deg (0.26 rad) and came back to <5deg (0.087 rad) within 1s
    let largeAngleThreshold = 0.26  // ~15 degrees
    let recoveredThreshold = 0.087  // ~5 degrees
    let windowSeconds = 1.0

    var bestRecovery: (time: Double, angle: Double)?
    var bestRecoveryMagnitude = 0.0

    for i in 0..<angleSamples.count {
      let startAngle = abs(angleSamples[i].angle)
      guard startAngle > largeAngleThreshold else { continue }

      // Look ahead within 1 second
      for j in (i + 1)..<angleSamples.count {
        let timeDiff = angleSamples[j].time - angleSamples[i].time
        if timeDiff > windowSeconds { break }

        let endAngle = abs(angleSamples[j].angle)
        if endAngle < recoveredThreshold {
          let magnitude = startAngle - endAngle
          if magnitude > bestRecoveryMagnitude {
            bestRecoveryMagnitude = magnitude
            bestRecovery = (time: angleSamples[i].time, angle: angleSamples[i].angle)
          }
          break
        }
      }
    }

    return bestRecovery
  }

  // MARK: - Stability Score

  private static func computeStabilityScore(
    attempts: [AttemptData],
    balanceFlags: [(time: Double, isBalanced: Bool)]
  ) -> Double {
    guard !attempts.isEmpty else { return 0.0 }

    let referenceMax = 30.0 // seconds

    // 1. Average time before fall (60% weight)
    let avgDuration = attempts.map { $0.duration }.reduce(0, +) / Double(attempts.count)
    let durationScore = min(avgDuration / referenceMax, 1.0) * 60.0

    // 2. Percentage of time in stable zone (30% weight)
    let totalFlags = balanceFlags.count
    let balancedFlags = balanceFlags.filter { $0.isBalanced }.count
    let stablePercent = totalFlags > 0 ? Double(balancedFlags) / Double(totalFlags) : 0.0
    let stableScore = stablePercent * 30.0

    // 3. Best single streak duration (10% weight)
    if let streak = findLongestStableStreak(balanceFlags: balanceFlags) {
      let streakScore = min(streak.duration / referenceMax, 1.0) * 10.0
      return min(durationScore + stableScore + streakScore, 100.0)
    }

    return min(durationScore + stableScore, 100.0)
  }
}
