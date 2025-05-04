// PendulumScene.swift
import SpriteKit

class PendulumScene: SKScene {
    private var pendulum: InvertedPendulumModel!
    private var pendulumNode: PendulumNode?
    private var leftButton: SKShapeNode?
    private var rightButton: SKShapeNode?
    private var resetButton: SKShapeNode?
    private var debugLabel: SKLabelNode?
    
    private var lastUpdateTime: TimeInterval = 0
    private var command: Double = 0
    private let timeStep: Double = 1.0/60.0 // 60Hz simulation
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Configure scene update rate
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        
        setupSimulation()
        setupPendulum()
        setupControls()
        setupDebugLabel()
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
        // Initialize pendulum with default parameters
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
        
        // Apply initial angle
        var initialState = pendulum.currentState
        initialState.theta = 0.05 // Small initial angle
        
        debugLabel?.text = "State: Simulation initialized"
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
            rightButton.zPosition = 100
            addChild(rightButton)
            
            let rightLabel = SKLabelNode(text: "→")
            rightLabel.fontSize = 24
            rightLabel.fontColor = .white
            rightLabel.position = CGPoint(x: 0, y: -8)
            rightButton.addChild(rightLabel)
        }
        
        // Reset button
        resetButton = SKShapeNode(rectOf: buttonSize)
        if let resetButton = resetButton {
            resetButton.position = CGPoint(x: frame.midX, y: buttonY)
            resetButton.fillColor = .gray
            resetButton.strokeColor = .white
            resetButton.name = "resetButton"
            resetButton.zPosition = 100
            addChild(resetButton)
            
            let resetLabel = SKLabelNode(text: "Reset")
            resetLabel.fontSize = 18
            resetLabel.fontColor = .white
            resetLabel.position = CGPoint(x: 0, y: -8)
            resetButton.addChild(resetLabel)
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
                    
                case "resetButton":
                    pendulum.reset()
                    debugLabel?.text = "Pendulum Reset"
                    print("Reset button pressed")
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
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        // Apply command force if any
        if command != 0 {
            pendulum.applyForce(command * 0.1)
        }
        
        // Step simulation
        pendulum.step(dt: timeStep)
        let state = pendulum.currentState
        
        // Update pendulum visualization
        pendulumNode?.updateAngle(state.theta)
        
        // Update debug info
        debugLabel?.text = String(format: "Pos: %.3f, Vel: %.3f, Cmd: %.1f",
                                state.theta, state.thetaDot, command)
        
        lastUpdateTime = currentTime
    }
}