//
//  CipherSessionCollector.swift
//  The Pendulum 2.0
//
//  Captures swing and peak data during gameplay for Golden Cipher behavioral analysis.
//

import Foundation

class CipherSessionCollector {
    private(set) var sessionId = UUID().uuidString
    private(set) var swings: [CipherAuthService.SwingPayload] = []
    private(set) var peaks: [CipherAuthService.PeakPayload] = []
    private var startTime: Date?
    private var levelConfig: LevelConfig?

    // Peak detection state
    private var previousAngle: Double?
    private var previousDirection: Int = 0  // -1 decreasing, 0 unknown, +1 increasing

    // Downsampling: collect at ~10 Hz for cipher (not every 60fps frame)
    private var lastRecordTime: TimeInterval = 0
    private let recordInterval: TimeInterval = 0.1

    // Summary statistics accumulated during session
    private(set) var totalBalanceTime: TimeInterval = 0
    private var lastBalanceCheckTime: TimeInterval?
    private var angleSum: Double = 0
    private var angleCount: Int = 0
    private var maxAngleDeviation: Double = 0

    /// Start collecting data for a new session
    func startSession(config: LevelConfig) {
        sessionId = UUID().uuidString
        swings = []
        peaks = []
        startTime = Date()
        levelConfig = config
        previousAngle = nil
        previousDirection = 0
        lastRecordTime = 0
        totalBalanceTime = 0
        lastBalanceCheckTime = nil
        angleSum = 0
        angleCount = 0
        maxAngleDeviation = 0
    }

    /// Record a physics frame (called from PendulumViewModel update loop).
    /// Downsamples to ~10 Hz for the cipher payload.
    func recordFrame(
        timestamp: TimeInterval,
        angle: Double,
        angularVelocity: Double,
        appliedForce: Double? = nil,
        isBalanced: Bool,
        balanceThreshold: Double
    ) {
        // Track balance time
        if isBalanced {
            if let lastCheck = lastBalanceCheckTime {
                totalBalanceTime += timestamp - lastCheck
            }
        }
        lastBalanceCheckTime = timestamp

        // Accumulate angle stats (every frame for accuracy)
        let deviation = abs(angle - .pi)
        angleSum += deviation
        angleCount += 1
        if deviation > maxAngleDeviation {
            maxAngleDeviation = deviation
        }

        // Peak detection (every frame for accuracy)
        detectPeak(timestamp: timestamp, angle: angle)

        // Downsample swing recording to ~10 Hz
        guard timestamp - lastRecordTime >= recordInterval else { return }
        lastRecordTime = timestamp

        swings.append(CipherAuthService.SwingPayload(
            timestamp: timestamp,
            angle: angle,
            angularVelocity: angularVelocity,
            appliedForce: appliedForce
        ))
    }

    /// Detect peaks (local extrema) in the angle signal.
    /// A peak occurs when the angle changes direction.
    private func detectPeak(timestamp: TimeInterval, angle: Double) {
        guard let prev = previousAngle else {
            previousAngle = angle
            return
        }

        let diff = angle - prev
        let currentDirection: Int
        if diff > 0.001 {
            currentDirection = 1   // increasing (swinging right of upright)
        } else if diff < -0.001 {
            currentDirection = -1  // decreasing (swinging left of upright)
        } else {
            previousAngle = angle
            return  // no significant change
        }

        // Direction changed = peak at previous angle
        if previousDirection != 0 && currentDirection != previousDirection {
            let direction = angle > .pi ? "right" : "left"
            peaks.append(CipherAuthService.PeakPayload(
                timestamp: timestamp,
                peakAngle: prev,
                direction: direction
            ))
        }

        previousDirection = currentDirection
        previousAngle = angle
    }

    /// Build the payload for Cipher API verification or ingestion
    func buildPayload(completionTime: Double?) -> CipherAuthService.PendulumSessionPayload {
        var configPayload: CipherAuthService.LevelConfigPayload? = nil
        if let config = levelConfig {
            configPayload = CipherAuthService.LevelConfigPayload(
                balanceThreshold: config.balanceThreshold,
                balanceRequiredTime: config.balanceRequiredTime,
                initialPerturbation: config.initialPerturbation,
                massMultiplier: config.massMultiplier,
                lengthMultiplier: config.lengthMultiplier,
                dampingValue: config.dampingValue,
                gravityMultiplier: config.gravityMultiplier,
                springConstantValue: config.springConstantValue
            )
        }

        let avgAngle = angleCount > 0 ? angleSum / Double(angleCount) : nil

        return CipherAuthService.PendulumSessionPayload(
            sessionId: sessionId,
            swings: swings,
            peaks: peaks,
            completionTime: completionTime,
            balanceTime: totalBalanceTime,
            averageAngle: avgAngle,
            maxAngle: maxAngleDeviation > 0 ? maxAngleDeviation : nil,
            levelConfig: configPayload
        )
    }
}
