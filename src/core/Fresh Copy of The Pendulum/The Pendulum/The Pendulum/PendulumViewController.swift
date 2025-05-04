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
    private let infoItem = UITabBarItem(title: "Info", image: UIImage(systemName: "info.circle"), tag: 5)
    
    // Views for different tabs
    let simulationView = UIView()
    let dashboardView = UIView()
    let modesView = UIView()
    let integrationView = UIView()
    let parametersView = UIView()
    let infoView = UIView()
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
        // Configure tab bar with Golden Enterprises theme
        tabBar.delegate = self
        tabBar.items = [simulationItem, dashboardItem, modesItem, integrationItem, parametersItem, infoItem]
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
        setupInfoView()
        
        // Add views to main view
        [simulationView, dashboardView, modesView, integrationView, parametersView, infoView].forEach { subview in
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
        
        // Add a header view at the top
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        simulationView.addSubview(headerView)
        
        // Add gradient to header
        DispatchQueue.main.async {
            let gradientLayer = GoldenGradients.createHeaderGradient(for: headerView)
            headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add title to header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "The Pendulum"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: simulationView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: simulationView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: simulationView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
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
        
        // Add a header view
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        parametersView.addSubview(headerView)
        
        // Add gradient to header
        DispatchQueue.main.async {
            let gradientLayer = GoldenGradients.createHeaderGradient(for: headerView)
            headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add title to header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pendulum Parameters"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: parametersView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
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
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor, constant: -20),
            
            // Parameters container
            parametersContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
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
        
        // Add a header view
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        modesView.addSubview(headerView)
        
        // Add gradient to header
        DispatchQueue.main.async {
            let gradientLayer = GoldenGradients.createHeaderGradient(for: headerView)
            headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add title to header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pendulum Modes"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: modesView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: modesView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: modesView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
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
        
        // Set a minimum height for the content - increased to accommodate all buttons
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1000).isActive = true
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
            ("Random Impulses", "impulse", "Random forces applied at unpredictable intervals", "wind"),
            ("Sine Wave", "sine", "Smooth oscillating forces with adjustable frequency", "waveform"),
            ("Data-Driven", "data", "Forces from external datasets or recordings", "doc.text"),
            ("Compound", "compound", "Complex combination of multiple perturbation types", "function"),
            ("No Perturbation", "none", "Standard pendulum with gravity only", "xmark.circle")
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
            updateStatusLabel("This perturbation mode will be available soon")
        
        // Standard modes
        case 101, 102, 106:
            // Primary, Dashboard, and Focal Calculator - no perturbation
            deactivatePerturbation()
            
        // Original unified perturbation buttons (300-304)
        case 300: // Random Impulses (new)
            activateSpecialPerturbation("impulse")
        case 301: // Sine Wave (new)
            activateSpecialPerturbation("sine")
        case 302: // Data-Driven (new)
            activateSpecialPerturbation("data")
        case 303: // Compound (new)
            activateSpecialPerturbation("compound")
        case 304: // No Perturbation (new)
            deactivatePerturbation()
            
        default:
            // By default, deactivate perturbations
            deactivatePerturbation()
        }
    }
    
    // MARK: - Integration View Setup
    
    private func setupIntegrationView() {
        // Set background to Golden Enterprises theme
        integrationView.backgroundColor = .goldenBackground
        
        // Add a header view
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        integrationView.addSubview(headerView)
        
        // Add gradient to header
        DispatchQueue.main.async {
            let gradientLayer = GoldenGradients.createHeaderGradient(for: headerView)
            headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add title to header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pendulum Integrations"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: integrationView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: integrationView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: integrationView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
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
    
    private func setupInfoView() {
        // Set background to Golden Enterprises theme
        infoView.backgroundColor = .goldenBackground
        
        // Add a header view
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .goldenPrimary
        infoView.addSubview(headerView)
        
        // Add gradient to header
        DispatchQueue.main.async {
            let gradientLayer = GoldenGradients.createHeaderGradient(for: headerView)
            headerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Add title to header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "About The Pendulum"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: infoView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Create scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(scrollView)
        
        // Create content view inside scroll view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Content title (distinct from header)
        let contentTitleLabel = UILabel()
        contentTitleLabel.text = "Golden Enterprise Solutions"
        contentTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        contentTitleLabel.textColor = .goldenDark
        contentTitleLabel.textAlignment = .center
        contentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentTitleLabel)
        
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
        descriptionTextView.textColor = .goldenText
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
        
        // Get units for the parameter
        let units = getUnitsForParameter(title)
        
        // Title label with units
        let titleLabel = UILabel()
        titleLabel.text = "\(title) (\(units))"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Value label with formatted value and initial non-zero value
        let valueLabel = UILabel()
        // Use a non-zero initial value even before slider is set
        let initialValue = getDefaultValueForParameter(title)
        valueLabel.text = formatParameterValue(title, value: initialValue)
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
        dashboardView.isHidden = true
        modesView.isHidden = true
        integrationView.isHidden = true
        parametersView.isHidden = true
        infoView.isHidden = true
        
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
        // Stop the simulation
        viewModel.stopSimulation()
        
        // Make the game inactive but don't reset score
        viewModel.isGameActive = false
        
        // Show message that game is paused
        updateStatusLabel("Game paused")
        
        // Change button text to reflect state
        startButton.setTitle("▶ Resume", for: .normal)
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
        updateStatusLabel("Mass updated to \(String(format: "%.2f", massSlider.value)) kg")
    }
    
    @objc private func lengthSliderChanged() {
        viewModel.length = Double(lengthSlider.value)
        updateStatusLabel("Length updated to \(String(format: "%.2f", lengthSlider.value)) m")
    }
    
    @objc private func dampingSliderChanged() {
        viewModel.damping = Double(dampingSlider.value)
        updateStatusLabel("Damping updated to \(String(format: "%.3f", dampingSlider.value)) Ns/m")
    }
    
    @objc private func gravitySliderChanged() {
        viewModel.gravity = Double(gravitySlider.value)
        updateStatusLabel("Gravity updated to \(String(format: "%.2f", gravitySlider.value)) m/s²")
    }
    
    @objc private func forceStrengthSliderChanged() {
        viewModel.forceStrength = Double(forceStrengthSlider.value)
        updateStatusLabel("Force strength updated to \(String(format: "%.2f", forceStrengthSlider.value))x")
    }
    
    @objc private func springConstantSliderChanged() {
        viewModel.springConstant = Double(springConstantSlider.value)
        updateStatusLabel("Spring constant updated to \(String(format: "%.2f", springConstantSlider.value)) N/m")
    }
    
    @objc private func momentOfInertiaSliderChanged() {
        viewModel.momentOfInertia = Double(momentOfInertiaSlider.value)
        updateStatusLabel("Moment of inertia updated to \(String(format: "%.2f", momentOfInertiaSlider.value)) kg·m²")
    }
    
    @objc private func initialPerturbationSliderChanged() {
        viewModel.setInitialPerturbation(Double(initialPerturbationSlider.value))
        updateStatusLabel("Initial perturbation set to \(String(format: "%.1f", initialPerturbationSlider.value))°")
    }
    
    // Show a temporary status message with visual feedback
    private func updateStatusLabel(_ message: String) {
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
        case 5: // Info
            showView(infoView)
        default:
            break
        }
    }
    
    // MARK: - Perturbation Management
    
    private var perturbationManager: PerturbationManager?
    
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
        
        // Activate the profile
        perturbationManager?.activateProfile(profile)
        
        // Show confirmation
        let modeName = profile.name
        updateStatusLabel("Activated \(modeName) mode")
    }
    
    private func activateSpecialPerturbation(_ type: String) {
        // Create custom profile based on perturbation type
        var profile: PerturbationProfile
        
        switch type {
        case "impulse":
            profile = PerturbationProfile(
                name: "Random Impulses",
                types: [.impulse],
                strength: 1.0,
                frequency: 0.0,
                randomInterval: 2.0...4.0,
                dataSource: nil,
                showWarnings: true
            )
        case "sine":
            profile = PerturbationProfile(
                name: "Sine Wave",
                types: [.sine],
                strength: 0.8,
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
                strength: 1.0,
                frequency: 0.4,
                randomInterval: 2.0...4.0,
                dataSource: "PerturbationData.csv",
                showWarnings: true,
                subProfiles: [
                    PerturbationProfile(
                        name: "Base Sine",
                        types: [.sine],
                        strength: 0.7,
                        frequency: 0.3,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Random Impulses",
                        types: [.impulse],
                        strength: 1.0,
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
        
        // Activate the profile
        perturbationManager?.activateProfile(profile)
        
        // Show confirmation
        updateStatusLabel("Activated \(profile.name) perturbation")
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
        
        // Set the empty profile
        perturbationManager?.activateProfile(emptyProfile)
        
        // Show confirmation
        updateStatusLabel("Perturbations disabled")
    }
}