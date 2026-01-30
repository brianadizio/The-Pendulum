// ProfileManager.swift
// The Pendulum 2.0
// Manages user profile persistence and 3-day prompt logic

import Foundation
import Combine

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    // MARK: - Published Properties

    @Published private(set) var currentProfile: UserProfile?
    @Published var shouldShowProfilePrompt: Bool = false

    var hasCompletedProfile: Bool {
        currentProfile != nil
    }

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let profile = "pendulum_user_profile"
        static let firstSessionDate = "pendulum_first_session_date"
        static let promptDismissedUntil = "pendulum_prompt_dismissed_until"
        static let promptPermanentlyDismissed = "pendulum_prompt_permanently_dismissed"
    }

    // MARK: - Initialization

    private init() {
        loadProfile()
        updatePromptState()
    }

    // MARK: - Profile CRUD

    func createProfile(_ profile: UserProfile) {
        saveProfile(profile)
        shouldShowProfilePrompt = false
    }

    func updateProfile(_ profile: UserProfile) {
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()
        saveProfile(updatedProfile)
    }

    func deleteProfile() {
        UserDefaults.standard.removeObject(forKey: Keys.profile)
        currentProfile = nil

        // Also clear prompt dismissal state
        UserDefaults.standard.removeObject(forKey: Keys.promptDismissedUntil)
        UserDefaults.standard.removeObject(forKey: Keys.promptPermanentlyDismissed)

        updatePromptState()
    }

    private func saveProfile(_ profile: UserProfile) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(profile) {
            UserDefaults.standard.set(data, forKey: Keys.profile)
            currentProfile = profile
        }
    }

    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: Keys.profile) else {
            currentProfile = nil
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        currentProfile = try? decoder.decode(UserProfile.self, from: data)
    }

    // MARK: - First Session Tracking

    func recordFirstSessionIfNeeded() {
        if UserDefaults.standard.object(forKey: Keys.firstSessionDate) == nil {
            UserDefaults.standard.set(Date(), forKey: Keys.firstSessionDate)
        }
    }

    func daysSinceFirstSession() -> Int? {
        guard let firstDate = UserDefaults.standard.object(forKey: Keys.firstSessionDate) as? Date else {
            return nil
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstDate, to: Date())
        return components.day
    }

    // MARK: - Prompt Logic

    func updatePromptState() {
        // Don't show if profile exists
        if hasCompletedProfile {
            shouldShowProfilePrompt = false
            return
        }

        // Don't show if permanently dismissed
        if UserDefaults.standard.bool(forKey: Keys.promptPermanentlyDismissed) {
            shouldShowProfilePrompt = false
            return
        }

        // Don't show if temporarily dismissed (within 24 hours)
        if let dismissedUntil = UserDefaults.standard.object(forKey: Keys.promptDismissedUntil) as? Date {
            if Date() < dismissedUntil {
                shouldShowProfilePrompt = false
                return
            }
        }

        // Show if 3+ days since first session
        if let days = daysSinceFirstSession(), days >= 3 {
            shouldShowProfilePrompt = true
        } else {
            shouldShowProfilePrompt = false
        }
    }

    func dismissPromptTemporarily() {
        // Dismiss for 24 hours
        let dismissUntil = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        UserDefaults.standard.set(dismissUntil, forKey: Keys.promptDismissedUntil)
        shouldShowProfilePrompt = false
    }

    func dismissPromptPermanently() {
        UserDefaults.standard.set(true, forKey: Keys.promptPermanentlyDismissed)
        shouldShowProfilePrompt = false
    }

    // MARK: - Export

    func exportProfileData() -> URL? {
        guard let profile = currentProfile else { return nil }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(profile) else { return nil }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportPath = documentsPath.appendingPathComponent("profile_export.json")

        do {
            try data.write(to: exportPath)
            return exportPath
        } catch {
            print("Failed to export profile: \(error)")
            return nil
        }
    }

    // MARK: - Clear All Data

    func clearAllData() {
        // Clear profile
        UserDefaults.standard.removeObject(forKey: Keys.profile)
        currentProfile = nil

        // Clear tracking dates
        UserDefaults.standard.removeObject(forKey: Keys.firstSessionDate)
        UserDefaults.standard.removeObject(forKey: Keys.promptDismissedUntil)
        UserDefaults.standard.removeObject(forKey: Keys.promptPermanentlyDismissed)

        shouldShowProfilePrompt = false
    }

    // MARK: - Health Data Management

    /// Update the cached health snapshot in the user's profile
    func updateHealthSnapshot(_ snapshot: HealthSnapshot) {
        guard var profile = currentProfile else { return }

        profile.cachedHealthSnapshot = snapshot
        profile.lastHealthSync = Date()
        saveProfile(profile)
    }

    /// Add a health correlation for a completed session
    func addHealthCorrelation(_ correlation: HealthCorrelation) {
        guard var profile = currentProfile else { return }

        // Keep last 100 correlations (rolling window)
        var correlations = profile.healthCorrelations
        correlations.append(correlation)
        if correlations.count > 100 {
            correlations = Array(correlations.suffix(100))
        }

        profile.healthCorrelations = correlations
        saveProfile(profile)
    }

    /// Get recent health correlations
    func getHealthCorrelations(limit: Int = 20) -> [HealthCorrelation] {
        guard let profile = currentProfile else { return [] }
        return Array(profile.healthCorrelations.suffix(limit))
    }

    /// Update health integration consent
    func setHealthIntegrationConsent(_ consent: Bool) {
        guard var profile = currentProfile else { return }

        profile.healthIntegrationConsent = consent
        if !consent {
            // Clear health data when consent is revoked
            profile.cachedHealthSnapshot = nil
            profile.healthCorrelations = []
            profile.lastHealthSync = nil
        }
        saveProfile(profile)
    }
}
