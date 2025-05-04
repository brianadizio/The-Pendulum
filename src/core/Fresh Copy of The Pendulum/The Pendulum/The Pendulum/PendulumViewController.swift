import UIKit
import SpriteKit
import QuartzCore

class PendulumViewController: UIViewController, UITabBarDelegate {
    
    let viewModel = PendulumViewModel()
    private var scene: PendulumScene?
    
    // Tab bar for navigation
    private let tabBar = UITabBar()
    private let simulationItem = UITabBarItem(title: "Simulation", image: UIImage(systemName: "waveform.path"), tag: 0)
    private let dashboardItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "chart.bar"), tag: 1)
    private let modesItem = UITabBarItem(title: "Modes", image: UIImage(systemName: "square.grid.2x2"), tag: 2)
    private let integrationItem = UITabBarItem(title: "Integration", image: UIImage(systemName: "link"), tag: 3)
    private let parametersItem = UITabBarItem(title: "Parameters", image: UIImage(systemName: "slider.horizontal.3"), tag: 4)
    private let settingsItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 5)
    
    // Views for different tabs
    let simulationView = UIView()
    let dashboardView = UIView()
    let modesView = UIView()
    let integrationView = UIView()
    let parametersView = UIView()
    let settingsView = UIView()
    private var currentView: UIView?
    
    // Dashboard view controller
    var dashboardViewController: DashboardViewController?
    
    // Parameter controls
    private let massSlider = UISlider()
    private let lengthSlider = UISlider()
    private let dampingSlider = UISlider()
    private let gravitySlider = UISlider()
    private let springConstantSlider = UISlider()
    private let momentOfInertiaSlider = UISlider()
    private let forceStrengthSlider = UISlider()
    private let initialPerturbationSlider = UISlider()
    
    // Game HUD elements
    private var scoreLabel: UILabel!
    private var timeLabel: UILabel!
    private var levelLabel: UILabel!
    private var gameMessageLabel: UILabel!
    private var hudContainer: UIView!
    
    // Dashboard elements for stats
    private var dashboardContainer: UIView!
    private var phaseSpaceView: PhaseSpaceView!
    private var phaseSpaceLabel: UILabel!
    private var updateTimer: Timer?
    var dashboardUpdateTimer: Timer?
    
    // Status label for feedback
    private var statusLabel: UILabel?
    private var statusTimer: Timer?
    
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
        setupStatusLabel()
        
        // Initialize settings
        initializeSettings()
        
        // Initialize analytics if a session is already active
        if let sessionId = viewModel.currentSessionId {
            AnalyticsManager.shared.startTracking(for: sessionId)
        }
        
        // Start with simulation view
        showView(simulationView)
    }
    
    private func setupStatusLabel() {
        // Create status label for feedback
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .goldenDark
        label.backgroundColor = .goldenAccent.withAlphaComponent(0.2)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
        label.alpha = 0
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -10),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            label.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        statusLabel = label
    }
    
    private func updateStatusLabel(_ message: String) {
        // Cancel any existing timer
        statusTimer?.invalidate()
        
        // Update and show the status label
        statusLabel?.text = message
        statusLabel?.isHidden = false
        
        // Animate in
        UIView.animate(withDuration: 0.3) {
            self.statusLabel?.alpha = 1.0
        }
        
        // Set timer to hide
        statusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.statusLabel?.alpha = 0.0
            } completion: { _ in
                self?.statusLabel?.isHidden = true
            }
        }
    }
    
    private func initializeSettings() {
        // Apply current settings
        let settingsManager = SettingsManager.shared
        let perturbationEffects = PerturbationEffects.shared
        
        // Initialize perturbation manager with first level profile
        let perturbationManager = PerturbationManager(profile: PerturbationProfile.forLevel(1))
        perturbationManager.viewModel = viewModel
        
        // Connect perturbation manager to the scene
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            perturbationManager.scene = self.scene
            self.scene?.perturbationManager = perturbationManager
            
            // Apply settings once scene is ready
            if let scene = self.scene {
                settingsManager.applyAllSettings(to: self.viewModel, scene: scene, effects: perturbationEffects)
            }
        }
    }
    
    private func setupTabBar() {
        // Configure tab bar with Golden Enterprises theme
        tabBar.delegate = self
        tabBar.items = [simulationItem, dashboardItem, modesItem, integrationItem, parametersItem, settingsItem]
        tabBar.selectedItem = simulationItem
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.tintColor = .goldenPrimary
        tabBar.unselectedItemTintColor = .goldenTextLight
        tabBar.backgroundColor = .goldenBackground
        
        // Add subtle top border
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
        
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
        // Apply Golden Enterprises theme to main view
        view.backgroundColor = .goldenBackground
        
        // Setup all views
        setupSimulationView()
        setupDashboardView() // This will create and configure the dashboard
        setupModesView()
        setupIntegrationView()
        setupParametersView()
        setupSettingsView() // Changed from setupInfoView to setupSettingsView
        
        // Add views to main view
        [simulationView, dashboardView, modesView, integrationView, parametersView, settingsView].forEach { subview in
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
        // Apply Golden Enterprises theme
        simulationView.backgroundColor = .goldenBackground
        
        // Add a header view with logo
        let headerView = createHeaderWithLogo(title: "The Pendulum", for: simulationView)
        
        // Create a container for the SpriteKit view with proper constraints
        let skViewContainer = UIView()
        skViewContainer.translatesAutoresizingMaskIntoConstraints = false
        skViewContainer.backgroundColor = .white
        skViewContainer.applyGoldenStyle() // Apply the Golden theme styling
        simulationView.addSubview(skViewContainer)
        
        // Position the SKView container to take most of the screen space below the header
        // Leave space at the bottom for controls
        NSLayoutConstraint.activate([
            skViewContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            skViewContainer.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 20),
            skViewContainer.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor, constant: -20),
            skViewContainer.heightAnchor.constraint(equalTo: simulationView.heightAnchor, multiplier: 0.45)
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
        // Set background to Golden Enterprises theme
        parametersView.backgroundColor = .goldenBackground
        
        // Add a header view with logo
        let headerView = createHeaderWithLogo(title: "Pendulum Parameters", for: parametersView)
        
        // Create a subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Adjust Parameters Below"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.textColor = .goldenDark
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        parametersView.addSubview(subtitleLabel)
        
        // Configure sliders
        let sliders = [massSlider, lengthSlider, dampingSlider, gravitySlider, springConstantSlider, momentOfInertiaSlider, forceStrengthSlider, initialPerturbationSlider]
        let sliderTitles = ["Mass", "Length", "Damping", "Gravity", "Spring Constant", "Moment of Inertia", "Force Strength", "Initial Perturbation"]
        
        // Create a scrollView to contain all parameters
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        parametersView.addSubview(scrollView)
        
        // Create a container for parameter controls
        let parametersContainer = UIView()
        parametersContainer.backgroundColor = .goldenBackground
        parametersContainer.layer.cornerRadius = 16
        parametersContainer.layer.borderWidth = 1
        parametersContainer.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
        parametersContainer.layer.shadowColor = UIColor.black.cgColor
        parametersContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        parametersContainer.layer.shadowOpacity = 0.1
        parametersContainer.layer.shadowRadius = 4
        parametersContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(parametersContainer)
        
        // Create a stack for all parameter controls
        let parametersStack = UIStackView()
        parametersStack.axis = .vertical
        parametersStack.spacing = 30 // Increased spacing to provide more room between parameters
        parametersStack.distribution = .fill // Changed from fillEqually to allow variable heights
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
        
        // Style the reset button with Golden theme
        resetButton.backgroundColor = .goldenPrimary
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 10
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor.goldenAccent.cgColor
        resetButton.layer.shadowColor = UIColor.black.cgColor
        resetButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        resetButton.layer.shadowOpacity = 0.1
        resetButton.layer.shadowRadius = 3
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
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
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor, constant: -20),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: parametersView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Parameters container
            parametersContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            parametersContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            parametersContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            parametersContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            parametersContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // Equal width to scrollView
            
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
        
        springConstantSlider.minimumValue = 0.0
        springConstantSlider.maximumValue = 3.0
        springConstantSlider.value = Float(viewModel.springConstant)
        
        momentOfInertiaSlider.minimumValue = 0.1
        momentOfInertiaSlider.maximumValue = 2.0
        momentOfInertiaSlider.value = Float(viewModel.momentOfInertia)
        
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
        springConstantSlider.addTarget(self, action: #selector(springConstantSliderChanged), for: .valueChanged)
        momentOfInertiaSlider.addTarget(self, action: #selector(momentOfInertiaSliderChanged), for: .valueChanged)
        forceStrengthSlider.addTarget(self, action: #selector(forceStrengthSliderChanged), for: .valueChanged)
        initialPerturbationSlider.addTarget(self, action: #selector(initialPerturbationSliderChanged), for: .valueChanged)
    }
    
    // MARK: - Modes View Setup
    
    private func setupModesView() {
        // Set background to Golden Enterprises theme
        modesView.backgroundColor = .goldenBackground
        
        // Add a header view with logo
        let headerView = createHeaderWithLogo(title: "Pendulum Modes", for: modesView)
        
        // Create a scroll view for the content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        modesView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: modesView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: modesView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: modesView.bottomAnchor, constant: -20)
        ])
        
        // Add the content view inside the scroll view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Create the grid layout for the modes
        setupModesGrid(in: contentView)
        
        // Create buttons for additional modes
        setupAdditionalModesButtons(in: contentView)
        
        // Add information buttons at the bottom
        setupInformationButtons(in: contentView)
        
        // Set a minimum height for the content - increased to accommodate all buttons
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1200).isActive = true
    }
    
    private func setupModesGrid(in containerView: UIView) {
        // Create a container for the grid
        let gridContainer = UIView()
        gridContainer.translatesAutoresizingMaskIntoConstraints = false
        gridContainer.backgroundColor = .clear
        containerView.addSubview(gridContainer)
        
        NSLayoutConstraint.activate([
            gridContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            gridContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gridContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        // Top row - 1x2 grid
        let topRowStack = createGridRow()
        gridContainer.addSubview(topRowStack)
        
        NSLayoutConstraint.activate([
            topRowStack.topAnchor.constraint(equalTo: gridContainer.topAnchor),
            topRowStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            topRowStack.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            topRowStack.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // Add buttons to top row
        let primaryButton = createModeButton(title: "Primary", tag: 101)
        let dashboardButton = createModeButton(title: "Dashboard", tag: 102)
        topRowStack.addArrangedSubview(primaryButton)
        topRowStack.addArrangedSubview(dashboardButton)
        
        // Middle row - 1x2 grid
        let middleRowStack = createGridRow()
        gridContainer.addSubview(middleRowStack)
        
        NSLayoutConstraint.activate([
            middleRowStack.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 10),
            middleRowStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            middleRowStack.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            middleRowStack.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // Add buttons to middle row
        // These titles are kept the same, but we'll disable their perturbation functionality
        let experimentButton = createModeButton(title: "Experiment", tag: 1103) // Changed tag to 1103
        let timeButton = createModeButton(title: "Joshua Tree", tag: 1104) // Changed tag to 1104
        middleRowStack.addArrangedSubview(experimentButton)
        middleRowStack.addArrangedSubview(timeButton)
        
        // Bottom row - 1x2 grid
        let bottomRowStack = createGridRow()
        gridContainer.addSubview(bottomRowStack)
        
        NSLayoutConstraint.activate([
            bottomRowStack.topAnchor.constraint(equalTo: middleRowStack.bottomAnchor, constant: 10),
            bottomRowStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            bottomRowStack.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            bottomRowStack.heightAnchor.constraint(equalToConstant: 120),
            bottomRowStack.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor)
        ])
        
        // Add buttons to bottom row
        // These titles are kept the same, but we'll disable their perturbation functionality
        let zerosSpaceButton = createModeButton(title: "Zero-G Space", tag: 1105) // Changed tag to 1105
        let focalButton = createModeButton(title: "The Focal Calculator", tag: 106)
        bottomRowStack.addArrangedSubview(zerosSpaceButton)
        bottomRowStack.addArrangedSubview(focalButton)
        
        // Add a label to indicate these buttons will have custom perturbations later
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Future Matlab-Processed Perturbation Modes"
        placeholderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        placeholderLabel.textColor = .goldenDark
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(placeholderLabel)
        
        // Add a visual separator
        let separator = UIView()
        separator.backgroundColor = .goldenAccent.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: gridContainer.bottomAnchor, constant: 20),
            placeholderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            placeholderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Add separator line below the label
            separator.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 10),
            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupAdditionalModesButtons(in containerView: UIView) {
        // This now relies on the separator line from previous section
        // Get the appropriate subview - the separator should be the last element added
        let separator = containerView.subviews.last(where: { $0 is UIView && $0.backgroundColor == .goldenAccent.withAlphaComponent(0.3) })
        let previousAnchor = separator?.bottomAnchor ?? containerView.topAnchor

        // Add Perturbation Modes header
        let perturbationHeader = UILabel()
        perturbationHeader.translatesAutoresizingMaskIntoConstraints = false
        perturbationHeader.text = "Available Perturbation Modes"
        perturbationHeader.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        perturbationHeader.textColor = .goldenDark
        perturbationHeader.textAlignment = .center
        containerView.addSubview(perturbationHeader)
        
        NSLayoutConstraint.activate([
            // Increase the top spacing to ensure no overlap
            perturbationHeader.topAnchor.constraint(equalTo: previousAnchor, constant: 60),
            perturbationHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            perturbationHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        // Create Perturbation Mode buttons
        let perturbationsStack = UIStackView()
        perturbationsStack.axis = .vertical
        perturbationsStack.spacing = 15
        perturbationsStack.distribution = .fillEqually
        perturbationsStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(perturbationsStack)
        
        NSLayoutConstraint.activate([
            perturbationsStack.topAnchor.constraint(equalTo: perturbationHeader.bottomAnchor, constant: 15),
            perturbationsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            perturbationsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            perturbationsStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
        ])
        
        // Unified perturbation button data
        let perturbationData: [(String, String, String, String)] = [
            ("No Perturbation", "none", "Standard pendulum with gravity only", "xmark.circle"),
            ("Random Impulses", "impulse", "Random forces applied at unpredictable intervals", "wind"),
            ("Sine Wave", "sine", "Smooth oscillating forces with adjustable frequency", "waveform"),
            ("Data-Driven", "data", "Forces from external datasets or recordings", "doc.text"),
            ("Compound", "compound", "Complex combination of multiple perturbation types", "function")
        ]
        
        // Create and add unified perturbation buttons
        for (index, data) in perturbationData.enumerated() {
            let button = createUnifiedPerturbationButton(
                title: data.0,
                description: data.2,
                perturbationType: data.1,
                iconName: data.3,
                tag: 300 + index
            )
            perturbationsStack.addArrangedSubview(button)
        }
    }
    
    private func createUnifiedPerturbationButton(title: String, description: String, perturbationType: String, iconName: String, tag: Int) -> UIView {
        // Container for the button with description
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .goldenBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.3).cgColor
        container.tag = tag
        
        // Add shadow for depth
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 3
        
        // Icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = .goldenPrimary
        iconContainer.layer.cornerRadius = 20
        container.addSubview(iconContainer)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconImageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: iconConfig))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainer.addSubview(iconImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .goldenDark
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .goldenText
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Activate button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Activate", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .goldenAccent
        button.layer.cornerRadius = 10
        button.tag = tag
        
        // Store perturbation type in button's accessibilityIdentifier
        button.accessibilityIdentifier = perturbationType
        
        // Add target action
        button.addTarget(self, action: #selector(specialPerturbationButtonTapped(_:)), for: .touchUpInside)
        
        container.addSubview(button)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 80),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),
            
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Add tap gesture to container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(specialPerturbationContainerTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return container
    }
    
    // MARK: - Information Buttons
    
    private func setupInformationButtons(in containerView: UIView) {
        // Find the perturbationsStack (the last stack view added)
        let perturbationsStack = containerView.subviews.last(where: { $0 is UIStackView }) as? UIStackView
        
        // Create a separator line
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .goldenAccent.withAlphaComponent(0.3)
        containerView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: perturbationsStack?.bottomAnchor ?? containerView.topAnchor, constant: 50),
            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Information section header
        let infoHeader = UILabel()
        infoHeader.translatesAutoresizingMaskIntoConstraints = false
        infoHeader.text = "Additional Information"
        infoHeader.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        infoHeader.textColor = .goldenDark
        infoHeader.textAlignment = .center
        containerView.addSubview(infoHeader)
        
        NSLayoutConstraint.activate([
            infoHeader.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 30),
            infoHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            infoHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        // Create stack for information buttons
        let infoButtonsStack = UIStackView()
        infoButtonsStack.axis = .vertical
        infoButtonsStack.spacing = 15
        infoButtonsStack.distribution = .fillEqually
        infoButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(infoButtonsStack)
        
        NSLayoutConstraint.activate([
            infoButtonsStack.topAnchor.constraint(equalTo: infoHeader.bottomAnchor, constant: 20),
            infoButtonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            infoButtonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            infoButtonsStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
        ])
        
        // Create and add the information buttons
        let pendulumModelButton = createInfoButton(
            title: "Inverted Pendulum Model",
            description: "Learn about the mathematics and physics behind the inverted pendulum model",
            iconName: "function",
            tag: 400
        )
        
        let dataSourcesButton = createInfoButton(
            title: "Data Sources for Modes",
            description: "Information about the data used in different pendulum modes and perturbations",
            iconName: "chart.xyaxis.line",
            tag: 401
        )
        
        infoButtonsStack.addArrangedSubview(pendulumModelButton)
        infoButtonsStack.addArrangedSubview(dataSourcesButton)
    }
    
    private func createInfoButton(title: String, description: String, iconName: String, tag: Int) -> UIView {
        // Container for the info button
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .goldenSecondary.withAlphaComponent(0.5)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
        container.tag = tag
        
        // Add shadow for depth
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 3
        
        // Icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = .goldenPrimary
        iconContainer.layer.cornerRadius = 20
        container.addSubview(iconContainer)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconImageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: iconConfig))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainer.addSubview(iconImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .goldenDark
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .goldenText
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Learn More button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Learn More", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .goldenPrimary
        button.layer.cornerRadius = 10
        button.tag = tag
        
        // Add target action
        button.addTarget(self, action: #selector(infoButtonTapped(_:)), for: .touchUpInside)
        
        container.addSubview(button)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 100),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -15),
            
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Add tap gesture recognizer to the container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(infoContainerTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return container
    }
    
    @objc private func infoButtonTapped(_ sender: UIButton) {
        showPlaceholderInfoView(for: sender.tag)
    }
    
    @objc private func infoContainerTapped(_ sender: UITapGestureRecognizer) {
        if let container = sender.view {
            showPlaceholderInfoView(for: container.tag)
        }
    }
    
    private func showPlaceholderInfoView(for tag: Int) {
        let alertTitle: String
        let alertMessage: String
        
        switch tag {
        case 400:
            alertTitle = "Inverted Pendulum Model"
            alertMessage = "This page will contain detailed information about the physics and mathematics behind the inverted pendulum model, including equations of motion, stability analysis, and control theory applications. It will provide explanations of relevant concepts such as angular momentum, torque, and differential equations for pendulum dynamics."
        case 401:
            alertTitle = "Data Sources for Modes"
            alertMessage = "This page will provide information about the data sources used for different pendulum modes, including real-world environmental data, synthetic datasets, and advanced perturbation techniques. It will describe how data is collected, processed, and applied to create realistic pendulum behaviors under various conditions."
        default:
            alertTitle = "Information"
            alertMessage = "More information will be available in a future update."
        }
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createSpecialPerturbationButton(title: String, description: String, perturbationType: String, tag: Int) -> UIView {
        // Container for the button with description
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .goldenBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.3).cgColor
        container.tag = tag
        
        // Add shadow for depth
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 3
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .goldenDark
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .goldenText
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Activate button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Activate", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .goldenAccent
        button.layer.cornerRadius = 10
        button.tag = tag
        
        // Store perturbation type in button's accessibilityIdentifier
        button.accessibilityIdentifier = perturbationType
        
        // Add target action
        button.addTarget(self, action: #selector(specialPerturbationButtonTapped(_:)), for: .touchUpInside)
        
        container.addSubview(button)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),
            
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Add tap gesture to container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(specialPerturbationContainerTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return container
    }
    
    @objc private func specialPerturbationButtonTapped(_ sender: UIButton) {
        // Get perturbation type from accessibilityIdentifier
        if let perturbationType = sender.accessibilityIdentifier {
            // Activate the selected perturbation type
            activateSpecialPerturbation(perturbationType)
            
            // Show visual feedback
            UIView.animate(withDuration: 0.1, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = .identity
                }
            }
        }
    }
    
    @objc private func specialPerturbationContainerTapped(_ sender: UITapGestureRecognizer) {
        if let container = sender.view,
           let button = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
            // Forward the tap to the button
            specialPerturbationButtonTapped(button)
        }
    }
    
    private func createGridRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createModeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.backgroundColor = .white
        button.setTitleColor(.goldenDark, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
        button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        
        return button
    }
    
    private func createCompactModeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.backgroundColor = .goldenBackground
        button.setTitleColor(.goldenDark, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.5).cgColor
        button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createLargeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.backgroundColor = .goldenSecondary.withAlphaComponent(0.5)
        button.setTitleColor(.goldenDark, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Add subtle shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
        
        return button
    }
    
    @objc private func modeButtonTapped(_ sender: UIButton) {
        // Handle mode button tap
        let title = "Mode Selected"
        let message = "You selected mode: \(sender.titleLabel?.text ?? "Unknown")"
        
        // Show visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        // Print the selection
        print("Selected mode: \(sender.titleLabel?.text ?? "Unknown") (tag: \(sender.tag))")
        
        // Set up perturbation system if not already done
        if perturbationManager == nil {
            setupPerturbationSystem()
        }
        
        // Handle specific mode selections based on tag
        switch sender.tag {
        // Old tags, disabled and changed
        case 1103, 1104, 1105:
            // These buttons have been disabled for perturbation functionality
            // and will be replaced with Matlab-processed modes
            updateGameMessageLabel("This perturbation mode will be available soon")
        
        // Standard modes
        case 101, 102, 106:
            // Primary, Dashboard, and Focal Calculator - no perturbation
            deactivatePerturbation()
            
        // Original unified perturbation buttons (300-304)
        case 300: // No Perturbation (now first)
            deactivatePerturbation()
        case 301: // Random Impulses
            activateSpecialPerturbation("impulse")
        case 302: // Sine Wave
            activateSpecialPerturbation("sine")
        case 303: // Data-Driven
            activateSpecialPerturbation("data")
        case 304: // Compound
            activateSpecialPerturbation("compound")
            
        default:
            // By default, deactivate perturbations
            deactivatePerturbation()
        }
    }
    
    // MARK: - Integration View Setup
    
    private func setupIntegrationView() {
        // Set background to Golden Enterprises theme
        integrationView.backgroundColor = .goldenBackground
        
        // Add a header view with logo
        let headerView = createHeaderWithLogo(title: "Pendulum Integrations", for: integrationView)
        
        // Create scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        integrationView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: integrationView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: integrationView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: integrationView.bottomAnchor, constant: -20)
        ])
        
        // Create content view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Setup View Leaderboards button
        let leaderboardsButton = createIntegrationButton(
            title: "View Leaderboards",
            tag: 301,
            in: contentView
        )
        
        // Setup social media integration buttons
        let socialStack = createSocialIntegrationButtons(in: contentView, topAnchor: leaderboardsButton.bottomAnchor)
        
        // Setup data view buttons
        let dataViewsStack = createDataViewButtons(in: contentView, topAnchor: socialStack.bottomAnchor)
        
        // Setup connection buttons
        let connectionsStack = createConnectionButtons(in: contentView, topAnchor: dataViewsStack.bottomAnchor)
        
        // Set minimum height for content
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 650).isActive = true
    }
    
    private func createIntegrationButton(title: String, tag: Int, in containerView: UIView) -> UIButton {
        // Create an integration button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.backgroundColor = .goldenSecondary.withAlphaComponent(0.6)
        button.setTitleColor(.goldenDark, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        
        containerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }
    
    private func createSocialIntegrationButtons(in containerView: UIView, topAnchor: NSLayoutYAxisAnchor) -> UIStackView {
        // Create a 2x1 grid for social media integration buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Add Instagram button
        let instagramButton = UIButton(type: .system)
        instagramButton.setTitle("Instagram", for: .normal)
        instagramButton.tag = 302
        instagramButton.backgroundColor = .white
        instagramButton.setTitleColor(.goldenDark, for: .normal)
        instagramButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instagramButton.layer.cornerRadius = 15
        instagramButton.layer.borderWidth = 1
        instagramButton.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.3).cgColor
        instagramButton.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
        
        // Add Facebook button
        let facebookButton = UIButton(type: .system)
        facebookButton.setTitle("Facebook", for: .normal)
        facebookButton.tag = 303
        facebookButton.backgroundColor = .white
        facebookButton.setTitleColor(.goldenDark, for: .normal)
        facebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        facebookButton.layer.cornerRadius = 15
        facebookButton.layer.borderWidth = 1
        facebookButton.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.3).cgColor
        facebookButton.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
        
        stackView.addArrangedSubview(instagramButton)
        stackView.addArrangedSubview(facebookButton)
        
        return stackView
    }
    
    private func createDataViewButtons(in containerView: UIView, topAnchor: NSLayoutYAxisAnchor) -> UIStackView {
        // Create a vertical stack for data view buttons
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        // Data view button titles and tags
        let buttonData = [
            ("View Data", 304),
            ("View Metadata", 305),
            ("View Statistics", 306),
            ("View Focus", 307),
            ("View Street", 308),
            ("View Category", 309)
        ]
        
        // Create data view buttons
        for (title, tag) in buttonData {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = tag
            button.backgroundColor = .goldenBackground.withAlphaComponent(0.8)
            button.setTitleColor(.goldenDark, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.goldenTextLight.withAlphaComponent(0.3).cgColor
            button.heightAnchor.constraint(equalToConstant: 45).isActive = true
            button.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createConnectionButtons(in containerView: UIView, topAnchor: NSLayoutYAxisAnchor) -> UIStackView {
        // Create a vertical stack for connection buttons
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
        ])
        
        // Connection button titles and tags
        let buttonData = [
            ("Connect The Pendulum", 310),
            ("Connect The Focus Calendar", 311)
        ]
        
        // Create connection buttons
        for (title, tag) in buttonData {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = tag
            button.backgroundColor = .goldenSecondary.withAlphaComponent(0.6)
            button.setTitleColor(.goldenDark, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 15
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
            
            // Add shadow
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.1
            button.layer.shadowRadius = 4
            
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    @objc private func integrationButtonTapped(_ sender: UIButton) {
        // Handle integration button tap
        let buttonTitle = sender.titleLabel?.text ?? "Unknown"
        
        // Show visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        // For now just print the selection
        print("Selected integration: \(buttonTitle) (tag: \(sender.tag))")
    }
    
    private func setupSettingsView() {
        // Set background to Golden Enterprises theme
        settingsView.backgroundColor = .goldenBackground
        
        // Add a header view with logo
        let headerView = createHeaderWithLogo(title: "Settings", for: settingsView)
        
        // Create scroll view for settings content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(scrollView)
        
        // Create content view inside scroll view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Layout scroll view and content view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Create stack view for settings sections
        let settingsStack = UIStackView()
        settingsStack.axis = .vertical
        settingsStack.spacing = 30
        settingsStack.distribution = .fill
        settingsStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(settingsStack)
        
        NSLayoutConstraint.activate([
            settingsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            settingsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            settingsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Define sections and their options
        let settingsSections = [
            (title: "Graphics", options: [
                "Standard", "High Definition", "Low Power", "Simplified", "Detailed", "Experimental"
            ]),
            (title: "Metrics", options: [
                "Basic", "Advanced", "Scientific", "Educational", "Detailed", "Performance"
            ]),
            (title: "Sounds", options: [
                "Standard", "Enhanced", "Minimal", "Realistic", "None", "Educational"
            ]),
            (title: "Backgrounds", options: [
                "Default", "Grid", "Dark", "Light", "Gradient", "None"
            ])
        ]
        
        // Add each section to the settings stack
        for section in settingsSections {
            // Create and add the section
            let sectionView = createSettingsSection(title: section.title, options: section.options)
            settingsStack.addArrangedSubview(sectionView)
        }
        
        // Add about section at the bottom
        let aboutButton = UIButton(type: .system)
        aboutButton.setTitle("About The Pendulum", for: .normal)
        aboutButton.setTitleColor(.goldenDark, for: .normal)
        aboutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        aboutButton.contentHorizontalAlignment = .left
        aboutButton.addTarget(self, action: #selector(showAboutInfo), for: .touchUpInside)
        
        let versionLabel = UILabel()
        versionLabel.text = "Version 1.0.0"
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textColor = .goldenTextLight
        versionLabel.textAlignment = .left
        
        let aboutStack = UIStackView(arrangedSubviews: [aboutButton, versionLabel])
        aboutStack.axis = .vertical
        aboutStack.spacing = 5
        aboutStack.translatesAutoresizingMaskIntoConstraints = false
        
        let separator = UIView()
        separator.backgroundColor = .goldenAccent.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let aboutSectionStack = UIStackView(arrangedSubviews: [separator, aboutStack])
        aboutSectionStack.axis = .vertical
        aboutSectionStack.spacing = 15
        aboutSectionStack.translatesAutoresizingMaskIntoConstraints = false
        aboutSectionStack.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        aboutSectionStack.isLayoutMarginsRelativeArrangement = true
        
        settingsStack.addArrangedSubview(aboutSectionStack)
        
        // Force a minimum content height
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 800).isActive = true
    }
    
    private func createSettingsSection(title: String, options: [String]) -> UIView {
        // Create section container
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Section title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .goldenDark
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(titleLabel)
        
        // Options container (shows current selection with dropdown indicator)
        let optionsContainer = UIView()
        optionsContainer.backgroundColor = .white
        optionsContainer.layer.cornerRadius = 12
        optionsContainer.layer.borderWidth = 1
        optionsContainer.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.3).cgColor
        optionsContainer.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(optionsContainer)
        
        // Current selection label
        let selectionLabel = UILabel()
        selectionLabel.text = options[0] // Default to first option
        selectionLabel.font = UIFont.systemFont(ofSize: 16)
        selectionLabel.textColor = .black
        selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(selectionLabel)
        
        // Dropdown icon
        let dropdownImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        dropdownImageView.tintColor = .goldenAccent
        dropdownImageView.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(dropdownImageView)
        
        // Create options grid
        let optionsStack = UIStackView()
        optionsStack.axis = .vertical
        optionsStack.spacing = 10
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(optionsStack)
        
        // First row of options (3 options)
        let firstRowStack = UIStackView()
        firstRowStack.axis = .horizontal
        firstRowStack.spacing = 10
        firstRowStack.distribution = .fillEqually
        
        // Second row of options (3 options)
        let secondRowStack = UIStackView()
        secondRowStack.axis = .horizontal
        secondRowStack.spacing = 10
        secondRowStack.distribution = .fillEqually
        
        // Add option buttons to rows
        for i in 0..<options.count {
            let optionButton = createOptionButton(title: options[i], section: title, isSelected: i == 0)
            
            if i < 3 {
                firstRowStack.addArrangedSubview(optionButton)
            } else {
                secondRowStack.addArrangedSubview(optionButton)
            }
        }
        
        optionsStack.addArrangedSubview(firstRowStack)
        optionsStack.addArrangedSubview(secondRowStack)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            
            // Options container
            optionsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            optionsContainer.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            optionsContainer.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            optionsContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Selection label
            selectionLabel.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: 15),
            selectionLabel.centerYAnchor.constraint(equalTo: optionsContainer.centerYAnchor),
            selectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: dropdownImageView.leadingAnchor, constant: -10),
            
            // Dropdown icon
            dropdownImageView.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor, constant: -15),
            dropdownImageView.centerYAnchor.constraint(equalTo: optionsContainer.centerYAnchor),
            dropdownImageView.widthAnchor.constraint(equalToConstant: 15),
            dropdownImageView.heightAnchor.constraint(equalToConstant: 15),
            
            // Options grid
            optionsStack.topAnchor.constraint(equalTo: optionsContainer.bottomAnchor, constant: 15),
            optionsStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            optionsStack.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            optionsStack.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor)
        ])
        
        // Make options container tappable to show/hide options
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleOptionsVisibility(_:)))
        optionsContainer.addGestureRecognizer(tapGesture)
        optionsContainer.isUserInteractionEnabled = true
        optionsContainer.tag = sectionView.hashValue
        
        // Store section title in the accessibilityIdentifier for reference
        optionsContainer.accessibilityIdentifier = title
        
        // Hide options initially
        optionsStack.isHidden = true
        
        return sectionView
    }
    
    private func createOptionButton(title: String, section: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(isSelected ? .white : .goldenDark, for: .normal)
        button.backgroundColor = isSelected ? .goldenAccent : .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.goldenAccent.withAlphaComponent(0.3).cgColor
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Store section in accessibilityIdentifier for reference
        button.accessibilityIdentifier = section
        
        // Add action
        button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func toggleOptionsVisibility(_ sender: UITapGestureRecognizer) {
        if let container = sender.view {
            // Get the section view
            if let sectionView = container.superview {
                // Find the options stack
                let optionsStack = sectionView.subviews.first { $0 is UIStackView } as? UIStackView
                
                // Toggle visibility with animation
                UIView.animate(withDuration: 0.3) {
                    optionsStack?.isHidden.toggle()
                    
                    // Rotate the dropdown icon
                    if let dropdownIcon = container.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                        dropdownIcon.transform = optionsStack?.isHidden ?? true ? .identity : CGAffineTransform(rotationAngle: .pi)
                    }
                }
            }
        }
    }
    
    @objc private func optionSelected(_ sender: UIButton) {
        // Get the section from the button's accessibilityIdentifier
        if let section = sender.accessibilityIdentifier {
            // Get the selected title
            if let title = sender.title(for: .normal) {
                // Update the selection in the UserDefaults
                UserDefaults.standard.set(title, forKey: "setting_\(section)")
                
                // Update UI
                updateSettingSelection(section: section, selection: title)
                
                // Show visual feedback
                UIView.animate(withDuration: 0.1, animations: {
                    sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        sender.transform = .identity
                    }
                }
                
                // Apply the updated setting using SettingsManager
                applyUpdatedSettings(section: section, selection: title)
                
                // Show confirmation using the status label (not the game message)
                // This uses the dedicated status label created for settings feedback
                updateStatusLabel("\(section) set to \(title)")
            }
        }
    }
    
    private func applyUpdatedSettings(section: String, selection: String) {
        // Get our relevant objects
        let settingsManager = SettingsManager.shared
        let perturbationEffects = PerturbationEffects.shared
        
        // Apply the appropriate setting based on the section
        switch section {
        case "Graphics":
            settingsManager.graphics = selection
            settingsManager.applyGraphicsSettings(to: perturbationEffects)
            
        case "Metrics":
            settingsManager.metrics = selection
            settingsManager.applyMetricsSettings(to: viewModel)
            
        case "Sounds":
            settingsManager.sounds = selection
            if let scene = self.scene {
                settingsManager.applySoundSettings(to: scene)
            }
            
        case "Backgrounds":
            settingsManager.backgrounds = selection
            if let scene = self.scene {
                settingsManager.applyBackgroundSettings(to: scene)
            }
            
        default:
            break
        }
    }
    
    private func updateSettingSelection(section: String, selection: String) {
        // Find the section view
        for subview in settingsView.subviews {
            if let scrollView = subview as? UIScrollView {
                for contentView in scrollView.subviews {
                    if let stackView = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                        for sectionView in stackView.arrangedSubviews {
                            // Check if this is the right section
                            if let optionsContainer = sectionView.subviews.first(where: { 
                                $0.accessibilityIdentifier == section 
                            }) {
                                // Update the selection label
                                if let selectionLabel = optionsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
                                    selectionLabel.text = selection
                                }
                                
                                // Update button states
                                if let optionsStack = sectionView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                                    updateOptionButtonStates(optionsStack, selectedOption: selection)
                                }
                                
                                // Hide options
                                toggleOptionsVisibility(UITapGestureRecognizer(target: optionsContainer, action: nil))
                                
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateOptionButtonStates(_ optionsStack: UIStackView, selectedOption: String) {
        // Go through all rows in the options stack
        for i in 0..<optionsStack.arrangedSubviews.count {
            let rowStack = optionsStack.arrangedSubviews[i] as? UIStackView
            
            // Go through all buttons in the row
            for j in 0..<(rowStack?.arrangedSubviews.count ?? 0) {
                if let button = rowStack?.arrangedSubviews[j] as? UIButton,
                   let title = button.title(for: .normal) {
                    // Update button state based on selection
                    let isSelected = title == selectedOption
                    button.backgroundColor = isSelected ? .goldenAccent : .white
                    button.setTitleColor(isSelected ? .white : .goldenDark, for: .normal)
                }
            }
        }
    }
    
    @objc private func showAboutInfo() {
        // Create and show an alert with app information
        let alert = UIAlertController(
            title: "About The Pendulum",
            message: """
            The Pendulum Simulation
            Golden Enterprise Solutions
            
            A physics-based pendulum simulation with dynamic perturbations and comprehensive visualizations.
            
            Version: 1.0.0
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func createParameterControl(title: String, slider: UISlider) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .goldenSecondary.withAlphaComponent(0.7)
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 3
        
        // Get units for the parameter
        let units = getUnitsForParameter(title)
        
        // Title label with units
        let titleLabel = UILabel()
        titleLabel.text = "\(title) (\(units))"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .goldenDark
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Value label with formatted value and initial non-zero value
        let valueLabel = UILabel()
        // Use a non-zero initial value even before slider is set
        let initialValue = getDefaultValueForParameter(title)
        valueLabel.text = formatParameterValue(title, value: initialValue)
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        valueLabel.textAlignment = .right
        valueLabel.textColor = .goldenAccentBlue
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        // Add description label between title and slider
        let descriptionLabel = UILabel()
        descriptionLabel.text = getDescriptionForParameter(title)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .goldenText
        descriptionLabel.numberOfLines = 0 // Allow multiple lines
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descriptionLabel)
        
        // Store the value label for updates
        slider.tag = Int(bitPattern: Unmanaged.passUnretained(valueLabel).toOpaque())
        
        // Configure slider appearance
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = .goldenPrimary
        slider.thumbTintColor = .goldenAccent
        slider.maximumTrackTintColor = UIColor.goldenBackgroundAlt
        
        // Create custom track height appearance
        slider.setMinimumTrackImage(createSliderTrackImage(color: .goldenPrimary), for: .normal)
        slider.setMaximumTrackImage(createSliderTrackImage(color: .goldenBackgroundAlt), for: .normal)
        
        container.addSubview(slider)
        
        // Add action to update value label when slider changes
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title - keep at top with more padding
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            
            // Value - align with title
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.widthAnchor.constraint(equalToConstant: 60),
            
            // Description - below title with more spacing
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            // Slider - below description with more spacing
            slider.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            slider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            slider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            slider.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        // Set a minimum height for each parameter control
        container.heightAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        
        return container
    }
    
    // Create custom slider track height
    private func createSliderTrackImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 6) // Thicker track (6 points)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    // Force layout update
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Create a header view with the Golden Enterprises logo
    private func createHeaderWithLogo(title: String, for containerView: UIView) -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        containerView.addSubview(headerView)
        
        // Add gradient to header
        DispatchQueue.main.async {
            let gradientLayer = GoldenGradients.createHeaderGradient(for: headerView)
            headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add logo to header - using the appLogo extension
        let logoImageView = UIImageView(image: UIImage.appLogo)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 15
        logoImageView.clipsToBounds = true
        if logoImageView.image == nil {
            // In case the image is nil, set a background color
            logoImageView.backgroundColor = .goldenAccent
        }
        logoImageView.tintColor = .goldenAccent // For the fallback symbol if used
        headerView.addSubview(logoImageView)
        
        // Add title to header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Logo on the left side of header
            logoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title centered in header
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    // MARK: - View Management
    
    private func showView(_ view: UIView) {
        // Hide all views
        simulationView.isHidden = true
        dashboardView.isHidden = true
        modesView.isHidden = true
        integrationView.isHidden = true
        parametersView.isHidden = true
        settingsView.isHidden = true
        
        // Show selected view
        view.isHidden = false
        currentView = view
    }
    
    // MARK: - Simulation Controls
    
    private func setupGameHUD() {
        // Container for game HUD elements - using Golden Enterprises theme
        hudContainer = UIView()
        hudContainer.backgroundColor = .goldenSecondary
        hudContainer.applyGoldenCard() // Apply Golden Enterprise styling
        hudContainer.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(hudContainer)
        
        // Score label - moved to the top
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        scoreLabel.textColor = .goldenDark
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(scoreLabel)
        
        // Level label
        levelLabel = UILabel()
        levelLabel.text = "Level: 1"
        levelLabel.textAlignment = .center
        levelLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        levelLabel.textColor = .goldenDark
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(levelLabel)
        
        // Time label
        timeLabel = UILabel()
        timeLabel.text = "Time: 0.0s"
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        timeLabel.textColor = .goldenDark
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(timeLabel)
        
        // Game message label (for game over messages)
        gameMessageLabel = UILabel()
        gameMessageLabel.text = "Balance the Inverted Pendulum!"
        gameMessageLabel.textAlignment = .center
        gameMessageLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        gameMessageLabel.textColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        gameMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        gameMessageLabel.isHidden = true
        hudContainer.addSubview(gameMessageLabel)
        
        // Position HUD at top of screen - make it larger to fit level info
        NSLayoutConstraint.activate([
            hudContainer.topAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.topAnchor, constant: 5),
            hudContainer.leadingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hudContainer.trailingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            // Increase height to fit 3 elements
            hudContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Move score to top left
            scoreLabel.topAnchor.constraint(equalTo: hudContainer.topAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor, constant: 16),
            scoreLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.5, constant: -16),
            
            // Level in center
            levelLabel.centerXAnchor.constraint(equalTo: hudContainer.centerXAnchor),
            levelLabel.topAnchor.constraint(equalTo: hudContainer.topAnchor, constant: 10),
            
            // Time at top right
            timeLabel.topAnchor.constraint(equalTo: hudContainer.topAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor, constant: -16),
            timeLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.5, constant: -16),
            
            // Game message below stats
            gameMessageLabel.centerXAnchor.constraint(equalTo: hudContainer.centerXAnchor),
            gameMessageLabel.bottomAnchor.constraint(equalTo: hudContainer.bottomAnchor, constant: -10),
            gameMessageLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, constant: -32)
        ])
        
        // Start update timer for HUD
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateGameHUD()
        }
    }
    
    private var controlPanel: UIView!
    
    private func setupPhaseSpaceView() {
        // Create a container view for the phase space
        let phaseSpaceContainer = UIView()
        phaseSpaceContainer.translatesAutoresizingMaskIntoConstraints = false
        phaseSpaceContainer.backgroundColor = UIColor.clear
        simulationView.addSubview(phaseSpaceContainer)
        
        // Position the container at the bottom third of the screen, after the controls
        NSLayoutConstraint.activate([
            // Position below the controls button panel
            phaseSpaceContainer.topAnchor.constraint(equalTo: simulationView.centerYAnchor, constant: 160),
            phaseSpaceContainer.centerXAnchor.constraint(equalTo: simulationView.centerXAnchor),
            phaseSpaceContainer.widthAnchor.constraint(equalToConstant: 180),
            phaseSpaceContainer.heightAnchor.constraint(equalToConstant: 200) // Reduced height for container
        ])
        
        // Create a label for the phase space
        phaseSpaceLabel = UILabel()
        phaseSpaceLabel.text = "Phase Space"
        phaseSpaceLabel.textAlignment = .center
        phaseSpaceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        phaseSpaceLabel.textColor = UIColor.darkGray
        phaseSpaceLabel.translatesAutoresizingMaskIntoConstraints = false
        phaseSpaceContainer.addSubview(phaseSpaceLabel)
        
        // Create phase space view
        phaseSpaceView = PhaseSpaceView(frame: .zero)
        phaseSpaceView.translatesAutoresizingMaskIntoConstraints = false
        phaseSpaceContainer.addSubview(phaseSpaceView)
        
        // Position phase space and label
        NSLayoutConstraint.activate([
            phaseSpaceLabel.topAnchor.constraint(equalTo: phaseSpaceContainer.topAnchor),
            phaseSpaceLabel.centerXAnchor.constraint(equalTo: phaseSpaceContainer.centerXAnchor),
            phaseSpaceLabel.widthAnchor.constraint(equalTo: phaseSpaceContainer.widthAnchor),
            phaseSpaceLabel.heightAnchor.constraint(equalToConstant: 20),
            
            phaseSpaceView.topAnchor.constraint(equalTo: phaseSpaceLabel.bottomAnchor, constant: 5),
            phaseSpaceView.centerXAnchor.constraint(equalTo: phaseSpaceContainer.centerXAnchor),
            phaseSpaceView.widthAnchor.constraint(equalToConstant: 170),
            phaseSpaceView.heightAnchor.constraint(equalToConstant: 170)
        ])
    }

    private func updateGameHUD() {
        // Update score and basic stats
        scoreLabel.text = "Score: \(viewModel.score)"
        levelLabel.text = "Level: \(viewModel.currentLevel)"
        timeLabel.text = String(format: "Time: %.1fs", viewModel.totalBalanceTime)
        
        // Calculate time needed to complete level
        let timeRemaining = max(0, viewModel.levelSuccessTime - viewModel.consecutiveBalanceTime)
        
        // Update message based on game state
        if !viewModel.isGameActive && viewModel.gameOverReason != nil {
            gameMessageLabel.text = viewModel.gameOverReason
            gameMessageLabel.isHidden = false
            
            // For level completion, use special formatting
            if viewModel.gameOverReason!.contains("completed") {
                gameMessageLabel.textColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
            } else if viewModel.gameOverReason!.contains("Level") && !viewModel.gameOverReason!.contains("completed") {
                // For level announcement, use blue
                gameMessageLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)
            } else {
                // For failure, use red
                gameMessageLabel.textColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            }
            
            // Change Start button to Restart if game is over and not just paused
            if viewModel.gameOverReason == "Pendulum fell!" {
                startButton.setTitle("↺ Restart", for: .normal)
            }
        } else if viewModel.isGameActive {
            // During active gameplay, show balance progress
            if viewModel.consecutiveBalanceTime > 0 {
                gameMessageLabel.text = String(format: "Balance: %.1fs / %.1fs", 
                                              viewModel.consecutiveBalanceTime, 
                                              viewModel.levelSuccessTime)
                gameMessageLabel.isHidden = false
                gameMessageLabel.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
            } else {
                gameMessageLabel.isHidden = true
            }
        } else {
            // Not active, not game over - must be paused
            gameMessageLabel.isHidden = false
            gameMessageLabel.text = "Game Paused"
            gameMessageLabel.textColor = UIColor(red: 0.5, green: 0.3, blue: 0.0, alpha: 1.0)
            
            // Change button text
            startButton.setTitle("▶ Resume", for: .normal)
        }
        
        // Update phase space view with current pendulum state
        phaseSpaceView.addPoint(theta: viewModel.currentState.theta, omega: viewModel.currentState.thetaDot)
    }
    
    private func setupSimulationControls(in parentView: UIView) {
        // Remove title labels per feedback
        // We'll use just the score and time from the HUD at the top
        
        // Style buttons with Golden Enterprises theme
        let buttonStyle: (UIButton) -> Void = { button in
            button.applyGoldenButtonStyle(isPrimary: false)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        // Apply styles to buttons
        [startButton, stopButton, pushLeftButton, pushRightButton].forEach(buttonStyle)
        
        // Special styling for Start/Stop buttons using Golden theme
        startButton.applyGoldenButtonStyle(isPrimary: true)
        startButton.backgroundColor = .goldenAccentGreen
        
        stopButton.applyGoldenButtonStyle(isPrimary: true)
        stopButton.backgroundColor = .goldenError
        
        
        // Add custom icons to buttons
        startButton.setTitle("▶ Start", for: .normal)
        stopButton.setTitle("◼ Stop", for: .normal)
        pushLeftButton.setTitle("◄ Push", for: .normal)
        pushRightButton.setTitle("Push ►", for: .normal)
        
        // Create a container for the buttons with Golden Enterprises styling
        controlPanel = UIView()
        controlPanel.backgroundColor = .goldenSecondary
        controlPanel.applyGoldenCard() // Apply Golden Enterprise styling
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
            
            // Control panel - positioned to leave space for phase space below
            controlPanel.centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: 50),
            controlPanel.leadingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            controlPanel.heightAnchor.constraint(lessThanOrEqualToConstant: 140), // Ensure fixed max height
            
            // Control stack
            controlStack.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 16),
            controlStack.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            controlStack.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            controlStack.bottomAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: -16),
            
            // Control stacks height
            simulationControlsStack.heightAnchor.constraint(equalToConstant: 50),
            forceControlsStack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // We now position the phase space in setupPhaseSpaceView
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        // If the game is paused, handle resuming
        if viewModel.isPaused {
            // Resume the simulation
            viewModel.isPaused = false
            
            // Restore any previously active perturbation profile
            if let profile = pendingPerturbationProfile, let perturbationManager = perturbationManager {
                perturbationManager.activateProfile(profile)
                pendingPerturbationProfile = nil
            }
            
            // Restart the simulation timer
            viewModel.startSimulation()
            
            // Update UI
            updateGameMessageLabel("Game resumed")
            startButton.setTitle("Restart", for: .normal)
            return
        }
        
        // If game is over, clear phase space and restart
        if viewModel.gameOverReason != nil {
            // Apply any pending perturbation profile before restarting
            if let profile = pendingPerturbationProfile, let perturbationManager = perturbationManager {
                perturbationManager.activateProfile(profile)
                updateGameMessageLabel("Applied \(profile.name) perturbation mode")
                pendingPerturbationProfile = nil
            }
            
            phaseSpaceView.clearPoints()
            viewModel.resetAndStart()
        } else {
            // Start the game normally
            viewModel.startGame()
            startButton.setTitle("Restart", for: .normal)
        }
    }
    
    @objc private func stopButtonTapped() {
        // First check if we're already paused
        if viewModel.isPaused {
            return // Already paused, don't do anything
        }
        
        // Set the view model to paused state (this will be checked by the game logic)
        viewModel.isPaused = true
        
        // Stop the simulation timer but keep the game active
        viewModel.stopSimulation()
        
        // Ensure the game remains marked as active
        viewModel.isGameActive = true
        
        // Also pause any active perturbations
        if let perturbationManager = perturbationManager {
            // Create a temporary empty profile to pause perturbations
            let tempEmptyProfile = PerturbationProfile(
                name: "Paused",
                types: [],
                strength: 0.0,
                frequency: 0.0,
                randomInterval: 0...0,
                dataSource: nil,
                showWarnings: false
            )
            
            // Store the currently active profile to restore later
            if pendingPerturbationProfile == nil && perturbationManager.activeProfile != nil {
                pendingPerturbationProfile = perturbationManager.activeProfile
            }
            
            // Temporarily disable perturbations
            perturbationManager.activateProfile(tempEmptyProfile)
        }
        
        // Show message that game is paused
        updateGameMessageLabel("Game paused - Return to Simulation tab and press Resume or Push to continue")
        
        // Change button text to reflect state
        startButton.setTitle("▶ Resume", for: .normal)
    }
    
    @objc private func pushLeftButtonTapped() {
        // Apply a leftward force (positive value for inverted pendulum)
        print("Push left button tapped")
        
        // If game is paused, resume it first
        if viewModel.isPaused {
            // Resume the game
            viewModel.isPaused = false
            
            // Restore any previously active perturbation profile
            if let profile = pendingPerturbationProfile, let perturbationManager = perturbationManager {
                perturbationManager.activateProfile(profile)
                pendingPerturbationProfile = nil
            }
            
            // Restart the simulation timer
            viewModel.startSimulation()
            
            // Update UI
            updateGameMessageLabel("Game resumed")
            startButton.setTitle("Restart", for: .normal)
        }
        
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
        
        // If game is paused, resume it first
        if viewModel.isPaused {
            // Resume the game
            viewModel.isPaused = false
            
            // Restore any previously active perturbation profile
            if let profile = pendingPerturbationProfile, let perturbationManager = perturbationManager {
                perturbationManager.activateProfile(profile)
                pendingPerturbationProfile = nil
            }
            
            // Restart the simulation timer
            viewModel.startSimulation()
            
            // Update UI
            updateGameMessageLabel("Game resumed")
            startButton.setTitle("Restart", for: .normal)
        }
        
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
            // Get parameter name from slider
            let parameterName = getParameterNameFromSlider(slider)
            label.text = formatParameterValue(parameterName, value: slider.value)
        }
    }
    
    // Helper to determine parameter name from slider
    private func getParameterNameFromSlider(_ slider: UISlider) -> String {
        if slider === massSlider {
            return "Mass"
        } else if slider === lengthSlider {
            return "Length"
        } else if slider === dampingSlider {
            return "Damping"
        } else if slider === gravitySlider {
            return "Gravity"
        } else if slider === springConstantSlider {
            return "Spring Constant"
        } else if slider === momentOfInertiaSlider {
            return "Moment of Inertia"
        } else if slider === forceStrengthSlider {
            return "Force Strength"
        } else if slider === initialPerturbationSlider {
            return "Initial Perturbation"
        } else {
            return "Parameter"
        }
    }
    
    // Helper to get units for each parameter
    private func getUnitsForParameter(_ title: String) -> String {
        switch title {
        case "Mass":
            return "kg"
        case "Length":
            return "m"
        case "Damping":
            return "Ns/m"
        case "Gravity":
            return "m/s²"
        case "Spring Constant":
            return "N/m"
        case "Moment of Inertia":
            return "kg·m²"
        case "Force Strength":
            return "multiplier"
        case "Initial Perturbation":
            return "degrees"
        default:
            return ""
        }
    }
    
    // Get description for each parameter
    private func getDescriptionForParameter(_ title: String) -> String {
        switch title {
        case "Mass":
            return "The weight of the pendulum bob, affecting inertia and momentum"
        case "Length":
            return "Distance from pivot to center of mass, affects oscillation period"
        case "Damping":
            return "Energy dissipation due to friction, higher values slow the pendulum faster"
        case "Gravity":
            return "Acceleration due to gravity, affects the restoring force"
        case "Spring Constant":
            return "Stiffness of the restoring force, higher values create stronger spring forces"
        case "Moment of Inertia":
            return "Resistance to rotational motion, affects angular acceleration"
        case "Force Strength":
            return "Magnitude of external forces applied to the pendulum"
        case "Initial Perturbation":
            return "Starting angle deviation from equilibrium position"
        default:
            return ""
        }
    }
    
    // Format parameter value with appropriate precision and units
    private func formatParameterValue(_ parameterName: String, value: Float) -> String {
        switch parameterName {
        case "Initial Perturbation":
            return String(format: "%.1f°", value)
        case "Damping":
            return String(format: "%.3f", value)
        case "Spring Constant":
            return String(format: "%.2f", value)
        case "Moment of Inertia":
            return String(format: "%.2f", value)
        default:
            return String(format: "%.2f", value)
        }
    }
    
    // Get sensible default value for each parameter to ensure non-zero display
    private func getDefaultValueForParameter(_ parameterName: String) -> Float {
        switch parameterName {
        case "Mass":
            return Float(viewModel.mass > 0 ? viewModel.mass : 1.0)
        case "Length":
            return Float(viewModel.length > 0 ? viewModel.length : 1.0)
        case "Damping":
            return Float(viewModel.damping)  // Can legitimately be 0
        case "Gravity":
            return Float(viewModel.gravity > 0 ? viewModel.gravity : 15.0)
        case "Spring Constant":
            return Float(viewModel.springConstant)  // Can legitimately be 0
        case "Moment of Inertia":
            return Float(viewModel.momentOfInertia > 0 ? viewModel.momentOfInertia : 0.5)
        case "Force Strength":
            return Float(viewModel.forceStrength > 0 ? viewModel.forceStrength : 5.0)
        case "Initial Perturbation":
            return Float(viewModel.initialPerturbation > 0 ? viewModel.initialPerturbation : 20.0)
        default:
            return 1.0  // Default fallback
        }
    }
    
    @objc private func massSliderChanged() {
        viewModel.mass = Double(massSlider.value)
        updateGameMessageLabel("Mass updated to \(String(format: "%.2f", massSlider.value)) kg")
    }
    
    @objc private func lengthSliderChanged() {
        viewModel.length = Double(lengthSlider.value)
        updateGameMessageLabel("Length updated to \(String(format: "%.2f", lengthSlider.value)) m")
    }
    
    @objc private func dampingSliderChanged() {
        viewModel.damping = Double(dampingSlider.value)
        updateGameMessageLabel("Damping updated to \(String(format: "%.3f", dampingSlider.value)) Ns/m")
    }
    
    @objc private func gravitySliderChanged() {
        viewModel.gravity = Double(gravitySlider.value)
        updateGameMessageLabel("Gravity updated to \(String(format: "%.2f", gravitySlider.value)) m/s²")
    }
    
    @objc private func forceStrengthSliderChanged() {
        viewModel.forceStrength = Double(forceStrengthSlider.value)
        updateGameMessageLabel("Force strength updated to \(String(format: "%.2f", forceStrengthSlider.value))x")
    }
    
    @objc private func springConstantSliderChanged() {
        viewModel.springConstant = Double(springConstantSlider.value)
        updateGameMessageLabel("Spring constant updated to \(String(format: "%.2f", springConstantSlider.value)) N/m")
    }
    
    @objc private func momentOfInertiaSliderChanged() {
        viewModel.momentOfInertia = Double(momentOfInertiaSlider.value)
        updateGameMessageLabel("Moment of inertia updated to \(String(format: "%.2f", momentOfInertiaSlider.value)) kg·m²")
    }
    
    @objc private func initialPerturbationSliderChanged() {
        viewModel.setInitialPerturbation(Double(initialPerturbationSlider.value))
        updateGameMessageLabel("Initial perturbation set to \(String(format: "%.1f", initialPerturbationSlider.value))°")
    }
    
    // Show a temporary game message with visual feedback
    private func updateGameMessageLabel(_ message: String) {
        // Show a game message temporarily with visual styling
        gameMessageLabel.text = message
        gameMessageLabel.isHidden = false
        
        // Change color to indicate update (blue for parameter changes)
        gameMessageLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)
        
        // Animate the label for better visibility
        UIView.animate(withDuration: 0.2, animations: {
            self.gameMessageLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.gameMessageLabel.transform = .identity
            }
        }
        
        // Hide it after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.viewModel.gameOverReason == nil {
                // Fade out animation
                UIView.animate(withDuration: 0.5, animations: {
                    self?.gameMessageLabel.alpha = 0
                }) { _ in
                    self?.gameMessageLabel.isHidden = true
                    self?.gameMessageLabel.alpha = 1
                    // Reset color for other messages
                    self?.gameMessageLabel.textColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
                }
            }
        }
        
        // Force an immediate update of the parameter in the simulation
        // This ensures parameter changes take immediate effect without waiting
        DispatchQueue.main.async {
            // This will trigger updatePhysicsParameters through property observers
            self.viewModel.updateSimulationParameters()
        }
    }
    
    // UITabBarDelegate method
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // First stop any dashboard updates to avoid unnecessary refreshes
        stopDashboardUpdates()
        
        switch item.tag {
        case 0: // Simulation
            showView(simulationView)
        case 1: // Dashboard
            updateDashboardStats() // Update stats before showing (this will start the timer)
            showView(dashboardView)
        case 2: // Modes
            // Set up perturbation system if not already done
            if perturbationManager == nil {
                setupPerturbationSystem()
            }
            showView(modesView)
        case 3: // Integration
            showView(integrationView)
        case 4: // Parameters
            showView(parametersView)
        case 5: // Settings
            showView(settingsView)
        default:
            break
        }
    }
    
    // MARK: - Perturbation Management
    
    private var perturbationManager: PerturbationManager?
    private var pendingPerturbationProfile: PerturbationProfile?
    
    private func setupPerturbationSystem() {
        // Create perturbation manager
        perturbationManager = PerturbationManager()
        perturbationManager?.viewModel = viewModel
        perturbationManager?.scene = scene
        
        // Connect perturbation manager to scene
        scene?.perturbationManager = perturbationManager
        
        // Register for notifications from SwiftUI interface
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePerturbationModeChange(_:)),
            name: Notification.Name("ActivatePerturbationMode"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSpecialPerturbation(_:)),
            name: Notification.Name("ActivateSpecialPerturbation"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeactivatePerturbation),
            name: Notification.Name("DeactivatePerturbation"),
            object: nil
        )
    }
    
    @objc private func handlePerturbationModeChange(_ notification: Notification) {
        if let modeNumber = notification.object as? Int {
            activatePerturbationMode(modeNumber)
        }
    }
    
    @objc private func handleSpecialPerturbation(_ notification: Notification) {
        if let perturbationType = notification.object as? String {
            activateSpecialPerturbation(perturbationType)
        }
    }
    
    @objc private func handleDeactivatePerturbation() {
        deactivatePerturbation()
    }
    
    private func activatePerturbationMode(_ mode: Int) {
        // Get profile for the specified mode
        let profile = PerturbationProfile.forMode(mode)
        
        // Store the profile but don't activate it yet
        pendingPerturbationProfile = profile
        
        // Show confirmation
        let modeName = profile.name
        updateGameMessageLabel("\(modeName) mode ready. Click Restart to apply.")
    }
    
    private func activateSpecialPerturbation(_ type: String) {
        // Create custom profile based on perturbation type
        var profile: PerturbationProfile
        
        switch type {
        case "impulse":
            profile = PerturbationProfile(
                name: "Random Impulses",
                types: [.impulse],
                strength: 1.5, // Increased from 1.0 to 1.5 for more pronounced effect
                frequency: 0.0,
                randomInterval: 2.0...4.0,
                dataSource: nil,
                showWarnings: true
            )
        case "sine":
            profile = PerturbationProfile(
                name: "Sine Wave",
                types: [.sine],
                strength: 0.6, // Reduced from 0.8 to 0.6 (25% reduction)
                frequency: 0.5,
                randomInterval: 0...0,
                dataSource: nil,
                showWarnings: false
            )
        case "data":
            profile = PerturbationProfile(
                name: "Data-Driven",
                types: [.dataSet],
                strength: 1.0,
                frequency: 0.0,
                randomInterval: 0...0,
                dataSource: "PerturbationData.csv",
                showWarnings: true
            )
        case "compound":
            profile = PerturbationProfile(
                name: "Compound",
                types: [.compound],
                strength: 0.75, // Reduced from 1.0 to 0.75 (25% reduction)
                frequency: 0.4,
                randomInterval: 2.0...4.0,
                dataSource: "PerturbationData.csv",
                showWarnings: true,
                subProfiles: [
                    PerturbationProfile(
                        name: "Base Sine",
                        types: [.sine],
                        strength: 0.525, // Reduced from 0.7 to 0.525 (25% reduction)
                        frequency: 0.3,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Random Impulses",
                        types: [.impulse],
                        strength: 0.75, // Reduced from 1.0 to 0.75 (25% reduction)
                        frequency: 0.0,
                        randomInterval: 3.0...5.0,
                        dataSource: nil,
                        showWarnings: true
                    )
                ]
            )
        default:
            profile = PerturbationProfile(
                name: "Custom",
                types: [.random],
                strength: 0.5,
                frequency: 0.0,
                randomInterval: 1.0...3.0,
                dataSource: nil,
                showWarnings: false
            )
        }
        
        // Store the profile but don't activate it yet
        pendingPerturbationProfile = profile
        
        // Show confirmation
        updateGameMessageLabel("\(profile.name) perturbation ready. Click Restart to apply.")
    }
    
    private func deactivatePerturbation() {
        // Create a minimal profile that does essentially nothing
        let emptyProfile = PerturbationProfile(
            name: "None",
            types: [],
            strength: 0.0,
            frequency: 0.0,
            randomInterval: 0...0,
            dataSource: nil,
            showWarnings: false
        )
        
        // Store the empty profile but don't activate it yet
        pendingPerturbationProfile = emptyProfile
        
        // Show confirmation
        updateGameMessageLabel("Perturbations will be disabled on restart")
    }
}