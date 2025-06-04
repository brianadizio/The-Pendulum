// AnalyticsDashboardView.swift
// This is now a compatibility wrapper around our native implementation
import UIKit

// Import the enum from AnalyticsDashboardViewNative
// This ensures we use the same enum throughout the project
// TimeRange enum provides backward compatibility
enum TimeRange {
    case session
    case daily
    case weekly
    case monthly
}

class AnalyticsDashboardView: UIView {
    
    // Internal native implementation
    private var nativeView: AnalyticsDashboardViewNative!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNativeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNativeView()
    }
    
    private func setupNativeView() {
        // Create and configure the native implementation
        nativeView = AnalyticsDashboardViewNative(frame: bounds)
        nativeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nativeView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            nativeView.topAnchor.constraint(equalTo: topAnchor),
            nativeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nativeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nativeView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Update the dashboard with data for the specified time range and session
    func updateDashboard(timeRange: TimeRange = .session, sessionId: UUID? = nil) {
        // Convert TimeRange to AnalyticsTimeRange defined in AnalyticsDashboardViewNative
        let nativeTimeRange: AnalyticsTimeRange
        switch timeRange {
        case .session:
            nativeTimeRange = .session
        case .daily:
            nativeTimeRange = .daily
        case .weekly:
            nativeTimeRange = .weekly
        case .monthly:
            nativeTimeRange = .monthly
        }
        
        // Delegate to the native implementation
        nativeView.updateDashboard(timeRange: nativeTimeRange, sessionId: sessionId)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nativeView.frame = bounds
    }
}