// ArchetypeClassifier.swift
// The Pendulum 2.0
// Classifies player balance style into archetypes using cross-correlation analysis

import Foundation

// MARK: - Archetype Enum

enum PendulumArchetype: String, Codable, CaseIterable {
  case anticipator
  case surfer
  case overcorrector
  case learner
  case responder

  var displayName: String {
    switch self {
    case .anticipator: return "The Anticipator"
    case .surfer: return "The Surfer"
    case .overcorrector: return "The Overcorrector"
    case .learner: return "The Learner"
    case .responder: return "The Responder"
    }
  }

  var insight: String {
    switch self {
    case .anticipator:
      return "You correct before the pendulum fully commits to a direction. Your vestibular system is predicting the physics. Athletes and dancers often show this pattern."
    case .surfer:
      return "You make constant tiny adjustments, like a surfer reading the wave. This is an advanced balance strategy."
    case .overcorrector:
      return "You correct strongly, which sometimes creates new wobbles. Smooth, smaller corrections are the path to stability."
    case .learner:
      return "Your balance is improving rapidly. Your vestibular system is actively recalibrating. Come back tomorrow to see how far this goes."
    case .responder:
      return "You respond to the pendulum after it moves. This is how most people start. Anticipators develop over 3\u{2013}5 days of practice."
    }
  }

  var icon: String {
    switch self {
    case .anticipator: return "eye"
    case .surfer: return "wind"
    case .overcorrector: return "arrow.left.arrow.right"
    case .learner: return "arrow.up.right"
    case .responder: return "hand.raised"
    }
  }

  var color: (red: Double, green: Double, blue: Double) {
    switch self {
    case .anticipator: return (0.30, 0.69, 0.31)   // Green — mastery
    case .surfer: return (0.20, 0.60, 0.86)         // Blue — flow
    case .overcorrector: return (0.95, 0.55, 0.13)  // Orange — energy
    case .learner: return (0.85, 0.65, 0.13)        // Gold — growth
    case .responder: return (0.55, 0.41, 0.60)      // Purple — awareness
    }
  }
}

// MARK: - Classification Result

struct ArchetypeResult: Codable {
  let archetype: PendulumArchetype
  let confidence: Double
  let crossCorrelationPeakLag: Int
  let zeroCrossingRate: Double
  let correctionVariance: Double
  let correctionFrequency: Double
  let attemptDurations: [TimeInterval]
}

// MARK: - Classifier

enum ArchetypeClassifier {

  /// Classify a player's balance style from angle and correction time series data.
  /// - Parameters:
  ///   - angleSamples: Array of (time, angle) pairs at ~50Hz
  ///   - correctionSamples: Array of (time, direction, magnitude) push events
  ///   - attemptDurations: Duration of each attempt before falling
  ///   - totalDuration: Total session time
  static func classify(
    angleSamples: [(time: Double, angle: Double)],
    correctionSamples: [(time: Double, direction: Int, magnitude: Double)],
    attemptDurations: [TimeInterval]
  ) -> ArchetypeResult {

    // Need minimum data to classify
    guard angleSamples.count >= 20, correctionSamples.count >= 5 else {
      return ArchetypeResult(
        archetype: .responder,
        confidence: 0.0,
        crossCorrelationPeakLag: 1,
        zeroCrossingRate: 0.0,
        correctionVariance: 0.0,
        correctionFrequency: 0.0,
        attemptDurations: attemptDurations
      )
    }

    // 1. Downsample angle to 10Hz for cross-correlation
    let downsampledAngle = downsample(angleSamples, targetHz: 10.0)

    // 2. Build correction signal aligned to angle timestamps
    let correctionSignal = buildCorrectionSignal(
      corrections: correctionSamples,
      timestamps: downsampledAngle.map { $0.time }
    )

    // 3. Compute cross-correlation
    let angleValues = downsampledAngle.map { $0.angle }
    let (peakLag, peakCorrelation) = crossCorrelation(
      signal1: angleValues,
      signal2: correctionSignal,
      maxLag: 30
    )

    // 4. Compute zero-crossing rate of corrections relative to angle
    let zeroCrossingRate = computeZeroCrossingRate(
      corrections: correctionSamples,
      angleSamples: angleSamples
    )

    // 5. Compute correction variance and frequency
    let magnitudes = correctionSamples.map { $0.magnitude }
    let meanMag = magnitudes.reduce(0, +) / Double(magnitudes.count)
    let variance = magnitudes.map { pow($0 - meanMag, 2) }.reduce(0, +) / Double(magnitudes.count)
    let stdDev = sqrt(variance)

    let totalTime = (angleSamples.last?.time ?? 1.0) - (angleSamples.first?.time ?? 0.0)
    let correctionFrequency = totalTime > 0 ? Double(correctionSamples.count) / totalTime : 0.0

    // 6. Decision tree (order matters)
    let archetype: PendulumArchetype
    var confidence = abs(peakCorrelation)

    // Check Anticipator first (most impressive)
    if peakLag <= 0 && peakCorrelation > 0.15 {
      archetype = .anticipator
      confidence = min(abs(peakCorrelation) * 1.5, 1.0)
    }
    // Surfer: low variance, high frequency micro-corrections
    else if meanMag > 0 && stdDev < 0.25 * meanMag && correctionFrequency > 2.0 {
      archetype = .surfer
      confidence = min(correctionFrequency / 5.0, 1.0)
    }
    // Overcorrector: high zero-crossing rate
    else if zeroCrossingRate > 0.4 {
      archetype = .overcorrector
      confidence = min(zeroCrossingRate, 1.0)
    }
    // Learner: improving across attempts
    else if attemptDurations.count >= 3 &&
            attemptDurations.last! > attemptDurations.first! * 1.5 &&
            abs(peakCorrelation) < 0.3 {
      archetype = .learner
      let improvement = attemptDurations.last! / max(attemptDurations.first!, 0.1)
      confidence = min(improvement / 3.0, 1.0)
    }
    // Responder: default (corrections follow angle changes)
    else {
      archetype = .responder
      confidence = max(abs(peakCorrelation), 0.3)
    }

    return ArchetypeResult(
      archetype: archetype,
      confidence: confidence,
      crossCorrelationPeakLag: peakLag,
      zeroCrossingRate: zeroCrossingRate,
      correctionVariance: variance,
      correctionFrequency: correctionFrequency,
      attemptDurations: attemptDurations
    )
  }

  // MARK: - Signal Processing

  /// Downsample time series to target Hz
  private static func downsample(
    _ samples: [(time: Double, angle: Double)],
    targetHz: Double
  ) -> [(time: Double, angle: Double)] {
    guard let first = samples.first else { return [] }
    let interval = 1.0 / targetHz
    var result: [(time: Double, angle: Double)] = []
    var nextTime = first.time

    for sample in samples {
      if sample.time >= nextTime {
        result.append(sample)
        nextTime = sample.time + interval
      }
    }
    return result
  }

  /// Build a correction signal aligned to given timestamps
  /// Returns an array of signed correction magnitudes at each timestamp
  private static func buildCorrectionSignal(
    corrections: [(time: Double, direction: Int, magnitude: Double)],
    timestamps: [Double]
  ) -> [Double] {
    var signal = [Double](repeating: 0.0, count: timestamps.count)
    let window = 0.15 // 150ms window around each timestamp

    for correction in corrections {
      let signedMag = Double(correction.direction) * correction.magnitude
      for (i, t) in timestamps.enumerated() {
        if abs(t - correction.time) < window {
          signal[i] += signedMag
        }
      }
    }
    return signal
  }

  /// Compute normalized cross-correlation and return (peakLag, peakValue)
  /// Positive lag means signal2 lags signal1 (corrections follow angle)
  /// Negative lag means signal2 leads signal1 (corrections anticipate angle)
  private static func crossCorrelation(
    signal1: [Double],
    signal2: [Double],
    maxLag: Int
  ) -> (lag: Int, value: Double) {
    let n = min(signal1.count, signal2.count)
    guard n > maxLag * 2 else { return (1, 0.0) }

    // Compute means
    let mean1 = signal1.prefix(n).reduce(0, +) / Double(n)
    let mean2 = signal2.prefix(n).reduce(0, +) / Double(n)

    // Compute standard deviations
    let std1 = sqrt(signal1.prefix(n).map { pow($0 - mean1, 2) }.reduce(0, +) / Double(n))
    let std2 = sqrt(signal2.prefix(n).map { pow($0 - mean2, 2) }.reduce(0, +) / Double(n))

    guard std1 > 1e-10, std2 > 1e-10 else { return (1, 0.0) }

    var bestLag = 0
    var bestCorr = -2.0

    for lag in -maxLag...maxLag {
      var sum = 0.0
      var count = 0

      for i in 0..<n {
        let j = i + lag
        if j >= 0 && j < n {
          sum += (signal1[i] - mean1) * (signal2[j] - mean2)
          count += 1
        }
      }

      if count > 0 {
        let corr = sum / (Double(count) * std1 * std2)
        if corr > bestCorr {
          bestCorr = corr
          bestLag = lag
        }
      }
    }

    return (bestLag, bestCorr)
  }

  /// Compute zero-crossing rate: how often corrections reverse direction within 0.5s
  private static func computeZeroCrossingRate(
    corrections: [(time: Double, direction: Int, magnitude: Double)],
    angleSamples: [(time: Double, angle: Double)]
  ) -> Double {
    guard corrections.count >= 3 else { return 0.0 }

    var reversals = 0
    for i in 1..<corrections.count {
      let timeDiff = corrections[i].time - corrections[i - 1].time
      let dirChanged = corrections[i].direction != corrections[i - 1].direction
      if timeDiff < 0.5 && dirChanged {
        reversals += 1
      }
    }

    return Double(reversals) / Double(corrections.count - 1)
  }
}
