import UIKit

class GraphicsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var graphicsOptions: [(title: String, subtitle: String, isAvailable: Bool, isSelected: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadGraphicsOptions()
    }
    
    private func setupUI() {
        title = "Graphics"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GraphicsCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadGraphicsOptions() {
        let currentGraphics = SettingsManager.shared.graphics
        
        graphicsOptions = [
            (title: "Golden Theme", 
             subtitle: "Current implementation", 
             isAvailable: true,
             isSelected: currentGraphics == "Golden Theme" || currentGraphics == "Standard"),
            
            (title: "High Definition", 
             subtitle: "Coming Soon - Enhanced visuals", 
             isAvailable: false,
             isSelected: false),
            
            (title: "Low Power", 
             subtitle: "Coming Soon - Battery saver mode", 
             isAvailable: false,
             isSelected: false),
            
            (title: "Neon", 
             subtitle: "Coming Soon - Vibrant neon style", 
             isAvailable: false,
             isSelected: false),
            
            (title: "Minimal", 
             subtitle: "Coming Soon - Clean aesthetics", 
             isAvailable: false,
             isSelected: false),
            
            (title: "Dark Matter", 
             subtitle: "Coming Soon - Deep space theme", 
             isAvailable: false,
             isSelected: false)
        ]
        
        tableView.reloadData()
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension GraphicsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graphicsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraphicsCell", for: indexPath)
        let option = graphicsOptions[indexPath.row]
        
        var config = UIListContentConfiguration.subtitleCell()
        config.text = option.title
        config.secondaryText = option.subtitle
        config.textProperties.font = .systemFont(ofSize: 17)
        config.secondaryTextProperties.font = .systemFont(ofSize: 13)
        
        if option.isAvailable {
            config.textProperties.color = .label
            config.secondaryTextProperties.color = .secondaryLabel
            cell.selectionStyle = .default
            cell.accessoryType = option.isSelected ? .checkmark : .none
        } else {
            config.textProperties.color = .tertiaryLabel
            config.secondaryTextProperties.color = .tertiaryLabel
            cell.selectionStyle = .none
            cell.accessoryType = .none
            
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
            
            cell.accessoryView = containerView
        }
        
        cell.contentConfiguration = config
        cell.tintColor = .systemBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Visual Themes"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Choose a graphics theme for your pendulum. More themes will be available in future updates."
    }
}

// MARK: - UITableViewDelegate

extension GraphicsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = graphicsOptions[indexPath.row]
        
        if option.isAvailable {
            // Update selection
            for i in 0..<graphicsOptions.count {
                graphicsOptions[i].isSelected = (i == indexPath.row)
            }
            
            // Update settings
            SettingsManager.shared.graphics = option.title
            
            // Refresh table to show new selection
            tableView.reloadData()
            
            // Show feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            // Post notification to update graphics settings if needed
            NotificationCenter.default.post(name: Notification.Name("GraphicsSettingChanged"), object: option.title)
        } else {
            // Show coming soon alert
            showComingSoonAlert(for: "\(option.title) theme")
        }
    }
}