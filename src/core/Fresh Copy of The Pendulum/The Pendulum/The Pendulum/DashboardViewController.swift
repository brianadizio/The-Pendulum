import UIKit
// Remove Charts import as it's not included by default
// import Charts

// Dashboard notification name
let DashboardStatsUpdatedNotification = NSNotification.Name("PendulumStatsUpdated")

class DashboardViewController: UIViewController {
    
    // Reference to view model
    private let viewModel: PendulumViewModel
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var statisticsCard: UIView!
    private var levelCard: UIView!
    private var historyCard: UIView!
    private var performanceCard: UIView!
    
    // Header components
    private var headerView: UIView!
    private var titleLabel: UILabel!
    
    // Statistics labels (containing both title and value)
    private var highScoreContainer: UIView!
    private var totalTimeContainer: UIView!
    private var currentLevelContainer: UIView!
    private var maxAngleContainer: UIView!
    
    // Value labels for accessing directly
    private var highScoreValueLabel: UILabel!
    private var totalTimeValueLabel: UILabel!
    private var currentLevelValueLabel: UILabel!
    private var maxAngleValueLabel: UILabel!
    
    // Chart view
    private var chartView: UIView!
    private var phaseSpaceView: PhaseSpaceView!
    
    init(viewModel: PendulumViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        // Register for updates from the view model
        NotificationCenter.default.addObserver(self, selector: #selector(updateStats), name: DashboardStatsUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustContentSize()
    }
    
    /// Adjusts the content size based on the actual content height
    private func adjustContentSize() {
        // Find the last subview of contentView
        if let lastView = contentView.subviews.last, 
           let performanceCard = performanceCard {
            // Calculate height based on the actual position of the last view
            let contentHeight = performanceCard.frame.maxY + 30
            
            // Update the scrollView contentSize
            var contentSize = scrollView.contentSize
            contentSize.height = contentHeight
            scrollView.contentSize = contentSize
            
            // Update contentView height constraint
            for constraint in contentView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = contentHeight
                }
            }
        }
    }
    
    private func setupViews() {
        // Set up the main view with Golden Enterprise theme
        view.backgroundColor = .goldenBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Setup content view inside scroll view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Set a default minimum height for contentView
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 650).isActive = true
        
        // Setup header and all dashboard cards
        setupHeader()
        setupStatisticsCard()
        setupLevelProgressCard()
        setupPerformanceCard()
        
        // Set content size based on the bottom of the last component
        if let lastView = contentView.subviews.last {
            let constraint = NSLayoutConstraint(
                item: contentView, 
                attribute: .height, 
                relatedBy: .equal, 
                toItem: nil, 
                attribute: .notAnAttribute, 
                multiplier: 1.0, 
                constant: lastView.frame.maxY + 20
            )
            contentView.addConstraint(constraint)
            
            // Also add this constraint in viewDidLayoutSubviews to get the correct size
            DispatchQueue.main.async {
                self.adjustContentSize()
            }
        }
    }
    
    private func setupHeader() {
        // Create header container
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        contentView.addSubview(headerView)
        
        // Add gradient layer to header
        DispatchQueue.main.async { // Add on next run loop to ensure bounds are set
            let gradientLayer = GoldenGradients.createHeaderGradient(for: self.headerView)
            self.headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add logo to header - using the appLogo extension
        let logoImageView = UIImageView(image: UIImage.appLogo)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 15
        logoImageView.clipsToBounds = true
        if logoImageView.image == nil {
            // In case the image is nil, set a background color
            logoImageView.backgroundColor = .goldenAccent
        }
        logoImageView.tintColor = .goldenAccent // For the fallback symbol if used
        headerView.addSubview(logoImageView)
        
        // Create title label
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "The Pendulum Dashboard"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)
        
        // Set constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Logo on the left side of header
            logoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title centered in header
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
    
    private func setupStatisticsCard() {
        // Create statistics card
        statisticsCard = UIView()
        statisticsCard.translatesAutoresizingMaskIntoConstraints = false
        statisticsCard.applyGoldenCard()
        contentView.addSubview(statisticsCard)
        
        // Create card title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Statistics"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .goldenDark
        statisticsCard.addSubview(titleLabel)
        
        // Create statistics stack
        let statsStack = UIStackView()
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .vertical
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually
        statisticsCard.addSubview(statsStack)
        
        // Create individual statistics labels with their containers
        highScoreContainer = createStatLabel(title: "High Score", value: "\(viewModel.highScore)")
        totalTimeContainer = createStatLabel(title: "Total Balance Time", value: String(format: "%.1f s", viewModel.totalBalanceTime))
        currentLevelContainer = createStatLabel(title: "Current Level", value: "\(viewModel.currentLevel)")
        maxAngleContainer = createStatLabel(title: "Max Angle Achieved", value: String(format: "%.1f°", viewModel.levelStats["maxAngle"] ?? 0.0))
        
        // Get references to value labels
        if let highScoreView = highScoreContainer.subviews.last as? UILabel {
            highScoreValueLabel = highScoreView
        }
        if let totalTimeView = totalTimeContainer.subviews.last as? UILabel {
            totalTimeValueLabel = totalTimeView
        }
        if let currentLevelView = currentLevelContainer.subviews.last as? UILabel {
            currentLevelValueLabel = currentLevelView
        }
        if let maxAngleView = maxAngleContainer.subviews.last as? UILabel {
            maxAngleValueLabel = maxAngleView
        }
        
        // Add to stack view
        statsStack.addArrangedSubview(highScoreContainer)
        statsStack.addArrangedSubview(totalTimeContainer)
        statsStack.addArrangedSubview(currentLevelContainer)
        statsStack.addArrangedSubview(maxAngleContainer)
        
        // Set constraints
        NSLayoutConstraint.activate([
            statisticsCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            statisticsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statisticsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: statisticsCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: statisticsCard.trailingAnchor, constant: -16),
            
            statsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: statisticsCard.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: statisticsCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupLevelProgressCard() {
        // Create level progress card
        levelCard = UIView()
        levelCard.translatesAutoresizingMaskIntoConstraints = false
        levelCard.applyGoldenCard()
        contentView.addSubview(levelCard)
        
        // Create card title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Level Progress"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .goldenDark
        levelCard.addSubview(titleLabel)
        
        // Create level indicator
        let levelIndicator = UIView()
        levelIndicator.translatesAutoresizingMaskIntoConstraints = false
        levelIndicator.backgroundColor = .goldenBackground
        levelIndicator.layer.cornerRadius = 8
        levelIndicator.layer.borderWidth = 1
        levelIndicator.layer.borderColor = UIColor.goldenPrimary.cgColor
        levelCard.addSubview(levelIndicator)
        
        // Create level label
        let levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Level \(viewModel.currentLevel)"
        levelLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        levelLabel.textColor = .goldenDark
        levelLabel.textAlignment = .center
        levelIndicator.addSubview(levelLabel)
        
        // Create progress description
        let progressDescription = UILabel()
        progressDescription.translatesAutoresizingMaskIntoConstraints = false
        progressDescription.text = "Balance time required: \(String(format: "%.1f", viewModel.levelSuccessTime)) seconds"
        progressDescription.font = UIFont.systemFont(ofSize: 16)
        progressDescription.textColor = .goldenTextLight
        progressDescription.textAlignment = .center
        levelCard.addSubview(progressDescription)
        
        // Set constraints
        NSLayoutConstraint.activate([
            levelCard.topAnchor.constraint(equalTo: statisticsCard.bottomAnchor, constant: 20),
            levelCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            levelCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: levelCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: levelCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: levelCard.trailingAnchor, constant: -16),
            
            levelIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            levelIndicator.centerXAnchor.constraint(equalTo: levelCard.centerXAnchor),
            levelIndicator.widthAnchor.constraint(equalToConstant: 150),
            levelIndicator.heightAnchor.constraint(equalToConstant: 150),
            
            levelLabel.centerXAnchor.constraint(equalTo: levelIndicator.centerXAnchor),
            levelLabel.centerYAnchor.constraint(equalTo: levelIndicator.centerYAnchor),
            
            progressDescription.topAnchor.constraint(equalTo: levelIndicator.bottomAnchor, constant: 16),
            progressDescription.leadingAnchor.constraint(equalTo: levelCard.leadingAnchor, constant: 16),
            progressDescription.trailingAnchor.constraint(equalTo: levelCard.trailingAnchor, constant: -16),
            progressDescription.bottomAnchor.constraint(equalTo: levelCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPerformanceCard() {
        // Create performance card
        performanceCard = UIView()
        performanceCard.translatesAutoresizingMaskIntoConstraints = false
        performanceCard.applyGoldenCard()
        contentView.addSubview(performanceCard)
        
        // Create card title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Balancing Performance"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .goldenDark
        performanceCard.addSubview(titleLabel)
        
        // Create chart view placeholder
        chartView = UIView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = UIColor.white
        chartView.layer.cornerRadius = 8
        chartView.layer.borderWidth = 1
        chartView.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.2).cgColor
        performanceCard.addSubview(chartView)
        
        // Setup the chart placeholder
        setupChart()
        
        // Create chart label
        let chartLabel = UILabel()
        chartLabel.translatesAutoresizingMaskIntoConstraints = false
        chartLabel.text = "Phase Space Visualization"
        chartLabel.font = UIFont.systemFont(ofSize: 14)
        chartLabel.textColor = .goldenTextLight
        chartLabel.textAlignment = .center
        performanceCard.addSubview(chartLabel)
        
        // Set constraints
        NSLayoutConstraint.activate([
            performanceCard.topAnchor.constraint(equalTo: levelCard.bottomAnchor, constant: 20),
            performanceCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            performanceCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: performanceCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: performanceCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: performanceCard.trailingAnchor, constant: -16),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: performanceCard.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: performanceCard.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200),
            
            chartLabel.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 8),
            chartLabel.leadingAnchor.constraint(equalTo: performanceCard.leadingAnchor, constant: 16),
            chartLabel.trailingAnchor.constraint(equalTo: performanceCard.trailingAnchor, constant: -16),
            chartLabel.bottomAnchor.constraint(equalTo: performanceCard.bottomAnchor, constant: -16)
        ])
    }
    
    // Helper method to create a stat row with a title and value
    private func createStatLabel(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .goldenTextLight
        container.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .goldenDark
        valueLabel.textAlignment = .right
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
        
        // Store the container's tag for identification
        container.tag = title.hashValue
        
        return container
    }
    
    @objc private func updateStats() {
        // Update all stats from the view model
        
        // Update statistics directly
        highScoreValueLabel?.text = "\(viewModel.highScore)"
        totalTimeValueLabel?.text = String(format: "%.1f s", viewModel.totalBalanceTime)
        currentLevelValueLabel?.text = "\(viewModel.currentLevel)"
        maxAngleValueLabel?.text = String(format: "%.1f°", viewModel.levelStats["maxAngle"] ?? 0.0)
        
        // Level card
        for subview in levelCard.subviews {
            if let label = subview as? UILabel, label.text?.contains("Level") == true {
                label.text = "Level \(viewModel.currentLevel)"
            }
            
            if let label = subview as? UILabel, label.text?.contains("Balance time") == true {
                label.text = "Balance time required: \(String(format: "%.1f", viewModel.levelSuccessTime)) seconds"
            }
        }
        
        // Update the phase space view with the current state
        phaseSpaceView?.clearPoints()
        phaseSpaceView?.addPoint(theta: viewModel.currentState.theta, omega: viewModel.currentState.thetaDot)
    }
}

// MARK: - Extension for chart handling
extension DashboardViewController {
    private func setupChart() {
        // Create a phase space view for chart visualization
        phaseSpaceView = PhaseSpaceView(frame: .zero)
        phaseSpaceView.translatesAutoresizingMaskIntoConstraints = false
        chartView.addSubview(phaseSpaceView)
        
        NSLayoutConstraint.activate([
            phaseSpaceView.topAnchor.constraint(equalTo: chartView.topAnchor, constant: 10),
            phaseSpaceView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor, constant: 10),
            phaseSpaceView.trailingAnchor.constraint(equalTo: chartView.trailingAnchor, constant: -10),
            phaseSpaceView.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: -10)
        ])
        
        // Add an initial point to visualize the phase space
        phaseSpaceView.addPoint(theta: viewModel.currentState.theta, omega: viewModel.currentState.thetaDot)
    }
}