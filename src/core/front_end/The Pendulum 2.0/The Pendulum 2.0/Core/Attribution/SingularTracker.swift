// SingularTracker.swift
// The Pendulum 2.0
// Event tracking wrapper for Singular SDK — core UA attribution events

import Foundation
import UIKit
#if canImport(Singular)
import Singular
#endif

class SingularTracker {

    // MARK: - Install Tracking

    /// Track app install (called once on first launch after ATT flow)
    static func trackInstall() {
        let attributes = [
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("app_install", attributes: attributes)
    }

    // MARK: - Session Tracking

    /// Track when user starts a gameplay session
    static func trackSessionStart(mode: String, level: Int) {
        let attributes = [
            "game_mode": mode,
            "level": "\(level)",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("session_start", attributes: attributes)
    }

    /// Track when a gameplay session ends
    static func trackSessionEnd(mode: String, duration: TimeInterval, score: Int, levelsCompleted: Int) {
        let attributes = [
            "game_mode": mode,
            "duration": String(format: "%.0f", duration),
            "score": "\(score)",
            "levels_completed": "\(levelsCompleted)",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("session_end", attributes: attributes)
    }

    // MARK: - Level Tracking

    /// Track when a player beats a level
    static func trackLevelComplete(level: Int, mode: String, balanceTime: Double) {
        let attributes = [
            "level": "\(level)",
            "game_mode": mode,
            "balance_time": String(format: "%.1f", balanceTime),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("level_complete", attributes: attributes)
    }

    // MARK: - Mode Selection

    /// Track when user selects a game mode
    static func trackModeSelected(mode: String) {
        let attributes = [
            "game_mode": mode,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("mode_selected", attributes: attributes)
    }

    // MARK: - Profile

    /// Track when user creates their profile
    static func trackProfileCreated(goal: String) {
        let attributes = [
            "training_goal": goal,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("profile_created", attributes: attributes)
    }

    // MARK: - Tutorial

    /// Track when user completes the tutorial
    static func trackTutorialCompleted(totalTime: TimeInterval) {
        let attributes = [
            "total_time": String(format: "%.0f", totalTime),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("tutorial_completed", attributes: attributes)
    }

    // MARK: - Golden Mode

    /// Track when a Golden Mode session ends
    static func trackGoldenSessionEnd(coherenceScore: Double, duration: TimeInterval) {
        let attributes = [
            "coherence_score": String(format: "%.1f", coherenceScore),
            "duration": String(format: "%.0f", duration),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("golden_session_end", attributes: attributes)
    }

    // MARK: - ATT Permission

    /// Track the App Tracking Transparency permission result
    static func trackTrackingPermission(granted: Bool, idfa: String?) {
        var attributes = [
            "att_granted": granted ? "true" : "false",
            "att_status": AppTrackingManager.shared.getCurrentTrackingStatus(),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let idfa = idfa {
            attributes["idfa"] = idfa
        }
        sendEvent("att_permission_result", attributes: attributes)
    }

    // MARK: - Error Tracking

    /// Track an unexpected error
    static func trackError(error: String, context: String) {
        let attributes = [
            "error_message": error,
            "error_context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendEvent("app_error", attributes: attributes)
    }

    // MARK: - Private

    private static func sendEvent(_ name: String, attributes: [String: String]) {
        #if canImport(Singular)
        Singular.event(name, withArgs: attributes)
        #else
        print("[Singular] \(name): \(attributes)")
        #endif
    }
}
