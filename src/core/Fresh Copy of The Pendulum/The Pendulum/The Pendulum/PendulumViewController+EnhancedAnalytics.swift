import UIKit

// Extension to handle Analytics integration (using SimpleDashboard)
extension PendulumViewController {
    
    // MARK: - Analytics Setup
    
    func setupEnhancedAnalyticsView() {
        print("Setting up Analytics View (SimpleDashboard)")
        
        // Create container for analytics
        let analyticsContainer = UIView()
        analyticsContainer.translatesAutoresizingMaskIntoConstraints = false
        analyticsContainer.backgroundColor = .goldenBackground
        
        // Sync with Settings metric selection
        syncMetricsWithSettings()
        
        // Add to dashboard view
        dashboardView.addSubview(analyticsContainer)
        
        NSLayoutConstraint.activate([
            analyticsContainer.topAnchor.constraint(equalTo: dashboardView.topAnchor),
            analyticsContainer.leadingAnchor.constraint(equalTo: dashboardView.leadingAnchor),
            analyticsContainer.trailingAnchor.constraint(equalTo: dashboardView.trailingAnchor),
            analyticsContainer.bottomAnchor.constraint(equalTo: dashboardView.bottomAnchor)
        ])
        
        // Create simple analytics dashboard (replaces EnhancedAnalyticsDashboard)
        let simpleDashboard = SimpleDashboard()
        simpleDashboard.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add as child view controller
        addChild(simpleDashboard)
        analyticsContainer.addSubview(simpleDashboard.view)
        simpleDashboard.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            simpleDashboard.view.topAnchor.constraint(equalTo: analyticsContainer.topAnchor),
            simpleDashboard.view.leadingAnchor.constraint(equalTo: analyticsContainer.leadingAnchor),
            simpleDashboard.view.trailingAnchor.constraint(equalTo: analyticsContainer.trailingAnchor),
            simpleDashboard.view.bottomAnchor.constraint(equalTo: analyticsContainer.bottomAnchor)
        ])
        
        // Store reference if needed
        self.simpleDashboard = simpleDashboard
    }
    
    // MARK: - Metric Group Selection
    
    func selectMetricGroup(_ group: MetricGroupType) {
        // SimpleDashboard handles metric group selection internally via controls
        // No need to update manually since it has its own controls
        
        // Provide haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        
        // Log metric group selection
        print("Selected metric group: \(group.displayName)")
    }
    
    // MARK: - Analytics Tracking Integration
    
    func startEnhancedAnalyticsTracking() {
        // Ensure analytics manager is configured with system parameters
        AnalyticsManager.shared.updateSystemParameters(
            mass: viewModel.mass,
            length: viewModel.length,
            gravity: viewModel.gravity
        )
        
        // Start tracking with enhanced metrics
        if let sessionId = viewModel.currentSessionId {
            AnalyticsManager.shared.startTracking(for: sessionId)
        }
    }
    
    func updateEnhancedAnalytics() {
        let currentTime = CACurrentMediaTime()
        
        // Track enhanced pendulum state
        AnalyticsManager.shared.trackEnhancedPendulumState(
            time: currentTime,
            angle: viewModel.currentState.theta,
            angleVelocity: viewModel.currentState.thetaDot
        )
        
        // Track phase space for scientific metrics
        AnalyticsManager.shared.trackPhaseSpacePoint(
            theta: viewModel.currentState.theta,
            omega: viewModel.currentState.thetaDot
        )
    }
    
    func trackParameterChange(parameter: String, oldValue: Double, newValue: Double) {
        let currentTime = CACurrentMediaTime()
        AnalyticsManager.shared.trackParameterChange(
            time: currentTime,
            parameter: parameter,
            oldValue: oldValue,
            newValue: newValue
        )
    }
    
    func completeAnalyticsSession() {
        // Calculate final metrics
        let metrics = AnalyticsManager.shared.getPerformanceMetrics()
        let stabilityScore = metrics["stabilityScore"] as? Double ?? 0.0
        let currentLevel = viewModel.currentLevel
        
        // Complete the session
        AnalyticsManager.shared.completeSession(
            stabilityScore: stabilityScore,
            level: currentLevel
        )
        
        // Stop tracking
        AnalyticsManager.shared.stopTracking()
    }
    
    // MARK: - Metric Display Modes
    
    func showMetricGroupInfo() {
        let infoVC = MetricGroupInfoViewController()
        infoVC.modalPresentationStyle = .pageSheet
        
        if let sheet = infoVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(infoVC, animated: true)
    }
    
    // MARK: - Settings Sync
    
    func syncMetricsWithSettings() {
        // SimpleDashboard handles metric group selection internally
        // Settings sync is now handled within the dashboard controls
        print("Syncing metrics with settings (handled internally by SimpleDashboard)")
    }
    
    // This method should be called when the analytics tab is selected
    func onAnalyticsTabSelected() {
        // SimpleDashboard automatically refreshes via its timer
        // No manual refresh needed
        print("Analytics tab selected - SimpleDashboard will update automatically")
    }
}

// MARK: - Stored Property Extension
private var simpleDashboardKey: UInt8 = 0

extension PendulumViewController {
    var simpleDashboard: SimpleDashboard? {
        get {
            return objc_getAssociatedObject(self, &simpleDashboardKey) as? SimpleDashboard
        }
        set {
            objc_setAssociatedObject(self, &simpleDashboardKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Metric Group Info View Controller
class MetricGroupInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Metric Groups"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        var previousView: UIView = titleLabel
        
        // Add info for each metric group
        for group in MetricGroupType.allCases {
            let groupView = createGroupInfoView(for: group)
            groupView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(groupView)
            
            NSLayoutConstraint.activate([
                groupView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
                groupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                groupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            previousView = groupView
        }
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20)
        ])
    }
    
    private func createGroupInfoView(for group: MetricGroupType) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = group.icon
        iconLabel.font = .systemFont(ofSize: 36)
        container.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = group.displayName
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        container.addSubview(nameLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = group.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        container.addSubview(descriptionLabel)
        
        let metricsLabel = UILabel()
        metricsLabel.translatesAutoresizingMaskIntoConstraints = false
        let metrics = MetricGroupDefinition.metrics(for: group)
        metricsLabel.text = "Includes: " + metrics.map { $0.rawValue }.joined(separator: ", ")
        metricsLabel.font = .systemFont(ofSize: 12)
        metricsLabel.textColor = .tertiaryLabel
        metricsLabel.numberOfLines = 0
        container.addSubview(metricsLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            nameLabel.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            metricsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            metricsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            metricsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            metricsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
}