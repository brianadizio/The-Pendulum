import UIKit
import SpriteKit
import QuartzCore

class PendulumViewController: UIViewController, UITabBarDelegate {
    
    private let viewModel = PendulumViewModel()
    private var scene: PendulumScene?
    
    // Tab bar for navigation
    private let tabBar = UITabBar()
    private let simulationItem = UITabBarItem(title: "Simulation", image: UIImage(systemName: "waveform.path"), tag: 0)
    private let parametersItem = UITabBarItem(title: "Parameters", image: UIImage(systemName: "slider.horizontal.3"), tag: 1)
    private let infoItem = UITabBarItem(title: "Info", image: UIImage(systemName: "info.circle"), tag: 2)
    
    // Views for different tabs
    private let simulationView = UIView()
    private let parametersView = UIView()
    private let infoView = UIView()
    private var currentView: UIView?
    
    // Parameter controls
    private let massSlider = UISlider()
    private let lengthSlider = UISlider()
    private let dampingSlider = UISlider()
    private let gravitySlider = UISlider()
    private let forceStrengthSlider = UISlider()
    private let initialPerturbationSlider = UISlider()
    
    // Game HUD elements
    private var scoreLabel: UILabel!
    private var timeLabel: UILabel!
    private var gameMessageLabel: UILabel!
    private var hudContainer: UIView!
    private var phaseSpaceView: PhaseSpaceView!
    private var updateTimer: Timer?
    
    // Control buttons
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Balance!", for: .normal) // Changed from "Start" to "Balance!"
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var pushLeftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← Push", for: .normal)
        button.addTarget(self, action: #selector(pushLeftButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var pushRightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Push →", for: .normal)
        button.addTarget(self, action: #selector(pushRightButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the main interface
        setupTabBar()
        setupViews()
        
        // Start with simulation view
        showView(simulationView)
    }
    
    private func setupTabBar() {
        // Configure tab bar
        tabBar.delegate = self
        tabBar.items = [simulationItem, parametersItem, infoItem]
        tabBar.selectedItem = simulationItem
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tab bar to view
        view.addSubview(tabBar)
        
        // Position tab bar at bottom of screen
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupViews() {
        // Setup all three views
        setupSimulationView()
        setupParametersView()
        setupInfoView()
        
        // Add views to main view
        [simulationView, parametersView, infoView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
            
            // Position each view to fill the space above the tab bar
            NSLayoutConstraint.activate([
                subview.topAnchor.constraint(equalTo: view.topAnchor),
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
            ])
            
            // Hide all views initially
            subview.isHidden = true
        }
    }
    
    private func setupSimulationView() {
        // Set background color
        simulationView.backgroundColor = .white
        
        // Create a container for the SpriteKit view with proper constraints
        let skViewContainer = UIView()
        skViewContainer.translatesAutoresizingMaskIntoConstraints = false
        skViewContainer.backgroundColor = .white
        simulationView.addSubview(skViewContainer)
        
        // Position the SKView container to take most of the screen space
        // Leave space at the bottom for controls
        NSLayoutConstraint.activate([
            skViewContainer.topAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.topAnchor, constant: 100),
            skViewContainer.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor),
            skViewContainer.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor),
            skViewContainer.heightAnchor.constraint(equalTo: simulationView.heightAnchor, multiplier: 0.5)
        ])
        
        // Add the SpriteKit view
        let skView = SKView(frame: .zero)
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.backgroundColor = .white
        skViewContainer.addSubview(skView)
        
        // Make the SKView fill its container
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: skViewContainer.topAnchor),
            skView.leadingAnchor.constraint(equalTo: skViewContainer.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: skViewContainer.trailingAnchor),
            skView.bottomAnchor.constraint(equalTo: skViewContainer.bottomAnchor)
        ])
        
        // Configure the SpriteKit view
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        // Add a border to the SKView for visibility
        skView.layer.borderColor = UIColor.lightGray.cgColor
        skView.layer.borderWidth = 1.0
        
        // Wait for the view to layout before creating the scene
        DispatchQueue.main.async {
            // Create and present the pendulum scene once view is sized
            let sceneSize = skView.bounds.size
            print("Creating scene with size: \(sceneSize)")
            
            self.scene = PendulumScene(size: sceneSize)
            self.scene?.scaleMode = .aspectFill
            self.scene?.viewModel = self.viewModel
            self.scene?.backgroundColor = .white
            
            // Set the scene in the viewModel for bidirectional communication
            self.viewModel.scene = self.scene
            
            // Present the scene
            if let theScene = self.scene {
                skView.presentScene(theScene, transition: SKTransition.fade(withDuration: 0.5))
                print("Scene presented. SKView size: \(skView.bounds.size)")
            }
        }
        
        // Add control buttons
        setupSimulationControls(in: simulationView)
        
        // Setup game HUD
        setupGameHUD()
        
        // Setup phase space view
        setupPhaseSpaceView()
    }
    
    private func setupParametersView() {
        // Set background
        parametersView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        
        // Create a title label
        let titleLabel = UILabel()
        titleLabel.text = "Pendulum Parameters"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        parametersView.addSubview(titleLabel)
        
        // Configure sliders
        let sliders = [massSlider, lengthSlider, dampingSlider, gravitySlider, forceStrengthSlider, initialPerturbationSlider]
        let sliderTitles = ["Mass", "Length", "Damping", "Gravity", "Force Strength", "Initial Perturbation"]
        
        // Create a container for parameter controls
        let parametersContainer = UIView()
        parametersContainer.backgroundColor = .white
        parametersContainer.layer.cornerRadius = 16
        parametersContainer.layer.shadowColor = UIColor.black.cgColor
        parametersContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        parametersContainer.layer.shadowOpacity = 0.1
        parametersContainer.layer.shadowRadius = 4
        parametersContainer.translatesAutoresizingMaskIntoConstraints = false
        parametersView.addSubview(parametersContainer)
        
        // Create a stack for all parameter controls
        let parametersStack = UIStackView()
        parametersStack.axis = .vertical
        parametersStack.spacing = 20
        parametersStack.distribution = .fillEqually
        parametersStack.translatesAutoresizingMaskIntoConstraints = false
        parametersContainer.addSubview(parametersStack)
        
        // Add each parameter slider with label and value
        for (index, slider) in sliders.enumerated() {
            let sliderContainer = createParameterControl(
                title: sliderTitles[index],
                slider: slider
            )
            parametersStack.addArrangedSubview(sliderContainer)
        }
        
        // Add reset button
        let resetContainer = UIView()
        resetContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Style the reset button
        resetButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
        resetButton.setTitleColor(UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0), for: .normal)
        resetButton.layer.cornerRadius = 10
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0).cgColor
        
        resetContainer.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resetButton.centerXAnchor.constraint(equalTo: resetContainer.centerXAnchor),
            resetButton.centerYAnchor.constraint(equalTo: resetContainer.centerYAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        parametersStack.addArrangedSubview(resetContainer)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: parametersView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor, constant: -20),
            
            // Parameters container
            parametersContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            parametersContainer.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor, constant: 20),
            parametersContainer.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor, constant: -20),
            parametersContainer.bottomAnchor.constraint(lessThanOrEqualTo: parametersView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Parameters stack
            parametersStack.topAnchor.constraint(equalTo: parametersContainer.topAnchor, constant: 20),
            parametersStack.leadingAnchor.constraint(equalTo: parametersContainer.leadingAnchor, constant: 20),
            parametersStack.trailingAnchor.constraint(equalTo: parametersContainer.trailingAnchor, constant: -20),
            parametersStack.bottomAnchor.constraint(equalTo: parametersContainer.bottomAnchor, constant: -20)
        ])
        
        // Set up initial slider values based on viewModel
        massSlider.minimumValue = 0.1
        massSlider.maximumValue = 10.0
        massSlider.value = Float(viewModel.mass)
        
        lengthSlider.minimumValue = 0.1
        lengthSlider.maximumValue = 5.0
        lengthSlider.value = Float(viewModel.length)
        
        dampingSlider.minimumValue = 0.0
        dampingSlider.maximumValue = 2.0
        dampingSlider.value = Float(viewModel.damping)
        
        gravitySlider.minimumValue = 1.0
        gravitySlider.maximumValue = 20.0
        gravitySlider.value = Float(viewModel.gravity)
        
        forceStrengthSlider.minimumValue = 0.1
        forceStrengthSlider.maximumValue = 10.0
        forceStrengthSlider.value = Float(viewModel.forceStrength)
        
        initialPerturbationSlider.minimumValue = 5.0
        initialPerturbationSlider.maximumValue = 50.0
        initialPerturbationSlider.value = Float(viewModel.initialPerturbation)
        
        // Add actions to sliders
        massSlider.addTarget(self, action: #selector(massSliderChanged), for: .valueChanged)
        lengthSlider.addTarget(self, action: #selector(lengthSliderChanged), for: .valueChanged)
        dampingSlider.addTarget(self, action: #selector(dampingSliderChanged), for: .valueChanged)
        gravitySlider.addTarget(self, action: #selector(gravitySliderChanged), for: .valueChanged)
        forceStrengthSlider.addTarget(self, action: #selector(forceStrengthSliderChanged), for: .valueChanged)
        initialPerturbationSlider.addTarget(self, action: #selector(initialPerturbationSliderChanged), for: .valueChanged)
    }
    
    private func setupInfoView() {
        // Set background
        infoView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        
        // Create scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(scrollView)
        
        // Create content view inside scroll view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "About The Pendulum"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Description text
        let descriptionTextView = UITextView()
        descriptionTextView.text = """
        The Pendulum Simulation
        
        This app demonstrates the physics of a pendulum, one of the most fundamental systems in classical mechanics.
        
        A pendulum consists of a mass (the bob) attached to a fixed point by a string or rod. When displaced from equilibrium, gravity causes the pendulum to swing back and forth.
        
        The motion of a pendulum is governed by the following differential equation:
        
        θ'' + (g/L)sin(θ) + b·θ' = 0
        
        Where:
        • θ is the angle from vertical
        • g is the acceleration due to gravity
        • L is the length of the pendulum
        • b is the damping coefficient
        
        Features:
        • Adjust parameters like mass, length, damping, and gravity
        • Apply forces to see how the pendulum responds
        • Observe the pendulum's motion trail
        
        The simulation uses a numerical method called Runge-Kutta (RK4) to solve the equations of motion with high accuracy.
        
        Experiment with different parameters to see how they affect the pendulum's behavior!
        """
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionTextView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: infoView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: infoView.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createParameterControl(title: String, slider: UISlider) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.text = String(format: "%.2f", slider.value)
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textAlignment = .right
        valueLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.6, alpha: 1.0)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        // Store the value label for updates
        slider.tag = Int(bitPattern: Unmanaged.passUnretained(valueLabel).toOpaque())
        
        // Configure slider appearance
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
        slider.thumbTintColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
        container.addSubview(slider)
        
        // Add action to update value label when slider changes
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            // Value
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.widthAnchor.constraint(equalToConstant: 60),
            
            // Slider
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            slider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    // Force layout update
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - View Management
    
    private func showView(_ view: UIView) {
        // Hide all views
        simulationView.isHidden = true
        parametersView.isHidden = true
        infoView.isHidden = true
        
        // Show selected view
        view.isHidden = false
        currentView = view
    }
    
    // MARK: - Simulation Controls
    
    private func setupGameHUD() {
        // Container for game HUD elements
        hudContainer = UIView()
        hudContainer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.85)
        hudContainer.layer.cornerRadius = 16
        hudContainer.layer.shadowColor = UIColor.black.cgColor
        hudContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        hudContainer.layer.shadowOpacity = 0.2
        hudContainer.layer.shadowRadius = 5
        hudContainer.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(hudContainer)
        
        // Score label
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        scoreLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(scoreLabel)
        
        // Time label
        timeLabel = UILabel()
        timeLabel.text = "Time: 0.0s"
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        timeLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(timeLabel)
        
        // Game message label (for game over messages)
        gameMessageLabel = UILabel()
        gameMessageLabel.text = "Balance the Pendulum!"
        gameMessageLabel.textAlignment = .center
        gameMessageLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        gameMessageLabel.textColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        gameMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        gameMessageLabel.isHidden = true
        hudContainer.addSubview(gameMessageLabel)
        
        // Position HUD at top of screen
        NSLayoutConstraint.activate([
            hudContainer.topAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.topAnchor, constant: 90),
            hudContainer.leadingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hudContainer.trailingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: hudContainer.topAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor, constant: 16),
            scoreLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.5, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: hudContainer.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor, constant: -16),
            timeLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.5, constant: -16),
            
            gameMessageLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            gameMessageLabel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor, constant: 16),
            gameMessageLabel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor, constant: -16),
            gameMessageLabel.bottomAnchor.constraint(equalTo: hudContainer.bottomAnchor, constant: -12)
        ])
        
        // Start update timer for HUD
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateGameHUD()
        }
    }
    
    private func setupPhaseSpaceView() {
        // Create phase space view
        phaseSpaceView = PhaseSpaceView(frame: .zero)
        phaseSpaceView.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(phaseSpaceView)
        
        NSLayoutConstraint.activate([
            phaseSpaceView.topAnchor.constraint(equalTo: hudContainer.bottomAnchor, constant: 16),
            phaseSpaceView.leadingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            phaseSpaceView.widthAnchor.constraint(equalToConstant: 150),
            phaseSpaceView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Create a label for it
        let phaseSpaceLabel = UILabel()
        phaseSpaceLabel.text = "Phase Space"
        phaseSpaceLabel.textAlignment = .center
        phaseSpaceLabel.font = UIFont.systemFont(ofSize: 14)
        phaseSpaceLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        phaseSpaceLabel.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(phaseSpaceLabel)
        
        NSLayoutConstraint.activate([
            phaseSpaceLabel.topAnchor.constraint(equalTo: phaseSpaceView.bottomAnchor, constant: 4),
            phaseSpaceLabel.centerXAnchor.constraint(equalTo: phaseSpaceView.centerXAnchor)
        ])
    }

    private func updateGameHUD() {
        scoreLabel.text = "Score: \(viewModel.score)"
        timeLabel.text = String(format: "Time: %.1fs", viewModel.totalBalanceTime)
        
        if !viewModel.isGameActive && viewModel.gameOverReason != nil {
            gameMessageLabel.text = viewModel.gameOverReason
            gameMessageLabel.isHidden = false
            
            // Change Start button to Restart if game is over
            startButton.setTitle("↺ Restart", for: .normal)
        } else {
            gameMessageLabel.isHidden = viewModel.isGameActive
            
            // Change back to Start if game is active or not yet started
            startButton.setTitle("▶ Start", for: .normal)
        }
        
        // Update phase space view
        phaseSpaceView.addPoint(theta: viewModel.currentState.theta, omega: viewModel.currentState.thetaDot)
    }
    
    private func setupSimulationControls(in parentView: UIView) {
        // Create a custom title/header view
        let headerContainer = UIView()
        headerContainer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.85)
        headerContainer.layer.cornerRadius = 10
        headerContainer.layer.shadowColor = UIColor.black.cgColor
        headerContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerContainer.layer.shadowOpacity = 0.2
        headerContainer.layer.shadowRadius = 4
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(headerContainer)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "The Pendulum"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(titleLabel)
        
        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Physics Simulation"
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.6, alpha: 1.0)
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(subtitleLabel)
        
        // Style buttons with a modern, elegant appearance
        let buttonStyle: (UIButton) -> Void = { button in
            button.layer.cornerRadius = 12
            button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.85)
            button.setTitleColor(UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.1
            button.layer.shadowRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 0.5).cgColor
        }
        
        // Apply styles to buttons
        [startButton, stopButton, pushLeftButton, pushRightButton].forEach(buttonStyle)
        
        // Special styling for Start/Stop buttons
        startButton.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 0.9)
        startButton.setTitleColor(UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0), for: .normal)
        
        stopButton.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 0.9)
        stopButton.setTitleColor(UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0), for: .normal)
        
        
        // Add custom icons to buttons
        startButton.setTitle("▶ Start", for: .normal)
        stopButton.setTitle("◼ Stop", for: .normal)
        pushLeftButton.setTitle("◄ Push", for: .normal)
        pushRightButton.setTitle("Push ►", for: .normal)
        
        // Create a container for the buttons
        let controlPanel = UIView()
        controlPanel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.85)
        controlPanel.layer.cornerRadius = 16
        controlPanel.layer.shadowColor = UIColor.black.cgColor
        controlPanel.layer.shadowOffset = CGSize(width: 0, height: 3)
        controlPanel.layer.shadowOpacity = 0.2
        controlPanel.layer.shadowRadius = 5
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(controlPanel)
        
        // Create button stacks for better organization
        let simulationControlsStack = UIStackView()
        simulationControlsStack.axis = .horizontal
        simulationControlsStack.distribution = .fillEqually
        simulationControlsStack.spacing = 10
        simulationControlsStack.translatesAutoresizingMaskIntoConstraints = false
        simulationControlsStack.addArrangedSubview(startButton)
        simulationControlsStack.addArrangedSubview(stopButton)
        
        let forceControlsStack = UIStackView()
        forceControlsStack.axis = .horizontal
        forceControlsStack.distribution = .fillEqually
        forceControlsStack.spacing = 10
        forceControlsStack.translatesAutoresizingMaskIntoConstraints = false
        forceControlsStack.addArrangedSubview(pushLeftButton)
        forceControlsStack.addArrangedSubview(pushRightButton)
        
        
        // Main control stack
        let controlStack = UIStackView()
        controlStack.axis = .vertical
        controlStack.spacing = 12
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.addArrangedSubview(simulationControlsStack)
        controlStack.addArrangedSubview(forceControlsStack)
        
        controlPanel.addSubview(controlStack)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Header container
            headerContainer.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerContainer.leadingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            
            // Control panel
            controlPanel.leadingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            controlPanel.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Control stack
            controlStack.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 16),
            controlStack.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            controlStack.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            controlStack.bottomAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: -16),
            
            // Control stacks height
            simulationControlsStack.heightAnchor.constraint(equalToConstant: 50),
            forceControlsStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        // If game is over, clear phase space and restart
        if viewModel.gameOverReason != nil {
            phaseSpaceView.clearPoints()
            viewModel.resetAndStart()
        } else {
            // Start the game normally
            viewModel.startGame()
        }
    }
    
    @objc private func stopButtonTapped() {
        viewModel.stopSimulation()
    }
    
    @objc private func pushLeftButtonTapped() {
        // Apply a leftward force (positive value for inverted pendulum)
        print("Push left button tapped")
        
        // Use a fixed baseline for the push direction with increased magnitude
        viewModel.applyForce(2.0) // Positive force pushes left (matches pendulumButtonControls.swift)
        
        // Visual feedback - animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.pushLeftButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.pushLeftButton.transform = .identity
            }
        }
    }
    
    @objc private func pushRightButtonTapped() {
        // Apply a rightward force (negative value for inverted pendulum)
        print("Push right button tapped")
        
        // Use a fixed baseline for the push direction with increased magnitude
        viewModel.applyForce(-2.0) // Negative force pushes right (matches pendulumButtonControls.swift)
        
        // Visual feedback - animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.pushRightButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.pushRightButton.transform = .identity
            }
        }
    }
    
    // This method is no longer used but we're keeping it for now as startButtonTapped
    // has the reset functionality when needed
    @objc private func resetButtonTapped() {
        phaseSpaceView.clearPoints()
        viewModel.resetAndStart()
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        // Update the value label
        updateSliderValueLabel(slider)
    }
    
    private func updateSliderValueLabel(_ slider: UISlider) {
        if let label = Unmanaged<UILabel>.fromOpaque(UnsafeRawPointer(bitPattern: slider.tag)!).takeUnretainedValue() as UILabel? {
            label.text = String(format: "%.2f", slider.value)
        }
    }
    
    @objc private func massSliderChanged() {
        viewModel.mass = Double(massSlider.value)
    }
    
    @objc private func lengthSliderChanged() {
        viewModel.length = Double(lengthSlider.value)
    }
    
    @objc private func dampingSliderChanged() {
        viewModel.damping = Double(dampingSlider.value)
    }
    
    @objc private func gravitySliderChanged() {
        viewModel.gravity = Double(gravitySlider.value)
    }
    
    @objc private func forceStrengthSliderChanged() {
        viewModel.forceStrength = Double(forceStrengthSlider.value)
    }
    
    @objc private func initialPerturbationSliderChanged() {
        viewModel.setInitialPerturbation(Double(initialPerturbationSlider.value))
    }
    
    // UITabBarDelegate method
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0: // Simulation
            showView(simulationView)
        case 1: // Parameters
            showView(parametersView)
        case 2: // Info
            showView(infoView)
        default:
            break
        }
    }
}