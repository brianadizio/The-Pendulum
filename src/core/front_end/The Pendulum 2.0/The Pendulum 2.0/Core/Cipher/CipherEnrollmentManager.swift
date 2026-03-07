//
//  CipherEnrollmentManager.swift
//  The Pendulum 2.0
//
//  Manages the Golden Cipher enrollment flow: play 30 sessions to build
//  a behavioral template, then authenticate via gameplay.
//

import Foundation
import Combine

@MainActor
class CipherEnrollmentManager: ObservableObject {
    static let shared = CipherEnrollmentManager()

    // MARK: - State

    @Published private(set) var isEnrolling: Bool = false
    @Published private(set) var sessionsSubmitted: Int = 0
    @Published private(set) var targetSessions: Int = 30

    private var enrollmentId: String?

    var isEnrolled: Bool {
        UserDefaults.standard.string(forKey: "cipherTemplateId") != nil
    }

    var enrollmentProgress: Double {
        guard targetSessions > 0 else { return 0 }
        return Double(sessionsSubmitted) / Double(targetSessions)
    }

    var templateId: String? {
        UserDefaults.standard.string(forKey: "cipherTemplateId")
    }

    private init() {
        // Restore in-progress enrollment
        if let eid = UserDefaults.standard.string(forKey: "cipherEnrollmentId") {
            enrollmentId = eid
            isEnrolling = true
            sessionsSubmitted = UserDefaults.standard.integer(forKey: "cipherEnrollmentSessions")
        }
    }

    // MARK: - Enrollment Flow

    /// Start enrollment. Call once when user opts in to Golden Cipher.
    func startEnrollment() async throws {
        let userId = cipherUserId
        let response = try await CipherAuthService.shared.startEnrollment(
            userId: userId,
            sessions: targetSessions
        )
        enrollmentId = response.enrollmentId
        sessionsSubmitted = 0
        isEnrolling = true

        // Persist enrollment state
        UserDefaults.standard.set(response.enrollmentId, forKey: "cipherEnrollmentId")
        UserDefaults.standard.set(0, forKey: "cipherEnrollmentSessions")
    }

    /// Submit a completed gameplay session for enrollment.
    /// Call after each normal session during the enrollment period.
    func submitSession(_ payload: CipherAuthService.PendulumSessionPayload) async throws {
        guard let eid = enrollmentId else { return }

        try await CipherAuthService.shared.submitEnrollmentSession(
            enrollmentId: eid,
            session: payload
        )
        sessionsSubmitted += 1
        UserDefaults.standard.set(sessionsSubmitted, forKey: "cipherEnrollmentSessions")

        // Auto-finalize when target reached
        if sessionsSubmitted >= targetSessions {
            try await finalize()
        }
    }

    /// Manually finalize enrollment (if target sessions met).
    func finalize() async throws {
        guard let eid = enrollmentId else { return }

        let result = try await CipherAuthService.shared.finalizeEnrollment(
            enrollmentId: eid
        )

        // Store template ID
        UserDefaults.standard.set(result.templateId, forKey: "cipherTemplateId")

        // Clear enrollment state
        UserDefaults.standard.removeObject(forKey: "cipherEnrollmentId")
        UserDefaults.standard.removeObject(forKey: "cipherEnrollmentSessions")
        enrollmentId = nil
        isEnrolling = false
    }

    /// Reset enrollment (e.g., if user wants to re-enroll).
    func resetEnrollment() {
        UserDefaults.standard.removeObject(forKey: "cipherTemplateId")
        UserDefaults.standard.removeObject(forKey: "cipherEnrollmentId")
        UserDefaults.standard.removeObject(forKey: "cipherEnrollmentSessions")
        enrollmentId = nil
        sessionsSubmitted = 0
        isEnrolling = false
    }

    // MARK: - User ID

    /// Consistent user ID across apps (Firebase UID preferred, App Group fallback).
    var cipherUserId: String {
        if let uid = FirebaseManager.shared.uid {
            return uid
        }
        return "anonymous"
    }
}
