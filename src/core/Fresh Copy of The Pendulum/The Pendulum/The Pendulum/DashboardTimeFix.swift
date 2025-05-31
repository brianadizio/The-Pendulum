// DashboardTimeFix.swift
// Extension to fix the dashboard time display issue

import UIKit

extension AnalyticsDashboardViewNative {
    
    /// Override willMoveToWindow to freeze session time when dashboard is shown
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow != nil {
            // When dashboard appears, ensure session time is static
            disableTimeUpdates()
        }
    }
    
    /// Disable any timers or updates that might refresh the session time
    func disableTimeUpdates() {
        // Cancel any existing timers that might be updating the UI
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        // Ensure we're using the static session duration
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let staticDuration = SessionTimeManager.shared.getDashboardSessionDuration()
            self.sessionTimeLabel?.text = self.formatTimeInterval(staticDuration)
        }
    }
    
    /// Update the refresh behavior to not update session time
    func refreshDashboardData() {
        // Save current session time text before refresh
        let currentSessionTimeText = sessionTimeLabel?.text
        
        // Update dashboard with current time range
        updateDashboard(timeRange: selectedTimeRange, sessionId: nil)
        
        // Restore the static session time after refresh
        if selectedTimeRange == .session {
            DispatchQueue.main.async { [weak self] in
                self?.sessionTimeLabel?.text = currentSessionTimeText
            }
        }
    }
    
    /// Override the update dashboard to ensure static time
    func updateDashboardWithStaticTime(timeRange: AnalyticsTimeRange? = nil, sessionId: UUID? = nil) {
        // Store static session time
        let staticDuration = SessionTimeManager.shared.getDashboardSessionDuration()
        
        // Call original update
        updateDashboard(timeRange: timeRange, sessionId: sessionId)
        
        // Always restore static session time after update
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.selectedTimeRange == .session {
                self.sessionTimeLabel?.text = self.formatTimeInterval(staticDuration)
            }
        }
    }
}

// MARK: - AnalyticsManager Extension for Sample Data

extension AnalyticsManager {
    
    /// Provide sample session duration when no real data exists
    func getSampleSessionDuration(for timeRange: AnalyticsTimeRange) -> TimeInterval {
        switch timeRange {
        case .session:
            // Use the static session duration if available
            let staticDuration = SessionTimeManager.shared.getDashboardSessionDuration()
            return staticDuration > 0 ? staticDuration : 180.0 // 3 minutes default
        case .daily:
            return 620.0  // ~10 minutes
        case .weekly:
            return 2450.0 // ~40 minutes
        case .monthly:
            return 9200.0 // ~2.5 hours
        case .yearly:
            return 86400.0 // 24 hours
        }
    }
}