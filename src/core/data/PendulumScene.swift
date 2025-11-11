import SpriteKit

class PendulumScene: SKScene {
    // The pendulum model that handles the physics
    private var pendulum: InvertedPendulumModel!
    
    // Visual elements
    private var pendulumPivot: SKShapeNode!
    private var pendulumRod: SKShapeNode!
    private var pendulumBob: SKShapeNode!
    private var trailNode: SKNode!
    
    // Control buttons
    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    private var resetButton: SKShapeNode!
    
    // Debug label
    private var debugLabel: SKLabelNode!
    
    // Timing variables
    private var lastUpdateTime: TimeInterval = 0
    private var force: Double = 0.0
    private let timeStep: Double = 1.0/60.0
    
    // Setup flag to ensure we only do it once
    private var isSetup = false
    
    override func didMove(to view: SKView) {
        // Set up the scene
        backgroundColor = .black
        
        // Configure the view
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        
        // Delay the setup to ensure scene sizing is correct
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.setupSimulation()
            self.setupPendulumVisuals()
            self.setupControls()
            self.setupDebugLabel()
            self.isSetup = true
            print("PendulumScene: Setup complete")
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupSimulation() {
        // Create the pendulum model with default parameters
        pendulum = InvertedPendulumModel(
            mass: 1.0,
            length: 1.0,
            gravity: 9.81,
            damping: 0.1,
            springConstant: 5.0,
            momentOfInertia: 1.0,
            driveFrequency: 0.0,
            driveAmplitude: 0.0
        )
        
        // Initialize with a small push
        pendulum.reset()
        pendulum.applyForce(0.1)
        print("PendulumScene: Simulation initialized")
    }
    
    private func setupPendulumVisuals() {
        let pendulumLength = frame.height * 0.3
        
        // Create the pivot point (fixed at the top)
        pendulumPivot = SKShapeNode(circleOfRadius: 6)
        pendulumPivot.fillColor = .gray
        pendulumPivot.strokeColor = .white
        pendulumPivot.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(pendulumPivot)
        
        // Create the trail node
        trailNode = SKNode()
        addChild(trailNode)
        
        // Create the rod
        pendulumRod = SKShapeNode()
        pendulumRod.strokeColor = .white
        pendulumRod.lineWidth = 2
        addChild(pendulumRod)
        
        // Create the bob (the ball at the end)
        pendulumBob = SKShapeNode(circleOfRadius: 20)
        pendulumBob.fillColor = .red
        pendulumBob.strokeColor = .red
        addChild(pendulumBob)
        
        // Set the initial position
        updatePendulumPosition(angle: pendulum.currentState.theta)
        print("PendulumScene: Visuals created")
    }
    
    private func setupControls() {
        let buttonSize = CGSize(width: 100, height: 50)
        let buttonY = frame.minY + 100
        
        // Create left button
        leftButton = SKShapeNode(rectOf: buttonSize)
        leftButton.position = CGPoint(x: frame.midX - 120, y: buttonY)
        leftButton.fillColor = .blue
        leftButton.strokeColor = .white
        leftButton.name = "leftButton"
        addChild(leftButton)
        
        let leftLabel = SKLabelNode(text: "←")
        leftLabel.fontSize = 24
        leftLabel.fontColor = .white
        leftLabel.position = CGPoint(x: 0, y: -8)
        leftButton.addChild(leftLabel)
        
        // Create right button
        rightButton = SKShapeNode(rectOf: buttonSize)
        rightButton.position = CGPoint(x: frame.midX + 120, y: buttonY)
        rightButton.fillColor = .blue
        rightButton.strokeColor = .white
        rightButton.name = "rightButton"
        addChild(rightButton)
        
        let rightLabel = SKLabelNode(text: "→")
        rightLabel.fontSize = 24
        rightLabel.fontColor = .white
        rightLabel.position = CGPoint(x: 0, y: -8)
        rightButton.addChild(rightLabel)
        
        // Create reset button
        resetButton = SKShapeNode(rectOf: buttonSize)
        resetButton.position = CGPoint(x: frame.midX, y: buttonY)
        resetButton.fillColor = .gray
        resetButton.strokeColor = .white
        resetButton.name = "resetButton"
        addChild(resetButton)
        
        let resetLabel = SKLabelNode(text: "Reset")
        resetLabel.fontSize = 18
        resetLabel.fontColor = .white
        resetLabel.position = CGPoint(x: 0, y: -8)
        resetButton.addChild(resetLabel)
        
        print("PendulumScene: Controls created")
    }
    
    private func setupDebugLabel() {
        debugLabel = SKLabelNode(text: "State: Initializing")
        debugLabel.fontSize = 14
        debugLabel.fontColor = .white
        debugLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(debugLabel)
    }
    
    // MARK: - Update Methods
    
    private func updatePendulumPosition(angle: Double) {
        let pendulumLength = frame.height * 0.3
        let pivotX = pendulumPivot.position.x
        let pivotY = pendulumPivot.position.y
        
        // Calculate end position of pendulum
        let sinTheta = CGFloat(sin(angle))
        let cosTheta = CGFloat(cos(angle))
        
        let bobX = pivotX + pendulumLength * sinTheta
        let bobY = pivotY - pendulumLength * cosTheta
        
        // Update rod path
        let path = CGMutablePath()
        path.move(to: CGPoint(x: pivotX, y: pivotY))
        path.addLine(to: CGPoint(x: bobX, y: bobY))
        pendulumRod.path = path
        
        // Update bob position
        pendulumBob.position = CGPoint(x: bobX, y: bobY)
        
        // Add dot to trail
        if abs(pendulum.currentState.thetaDot) > 0.1 {
            let trailDot = SKShapeNode(circleOfRadius: 2)
            trailDot.fillColor = .red
            trailDot.alpha = 0.5
            trailDot.position = CGPoint(x: bobX, y: bobY)
            trailNode.addChild(trailDot)
            
            // Fade out and remove after a delay
            let fadeAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.removeFromParent()
            ])
            trailDot.run(fadeAction)
            
            // Limit trail nodes
            if trailNode.children.count > 100 {
                trailNode.children.first?.removeFromParent()
            }
        }
    }
    
    // MARK: - Simulation Methods
    
    override func update(_ currentTime: TimeInterval) {
        // Skip if we're not set up yet
        if !isSetup { return }
        
        // Initialize lastUpdateTime if needed
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        // Apply force if any
        if force != 0 {
            pendulum.applyForce(force)
        }
        
        // Step simulation
        pendulum.step(dt: timeStep)
        let state = pendulum.currentState
        
        // Update visuals
        updatePendulumPosition(angle: state.theta)
        
        // Update debug info
        debugLabel?.text = String(format: "Angle: %.2f, Velocity: %.2f, Force: %.1f",
                                  state.theta, state.thetaDot, force)
        
        lastUpdateTime = currentTime
    }
    
    // MARK: - User Interaction
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if leftButton.contains(location) {
            force = -0.5
        } else if rightButton.contains(location) {
            force = 0.5
        } else if resetButton.contains(location) {
            pendulum.reset()
            trailNode.removeAllChildren()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        force = 0.0
    }
}