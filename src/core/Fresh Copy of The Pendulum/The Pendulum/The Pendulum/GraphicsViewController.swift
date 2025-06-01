import UIKit

class GraphicsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let graphicsOptions = ["Standard", "High Definition", "Low Power", "Simplified", "Detailed", "Experimental"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Graphics"
        view.backgroundColor = .goldenBackground
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.goldenPrimary.withAlphaComponent(0.3)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GraphicsCell")
        
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

extension GraphicsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graphicsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraphicsCell", for: indexPath)
        let option = graphicsOptions[indexPath.row]
        
        cell.textLabel?.text = option
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Add checkmark if this is the current selection
        let currentGraphics = SettingsManager.shared.graphics
        if option == currentGraphics {
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

extension GraphicsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedOption = graphicsOptions[indexPath.row]
        
        // Update settings
        SettingsManager.shared.graphics = selectedOption
        
        // Refresh table to show new selection
        tableView.reloadData()
        
        // Show feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Post notification to update graphics settings if needed
        NotificationCenter.default.post(name: Notification.Name("GraphicsSettingChanged"), object: selectedOption)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}