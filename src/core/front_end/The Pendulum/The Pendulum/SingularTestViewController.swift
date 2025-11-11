import UIKit

class SingularTestViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let statusLabel = UILabel()
    private let versionLabel = UILabel()
    
    // Test buttons
    private let initializeButton = UIButton(type: .system)
    private let trackInstallButton = UIButton(type: .system)
    private let trackLevelButton = UIButton(type: .system)
    private let trackRevenueButton = UIButton(type: .system)
    private let trackCustomEventButton = UIButton(type: .system)
    private let testDeepLinkButton = UIButton(type: .system)
    
    // Output text view
    private let outputTextView = UITextView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkSingularStatus()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Singular SDK Test"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Status label
        statusLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // Version label
        versionLabel.font = .systemFont(ofSize: 14)
        versionLabel.textColor = .secondaryLabel
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(versionLabel)
        
        // Initialize button
        initializeButton.setTitle("Initialize Singular", for: .normal)
        initializeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        initializeButton.backgroundColor = .systemBlue
        initializeButton.setTitleColor(.white, for: .normal)
        initializeButton.layer.cornerRadius = 8
        initializeButton.addTarget(self, action: #selector(initializeTapped), for: .touchUpInside)
        initializeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(initializeButton)
        
        // Track Install button
        trackInstallButton.setTitle("Track Install Event", for: .normal)
        trackInstallButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        trackInstallButton.backgroundColor = .systemGreen
        trackInstallButton.setTitleColor(.white, for: .normal)
        trackInstallButton.layer.cornerRadius = 8
        trackInstallButton.addTarget(self, action: #selector(trackInstallTapped), for: .touchUpInside)
        trackInstallButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackInstallButton)
        
        // Track Level button
        trackLevelButton.setTitle("Track Level Balanced", for: .normal)
        trackLevelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        trackLevelButton.backgroundColor = .systemOrange
        trackLevelButton.setTitleColor(.white, for: .normal)
        trackLevelButton.layer.cornerRadius = 8
        trackLevelButton.addTarget(self, action: #selector(trackLevelTapped), for: .touchUpInside)
        trackLevelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackLevelButton)
        
        // Track Revenue button
        trackRevenueButton.setTitle("Track Revenue", for: .normal)
        trackRevenueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        trackRevenueButton.backgroundColor = .systemPurple
        trackRevenueButton.setTitleColor(.white, for: .normal)
        trackRevenueButton.layer.cornerRadius = 8
        trackRevenueButton.addTarget(self, action: #selector(trackRevenueTapped), for: .touchUpInside)
        trackRevenueButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackRevenueButton)
        
        // Track Custom Event button
        trackCustomEventButton.setTitle("Track Custom Event", for: .normal)
        trackCustomEventButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        trackCustomEventButton.backgroundColor = .systemTeal
        trackCustomEventButton.setTitleColor(.white, for: .normal)
        trackCustomEventButton.layer.cornerRadius = 8
        trackCustomEventButton.addTarget(self, action: #selector(trackCustomEventTapped), for: .touchUpInside)
        trackCustomEventButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackCustomEventButton)
        
        // Test Deep Link button
        testDeepLinkButton.setTitle("Test Deep Link", for: .normal)
        testDeepLinkButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        testDeepLinkButton.backgroundColor = .systemIndigo
        testDeepLinkButton.setTitleColor(.white, for: .normal)
        testDeepLinkButton.layer.cornerRadius = 8
        testDeepLinkButton.addTarget(self, action: #selector(testDeepLinkTapped), for: .touchUpInside)
        testDeepLinkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testDeepLinkButton)
        
        // Output text view
        outputTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        outputTextView.backgroundColor = .secondarySystemBackground
        outputTextView.layer.cornerRadius = 8
        outputTextView.isEditable = false
        outputTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(outputTextView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Version label
            versionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Initialize button
            initializeButton.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 30),
            initializeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            initializeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            initializeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Track Install button
            trackInstallButton.topAnchor.constraint(equalTo: initializeButton.bottomAnchor, constant: 16),
            trackInstallButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trackInstallButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            trackInstallButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Track Level button
            trackLevelButton.topAnchor.constraint(equalTo: trackInstallButton.bottomAnchor, constant: 16),
            trackLevelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trackLevelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            trackLevelButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Track Revenue button
            trackRevenueButton.topAnchor.constraint(equalTo: trackLevelButton.bottomAnchor, constant: 16),
            trackRevenueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trackRevenueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            trackRevenueButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Track Custom Event button
            trackCustomEventButton.topAnchor.constraint(equalTo: trackRevenueButton.bottomAnchor, constant: 16),
            trackCustomEventButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trackCustomEventButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            trackCustomEventButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Test Deep Link button
            testDeepLinkButton.topAnchor.constraint(equalTo: trackCustomEventButton.bottomAnchor, constant: 16),
            testDeepLinkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testDeepLinkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testDeepLinkButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Output text view
            outputTextView.topAnchor.constraint(equalTo: testDeepLinkButton.bottomAnchor, constant: 30),
            outputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            outputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            outputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            outputTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Status Check
    
    private func checkSingularStatus() {
        if SingularTestConfiguration.isSingularAvailable() {
            statusLabel.text = "✅ Singular SDK Available"
            statusLabel.textColor = .systemGreen
            versionLabel.text = "Version: \(SingularTestConfiguration.getSDKVersion())"
        } else {
            statusLabel.text = "❌ Singular SDK Not Available"
            statusLabel.textColor = .systemRed
            versionLabel.text = "Please add Singular SDK via Swift Package Manager"
        }
        
        SingularTestConfiguration.printConfiguration()
        outputTextView.text = """
        Singular SDK Test
        
        Status: \(SingularTestConfiguration.isSingularAvailable() ? "Available" : "Not Available")
        Version: \(SingularTestConfiguration.getSDKVersion())
        
        Ready to test Singular integration.
        
        Note: You'll need to add your API Key and Secret in SingularTestConfiguration.swift
        """
    }
    
    // MARK: - Actions
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    @objc private func initializeTapped() {
        appendOutput("\n🚀 Initializing Singular...")
        SingularTestConfiguration.initializeSingular()
        appendOutput("✅ Singular initialization called")
    }
    
    @objc private func trackInstallTapped() {
        appendOutput("\n📱 Tracking install event...")
        SingularTracker.trackInstall()
        appendOutput("✅ Install event tracked")
    }
    
    @objc private func trackLevelTapped() {
        appendOutput("\n🎮 Tracking level balanced...")
        // Simulate tracking a level completion
        let level = Int.random(in: 1...10)
        let balanceTime = Double.random(in: 10...120)
        let score = Int.random(in: 1000...10000)
        
        SingularTracker.trackLevelBalanced(
            level: level,
            balanceTime: balanceTime,
            score: score,
            attempts: Int.random(in: 1...5)
        )
        
        appendOutput("✅ Level \(level) balanced tracked (Time: \(String(format: "%.1f", balanceTime))s, Score: \(score))")
    }
    
    @objc private func trackRevenueTapped() {
        appendOutput("\n💰 Tracking revenue...")
        SingularTestConfiguration.testRevenue()
        appendOutput("✅ Revenue tracked")
    }
    
    @objc private func trackCustomEventTapped() {
        appendOutput("\n📊 Tracking custom event...")
        SingularTestConfiguration.testTrackEvent()
        appendOutput("✅ Custom event tracked")
    }
    
    @objc private func testDeepLinkTapped() {
        appendOutput("\n🔗 Testing deep link...")
        SingularTestConfiguration.testDeepLinks()
        appendOutput("✅ Deep link tested")
    }
    
    private func appendOutput(_ text: String) {
        outputTextView.text += "\n" + text
        
        // Scroll to bottom
        if outputTextView.text.count > 0 {
            let bottom = NSMakeRange(outputTextView.text.count - 1, 1)
            outputTextView.scrollRangeToVisible(bottom)
        }
    }
}