// AnalyticsDashboardViewNative.swift
// Analytics dashboard using native charts (no dependency required)

import UIKit

// TimeRange enum definition (same as in original)
enum AnalyticsTimeRange {
    case session
    case daily
    case weekly
    case monthly
}

class AnalyticsDashboardViewNative: UIView, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Data labels
    private var stabilityScoreLabel: UILabel!
    private var efficiencyRatingLabel: UILabel!
    private var playerStyleLabel: UILabel!
    private var reactionTimeLabel: UILabel!
    private var directionalBiasLabel: UILabel!
    private var sessionTimeLabel: UILabel!
    
    // Charts
    private var angleVarianceChart: SimpleLineChartView!
    private var pushFrequencyChart: SimpleBarChartView!
    private var pushMagnitudeChart: SimpleBarChartView!
    private var reactionTimeChart: SimpleLineChartView!
    private var learningCurveChart: SimpleLineChartView!
    private var directionalBiasChart: SimplePieChartView!
    
    // Time range control
    private var timeSegmentControl: UISegmentedControl!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        // Initialize charts with sample data for session timeframe
        loadInitialData()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        // Initialize charts with sample data for session timeframe
        loadInitialData()
    }

    private func loadInitialData() {
        // Initially select the session time range
        selectedTimeRange = .session
        timeSegmentControl.selectedSegmentIndex = 0

        // Load sample data for the selected time range
        loadSummaryMetrics(timeRange: selectedTimeRange, sessionId: nil)
        loadAngleVarianceChart(timeRange: selectedTimeRange, sessionId: nil)
        loadPushFrequencyChart(timeRange: selectedTimeRange, sessionId: nil)
        loadPushMagnitudeChart(timeRange: selectedTimeRange, sessionId: nil)
        loadReactionTimeChart(timeRange: selectedTimeRange, sessionId: nil)
        loadLearningCurveChart(timeRange: selectedTimeRange, sessionId: nil)
        loadDirectionalBiasChart(timeRange: selectedTimeRange, sessionId: nil)
        updateAdditionalMetrics(timeRange: "Session")
        updateLevelCompletionsChart(timeRange: "Session")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .goldenBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add header title
        let headerTitle = createHeaderLabel("Pendulum Analytics")
        contentView.addSubview(headerTitle)
        
        // Configure header title constraints after adding to view hierarchy
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerTitle.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add time range segment control
        setupTimeRangeControl()
        
        // Add summary cards
        setupSummaryCards()
        
        // Add detailed charts
        setupCharts()
        
        // Setup content height (will be adjusted as charts are added)
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 2300) // Increased from 2000 to 2300
        heightConstraint.priority = .defaultLow // Allow it to grow based on content
        heightConstraint.isActive = true
    }
    
    private func setupTimeRangeControl() {
        timeSegmentControl = UISegmentedControl(items: ["Session", "Daily", "Weekly", "Monthly"])
        timeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        timeSegmentControl.selectedSegmentIndex = 0

        // Use Golden theme colors
        timeSegmentControl.selectedSegmentTintColor = .goldenPrimary
        timeSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        timeSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.goldenDark], for: .normal)

        contentView.addSubview(timeSegmentControl)

        // Get the header title - it should be the first UILabel in contentView
        let headerTitle = contentView.subviews.first(where: { $0 is UILabel }) as? UILabel

        NSLayoutConstraint.activate([
            timeSegmentControl.topAnchor.constraint(equalTo: headerTitle?.bottomAnchor ?? contentView.topAnchor, constant: 20),
            timeSegmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeSegmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timeSegmentControl.heightAnchor.constraint(equalToConstant: 40)
        ])

        // IMPORTANT: Add the target after all configuration is done, to prevent early triggering
        timeSegmentControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
    }
    
    private func setupSummaryCards() {
        // Create container for summary cards
        let summaryContainer = UIView()
        summaryContainer.translatesAutoresizingMaskIntoConstraints = false
        summaryContainer.backgroundColor = .clear
        contentView.addSubview(summaryContainer)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            summaryContainer.topAnchor.constraint(equalTo: timeSegmentControl.bottomAnchor, constant: 20),
            summaryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        // Create the summary cards
        let metrics = [
            ["title": "Stability Score", "icon": "waveform.path", "color": UIColor.systemBlue],
            ["title": "Efficiency Rating", "icon": "bolt.fill", "color": UIColor.systemGreen],
            ["title": "Player Style", "icon": "person.fill", "color": UIColor.systemIndigo],
            ["title": "Reaction Time", "icon": "timer", "color": UIColor.systemOrange],
            ["title": "Directional Bias", "icon": "arrow.left.arrow.right", "color": UIColor.systemPurple],
            ["title": "Session Time", "icon": "clock.fill", "color": UIColor.systemTeal]
        ]
        
        // Create a horizontal grid of 2x3 cards
        var cardViews: [UIView] = []
        
        for (index, metric) in metrics.enumerated() {
            let card = createSummaryCard(
                title: metric["title"] as! String,
                iconName: metric["icon"] as! String,
                color: metric["color"] as! UIColor
            )
            
            summaryContainer.addSubview(card)
            cardViews.append(card)
            
            // Store labels for updating values later
            let valueLabel = card.subviews.compactMap { $0 as? UILabel }.last!
            
            switch metric["title"] as! String {
            case "Stability Score":
                stabilityScoreLabel = valueLabel
            case "Efficiency Rating":
                efficiencyRatingLabel = valueLabel
            case "Player Style":
                playerStyleLabel = valueLabel
            case "Reaction Time":
                reactionTimeLabel = valueLabel
            case "Directional Bias":
                directionalBiasLabel = valueLabel
            case "Session Time":
                sessionTimeLabel = valueLabel
            default:
                break
            }
            
            // Layout in a 2-column grid
            let row = index / 2
            let col = index % 2
            
            if col == 0 {
                // Left column
                card.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor).isActive = true
                card.trailingAnchor.constraint(equalTo: summaryContainer.centerXAnchor, constant: -5).isActive = true
            } else {
                // Right column
                card.leadingAnchor.constraint(equalTo: summaryContainer.centerXAnchor, constant: 5).isActive = true
                card.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor).isActive = true
            }
            
            if row == 0 {
                // First row
                card.topAnchor.constraint(equalTo: summaryContainer.topAnchor).isActive = true
            } else {
                // Subsequent rows
                let previousRowCard = cardViews[(row-1)*2]
                card.topAnchor.constraint(equalTo: previousRowCard.bottomAnchor, constant: 10).isActive = true
            }
            
            card.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            // If this is the last card, set the bottom constraint
            if index == metrics.count - 1 || index == metrics.count - 2 {
                card.bottomAnchor.constraint(equalTo: summaryContainer.bottomAnchor).isActive = true
            }
        }
    }
    
    private func setupCharts() {
        // Create charts container
        let chartsContainer = UIView()
        chartsContainer.translatesAutoresizingMaskIntoConstraints = false
        chartsContainer.backgroundColor = .clear
        contentView.addSubview(chartsContainer)
        
        // Get reference to summary container
        let summaryContainer = contentView.subviews.filter { $0 != timeSegmentControl && $0 != contentView.subviews.first }.first!
        
        // Layout constraints
        NSLayoutConstraint.activate([
            chartsContainer.topAnchor.constraint(equalTo: summaryContainer.bottomAnchor, constant: 20),
            chartsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chartsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50) // Increased padding from -20 to -50
        ])
        
        // Add section title
        let sectionTitle = createSectionLabel("Performance Charts")
        chartsContainer.addSubview(sectionTitle)
        
        // Add Charts
        
        // 1. Angle Variance Chart
        let angleVarianceSection = createChartSection(
            title: "Pendulum Angle Variance",
            description: "Shows the pendulum angle over time. Smaller variance indicates better stability."
        )
        chartsContainer.addSubview(angleVarianceSection)
        
        angleVarianceChart = SimpleLineChartView()
        angleVarianceChart.translatesAutoresizingMaskIntoConstraints = false
        angleVarianceChart.color = .goldenPrimary
        angleVarianceSection.addSubview(angleVarianceChart)
        
        // 2. Push Frequency Chart
        let pushFrequencySection = createChartSection(
            title: "Push Frequency Distribution",
            description: "Shows how frequently you apply forces to the pendulum."
        )
        chartsContainer.addSubview(pushFrequencySection)
        
        pushFrequencyChart = SimpleBarChartView()
        pushFrequencyChart.translatesAutoresizingMaskIntoConstraints = false
        pushFrequencyChart.color = .goldenAccent
        pushFrequencySection.addSubview(pushFrequencyChart)
        
        // 3. Push Magnitude Chart 
        let pushMagnitudeSection = createChartSection(
            title: "Push Magnitude Distribution",
            description: "Shows the distribution of force magnitudes you apply."
        )
        chartsContainer.addSubview(pushMagnitudeSection)
        
        pushMagnitudeChart = SimpleBarChartView()
        pushMagnitudeChart.translatesAutoresizingMaskIntoConstraints = false
        pushMagnitudeChart.color = .systemOrange
        pushMagnitudeSection.addSubview(pushMagnitudeChart)
        
        // 4. Reaction Time Chart
        let reactionTimeSection = createChartSection(
            title: "Reaction Time Analysis",
            description: "Shows how quickly you respond to pendulum instability."
        )
        chartsContainer.addSubview(reactionTimeSection)
        
        reactionTimeChart = SimpleLineChartView()
        reactionTimeChart.translatesAutoresizingMaskIntoConstraints = false
        reactionTimeChart.color = .systemBlue
        reactionTimeSection.addSubview(reactionTimeChart)
        
        // 5. Learning Curve Chart
        let learningCurveSection = createChartSection(
            title: "Learning Curve",
            description: "Shows your improvement over time based on stability scores."
        )
        chartsContainer.addSubview(learningCurveSection)
        
        learningCurveChart = SimpleLineChartView()
        learningCurveChart.translatesAutoresizingMaskIntoConstraints = false
        learningCurveChart.color = .systemGreen
        learningCurveSection.addSubview(learningCurveChart)
        
        // 6. Directional Bias Chart
        let directionalBiasSection = createChartSection(
            title: "Directional Bias",
            description: "Shows your tendency to favor left vs. right corrections."
        )
        chartsContainer.addSubview(directionalBiasSection)
        
        directionalBiasChart = SimplePieChartView()
        directionalBiasChart.translatesAutoresizingMaskIntoConstraints = false
        directionalBiasSection.addSubview(directionalBiasChart)
        
        // Layout the chart sections vertically
        NSLayoutConstraint.activate([
            // Section title
            sectionTitle.topAnchor.constraint(equalTo: chartsContainer.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            sectionTitle.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            
            // Angle variance chart
            angleVarianceSection.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 20),
            angleVarianceSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            angleVarianceSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            angleVarianceSection.heightAnchor.constraint(equalToConstant: 300),
            
            angleVarianceChart.topAnchor.constraint(equalTo: angleVarianceSection.topAnchor, constant: 60),
            angleVarianceChart.leadingAnchor.constraint(equalTo: angleVarianceSection.leadingAnchor, constant: 10),
            angleVarianceChart.trailingAnchor.constraint(equalTo: angleVarianceSection.trailingAnchor, constant: -10),
            angleVarianceChart.bottomAnchor.constraint(equalTo: angleVarianceSection.bottomAnchor, constant: -10),
            
            // Push frequency chart
            pushFrequencySection.topAnchor.constraint(equalTo: angleVarianceSection.bottomAnchor, constant: 20),
            pushFrequencySection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            pushFrequencySection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            pushFrequencySection.heightAnchor.constraint(equalToConstant: 300),
            
            pushFrequencyChart.topAnchor.constraint(equalTo: pushFrequencySection.topAnchor, constant: 60),
            pushFrequencyChart.leadingAnchor.constraint(equalTo: pushFrequencySection.leadingAnchor, constant: 10),
            pushFrequencyChart.trailingAnchor.constraint(equalTo: pushFrequencySection.trailingAnchor, constant: -10),
            pushFrequencyChart.bottomAnchor.constraint(equalTo: pushFrequencySection.bottomAnchor, constant: -10),
            
            // Push magnitude chart
            pushMagnitudeSection.topAnchor.constraint(equalTo: pushFrequencySection.bottomAnchor, constant: 20),
            pushMagnitudeSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            pushMagnitudeSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            pushMagnitudeSection.heightAnchor.constraint(equalToConstant: 300),
            
            pushMagnitudeChart.topAnchor.constraint(equalTo: pushMagnitudeSection.topAnchor, constant: 60),
            pushMagnitudeChart.leadingAnchor.constraint(equalTo: pushMagnitudeSection.leadingAnchor, constant: 10),
            pushMagnitudeChart.trailingAnchor.constraint(equalTo: pushMagnitudeSection.trailingAnchor, constant: -10),
            pushMagnitudeChart.bottomAnchor.constraint(equalTo: pushMagnitudeSection.bottomAnchor, constant: -10),
            
            // Reaction time chart
            reactionTimeSection.topAnchor.constraint(equalTo: pushMagnitudeSection.bottomAnchor, constant: 20),
            reactionTimeSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            reactionTimeSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            reactionTimeSection.heightAnchor.constraint(equalToConstant: 300),
            
            reactionTimeChart.topAnchor.constraint(equalTo: reactionTimeSection.topAnchor, constant: 60),
            reactionTimeChart.leadingAnchor.constraint(equalTo: reactionTimeSection.leadingAnchor, constant: 10),
            reactionTimeChart.trailingAnchor.constraint(equalTo: reactionTimeSection.trailingAnchor, constant: -10),
            reactionTimeChart.bottomAnchor.constraint(equalTo: reactionTimeSection.bottomAnchor, constant: -10),
            
            // Learning curve chart
            learningCurveSection.topAnchor.constraint(equalTo: reactionTimeSection.bottomAnchor, constant: 20),
            learningCurveSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            learningCurveSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            learningCurveSection.heightAnchor.constraint(equalToConstant: 300),
            
            learningCurveChart.topAnchor.constraint(equalTo: learningCurveSection.topAnchor, constant: 60),
            learningCurveChart.leadingAnchor.constraint(equalTo: learningCurveSection.leadingAnchor, constant: 10),
            learningCurveChart.trailingAnchor.constraint(equalTo: learningCurveSection.trailingAnchor, constant: -10),
            learningCurveChart.bottomAnchor.constraint(equalTo: learningCurveSection.bottomAnchor, constant: -10),
            
            // Directional bias chart
            directionalBiasSection.topAnchor.constraint(equalTo: learningCurveSection.bottomAnchor, constant: 30), // Increased from 20 to 30
            directionalBiasSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            directionalBiasSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            directionalBiasSection.heightAnchor.constraint(equalToConstant: 320), // Increased from 300 to 320
            // Removed the bottom constraint to chartsContainer.bottomAnchor to prevent overlap
            
            directionalBiasChart.topAnchor.constraint(equalTo: directionalBiasSection.topAnchor, constant: 60),
            directionalBiasChart.leadingAnchor.constraint(equalTo: directionalBiasSection.leadingAnchor, constant: 10),
            directionalBiasChart.trailingAnchor.constraint(equalTo: directionalBiasSection.trailingAnchor, constant: -10),
            directionalBiasChart.bottomAnchor.constraint(equalTo: directionalBiasSection.bottomAnchor, constant: -10)
        ])

        // Add additional metrics section
        setupAdditionalMetricsSection(after: directionalBiasSection)
    }
    
    // MARK: - Additional Metrics

    private func setupAdditionalMetricsSection(after lastSection: UIView) {
        let chartsContainer = lastSection.superview!

        // Create section for additional metrics
        let additionalMetricsTitle = createSectionLabel("Additional Statistics")
        additionalMetricsTitle.translatesAutoresizingMaskIntoConstraints = false
        chartsContainer.addSubview(additionalMetricsTitle)

        // Create a container for additional metrics cards
        let additionalMetricsContainer = UIView()
        additionalMetricsContainer.translatesAutoresizingMaskIntoConstraints = false
        additionalMetricsContainer.backgroundColor = .clear
        chartsContainer.addSubview(additionalMetricsContainer)

        // Create cards for the additional metrics
        let metricsData = [
            ["title": "Total Levels Balanced", "icon": "checkmark.circle.fill", "color": UIColor.systemGreen],
            ["title": "Average Time Per Level", "icon": "timer", "color": UIColor.systemBlue],
            ["title": "Longest Balance Streak", "icon": "flame.fill", "color": UIColor.systemOrange],
            ["title": "Play Sessions (Last Week)", "icon": "calendar", "color": UIColor.systemIndigo]
        ]

        var metricCards: [UIView] = []

        for (index, data) in metricsData.enumerated() {
            let card = createSummaryCard(
                title: data["title"] as! String,
                iconName: data["icon"] as! String,
                color: data["color"] as! UIColor
            )
            additionalMetricsContainer.addSubview(card)
            metricCards.append(card)

            // Layout in a 2-column grid
            let row = index / 2
            let col = index % 2

            if col == 0 {
                // Left column
                card.leadingAnchor.constraint(equalTo: additionalMetricsContainer.leadingAnchor).isActive = true
                card.trailingAnchor.constraint(equalTo: additionalMetricsContainer.centerXAnchor, constant: -5).isActive = true
            } else {
                // Right column
                card.leadingAnchor.constraint(equalTo: additionalMetricsContainer.centerXAnchor, constant: 5).isActive = true
                card.trailingAnchor.constraint(equalTo: additionalMetricsContainer.trailingAnchor).isActive = true
            }

            if row == 0 {
                // First row
                card.topAnchor.constraint(equalTo: additionalMetricsContainer.topAnchor).isActive = true
            } else {
                // Subsequent rows
                let previousRowCard = metricCards[(row-1)*2]
                card.topAnchor.constraint(equalTo: previousRowCard.bottomAnchor, constant: 10).isActive = true
            }

            card.heightAnchor.constraint(equalToConstant: 100).isActive = true

            // If this is the last card, set the bottom constraint
            if index == metricsData.count - 1 || index == metricsData.count - 2 {
                card.bottomAnchor.constraint(equalTo: additionalMetricsContainer.bottomAnchor).isActive = true
            }
        }

        // Create level completions bar chart
        let levelCompletionsSection = createChartSection(
            title: "Level Completions Over Time",
            description: "Shows how many levels you've completed per time period."
        )
        chartsContainer.addSubview(levelCompletionsSection)

        let levelCompletionsChart = SimpleBarChartView()
        levelCompletionsChart.translatesAutoresizingMaskIntoConstraints = false
        levelCompletionsChart.color = .goldenPrimary
        levelCompletionsSection.addSubview(levelCompletionsChart)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            additionalMetricsTitle.topAnchor.constraint(equalTo: lastSection.bottomAnchor, constant: 50),
            additionalMetricsTitle.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            additionalMetricsTitle.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),

            // Metrics container - now directly below the title (no time selector in between)
            additionalMetricsContainer.topAnchor.constraint(equalTo: additionalMetricsTitle.bottomAnchor, constant: 15),
            additionalMetricsContainer.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            additionalMetricsContainer.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),

            // Level completions chart
            levelCompletionsSection.topAnchor.constraint(equalTo: additionalMetricsContainer.bottomAnchor, constant: 20),
            levelCompletionsSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            levelCompletionsSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            levelCompletionsSection.heightAnchor.constraint(equalToConstant: 300),
            levelCompletionsSection.bottomAnchor.constraint(equalTo: chartsContainer.bottomAnchor, constant: -20),

            levelCompletionsChart.topAnchor.constraint(equalTo: levelCompletionsSection.topAnchor, constant: 60),
            levelCompletionsChart.leadingAnchor.constraint(equalTo: levelCompletionsSection.leadingAnchor, constant: 10),
            levelCompletionsChart.trailingAnchor.constraint(equalTo: levelCompletionsSection.trailingAnchor, constant: -10),
            levelCompletionsChart.bottomAnchor.constraint(equalTo: levelCompletionsSection.bottomAnchor, constant: -10),
        ])

        // Initialize with sample data - now using the main time range selector
        updateAdditionalMetrics(timeRange: "Session")
        updateLevelCompletionsChart(timeRange: "Session")
    }

    // Combined time range handler - updates both performance charts and additional metrics
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        // Manual direct handling of segmented control change
        let selectedIndex = sender.selectedSegmentIndex

        // Convert segment index to time range
        let range: AnalyticsTimeRange
        let stringRange: String

        switch selectedIndex {
        case 0:
            range = .session
            stringRange = "Session"
        case 1:
            range = .daily
            stringRange = "Daily"
        case 2:
            range = .weekly
            stringRange = "Week"
        case 3:
            range = .monthly
            stringRange = "Month"
        default:
            range = .session
            stringRange = "Session"
        }

        // Update our tracking property
        selectedTimeRange = range

        // Load data directly without calling updateDashboard
        loadSummaryMetrics(timeRange: range, sessionId: nil)
        loadAngleVarianceChart(timeRange: range, sessionId: nil)
        loadPushFrequencyChart(timeRange: range, sessionId: nil)
        loadPushMagnitudeChart(timeRange: range, sessionId: nil)
        loadReactionTimeChart(timeRange: range, sessionId: nil)
        loadLearningCurveChart(timeRange: range, sessionId: nil)
        loadDirectionalBiasChart(timeRange: range, sessionId: nil)

        // Also update additional metrics sections
        updateAdditionalMetrics(timeRange: stringRange)
        updateLevelCompletionsChart(timeRange: stringRange)
    }

    private func updateAdditionalMetrics(timeRange: String) {
        // In a real implementation, these would fetch from Core Data based on time range
        // For now, we'll use sample data

        // Find the metric cards
        let metricContainers = contentView.subviews.compactMap { $0.subviews }
            .flatMap { $0 }
            .filter { $0.backgroundColor == .clear }

        let metricCards = metricContainers.flatMap { $0.subviews }
            .filter { $0.layer.cornerRadius == 12 }

        // Sample data based on time range
        var totalLevels = 0
        var avgTimePerLevel = 0.0
        var longestStreak = 0
        var playSessions = 0

        switch timeRange {
        case "Session":
            totalLevels = 3
            avgTimePerLevel = 35.2
            longestStreak = 3
            playSessions = 1
        case "Daily":
            totalLevels = 8
            avgTimePerLevel = 33.8
            longestStreak = 4
            playSessions = 4
        case "Week":
            totalLevels = 12
            avgTimePerLevel = 32.5
            longestStreak = 5
            playSessions = 8
        case "Month":
            totalLevels = 45
            avgTimePerLevel = 28.7
            longestStreak = 12
            playSessions = 22
        case "Year":
            totalLevels = 186
            avgTimePerLevel = 24.3
            longestStreak = 18
            playSessions = 95
        case "All Time":
            totalLevels = 247
            avgTimePerLevel = 22.1
            longestStreak = 24
            playSessions = 120
        default:
            totalLevels = 3
            avgTimePerLevel = 35.2
            longestStreak = 3
            playSessions = 1
        }

        // Update the card values
        for card in metricCards {
            if let titleLabel = card.subviews.first(where: { $0 is UILabel }) as? UILabel {
                let valueLabel = card.subviews.last(where: { $0 is UILabel }) as? UILabel

                switch titleLabel.text {
                case "Total Levels Balanced":
                    valueLabel?.text = "\(totalLevels)"
                case "Average Time Per Level":
                    valueLabel?.text = String(format: "%.1fs", avgTimePerLevel)
                case "Longest Balance Streak":
                    valueLabel?.text = "\(longestStreak) levels"
                case "Play Sessions (Last Week)":
                    valueLabel?.text = "\(playSessions)"
                default:
                    break
                }
            }
        }
    }

    private func updateLevelCompletionsChart(timeRange: String) {
        // Find the chart
        let chartSections = contentView.subviews.compactMap { $0.subviews }
            .flatMap { $0 }
            .filter { view in
                if let label = view.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    return label.text == "Level Completions Over Time"
                }
                return false
            }

        guard let chartSection = chartSections.first,
              let chart = chartSection.subviews.first(where: { $0 is SimpleBarChartView }) as? SimpleBarChartView else {
            return
        }

        // Sample data based on time range
        var levels: [Double] = []
        var labels: [String] = []

        switch timeRange {
        case "Session":
            levels = [1, 1, 1]
            labels = ["Level 1", "Level 2", "Level 3"]
        case "Daily":
            levels = [3, 2, 1, 2]
            labels = ["Morning", "Afternoon", "Evening", "Night"]
        case "Week":
            levels = [2, 3, 1, 0, 3, 2, 1]
            labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case "Month":
            levels = [8, 12, 9, 16]
            labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
        case "Year":
            levels = [15, 22, 18, 12, 25, 20, 16, 14, 18, 10, 8, 10]
            labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        case "All Time":
            levels = [45, 60, 83, 59]
            labels = ["2022", "2023", "2024", "2025"]
        default:
            levels = [1, 1, 1]
            labels = ["Level 1", "Level 2", "Level 3"]
        }

        // Update chart
        chart.updateData(
            data: levels,
            labels: labels,
            title: "Level Completions: \(timeRange)",
            color: .goldenPrimary
        )
    }

    // MARK: - Helper Functions for UI Components
    
    private func createHeaderLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .goldenPrimary
        label.textAlignment = .center
        // We'll configure constraints in setupUI after adding the label to the view hierarchy
        return label
    }
    
    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .goldenDark
        label.textAlignment = .left
        
        return label
    }
    
    private func createSummaryCard(title: String, iconName: String, color: UIColor) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = (UIColor.goldenText as UIColor)
        card.addSubview(titleLabel)
        
        // Icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconImage = UIImage(systemName: iconName, withConfiguration: iconConfig)
        let iconView = UIImageView(image: iconImage)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = color
        card.addSubview(iconView)
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = "Loading..."
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        card.addSubview(valueLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    private func createChartSection(title: String, description: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 4
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .goldenDark
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = (UIColor.goldenText as UIColor)
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
    
    // MARK: - Data Updates
    
    // The selected time range - use this to track the current state
    private var selectedTimeRange: AnalyticsTimeRange = .session

    func updateDashboard(timeRange: AnalyticsTimeRange? = nil, sessionId: UUID? = nil) {
        // Only update the selectedTimeRange if explicitly provided
        if let newTimeRange = timeRange {
            selectedTimeRange = newTimeRange

            // Update UI to match our tracking property
            switch selectedTimeRange {
            case .session:
                if timeSegmentControl.selectedSegmentIndex != 0 {
                    timeSegmentControl.selectedSegmentIndex = 0
                }
            case .daily:
                if timeSegmentControl.selectedSegmentIndex != 1 {
                    timeSegmentControl.selectedSegmentIndex = 1
                }
            case .weekly:
                if timeSegmentControl.selectedSegmentIndex != 2 {
                    timeSegmentControl.selectedSegmentIndex = 2
                }
            case .monthly:
                if timeSegmentControl.selectedSegmentIndex != 3 {
                    timeSegmentControl.selectedSegmentIndex = 3
                }
            }
        } else {
            // If timeRange is nil, get the current selection from the segment control
            let currentIndex = timeSegmentControl.selectedSegmentIndex

            switch currentIndex {
            case 0:
                selectedTimeRange = .session
            case 1:
                selectedTimeRange = .daily
            case 2:
                selectedTimeRange = .weekly
            case 3:
                selectedTimeRange = .monthly
            default:
                selectedTimeRange = .session
            }
        }

        // Convert the enum time range to a string for the additional metrics
        let stringTimeRange: String
        switch selectedTimeRange {
        case .session:
            stringTimeRange = "Session"
        case .daily:
            stringTimeRange = "Daily"
        case .weekly:
            stringTimeRange = "Week"
        case .monthly:
            stringTimeRange = "Month"
        }

        // Load all data using the selectedTimeRange
        loadSummaryMetrics(timeRange: selectedTimeRange, sessionId: sessionId)
        loadAngleVarianceChart(timeRange: selectedTimeRange, sessionId: sessionId)
        loadPushFrequencyChart(timeRange: selectedTimeRange, sessionId: sessionId)
        loadPushMagnitudeChart(timeRange: selectedTimeRange, sessionId: sessionId)
        loadReactionTimeChart(timeRange: selectedTimeRange, sessionId: sessionId)
        loadLearningCurveChart(timeRange: selectedTimeRange, sessionId: sessionId)
        loadDirectionalBiasChart(timeRange: selectedTimeRange, sessionId: sessionId)

        // Update additional metrics
        updateAdditionalMetrics(timeRange: stringTimeRange)
        updateLevelCompletionsChart(timeRange: stringTimeRange)
    }
    
    private func loadSummaryMetrics(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        var metrics: [String: Any] = [:]

        // Try to get metrics from AnalyticsManager, handle empty case gracefully
        do {
            switch timeRange {
            case .session:
                if let sessionId = sessionId {
                    metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
                } else {
                    metrics = AnalyticsManager.shared.getPerformanceMetrics()
                }
            case .daily, .weekly, .monthly:
                let period = timeRange == .daily ? "daily" : timeRange == .weekly ? "weekly" : "monthly"
                metrics = AnalyticsManager.shared.getAggregatedAnalytics(period: period)
            }
        } catch {
            print("Error loading metrics: \(error)")
            // Metrics will remain empty, which is handled below
        }

        // If metrics is empty, provide sample data based on time range
        if metrics.isEmpty {
            switch timeRange {
            case .session:
                metrics = [
                    "stabilityScore": 78.5,
                    "efficiencyRating": 82.1,
                    "playerStyle": "Balanced",
                    "averageCorrectionTime": 0.45,
                    "directionalBias": 0.12,
                    "totalPlayTime": 180.0
                ]
            case .daily:
                metrics = [
                    "stabilityScore": 75.2,
                    "efficiencyRating": 80.7,
                    "playerStyle": "Reactive",
                    "averageCorrectionTime": 0.52,
                    "directionalBias": -0.08,
                    "totalPlayTime": 620.0
                ]
            case .weekly:
                metrics = [
                    "stabilityScore": 81.8,
                    "efficiencyRating": 84.3,
                    "playerStyle": "Precise",
                    "averageCorrectionTime": 0.38,
                    "directionalBias": 0.05,
                    "totalPlayTime": 2450.0
                ]
            case .monthly:
                metrics = [
                    "stabilityScore": 85.6,
                    "efficiencyRating": 87.9,
                    "playerStyle": "Expert",
                    "averageCorrectionTime": 0.32,
                    "directionalBias": 0.03,
                    "totalPlayTime": 9200.0
                ]
            }
        }

        // Update summary labels with safe unwrapping
        stabilityScoreLabel.text = (metrics["stabilityScore"] as? Double).map {
            String(format: "%.1f", $0)
        } ?? "N/A"

        efficiencyRatingLabel.text = (metrics["efficiencyRating"] as? Double).map {
            String(format: "%.1f", $0)
        } ?? "N/A"

        playerStyleLabel.text = metrics["playerStyle"] as? String ?? "Unknown"

        reactionTimeLabel.text = (metrics["averageCorrectionTime"] as? Double).map {
            String(format: "%.2fs", $0)
        } ?? "N/A"

        directionalBiasLabel.text = (metrics["directionalBias"] as? Double).map {
            formatDirectionalBias($0)
        } ?? "N/A"

        sessionTimeLabel.text = (metrics["totalPlayTime"] as? Double).map {
            formatTimeInterval($0)
        } ?? "N/A"
    }
    
    private func loadAngleVarianceChart(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        // Get angle data from AnalyticsManager
        var timeSeriesData: [[String: Any]] = []

        switch timeRange {
        case .session:
            if let sessionId = sessionId {
                timeSeriesData = AnalyticsManager.shared.getInteractionTimeSeries(timeframe: -3600) // Last hour
            }
        case .daily:
            timeSeriesData = AnalyticsManager.shared.getInteractionTimeSeries(timeframe: -86400) // Last 24 hours
        case .weekly:
            timeSeriesData = AnalyticsManager.shared.getInteractionTimeSeries(timeframe: -604800) // Last 7 days
        case .monthly:
            timeSeriesData = AnalyticsManager.shared.getInteractionTimeSeries(timeframe: -2592000) // Last 30 days
        }

        // If no data, provide sample data based on time range
        if timeSeriesData.isEmpty {
            var angleValues: [Double] = []
            var labels: [String] = []

            switch timeRange {
            case .session:
                // Simulated angle variances for a single session (10 data points)
                angleValues = [12.5, 15.2, 18.7, 10.3, 8.1, 5.6, 7.2, 9.5, 4.8, 3.2]
                labels = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30"]
            case .daily:
                // Simulated hourly angle variances for a day
                angleValues = [14.2, 12.8, 10.5, 9.2, 7.8, 6.5, 8.1, 9.3]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case .weekly:
                // Simulated daily angle variances for a week
                angleValues = [15.2, 13.8, 12.5, 10.2, 8.7, 7.5, 9.2]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .monthly:
                // Simulated weekly angle variances for a month
                angleValues = [14.5, 12.2, 10.8, 9.5]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            }

            angleVarianceChart.updateData(
                data: angleValues,
                labels: labels,
                title: "Pendulum Angle Variance",
                color: .goldenPrimary
            )
            return
        }

        // Extract data for chart with safe unwrapping
        let angleValues = timeSeriesData.compactMap { entry -> Double? in
            return entry["angle"] as? Double ?? 0.0
        }

        let labels = timeSeriesData.compactMap { entry -> String? in
            guard let date = entry["timestamp"] as? Date else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: date)
        }

        // Update chart
        angleVarianceChart.updateData(
            data: angleValues,
            labels: labels,
            title: "Pendulum Angle Variance",
            color: .goldenPrimary
        )
    }
    
    private func loadPushFrequencyChart(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        // Get push frequency distribution from AnalyticsManager
        let distribution = AnalyticsManager.shared.getPushFrequencyDistribution()

        if distribution.isEmpty {
            // Provide sample data based on time range
            var values: [Double] = []
            var labels: [String] = []

            switch timeRange {
            case .session:
                values = [4, 8, 15, 12, 6, 2]
                labels = ["0.5s", "1.0s", "1.5s", "2.0s", "2.5s", "3.0s"]
            case .daily:
                values = [12, 25, 42, 38, 20, 8]
                labels = ["0.5s", "1.0s", "1.5s", "2.0s", "2.5s", "3.0s"]
            case .weekly:
                values = [35, 68, 92, 75, 48, 22]
                labels = ["0.5s", "1.0s", "1.5s", "2.0s", "2.5s", "3.0s"]
            case .monthly:
                values = [125, 215, 302, 278, 165, 95]
                labels = ["0.5s", "1.0s", "1.5s", "2.0s", "2.5s", "3.0s"]
            }

            pushFrequencyChart.updateData(
                data: values,
                labels: labels,
                title: "Push Frequency",
                color: .goldenAccent
            )
            return
        }

        // Sort by time interval
        let sortedDistribution = distribution.sorted { $0.key < $1.key }

        // Extract data for the chart
        let values = sortedDistribution.map { Double($0.value) }
        let labels = sortedDistribution.map { String(format: "%.1fs", $0.key) }

        // Update chart
        pushFrequencyChart.updateData(
            data: values,
            labels: labels,
            title: "Push Frequency",
            color: .goldenAccent
        )
    }
    
    private func loadPushMagnitudeChart(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        // Get push magnitude distribution from AnalyticsManager
        let distribution = AnalyticsManager.shared.getPushMagnitudeDistribution()

        if distribution.isEmpty {
            // Provide sample data based on time range
            var values: [Double] = []
            var labels: [String] = []

            switch timeRange {
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
            }

            pushMagnitudeChart.updateData(
                data: values,
                labels: labels,
                title: "Push Magnitude",
                color: .systemOrange
            )
            return
        }

        // Sort by magnitude
        let sortedDistribution = distribution.sorted { $0.key < $1.key }

        // Extract data for the chart
        let values = sortedDistribution.map { Double($0.value) }
        let labels = sortedDistribution.map { String(format: "%.1f", $0.key) }

        // Update chart
        pushMagnitudeChart.updateData(
            data: values,
            labels: labels,
            title: "Push Magnitude",
            color: .systemOrange
        )
    }
    
    private func loadReactionTimeChart(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        // For demo purposes, use sample data when appropriate
        // In a real implementation, this would fetch from analytics
        var reactionTimes: [Double] = []
        var labels: [String] = []
        
        // Only show data if we're looking at session data and have a session ID
        if timeRange == .session && sessionId != nil {
            // Use sample data for demonstration
            reactionTimes = [0.42, 0.53, 0.38, 0.65, 0.29, 0.47]
            labels = ["1", "2", "3", "4", "5", "6"]
        } else {
            // For a real implementation, this would fetch from AnalyticsManager
            // For now, use placeholder data for different time ranges
            switch timeRange {
            case .daily:
                reactionTimes = [0.45, 0.51, 0.40, 0.38]
                labels = ["Morning", "Noon", "Afternoon", "Evening"]
            case .weekly:
                reactionTimes = [0.55, 0.50, 0.45, 0.42, 0.41, 0.39, 0.38]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .monthly:
                reactionTimes = [0.60, 0.55, 0.50, 0.45]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            default:
                // Empty data for session without ID or other time ranges
                reactionTimes = []
                labels = []
            }
        }
        
        // Update chart with appropriate title
        reactionTimeChart.updateData(
            data: reactionTimes,
            labels: labels,
            title: reactionTimes.isEmpty ? "Reaction Time (No Data)" : "Reaction Time",
            color: .systemBlue
        )
    }
    
    private func loadLearningCurveChart(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        // Sample learning curve data - in a real implementation, this would come from analytics
        var scores: [Double] = []
        var labels: [String] = []
        
        // Always provide sample data based on the selected time range
        // This ensures we always have something to show
        switch timeRange {
        case .session:
            scores = [45.0, 53.0, 58.0, 72.0, 68.0, 85.0]
            labels = ["Start", "5min", "10min", "15min", "20min", "End"]
        case .daily:
            scores = [55.0, 62.0, 68.0, 72.0]
            labels = ["Morning", "Noon", "Afternoon", "Evening"]
        case .weekly:
            scores = [45.0, 53.0, 58.0, 65.0, 68.0, 72.0, 75.0]
            labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case .monthly:
            scores = [45.0, 53.0, 65.0, 78.0]
            labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
        }
        
        // Update chart
        learningCurveChart.updateData(
            data: scores,
            labels: labels,
            title: scores.isEmpty ? "Learning Curve (No Data)" : "Learning Curve",
            color: .systemGreen
        )
    }
    
    private func loadDirectionalBiasChart(timeRange: AnalyticsTimeRange, sessionId: UUID?) {
        // Get directional bias data
        let (leftCount, rightCount) = getDirectionalPushCounts(sessionId: sessionId)
        
        if leftCount == 0 && rightCount == 0 {
            // Handle empty data case - show empty segments with labels
            let segments = [
                (value: 1.0, label: "No Data", color: UIColor.lightGray)
            ]
            directionalBiasChart.updateSegments(segments)
            return
        }
        
        // Create segments for the pie chart
        let segments = [
            (value: Double(leftCount), label: "Left", color: UIColor.systemBlue),
            (value: Double(rightCount), label: "Right", color: UIColor.systemRed)
        ]
        
        // Update segments in the pie chart
        directionalBiasChart.updateSegments(segments)
    }
    
    // MARK: - Helper Methods
    
    private func getDirectionalPushCounts(sessionId: UUID?) -> (Int, Int) {
        // Try to get real data
        let directionalPushes = AnalyticsManager.shared.directionalPushes
        let leftCount = directionalPushes["left"] ?? 0
        let rightCount = directionalPushes["right"] ?? 0

        // If no real data, provide sample data
        if leftCount == 0 && rightCount == 0 {
            // Determine which time range we're in by checking the selected segment index
            let selectedSegment = timeSegmentControl.selectedSegmentIndex

            // Provide sample data based on the selected time range
            switch selectedSegment {
            case 0: // Session
                return (15, 12)
            case 1: // Daily
                return (42, 38)
            case 2: // Weekly
                return (165, 178)
            case 3: // Monthly
                return (485, 502)
            default:
                return (15, 12)
            }
        }

        return (leftCount, rightCount)
    }
    
    private func formatDirectionalBias(_ bias: Double) -> String {
        let percentage = abs(bias) * 100
        if abs(bias) < 0.1 {
            return "Balanced"
        } else if bias < 0 {
            return String(format: "%.0f%% Left", percentage)
        } else {
            return String(format: "%.0f%% Right", percentage)
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Actions

    // Note: The combined time range handler is now defined earlier in the file
    // This implementation has been merged with the other timeRangeChanged method
    
}