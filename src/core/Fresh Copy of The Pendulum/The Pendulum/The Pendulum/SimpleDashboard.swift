import UIKit

class SimpleDashboard: UITableViewController {
    
    // MARK: - Properties
    
    private var metrics: [MetricValue] = []
    private var updateTimer: Timer?
    private var currentMetricGroup: MetricGroupType = .basic
    private var currentTimeRange: AnalyticsTimeRange = .daily
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startMetricUpdates()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Configure table view - simple and clean
        tableView.backgroundColor = .goldenBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // Register cell types
        tableView.register(HeaderCell.self, forCellReuseIdentifier: "Header")
        tableView.register(ControlsCell.self, forCellReuseIdentifier: "Controls")
        tableView.register(MetricCell.self, forCellReuseIdentifier: "MetricCell")
        tableView.register(ChartCell.self, forCellReuseIdentifier: "ChartCell")
    }
    
    private func startMetricUpdates() {
        loadMetrics()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.loadMetrics()
        }
    }
    
    private func loadMetrics() {
        let newMetrics = AnalyticsManager.shared.calculateMetrics(for: currentMetricGroup)
        
        // Only reload if metrics count changed to avoid unnecessary reloads
        if newMetrics.count != metrics.count {
            metrics = newMetrics
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            // Update values in place for better performance
            metrics = newMetrics
            updateVisibleCells()
        }
    }
    
    private func updateVisibleCells() {
        for cell in tableView.visibleCells {
            if let metricCell = cell as? MetricCell,
               let indexPath = tableView.indexPath(for: cell),
               indexPath.section == 2 && indexPath.row < metrics.count {
                metricCell.updateValue(metrics[indexPath.row])
            } else if let chartCell = cell as? ChartCell,
                      let indexPath = tableView.indexPath(for: cell),
                      indexPath.section == 2 && indexPath.row < metrics.count {
                chartCell.updateChart(metrics[indexPath.row])
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Header, Controls, Metrics
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Header
        case 1: return 1 // Controls
        case 2: return metrics.count // Metrics
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath) as! HeaderCell
            cell.configure(title: "Analytics Dashboard")
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Controls", for: indexPath) as! ControlsCell
            cell.configure(
                currentGroup: currentMetricGroup,
                currentTimeRange: currentTimeRange,
                onGroupChanged: { [weak self] group in
                    self?.currentMetricGroup = group
                    self?.loadMetrics()
                    // Force table reload to update all visible charts
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                },
                onTimeRangeChanged: { [weak self] range in
                    self?.currentTimeRange = range
                    self?.loadMetrics()
                    // Force table reload to update all visible charts
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            )
            return cell
            
        case 2:
            let metric = metrics[indexPath.row]
            
            if metric.type.isDistribution || metric.type.isTimeSeries {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath) as! ChartCell
                cell.configure(with: metric)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCell", for: indexPath) as! MetricCell
                cell.configure(with: metric)
                return cell
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 60  // Header
        case 1: return 100 // Controls
        case 2:
            let metric = metrics[indexPath.row]
            return (metric.type.isDistribution || metric.type.isTimeSeries) ? 250 : 80
        default: return 44
        }
    }
}

// MARK: - Header Cell

class HeaderCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 28)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Controls Cell

class ControlsCell: UITableViewCell {
    
    private let groupControl = UISegmentedControl()
    private let timeControl = UISegmentedControl()
    private var onGroupChanged: ((MetricGroupType) -> Void)?
    private var onTimeRangeChanged: ((AnalyticsTimeRange) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Group control
        let groupItems = MetricGroupType.allCases.map { $0.displayName }
        groupControl.removeAllSegments()
        for (index, item) in groupItems.enumerated() {
            groupControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        groupControl.selectedSegmentIndex = 0
        groupControl.translatesAutoresizingMaskIntoConstraints = false
        groupControl.addTarget(self, action: #selector(groupChanged), for: .valueChanged)
        contentView.addSubview(groupControl)
        
        // Time range control  
        let timeItems = ["Session", "Daily", "Weekly", "Monthly", "Yearly"]
        timeControl.removeAllSegments()
        for (index, item) in timeItems.enumerated() {
            timeControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        timeControl.selectedSegmentIndex = 1 // Daily
        timeControl.translatesAutoresizingMaskIntoConstraints = false
        timeControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
        contentView.addSubview(timeControl)
        
        NSLayoutConstraint.activate([
            groupControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            groupControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            groupControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupControl.heightAnchor.constraint(equalToConstant: 36),
            
            timeControl.topAnchor.constraint(equalTo: groupControl.bottomAnchor, constant: 8),
            timeControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timeControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configure(
        currentGroup: MetricGroupType,
        currentTimeRange: AnalyticsTimeRange,
        onGroupChanged: @escaping (MetricGroupType) -> Void,
        onTimeRangeChanged: @escaping (AnalyticsTimeRange) -> Void
    ) {
        if let groupIndex = MetricGroupType.allCases.firstIndex(of: currentGroup) {
            groupControl.selectedSegmentIndex = groupIndex
        }
        
        let timeRanges: [AnalyticsTimeRange] = [.session, .daily, .weekly, .monthly, .yearly]
        if let timeIndex = timeRanges.firstIndex(of: currentTimeRange) {
            timeControl.selectedSegmentIndex = timeIndex
        }
        
        self.onGroupChanged = onGroupChanged
        self.onTimeRangeChanged = onTimeRangeChanged
    }
    
    @objc private func groupChanged() {
        let group = MetricGroupType.allCases[groupControl.selectedSegmentIndex]
        onGroupChanged?(group)
    }
    
    @objc private func timeRangeChanged() {
        let timeRanges: [AnalyticsTimeRange] = [.session, .daily, .weekly, .monthly, .yearly]
        let range = timeRanges[timeControl.selectedSegmentIndex]
        onTimeRangeChanged?(range)
    }
}

// MARK: - Metric Cell

class MetricCell: UITableViewCell {
    
    private let cardView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Card container
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        contentView.addSubview(cardView)
        
        // Icon
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        cardView.addSubview(iconLabel)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        cardView.addSubview(titleLabel)
        
        // Value
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .goldenPrimary
        valueLabel.textAlignment = .right
        cardView.addSubview(valueLabel)
        
        // Unit
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.font = .systemFont(ofSize: 12)
        unitLabel.textColor = .secondaryLabel
        unitLabel.textAlignment = .right
        cardView.addSubview(unitLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            iconLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),
            
            valueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -6),
            
            unitLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            unitLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2)
        ])
    }
    
    func configure(with metric: MetricValue) {
        titleLabel.text = metric.type.rawValue
        valueLabel.text = metric.formattedValue
        
        // Debug logging
        print("DEBUG: MetricCell - \(metric.type.rawValue): value='\(metric.formattedValue)' unit='\(metric.type.unit)'")
        
        // Only show unit label for metrics that have meaningful units
        if metric.type.unit == "category" || metric.type.unit == "path" || 
           metric.type.unit == "distribution" || metric.type.unit == "values" ||
           metric.type.unit == "dimension" || metric.type.unit == "complexity" {
            unitLabel.text = ""
        } else {
            unitLabel.text = metric.type.unit
        }
        
        // Set icon based on metric type
        switch metric.type {
        case .stabilityScore: iconLabel.text = "〰️"
        case .efficiencyRating: iconLabel.text = "⚡"
        case .playerStyle: iconLabel.text = "👤"
        case .averageCorrectionTime: iconLabel.text = "⏱"
        case .directionalBias: iconLabel.text = "↔️"
        case .sessionTime: iconLabel.text = "⏲"
        default: iconLabel.text = "📊"
        }
        
        // Color based on confidence
        if let confidence = metric.confidence {
            valueLabel.textColor = confidenceColor(for: confidence)
        } else {
            valueLabel.textColor = .goldenPrimary
        }
    }
    
    func updateValue(_ metric: MetricValue) {
        valueLabel.text = metric.formattedValue
        
        // Debug logging
        print("DEBUG: MetricCell update - \(metric.type.rawValue): value='\(metric.formattedValue)'")
        
        if let confidence = metric.confidence {
            valueLabel.textColor = confidenceColor(for: confidence)
        }
    }
    
    private func confidenceColor(for confidence: Double) -> UIColor {
        if confidence >= 0.9 {
            return .systemGreen
        } else if confidence >= 0.7 {
            return .goldenPrimary
        } else if confidence >= 0.5 {
            return .systemOrange
        } else {
            return .systemRed
        }
    }
}

// MARK: - Chart Cell

class ChartCell: UITableViewCell {
    
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let chartContainer = UIView()
    private var currentChart: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Card container
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        contentView.addSubview(cardView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        cardView.addSubview(titleLabel)
        
        // Chart container
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.backgroundColor = .systemGray6
        chartContainer.layer.cornerRadius = 8
        cardView.addSubview(chartContainer)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            chartContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            chartContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            chartContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chartContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with metric: MetricValue) {
        titleLabel.text = metric.type.rawValue
        
        // Remove existing chart
        currentChart?.removeFromSuperview()
        
        // Create appropriate chart
        let chart = createChart(for: metric)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(chart)
        currentChart = chart
        
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: chartContainer.topAnchor),
            chart.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor),
            chart.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor)
        ])
        
        updateChart(metric)
    }
    
    func updateChart(_ metric: MetricValue) {
        guard let chart = currentChart else { return }
        updateChartData(chart, with: metric)
    }
    
    private func createChart(for metric: MetricValue) -> UIView {
        switch metric.type {
        case .directionalBias, .fullDirectionalBias:
            return SimplePieChartView()
        case .phaseTrajectory:
            return PhaseSpaceChartView()
        default:
            if metric.type.isDistribution {
                return SimpleBarChartView()
            } else {
                return SimpleLineChartView()
            }
        }
    }
    
    private func updateChartData(_ chartView: UIView, with metricValue: MetricValue) {
        switch metricValue.value {
        case let distribution as [Double]:
            if let barChart = chartView as? SimpleBarChartView {
                var chartData = distribution
                var chartLabels = (0..<distribution.count).map { String($0) }
                
                // Provide sample data if empty
                if chartData.isEmpty {
                    chartData = getSampleDistributionData(for: metricValue.type)
                    chartLabels = getSampleDistributionLabels(for: metricValue.type)
                }
                
                barChart.updateData(data: chartData, labels: chartLabels, title: "")
            }
            
        case let timeSeries as [(Date, Double)]:
            if let lineChart = chartView as? SimpleLineChartView {
                var values = timeSeries.map { $0.1 }
                var labels = timeSeries.map { DateFormatter.localizedString(from: $0.0, dateStyle: .none, timeStyle: .short) }
                
                // Provide sample data if empty
                if values.isEmpty {
                    let sampleData = getSampleTimeSeriesData(for: metricValue.type)
                    values = sampleData.map { $0.1 }
                    labels = sampleData.map { DateFormatter.localizedString(from: $0.0, dateStyle: .none, timeStyle: .short) }
                }
                
                lineChart.updateData(data: values, labels: labels, title: "")
            }
            
        case let trajectory as [(theta: Double, omega: Double)]:
            if let phaseChart = chartView as? PhaseSpaceChartView {
                var trajectoryData = trajectory
                
                // Provide sample trajectory if empty
                if trajectoryData.isEmpty {
                    trajectoryData = getSampleTrajectoryData()
                }
                
                let currentLevel = 1 // Default to level 1 for charts
                phaseChart.updateLevelData([currentLevel: trajectoryData])
            }
            
        default:
            // For simple metrics without special chart data, show a placeholder
            if let label = chartView.subviews.first as? UILabel {
                label.text = metricValue.formattedValue
            } else {
                let placeholderLabel = UILabel()
                placeholderLabel.text = metricValue.formattedValue
                placeholderLabel.font = .systemFont(ofSize: 24, weight: .bold)
                placeholderLabel.textAlignment = .center
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                chartView.addSubview(placeholderLabel)
                
                NSLayoutConstraint.activate([
                    placeholderLabel.centerXAnchor.constraint(equalTo: chartView.centerXAnchor),
                    placeholderLabel.centerYAnchor.constraint(equalTo: chartView.centerYAnchor)
                ])
            }
        }
    }
    
    // MARK: - Sample Data Providers
    
    private func getSampleDistributionData(for type: MetricType) -> [Double] {
        switch type {
        case .forceDistribution, .pushMagnitudeDistribution:
            return [5, 12, 18, 24, 15, 8, 3, 1] // Force magnitude histogram
        case .fullDirectionalBias:
            return [45, 55] // Left vs Right bias
        case .levelCompletionsOverTime:
            return [1, 2, 1, 3, 2, 1, 4, 2, 3, 1] // Levels completed per time period
        default:
            return [2, 5, 8, 12, 9, 6, 3, 1]
        }
    }
    
    private func getSampleDistributionLabels(for type: MetricType) -> [String] {
        switch type {
        case .forceDistribution, .pushMagnitudeDistribution:
            return ["0.5", "1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0"]
        case .fullDirectionalBias:
            return ["Left", "Right"]
        case .levelCompletionsOverTime:
            return ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7", "Day 8", "Day 9", "Day 10"]
        default:
            return (0..<8).map { "Bin \($0)" }
        }
    }
    
    private func getSampleTimeSeriesData(for type: MetricType) -> [(Date, Double)] {
        let now = Date()
        switch type {
        case .angularDeviation:
            return (0..<20).map { i in
                let date = now.addingTimeInterval(Double(i - 20) * 15) // 15 second intervals
                let angle = 0.1 * sin(Double(i) * 0.3) + Double.random(in: -0.05...0.05)
                return (date, angle)
            }
        case .reactionTimeAnalysis:
            return (0..<15).map { i in
                let date = now.addingTimeInterval(Double(i - 15) * 30) // 30 second intervals
                let reactionTime = 0.4 + Double.random(in: -0.1...0.2)
                return (date, reactionTime)
            }
        case .pendulumParametersOverTime:
            return (0..<12).map { i in
                let date = now.addingTimeInterval(Double(i - 12) * 60) // 1 minute intervals
                let parameterValue = 1.0 + Double(i) * 0.05 + Double.random(in: -0.02...0.02)
                return (date, parameterValue)
            }
        default:
            return (0..<10).map { i in
                let date = now.addingTimeInterval(Double(i - 10) * 60)
                let value = Double(i) + Double.random(in: -0.5...0.5)
                return (date, value)
            }
        }
    }
    
    private func getSampleTrajectoryData() -> [(theta: Double, omega: Double)] {
        // Generate a sample pendulum trajectory
        return (0..<100).map { i in
            let t = Double(i) * 0.05
            let theta = 0.3 * sin(t * 2.0) * exp(-t * 0.1) // Damped oscillation
            let omega = 0.6 * cos(t * 2.0) * exp(-t * 0.1) // Angular velocity
            return (theta: theta, omega: omega)
        }
    }
}