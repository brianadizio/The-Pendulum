import UIKit
import SpriteKit
import QuartzCore

class PendulumViewController: UIViewController, UITabBarDelegate {
    
    let viewModel = PendulumViewModel()
    private var scene: PendulumScene?
    
    // Tab bar for navigation
    private let tabBar = UITabBar()
    private let simulationItem: UITabBarItem = {
        // Create the image with original rendering mode to preserve colors
        let image = UIImage(named: "simulationTabPendulum-removebg-preview")?.withRenderingMode(.alwaysOriginal)
        let resizedImage = PendulumViewController.resizeImage(image, targetSize: CGSize(width: 25, height: 25))
        let item = UITabBarItem(title: "Simulation", image: resizedImage, tag: 0)
        item.selectedImage = resizedImage
        return item
    }()

    private let dashboardItem: UITabBarItem = {
        // Create the image with original rendering mode to preserve colors
        let image = UIImage(named: "dashboardTabFocusCalendar-removebg-preview")?.withRenderingMode(.alwaysOriginal)
        let resizedImage = PendulumViewController.resizeImage(image, targetSize: CGSize(width: 25, height: 25))
        let item = UITabBarItem(title: "Dashboard", image: resizedImage, tag: 1)
        item.selectedImage = resizedImage
        return item
    }()

    private let modesItem: UITabBarItem = {
        // Create the image with original rendering mode to preserve colors
        let image = UIImage(named: "modesTabFocusCalendar-removebg-preview")?.withRenderingMode(.alwaysOriginal)
        let resizedImage = PendulumViewController.resizeImage(image, targetSize: CGSize(width: 25, height: 25))
        let item = UITabBarItem(title: "Modes", image: resizedImage, tag: 2)
        item.selectedImage = resizedImage
        return item
    }()

    private let integrationItem: UITabBarItem = {
        // Create the image with original rendering mode to preserve colors
        let image = UIImage(named: "integrationTabFocusCalendar-removebg-preview")?.withRenderingMode(.alwaysOriginal)
        let resizedImage = PendulumViewController.resizeImage(image, targetSize: CGSize(width: 25, height: 25))
        let item = UITabBarItem(title: "Integration", image: resizedImage, tag: 3)
        item.selectedImage = resizedImage
        return item
    }()

    private let parametersItem: UITabBarItem = {
        // Create the image with original rendering mode to preserve colors
        let image = UIImage(named: "parametersTabPendulum-removebg-preview")?.withRenderingMode(.alwaysOriginal)
        let resizedImage = PendulumViewController.resizeImage(image, targetSize: CGSize(width: 25, height: 25))
        let item = UITabBarItem(title: "Parameters", image: resizedImage, tag: 4)
        item.selectedImage = resizedImage
        return item
    }()

    private let settingsItem: UITabBarItem = {
        // Create the image with original rendering mode to preserve colors
        let image = UIImage(named: "settingsTabFocusCalendar-removebg-preview")?.withRenderingMode(.alwaysOriginal)
        let resizedImage = PendulumViewController.resizeImage(image, targetSize: CGSize(width: 25, height: 25))
        let item = UITabBarItem(title: "Settings", image: resizedImage, tag: 5)
        item.selectedImage = resizedImage
        return item
    }()
    
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

        // Apply Focus Calendar theme to main view
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Set up the main interface
        setupTabBar()
        setupViews()
        setupStatusLabel()

        // Initialize settings
        initializeSettings()
        
        // Initialize sound mode from saved settings
        if let savedSoundMode = UserDefaults.standard.string(forKey: "setting_Sounds") {
            PendulumSoundManager.shared.updateSoundMode(savedSoundMode)
        } else {
            // Default to Standard sound mode
            PendulumSoundManager.shared.updateSoundMode("Standard")
        }
        
        // Initialize background mode from saved settings
        if let savedBackgroundMode = UserDefaults.standard.string(forKey: "setting_Backgrounds") {
            BackgroundManager.shared.updateBackgroundMode(savedBackgroundMode)
        } else {
            // Default to AI background mode for testing
            BackgroundManager.shared.updateBackgroundMode("AI")
            UserDefaults.standard.set("AI", forKey: "setting_Backgrounds")
        }

        // Initialize analytics if a session is already active
        if let sessionId = viewModel.currentSessionId {
            AnalyticsManager.shared.startTracking(for: sessionId)
        }

        // Start with simulation view
        showView(simulationView)
        
        // Initialize backgrounds for all tabs after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            BackgroundManager.shared.applyBackgroundToAllTabs(in: self)
        }
    }

    
    private func setupStatusLabel() {
        // Create status label for feedback
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = FocusCalendarTheme.primaryTextColor
        label.backgroundColor = FocusCalendarTheme.accentGold.withAlphaComponent(0.2)
        label.textAlignment = .center
        label.font = FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.subheadline)
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
        // Don't set tintColor to preserve original icon colors
        // tabBar.tintColor = .goldenPrimary
        // tabBar.unselectedItemTintColor = .darkGray // Darker color for better visibility
        tabBar.backgroundColor = FocusCalendarTheme.backgroundColor

        // Make tab bar and icons more visible
        tabBar.itemPositioning = .centered
        tabBar.itemWidth = 80 // Wider items for more space

        // Remove the bottom border (darker colored line)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = FocusCalendarTheme.backgroundColor
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        
        // Configure stack appearance with Focus Calendar colors
        appearance.stackedLayoutAppearance.normal.iconColor = FocusCalendarTheme.tertiaryTextColor
        appearance.stackedLayoutAppearance.selected.iconColor = FocusCalendarTheme.primaryTextColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: FocusCalendarTheme.tertiaryTextColor,
            .font: FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.caption)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: FocusCalendarTheme.primaryTextColor,
            .font: FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.caption)
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        // Use custom styling for the top border only
        tabBar.layer.borderWidth = 0.0 // Remove the full border
        // Add a custom top border only
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5)
        topBorder.backgroundColor = FocusCalendarTheme.lightBorderColor.cgColor
        tabBar.layer.addSublayer(topBorder)

        // Add tab bar to view
        view.addSubview(tabBar)

        // Position tab bar at bottom of screen with fixed height
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 50) // Fixed height for tab bar
        ])
    }
    
    private func setupViews() {
        // Apply Focus Calendar theme to main view
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
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
            
            // Position each view to fill the space above the tab bar with padding
            NSLayoutConstraint.activate([
                subview.topAnchor.constraint(equalTo: view.topAnchor),
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -5) // Small gap for separation
            ])
            
            // Hide all views initially
            subview.isHidden = true
        }
    }
    
    private func setupSimulationView() {
        // Apply Focus Calendar theme
        simulationView.backgroundColor = FocusCalendarTheme.backgroundColor

        // Add a header view with logo - ensure it's positioned below the status bar
        _ = createHeaderWithLogo(title: "The Pendulum", for: simulationView)

        // Setup the HUD first so we can position other elements relative to it
        setupGameHUD()

        // Create a container for the SpriteKit view with proper constraints
        let skViewContainer = UIView()
        skViewContainer.translatesAutoresizingMaskIntoConstraints = false
        skViewContainer.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        FocusCalendarTheme.styleCard(skViewContainer) // Apply the Focus Calendar styling
        simulationView.addSubview(skViewContainer)

        // Position the SKView container below the game HUD with proper spacing
        // Reduce height to make the pendulum area more compact - focus on the upper region
        NSLayoutConstraint.activate([
            skViewContainer.topAnchor.constraint(equalTo: hudContainer.bottomAnchor, constant: 15),
            skViewContainer.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor, constant: 20),
            skViewContainer.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor, constant: -20),
            // Reduced height to make the container more compact - we don't need to see below 90 degrees
            skViewContainer.heightAnchor.constraint(equalTo: simulationView.heightAnchor, multiplier: 0.32)
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

        // Add control buttons next
        setupSimulationControls(in: simulationView)

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

        // Setup phase space view last
        setupPhaseSpaceView()
    }
    
    private func setupParametersView() {
        // Set background to Focus Calendar theme
        parametersView.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Add a header view with logo
        let headerView = createHeaderWithLogo(title: "Pendulum Parameters", for: parametersView)
        
        // Create a subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Adjust Parameters Below"
        FocusCalendarTheme.styleLabel(subtitleLabel, style: .subheadline)
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
        FocusCalendarTheme.styleCard(parametersContainer)
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
        
        // Style the reset button with Focus Calendar theme
        FocusCalendarTheme.styleButton(resetButton, isPrimary: true)
        resetButton.titleLabel?.font = FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.bodyText)
        
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
        modesView.backgroundColor = FocusCalendarTheme.backgroundColor
        
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

        // Add buttons to top row - Update "Primary" to be a quasi-periodic constant difficulty mode
        // and rename "Dashboard" to "Progressive" for increasing difficulty
        let primaryButton = createModeButton(title: "Primary", tag: 201) // Changed tag to 201 for quasi-periodic mode
        let progressiveButton = createModeButton(title: "Progressive", tag: 202) // Changed from "Dashboard" to "Progressive" and tag to 202
        topRowStack.addArrangedSubview(primaryButton)
        topRowStack.addArrangedSubview(progressiveButton)
        
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
        placeholderLabel.font = FocusCalendarTheme.titleFont
        placeholderLabel.textColor = FocusCalendarTheme.primaryTextColor
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(placeholderLabel)
        
        // Add a visual separator
        let separator = UIView()
        separator.backgroundColor = FocusCalendarTheme.borderColor
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
        let separator = containerView.subviews.last(where: { $0 is UIView && $0.backgroundColor == FocusCalendarTheme.borderColor })
        var previousAnchor = separator?.bottomAnchor ?? containerView.topAnchor

        // Add explanatory text for the game modes
        let modesDescriptionLabel = UILabel()
        modesDescriptionLabel.text = "Game Modes:\n• Primary Mode: Constant difficulty, beat the same level repeatedly while tracking total completions\n• Progressive: Increasing difficulty with each level completion"
        modesDescriptionLabel.font = FocusCalendarTheme.bodyFont
        modesDescriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        modesDescriptionLabel.numberOfLines = 0
        modesDescriptionLabel.textAlignment = .left
        modesDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(modesDescriptionLabel)

        NSLayoutConstraint.activate([
            modesDescriptionLabel.topAnchor.constraint(equalTo: previousAnchor, constant: 20),
            modesDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            modesDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
        ])

        // Update previousAnchor for the rest of the layout
        previousAnchor = modesDescriptionLabel.bottomAnchor

        // Add Perturbation Modes header
        let perturbationHeader = UILabel()
        perturbationHeader.translatesAutoresizingMaskIntoConstraints = false
        perturbationHeader.text = "Available Perturbation Modes"
        perturbationHeader.font = FocusCalendarTheme.largeTitleFont
        perturbationHeader.textColor = FocusCalendarTheme.primaryTextColor
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
        container.tag = tag
        FocusCalendarTheme.styleCard(container)
        
        // Icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = FocusCalendarTheme.primaryTextColor
        iconContainer.layer.cornerRadius = 20
        container.addSubview(iconContainer)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconImageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: iconConfig))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = FocusCalendarTheme.backgroundColor
        iconContainer.addSubview(iconImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = FocusCalendarTheme.titleFont
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = FocusCalendarTheme.bodyFont
        descriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Activate button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Activate", for: .normal)
        button.tag = tag
        FocusCalendarTheme.styleButton(button)
        
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
        separator.backgroundColor = FocusCalendarTheme.borderColor
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
        infoHeader.font = FocusCalendarTheme.largeTitleFont
        infoHeader.textColor = FocusCalendarTheme.primaryTextColor
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
        container.tag = tag
        FocusCalendarTheme.styleCard(container)
        
        // Icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = FocusCalendarTheme.primaryTextColor
        iconContainer.layer.cornerRadius = 20
        container.addSubview(iconContainer)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconImageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: iconConfig))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = FocusCalendarTheme.backgroundColor
        iconContainer.addSubview(iconImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = FocusCalendarTheme.titleFont
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = FocusCalendarTheme.bodyFont
        descriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Learn More button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Learn More", for: .normal)
        button.titleLabel?.font = FocusCalendarTheme.buttonFont
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = FocusCalendarTheme.primaryTextColor
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
        container.backgroundColor = FocusCalendarTheme.backgroundColor
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = FocusCalendarTheme.borderColor.cgColor
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
        titleLabel.font = FocusCalendarTheme.titleFont
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        container.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = FocusCalendarTheme.bodyFont
        descriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        descriptionLabel.numberOfLines = 2
        container.addSubview(descriptionLabel)
        
        // Activate button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Activate", for: .normal)
        button.tag = tag
        FocusCalendarTheme.styleButton(button)
        
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
        FocusCalendarTheme.styleButton(button)
        button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createCompactModeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        FocusCalendarTheme.styleButton(button)
        button.titleLabel?.font = FocusCalendarTheme.bodyFont
        button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createLargeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        FocusCalendarTheme.styleButton(button)
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
        // Play button tap sound
        PendulumSoundManager.shared.playButtonTapSound()
        
        // Handle mode button tap
        let title = "Mode Selected"
        _ = "You selected mode: \(sender.titleLabel?.text ?? "Unknown")"
        
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

        // Game modes
        case 201: // Primary mode (quasi-periodic constant difficulty)
            // Enable quasi-periodic mode where the player beats the same level repeatedly
            viewModel.enableQuasiPeriodicMode()
            // Reset the game but keep stats
            viewModel.resetToLevel1KeepingStats()
            // Update label to reflect the mode
            updateGameMessageLabel("Primary Mode: Beat level 1 repeatedly")
            // Deactivate perturbation for game modes
            deactivatePerturbation()

        case 202: // Progressive mode (increasing difficulty)
            // Enable progressive mode where difficulty increases with each level
            viewModel.enableProgressiveMode()
            // Reset the game with progressive difficulty
            viewModel.resetToLevel1WithProgressiveDifficulty()
            // Update label to reflect the mode
            updateGameMessageLabel("Progressive Mode: Increasing difficulty")
            // Deactivate perturbation for game modes
            deactivatePerturbation()

        // Legacy standard modes (no longer active for game modes)
        case 101, 102, 106:
            // Now just deactivate perturbation but don't change game mode
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
        integrationView.backgroundColor = FocusCalendarTheme.backgroundColor
        
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
        button.backgroundColor = FocusCalendarTheme.accentSage.withAlphaComponent(0.6)
        button.setTitleColor(FocusCalendarTheme.primaryTextColor, for: .normal)
        button.titleLabel?.font = FocusCalendarTheme.titleFont
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
        
        // Add Instagram button with icon
        let instagramButton = createSocialButton(title: "Instagram", iconName: "instagram-removebg-preview", tag: 302)
        
        // Add Facebook button with icon
        let facebookButton = createSocialButton(title: "Facebook", iconName: "facebook-removebg-preview", tag: 303)
        
        stackView.addArrangedSubview(instagramButton)
        stackView.addArrangedSubview(facebookButton)
        
        return stackView
    }
    
    private func createSocialButton(title: String, iconName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = FocusCalendarTheme.borderColor.cgColor
        button.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
        
        // Create icon image
        if let icon = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal) {
            let resizedIcon = PendulumViewController.resizeImage(icon, targetSize: CGSize(width: 24, height: 24))
            button.setImage(resizedIcon, for: .normal)
        }
        
        // Configure title
        button.setTitle(title, for: .normal)
        button.setTitleColor(FocusCalendarTheme.primaryTextColor, for: .normal)
        button.titleLabel?.font = FocusCalendarTheme.buttonFont
        
        // Adjust button layout
        // imageEdgeInsets is deprecated, using configuration instead
        // titleEdgeInsets is deprecated, using configuration instead
        
        return button
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
        
        // Data view button titles, tags, and icons
        let buttonData = [
            ("View Data", 304, "general1-removebg-preview"),
            ("View Manifolds", 305, "general14-removebg-preview"),
            ("View Surjective Submersions", 306, "general4-removebg-preview"),
            ("View Sheaf", 307, "general7-removebg-preview"),
            ("View Morphisms", 308, "general8-removebg-preview"),
            ("View Category", 309, "fibonacciColor"),
            ("View Functor", 400, "tesseract")
        ]
        
        // Create data view buttons
        for (title, tag, iconName) in buttonData {
            let button = createDataButton(title: title, iconName: iconName, tag: tag)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createDataButton(title: String, iconName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.backgroundColor = FocusCalendarTheme.backgroundColor.withAlphaComponent(0.8)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = FocusCalendarTheme.borderColor.cgColor
        button.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
        
        // Create icon image
        if let icon = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal) {
            let resizedIcon = PendulumViewController.resizeImage(icon, targetSize: CGSize(width: 20, height: 20))
            button.setImage(resizedIcon, for: .normal)
        }
        
        // Configure title
        button.setTitle(title, for: .normal)
        button.setTitleColor(FocusCalendarTheme.primaryTextColor, for: .normal)
        button.titleLabel?.font = FocusCalendarTheme.buttonFont
        
        // Adjust button layout
        // imageEdgeInsets is deprecated, using configuration instead
        // titleEdgeInsets is deprecated, using configuration instead
        
        // Set height constraint
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        return button
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
        
        // Connection button titles, tags, and icons
        let buttonData = [
            ("Connect The Maze", 310, "TheMazeLogo-removebg-preview"),
            ("Connect The Focus Calendar", 311, "FocusCalendarLogo-removebg-preview")
        ]
        
        // Create connection buttons
        for (title, tag, iconName) in buttonData {
            let button = createConnectionButton(title: title, iconName: iconName, tag: tag)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createConnectionButton(title: String, iconName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.backgroundColor = FocusCalendarTheme.accentSage.withAlphaComponent(0.6)
        button.layer.cornerRadius = 15
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(integrationButtonTapped(_:)), for: .touchUpInside)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        
        // Create icon image
        if let icon = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal) {
            let resizedIcon = PendulumViewController.resizeImage(icon, targetSize: CGSize(width: 28, height: 28))
            button.setImage(resizedIcon, for: .normal)
        }
        
        // Configure title
        button.setTitle(title, for: .normal)
        button.setTitleColor(FocusCalendarTheme.primaryTextColor, for: .normal)
        button.titleLabel?.font = FocusCalendarTheme.buttonFont
        
        // Adjust button layout
        // imageEdgeInsets is deprecated, using configuration instead
        // titleEdgeInsets is deprecated, using configuration instead
        
        return button
    }
    
    @objc private func integrationButtonTapped(_ sender: UIButton) {
        // Play button tap sound
        PendulumSoundManager.shared.playButtonTapSound()
        
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
        settingsView.backgroundColor = FocusCalendarTheme.backgroundColor
        
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
                "None", "AI", "Acadia", "Fluid", "Immersive Topology", "Joshua Tree", 
                "Outer Space", "Parchment", "Sachuest", "The Maze Guide", "The Portraits", "TSP"
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
        aboutButton.setTitleColor(FocusCalendarTheme.primaryTextColor, for: .normal)
        aboutButton.titleLabel?.font = FocusCalendarTheme.buttonFont
        aboutButton.contentHorizontalAlignment = .left
        aboutButton.addTarget(self, action: #selector(showAboutInfo), for: .touchUpInside)
        
        let versionLabel = UILabel()
        versionLabel.text = "Version 1.0.0"
        versionLabel.font = FocusCalendarTheme.bodyFont
        versionLabel.textColor = FocusCalendarTheme.tertiaryTextColor
        versionLabel.textAlignment = .left
        
        let aboutStack = UIStackView(arrangedSubviews: [aboutButton, versionLabel])
        aboutStack.axis = .vertical
        aboutStack.spacing = 5
        aboutStack.translatesAutoresizingMaskIntoConstraints = false
        
        let separator = UIView()
        separator.backgroundColor = FocusCalendarTheme.borderColor
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
        titleLabel.font = FocusCalendarTheme.largeTitleFont
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(titleLabel)
        
        // Options container (shows current selection with dropdown indicator)
        let optionsContainer = UIView()
        optionsContainer.backgroundColor = FocusCalendarTheme.cardBackgroundColor
        optionsContainer.layer.cornerRadius = 12
        optionsContainer.layer.borderWidth = 1
        optionsContainer.layer.borderColor = FocusCalendarTheme.borderColor.cgColor
        optionsContainer.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(optionsContainer)
        
        // Current selection label
        let selectionLabel = UILabel()
        
        // Get saved selection or appropriate default
        let savedSelection = UserDefaults.standard.string(forKey: "setting_\(title)")
        let defaultSelection: String
        
        // Set appropriate defaults for each section
        switch title {
        case "Graphics":
            defaultSelection = "Standard"
        case "Metrics":
            defaultSelection = "Basic"
        case "Sounds":
            defaultSelection = "Standard"
        case "Backgrounds":
            defaultSelection = "AI"  // Changed from "None" to "AI" for testing
        default:
            defaultSelection = options[0]
        }
        
        // Use saved selection if available and valid, otherwise use default
        if let saved = savedSelection, options.contains(saved) {
            selectionLabel.text = saved
        } else {
            selectionLabel.text = defaultSelection
            // Save the default if nothing was saved
            UserDefaults.standard.set(defaultSelection, forKey: "setting_\(title)")
        }
        
        selectionLabel.font = FocusCalendarTheme.bodyFont
        selectionLabel.textColor = .black
        selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(selectionLabel)
        
        // Dropdown icon
        let dropdownImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        dropdownImageView.tintColor = FocusCalendarTheme.primaryTextColor
        dropdownImageView.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(dropdownImageView)
        
        // Create options grid
        let optionsStack = UIStackView()
        optionsStack.axis = .vertical
        optionsStack.spacing = 10
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(optionsStack)
        
        // Determine number of buttons per row based on section
        let buttonsPerRow = (title == "Backgrounds") ? 3 : 3  // 3 buttons per row for backgrounds too
        let numberOfRows = Int(ceil(Double(options.count) / Double(buttonsPerRow)))
        
        // Create rows dynamically
        for row in 0..<numberOfRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually
            
            let startIndex = row * buttonsPerRow
            let endIndex = min(startIndex + buttonsPerRow, options.count)
            
            for i in startIndex..<endIndex {
                let optionButton = createOptionButton(title: options[i], section: title, isSelected: i == 0)
                rowStack.addArrangedSubview(optionButton)
            }
            
            // If this is the last row and it's not full, add spacer views
            if endIndex < startIndex + buttonsPerRow {
                for _ in endIndex..<(startIndex + buttonsPerRow) {
                    let spacerView = UIView()
                    rowStack.addArrangedSubview(spacerView)
                }
            }
            
            optionsStack.addArrangedSubview(rowStack)
        }
        
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
        button.titleLabel?.font = FocusCalendarTheme.bodyFont
        button.setTitleColor(isSelected ? FocusCalendarTheme.cardBackgroundColor : FocusCalendarTheme.primaryTextColor, for: .normal)
        button.backgroundColor = isSelected ? FocusCalendarTheme.primaryTextColor : FocusCalendarTheme.cardBackgroundColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = FocusCalendarTheme.borderColor.cgColor
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
        // Play button tap sound
        PendulumSoundManager.shared.playButtonTapSound()
        
        // Get the section from the button's accessibilityIdentifier
        if let section = sender.accessibilityIdentifier {
            // Get the selected title
            if let title = sender.title(for: .normal) {
                // Update the selection in the UserDefaults
                UserDefaults.standard.set(title, forKey: "setting_\(section)")
                
                // Update UI
                updateSettingSelection(section: section, selection: title)
                
                // If this is a sound setting, update the sound manager
                if section == "Sounds" {
                    PendulumSoundManager.shared.updateSoundMode(title)
                } else if section == "Backgrounds" {
                    BackgroundManager.shared.updateBackgroundMode(title)
                    // Apply new background to all tabs after a small delay to ensure views are ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        BackgroundManager.shared.applyBackgroundToAllTabs(in: self)
                    }
                }
                
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
                    button.backgroundColor = isSelected ? FocusCalendarTheme.primaryTextColor : FocusCalendarTheme.cardBackgroundColor
                    button.setTitleColor(isSelected ? FocusCalendarTheme.cardBackgroundColor : FocusCalendarTheme.primaryTextColor, for: .normal)
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
        container.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor.withAlphaComponent(0.7)
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 1
        container.layer.borderColor = FocusCalendarTheme.borderColor.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 3
        
        // Get units for the parameter
        let units = getUnitsForParameter(title)
        
        // Title label with units
        let titleLabel = UILabel()
        titleLabel.text = "\(title) (\(units))"
        titleLabel.font = FocusCalendarTheme.titleFont
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Value label with formatted value and initial non-zero value
        let valueLabel = UILabel()
        // Use a non-zero initial value even before slider is set
        let initialValue = getDefaultValueForParameter(title)
        valueLabel.text = formatParameterValue(title, value: initialValue)
        valueLabel.font = FocusCalendarTheme.buttonFont
        valueLabel.textAlignment = .right
        valueLabel.textColor = FocusCalendarTheme.accentSlate
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        // Add description label between title and slider
        let descriptionLabel = UILabel()
        descriptionLabel.text = getDescriptionForParameter(title)
        descriptionLabel.font = FocusCalendarTheme.bodyFont
        descriptionLabel.textColor = FocusCalendarTheme.secondaryTextColor
        descriptionLabel.numberOfLines = 0 // Allow multiple lines
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descriptionLabel)
        
        // Store the value label for updates
        slider.tag = Int(bitPattern: Unmanaged.passUnretained(valueLabel).toOpaque())
        
        // Configure slider appearance
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = FocusCalendarTheme.primaryTextColor
        slider.thumbTintColor = FocusCalendarTheme.accentGold
        slider.maximumTrackTintColor = FocusCalendarTheme.secondaryBackgroundColor
        
        // Create custom track height appearance
        slider.setMinimumTrackImage(createSliderTrackImage(color: FocusCalendarTheme.primaryTextColor), for: .normal)
        slider.setMaximumTrackImage(createSliderTrackImage(color: FocusCalendarTheme.secondaryBackgroundColor), for: .normal)
        
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
    
    // Helper function to resize images for tab bar
    private static func resizeImage(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        // Preserve the original rendering mode
        return resizedImage.withRenderingMode(.alwaysOriginal)
    }
    
    // Create a header view with the Pendulum logo
    private func createHeaderWithLogo(title: String, for containerView: UIView) -> UIView {
        // Create the styled header with consistent styling - use same method as Dashboard
        let headerView = HeaderViewCreator.createHeaderView(title: title)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerView)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Move header down from the top edge to avoid system status bar
            headerView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 40)
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
        // Container for game HUD elements - using Focus Calendar theme
        hudContainer = UIView()
        FocusCalendarTheme.styleCard(hudContainer)
        hudContainer.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(hudContainer)

        // Get header view to position the HUD properly - look for the header created by HeaderViewCreator
        let headerView = simulationView.subviews.first { view in
            // The header is a UIView containing a UILabel created by HeaderViewCreator
            return view.subviews.contains(where: { $0 is UILabel || $0 is UIImageView })
        }

        // Score label - moved to the top
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .left
        scoreLabel.font = FocusCalendarTheme.Fonts.titleFont(size: FocusCalendarTheme.Fonts.Size.bodyText)
        scoreLabel.textColor = FocusCalendarTheme.primaryTextColor
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(scoreLabel)

        // Level label
        levelLabel = UILabel()
        levelLabel.text = "Level: 1"
        levelLabel.textAlignment = .center
        levelLabel.font = FocusCalendarTheme.Fonts.titleFont(size: FocusCalendarTheme.Fonts.Size.bodyText)
        levelLabel.textColor = FocusCalendarTheme.primaryTextColor
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(levelLabel)

        // Time label
        timeLabel = UILabel()
        timeLabel.text = "Time: 0.0s"
        timeLabel.textAlignment = .right
        timeLabel.font = FocusCalendarTheme.Fonts.titleFont(size: FocusCalendarTheme.Fonts.Size.bodyText)
        timeLabel.textColor = FocusCalendarTheme.primaryTextColor
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.addSubview(timeLabel)

        // Game message label (for game over messages)
        gameMessageLabel = UILabel()
        gameMessageLabel.text = "Balance the Inverted Pendulum!"
        gameMessageLabel.textAlignment = .center
        gameMessageLabel.font = FocusCalendarTheme.Fonts.titleFont(size: FocusCalendarTheme.Fonts.Size.bodyText)
        gameMessageLabel.textColor = FocusCalendarTheme.accentRose // Using rose accent for warnings
        gameMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        gameMessageLabel.isHidden = true
        hudContainer.addSubview(gameMessageLabel)

        // Position HUD below the header with proper spacing
        NSLayoutConstraint.activate([
            // Position HUD properly below the header with more space
            hudContainer.topAnchor.constraint(equalTo: headerView?.bottomAnchor ?? simulationView.safeAreaLayoutGuide.topAnchor, constant: 10),
            hudContainer.leadingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hudContainer.trailingAnchor.constraint(equalTo: simulationView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            // Increased height to accommodate both level label and game message without overlap
            hudContainer.heightAnchor.constraint(equalToConstant: 65),

            // Single row with score, level, and time evenly spaced
            scoreLabel.centerYAnchor.constraint(equalTo: hudContainer.centerYAnchor),
            scoreLabel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor, constant: 20),
            scoreLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.28),

            // Reposition level label to the top part of the container to prevent overlap
            levelLabel.topAnchor.constraint(equalTo: hudContainer.topAnchor, constant: 5),
            levelLabel.centerXAnchor.constraint(equalTo: hudContainer.centerXAnchor),
            levelLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.28),

            timeLabel.centerYAnchor.constraint(equalTo: hudContainer.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor, constant: -20),
            timeLabel.widthAnchor.constraint(equalTo: hudContainer.widthAnchor, multiplier: 0.28),

            // Position game message in the bottom part of the container
            gameMessageLabel.centerXAnchor.constraint(equalTo: hudContainer.centerXAnchor),
            gameMessageLabel.bottomAnchor.constraint(equalTo: hudContainer.bottomAnchor, constant: -5),
            gameMessageLabel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor, constant: 20),
            gameMessageLabel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor, constant: -20)
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
        FocusCalendarTheme.styleCard(phaseSpaceContainer)
        simulationView.addSubview(phaseSpaceContainer)

        // Create a label for the phase space
        phaseSpaceLabel = UILabel()
        phaseSpaceLabel.text = "Phase Space"
        phaseSpaceLabel.textAlignment = .center
        FocusCalendarTheme.styleLabel(phaseSpaceLabel, style: .sectionHeader)
        phaseSpaceLabel.translatesAutoresizingMaskIntoConstraints = false
        simulationView.addSubview(phaseSpaceLabel)

        // Create phase space view
        phaseSpaceView = PhaseSpaceView(frame: .zero)
        phaseSpaceView.translatesAutoresizingMaskIntoConstraints = false
        phaseSpaceContainer.addSubview(phaseSpaceView)

        // Position the phase space below the controls with proper constraints
        // Give more vertical space to the phase space view now that pendulum area is smaller
        NSLayoutConstraint.activate([
            // Position label below the control panel with reduced spacing
            phaseSpaceLabel.topAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: 10),
            phaseSpaceLabel.centerXAnchor.constraint(equalTo: simulationView.centerXAnchor),

            // Position container below the label with increased height
            phaseSpaceContainer.topAnchor.constraint(equalTo: phaseSpaceLabel.bottomAnchor, constant: 5),
            phaseSpaceContainer.centerXAnchor.constraint(equalTo: simulationView.centerXAnchor),
            phaseSpaceContainer.widthAnchor.constraint(equalTo: simulationView.widthAnchor, multiplier: 0.85),
            // Connect to the simulationView's bottom instead (which is already constrained to the tab bar)
            phaseSpaceContainer.bottomAnchor.constraint(equalTo: simulationView.bottomAnchor, constant: -5), // Small gap at bottom

            // Position the phase space view within its container
            phaseSpaceView.topAnchor.constraint(equalTo: phaseSpaceContainer.topAnchor, constant: 10),
            phaseSpaceView.leadingAnchor.constraint(equalTo: phaseSpaceContainer.leadingAnchor, constant: 10),
            phaseSpaceView.trailingAnchor.constraint(equalTo: phaseSpaceContainer.trailingAnchor, constant: -10),
            phaseSpaceView.bottomAnchor.constraint(equalTo: phaseSpaceContainer.bottomAnchor, constant: -10)
        ])

        // Start update timer for phase space
        dashboardUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Add the current state as a moving point
            self.phaseSpaceView.addPoint(
                theta: self.viewModel.currentState.theta,
                omega: self.viewModel.currentState.thetaDot
            )
        }
    }

    private func updateGameHUD() {
        // Update score and basic stats
        scoreLabel.text = "Score: \(viewModel.score)"
        levelLabel.text = "Level: \(viewModel.currentLevel)"
        timeLabel.text = String(format: "Time: %.1fs", viewModel.totalBalanceTime)

        // Update message based on game state
        if !viewModel.isGameActive && viewModel.gameOverReason != nil {
            gameMessageLabel.text = viewModel.gameOverReason
            gameMessageLabel.isHidden = false

            // For level completion, use special formatting
            if viewModel.gameOverReason!.contains("completed") {
                gameMessageLabel.textColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
                // Play achievement sound for level completion
                PendulumSoundManager.shared.playAchievementSound()
                // Cycle background when level is completed
                BackgroundManager.shared.cycleBackground(for: simulationView)
            } else if viewModel.gameOverReason!.contains("Level") && !viewModel.gameOverReason!.contains("completed") {
                // For level announcement, use blue
                gameMessageLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)
                // Play level start sound
                PendulumSoundManager.shared.playLevelStartSound()
            } else {
                // For failure, use red
                gameMessageLabel.textColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
                // Play failure sound
                PendulumSoundManager.shared.playFailureSound()
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
            FocusCalendarTheme.styleButton(button, isPrimary: false)
            button.titleLabel?.font = FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.bodyText)
        }

        // Apply styles to buttons
        [startButton, stopButton, pushLeftButton, pushRightButton].forEach(buttonStyle)

        // Special styling for Start/Stop buttons using Focus Calendar theme
        FocusCalendarTheme.styleButton(startButton, isPrimary: true)
        startButton.backgroundColor = FocusCalendarTheme.accentSage // Sage green for start

        FocusCalendarTheme.styleButton(stopButton, isPrimary: true)
        stopButton.backgroundColor = FocusCalendarTheme.accentRose // Rose for stop

        // Set plain text button titles to avoid symbol confusion
        startButton.setTitle("Start", for: .normal)
        stopButton.setTitle("Stop", for: .normal)
        pushLeftButton.setTitle("← Push", for: .normal)
        pushRightButton.setTitle("Push →", for: .normal)

        // Create a container for the buttons with Focus Calendar styling
        controlPanel = UIView()
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        FocusCalendarTheme.styleCard(controlPanel)
        parentView.addSubview(controlPanel)

        // Create button stacks for better organization - using vertical layout
        // Row 1: Start/Stop buttons
        let simulationControlsStack = UIStackView()
        simulationControlsStack.axis = .horizontal
        simulationControlsStack.distribution = .fillEqually
        simulationControlsStack.spacing = 20 // Increased spacing between buttons
        simulationControlsStack.translatesAutoresizingMaskIntoConstraints = false
        simulationControlsStack.addArrangedSubview(startButton)
        simulationControlsStack.addArrangedSubview(stopButton)

        // Row 2: Push buttons
        let forceControlsStack = UIStackView()
        forceControlsStack.axis = .horizontal
        forceControlsStack.distribution = .fillEqually
        forceControlsStack.spacing = 20 // Increased spacing between buttons
        forceControlsStack.translatesAutoresizingMaskIntoConstraints = false
        forceControlsStack.addArrangedSubview(pushLeftButton)
        forceControlsStack.addArrangedSubview(pushRightButton)

        // Main control stack - vertical layout with tighter spacing
        let controlStack = UIStackView()
        controlStack.axis = .vertical
        controlStack.spacing = 10 // Reduced spacing between rows for a more compact layout
        controlStack.distribution = .fillEqually // Ensure equal height for both rows
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.addArrangedSubview(simulationControlsStack)
        controlStack.addArrangedSubview(forceControlsStack)

        controlPanel.addSubview(controlStack)

        // Get the SKView container to position controls relative to it
        let skViewContainer = parentView.subviews.first { $0.backgroundColor == .white && $0.layer.cornerRadius > 0 }

        // Layout constraints
        NSLayoutConstraint.activate([
            // Position control panel immediately below the SpriteKit view with minimal spacing
            controlPanel.topAnchor.constraint(equalTo: skViewContainer?.bottomAnchor ?? parentView.centerYAnchor, constant: 10), // Reduced spacing
            controlPanel.leadingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            controlPanel.heightAnchor.constraint(equalToConstant: 100), // Slightly reduced height to be more compact

            // Control stack - fill the container with a bit more padding
            controlStack.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 10), // Increased padding
            controlStack.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 15), // Increased padding
            controlStack.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -15), // Increased padding
            controlStack.bottomAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: -10), // Increased padding

            // Make buttons have a minimum height
            startButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            stopButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            pushLeftButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            pushRightButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
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
            
            // Cycle background when restarting
            BackgroundManager.shared.cycleBackground(for: simulationView)
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
        // Play tab selection sound
        PendulumSoundManager.shared.playButtonTapSound()
        
        // First stop any dashboard updates to avoid unnecessary refreshes
        stopDashboardUpdates()
        
        // Get the view for the selected tab
        var selectedView: UIView?
        
        switch item.tag {
        case 0: // Simulation
            selectedView = simulationView
            showView(simulationView)
        case 1: // Dashboard
            selectedView = dashboardView
            updateDashboardStats() // Update stats before showing (this will start the timer)
            showView(dashboardView)
        case 2: // Modes
            selectedView = modesView
            // Set up perturbation system if not already done
            if perturbationManager == nil {
                setupPerturbationSystem()
            }
            showView(modesView)
        case 3: // Integration
            selectedView = integrationView
            showView(integrationView)
        case 4: // Parameters
            selectedView = parametersView
            showView(parametersView)
        case 5: // Settings
            selectedView = settingsView
            showView(settingsView)
        default:
            break
        }
        
        // Cycle background for the selected view
        if let view = selectedView {
            BackgroundManager.shared.cycleBackground(for: view)
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