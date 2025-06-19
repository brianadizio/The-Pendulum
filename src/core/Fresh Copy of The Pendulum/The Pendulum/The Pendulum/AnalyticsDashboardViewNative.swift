// AnalyticsDashboardViewNative.swift
// Analytics dashboard using native charts (no dependency required)

import UIKit

// TimeRange enum definition (same as in original)
enum AnalyticsTimeRange {
    case session
    case daily
    case weekly
    case monthly
    case yearly
}

// Pendulum parameters enum
enum PendulumParameter: String, CaseIterable {
    case forceMultiplier = "Force Multiplier"
    case damping = "Damping"
    case gravity = "Gravity"
    case mass = "Mass"
    case length = "Length"
    
    var unit: String {
        switch self {
        case .forceMultiplier:
            return ""
        case .damping:
            return ""
        case .gravity:
            return "m/s²"
        case .mass:
            return "kg"
        case .length:
            return "m"
        }
    }
}

class AnalyticsDashboardViewNative: UIView, UIScrollViewDelegate {
    
    // Public method to capture session time when dashboard is shown
    func captureSessionTime() {
        // Capture the current session duration from SessionTimeManager
        initialSessionTime = SessionTimeManager.shared.getDashboardSessionDuration()
        // Removed debug print
    }
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Data labels
    private var stabilityScoreLabel: UILabel!
    private var efficiencyRatingLabel: UILabel!
    private var playerStyleLabel: UILabel!
    private var reactionTimeLabel: UILabel!
    private var directionalBiasLabel: UILabel!
    internal var sessionTimeLabel: UILabel!
    
    // Charts
    private var angleVarianceChart: SimpleLineChartView!
    private var pushFrequencyChart: SimpleBarChartView!
    private var pushMagnitudeChart: SimpleBarChartView!
    private var reactionTimeChart: SimpleLineChartView!
    private var learningCurveChart: SimpleLineChartView!
    private var directionalBiasChart: SimplePieChartView!
    private var pendulumParametersChart: SimpleLineChartView!
    private var averagePhaseSpaceChart: PhaseSpaceChartView!
    
    // Parameter selection for pendulum parameters chart
    private var parameterSegmentControl: UISegmentedControl!
    private var selectedParameter: PendulumParameter = .forceMultiplier
    
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
        updatePendulumParametersChart(timeRange: "Session", parameter: selectedParameter)
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
        
        // Add header title with logo
        let headerTitle = HeaderViewCreator.createHeaderView(title: "Pendulum Analytics")
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerTitle)
        
        // Configure header title constraints to match other tabs
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
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
        timeSegmentControl = UISegmentedControl(items: ["Session", "Daily", "Weekly", "Monthly", "Yearly"])
        timeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        timeSegmentControl.selectedSegmentIndex = 0

        // Use Golden theme colors
        timeSegmentControl.selectedSegmentTintColor = .goldenPrimary
        timeSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        timeSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.goldenDark], for: .normal)

        contentView.addSubview(timeSegmentControl)

        // Get the header title - it's the UIView created by HeaderViewCreator
        let headerTitle = contentView.subviews.first(where: { 
            // The header is a UIView containing a UILabel
            $0.subviews.contains(where: { $0 is UILabel }) 
        })

        NSLayoutConstraint.activate([
            timeSegmentControl.topAnchor.constraint(equalTo: headerTitle?.bottomAnchor ?? contentView.topAnchor, constant: 15),
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
        summaryContainer.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        contentView.addSubview(summaryContainer)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            summaryContainer.topAnchor.constraint(equalTo: timeSegmentControl.bottomAnchor, constant: 20),
            summaryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        // Create the summary cards with descriptions
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
            let card = createEnhancedSummaryCard(
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
        chartsContainer.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
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
        
        // Add section title with logo
        let sectionTitle = HeaderViewCreator.createSectionHeader(title: "Performance Charts")
        chartsContainer.addSubview(sectionTitle)
        
        // Add Charts
        
        // 1. Angle Variance Chart
        let angleVarianceSection = createEnhancedChartSection(
            title: "Pendulum Angle Variance",
            description: "Shows pendulum deviation from vertical over time - lower values mean better stability.",
            chartKey: "AngleVariance"
        )
        chartsContainer.addSubview(angleVarianceSection)
        
        angleVarianceChart = SimpleLineChartView()
        angleVarianceChart.translatesAutoresizingMaskIntoConstraints = false
        angleVarianceChart.color = .goldenPrimary
        angleVarianceSection.addSubview(angleVarianceChart)
        
        // 2. Push Frequency Chart
        let pushFrequencySection = createEnhancedChartSection(
            title: "Push Frequency Distribution",
            description: "How often you apply corrections - optimal frequency balances responsiveness with efficiency.",
            chartKey: "PushFrequency"
        )
        chartsContainer.addSubview(pushFrequencySection)
        
        pushFrequencyChart = SimpleBarChartView()
        pushFrequencyChart.translatesAutoresizingMaskIntoConstraints = false
        pushFrequencyChart.color = .goldenAccent
        pushFrequencySection.addSubview(pushFrequencyChart)
        
        // 3. Push Magnitude Chart 
        let pushMagnitudeSection = createEnhancedChartSection(
            title: "Push Magnitude Distribution",
            description: "Strength of your corrections - smaller forces indicate more precise control.",
            chartKey: "PushMagnitude"
        )
        chartsContainer.addSubview(pushMagnitudeSection)
        
        pushMagnitudeChart = SimpleBarChartView()
        pushMagnitudeChart.translatesAutoresizingMaskIntoConstraints = false
        pushMagnitudeChart.color = .systemOrange
        pushMagnitudeSection.addSubview(pushMagnitudeChart)
        
        // 4. Reaction Time Chart
        let reactionTimeSection = createEnhancedChartSection(
            title: "Reaction Time Analysis",
            description: "Speed of response to instability - faster reactions typically yield better control.",
            chartKey: "ReactionTime"
        )
        chartsContainer.addSubview(reactionTimeSection)
        
        reactionTimeChart = SimpleLineChartView()
        reactionTimeChart.translatesAutoresizingMaskIntoConstraints = false
        reactionTimeChart.color = .systemBlue
        reactionTimeSection.addSubview(reactionTimeChart)
        
        // 5. Learning Curve Chart
        let learningCurveSection = createEnhancedChartSection(
            title: "Learning Curve",
            description: "Your improvement trend over time based on stability scores.",
            chartKey: "LearningCurve"
        )
        chartsContainer.addSubview(learningCurveSection)
        
        learningCurveChart = SimpleLineChartView()
        learningCurveChart.translatesAutoresizingMaskIntoConstraints = false
        learningCurveChart.color = .systemGreen
        learningCurveSection.addSubview(learningCurveChart)
        
        // 6. Directional Bias Chart
        let directionalBiasSection = createEnhancedChartSection(
            title: "Directional Bias",
            description: "Balance between left and right corrections - centered distribution shows unbiased control.",
            chartKey: "DirectionalBias"
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
            
            angleVarianceChart.topAnchor.constraint(equalTo: angleVarianceSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            angleVarianceChart.leadingAnchor.constraint(equalTo: angleVarianceSection.leadingAnchor, constant: 10),
            angleVarianceChart.trailingAnchor.constraint(equalTo: angleVarianceSection.trailingAnchor, constant: -10),
            angleVarianceChart.bottomAnchor.constraint(equalTo: angleVarianceSection.bottomAnchor, constant: -10),
            
            // Push frequency chart
            pushFrequencySection.topAnchor.constraint(equalTo: angleVarianceSection.bottomAnchor, constant: 20),
            pushFrequencySection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            pushFrequencySection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            pushFrequencySection.heightAnchor.constraint(equalToConstant: 300),
            
            pushFrequencyChart.topAnchor.constraint(equalTo: pushFrequencySection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            pushFrequencyChart.leadingAnchor.constraint(equalTo: pushFrequencySection.leadingAnchor, constant: 10),
            pushFrequencyChart.trailingAnchor.constraint(equalTo: pushFrequencySection.trailingAnchor, constant: -10),
            pushFrequencyChart.bottomAnchor.constraint(equalTo: pushFrequencySection.bottomAnchor, constant: -10),
            
            // Push magnitude chart
            pushMagnitudeSection.topAnchor.constraint(equalTo: pushFrequencySection.bottomAnchor, constant: 20),
            pushMagnitudeSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            pushMagnitudeSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            pushMagnitudeSection.heightAnchor.constraint(equalToConstant: 300),
            
            pushMagnitudeChart.topAnchor.constraint(equalTo: pushMagnitudeSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            pushMagnitudeChart.leadingAnchor.constraint(equalTo: pushMagnitudeSection.leadingAnchor, constant: 10),
            pushMagnitudeChart.trailingAnchor.constraint(equalTo: pushMagnitudeSection.trailingAnchor, constant: -10),
            pushMagnitudeChart.bottomAnchor.constraint(equalTo: pushMagnitudeSection.bottomAnchor, constant: -10),
            
            // Reaction time chart
            reactionTimeSection.topAnchor.constraint(equalTo: pushMagnitudeSection.bottomAnchor, constant: 20),
            reactionTimeSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            reactionTimeSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            reactionTimeSection.heightAnchor.constraint(equalToConstant: 300),
            
            reactionTimeChart.topAnchor.constraint(equalTo: reactionTimeSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            reactionTimeChart.leadingAnchor.constraint(equalTo: reactionTimeSection.leadingAnchor, constant: 10),
            reactionTimeChart.trailingAnchor.constraint(equalTo: reactionTimeSection.trailingAnchor, constant: -10),
            reactionTimeChart.bottomAnchor.constraint(equalTo: reactionTimeSection.bottomAnchor, constant: -10),
            
            // Learning curve chart
            learningCurveSection.topAnchor.constraint(equalTo: reactionTimeSection.bottomAnchor, constant: 20),
            learningCurveSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            learningCurveSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            learningCurveSection.heightAnchor.constraint(equalToConstant: 300),
            
            learningCurveChart.topAnchor.constraint(equalTo: learningCurveSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            learningCurveChart.leadingAnchor.constraint(equalTo: learningCurveSection.leadingAnchor, constant: 10),
            learningCurveChart.trailingAnchor.constraint(equalTo: learningCurveSection.trailingAnchor, constant: -10),
            learningCurveChart.bottomAnchor.constraint(equalTo: learningCurveSection.bottomAnchor, constant: -10),
            
            // Directional bias chart
            directionalBiasSection.topAnchor.constraint(equalTo: learningCurveSection.bottomAnchor, constant: 30), // Increased from 20 to 30
            directionalBiasSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            directionalBiasSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            directionalBiasSection.heightAnchor.constraint(equalToConstant: 320), // Increased from 300 to 320
            // Removed the bottom constraint to chartsContainer.bottomAnchor to prevent overlap
            
            directionalBiasChart.topAnchor.constraint(equalTo: directionalBiasSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
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
        
        // Add Phase Space Chart
        let phaseSpaceSection = createEnhancedChartSection(
            title: "Average Phase Space by Level",
            description: "Pendulum's angle vs velocity patterns - tighter loops indicate better control.",
            chartKey: "PhaseSpace"
        )
        chartsContainer.addSubview(phaseSpaceSection)
        
        let phaseSpaceChart = PhaseSpaceChartView()
        phaseSpaceChart.translatesAutoresizingMaskIntoConstraints = false
        phaseSpaceSection.addSubview(phaseSpaceChart)
        
        // Layout constraints for phase space chart
        NSLayoutConstraint.activate([
            phaseSpaceSection.topAnchor.constraint(equalTo: lastSection.bottomAnchor, constant: 30),
            phaseSpaceSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            phaseSpaceSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            phaseSpaceSection.heightAnchor.constraint(equalToConstant: 400), // Taller for phase space
            
            phaseSpaceChart.topAnchor.constraint(equalTo: phaseSpaceSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            phaseSpaceChart.leadingAnchor.constraint(equalTo: phaseSpaceSection.leadingAnchor, constant: 10),
            phaseSpaceChart.trailingAnchor.constraint(equalTo: phaseSpaceSection.trailingAnchor, constant: -10),
            phaseSpaceChart.bottomAnchor.constraint(equalTo: phaseSpaceSection.bottomAnchor, constant: -10)
        ])
        
        // Store reference for data updates
        self.averagePhaseSpaceChart = phaseSpaceChart

        // Create section for additional metrics
        let additionalMetricsTitle = createSectionLabel("Additional Statistics")
        additionalMetricsTitle.translatesAutoresizingMaskIntoConstraints = false
        chartsContainer.addSubview(additionalMetricsTitle)

        // Create a container for additional metrics cards
        let additionalMetricsContainer = UIView()
        additionalMetricsContainer.translatesAutoresizingMaskIntoConstraints = false
        additionalMetricsContainer.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        chartsContainer.addSubview(additionalMetricsContainer)

        // Create cards for the additional metrics
        let metricsData = [
            ["title": "Total Levels\nBalanced", "icon": "checkmark.circle.fill", "color": UIColor.systemGreen],
            ["title": "Average Time\nPer Level", "icon": "timer", "color": UIColor.systemBlue],
            ["title": "Longest Balance\nStreak", "icon": "flame.fill", "color": UIColor.systemOrange],
            ["title": "Play Sessions\n(Last Week)", "icon": "calendar", "color": UIColor.systemIndigo]
        ]

        var metricCards: [UIView] = []

        for (index, data) in metricsData.enumerated() {
            let card = createEnhancedSummaryCard(
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
        let levelCompletionsSection = createEnhancedChartSection(
            title: "Level Completions Over Time",
            description: "Number of levels successfully completed in each time period.",
            chartKey: "LevelCompletions"
        )
        chartsContainer.addSubview(levelCompletionsSection)

        let levelCompletionsChart = SimpleBarChartView()
        levelCompletionsChart.translatesAutoresizingMaskIntoConstraints = false
        levelCompletionsChart.color = .goldenPrimary
        levelCompletionsSection.addSubview(levelCompletionsChart)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            additionalMetricsTitle.topAnchor.constraint(equalTo: phaseSpaceSection.bottomAnchor, constant: 50),
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
            levelCompletionsSection.bottomAnchor.constraint(equalTo: chartsContainer.bottomAnchor, constant: -400),

            levelCompletionsChart.topAnchor.constraint(equalTo: levelCompletionsSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            levelCompletionsChart.leadingAnchor.constraint(equalTo: levelCompletionsSection.leadingAnchor, constant: 10),
            levelCompletionsChart.trailingAnchor.constraint(equalTo: levelCompletionsSection.trailingAnchor, constant: -10),
            levelCompletionsChart.bottomAnchor.constraint(equalTo: levelCompletionsSection.bottomAnchor, constant: -10),
        ])

        // Create pendulum parameters chart section
        let pendulumParametersSection = createEnhancedChartSection(
            title: "Pendulum Parameters Over Time",
            description: "How game physics parameters change across levels to increase difficulty.",
            chartKey: "PendulumParameters"
        )
        chartsContainer.addSubview(pendulumParametersSection)
        
        // Add parameter selector
        parameterSegmentControl = UISegmentedControl(items: PendulumParameter.allCases.map { $0.rawValue })
        parameterSegmentControl.selectedSegmentIndex = 0
        parameterSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        parameterSegmentControl.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        parameterSegmentControl.selectedSegmentTintColor = .goldenPrimary
        parameterSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        parameterSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        parameterSegmentControl.addTarget(self, action: #selector(parameterChanged(_:)), for: .valueChanged)
        pendulumParametersSection.addSubview(parameterSegmentControl)
        
        pendulumParametersChart = SimpleLineChartView()
        pendulumParametersChart.translatesAutoresizingMaskIntoConstraints = false
        pendulumParametersChart.color = .systemPurple
        pendulumParametersSection.addSubview(pendulumParametersChart)
        
        // Layout constraints for pendulum parameters section
        NSLayoutConstraint.activate([
            pendulumParametersSection.topAnchor.constraint(equalTo: levelCompletionsSection.bottomAnchor, constant: 20),
            pendulumParametersSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            pendulumParametersSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            pendulumParametersSection.heightAnchor.constraint(equalToConstant: 350),
            pendulumParametersSection.bottomAnchor.constraint(equalTo: chartsContainer.bottomAnchor, constant: -20),
            
            parameterSegmentControl.topAnchor.constraint(equalTo: pendulumParametersSection.topAnchor, constant: 110), // Increased from 80 to 110 for description space
            parameterSegmentControl.leadingAnchor.constraint(equalTo: pendulumParametersSection.leadingAnchor, constant: 10),
            parameterSegmentControl.trailingAnchor.constraint(equalTo: pendulumParametersSection.trailingAnchor, constant: -10),
            parameterSegmentControl.heightAnchor.constraint(equalToConstant: 30),
            
            pendulumParametersChart.topAnchor.constraint(equalTo: parameterSegmentControl.bottomAnchor, constant: 30),
            pendulumParametersChart.leadingAnchor.constraint(equalTo: pendulumParametersSection.leadingAnchor, constant: 10),
            pendulumParametersChart.trailingAnchor.constraint(equalTo: pendulumParametersSection.trailingAnchor, constant: -10),
            pendulumParametersChart.bottomAnchor.constraint(equalTo: pendulumParametersSection.bottomAnchor, constant: -10)
        ])
        
        // Initialize with sample data - now using the main time range selector
        updateAdditionalMetrics(timeRange: "Session")
        updateLevelCompletionsChart(timeRange: "Session")
        updatePendulumParametersChart(timeRange: "Session", parameter: selectedParameter)
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
        case 4:
            range = .yearly
            stringRange = "Year"
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
        updatePendulumParametersChart(timeRange: stringRange, parameter: selectedParameter)
        updateAveragePhaseSpaceChart()
    }

    private func updateAdditionalMetrics(timeRange: String) {
        // In a real implementation, these would fetch from Core Data based on time range
        // For now, we'll use sample data

        // Find the metric cards
        let metricContainers = contentView.subviews.compactMap { $0.subviews }
            .flatMap { $0 }
            .filter { $0.backgroundColor == FocusCalendarTheme.secondaryBackgroundColor }

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
                case "Total Levels\nBalanced":
                    valueLabel?.text = "\(totalLevels)"
                case "Average Time\nPer Level":
                    valueLabel?.text = String(format: "%.1fs", avgTimePerLevel)
                case "Longest Balance\nStreak":
                    valueLabel?.text = "\(longestStreak) levels"
                case "Play Sessions\n(Last Week)":
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

        // Update chart - X-axis shows time periods, Y-axis shows number of levels completed
        chart.updateData(
            data: levels,
            labels: labels,
            title: "Level Completions Over Time (\(timeRange))",
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
        card.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = (UIColor.goldenText as UIColor)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        card.addSubview(titleLabel)
        
        // Icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iconImage = UIImage(systemName: iconName, withConfiguration: iconConfig)
        let iconView = UIImageView(image: iconImage)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
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
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconView.leadingAnchor, constant: -4),
            
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
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
        container.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
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
        
        // Description label with better visibility
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium) // Larger font for better visibility
        descriptionLabel.textColor = UIColor.label // Use system label color for better contrast
        descriptionLabel.numberOfLines = 0 // Allow unlimited lines
        descriptionLabel.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        descriptionLabel.layer.cornerRadius = 6
        descriptionLabel.layer.masksToBounds = true
        
        // Add padding to the label
        descriptionLabel.textAlignment = .left
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        // Debug: Print when descriptions are created
        // Removed debug print
        
        container.addSubview(descriptionLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12), // More space between title and description
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20), // More padding
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20), // More padding
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50) // Larger minimum height for visibility
        ])
        
        return container
    }
    
    // MARK: - Data Updates
    
    // The selected time range - use this to track the current state
    internal var selectedTimeRange: AnalyticsTimeRange = .session
    
    // Store the initial session time to prevent updates
    private var initialSessionTime: TimeInterval?

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
            case .yearly:
                if timeSegmentControl.selectedSegmentIndex != 4 {
                    timeSegmentControl.selectedSegmentIndex = 4
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
            case 4:
                selectedTimeRange = .yearly
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
        case .yearly:
            stringTimeRange = "Year"
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
        
        // Store current session time text if we're in session view
        let previousSessionTimeText = (timeRange == .session) ? sessionTimeLabel?.text : nil

        // Try to get metrics from AnalyticsManager, handle empty case gracefully
        do {
            switch timeRange {
            case .session:
                if let sessionId = sessionId {
                    metrics = AnalyticsManager.shared.getPerformanceMetricsWithStaticTime(for: sessionId)
                } else {
                    metrics = AnalyticsManager.shared.getPerformanceMetricsWithStaticTime()
                }
            case .daily, .weekly, .monthly, .yearly:
                let period = timeRange == .daily ? "daily" : timeRange == .weekly ? "weekly" : timeRange == .monthly ? "monthly" : "yearly"
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
                // Use static session duration for sample data
                let staticDuration = SessionTimeManager.shared.getDashboardSessionDuration()
                metrics = [
                    "stabilityScore": 78.5,
                    "efficiencyRating": 82.1,
                    "playerStyle": "Balanced",
                    "averageCorrectionTime": 0.45,
                    "directionalBias": 0.12,
                    "totalPlayTime": staticDuration > 0 ? staticDuration : 180.0
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
            case .yearly:
                metrics = [
                    "stabilityScore": 88.4,
                    "efficiencyRating": 91.2,
                    "playerStyle": "Master",
                    "averageCorrectionTime": 0.28,
                    "directionalBias": 0.01,
                    "totalPlayTime": 86400.0
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

        // For session time range, preserve the previous value to prevent constant updates
        if timeRange == .session && previousSessionTimeText != nil && previousSessionTimeText != "N/A" {
            sessionTimeLabel.text = previousSessionTimeText
        } else {
            sessionTimeLabel.text = (metrics["totalPlayTime"] as? Double).map {
                formatTimeInterval($0)
            } ?? "N/A"
        }
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
        case .yearly:
            timeSeriesData = AnalyticsManager.shared.getInteractionTimeSeries(timeframe: -31536000) // Last 365 days
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
            case .yearly:
                // Simulated monthly angle variances for a year
                angleValues = [13.5, 12.8, 11.5, 10.2, 9.0, 8.2, 7.5, 7.0, 6.8, 6.5, 6.2, 6.0]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
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
            
            // Use appropriate date format based on time range
            switch timeRange {
            case .session:
                formatter.dateFormat = "HH:mm"  // Show time for session view
            case .daily:
                formatter.dateFormat = "h a"    // Show hours (e.g., "3 PM")
            case .weekly:
                formatter.dateFormat = "EEE"    // Show day names (e.g., "Mon")
            case .monthly:
                formatter.dateFormat = "MMM d"  // Show month and day (e.g., "Jan 15")
            case .yearly:
                formatter.dateFormat = "MMM"    // Show month names (e.g., "Jan")
            }
            
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
            case .yearly:
                values = [520, 890, 1250, 1150, 680, 390]
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
            case .yearly:
                values = [1580, 2150, 1740, 1160, 620, 270]
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
        // Try to get real reaction time data first
        let realReactionTimes = AnalyticsManager.shared.reactionTimes
        var reactionTimes: [Double] = []
        var labels: [String] = []
        
        // Use real data if available, otherwise use sample data
        if !realReactionTimes.isEmpty {
            reactionTimes = Array(realReactionTimes.prefix(20)) // Limit to recent 20 data points
            labels = reactionTimes.enumerated().map { "Push \($0.offset + 1)" }
            // Removed debug print
        } else {
            // Provide sample data for all time ranges to demonstrate functionality
            // Removed debug print
            switch timeRange {
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
        case .yearly:
            scores = [45.0, 48.0, 52.0, 58.0, 62.0, 68.0, 72.0, 75.0, 78.0, 82.0, 85.0, 88.0]
            labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
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
        
        // Removed debug print

        // If we have real data, use it
        if leftCount > 0 || rightCount > 0 {
            return (leftCount, rightCount)
        }
        
        // If no real data, provide sample data based on current time range
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
    
    internal func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Actions

    // Note: The combined time range handler is now defined earlier in the file
    // This implementation has been merged with the other timeRangeChanged method
    
    @objc private func parameterChanged(_ sender: UISegmentedControl) {
        selectedParameter = PendulumParameter.allCases[sender.selectedSegmentIndex]
        
        // Convert current time range to string
        let stringRange: String
        switch selectedTimeRange {
        case .session:
            stringRange = "Session"
        case .daily:
            stringRange = "Daily"
        case .weekly:
            stringRange = "Week"
        case .monthly:
            stringRange = "Month"
        case .yearly:
            stringRange = "Year"
        }
        
        updatePendulumParametersChart(timeRange: stringRange, parameter: selectedParameter)
    }
    
    private func updatePendulumParametersChart(timeRange: String, parameter: PendulumParameter) {
        // Sample data based on time range and parameter
        var values: [Double] = []
        var labels: [String] = []
        
        switch timeRange {
        case "Session":
            // Show parameter values for each level in the session
            switch parameter {
            case .forceMultiplier:
                values = [1.0, 1.2, 1.4, 1.6]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case .damping:
                values = [0.5, 0.45, 0.4, 0.35]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case .gravity:
                values = [9.81, 9.81, 9.81, 9.81]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case .mass:
                values = [5.0, 5.2, 5.4, 5.6]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            case .length:
                values = [3.0, 3.1, 3.2, 3.3]
                labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
            }
        case "Daily":
            // Show average parameter values per hour
            switch parameter {
            case .forceMultiplier:
                values = [1.0, 1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case .damping:
                values = [0.5, 0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case .gravity:
                values = [9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case .mass:
                values = [5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            case .length:
                values = [3.0, 3.05, 3.1, 3.15, 3.2, 3.25, 3.3, 3.35]
                labels = ["9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM"]
            }
        case "Week":
            // Show average parameter values per day
            switch parameter {
            case .forceMultiplier:
                values = [1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .damping:
                values = [0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .gravity:
                values = [9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .mass:
                values = [5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .length:
                values = [3.05, 3.1, 3.15, 3.2, 3.25, 3.3, 3.35]
                labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            }
        case "Month":
            // Show average parameter values per week
            switch parameter {
            case .forceMultiplier:
                values = [1.2, 1.5, 1.8, 2.1]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .damping:
                values = [0.45, 0.40, 0.35, 0.30]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .gravity:
                values = [9.81, 9.81, 9.81, 9.81]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .mass:
                values = [5.2, 5.4, 5.6, 5.8]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .length:
                values = [3.1, 3.2, 3.3, 3.4]
                labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            }
        case "Year":
            // Show average parameter values per month
            switch parameter {
            case .forceMultiplier:
                values = [1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3, 2.5, 2.7, 2.9, 3.1, 3.3]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case .damping:
                values = [0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33, 0.31, 0.29, 0.27, 0.25, 0.23]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case .gravity:
                values = [9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81, 9.81]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case .mass:
                values = [5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6.0, 6.1]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            case .length:
                values = [3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.1]
                labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            }
        default:
            // Default to session data
            values = [1.0, 1.2, 1.4, 1.6]
            labels = ["Level 1", "Level 2", "Level 3", "Level 4"]
        }
        
        // Update the chart with a title that includes the unit
        let title = "\(parameter.rawValue)\(parameter.unit.isEmpty ? "" : " (\(parameter.unit))")"
        pendulumParametersChart.updateDataWithUnit(
            data: values,
            labels: labels,
            title: title,
            color: .systemPurple,
            unit: parameter.unit
        )
        
        // Debug logging for parameter chart updates
        // Removed debug print
    }
    
    private func updateAveragePhaseSpaceChart() {
        guard let phaseSpaceChart = averagePhaseSpaceChart else { return }
        
        // Get average phase space data from the analytics manager
        let phaseSpaceData = AnalyticsManager.shared.getAveragePhaseSpaceData()
        
        // Update the chart with the data
        phaseSpaceChart.updateLevelData(phaseSpaceData)
    }
    
    // MARK: - Enhanced UI Components with Descriptions
    
    private func createEnhancedSummaryCard(title: String, iconName: String, color: UIColor) -> UIView {
        let card = createSummaryCard(title: title, iconName: iconName, color: color)
        
        // Add info button if description exists
        if let descriptionData = DashboardDescriptions.summaryMetrics[title] ?? 
           DashboardDescriptions.additionalMetrics[title] {
            let infoButton = DashboardInfoButton(
                title: descriptionData.title,
                description: descriptionData.description
            )
            card.addSubview(infoButton)
            
            // Position info button in top-right corner, away from the existing icon
            NSLayoutConstraint.activate([
                infoButton.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
                infoButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8)
            ])
        }
        
        return card
    }
    
    private func createEnhancedChartSection(title: String, description: String, chartKey: String) -> UIView {
        let container = createChartSection(title: title, description: description)
        
        // Add info button for additional details if needed
        if let descriptionData = DashboardDescriptions.chartDescriptions[chartKey] {
            // The description is already shown in the chart section, so we're using the provided description
            // No need for additional info button since description is visible
        }
        
        return container
    }
    
}