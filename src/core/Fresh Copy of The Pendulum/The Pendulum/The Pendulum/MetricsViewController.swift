import UIKit

class MetricsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var metricsOptions: [(title: String, subtitle: String, isAvailable: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMetricsOptions()
    }
    
    private func setupUI() {
        title = "Metrics"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MetricsCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadMetricsOptions() {
        // All metrics are coming soon
        metricsOptions = [
            (title: "Energy Tracking", 
             subtitle: "Monitor kinetic and potential energy",
             isAvailable: false),
            
            (title: "Phase Space Analysis", 
             subtitle: "Track position and velocity relationships",
             isAvailable: false),
            
            (title: "Chaos Detection", 
             subtitle: "Calculate Lyapunov exponents",
             isAvailable: false),
            
            (title: "Statistical Analysis", 
             subtitle: "Mean, variance, and distribution",
             isAvailable: false),
            
            (title: "Frequency Spectrum", 
             subtitle: "FFT analysis of pendulum motion",
             isAvailable: false),
            
            (title: "Real-time Graphs", 
             subtitle: "Display live metric visualizations",
             isAvailable: false)
        ]
        
        tableView.reloadData()
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MetricsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricsCell", for: indexPath)
        let option = metricsOptions[indexPath.row]
        
        var config = UIListContentConfiguration.subtitleCell()
        config.text = option.title
        config.secondaryText = option.subtitle
        config.textProperties.font = .systemFont(ofSize: 17)
        config.secondaryTextProperties.font = .systemFont(ofSize: 13)
        
        // Style for coming soon
        config.textProperties.color = .tertiaryLabel
        config.secondaryTextProperties.color = .tertiaryLabel
        cell.selectionStyle = .none
        
        // Add "Coming Soon" badge
        let badge = UILabel()
        badge.text = "SOON"
        badge.font = .systemFont(ofSize: 11, weight: .semibold)
        badge.textColor = .systemOrange
        badge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        badge.layer.cornerRadius = 4
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.addSubview(badge)
        
        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            badge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            badge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 45),
            badge.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        cell.contentConfiguration = config
        cell.accessoryView = containerView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Analytics Options"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Advanced metrics and analytics features will be available in a future update."
    }
}

// MARK: - UITableViewDelegate

extension MetricsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show coming soon alert
        let option = metricsOptions[indexPath.row]
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "\(option.title) will be available in a future update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}