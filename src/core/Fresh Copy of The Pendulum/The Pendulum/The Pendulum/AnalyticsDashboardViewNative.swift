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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
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
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 2000)
        heightConstraint.priority = .defaultLow // Allow it to grow based on content
        heightConstraint.isActive = true
    }
    
    private func setupTimeRangeControl() {
        timeSegmentControl = UISegmentedControl(items: ["Session", "Daily", "Weekly", "Monthly"])
        timeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        timeSegmentControl.selectedSegmentIndex = 0
        timeSegmentControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
        
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
            chartsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
            directionalBiasSection.topAnchor.constraint(equalTo: learningCurveSection.bottomAnchor, constant: 20),
            directionalBiasSection.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            directionalBiasSection.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            directionalBiasSection.heightAnchor.constraint(equalToConstant: 300),
            directionalBiasSection.bottomAnchor.constraint(equalTo: chartsContainer.bottomAnchor),
            
            directionalBiasChart.topAnchor.constraint(equalTo: directionalBiasSection.topAnchor, constant: 60),
            directionalBiasChart.leadingAnchor.constraint(equalTo: directionalBiasSection.leadingAnchor, constant: 10),
            directionalBiasChart.trailingAnchor.constraint(equalTo: directionalBiasSection.trailingAnchor, constant: -10),
            directionalBiasChart.bottomAnchor.constraint(equalTo: directionalBiasSection.bottomAnchor, constant: -10)
        ])
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
    
    func updateDashboard(timeRange: AnalyticsTimeRange = .session, sessionId: UUID? = nil) {
        // Update the segment control
        switch timeRange {
        case .session:
            timeSegmentControl.selectedSegmentIndex = 0
        case .daily:
            timeSegmentControl.selectedSegmentIndex = 1
        case .weekly:
            timeSegmentControl.selectedSegmentIndex = 2
        case .monthly:
            timeSegmentControl.selectedSegmentIndex = 3
        }
        
        // Load summary metrics
        loadSummaryMetrics(timeRange: timeRange, sessionId: sessionId)
        
        // Load chart data
        loadAngleVarianceChart(timeRange: timeRange, sessionId: sessionId)
        loadPushFrequencyChart(timeRange: timeRange, sessionId: sessionId)
        loadPushMagnitudeChart(timeRange: timeRange, sessionId: sessionId)
        loadReactionTimeChart(timeRange: timeRange, sessionId: sessionId)
        loadLearningCurveChart(timeRange: timeRange, sessionId: sessionId)
        loadDirectionalBiasChart(timeRange: timeRange, sessionId: sessionId)
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
        
        // If no data, display placeholder
        if timeSeriesData.isEmpty {
            // For empty data, provide placeholder or sample data
            let emptyData: [Double] = []
            let emptyLabels: [String] = []
            
            angleVarianceChart.updateData(
                data: emptyData,
                labels: emptyLabels,
                title: "Pendulum Angle Variance (No Data)",
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
            // Handle empty data case
            pushFrequencyChart.updateData(
                data: [],
                labels: [],
                title: "Push Frequency (No Data)",
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
            // Handle empty data case
            pushMagnitudeChart.updateData(
                data: [],
                labels: [],
                title: "Push Magnitude (No Data)",
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
        
        // If no real data but have a session ID, could provide sample data for demonstration
        if leftCount == 0 && rightCount == 0 && sessionId != nil {
            // In a real implementation, we would fetch from Core Data
            // For demo purposes, could return sample data
            // return (15, 12) // Sample data for demo
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
    
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        // Convert segment index to time range
        let range: AnalyticsTimeRange
        switch sender.selectedSegmentIndex {
        case 0:
            range = .session
        case 1:
            range = .daily
        case 2:
            range = .weekly
        case 3:
            range = .monthly
        default:
            range = .session
        }
        
        // Update dashboard with the selected time range
        updateDashboard(timeRange: range)
    }
}