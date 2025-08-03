import UIKit

/// Developer Tool: Particle Effects Test View Controller
/// Displays victory particle effects every 2 seconds after an initial 2-second delay
class ParticleTestViewController: UIViewController {
  
  // MARK: - Properties
  private var particleTimer: Timer?
  private let startDelay: TimeInterval = 2.0
  private let repeatInterval: TimeInterval = 2.0
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    startParticleDemo()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopParticleDemo()
  }
  
  deinit {
    stopParticleDemo()
  }
  
  // MARK: - UI Setup
  
  private func setupUI() {
    // Set plain white background
    view.backgroundColor = UIColor.white
    
    // Add title label for developer tool
    let titleLabel = UILabel()
    titleLabel.text = "Particle Effects Test"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
    titleLabel.textColor = UIColor.black
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    let subtitleLabel = UILabel()
    subtitleLabel.text = "Victory particle effects repeat every 2 seconds"
    subtitleLabel.font = UIFont.systemFont(ofSize: 16)
    subtitleLabel.textColor = UIColor.darkGray
    subtitleLabel.textAlignment = .center
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    
    // Set up constraints
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
      
      subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
    ])
    
    // Add close button
    let closeButton = UIButton(type: .system)
    closeButton.setTitle("Close", for: .normal)
    closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(closeButton)
    
    NSLayoutConstraint.activate([
      closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
    ])
  }
  
  // MARK: - Particle Demo Control
  
  private func startParticleDemo() {
    // Initial delay, then start repeating timer
    DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) { [weak self] in
      self?.triggerVictoryParticles()
      self?.startRepeatingTimer()
    }
  }
  
  private func startRepeatingTimer() {
    particleTimer = Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: true) { [weak self] _ in
      self?.triggerVictoryParticles()
    }
  }
  
  private func stopParticleDemo() {
    particleTimer?.invalidate()
    particleTimer = nil
  }
  
  private func triggerVictoryParticles() {
    // Use the same level completion celebration effect from the main game
    ViewControllerParticleSystem.createAchievementCelebration(in: view)
  }
  
  // MARK: - Actions
  
  @objc private func closeButtonTapped() {
    dismiss(animated: true)
  }
}