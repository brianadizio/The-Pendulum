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
        
        // Create dashboard view controller
        dashboardViewController = DashboardViewController(viewModel: viewModel)
        
        // Add as child view controller
        if let dashboardVC = dashboardViewController {
            addChild(dashboardVC)
            dashboardVC.view.frame = dashboardView.bounds
            dashboardVC.view.translatesAutoresizingMaskIntoConstraints = false
            dashboardView.addSubview(dashboardVC.view)
            
            // Set up constraints (safer than just using autoresizingMask)
            NSLayoutConstraint.activate([
                dashboardVC.view.topAnchor.constraint(equalTo: dashboardView.topAnchor),
                dashboardVC.view.leadingAnchor.constraint(equalTo: dashboardView.leadingAnchor),
                dashboardVC.view.trailingAnchor.constraint(equalTo: dashboardView.trailingAnchor),
                dashboardVC.view.bottomAnchor.constraint(equalTo: dashboardView.bottomAnchor)
            ])
            
            // Complete the child view controller setup
            dashboardVC.didMove(toParent: self)
        }
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