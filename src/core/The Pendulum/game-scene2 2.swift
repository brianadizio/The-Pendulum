import SpriteKit

class GameScene: SKScene {
    private var pendulum: InvertedPendulum!
    private var pendulumNode: PendulumNode?
    private var leftButton: SKShapeNode?
    private var rightButton: SKShapeNode?
    private var debugLabel: SKLabelNode?
    
    private var lastUpdateTime: TimeInterval = 0
    private var command: Double = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Configure physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Configure scene update rate
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        
        setupSimulation()
        setupPendulum()
        setupControls()
        setupDebugLabel()
        
        // Run validation on startup
        PendulumTester.validateSimulation()
    }
    
    private func setupDebugLabel() {
        debugLabel = SKLabelNode(text: "State: Initializing")
        if let debugLabel = debugLabel {
            debugLabel.fontSize = 14
            debugLabel.fontColor = .white
            debugLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
            addChild(debugLabel)
        }
    }
    
    private func setupSimulation() {
        guard let path = Bundle.main.path(forResource: "InputPendulumSim", ofType: "csv") else {
            print("Error: Could not find input file")
            return
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let rows = content.components(separatedBy: .newlines)
                            .filter { !$0.isEmpty }
            
            let parameters = rows.compactMap { row -> Double? in
                let components = row.components(separatedBy: ",")
                guard let firstValue = components.first else { return nil }
                return Double(firstValue)
            }
            
            print("Loaded parameters:", parameters)
            pendulum = InvertedPendulum(parameters: parameters)
            debugLabel?.text = "State: Simulation initialized"
            
        } catch {
            print("Error loading simulation parameters: \(error)")
            debugLabel?.text = "State: Error loading parameters"
        }
    }
    
    private func setupPendulum() {
        let screenHeight = frame.size.height
        let pendulumLength: CGFloat = screenHeight * 0.3
        let massRadius: CGFloat = 20
        
        pendulumNode = PendulumNode(length: pendulumLength, massRadius: massRadius)
        if let pendulumNode = pendulumNode {
            pendulumNode.position = CGPoint(x: frame.midX, y: frame.midY + pendulumLength/2)
            addChild(pendulumNode)
        }
    }
    
    private func setupControls() {
        let buttonSize = CGSize(width: 100, height: 50)
        let buttonY = frame.minY + 100
        
        // Left button
        leftButton = SKShapeNode(rectOf: buttonSize)
        if let leftButton = leftButton {
            leftButton.position = CGPoint(x: frame.midX - 120, y: buttonY)
            leftButton.fillColor = .blue
            leftButton.strokeColor = .white
            leftButton.name = "leftButton"
            leftButton.zPosition = 100  // Ensure buttons are above other nodes
            addChild(leftButton)
            
            let leftLabel = SKLabelNode(text: "←")
            leftLabel.fontSize = 24
            leftLabel.fontColor = .white
            leftLabel.position = CGPoint(x: 0, y: -8)
            leftButton.addChild(leftLabel)
        }
        
        // Right button
        rightButton = SKShapeNode(rectOf: buttonSize)
        if let rightButton = rightButton {
            rightButton.position = CGPoint(x: frame.midX + 120, y: buttonY)
            rightButton.fillColor = .blue
            rightButton.strokeColor = .white
            rightButton.name = "rightButton"
            rightButton.zPosition = 100  // Ensure buttons are above other nodes
            addChild(rightButton)
            
            let rightLabel = SKLabelNode(text: "→")
            rightLabel.fontSize = 24
            rightLabel.fontColor = .white
            rightLabel.position = CGPoint(x: 0, y: -8)
            rightButton.addChild(rightLabel)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes {
                switch node.name {
                case "leftButton":
                    command = -1.0
                    debugLabel?.text = "Command: Left"
                    print("Left button pressed")
                    return
                    
                case "rightButton":
                    command = 1.0
                    debugLabel?.text = "Command: Right"
                    print("Right button pressed")
                    return
                    
                default:
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        command = 0
        debugLabel?.text = "Command: None"
        print("Touch ended")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // No need for guard let since we're using force unwrap
        let stepResult = pendulum.step(command: command)
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let dt = currentTime - lastUpdateTime
        print("Update called - dt: \(dt)")
        
        // Step simulation and update visualization
        let (position, velocity) = stepResult
        pendulumNode?.updateAngle(position)
        
        // Update debug info
        debugLabel?.text = String(format: "Pos: %.3f, Vel: %.3f, Cmd: %.1f",
                                position, velocity, command)
        
        lastUpdateTime = currentTime
    }
}
