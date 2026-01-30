// UserProfile.swift
// The Pendulum 2.0
// Local user profile data model

import Foundation

// MARK: - User Profile

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var trainingGoal: TrainingGoal
    var ageRange: AgeRange?
    var dominantHand: DominantHand?
    let createdAt: Date
    var updatedAt: Date

    // Consent flags (for future integrations)
    var healthIntegrationConsent: Bool
    var analyticsConsent: Bool

    // Health data (from Apple Health integration)
    var lastHealthSync: Date?
    var cachedHealthSnapshot: HealthSnapshot?
    var healthCorrelations: [HealthCorrelation]

    init(
        id: UUID = UUID(),
        displayName: String,
        trainingGoal: TrainingGoal,
        ageRange: AgeRange? = nil,
        dominantHand: DominantHand? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        healthIntegrationConsent: Bool = false,
        analyticsConsent: Bool = true,
        lastHealthSync: Date? = nil,
        cachedHealthSnapshot: HealthSnapshot? = nil,
        healthCorrelations: [HealthCorrelation] = []
    ) {
        self.id = id
        self.displayName = displayName
        self.trainingGoal = trainingGoal
        self.ageRange = ageRange
        self.dominantHand = dominantHand
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.healthIntegrationConsent = healthIntegrationConsent
        self.analyticsConsent = analyticsConsent
        self.lastHealthSync = lastHealthSync
        self.cachedHealthSnapshot = cachedHealthSnapshot
        self.healthCorrelations = healthCorrelations
    }
}

// MARK: - Training Goal

enum TrainingGoal: String, Codable, CaseIterable, Identifiable {
    case focus = "Improve Focus"
    case relaxation = "Relaxation & Mindfulness"
    case research = "Scientific Research"
    case curiosity = "Just Curious"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .focus: return "target"
        case .relaxation: return "leaf"
        case .research: return "flask"
        case .curiosity: return "sparkles"
        }
    }

    var description: String {
        switch self {
        case .focus:
            return "Train concentration and sustained attention"
        case .relaxation:
            return "Practice mindful balance and stress relief"
        case .research:
            return "Explore motor control and dynamics"
        case .curiosity:
            return "Discover the physics of balance"
        }
    }
}

// MARK: - Age Range

enum AgeRange: String, Codable, CaseIterable, Identifiable {
    case under18 = "Under 18"
    case age18to30 = "18-30"
    case age31to50 = "31-50"
    case age51plus = "51+"

    var id: String { rawValue }
}

// MARK: - Dominant Hand

enum DominantHand: String, Codable, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"
    case ambidextrous = "Ambidextrous"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .left: return "hand.point.left"
        case .right: return "hand.point.right"
        case .ambidextrous: return "hands.clap"
        }
    }
}
