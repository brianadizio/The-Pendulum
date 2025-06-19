import UIKit

class GameControlsViewController: UIViewController {
  
  // MARK: - Properties
  private let tableView = UITableView(frame: .zero, style: .insetGrouped)
  private var controlOptions: [(title: String, subtitle: String, isSelected: Bool)] = []
  private var sensitivityValue: Float = 0.5
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    loadControlSettings()
  }
  
  // MARK: - Setup
  private func setupUI() {
    title = "Game Controls"
    view.backgroundColor = .systemGroupedBackground
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(doneTapped)
    )
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ControlCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func loadControlSettings() {
    let defaults = UserDefaults.standard
    sensitivityValue = defaults.float(forKey: "controlSensitivity")
    if sensitivityValue == 0 { sensitivityValue = 0.5 } // Default value
    
    let currentControl = SettingsManager.shared.gameControls
    
    controlOptions = [
      (title: "Push", 
       subtitle: "Push the pendulum with touch",
       isSelected: currentControl == "Push"),
      
      (title: "Gyroscope", 
       subtitle: "Tilt device to control pendulum",
       isSelected: currentControl == "Gyroscope"),
      
      (title: "Slide", 
       subtitle: "Slide finger to apply force",
       isSelected: currentControl == "Slide"),
      
      (title: "Tap", 
       subtitle: "Tap to apply impulse",
       isSelected: currentControl == "Tap"),
      
      (title: "Swipe", 
       subtitle: "Swipe gestures for control",
       isSelected: currentControl == "Swipe"),
      
      (title: "Tilt", 
       subtitle: "Tilt device to change gravity",
       isSelected: currentControl == "Tilt")
    ]
    
    tableView.reloadData()
  }
  
  // MARK: - Actions
  @objc private func doneTapped() {
    dismiss(animated: true)
  }
}

// MARK: - UITableViewDataSource
extension GameControlsViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return controlOptions.count // Control methods
    case 1:
      return 1 // Sensitivity slider
    case 2:
      return 1 // Reset button
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ControlCell", for: indexPath)
    
    switch indexPath.section {
    case 0:
      // Control method options
      let option = controlOptions[indexPath.row]
      
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
      // Sensitivity slider
      var config = UIListContentConfiguration.cell()
      config.text = "Touch Sensitivity"
      config.textProperties.font = .systemFont(ofSize: 17)
      
      let slider = UISlider()
      slider.minimumValue = 0.1
      slider.maximumValue = 1.0
      slider.value = sensitivityValue
      slider.addTarget(self, action: #selector(sensitivityChanged(_:)), for: .valueChanged)
      slider.translatesAutoresizingMaskIntoConstraints = false
      
      let containerView = UIView()
      containerView.addSubview(slider)
      
      NSLayoutConstraint.activate([
        slider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        slider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        slider.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        slider.widthAnchor.constraint(equalToConstant: 200)
      ])
      
      cell.contentConfiguration = config
      cell.accessoryView = containerView
      
    case 2:
      // Reset button
      var config = UIListContentConfiguration.cell()
      config.text = "Reset Control Settings"
      config.textProperties.color = .systemRed
      config.textProperties.alignment = .center
      config.textProperties.font = .systemFont(ofSize: 17)
      
      cell.contentConfiguration = config
      cell.accessoryView = nil
      
    default:
      break
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Control Method"
    case 1:
      return "Sensitivity"
    case 2:
      return nil
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Choose how you want to interact with the pendulum."
    case 1:
      return "Adjust how responsive the pendulum is to your input."
    default:
      return nil
    }
  }
  
  @objc private func sensitivityChanged(_ sender: UISlider) {
    sensitivityValue = sender.value
    UserDefaults.standard.set(sender.value, forKey: "controlSensitivity")
    
    // Post notification for sensitivity change
    NotificationCenter.default.post(
      name: Notification.Name("ControlSensitivityChanged"),
      object: nil,
      userInfo: ["sensitivity": sender.value]
    )
  }
  
}

// MARK: - UITableViewDelegate
extension GameControlsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.section {
    case 0:
      // Control method selection
      for i in 0..<controlOptions.count {
        controlOptions[i].isSelected = (i == indexPath.row)
      }
      
      let selectedOption = controlOptions[indexPath.row].title
      
      // Update settings
      SettingsManager.shared.gameControls = selectedOption
      
      // Refresh table to show new selection
      tableView.reloadData()
      
      // Show feedback
      let impact = UIImpactFeedbackGenerator(style: .light)
      impact.impactOccurred()
      
      // Post notification
      NotificationCenter.default.post(name: Notification.Name("GameControlsChanged"), object: nil)
      
    case 2:
      // Reset controls
      let alert = UIAlertController(
        title: "Reset Control Settings?",
        message: "This will restore all control settings to their default values.",
        preferredStyle: .alert
      )
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
        // Reset all control settings
        UserDefaults.standard.set(0.5, forKey: "controlSensitivity")
        SettingsManager.shared.gameControls = "Push" // Default control method
        
        // Reload settings and table
        self.loadControlSettings()
        self.tableView.reloadData()
        
        // Show confirmation
        let confirmAlert = UIAlertController(
          title: "Settings Reset",
          message: "Control settings have been restored to defaults.",
          preferredStyle: .alert
        )
        confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(confirmAlert, animated: true)
        
        // Post notification
        NotificationCenter.default.post(name: Notification.Name("GameControlsChanged"), object: nil)
      })
      
      present(alert, animated: true)
      
    default:
      break
    }
  }
}