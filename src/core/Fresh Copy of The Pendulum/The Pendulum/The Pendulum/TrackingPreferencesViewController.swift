import UIKit
import AppTrackingTransparency

/// View controller for managing App Tracking Transparency preferences
class TrackingPreferencesViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statusLabel = UILabel()
    private let idfaLabel = UILabel()
    
    private let changeSettingsButton = UIButton(type: .system)
    private let testTrackingButton = UIButton(type: .system)
    private let refreshStatusButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshTrackingStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTrackingStatus()
    }
    
    private func setupUI() {
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        title = "Privacy & Tracking"
        
        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "App Tracking Transparency"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Description
        descriptionLabel.text = """
        This app uses analytics to understand how you play and improve your gaming experience. 
        
        With tracking enabled, we can provide personalized insights and better game features. You can change this permission anytime in your device settings.
        """
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Status label
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.textColor = FocusCalendarTheme.primaryTextColor
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // IDFA label
        idfaLabel.font = .systemFont(ofSize: 14, weight: .regular)
        idfaLabel.textColor = FocusCalendarTheme.secondaryTextColor
        idfaLabel.numberOfLines = 0
        idfaLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(idfaLabel)
        
        // Change Settings Button
        changeSettingsButton.setTitle("Open Privacy Settings", for: .normal)
        changeSettingsButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        changeSettingsButton.backgroundColor = FocusCalendarTheme.accentGold
        changeSettingsButton.setTitleColor(.white, for: .normal)
        changeSettingsButton.layer.cornerRadius = 8
        changeSettingsButton.addTarget(self, action: #selector(openPrivacySettings), for: .touchUpInside)
        changeSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(changeSettingsButton)
        
        // Test Tracking Button (for debugging)
        testTrackingButton.setTitle("Test Tracking Event", for: .normal)
        testTrackingButton.titleLabel?.font = .systemFont(ofSize: 16)
        testTrackingButton.backgroundColor = .systemBlue
        testTrackingButton.setTitleColor(.white, for: .normal)
        testTrackingButton.layer.cornerRadius = 6
        testTrackingButton.addTarget(self, action: #selector(testTracking), for: .touchUpInside)
        testTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testTrackingButton)
        
        // Refresh Status Button
        refreshStatusButton.setTitle("Refresh Status", for: .normal)
        refreshStatusButton.titleLabel?.font = .systemFont(ofSize: 16)
        refreshStatusButton.backgroundColor = .systemGray
        refreshStatusButton.setTitleColor(.white, for: .normal)
        refreshStatusButton.layer.cornerRadius = 6
        refreshStatusButton.addTarget(self, action: #selector(refreshStatusTapped), for: .touchUpInside)
        refreshStatusButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(refreshStatusButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Status
            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // IDFA
            idfaLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            idfaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            idfaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Change Settings Button
            changeSettingsButton.topAnchor.constraint(equalTo: idfaLabel.bottomAnchor, constant: 30),
            changeSettingsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            changeSettingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            changeSettingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Test Button
            testTrackingButton.topAnchor.constraint(equalTo: changeSettingsButton.bottomAnchor, constant: 20),
            testTrackingButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            testTrackingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            testTrackingButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Refresh Button
            refreshStatusButton.topAnchor.constraint(equalTo: testTrackingButton.bottomAnchor, constant: 12),
            refreshStatusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            refreshStatusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            refreshStatusButton.heightAnchor.constraint(equalToConstant: 44),
            refreshStatusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func refreshTrackingStatus() {
        let manager = AppTrackingManager.shared
        let status = manager.getCurrentTrackingStatus()
        let isAuthorized = manager.isTrackingAuthorized()
        let idfa = manager.getIDFA()
        
        // Update status label
        let statusEmoji = isAuthorized ? "✅" : "❌"
        statusLabel.text = "\(statusEmoji) Tracking Status: \(status)"
        
        // Update IDFA label
        if let idfa = idfa {
            idfaLabel.text = "📱 Device ID: \(idfa)"
        } else {
            idfaLabel.text = "📱 Device ID: Not Available"
        }
        
        // Update button visibility
        if #available(iOS 14.5, *) {
            changeSettingsButton.isHidden = false
        } else {
            changeSettingsButton.isHidden = true
        }
        
        // Print debug info
        manager.printTrackingStatus()
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    @objc private func openPrivacySettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                if success {
                    print("📱 Opened Privacy Settings")
                    SingularTracker.trackTrackingSettingsOpened()
                } else {
                    print("❌ Failed to open Privacy Settings")
                }
            }
        }
    }
    
    @objc private func testTracking() {
        // Test tracking event
        SingularTracker.trackAchievement(type: "test_tracking_event")
        
        let alert = UIAlertController(
            title: "Test Event Sent",
            message: "A test tracking event has been sent to Singular SDK. Check the console for details.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshStatusTapped() {
        refreshTrackingStatus()
        
        let alert = UIAlertController(
            title: "Status Refreshed",
            message: "Tracking status has been updated.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}