import UIKit
import UniformTypeIdentifiers

// MARK: - Dashboard CSV Integration

extension SimpleDashboard {
    
    // MARK: - Import CSV UI
    
    func setupCSVImportButton() {
        let importButton = UIButton(type: .system)
        importButton.setTitle("Import Session", for: .normal)
        importButton.setImage(UIImage(systemName: "arrow.down.doc"), for: .normal)
        importButton.backgroundColor = FocusCalendarTheme.accentGold.withAlphaComponent(0.1)
        importButton.layer.cornerRadius = 12
        importButton.titleLabel?.font = FocusCalendarTheme.Fonts.bodyFont(size: 14)
        importButton.tintColor = FocusCalendarTheme.accentGold
        importButton.addTarget(self, action: #selector(importCSVTapped), for: .touchUpInside)
        importButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: importButton)
        
        NSLayoutConstraint.activate([
            importButton.widthAnchor.constraint(equalToConstant: 120),
            importButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func importCSVTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        let viewController = self.navigationController ?? self
        viewController.present(documentPicker, animated: true)
    }
    
    // MARK: - CSV Analysis Display
    
    func displayDetailedAnalysis(_ metrics: CSVAnalyzer.DetailedMetrics) {
        // Create a comprehensive analysis view
        let analysisView = CSVAnalysisView(metrics: metrics)
        analysisView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view hierarchy
        view.addSubview(analysisView)
        
        NSLayoutConstraint.activate([
            analysisView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            analysisView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            analysisView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        // Animate in
        analysisView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            analysisView.alpha = 1
        }
    }
}

// MARK: - Document Picker Delegate

extension SimpleDashboard: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Security scoped resource
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let csvData = try Data(contentsOf: url)
            
            // Analyze the CSV
            if let metrics = CSVAnalyzer.analyzeCSVData(csvData) {
                displayDetailedAnalysis(metrics)
                
                // Optionally save to Core Data for comparison
                saveImportedSession(metrics: metrics, csvData: csvData)
            } else {
                showImportError("Unable to analyze CSV data")
            }
            
        } catch {
            showImportError("Failed to read file: \(error.localizedDescription)")
        }
    }
    
    private func showImportError(_ message: String) {
        let alert = UIAlertController(title: "Import Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        let viewController = self.navigationController ?? self
        viewController.present(alert, animated: true)
    }
    
    private func saveImportedSession(metrics: CSVAnalyzer.DetailedMetrics, csvData: Data) {
        // Save key metrics to Core Data for comparison
        // This allows comparing imported sessions with live sessions
        
        AnalyticsManager.shared.recordImportedSession(
            duration: metrics.totalDuration,
            balancePercentage: metrics.balancePercentage,
            pushFrequency: metrics.pushFrequency,
            dominantPattern: metrics.dominantPushPattern
        )
    }
}

// MARK: - CSV Analysis View

class CSVAnalysisView: UIView {
    
    private let metrics: CSVAnalyzer.DetailedMetrics
    
    init(metrics: CSVAnalyzer.DetailedMetrics) {
        self.metrics = metrics
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = FocusCalendarTheme.cardBackgroundColor
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Imported Session Analysis"
        titleLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 20)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        stackView.addArrangedSubview(titleLabel)
        
        // Key metrics grid
        let gridView = createMetricsGrid()
        stackView.addArrangedSubview(gridView)
        
        // Pattern analysis
        let patternView = createPatternAnalysis()
        stackView.addArrangedSubview(patternView)
        
        // Comparison button
        let compareButton = UIButton(type: .system)
        compareButton.setTitle("Compare with Current Session", for: .normal)
        compareButton.backgroundColor = FocusCalendarTheme.accentGold
        compareButton.setTitleColor(.white, for: .normal)
        compareButton.layer.cornerRadius = 8
        compareButton.titleLabel?.font = FocusCalendarTheme.Fonts.bodyFont(size: 16)
        compareButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        compareButton.addTarget(self, action: #selector(compareTapped), for: .touchUpInside)
        stackView.addArrangedSubview(compareButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    private func createMetricsGrid() -> UIView {
        let gridContainer = UIView()
        
        let metricsData = [
            ("Duration", formatDuration(metrics.totalDuration)),
            ("Balance %", String(format: "%.1f%%", metrics.balancePercentage)),
            ("Total Pushes", "\(metrics.totalPushes)"),
            ("Push Rate", String(format: "%.1f/s", metrics.pushFrequency)),
            ("Recovery Speed", String(format: "%.1fs", metrics.recoverySpeed)),
            ("Micro Adjust", String(format: "%.0f%%", metrics.microAdjustmentRatio * 100))
        ]
        
        let columns = 2
        let rows = (metricsData.count + columns - 1) / columns
        
        for (index, (title, value)) in metricsData.enumerated() {
            let metricView = createMetricCard(title: title, value: value)
            metricView.translatesAutoresizingMaskIntoConstraints = false
            gridContainer.addSubview(metricView)
            
            let row = index / columns
            let col = index % columns
            
            NSLayoutConstraint.activate([
                metricView.leadingAnchor.constraint(
                    equalTo: col == 0 ? gridContainer.leadingAnchor : gridContainer.centerXAnchor,
                    constant: col == 0 ? 0 : 8
                ),
                metricView.trailingAnchor.constraint(
                    equalTo: col == 0 ? gridContainer.centerXAnchor : gridContainer.trailingAnchor,
                    constant: col == 0 ? -8 : 0
                ),
                metricView.topAnchor.constraint(
                    equalTo: row == 0 ? gridContainer.topAnchor : gridContainer.topAnchor,
                    constant: CGFloat(row * 80)
                ),
                metricView.heightAnchor.constraint(equalToConstant: 70)
            ])
        }
        
        gridContainer.heightAnchor.constraint(equalToConstant: CGFloat(rows * 80 - 10)).isActive = true
        
        return gridContainer
    }
    
    private func createMetricCard(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        card.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 12)
        titleLabel.textColor = FocusCalendarTheme.secondaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 18)
        valueLabel.textColor = FocusCalendarTheme.primaryTextColor
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12)
        ])
        
        return card
    }
    
    private func createPatternAnalysis() -> UIView {
        let container = UIView()
        container.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        container.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = "Control Pattern"
        titleLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 14)
        titleLabel.textColor = FocusCalendarTheme.secondaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let patternLabel = UILabel()
        patternLabel.text = metrics.dominantPushPattern.capitalized
        patternLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 24)
        patternLabel.textColor = FocusCalendarTheme.accentGold
        patternLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let rhythmLabel = UILabel()
        rhythmLabel.text = "Rhythmicity: \(Int(metrics.pushRhythmicity * 100))%"
        rhythmLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 12)
        rhythmLabel.textColor = FocusCalendarTheme.secondaryTextColor
        rhythmLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(patternLabel)
        container.addSubview(rhythmLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            patternLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            patternLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            rhythmLabel.topAnchor.constraint(equalTo: patternLabel.bottomAnchor, constant: 8),
            rhythmLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            rhythmLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            container.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        return container
    }
    
    @objc private func compareTapped() {
        // Implement comparison view
        NotificationCenter.default.post(
            name: Notification.Name("ShowSessionComparison"),
            object: nil,
            userInfo: ["metrics": metrics]
        )
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Analytics Manager Extension

extension AnalyticsManager {
    
    func recordImportedSession(
        duration: TimeInterval,
        balancePercentage: Double,
        pushFrequency: Double,
        dominantPattern: String
    ) {
        // Save to Core Data for comparison purposes
        // This could create a special "ImportedSession" entity
        
        // Save to Core Data for comparison purposes
        // This would need a Core Data entity defined
        /*
        let context = persistentContainer.viewContext
        
        // Create imported session record
        // This would need a Core Data entity defined
        
        do {
            try context.save()
        } catch {
            print("Failed to save imported session: \(error)")
        }
        */
    }
}

// MARK: - Firebase Integration

/* Uncomment when Firebase Storage is added
extension GameplayDataUploader {
    
    /// Upload with user consent and options
    func presentUploadOptions(
        for package: BalanceDataExporter.ExportPackage,
        from viewController: UIViewController
    ) {
        let alert = UIAlertController(
            title: "Share Gameplay Data",
            message: "Help improve The Pendulum by sharing anonymized gameplay data",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Share Anonymously", style: .default) { _ in
            let config = UploadConfig(
                includeRawCSV: true,
                includeAnalysis: true,
                includeVisualization: false,
                anonymize: true,
                compress: true
            )
            
            self.uploadGameplayData(package: package, config: config) { result in
                switch result {
                case .success(let sessionId):
                    print("Successfully uploaded session: \(sessionId)")
                case .failure(let error):
                    print("Upload failed: \(error)")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Share with Account", style: .default) { _ in
            let config = UploadConfig(
                includeRawCSV: true,
                includeAnalysis: true,
                includeVisualization: true,
                anonymize: false,
                compress: true
            )
            
            self.uploadGameplayData(package: package, config: config) { result in
                switch result {
                case .success(let sessionId):
                    print("Successfully uploaded session with account: \(sessionId)")
                case .failure(let error):
                    print("Upload failed: \(error)")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Don't Share", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
}
*/