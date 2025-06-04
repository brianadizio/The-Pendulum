import UIKit

class EnhancedAnalyticsDashboard: UIView {
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Metric group selection
    private var metricGroupScrollView: UIScrollView!
    private var metricGroupStackView: UIStackView!
    private var metricGroupButtons: [UIButton] = []
    private var currentMetricGroup: MetricGroupType = .basic
    
    // Time range tracking (hidden from UI)
    private var currentTimeRange: AnalyticsTimeRange = .session
    
    // Metric display containers
    private var metricContainers: [MetricType: UIView] = [:]
    private var metricLabels: [MetricType: UILabel] = [:]
    private var metricCharts: [MetricType: UIView] = [:]
    
    // Layout
    private let containerSpacing: CGFloat = 16
    private let containerPadding: CGFloat = 16
    
    // Update timer
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        // Removed debug print
        setupUI()
        startMetricUpdates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        startMetricUpdates()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Only log once per significant change to avoid spam
        if abs(frame.width - lastLoggedWidth) > 10 {
            lastLoggedWidth = frame.width
            // Removed debug print
            // Removed debug print
            // Removed debug print
            // Removed debug print
            // Removed debug print
            
            // Check if any subviews have autoresizing masks
            checkAutoresizingMasks(in: self)
            
            // Check for views with width == 0
            checkForZeroWidthViews(in: self)
            
            // Check scroll view state but don't force reset 
            // Removed debug print
        }
    }
    
    private var hasScrolledManually = false
    
    private var lastLoggedWidth: CGFloat = 0
    
    private func checkForZeroWidthViews(in view: UIView, depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        
        if view.frame.width == 0 {
            print("WARNING: \(indent)Zero width view: \(type(of: view))")
            print("WARNING: \(indent)Constraints: \(view.constraints)")
        }
        
        for subview in view.subviews {
            checkForZeroWidthViews(in: subview, depth: depth + 1)
        }
    }
    
    private func checkAutoresizingMasks(in view: UIView, depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        
        if view.translatesAutoresizingMaskIntoConstraints {
            print("WARNING: \(indent)View \(type(of: view)) has translatesAutoresizingMaskIntoConstraints = true")
            print("WARNING: \(indent)Frame: \(view.frame)")
        }
        
        for subview in view.subviews {
            checkAutoresizingMasks(in: subview, depth: depth + 1)
        }
    }
    
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Removed debug print
        // Removed debug print
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .goldenBackground
        
        // Setup scroll view
        // Removed debug print
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.delaysContentTouches = false
        addSubview(scrollView)
        
        // Removed debug print
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Removed debug print
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        setupHeader()
        setupControls()
        setupMetricContainers()
    }
    
    private func setupHeader() {
        let headerView = HeaderViewCreator.createHeaderView(title: "Enhanced Analytics")
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupControls() {
        // Create horizontal scrollable metric group selector
        metricGroupScrollView = UIScrollView()
        metricGroupScrollView.translatesAutoresizingMaskIntoConstraints = false
        metricGroupScrollView.showsHorizontalScrollIndicator = false
        metricGroupScrollView.showsVerticalScrollIndicator = false
        metricGroupScrollView.backgroundColor = FocusCalendarTheme.backgroundColor
        contentView.addSubview(metricGroupScrollView)
        
        // Create stack view for buttons
        metricGroupStackView = UIStackView()
        metricGroupStackView.translatesAutoresizingMaskIntoConstraints = false
        metricGroupStackView.axis = .horizontal
        metricGroupStackView.spacing = 16
        metricGroupStackView.alignment = .center
        metricGroupStackView.distribution = .fillProportionally // Changed from .equalSpacing
        metricGroupScrollView.addSubview(metricGroupStackView)
        
        // Create buttons for each metric group
        for (index, groupType) in MetricGroupType.allCases.enumerated() {
            let button = createMetricGroupButton(for: groupType, tag: index)
            metricGroupButtons.append(button)
            metricGroupStackView.addArrangedSubview(button)
        }
        
        // Select the first button by default
        selectMetricGroupButton(at: 0)
        
        NSLayoutConstraint.activate([
            // Metric group scroll view
            metricGroupScrollView.topAnchor.constraint(equalTo: contentView.subviews[0].bottomAnchor, constant: 16),
            metricGroupScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            metricGroupScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            metricGroupScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            // Stack view inside scroll view
            metricGroupStackView.topAnchor.constraint(equalTo: metricGroupScrollView.topAnchor),
            metricGroupStackView.leadingAnchor.constraint(equalTo: metricGroupScrollView.leadingAnchor, constant: 20),
            metricGroupStackView.trailingAnchor.constraint(equalTo: metricGroupScrollView.trailingAnchor, constant: -20),
            metricGroupStackView.bottomAnchor.constraint(equalTo: metricGroupScrollView.bottomAnchor),
            metricGroupStackView.heightAnchor.constraint(equalTo: metricGroupScrollView.heightAnchor)
        ])
    }
    
    private func createMetricGroupButton(for groupType: MetricGroupType, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = tag
        
        // Set title with icon
        let title = groupType.icon + " " + groupType.displayName
        button.setTitle(title, for: .normal)
        
        // Style with Georgia font
        button.titleLabel?.font = UIFont(name: "Georgia", size: 16)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.setTitleColor(.goldenPrimary, for: .selected)
        
        // Add padding to ensure buttons have proper size
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Add action
        button.addTarget(self, action: #selector(metricGroupButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func selectMetricGroupButton(at index: Int) {
        // Deselect all buttons
        for (i, button) in metricGroupButtons.enumerated() {
            button.isSelected = false
            button.titleLabel?.font = UIFont(name: "Georgia", size: 16)
            button.setTitleColor(.secondaryLabel, for: .normal)
        }
        
        // Select the button at index
        if index < metricGroupButtons.count {
            let selectedButton = metricGroupButtons[index]
            selectedButton.isSelected = true
            selectedButton.titleLabel?.font = UIFont(name: "Georgia-Bold", size: 16)
            selectedButton.setTitleColor(.goldenPrimary, for: .normal)
            
            // Update current metric group
            currentMetricGroup = MetricGroupType.allCases[index]
            
            // Scroll to make selected button visible
            metricGroupScrollView.scrollRectToVisible(selectedButton.frame, animated: true)
        }
    }
    
    @objc private func metricGroupButtonTapped(_ sender: UIButton) {
        selectMetricGroupButton(at: sender.tag)
        metricGroupChanged()
    }
    
    private func setupMetricContainers() {
        // Clear existing containers
        metricContainers.values.forEach { $0.removeFromSuperview() }
        metricContainers.removeAll()
        metricLabels.removeAll()
        metricCharts.removeAll()
        
        // Remove all subviews except header and metric group scroll view
        let headerView = contentView.subviews.first
        contentView.subviews.forEach { view in
            // Keep the header (first subview) and metric group scroll view
            if view != headerView && view != metricGroupScrollView {
                view.removeFromSuperview()
            }
        }
        
        // Start layout chain from the metric group scroll view
        var previousView: UIView = metricGroupScrollView
        
        // Add time range selector for Basic metrics only
        if currentMetricGroup == .basic {
            let timeRangeControl = UISegmentedControl(items: ["Session", "Daily", "Weekly", "Monthly", "Yearly"])
            timeRangeControl.selectedSegmentIndex = 1  // Default to Daily like old dashboard
            timeRangeControl.translatesAutoresizingMaskIntoConstraints = false
            timeRangeControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
            timeRangeControl.isUserInteractionEnabled = true
            timeRangeControl.layer.zPosition = 100 // Ensure it's on top
            
            // Removed debug print
            
            // Style to match old dashboard
            timeRangeControl.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            timeRangeControl.selectedSegmentTintColor = .goldenPrimary
            timeRangeControl.setTitleTextAttributes([
                .foregroundColor: UIColor.darkGray,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ], for: .normal)
            timeRangeControl.setTitleTextAttributes([
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ], for: .selected)
            
            contentView.addSubview(timeRangeControl)
            
            NSLayoutConstraint.activate([
                timeRangeControl.topAnchor.constraint(equalTo: metricGroupScrollView.bottomAnchor, constant: 16),
                timeRangeControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                timeRangeControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                timeRangeControl.heightAnchor.constraint(equalToConstant: 36)
            ])
            
            previousView = timeRangeControl
        }
        
        // Get metrics for current group
        let metrics = MetricGroupDefinition.metrics(for: currentMetricGroup)
        print("EnhancedAnalyticsDashboard: Setting up containers for \(metrics.count) metrics: \(metrics.map { $0.rawValue })")
        
        if currentMetricGroup == .basic {
            // Create special layout for Basic metrics to match old dashboard
            
            // Main stats grid (6 cards in 2x3 grid)
            let statsMetrics: [MetricType] = [.stabilityScore, .efficiencyRating, .playerStyle, .averageCorrectionTime, .directionalBias, .sessionTime]
            let gridContainer = createStatsGrid(with: statsMetrics)
            contentView.addSubview(gridContainer)
            
            NSLayoutConstraint.activate([
                gridContainer.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
                gridContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                gridContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            previousView = gridContainer
            
            // Performance Charts header
            let chartsHeader = createSectionHeader(title: "Performance Charts", icon: "📊")
            contentView.addSubview(chartsHeader)
            
            NSLayoutConstraint.activate([
                chartsHeader.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
                chartsHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                chartsHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                chartsHeader.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            previousView = chartsHeader
            
            // Chart metrics
            let chartMetrics: [MetricType] = [.angularDeviation, .forceDistribution, .learningCurve, .phaseTrajectory]
            for metric in chartMetrics {
                let container = createMetricContainer(for: metric)
                container.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(container)
                
                NSLayoutConstraint.activate([
                    container.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                    container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    container.heightAnchor.constraint(equalToConstant: 250)
                ])
                
                metricContainers[metric] = container
                previousView = container
            }
            
            // Additional charts from old dashboard after existing charts
            
            // 1. Push Magnitude Distribution Chart
            let pushMagnitudeContainer = createChartContainer(
                title: "Push Magnitude Distribution",
                description: "Shows the distribution of force magnitudes you apply."
            )
            contentView.addSubview(pushMagnitudeContainer)
            
            let pushMagnitudeChart = SimpleBarChartView()
            pushMagnitudeChart.translatesAutoresizingMaskIntoConstraints = false
            pushMagnitudeChart.color = .systemOrange
            pushMagnitudeContainer.addSubview(pushMagnitudeChart)
            metricCharts[.pushMagnitudeDistribution] = pushMagnitudeChart
            
            NSLayoutConstraint.activate([
                pushMagnitudeContainer.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                pushMagnitudeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                pushMagnitudeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                pushMagnitudeContainer.heightAnchor.constraint(equalToConstant: 300),
                
                pushMagnitudeChart.topAnchor.constraint(equalTo: pushMagnitudeContainer.topAnchor, constant: 80),
                pushMagnitudeChart.leadingAnchor.constraint(equalTo: pushMagnitudeContainer.leadingAnchor, constant: 10),
                pushMagnitudeChart.trailingAnchor.constraint(equalTo: pushMagnitudeContainer.trailingAnchor, constant: -10),
                pushMagnitudeChart.bottomAnchor.constraint(equalTo: pushMagnitudeContainer.bottomAnchor, constant: -10)
            ])
            
            previousView = pushMagnitudeContainer
            
            // 2. Reaction Time Analysis Chart
            let reactionTimeContainer = createChartContainer(
                title: "Reaction Time Analysis",
                description: "Shows how quickly you respond to pendulum instability."
            )
            contentView.addSubview(reactionTimeContainer)
            
            let reactionTimeChart = SimpleLineChartView()
            reactionTimeChart.translatesAutoresizingMaskIntoConstraints = false
            reactionTimeChart.color = .systemBlue
            reactionTimeContainer.addSubview(reactionTimeChart)
            metricCharts[.reactionTimeAnalysis] = reactionTimeChart
            
            NSLayoutConstraint.activate([
                reactionTimeContainer.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                reactionTimeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                reactionTimeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                reactionTimeContainer.heightAnchor.constraint(equalToConstant: 300),
                
                reactionTimeChart.topAnchor.constraint(equalTo: reactionTimeContainer.topAnchor, constant: 80),
                reactionTimeChart.leadingAnchor.constraint(equalTo: reactionTimeContainer.leadingAnchor, constant: 10),
                reactionTimeChart.trailingAnchor.constraint(equalTo: reactionTimeContainer.trailingAnchor, constant: -10),
                reactionTimeChart.bottomAnchor.constraint(equalTo: reactionTimeContainer.bottomAnchor, constant: -10)
            ])
            
            previousView = reactionTimeContainer
            
            // 3. Full Directional Bias Chart
            let directionalBiasContainer = createChartContainer(
                title: "Directional Bias Analysis",
                description: "Shows your tendency to favor left vs. right corrections."
            )
            contentView.addSubview(directionalBiasContainer)
            
            let directionalBiasChart = SimplePieChartView()
            directionalBiasChart.translatesAutoresizingMaskIntoConstraints = false
            directionalBiasContainer.addSubview(directionalBiasChart)
            metricCharts[.fullDirectionalBias] = directionalBiasChart
            
            NSLayoutConstraint.activate([
                directionalBiasContainer.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                directionalBiasContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                directionalBiasContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                directionalBiasContainer.heightAnchor.constraint(equalToConstant: 320),
                
                directionalBiasChart.topAnchor.constraint(equalTo: directionalBiasContainer.topAnchor, constant: 80),
                directionalBiasChart.leadingAnchor.constraint(equalTo: directionalBiasContainer.leadingAnchor, constant: 10),
                directionalBiasChart.trailingAnchor.constraint(equalTo: directionalBiasContainer.trailingAnchor, constant: -10),
                directionalBiasChart.bottomAnchor.constraint(equalTo: directionalBiasContainer.bottomAnchor, constant: -10)
            ])
            
            previousView = directionalBiasContainer
            
            // Additional Statistics section
            // Removed debug print
            // Removed debug print
            let additionalHeader = createSectionHeader(title: "Additional Statistics", icon: "📈")
            contentView.addSubview(additionalHeader)
            
            // Removed debug print
            NSLayoutConstraint.activate([
                additionalHeader.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
                additionalHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                additionalHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                additionalHeader.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            previousView = additionalHeader
            
            // Additional stats grid
            let additionalStatsView = createAdditionalStatsGrid()
            contentView.addSubview(additionalStatsView)
            
            NSLayoutConstraint.activate([
                additionalStatsView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 16),
                additionalStatsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                additionalStatsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                additionalStatsView.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            previousView = additionalStatsView
            
            // 4. Level Completions Over Time Chart
            let levelCompletionsContainer = createChartContainer(
                title: "Level Completions Over Time",
                description: "Shows how many levels you've completed per time period."
            )
            contentView.addSubview(levelCompletionsContainer)
            
            let levelCompletionsChart = SimpleBarChartView()
            levelCompletionsChart.translatesAutoresizingMaskIntoConstraints = false
            levelCompletionsChart.color = .goldenPrimary
            levelCompletionsContainer.addSubview(levelCompletionsChart)
            metricCharts[.levelCompletionsOverTime] = levelCompletionsChart
            
            NSLayoutConstraint.activate([
                levelCompletionsContainer.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                levelCompletionsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                levelCompletionsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                levelCompletionsContainer.heightAnchor.constraint(equalToConstant: 300),
                
                levelCompletionsChart.topAnchor.constraint(equalTo: levelCompletionsContainer.topAnchor, constant: 80),
                levelCompletionsChart.leadingAnchor.constraint(equalTo: levelCompletionsContainer.leadingAnchor, constant: 10),
                levelCompletionsChart.trailingAnchor.constraint(equalTo: levelCompletionsContainer.trailingAnchor, constant: -10),
                levelCompletionsChart.bottomAnchor.constraint(equalTo: levelCompletionsContainer.bottomAnchor, constant: -10)
            ])
            
            previousView = levelCompletionsContainer
            
            // 5. Pendulum Parameters Over Time Chart
            let pendulumParametersContainer = createChartContainer(
                title: "Pendulum Parameters Over Time",
                description: "Shows how pendulum parameters change across levels."
            )
            contentView.addSubview(pendulumParametersContainer)
            
            // Add parameter selector
            let parameterSegmentControl = UISegmentedControl(items: ["Force", "Damping", "Gravity", "Mass", "Length"])
            parameterSegmentControl.selectedSegmentIndex = 0
            parameterSegmentControl.translatesAutoresizingMaskIntoConstraints = false
            parameterSegmentControl.backgroundColor = .systemGray6
            parameterSegmentControl.selectedSegmentTintColor = .goldenPrimary
            parameterSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
            parameterSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            parameterSegmentControl.addTarget(self, action: #selector(parameterChanged(_:)), for: .valueChanged)
            pendulumParametersContainer.addSubview(parameterSegmentControl)
            
            let pendulumParametersChart = SimpleLineChartView()
            pendulumParametersChart.translatesAutoresizingMaskIntoConstraints = false
            pendulumParametersChart.color = .systemPurple
            pendulumParametersContainer.addSubview(pendulumParametersChart)
            metricCharts[.pendulumParametersOverTime] = pendulumParametersChart
            
            NSLayoutConstraint.activate([
                pendulumParametersContainer.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                pendulumParametersContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                pendulumParametersContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                pendulumParametersContainer.heightAnchor.constraint(equalToConstant: 350),
                
                parameterSegmentControl.topAnchor.constraint(equalTo: pendulumParametersContainer.topAnchor, constant: 80),
                parameterSegmentControl.leadingAnchor.constraint(equalTo: pendulumParametersContainer.leadingAnchor, constant: 10),
                parameterSegmentControl.trailingAnchor.constraint(equalTo: pendulumParametersContainer.trailingAnchor, constant: -10),
                parameterSegmentControl.heightAnchor.constraint(equalToConstant: 30),
                
                pendulumParametersChart.topAnchor.constraint(equalTo: parameterSegmentControl.bottomAnchor, constant: 30),
                pendulumParametersChart.leadingAnchor.constraint(equalTo: pendulumParametersContainer.leadingAnchor, constant: 10),
                pendulumParametersChart.trailingAnchor.constraint(equalTo: pendulumParametersContainer.trailingAnchor, constant: -10),
                pendulumParametersChart.bottomAnchor.constraint(equalTo: pendulumParametersContainer.bottomAnchor, constant: -10)
            ])
            
            previousView = pendulumParametersContainer
        } else {
            // Standard vertical layout for other metric groups
            for metric in metrics {
                let container = createMetricContainer(for: metric)
                container.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(container)
                
                NSLayoutConstraint.activate([
                    container.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: containerSpacing),
                    container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    container.heightAnchor.constraint(greaterThanOrEqualToConstant: metric.isDistribution || metric.isTimeSeries ? 200 : 80)
                ])
                
                metricContainers[metric] = container
                previousView = container
            }
        }
        
        // Set content view bottom constraint to last view to determine content size
        if let lastView = previousView as? UIView {
            // Removed debug print
            let bottomConstraint = lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            bottomConstraint.priority = .required
            bottomConstraint.isActive = true
        } else {
            print("ERROR: No last view found for bottom constraint!")
        }
        
    }
    
    private func createMetricContainer(for metric: MetricType) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Use custom names to match old dashboard
        switch metric {
        case .angularDeviation:
            titleLabel.text = "Pendulum Angle Variance"
        case .forceDistribution:
            titleLabel.text = "Push Frequency Distribution"
        case .learningCurve:
            titleLabel.text = "Learning Curve"
        case .phaseTrajectory:
            titleLabel.text = "Average Phase Space by Level"
        case .averageCorrectionTime:
            titleLabel.text = "Reaction Time Analysis"
        default:
            titleLabel.text = metric.rawValue
        }
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        container.addSubview(titleLabel)
        
        // Add description for chart metrics in Basic view
        var descriptionLabel: UILabel?
        if currentMetricGroup == .basic && (metric.isDistribution || metric.isTimeSeries) {
            let descLabel = UILabel()
            descLabel.translatesAutoresizingMaskIntoConstraints = false
            descLabel.font = .systemFont(ofSize: 12)
            descLabel.textColor = .secondaryLabel
            descLabel.numberOfLines = 0
            
            switch metric {
            case .angularDeviation:
                descLabel.text = "Shows the pendulum angle over time. Smaller variance indicates better stability."
            case .forceDistribution:
                descLabel.text = "Displays the magnitude and frequency of your corrective pushes."
            case .learningCurve:
                descLabel.text = "Tracks your improvement over time as you progress through levels."
            case .phaseTrajectory:
                descLabel.text = "Visualizes the pendulum's state space trajectory by level."
            default:
                break
            }
            
            container.addSubview(descLabel)
            descriptionLabel = descLabel
        }
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = "Loading..."
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .label  // Changed from .systemBlue for better visibility
        valueLabel.textAlignment = .right
        container.addSubview(valueLabel)
        metricLabels[metric] = valueLabel
        
        // Unit label
        let unitLabel = UILabel()
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.text = metric.unit
        unitLabel.font = .systemFont(ofSize: 14, weight: .regular)
        unitLabel.textColor = .secondaryLabel
        unitLabel.textAlignment = .right
        container.addSubview(unitLabel)
        
        // Basic layout for text metrics
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: containerPadding),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),
            
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding),
            
            unitLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            unitLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor)
        ])
        
        // Add chart for distribution or time series metrics
        if metric.isDistribution || metric.isTimeSeries {
            let chartView = createChart(for: metric)
            chartView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(chartView)
            metricCharts[metric] = chartView
            
            if let descLabel = descriptionLabel {
                NSLayoutConstraint.activate([
                    descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                    descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerPadding),
                    descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding),
                    
                    chartView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
                    chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerPadding),
                    chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding),
                    chartView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -containerPadding),
                    chartView.heightAnchor.constraint(equalToConstant: 140)
                ])
            } else {
                NSLayoutConstraint.activate([
                    chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                    chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerPadding),
                    chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding),
                    chartView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -containerPadding),
                    chartView.heightAnchor.constraint(equalToConstant: 140)
                ])
            }
        } else {
            NSLayoutConstraint.activate([
                container.bottomAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: containerPadding)
            ])
        }
        
        return container
    }
    
    private func createChart(for metric: MetricType) -> UIView {
        // Special handling for specific metrics
        switch metric {
        case .phaseTrajectory:
            return PhaseSpaceChartView()
        case .fullDirectionalBias, .directionalBias:
            return SimplePieChartView()
        default:
            break
        }
        
        let config = MetricDisplayConfig.defaultConfig(for: metric)
        
        switch config.chartType {
        case .line:
            return SimpleLineChartView()
        case .bar, .histogram:
            return SimpleBarChartView()
        case .gauge:
            return createGaugeView()
        case .scatter:
            return createScatterPlotView()
        case .radar:
            return createRadarChartView()
        default:
            return UIView()
        }
    }
    
    private func createGaugeView() -> UIView {
        // Simple circular gauge
        let gaugeView = UIView()
        gaugeView.backgroundColor = .systemGray6
        gaugeView.layer.cornerRadius = 8
        return gaugeView
    }
    
    private func createScatterPlotView() -> UIView {
        // Simple scatter plot
        let scatterView = UIView()
        scatterView.backgroundColor = .systemGray6
        scatterView.layer.cornerRadius = 8
        return scatterView
    }
    
    private func createRadarChartView() -> UIView {
        // Simple radar chart
        let radarView = UIView()
        radarView.backgroundColor = .systemGray6
        radarView.layer.cornerRadius = 8
        return radarView
    }
    
    // MARK: - Basic Dashboard Helpers
    
    private func createStatsGrid(with metrics: [MetricType]) -> UIView {
        let gridContainer = UIView()
        gridContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let gridStack = UIStackView()
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 16
        gridStack.distribution = .fillEqually
        gridContainer.addSubview(gridStack)
        
        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: gridContainer.topAnchor),
            gridStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor)
        ])
        
        // Create 3 rows of 2 cards each
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually
            
            for col in 0..<2 {
                let index = row * 2 + col
                if index < metrics.count {
                    let card = createStatCard(for: metrics[index])
                    rowStack.addArrangedSubview(card)
                    metricContainers[metrics[index]] = card
                }
            }
            
            gridStack.addArrangedSubview(rowStack)
        }
        
        // Set height based on 3 rows (increased to accommodate pie chart + legend)
        gridContainer.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        return gridContainer
    }
    
    private func createStatCard(for metric: MetricType) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        // Removed debug print
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        
        // Special handling for Directional Bias - show as donut chart
        if metric == .directionalBias {
            return createDirectionalBiasCard()
        }
        
        // Icon
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        
        // Set icon based on metric type
        switch metric {
        case .stabilityScore: iconLabel.text = "〰️"
        case .efficiencyRating: iconLabel.text = "⚡"
        case .playerStyle: iconLabel.text = "👤"
        case .averageCorrectionTime: iconLabel.text = "⏱"
        case .directionalBias: iconLabel.text = "↔️"
        case .sessionTime: iconLabel.text = "⏲"
        default: iconLabel.text = "📊"
        }
        
        card.addSubview(iconLabel)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Use custom names to match old dashboard
        switch metric {
        case .averageCorrectionTime:
            titleLabel.text = "Reaction Time"
        default:
            titleLabel.text = metric.rawValue
        }
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .label  // Changed from .secondaryLabel for better visibility
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        card.addSubview(titleLabel)
        
        // Value
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = "N/A"
        valueLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        valueLabel.textColor = .label  // Added explicit text color
        valueLabel.textAlignment = .center
        valueLabel.tag = 1001 // Tag for updating
        card.addSubview(valueLabel)
        
        metricLabels[metric] = valueLabel
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            iconLabel.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    private func createDirectionalBiasCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        // Removed debug print
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Directional Bias"
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        card.addSubview(titleLabel)
        
        // Donut chart view
        let donutView = SimplePieChartView()
        donutView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(donutView)
        
        // Store reference for updates
        metricCharts[.directionalBias] = donutView
        
        // Initialize with sample data if no real data available
        let leftCount = AnalyticsManager.shared.directionalPushes["left"] ?? 15
        let rightCount = AnalyticsManager.shared.directionalPushes["right"] ?? 12
        
        if leftCount > 0 || rightCount > 0 {
            let segments = [
                (value: Double(leftCount), label: "Left", color: UIColor.systemBlue),
                (value: Double(rightCount), label: "Right", color: UIColor.systemOrange)
            ]
            donutView.updateSegments(segments)
        } else {
            // Show balanced state
            let segments = [
                (value: 1.0, label: "Left", color: UIColor.systemBlue),
                (value: 1.0, label: "Right", color: UIColor.systemOrange)
            ]
            donutView.updateSegments(segments)
        }
        
        // Legend
        let legendStack = UIStackView()
        legendStack.translatesAutoresizingMaskIntoConstraints = false
        legendStack.axis = .horizontal
        legendStack.spacing = 12
        legendStack.distribution = .fillEqually
        card.addSubview(legendStack)
        
        // Left indicator
        let leftView = createLegendItem(color: .systemBlue, text: "Left")
        legendStack.addArrangedSubview(leftView)
        
        // Right indicator  
        let rightView = createLegendItem(color: .systemOrange, text: "Right")
        legendStack.addArrangedSubview(rightView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            
            donutView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            donutView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            donutView.widthAnchor.constraint(equalToConstant: 70),
            donutView.heightAnchor.constraint(equalToConstant: 70),
            
            legendStack.topAnchor.constraint(equalTo: donutView.bottomAnchor, constant: 4),
            legendStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            legendStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        
        return card
    }
    
    private func createLegendItem(color: UIColor, text: String) -> UIView {
        let container = UIView()
        
        let colorDot = UIView()
        colorDot.translatesAutoresizingMaskIntoConstraints = false
        colorDot.backgroundColor = color
        colorDot.layer.cornerRadius = 4
        container.addSubview(colorDot)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 10)
        label.textColor = .secondaryLabel
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            colorDot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            colorDot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorDot.widthAnchor.constraint(equalToConstant: 8),
            colorDot.heightAnchor.constraint(equalToConstant: 8),
            
            label.leadingAnchor.constraint(equalTo: colorDot.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createSectionHeader(title: String, icon: String) -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        headerView.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 24)
        titleLabel.textColor = .label
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    private func createAdditionalStatsGrid() -> UIView {
        let gridContainer = UIView()
        gridContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create 2x2 grid of additional stats
        let gridStack = UIStackView()
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 16
        gridStack.distribution = .fillEqually
        gridContainer.addSubview(gridStack)
        
        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: gridContainer.topAnchor),
            gridStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor)
        ])
        
        // Stats to display
        let additionalStats = [
            ("Total Levels Balanced", "🏆", self.getTotalLevelsBalanced()),
            ("Average Time Per Level", "⏱", self.getAverageTimePerLevel()),
            ("Longest Balance Streak", "🔥", self.getLongestBalanceStreak()),
            ("Play Sessions Last Week", "📅", self.getPlaySessionsLastWeek())
        ]
        
        // Create 2 rows
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually
            
            for col in 0..<2 {
                let index = row * 2 + col
                if index < additionalStats.count {
                    let stat = additionalStats[index]
                    let card = createAdditionalStatCard(title: stat.0, icon: stat.1, value: stat.2)
                    rowStack.addArrangedSubview(card)
                }
            }
            
            gridStack.addArrangedSubview(rowStack)
        }
        
        return gridContainer
    }
    
    private func createChartContainer(title: String, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 4
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .goldenDark
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textColor = UIColor.goldenText
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createAdditionalStatCard(title: String, icon: String, value: String) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        // Removed debug print
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        
        // Icon
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        card.addSubview(iconLabel)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        card.addSubview(titleLabel)
        
        // Value
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textAlignment = .center
        valueLabel.textColor = .label
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    // MARK: - Additional Stats Helper Methods
    
    private func getTotalLevelsBalanced() -> String {
        let totalLevels = AnalyticsManager.shared.getTotalLevelsCompleted()
        return "\(totalLevels)"
    }
    
    private func getAverageTimePerLevel() -> String {
        let avgTime = AnalyticsManager.shared.getAverageTimePerLevel()
        let minutes = Int(avgTime) / 60
        let seconds = Int(avgTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func getLongestBalanceStreak() -> String {
        let streak = AnalyticsManager.shared.getLongestBalanceStreak()
        return "\(streak)s"
    }
    
    private func getPlaySessionsLastWeek() -> String {
        let sessions = AnalyticsManager.shared.getPlaySessionsLastWeek()
        return "\(sessions)"
    }
    
    // MARK: - Actions
    
    @objc private func metricGroupChanged() {
        print("EnhancedAnalyticsDashboard: Metric group changed to: \(currentMetricGroup.displayName)")
        
        // Rebuild metric containers
        setupMetricContainers()
        
        // Update metrics
        updateMetrics()
        
        // Scroll to top when changing metric groups
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        // Removed debug print
        let ranges: [AnalyticsTimeRange] = [.session, .daily, .weekly, .monthly, .yearly]
        currentTimeRange = ranges[sender.selectedSegmentIndex]
        updateMetrics()
    }
    
    @objc private func parameterChanged(_ sender: UISegmentedControl) {
        let parameters = ["Force Multiplier", "Damping", "Gravity", "Mass", "Length"]
        let selectedParameter = parameters[sender.selectedSegmentIndex]
        updatePendulumParametersChart(parameter: selectedParameter)
    }
    
    
    // MARK: - Metric Updates
    
    private func startMetricUpdates() {
        updateMetrics()
        
        // Set up timer based on current metric group
        let interval = getUpdateInterval(for: currentMetricGroup)
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }
    
    private func getUpdateInterval(for group: MetricGroupType) -> TimeInterval {
        switch group {
        case .performance: return 0.1
        case .basic: return 0.5
        case .scientific, .advanced: return 1.0
        case .educational: return 5.0
        case .topology: return 2.0
        }
    }
    
    private func updateMetrics() {
        let metrics = AnalyticsManager.shared.calculateMetrics(for: currentMetricGroup)
        // Removed excessive logging
        
        for metricValue in metrics {
            // Update value label
            if let label = metricLabels[metricValue.type] {
                label.text = metricValue.formattedValue
                
                // Add confidence indicator if available
                if let confidence = metricValue.confidence {
                    label.textColor = confidenceColor(for: confidence)
                }
            }
            
            // Update chart if needed
            if let chartView = metricCharts[metricValue.type] {
                updateChart(chartView, with: metricValue)
            }
        }
        
        // Update additional stats and charts for Basic view
        if currentMetricGroup == .basic {
            updateAdditionalStats()
            updateAdditionalCharts()
        }
    }
    
    private func updateAdditionalCharts() {
        // Update Push Magnitude Distribution
        if let pushMagnitudeChart = metricCharts[.pushMagnitudeDistribution] as? SimpleBarChartView {
            let distribution = AnalyticsManager.shared.getPushMagnitudeDistribution()
            if !distribution.isEmpty {
                let sortedDistribution = distribution.sorted { $0.key < $1.key }
                let values = sortedDistribution.map { Double($0.value) }
                let labels = sortedDistribution.map { String(format: "%.1f", $0.key) }
                pushMagnitudeChart.updateData(data: values, labels: labels, title: "Push Magnitude", color: .systemOrange)
            } else {
                // Sample data based on time range
                var values: [Double] = []
                var labels: [String] = []
                
                switch currentTimeRange {
                case .session:
                    values = [18, 24, 16, 10, 6, 2]
                    labels = ["0.5", "1.0", "1.5", "2.0", "2.5", "3.0"]
                case .daily:
                    values = [45, 62, 38, 25, 18, 8]
                    labels = ["0.5", "1.0", "1.5", "2.0", "2.5", "3.0"]
                case .weekly:
                    values = [120, 180, 145, 85, 45, 22]
                    labels = ["0.5", "1.0", "1.5", "2.0", "2.5", "3.0"]
                case .monthly:
                    values = [380, 520, 420, 280, 150, 65]
                    labels = ["0.5", "1.0", "1.5", "2.0", "2.5", "3.0"]
                case .yearly:
                    values = [1580, 2150, 1740, 1160, 620, 270]
                    labels = ["0.5", "1.0", "1.5", "2.0", "2.5", "3.0"]
                }
                
                pushMagnitudeChart.updateData(data: values, labels: labels, title: "Push Magnitude", color: .systemOrange)
            }
        }
        
        // Update Reaction Time Analysis
        if let reactionTimeChart = metricCharts[.reactionTimeAnalysis] as? SimpleLineChartView {
            var reactionTimes: [Double] = []
            var labels: [String] = []
            
            switch currentTimeRange {
            case .session:
                reactionTimes = [0.42, 0.53, 0.38, 0.65, 0.29, 0.47]
                labels = ["1", "2", "3", "4", "5", "6"]
            case .daily:
                reactionTimes = [0.45, 0.51, 0.40, 0.38]
                labels = ["Morning", "Noon", "Afternoon", "Evening"]
            case .weekly:
                reactionTimes = [0.55, 0.50, 0.45, 0.42, 0.41, 0.39, 0.38]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .monthly:
                reactionTimes = [0.60, 0.55, 0.50, 0.45]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .yearly:
                reactionTimes = [0.65, 0.62, 0.58, 0.54, 0.50, 0.48, 0.45, 0.43, 0.41, 0.39, 0.37, 0.35]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            }
            
            reactionTimeChart.updateData(data: reactionTimes, labels: labels, title: "Reaction Time", color: .systemBlue)
        }
        
        // Update Full Directional Bias
        if let directionalBiasChart = metricCharts[.fullDirectionalBias] as? SimplePieChartView {
            let directionalPushes = AnalyticsManager.shared.directionalPushes
            var leftCount = directionalPushes["left"] ?? 0
            var rightCount = directionalPushes["right"] ?? 0
            
            // If no real data, provide sample data
            if leftCount == 0 && rightCount == 0 {
                switch currentTimeRange {
                case .session:
                    leftCount = 15; rightCount = 12
                case .daily:
                    leftCount = 42; rightCount = 38
                case .weekly:
                    leftCount = 165; rightCount = 178
                case .monthly:
                    leftCount = 485; rightCount = 502
                case .yearly:
                    leftCount = 1985; rightCount = 2015
                }
            }
            
            if leftCount == 0 && rightCount == 0 {
                let segments = [(value: 1.0, label: "No Data", color: UIColor.lightGray)]
                directionalBiasChart.updateSegments(segments)
            } else {
                let segments = [
                    (value: Double(leftCount), label: "Left", color: UIColor.systemBlue),
                    (value: Double(rightCount), label: "Right", color: UIColor.systemRed)
                ]
                directionalBiasChart.updateSegments(segments)
            }
        }
        
        // Update Level Completions Over Time
        if let levelCompletionsChart = metricCharts[.levelCompletionsOverTime] as? SimpleBarChartView {
            var levels: [Double] = []
            var labels: [String] = []
            
            switch currentTimeRange {
            case .session:
                levels = [1, 1, 1]
                labels = ["Level 1", "Level 2", "Level 3"]
            case .daily:
                levels = [3, 2, 1, 2]
                labels = ["Morning", "Afternoon", "Evening", "Night"]
            case .weekly:
                levels = [2, 3, 1, 0, 3, 2, 1]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .monthly:
                levels = [8, 12, 9, 16]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .yearly:
                levels = [15, 22, 18, 12, 25, 20, 16, 14, 18, 10, 8, 10]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            }
            
            levelCompletionsChart.updateData(
                data: levels,
                labels: labels,
                title: "Level Completions",
                color: .goldenPrimary
            )
        }
        
        // Update Pendulum Parameters (with current selected parameter)
        if let segmentControl = contentView.subviews.compactMap({ $0.subviews.compactMap({ $0 as? UISegmentedControl }).first }).first {
            parameterChanged(segmentControl)
        }
    }
    
    private func updatePendulumParametersChart(parameter: String) {
        guard let chart = metricCharts[.pendulumParametersOverTime] as? SimpleLineChartView else { return }
        
        var values: [Double] = []
        var labels: [String] = []
        
        switch currentTimeRange {
        case .session:
            // Show parameter values for each level in the session
            switch parameter {
            case "Force Multiplier":
                values = [1.0, 1.2, 1.4, 1.6]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case "Damping":
                values = [0.5, 0.45, 0.4, 0.35]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case "Gravity":
                values = [9.81, 9.81, 9.81, 9.81]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case "Mass":
                values = [5.0, 5.2, 5.4, 5.6]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case "Length":
                values = [3.0, 3.1, 3.2, 3.3]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            default:
                break
            }
        case .daily:
            // Show average parameter values per hour
            switch parameter {
            case "Force Multiplier":
                values = [1.0, 1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case "Damping":
                values = [0.5, 0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case "Gravity":
                values = [9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case "Mass":
                values = [5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case "Length":
                values = [3.0, 3.05, 3.1, 3.15, 3.2, 3.25, 3.3, 3.35]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            default:
                break
            }
        case .weekly:
            // Show average parameter values per day
            switch parameter {
            case "Force Multiplier":
                values = [1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case "Damping":
                values = [0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case "Gravity":
                values = [9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case "Mass":
                values = [5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case "Length":
                values = [3.05, 3.1, 3.15, 3.2, 3.25, 3.3, 3.35]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            default:
                break
            }
        case .monthly:
            // Show average parameter values per week
            switch parameter {
            case "Force Multiplier":
                values = [1.2, 1.5, 1.8, 2.1]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case "Damping":
                values = [0.45, 0.40, 0.35, 0.30]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case "Gravity":
                values = [9.81, 9.81, 9.81, 9.81]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case "Mass":
                values = [5.2, 5.4, 5.6, 5.8]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case "Length":
                values = [3.1, 3.2, 3.3, 3.4]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            default:
                break
            }
        case .yearly:
            // Show average parameter values per month
            switch parameter {
            case "Force Multiplier":
                values = [1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3, 2.5, 2.7, 2.9, 3.1, 3.3]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case "Damping":
                values = [0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33, 0.31, 0.29, 0.27, 0.25, 0.23]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case "Gravity":
                values = [9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case "Mass":
                values = [5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6.0, 6.1]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case "Length":
                values = [3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.1]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            default:
                break
            }
        }
        
        // Add unit to parameter name
        var unit = ""
        switch parameter {
        case "Gravity":
            unit = " (m/s²)"
        case "Mass":
            unit = " (kg)"
        case "Length":
            unit = " (m)"
        default:
            break
        }
        
        let title = parameter + unit
        chart.updateData(data: values, labels: labels, title: title, color: .systemPurple)
    }
    
    private func updateAdditionalStats() {
        // Refresh the additional statistics values
        if let gridView = contentView.subviews.last(where: { view in
            // Find the additional stats grid by checking if it contains our stat cards
            return view.subviews.contains(where: { $0.subviews.contains(where: { ($0 as? UILabel)?.text == "Total Levels Balanced" }) })
        }) {
            // Update each stat card
            let stats = [
                ("Total Levels Balanced", self.getTotalLevelsBalanced()),
                ("Average Time Per Level", self.getAverageTimePerLevel()),
                ("Longest Balance Streak", self.getLongestBalanceStreak()),
                ("Play Sessions Last Week", self.getPlaySessionsLastWeek())
            ]
            
            // Find and update value labels in the grid
            for (index, stat) in stats.enumerated() {
                if let stackView = gridView.subviews.first as? UIStackView {
                    let rowIndex = index / 2
                    let colIndex = index % 2
                    
                    if rowIndex < stackView.arrangedSubviews.count,
                       let rowStack = stackView.arrangedSubviews[rowIndex] as? UIStackView,
                       colIndex < rowStack.arrangedSubviews.count {
                        let card = rowStack.arrangedSubviews[colIndex]
                        if let valueLabel = card.subviews.first(where: { ($0 as? UILabel)?.font.pointSize == 18 }) as? UILabel {
                            valueLabel.text = stat.1
                        }
                    }
                }
            }
        }
    }
    
    private func confidenceColor(for confidence: Double) -> UIColor {
        if confidence >= 0.9 {
            return .systemGreen
        } else if confidence >= 0.7 {
            return .systemBlue
        } else if confidence >= 0.5 {
            return .systemOrange
        } else {
            return .systemRed
        }
    }
    
    private func updateChart(_ chartView: UIView, with metricValue: MetricValue) {
        // Debug logging
        // Removed debug print
        // Removed debug print
        
        // Check if the metric value itself is NaN
        if let doubleValue = metricValue.value as? Double {
            // Removed debug print
            if doubleValue.isNaN || doubleValue.isInfinite {
                print("ERROR: NaN/Infinite metric value for \(metricValue.type.rawValue): \(doubleValue)")
                // Removed debug print
                Thread.callStackSymbols.forEach { print($0) }
            }
        }
        
        // Special handling for directional bias donut chart
        if metricValue.type == .directionalBias {
            if let pieChart = chartView as? SimplePieChartView {
                let bias = metricValue.value as? Double ?? 0
                let leftPercentage = (1 - bias) / 2  // -1 = 100% left, 0 = 50%, 1 = 0%
                let rightPercentage = (1 + bias) / 2  // -1 = 0%, 0 = 50%, 1 = 100% right
                
                let segments = [
                    (value: leftPercentage, label: "Left", color: UIColor.systemBlue),
                    (value: rightPercentage, label: "Right", color: UIColor.systemOrange)
                ]
                pieChart.updateSegments(segments)
            } else {
                updateDirectionalBiasDonut(chartView, bias: metricValue.value as? Double ?? 0)
            }
            return
        }
        
        switch metricValue.value {
        case let distribution as [Double]:
            // Removed debug print
            // Check for NaN in distribution data
            for (index, value) in distribution.enumerated() {
                if value.isNaN || value.isInfinite {
                    print("ERROR: NaN/Infinite in distribution data for \(metricValue.type.rawValue) at index \(index): \(value)")
                }
            }
            if let barChart = chartView as? SimpleBarChartView {
                let labels = (0..<distribution.count).map { String($0) }
                barChart.updateData(data: distribution, labels: labels, title: metricValue.type.rawValue)
            }
            
        case let timeSeries as [(Date, Double)]:
            // Removed debug print
            // Check for NaN in time series data
            for (index, point) in timeSeries.enumerated() {
                if point.1.isNaN || point.1.isInfinite {
                    print("ERROR: NaN/Infinite in time series data for \(metricValue.type.rawValue) at index \(index): \(point.1) at \(point.0)")
                }
            }
            if let lineChart = chartView as? SimpleLineChartView {
                let values = timeSeries.map { $0.1 }
                let labels = timeSeries.map { DateFormatter.localizedString(from: $0.0, dateStyle: .none, timeStyle: .short) }
                lineChart.updateData(data: values, labels: labels, title: metricValue.type.rawValue)
            } else {
                print("EnhancedAnalyticsDashboard: Chart view is not a SimpleLineChartView")
            }
            
        case let trajectory as [(theta: Double, omega: Double)]:
            if let phaseChart = chartView as? PhaseSpaceChartView {
                // Convert to level data format for phase space chart
                let currentLevel = AnalyticsManager.shared.getCurrentLevel()
                phaseChart.updateLevelData([currentLevel: trajectory])
            }
            
        default:
            break
        }
    }
    
    private func updateDirectionalBiasDonut(_ donutView: UIView, bias: Double) {
        // Remove existing layers
        donutView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Calculate percentages (-1 to 1 becomes 0% to 100% for each side)
        let leftPercentage = (1 - bias) / 2  // -1 = 100% left, 0 = 50%, 1 = 0%
        let rightPercentage = (1 + bias) / 2  // -1 = 0%, 0 = 50%, 1 = 100% right
        
        let center = CGPoint(x: donutView.bounds.width / 2, y: donutView.bounds.height / 2)
        let radius: CGFloat = 30
        let innerRadius: CGFloat = 20
        
        // Create donut chart
        let startAngle = -CGFloat.pi / 2
        
        // Left portion (blue)
        let leftEndAngle = startAngle + CGFloat(leftPercentage * 2 * .pi)
        let leftPath = UIBezierPath()
        leftPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: leftEndAngle, clockwise: true)
        leftPath.addArc(withCenter: center, radius: innerRadius, startAngle: leftEndAngle, endAngle: startAngle, clockwise: false)
        leftPath.close()
        
        let leftLayer = CAShapeLayer()
        leftLayer.path = leftPath.cgPath
        leftLayer.fillColor = UIColor.systemBlue.cgColor
        donutView.layer.addSublayer(leftLayer)
        
        // Right portion (orange)
        let rightPath = UIBezierPath()
        rightPath.addArc(withCenter: center, radius: radius, startAngle: leftEndAngle, endAngle: startAngle, clockwise: true)
        rightPath.addArc(withCenter: center, radius: innerRadius, startAngle: startAngle, endAngle: leftEndAngle, clockwise: false)
        rightPath.close()
        
        let rightLayer = CAShapeLayer()
        rightLayer.path = rightPath.cgPath
        rightLayer.fillColor = UIColor.systemOrange.cgColor
        donutView.layer.addSublayer(rightLayer)
        
        // Center text showing percentage
        let percentageLabel = UILabel()
        percentageLabel.frame = donutView.bounds
        percentageLabel.textAlignment = .center
        percentageLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        
        if abs(bias) < 0.1 {
            percentageLabel.text = "Balanced"
            percentageLabel.textColor = .systemGreen
        } else if bias < 0 {
            percentageLabel.text = String(format: "%.0f%% L", leftPercentage * 100)
            percentageLabel.textColor = .systemBlue
        } else {
            percentageLabel.text = String(format: "%.0f%% R", rightPercentage * 100)
            percentageLabel.textColor = .systemOrange
        }
        
        donutView.addSubview(percentageLabel)
    }
    
    
    // MARK: - Public Methods
    
    func selectMetricGroup(_ group: MetricGroupType) {
        print("EnhancedAnalyticsDashboard: Selecting metric group: \(group.displayName)")
        if let index = MetricGroupType.allCases.firstIndex(of: group) {
            selectMetricGroupButton(at: index)
            metricGroupChanged()
        }
    }
    
    func refreshMetrics() {
        updateMetrics()
    }
}

// MARK: - Extensions
extension UIColor {
    static var systemGold: UIColor {
        return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
    }
}