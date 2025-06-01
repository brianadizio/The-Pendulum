import UIKit

class SoundsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let soundOptions = ["Standard", "Music", "Immersive", "Minimal", "Silent"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Sounds"
        view.backgroundColor = .goldenBackground
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.goldenPrimary.withAlphaComponent(0.3)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SoundCell")
        
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

extension SoundsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
        let option = soundOptions[indexPath.row]
        
        cell.textLabel?.text = option
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Add checkmark if this is the current selection
        let currentSound = SettingsManager.shared.sounds
        if option == currentSound {
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

extension SoundsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedOption = soundOptions[indexPath.row]
        
        // Update settings
        SettingsManager.shared.sounds = selectedOption
        
        // Apply the sound change
        PendulumSoundManager.shared.updateSoundMode(selectedOption)
        
        // Refresh table to show new selection
        tableView.reloadData()
        
        // Show feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Play a test sound to demonstrate the change
        PendulumSoundManager.shared.playButtonTapSound()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}