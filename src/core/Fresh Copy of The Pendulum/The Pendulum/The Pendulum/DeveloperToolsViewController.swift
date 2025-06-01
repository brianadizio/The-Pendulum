import UIKit

class DeveloperToolsViewController: UIViewController {
    
    private let tableView = UITableView()
    private var progressHUD: UIView?
    
    private enum DeveloperOption: String, CaseIterable {
        case quickAITest = "Quick AI Test (5 min)"
        case comprehensiveAITest = "Comprehensive AI Test (10 min)"
        case longTermAITest = "Long-term AI Test (30 min)"
        case generateTestData = "Generate Test Dashboard Data"
        case debugDashboard = "Debug Dashboard Metrics"
        case clearAllData = "Clear All Analytics Data"
        
        var subtitle: String {
            switch self {
            case .quickAITest:
                return "Run a 5-minute AI simulation"
            case .comprehensiveAITest:
                return "Run multiple AI sessions with various modes"
            case .longTermAITest:
                return "Generate extensive historical data"
            case .generateTestData:
                return "Instantly populate dashboard with test data"
            case .debugDashboard:
                return "Show diagnostic report for metrics"
            case .clearAllData:
                return "Remove all analytics data (caution!)"
            }
        }
        
        var iconName: String {
            switch self {
            case .quickAITest, .comprehensiveAITest, .longTermAITest:
                return "brain.head.profile"
            case .generateTestData:
                return "chart.line.uptrend.xyaxis"
            case .debugDashboard:
                return "wrench.and.screwdriver"
            case .clearAllData:
                return "trash"
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .clearAllData:
                return .systemRed
            default:
                return .systemBlue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Developer Tools"
        view.backgroundColor = .goldenBackground
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.goldenPrimary.withAlphaComponent(0.3)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeveloperCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension DeveloperToolsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeveloperOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeveloperCell", for: indexPath)
        let option = DeveloperOption.allCases[indexPath.row]
        
        // Configure cell
        var content = cell.defaultContentConfiguration()
        content.text = option.rawValue
        content.secondaryText = option.subtitle
        content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
        content.secondaryTextProperties.color = .secondaryLabel
        
        // Add icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        content.image = UIImage(systemName: option.iconName, withConfiguration: iconConfig)
        content.imageProperties.tintColor = option.tintColor
        
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        
        // Add chevron
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .secondaryLabel
        cell.accessoryView = chevron
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DeveloperToolsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = DeveloperOption.allCases[indexPath.row]
        handleDeveloperOption(option)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func handleDeveloperOption(_ option: DeveloperOption) {
        switch option {
        case .quickAITest:
            runQuickAITest()
        case .comprehensiveAITest:
            runComprehensiveAITest()
        case .longTermAITest:
            runLongTermAITest()
        case .generateTestData:
            generateTestData()
        case .debugDashboard:
            showDebugReport()
        case .clearAllData:
            confirmClearAllData()
        }
    }
    
    // MARK: - AI Test Actions
    
    private func runQuickAITest() {
        showProgressHUD(message: "Running Quick AI Test...")
        
        let aiSystem = AITestingSystem()
        aiSystem.runQuickTest { [weak self] results in
            DispatchQueue.main.async {
                self?.hideProgressHUD()
                self?.showTestResults(results, testType: "Quick")
            }
        }
    }
    
    private func runComprehensiveAITest() {
        showProgressHUD(message: "Running Comprehensive AI Test...")
        
        let aiSystem = AITestingSystem()
        aiSystem.runComprehensiveTest { [weak self] results in
            DispatchQueue.main.async {
                self?.hideProgressHUD()
                self?.showTestResults(results, testType: "Comprehensive")
            }
        }
    }
    
    private func runLongTermAITest() {
        showProgressHUD(message: "Running Long-term AI Test...")
        
        let aiSystem = AITestingSystem()
        aiSystem.runLongTermTest { [weak self] results in
            DispatchQueue.main.async {
                self?.hideProgressHUD()
                self?.showTestResults(results, testType: "Long-term")
            }
        }
    }
    
    private func generateTestData() {
        showProgressHUD(message: "Generating Test Data...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Generate comprehensive test data
            DebugDashboardSystem.shared.generateComprehensiveTestData()
            
            DispatchQueue.main.async { [weak self] in
                self?.hideProgressHUD()
                self?.showAlert(
                    title: "Test Data Generated",
                    message: "Dashboard has been populated with test data. Navigate to Analytics to view the results."
                )
            }
        }
    }
    
    private func showDebugReport() {
        showProgressHUD(message: "Analyzing Metrics...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let report = DebugDashboardSystem.shared.analyzeCurrentMetrics()
            
            DispatchQueue.main.async { [weak self] in
                self?.hideProgressHUD()
                self?.showDebugReportView(report)
            }
        }
    }
    
    private func confirmClearAllData() {
        let alert = UIAlertController(
            title: "Clear All Data?",
            message: "This will permanently delete all analytics data. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.clearAllData()
        })
        
        present(alert, animated: true)
    }
    
    private func clearAllData() {
        // Clear all analytics data
        AnalyticsManager.shared.clearAllData()
        
        showAlert(
            title: "Data Cleared",
            message: "All analytics data has been removed."
        )
    }
    
    // MARK: - UI Helpers
    
    private func showProgressHUD(message: String) {
        let hud = UIView()
        hud.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        hud.layer.cornerRadius = 12
        hud.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        hud.addSubview(activityIndicator)
        hud.addSubview(label)
        
        view.addSubview(hud)
        progressHUD = hud
        
        NSLayoutConstraint.activate([
            hud.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hud.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hud.widthAnchor.constraint(equalToConstant: 200),
            hud.heightAnchor.constraint(equalToConstant: 100),
            
            activityIndicator.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: hud.topAnchor, constant: 20),
            
            label.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        ])
    }
    
    private func hideProgressHUD() {
        progressHUD?.removeFromSuperview()
        progressHUD = nil
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showTestResults(_ results: AITestingSystem.TestResults, testType: String) {
        let message = """
        \(testType) AI Test Complete!
        
        Sessions Run: \(results.totalSessions)
        Total Duration: \(Int(results.totalDuration / 60)) minutes
        Average Score: \(Int(results.averageScore))
        Avg Levels/Session: \(String(format: "%.1f", results.averageLevelsPerSession))
        
        Dashboard data has been generated.
        """
        
        showAlert(title: "Test Complete", message: message)
    }
    
    private func showDebugReportView(_ report: String) {
        let textView = UITextView()
        textView.text = report
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.backgroundColor = .systemBackground
        
        let vc = UIViewController()
        vc.view = textView
        vc.title = "Debug Report"
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissDebugReport)
        )
        
        present(nav, animated: true)
    }
    
    @objc private func dismissDebugReport() {
        dismiss(animated: true)
    }
}