import UIKit
// import MessageUI // Not needed for this implementation

// MARK: - Export View Controller

class ExportViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let exportButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let statusLabel = UILabel()
    private let previewContainer = UIView()
    private let shareButton = UIButton(type: .system)
    
    // MARK: - Properties
    
    var exporter: BalanceDataExporter?
    private var exportPackage: BalanceDataExporter.ExportPackage?
    private var exportURL: URL?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Container
        containerView.backgroundColor = FocusCalendarTheme.cardBackgroundColor
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        view.addSubview(containerView)
        
        // Title
        titleLabel.text = "Export Balance Data"
        titleLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 24)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        
        // Description
        descriptionLabel.text = """
        Create your personal balance signature for AI grounding.
        This exports your gameplay data, analysis, and AI prompts
        to help reduce hallucination and personalize AI responses.
        """
        descriptionLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 16)
        descriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        containerView.addSubview(descriptionLabel)
        
        // Export Button
        exportButton.setTitle("Generate Balance Signature", for: .normal)
        exportButton.titleLabel?.font = FocusCalendarTheme.Fonts.bodyFont(size: 18)
        exportButton.backgroundColor = FocusCalendarTheme.accentGold
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.layer.cornerRadius = 25
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        containerView.addSubview(exportButton)
        
        // Progress View
        progressView.progressTintColor = FocusCalendarTheme.accentGold
        progressView.isHidden = true
        containerView.addSubview(progressView)
        
        // Status Label
        statusLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 14)
        statusLabel.textColor = FocusCalendarTheme.secondaryTextColor
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true
        containerView.addSubview(statusLabel)
        
        // Preview Container
        previewContainer.backgroundColor = FocusCalendarTheme.cardBackgroundColor
        previewContainer.layer.cornerRadius = 15
        previewContainer.layer.borderWidth = 1
        previewContainer.layer.borderColor = FocusCalendarTheme.accentGold.cgColor
        previewContainer.isHidden = true
        containerView.addSubview(previewContainer)
        
        // Share Button
        shareButton.setTitle("Share Export", for: .normal)
        shareButton.titleLabel?.font = FocusCalendarTheme.Fonts.bodyFont(size: 18)
        shareButton.backgroundColor = FocusCalendarTheme.accentSage
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.layer.cornerRadius = 25
        shareButton.isHidden = true
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        containerView.addSubview(shareButton)
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Export Button
            exportButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            exportButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            exportButton.widthAnchor.constraint(equalToConstant: 250),
            exportButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: exportButton.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Preview Container
            previewContainer.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            previewContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            previewContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            previewContainer.heightAnchor.constraint(equalToConstant: 200),
            
            // Share Button
            shareButton.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 20),
            shareButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 200),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func exportTapped() {
        exportButton.isEnabled = false
        progressView.isHidden = false
        statusLabel.isHidden = false
        progressView.progress = 0
        
        // Simulate export process
        performExport()
    }
    
    @objc private func shareTapped() {
        guard let url = exportURL else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [url, "My Pendulum Balance Signature"],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
    
    // MARK: - Export Process
    
    private func performExport() {
        // Get current user ID (you'd get this from your auth system)
        let userId = UserDefaults.standard.string(forKey: "userId") ?? "anonymous"
        let levelReached = UserDefaults.standard.integer(forKey: "PendulumMaxLevel")
        
        // Update progress
        updateProgress(0.2, status: "Collecting balance data...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateProgress(0.4, status: "Analyzing patterns...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.updateProgress(0.6, status: "Generating visualizations...")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.updateProgress(0.8, status: "Creating AI prompts...")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.completeExport(userId: userId, level: levelReached)
                    }
                }
            }
        }
    }
    
    private func updateProgress(_ progress: Float, status: String) {
        progressView.setProgress(progress, animated: true)
        statusLabel.text = status
    }
    
    private func completeExport(userId: String, level: Int) {
        // In real implementation, this would use actual recorded data
        guard let exporter = exporter,
              let package = exporter.exportComprehensiveData(userId: userId, levelReached: level) else {
            showError("No balance data available. Play a session first!")
            return
        }
        
        exportPackage = package
        
        exporter.saveExportPackage(package) { [weak self] url in
            DispatchQueue.main.async {
                if let url = url {
                    self?.exportURL = url
                    self?.showSuccess(package: package)
                } else {
                    self?.showError("Failed to save export")
                }
            }
        }
    }
    
    private func showSuccess(package: BalanceDataExporter.ExportPackage) {
        progressView.setProgress(1.0, animated: true)
        statusLabel.text = "Export complete!"
        
        // Show preview
        previewContainer.isHidden = false
        shareButton.isHidden = false
        
        // Add preview content
        let previewLabel = UILabel()
        previewLabel.text = """
        Balance Signature Generated
        
        Personality Profile:
        • Aggressiveness: \(String(format: "%.0f%%", package.metadata.personalityProfile.aggressiveness * 100))
        • Anticipation: \(String(format: "%.0f%%", package.metadata.personalityProfile.anticipation * 100))
        • Precision: \(String(format: "%.0f%%", package.metadata.personalityProfile.precision * 100))
        
        Files Created:
        • balance_data.csv
        • analysis.txt
        • ai_prompts.txt
        • phase_space.png
        """
        previewLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 14)
        previewLabel.textColor = FocusCalendarTheme.primaryTextColor
        previewLabel.numberOfLines = 0
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        previewContainer.addSubview(previewLabel)
        NSLayoutConstraint.activate([
            previewLabel.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 15),
            previewLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 15),
            previewLabel.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -15),
            previewLabel.bottomAnchor.constraint(lessThanOrEqualTo: previewContainer.bottomAnchor, constant: -15)
        ])
        
        // Re-enable export button
        exportButton.isEnabled = true
    }
    
    private func showError(_ message: String) {
        progressView.isHidden = true
        statusLabel.text = message
        statusLabel.textColor = FocusCalendarTheme.accentRose
        exportButton.isEnabled = true
    }
}

// MARK: - Integration Notes

// To integrate with your settings menu, add this code where appropriate:
/*
let exportAction = UIAction(title: "Export Balance Data", 
                           image: UIImage(systemName: "square.and.arrow.up")) { _ in
    let exportVC = ExportViewController()
    exportVC.modalPresentationStyle = .pageSheet
    self.present(exportVC, animated: true)
}
*/