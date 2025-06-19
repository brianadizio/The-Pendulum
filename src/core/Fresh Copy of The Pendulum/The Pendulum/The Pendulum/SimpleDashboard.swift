import UIKit
import FirebaseAuth

// MARK: - Notifications
extension Notification.Name {
    static let parameterSelectionChanged = Notification.Name("parameterSelectionChanged")
}

// MARK: - Metric Description Helper

extension MetricType {
    var metricDescription: String {
        switch self {
        case .stabilityScore:
            return "Measures how well you keep the pendulum upright (0-100)."
        case .efficiencyRating:
            return "Shows how effectively you use force to maintain balance."
        case .playerStyle:
            return "Your playing pattern based on correction behavior."
        case .averageCorrectionTime:
            return "Average time to respond when pendulum becomes unstable."
        case .directionalBias:
            return "Tendency to favor left or right corrections."
        case .sessionTime:
            return "Total time spent playing in this period."
        case .balanceDuration:
            return "Time spent maintaining successful balance."
        case .pushCount:
            return "Total number of corrections applied."
        case .currentLevel:
            return "The level you're currently playing."
        case .overcorrectionRate:
            return "How often you apply opposite forces too quickly."
        case .responseDelay:
            return "Time delay between instability and correction."
        case .angularDeviation:
            return "Shows pendulum deviation from vertical over time - lower values mean better stability."
        case .forceDistribution, .pushMagnitudeDistribution:
            return "Strength of your corrections - smaller forces indicate more precise control."
        case .reactionTimeAnalysis:
            return "Speed of response to instability - faster reactions typically yield better control."
        case .learningCurve:
            return "Your improvement trend over time based on stability scores."
        case .fullDirectionalBias:
            return "Balance between left and right corrections - centered distribution shows unbiased control."
        case .levelCompletionsOverTime:
            return "Levels beaten as a function of time bins - adapts to selected time scale (session/daily/weekly/monthly/yearly)."
        case .pendulumParametersOverTime:
            return "How selected physics parameter changes over time - use controls above to select between Mass, Length, Gravity, Damping, and Force Multiplier."
        case .phaseTrajectory:
            return "Pendulum's angle vs velocity patterns - tighter loops indicate better control."
        case .inputFrequencySpectrum:
            return "Frequency analysis of your control inputs - reveals timing patterns."
        case .phaseSpaceCoverage:
            return "Percentage of possible pendulum states explored during play."
        case .energyManagement:
            return "How efficiently you manage the pendulum's kinetic and potential energy."
        case .lyapunovExponent:
            return "Measure of system chaos - higher values mean less predictable dynamics."
        case .controlStrategy:
            return "Your dominant control approach pattern during gameplay."
        case .stateTransitionFreq:
            return "How often the pendulum changes between different motion states."
        case .failureModeAnalysis:
            return "Common patterns in how you lose balance - helps identify weaknesses."
        case .adaptationRate:
            return "How quickly you adjust to new challenges and level changes."
        case .skillRetention:
            return "How well you maintain performance over extended play sessions."
        case .challengeThreshold:
            return "The difficulty level where you're most engaged and performing best."
        case .persistenceScore:
            return "Number of attempts before giving up on challenging levels."
        case .improvementRate:
            return "Speed of skill improvement over multiple sessions."
        case .windingNumber:
            return "Count of full rotations around vertical - indicates extreme swings."
        case .rotationNumber:
            return "Average rotation rate in phase space - characterizes motion type."
        case .homoclinicTangle:
            return "Complexity measure of chaotic pendulum trajectories."
        case .periodicOrbitCount:
            return "Number of repeating motion patterns in your control strategy."
        case .basinStability:
            return "Size of stable region - larger means more forgiving dynamics."
        case .topologicalEntropy:
            return "Information content of pendulum dynamics - complexity measure."
        case .bettinumbers:
            return "Topological features revealing phase space structure."
        case .persistentHomology:
            return "Long-lasting patterns in pendulum dynamics across time scales."
        case .separatrixCrossings:
            return "Transitions between different motion regimes (oscillation vs rotation)."
        case .phasePortraitStructure:
            return "Overall shape and type of phase space dynamics."
        case .realtimeStability:
            return "Consistency of performance metrics."
        case .cpuUsage:
            return "Processor load from game simulation."
        case .frameRate:
            return "Visual smoothness in frames per second."
        case .responseLatency:
            return "Delay between input and visual response."
        case .memoryEfficiency:
            return "RAM usage by the application."
        case .batteryImpact:
            return "Power consumption during gameplay."
        }
    }
}

class SimpleDashboard: UITableViewController {
    
    // MARK: - Properties
    
    private var metrics: [MetricValue] = []
    private var updateTimer: Timer?
    private var currentMetricGroup: MetricGroupType = .basic
    private var currentTimeRange: AnalyticsTimeRange = .daily
    private var capturedSessionTime: TimeInterval?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Set initial time range and parameter in AnalyticsManager
        AnalyticsManager.shared.setCurrentTimeRange(currentTimeRange)
        AnalyticsManager.shared.setCurrentSelectedParameter(.mass) // Default to mass
        startMetricUpdates()
        
        // Listen for auth state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authStateChanged),
            name: .authStateDidChange,
            object: nil
        )
        
        // Listen for parameter selection changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(parameterSelectionChanged),
            name: .parameterSelectionChanged,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Capture session time when dashboard appears
        captureSessionTime()
    }
    
    deinit {
        updateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func authStateChanged() {
        // Reload only the user status section
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
    
    @objc private func parameterSelectionChanged() {
        // Reload metrics to update charts with new parameter selection
        loadMetrics()
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
        }
    }
    
    // Public method to capture current session time
    func captureSessionTime() {
        // Only capture if we're showing session time range
        if currentTimeRange == .session {
            capturedSessionTime = SessionTimeManager.shared.getDashboardSessionDuration()
            // Silent capture - removed debug print
        }
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
        tableView.register(UserStatusCell.self, forCellReuseIdentifier: "UserStatus")
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
        var newMetrics = AnalyticsManager.shared.calculateMetrics(for: currentMetricGroup)
        
        // Override session time with captured value if in session time range
        if currentTimeRange == .session && capturedSessionTime != nil {
            for (index, metric) in newMetrics.enumerated() {
                if metric.type == .sessionTime {
                    // Replace with captured session time
                    newMetrics[index] = MetricValue(
                        type: .sessionTime,
                        value: capturedSessionTime!,
                        timestamp: metric.timestamp,
                        confidence: metric.confidence
                    )
                    // Silent override - removed debug print
                    break
                }
            }
        }
        
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
               indexPath.section == 3 && indexPath.row < metrics.count {
                metricCell.updateValue(metrics[indexPath.row])
            } else if let chartCell = cell as? ChartCell,
                      let indexPath = tableView.indexPath(for: cell),
                      indexPath.section == 3 && indexPath.row < metrics.count {
                chartCell.updateChart(metrics[indexPath.row])
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Header, User Status, Controls, Metrics
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Header
        case 1: return 1 // User Status
        case 2: return 1 // Controls
        case 3: return metrics.count // Metrics
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserStatus", for: indexPath) as! UserStatusCell
            cell.configure()
            return cell
            
        case 2:
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
                    // Update AnalyticsManager with new time range
                    AnalyticsManager.shared.setCurrentTimeRange(range)
                    // Capture session time when switching to session view
                    if range == .session {
                        self?.captureSessionTime()
                    }
                    self?.loadMetrics()
                    // Force table reload to update all visible charts
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            )
            return cell
            
        case 3:
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
        case 1: return 80  // User Status
        case 2: return 100 // Controls
        case 3:
            let metric = metrics[indexPath.row]
            return (metric.type.isDistribution || metric.type.isTimeSeries) ? 300 : 120 // Increased from 110 to 120 for value below description
        default: return 44
        }
    }
}

// MARK: - Header Cell

class HeaderCell: UITableViewCell {
    
    private let cardView = UIView()
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
        
        // Card container
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        contentView.addSubview(cardView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 28)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Controls Cell

class ControlsCell: UITableViewCell {
    
    private let cardView = UIView()
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
        
        // Card container
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        contentView.addSubview(cardView)
        
        // Group control
        let groupItems = MetricGroupType.allCases.map { $0.displayName }
        groupControl.removeAllSegments()
        for (index, item) in groupItems.enumerated() {
            groupControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        groupControl.selectedSegmentIndex = 0
        groupControl.translatesAutoresizingMaskIntoConstraints = false
        groupControl.addTarget(self, action: #selector(groupChanged), for: .valueChanged)
        cardView.addSubview(groupControl)
        
        // Time range control  
        let timeItems = ["Session", "Daily", "Weekly", "Monthly", "Yearly"]
        timeControl.removeAllSegments()
        for (index, item) in timeItems.enumerated() {
            timeControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        timeControl.selectedSegmentIndex = 1 // Daily
        timeControl.translatesAutoresizingMaskIntoConstraints = false
        timeControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
        cardView.addSubview(timeControl)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            groupControl.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            groupControl.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            groupControl.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            groupControl.heightAnchor.constraint(equalToConstant: 36),
            
            timeControl.topAnchor.constraint(equalTo: groupControl.bottomAnchor, constant: 8),
            timeControl.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            timeControl.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            timeControl.heightAnchor.constraint(equalToConstant: 36),
            timeControl.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
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
    private let descriptionLabel = UILabel()
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
        cardView.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
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
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        cardView.addSubview(descriptionLabel)
        
        // Value
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .goldenPrimary
        valueLabel.textAlignment = .left
        cardView.addSubview(valueLabel)
        
        // Unit
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.font = .systemFont(ofSize: 14)
        unitLabel.textColor = .secondaryLabel
        unitLabel.textAlignment = .left
        cardView.addSubview(unitLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            iconLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            
            unitLabel.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 6),
            unitLabel.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor)
        ])
    }
    
    func configure(with metric: MetricValue) {
        titleLabel.text = metric.type.rawValue
        descriptionLabel.text = metric.type.metricDescription
        
        // Format value with unit inline if appropriate
        let formattedValue = metric.formattedValue
        let unit = metric.type.unit
        
        // Check if unit is already included in formatted value or should be hidden
        let hideUnit = unit == "category" || unit == "path" || 
                      unit == "distribution" || unit == "values" ||
                      unit == "dimension" || unit == "complexity" ||
                      formattedValue.contains("%") || formattedValue.contains("s") ||
                      formattedValue.contains("ms") || formattedValue.contains("fps") ||
                      formattedValue.contains("Level") || formattedValue.contains("attempts")
        
        if hideUnit {
            valueLabel.text = formattedValue
            unitLabel.text = ""
        } else {
            valueLabel.text = formattedValue
            unitLabel.text = unit
        }
        
        // Debug logging
        // Removed debug print
        
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
        // Format value with unit inline if appropriate
        let formattedValue = metric.formattedValue
        let unit = metric.type.unit
        
        // Check if unit is already included in formatted value or should be hidden
        let hideUnit = unit == "category" || unit == "path" || 
                      unit == "distribution" || unit == "values" ||
                      unit == "dimension" || unit == "complexity" ||
                      formattedValue.contains("%") || formattedValue.contains("s") ||
                      formattedValue.contains("ms") || formattedValue.contains("fps") ||
                      formattedValue.contains("Level") || formattedValue.contains("attempts")
        
        if hideUnit {
            valueLabel.text = formattedValue
            unitLabel.text = ""
        } else {
            valueLabel.text = formattedValue
            unitLabel.text = unit
        }
        
        // Debug logging
        // Removed debug print
        
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
    private let descriptionLabel = UILabel()
    private let parameterSelector = UISegmentedControl()
    private let chartContainer = UIView()
    private var currentChart: UIView?
    private var currentMetric: MetricValue?
    
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
        cardView.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
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
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        descriptionLabel.layer.cornerRadius = 6
        descriptionLabel.layer.masksToBounds = true
        descriptionLabel.textAlignment = .left
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        // Add some internal padding to the description label
        descriptionLabel.layer.borderWidth = 0
        
        cardView.addSubview(descriptionLabel)
        
        // Parameter selector (initially hidden)
        parameterSelector.translatesAutoresizingMaskIntoConstraints = false
        for parameter in PendulumParameter.allCases {
            parameterSelector.insertSegment(withTitle: parameter.rawValue, at: parameterSelector.numberOfSegments, animated: false)
        }
        parameterSelector.selectedSegmentIndex = 0 // Default to first parameter
        parameterSelector.addTarget(self, action: #selector(parameterChanged), for: .valueChanged)
        parameterSelector.isHidden = true // Initially hidden
        cardView.addSubview(parameterSelector)
        
        // Chart container
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
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
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20), // Add left padding
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20), // Add right padding  
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 35), // Increase height for padding
            
            parameterSelector.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            parameterSelector.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            parameterSelector.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            parameterSelector.heightAnchor.constraint(equalToConstant: 32),
            
            chartContainer.topAnchor.constraint(equalTo: parameterSelector.bottomAnchor, constant: 8),
            chartContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            chartContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chartContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with metric: MetricValue) {
        currentMetric = metric
        titleLabel.text = metric.type.rawValue
        // Add padding to description text by using attributed string with paragraph style
        let description = metric.type.metricDescription
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 8
        paragraphStyle.headIndent = 8
        paragraphStyle.tailIndent = -8
        
        let attributedText = NSAttributedString(
            string: description,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraphStyle
            ]
        )
        descriptionLabel.attributedText = attributedText
        
        // Show parameter selector only for pendulum parameters chart
        if metric.type == .pendulumParametersOverTime {
            parameterSelector.isHidden = false
            // Set current selection based on AnalyticsManager's current selection
            let currentParam = AnalyticsManager.shared.getCurrentSelectedParameter()
            if let index = PendulumParameter.allCases.firstIndex(of: currentParam) {
                parameterSelector.selectedSegmentIndex = index
            }
        } else {
            parameterSelector.isHidden = true
        }
        
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
    
    @objc private func parameterChanged() {
        guard let selectedIndex = PendulumParameter.allCases.indices.contains(parameterSelector.selectedSegmentIndex) ? parameterSelector.selectedSegmentIndex : nil else { return }
        
        let selectedParameter = PendulumParameter.allCases[selectedIndex]
        
        // Update AnalyticsManager with new parameter selection
        AnalyticsManager.shared.setCurrentSelectedParameter(selectedParameter)
        
        // Trigger a refresh of the metric data
        // This will cause the dashboard to reload this metric with the new parameter
        if currentMetric != nil {
            // Post a notification to trigger dashboard reload
            NotificationCenter.default.post(name: .parameterSelectionChanged, object: nil)
        }
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
                var labels = timeSeries.map { formatDateForCurrentTimeScale($0.0) }
                
                // Provide sample data if empty
                if values.isEmpty {
                    let sampleData = getSampleTimeSeriesData(for: metricValue.type)
                    values = sampleData.map { $0.1 }
                    labels = sampleData.map { formatDateForCurrentTimeScale($0.0) }
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
                
                // Hide level selector and use simplified display
                phaseChart.showSimpleTrajectory(trajectoryData)
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
    
    // MARK: - Date Formatting
    
    private func formatDateForCurrentTimeScale(_ date: Date) -> String {
        let currentTimeRange = AnalyticsManager.shared.getCurrentTimeRange()
        
        switch currentTimeRange {
        case .session:
            // Show time (HH:MM) for session view
            return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            
        case .daily:
            // Show time (HH:MM) for daily view
            return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            
        case .weekly:
            // Show day names (Mon, Tue, Wed) for weekly view
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE" // Abbreviated weekday names
            return formatter.string(from: date)
            
        case .monthly:
            // Show dates (Jan 1, Jan 15) for monthly view
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // Month abbreviation + day
            return formatter.string(from: date)
            
        case .yearly:
            // Show months (Jan, Feb, Mar) for yearly view
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM" // Month abbreviation only
            return formatter.string(from: date)
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

// MARK: - User Status Cell

class UserStatusCell: UITableViewCell {
    
    private let cardView = UIView()
    private let iconImageView = UIImageView()
    private let statusLabel = UILabel()
    private let detailLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
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
        cardView.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        cardView.layer.cornerRadius = 12
        contentView.addSubview(cardView)
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        cardView.addSubview(iconImageView)
        
        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .label
        cardView.addSubview(statusLabel)
        
        // Detail label
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .secondaryLabel
        cardView.addSubview(detailLabel)
        
        // Action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        cardView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            statusLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            
            detailLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 2),
            detailLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: statusLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure() {
        if let user = AuthenticationManager.shared.currentUser {
            // User is signed in
            iconImageView.image = UIImage(systemName: "person.crop.circle.fill")
            statusLabel.text = "Signed In"
            detailLabel.text = user.displayName ?? user.email ?? "Player"
            actionButton.setTitle("View Profile", for: .normal)
            actionButton.removeTarget(nil, action: nil, for: .allEvents)
            actionButton.addTarget(self, action: #selector(viewProfileTapped), for: .touchUpInside)
        } else {
            // User is not signed in
            iconImageView.image = UIImage(systemName: "person.crop.circle.badge.plus")
            statusLabel.text = "Not Signed In"
            detailLabel.text = "Sign in to save your progress"
            actionButton.setTitle("Sign In", for: .normal)
            actionButton.removeTarget(nil, action: nil, for: .allEvents)
            actionButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        }
    }
    
    @objc private func viewProfileTapped() {
        // Find the parent view controller
        if let viewController = self.window?.rootViewController?.presentedViewController ?? self.window?.rootViewController {
            let alert = UIAlertController(
                title: "Profile",
                message: """
                \(AuthenticationManager.shared.currentUser?.displayName ?? "Player")
                \(AuthenticationManager.shared.currentUser?.email ?? "")
                """,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }
    
    @objc private func signInTapped() {
        // Find the parent view controller
        if let viewController = self.window?.rootViewController?.presentedViewController ?? self.window?.rootViewController {
            let signInVC = SignInViewController()
            let nav = UINavigationController(rootViewController: signInVC)
            nav.modalPresentationStyle = .fullScreen
            viewController.present(nav, animated: true)
        }
    }
}