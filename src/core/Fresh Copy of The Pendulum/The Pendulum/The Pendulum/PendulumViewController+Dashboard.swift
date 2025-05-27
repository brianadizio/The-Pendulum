import UIKit

// Import the notification constant from DashboardViewController
extension NSNotification.Name {
    static let DashboardStatsUpdated = DashboardStatsUpdatedNotification
}

// Extension to handle Dashboard setup
extension PendulumViewController {
    
    @objc func setupDashboardView() {
        // Set background color to match Golden Enterprises theme
        dashboardView.backgroundColor = (UIColor.goldenBackground as UIColor)
        
        // ONLY setup the enhanced analytics view - remove old dashboard
        setupEnhancedAnalyticsView()
    }
    
    // Method to update dashboard stats
    @objc func updateDashboardStats() {
        // Notify the dashboard to refresh stats
        NotificationCenter.default.post(name: DashboardStatsUpdatedNotification, object: nil)
        
        // Start a timer to periodically update the dashboard if not already running
        if dashboardUpdateTimer == nil {
            dashboardUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                NotificationCenter.default.post(name: DashboardStatsUpdatedNotification, object: nil)
            }
        }
    }
    
    // Stop dashboard updates when switching away from dashboard
    @objc func stopDashboardUpdates() {
        dashboardUpdateTimer?.invalidate()
        dashboardUpdateTimer = nil
    }
}