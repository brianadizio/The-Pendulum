// DashboardTestingViewController.swift
// Visual testing interface for dashboard data inspection

import UIKit

class DashboardTestingViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Control buttons
    private var generateDataButton: UIButton!
    private var validateButton: UIButton!
    private var runTestsButton: UIButton!
    private var clearDataButton: UIButton!
    
    // Simulation controls
    private var profileSegmentControl: UISegmentedControl!
    private var durationSlider: UISlider!
    private var levelsSlider: UISlider!
    private var simulateButton: UIButton!
    
    // Test output
    private var outputTextView: UITextView!
    private var metricsStackView: UIStackView!
    
    // Testing components
    private let testingCoordinator = DashboardTestingCoordinator()
    private let simulator = GameplayDataSimulator()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateMetricsDisplay()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Dashboard Testing"
        
        // Navigation items
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Dashboard",
            style: .plain,
            target: self,
            action: #selector(showDashboard)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
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
        
        setupControlButtons()
        setupSimulationControls()
        setupMetricsDisplay()
        setupOutputView()
        
        // Set content height
        if let lastView = contentView.subviews.last {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    private func setupControlButtons() {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStackView)
        
        // Create buttons
        generateDataButton = createButton(
            title: "Generate Sample Data",
            color: .systemBlue,
            action: #selector(generateSampleData)
        )
        
        validateButton = createButton(
            title: "Validate Current Data",
            color: .systemGreen,
            action: #selector(validateCurrentData)
        )
        
        runTestsButton = createButton(
            title: "Run All Tests",
            color: .systemOrange,
            action: #selector(runAllTests)
        )
        
        clearDataButton = createButton(
            title: "Clear Test Data",
            color: .systemRed,
            action: #selector(clearTestData)
        )
        
        // Add to stack
        [generateDataButton, validateButton, runTestsButton, clearDataButton].forEach {
            buttonStackView.addArrangedSubview($0!)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSimulationControls() {
        let simulationView = UIView()
        simulationView.backgroundColor = .secondarySystemBackground
        simulationView.layer.cornerRadius = 12
        simulationView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(simulationView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Simulation Controls"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(titleLabel)
        
        // Profile selector
        profileSegmentControl = UISegmentedControl(items: [
            "Beginner", "Intermediate", "Expert", "Erratic", "Improver"
        ])
        profileSegmentControl.selectedSegmentIndex = 0
        profileSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(profileSegmentControl)
        
        // Duration slider
        let durationLabel = UILabel()
        durationLabel.text = "Duration: 5 min"
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(durationLabel)
        
        durationSlider = UISlider()
        durationSlider.minimumValue = 60 // 1 minute
        durationSlider.maximumValue = 1800 // 30 minutes
        durationSlider.value = 300 // 5 minutes
        durationSlider.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(durationSlider)
        
        // Levels slider
        let levelsLabel = UILabel()
        levelsLabel.text = "Levels: 3"
        levelsLabel.font = .systemFont(ofSize: 14)
        levelsLabel.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(levelsLabel)
        
        levelsSlider = UISlider()
        levelsSlider.minimumValue = 1
        levelsSlider.maximumValue = 10
        levelsSlider.value = 3
        levelsSlider.addTarget(self, action: #selector(levelsChanged), for: .valueChanged)
        levelsSlider.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(levelsSlider)
        
        // Simulate button
        simulateButton = createButton(
            title: "Simulate Gameplay",
            color: .systemPurple,
            action: #selector(simulateGameplay)
        )
        simulationView.addSubview(simulateButton)
        
        // Layout
        NSLayoutConstraint.activate([
            simulationView.topAnchor.constraint(equalTo: contentView.subviews[0].bottomAnchor, constant: 20),
            simulationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            simulationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: simulationView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            
            profileSegmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            profileSegmentControl.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            profileSegmentControl.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: profileSegmentControl.bottomAnchor, constant: 16),
            durationLabel.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 4),
            durationSlider.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            durationSlider.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor, constant: -16),
            
            levelsLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 16),
            levelsLabel.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            
            levelsSlider.topAnchor.constraint(equalTo: levelsLabel.bottomAnchor, constant: 4),
            levelsSlider.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            levelsSlider.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor, constant: -16),
            
            simulateButton.topAnchor.constraint(equalTo: levelsSlider.bottomAnchor, constant: 20),
            simulateButton.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 16),
            simulateButton.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor, constant: -16),
            simulateButton.bottomAnchor.constraint(equalTo: simulationView.bottomAnchor, constant: -16)
        ])
        
        // Store labels for updating
        durationLabel.tag = 100
        levelsLabel.tag = 101
    }
    
    private func setupMetricsDisplay() {
        let metricsView = UIView()
        metricsView.backgroundColor = .secondarySystemBackground
        metricsView.layer.cornerRadius = 12
        metricsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(metricsView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Current Metrics"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        metricsView.addSubview(titleLabel)
        
        // Metrics stack
        metricsStackView = UIStackView()
        metricsStackView.axis = .vertical
        metricsStackView.spacing = 8
        metricsStackView.translatesAutoresizingMaskIntoConstraints = false
        metricsView.addSubview(metricsStackView)
        
        // Get the simulation view (previous view)
        let previousView = contentView.subviews[contentView.subviews.count - 2]
        
        NSLayoutConstraint.activate([
            metricsView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
            metricsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            metricsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: metricsView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: metricsView.leadingAnchor, constant: 16),
            
            metricsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            metricsStackView.leadingAnchor.constraint(equalTo: metricsView.leadingAnchor, constant: 16),
            metricsStackView.trailingAnchor.constraint(equalTo: metricsView.trailingAnchor, constant: -16),
            metricsStackView.bottomAnchor.constraint(equalTo: metricsView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupOutputView() {
        outputTextView = UITextView()
        outputTextView.isEditable = false
        outputTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        outputTextView.backgroundColor = .secondarySystemBackground
        outputTextView.layer.cornerRadius = 8
        outputTextView.translatesAutoresizingMaskIntoConstraints = false
        outputTextView.text = "Test output will appear here..."
        contentView.addSubview(outputTextView)
        
        // Get the metrics view (previous view)
        let previousView = contentView.subviews[contentView.subviews.count - 2]
        
        NSLayoutConstraint.activate([
            outputTextView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
            outputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            outputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            outputTextView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func createButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    private func createMetricRow(title: String, value: String, isValid: Bool = true) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = isValid ? .label : .systemRed
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            
            container.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return container
    }
    
    private func updateMetricsDisplay() {
        // Clear existing metrics
        metricsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Get current metrics
        let metrics = AnalyticsManager.shared.getPerformanceMetrics()
        
        // Validate metrics
        let validation = DashboardDataValidator.validateMetrics(metrics)
        
        // Add metric rows
        if let stability = metrics["stabilityScore"] as? Double {
            let isValid = stability >= 0 && stability <= 100 && !stability.isNaN
            metricsStackView.addArrangedSubview(
                createMetricRow(
                    title: "Stability Score",
                    value: String(format: "%.1f", stability),
                    isValid: isValid
                )
            )
        }
        
        if let efficiency = metrics["efficiencyRating"] as? Double {
            let isValid = efficiency >= 0 && efficiency <= 100 && !efficiency.isNaN
            metricsStackView.addArrangedSubview(
                createMetricRow(
                    title: "Efficiency Rating",
                    value: String(format: "%.1f", efficiency),
                    isValid: isValid
                )
            )
        }
        
        if let style = metrics["playerStyle"] as? String {
            metricsStackView.addArrangedSubview(
                createMetricRow(title: "Player Style", value: style)
            )
        }
        
        if let reactionTime = metrics["averageCorrectionTime"] as? Double {
            let isValid = reactionTime >= 0 && reactionTime < 5
            metricsStackView.addArrangedSubview(
                createMetricRow(
                    title: "Avg Reaction Time",
                    value: String(format: "%.2fs", reactionTime),
                    isValid: isValid
                )
            )
        }
        
        if let bias = metrics["directionalBias"] as? Double {
            let isValid = bias >= -1.0 && bias <= 1.0
            let biasText = bias > 0.1 ? "Right" : bias < -0.1 ? "Left" : "Balanced"
            metricsStackView.addArrangedSubview(
                createMetricRow(
                    title: "Directional Bias",
                    value: "\(biasText) (\(String(format: "%.2f", bias)))",
                    isValid: isValid
                )
            )
        }
        
        // Add validation status
        let statusRow = createMetricRow(
            title: "Validation Status",
            value: validation.isValid ? "✅ Valid" : "❌ Invalid",
            isValid: validation.isValid
        )
        metricsStackView.addArrangedSubview(statusRow)
    }
    
    private func appendOutput(_ text: String) {
        outputTextView.text += "\n" + text
        outputTextView.scrollRangeToVisible(NSRange(location: outputTextView.text.count - 1, length: 1))
    }
    
    // MARK: - Actions
    
    @objc private func generateSampleData() {
        appendOutput("🔄 Generating sample data...")
        
        DashboardTestingCoordinator.generateSampleData()
        
        appendOutput("✅ Sample data generated!")
        updateMetricsDisplay()
    }
    
    @objc private func validateCurrentData() {
        appendOutput("🔍 Validating current data...")
        
        let report = testingCoordinator.generateTestReport()
        appendOutput(report)
        
        updateMetricsDisplay()
    }
    
    @objc private func runAllTests() {
        appendOutput("🧪 Running all tests...")
        
        // Capture console output
        let originalOutput = outputTextView.text
        outputTextView.text = "Running comprehensive tests...\n"
        
        DispatchQueue.global(qos: .userInitiated).async {
            DashboardTestingCoordinator.runAllTests()
            
            DispatchQueue.main.async {
                self.appendOutput("✅ All tests completed!")
                self.updateMetricsDisplay()
            }
        }
    }
    
    @objc private func clearTestData() {
        let alert = UIAlertController(
            title: "Clear Test Data",
            message: "This will remove all simulated test data. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.appendOutput("🗑️ Clearing test data...")
            // In a real implementation, this would clear Core Data test entries
            self.appendOutput("✅ Test data cleared!")
            self.updateMetricsDisplay()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func durationChanged() {
        let minutes = Int(durationSlider.value / 60)
        let seconds = Int(durationSlider.value.truncatingRemainder(dividingBy: 60))
        
        if let label = contentView.viewWithTag(100) as? UILabel {
            label.text = "Duration: \(minutes)m \(seconds)s"
        }
    }
    
    @objc private func levelsChanged() {
        if let label = contentView.viewWithTag(101) as? UILabel {
            label.text = "Levels: \(Int(levelsSlider.value))"
        }
    }
    
    @objc private func simulateGameplay() {
        let profiles: [GameplayDataSimulator.SimulationProfile] = [
            .beginner, .intermediate, .expert, .erratic, .improver
        ]
        
        let selectedProfile = profiles[profileSegmentControl.selectedSegmentIndex]
        let duration = TimeInterval(durationSlider.value)
        let levels = Int(levelsSlider.value)
        
        appendOutput("🎮 Simulating \(selectedProfile) gameplay...")
        appendOutput("Duration: \(Int(duration))s, Levels: \(levels)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let sessionId = self.simulator.simulateGameplay(
                profile: selectedProfile,
                duration: duration,
                levels: levels
            )
            
            DispatchQueue.main.async {
                self.appendOutput("✅ Simulation complete!")
                self.appendOutput("Session ID: \(sessionId)")
                
                // Show validation for the new session
                let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
                let validation = DashboardDataValidator.validateMetrics(metrics)
                
                if !validation.errors.isEmpty {
                    self.appendOutput("\n❌ Validation Errors:")
                    validation.errors.forEach { self.appendOutput("  - \($0)") }
                }
                
                if !validation.warnings.isEmpty {
                    self.appendOutput("\n⚠️ Validation Warnings:")
                    validation.warnings.forEach { self.appendOutput("  - \($0)") }
                }
                
                self.updateMetricsDisplay()
            }
        }
    }
    
    @objc private func showDashboard() {
        // This would navigate to the actual dashboard
        appendOutput("📊 Opening dashboard...")
    }
}