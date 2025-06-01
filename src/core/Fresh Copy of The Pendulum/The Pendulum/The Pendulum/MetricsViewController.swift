import UIKit

class MetricsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let metricsOptions = ["Basic", "Advanced", "Scientific", "Educational", "Topology", "Performance"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Metrics"
        view.backgroundColor = .goldenBackground
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.goldenPrimary.withAlphaComponent(0.3)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MetricsCell")
        
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

extension MetricsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricsCell", for: indexPath)
        let option = metricsOptions[indexPath.row]
        
        cell.textLabel?.text = option
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Add checkmark if this is the current selection
        let currentMetrics = SettingsManager.shared.metrics
        if option == currentMetrics {
            cell.accessoryType = .checkmark
            cell.tintColor = .goldenPrimary
        } else {
            cell.accessoryType = .none
        }
        
        // Add disclosure indicator
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .secondaryLabel
        cell.accessoryView = cell.accessoryType == .checkmark ? nil : chevron
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MetricsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedOption = metricsOptions[indexPath.row]
        
        // Update settings
        SettingsManager.shared.metrics = selectedOption
        
        // Refresh table to show new selection
        tableView.reloadData()
        
        // Show feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Post notification to update analytics dashboard if needed
        NotificationCenter.default.post(name: Notification.Name("MetricsSettingChanged"), object: selectedOption)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}