import UIKit

class BackgroundsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var backgroundOptions: [(title: String, subtitle: String, isSelected: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBackgroundOptions()
    }
    
    private func setupUI() {
        title = "Backgrounds"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BackgroundCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadBackgroundOptions() {
        let currentBackground = SettingsManager.shared.backgrounds
        
        // Map BackgroundManager options to display format
        backgroundOptions = BackgroundManager.BackgroundFolder.allCases.map { folder in
            let title = folder.rawValue
            let subtitle: String
            
            switch folder {
            case .none:
                subtitle = "No background theme"
            case .ai:
                subtitle = "AI-generated backgrounds"
            case .acadia:
                subtitle = "Acadia National Park scenery"
            case .fluid:
                subtitle = "Fluid dynamics patterns"
            case .immersiveTopology:
                subtitle = "Immersive topology visualizations"
            case .joshuaTree:
                subtitle = "Joshua Tree desert landscapes"
            case .outerSpace:
                subtitle = "Cosmic space backgrounds"
            case .parchment:
                subtitle = "Classic parchment textures"
            case .sachuest:
                subtitle = "Sachuest Point scenery"
            case .theMazeGuide:
                subtitle = "The Maze Guide artwork"
            case .thePortraits:
                subtitle = "Portrait collection"
            case .tsp:
                subtitle = "TSP mathematical patterns"
            }
            
            return (title: title, subtitle: subtitle, isSelected: title == currentBackground)
        }
        
        tableView.reloadData()
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension BackgroundsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backgroundOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundCell", for: indexPath)
        let option = backgroundOptions[indexPath.row]
        
        var config = UIListContentConfiguration.subtitleCell()
        config.text = option.title
        config.secondaryText = option.subtitle
        config.textProperties.font = .systemFont(ofSize: 17)
        config.secondaryTextProperties.font = .systemFont(ofSize: 13)
        config.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = config
        cell.accessoryType = option.isSelected ? .checkmark : .none
        cell.tintColor = .systemBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose Background Theme"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Select a background theme for your pendulum simulation. Some themes may affect performance on older devices."
    }
}

// MARK: - UITableViewDelegate

extension BackgroundsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Update selection
        for i in 0..<backgroundOptions.count {
            backgroundOptions[i].isSelected = (i == indexPath.row)
        }
        
        let selectedOption = backgroundOptions[indexPath.row].title
        
        // Update settings
        SettingsManager.shared.backgrounds = selectedOption
        
        // Apply the background change
        BackgroundManager.shared.updateBackgroundMode(selectedOption)
        
        // Refresh table to show new selection
        tableView.reloadData()
        
        // Show feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}