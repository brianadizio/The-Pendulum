import UIKit

class SoundsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var soundOptions: [(title: String, subtitle: String, isSelected: Bool)] = []
    private var hapticFeedbackEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSoundOptions()
    }
    
    private func setupUI() {
        title = "Sounds"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SoundCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadSoundOptions() {
        let currentSound = SettingsManager.shared.sounds
        hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
        if !UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") {
            // Default to true if not set
            hapticFeedbackEnabled = true
            UserDefaults.standard.set(true, forKey: "hapticFeedbackEnabled")
        }
        
        soundOptions = [
            (title: "Standard", 
             subtitle: "Default sound effects", 
             isSelected: currentSound == "Standard"),
            
            (title: "Music", 
             subtitle: "Melodic background music", 
             isSelected: currentSound == "Music"),
            
            (title: "Immersive", 
             subtitle: "Rich spatial audio effects", 
             isSelected: currentSound == "Immersive"),
            
            (title: "Minimal", 
             subtitle: "Subtle notification sounds only", 
             isSelected: currentSound == "Minimal"),
            
            (title: "Silent", 
             subtitle: "No sounds at all", 
             isSelected: currentSound == "Silent")
        ]
        
        tableView.reloadData()
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SoundsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return soundOptions.count
        case 1:
            return 1 // Haptic feedback toggle only
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            // Sound theme options
            let option = soundOptions[indexPath.row]
            
            var config = UIListContentConfiguration.subtitleCell()
            config.text = option.title
            config.secondaryText = option.subtitle
            config.textProperties.font = .systemFont(ofSize: 17)
            config.secondaryTextProperties.font = .systemFont(ofSize: 13)
            config.secondaryTextProperties.color = .secondaryLabel
            
            cell.contentConfiguration = config
            cell.accessoryType = option.isSelected ? .checkmark : .none
            cell.tintColor = .systemBlue
            
        case 1:
            // Haptic feedback toggle
            var config = UIListContentConfiguration.cell()
            config.text = "Haptic Feedback"
            config.textProperties.font = .systemFont(ofSize: 17)
            
            let toggle = UISwitch()
            toggle.isOn = hapticFeedbackEnabled
            toggle.addTarget(self, action: #selector(hapticFeedbackToggled(_:)), for: .valueChanged)
            
            cell.contentConfiguration = config
            cell.accessoryView = toggle
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Sound Theme"
        case 1:
            return "Feedback"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Choose a sound theme that matches your preference. Volume is controlled by your device's volume settings."
        case 1:
            return "Enable haptic feedback for touch interactions."
        default:
            return nil
        }
    }
    
    @objc private func hapticFeedbackToggled(_ sender: UISwitch) {
        hapticFeedbackEnabled = sender.isOn
        UserDefaults.standard.set(sender.isOn, forKey: "hapticFeedbackEnabled")
        
        if sender.isOn {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
}

// MARK: - UITableViewDelegate

extension SoundsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            // Update selection
            for i in 0..<soundOptions.count {
                soundOptions[i].isSelected = (i == indexPath.row)
            }
            
            let selectedOption = soundOptions[indexPath.row].title
            
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
    }
}