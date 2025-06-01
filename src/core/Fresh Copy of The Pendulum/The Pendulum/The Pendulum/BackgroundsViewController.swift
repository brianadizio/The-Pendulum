import UIKit

class BackgroundsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let backgroundOptions = BackgroundManager.BackgroundFolder.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Backgrounds"
        view.backgroundColor = .goldenBackground
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.goldenPrimary.withAlphaComponent(0.3)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BackgroundCell")
        
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

extension BackgroundsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backgroundOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundCell", for: indexPath)
        let option = backgroundOptions[indexPath.row]
        
        cell.textLabel?.text = option.rawValue
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Add checkmark if this is the current selection
        let currentBackground = SettingsManager.shared.backgrounds
        if option.rawValue == currentBackground {
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

extension BackgroundsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedOption = backgroundOptions[indexPath.row]
        
        // Update settings
        SettingsManager.shared.backgrounds = selectedOption.rawValue
        
        // Apply the background change
        BackgroundManager.shared.updateBackgroundMode(selectedOption.rawValue)
        
        // Refresh table to show new selection
        tableView.reloadData()
        
        // Show feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}