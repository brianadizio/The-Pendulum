// HealthDataModels.swift
// The Pendulum 2.0
// Data models for Apple Health integration

import Foundation

// MARK: - Health Snapshot

/// Point-in-time snapshot of health metrics from Apple Health
struct HealthSnapshot: Codable, Equatable {
    let date: Date
    var steps: Int?
    var restingHeartRate: Double?
    var heartRateVariability: Double?  // SDNN in milliseconds
    var sleepDuration: TimeInterval?   // In seconds
    var activeCalories: Double?
    var mindfulMinutesLogged: Int

    init(
        date: Date = Date(),
        steps: Int? = nil,
        restingHeartRate: Double? = nil,
        heartRateVariability: Double? = nil,
        sleepDuration: TimeInterval? = nil,
        activeCalories: Double? = nil,
        mindfulMinutesLogged: Int = 0
    ) {
        self.date = date
        self.steps = steps
        self.restingHeartRate = restingHeartRate
        self.heartRateVariability = heartRateVariability
        self.sleepDuration = sleepDuration
        self.activeCalories = activeCalories
        self.mindfulMinutesLogged = mindfulMinutesLogged
    }

    // MARK: - Computed Properties

    /// Sleep duration formatted as hours and minutes
    var formattedSleepDuration: String? {
        guard let sleep = sleepDuration else { return nil }
        let hours = Int(sleep) / 3600
        let minutes = (Int(sleep) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    /// Check if snapshot has any meaningful data
    var hasData: Bool {
        steps != nil || restingHeartRate != nil || heartRateVariability != nil ||
        sleepDuration != nil || activeCalories != nil || mindfulMinutesLogged > 0
    }
}

// MARK: - Health Correlation

/// Links a gameplay session with health data for correlation analysis
struct HealthCorrelation: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let sessionScore: Int
    let sessionDuration: TimeInterval
    let healthSnapshot: HealthSnapshot
    let correlationDate: Date

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        sessionScore: Int,
        sessionDuration: TimeInterval,
        healthSnapshot: HealthSnapshot,
        correlationDate: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.sessionScore = sessionScore
        self.sessionDuration = sessionDuration
        self.healthSnapshot = healthSnapshot
        self.correlationDate = correlationDate
    }
}

// MARK: - Health Data Type

/// Types of health data we read from HealthKit
enum HealthDataType: String, CaseIterable, Identifiable {
    case steps = "Steps"
    case restingHeartRate = "Resting Heart Rate"
    case heartRateVariability = "Heart Rate Variability"
    case sleep = "Sleep"
    case activeCalories = "Active Calories"
    case mindfulness = "Mindfulness"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .restingHeartRate: return "heart.fill"
        case .heartRateVariability: return "waveform.path.ecg"
        case .sleep: return "bed.double.fill"
        case .activeCalories: return "flame.fill"
        case .mindfulness: return "brain.head.profile"
        }
    }

    var unit: String {
        switch self {
        case .steps: return "steps"
        case .restingHeartRate: return "BPM"
        case .heartRateVariability: return "ms"
        case .sleep: return "hours"
        case .activeCalories: return "kcal"
        case .mindfulness: return "min"
        }
    }

    var description: String {
        switch self {
        case .steps: return "Daily step count"
        case .restingHeartRate: return "Average resting heart rate"
        case .heartRateVariability: return "HRV (stress/recovery indicator)"
        case .sleep: return "Total sleep duration"
        case .activeCalories: return "Calories burned from activity"
        case .mindfulness: return "Minutes logged from sessions"
        }
    }
}

// MARK: - Health Authorization Status

/// Represents the current authorization state for HealthKit
enum HealthAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case unavailable

    var displayText: String {
        switch self {
        case .notDetermined: return "Not Connected"
        case .authorized: return "Connected"
        case .denied: return "Access Denied"
        case .unavailable: return "Not Available"
        }
    }

    var isConnected: Bool {
        self == .authorized
    }
}
