// SessionTimeManager.swift
// Manages session time tracking and provides static session duration for dashboard

import Foundation

class SessionTimeManager {
    static let shared = SessionTimeManager()
    
    private var sessionStartTime: Date?
    private var sessionEndTime: Date?
    private var completedSessionDuration: TimeInterval = 0
    private var isActiveSession: Bool = false
    
    private init() {}
    
    // MARK: - Session Management
    
    /// Start a new gaming session
    func startSession() {
        sessionStartTime = Date()
        sessionEndTime = nil
        isActiveSession = true
        completedSessionDuration = 0
    }
    
    /// End the current gaming session and record the duration
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        
        sessionEndTime = Date()
        completedSessionDuration = sessionEndTime!.timeIntervalSince(startTime)
        isActiveSession = false
    }
    
    /// Pause the session (for when game is paused)
    func pauseSession() {
        // In a more complex implementation, we might track pause duration
        // For now, we'll keep it simple
    }
    
    /// Resume the session
    func resumeSession() {
        // Resume tracking
    }
    
    // MARK: - Duration Getters
    
    /// Get the duration of the completed session (static value for dashboard)
    func getCompletedSessionDuration() -> TimeInterval {
        if isActiveSession {
            // If session is still active, return the current duration
            // This should only be used during gameplay, not on dashboard
            return getCurrentSessionDuration()
        } else {
            // Return the static completed duration
            return completedSessionDuration
        }
    }
    
    /// Get the current session duration (for active gameplay only)
    func getCurrentSessionDuration() -> TimeInterval {
        guard let startTime = sessionStartTime, isActiveSession else {
            return completedSessionDuration
        }
        
        return Date().timeIntervalSince(startTime)
    }
    
    /// Get the static dashboard display duration
    /// This returns the completed session duration and doesn't update
    func getDashboardSessionDuration() -> TimeInterval {
        // Always return the completed duration for dashboard
        // Never return a live updating value
        return completedSessionDuration
    }
    
    /// Check if a session is currently active
    func isSessionActive() -> Bool {
        return isActiveSession
    }
    
    /// Reset session data
    func resetSession() {
        sessionStartTime = nil
        sessionEndTime = nil
        completedSessionDuration = 0
        isActiveSession = false
    }
}

// MARK: - Analytics Manager Extension

extension AnalyticsManager {
    
    /// Get session duration for dashboard display (static value)
    func getSessionDurationForDashboard() -> TimeInterval {
        return SessionTimeManager.shared.getDashboardSessionDuration()
    }
    
    /// Update the getPerformanceMetrics to use static session time
    func getPerformanceMetricsWithStaticTime(for sessionId: UUID? = nil) -> [String: Any] {
        var metrics = getPerformanceMetrics(for: sessionId)
        
        // Replace totalPlayTime with static session duration
        metrics["totalPlayTime"] = SessionTimeManager.shared.getDashboardSessionDuration()
        
        return metrics
    }
}