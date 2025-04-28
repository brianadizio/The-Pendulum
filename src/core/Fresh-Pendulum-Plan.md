# Fresh Pendulum App Plan

## Project Creation

1. Create a completely new Xcode project:
   - Open Xcode
   - Choose "New Project" > "iOS" > "App"
   - Product Name: "PendulumSim"
   - Organization Identifier: com.yourdomain
   - Interface: SwiftUI (we'll add SpriteKit ourselves)
   - Language: Swift
   - Uncheck all test options

## File Structure

Create these files in your project:

1. **PendulumSimulation.swift** - Core physics simulation
2. **PendulumNode.swift** - SpriteKit visualization
3. **GameScene.swift** - Main SpriteKit scene
4. **GameViewController.swift** - UIKit bridge to SpriteKit

## Key Implementation Files

### PendulumSimulation.swift
```swift
import Foundation

struct PendulumState {
    var angle: Double
    var velocity: Double
    var time: Double
}

class PendulumSimulation {
    // Physics parameters
    var mass: Double = 1.0
    var length: Double = 1.0
    var gravity: Double = 9.81
    var damping: Double = 0.1
    var timeStep: Double = 1.0/60.0
    
    // Current state
    private(set) var state = PendulumState(angle: 0.05, velocity: 0.0, time: 0.0)
    
    func step() {
        // Calculate forces
        let gravityTorque = gravity / length * sin(state.angle)
        let dampingTorque = damping * state.velocity
        
        // Calculate acceleration
        let acceleration = -gravityTorque - dampingTorque
        
        // Euler integration
        state.velocity += acceleration * timeStep
        state.angle += state.velocity * timeStep
        state.time += timeStep
    }
    
    func applyForce(_ force: Double) {
        state.velocity += force
    }
    
    func reset() {
        state = PendulumState(angle: 0.05, velocity: 0.0, time: 0.0)
    }
}
```

### PendulumNode.swift
```swift
import SpriteKit

class PendulumNode: SKNode {
    private let rodNode = SKShapeNode()
    private let bobNode = SKShapeNode(circleOfRadius: 20)
    private let pivotNode = SKShapeNode(circleOfRadius: 6)
    private let length: CGFloat
    
    init(length: CGFloat) {
        self.length = length
        super.init()
        
        // Setup pivot
        pivotNode.fillColor = .gray
        addChild(pivotNode)
        
        // Setup rod
        rodNode.strokeColor = .white
        rodNode.lineWidth = 2
        addChild(rodNode)
        
        // Setup bob
        bobNode.fillColor = .red
        addChild(bobNode)
        
        updatePosition(angle: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(angle: Double) {
        let bobX = length * CGFloat(sin(angle))
        let bobY = length * CGFloat(cos(angle))
        
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: bobX, y: bobY))
        rodNode.path = path
        
        bobNode.position = CGPoint(x: bobX, y: bobY)
    }
}
```

### GameScene.swift
```swift
import SpriteKit

class GameScene: SKScene {
    private let pendulum = PendulumSimulation()
    private var pendulumNode: PendulumNode?
    private var leftButton: SKShapeNode?
    private var rightButton: SKShapeNode?
    private var resetButton: SKShapeNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupPendulum()
        setupButtons()
    }
    
    private func setupPendulum() {
        let pendulumLength: CGFloat = size.height * 0.4
        pendulumNode = PendulumNode(length: pendulumLength)
        
        if let pendulumNode = pendulumNode {
            pendulumNode.position = CGPoint(x: size.width/2, y: size.height/2)
            addChild(pendulumNode)
        }
    }
    
    private func setupButtons() {
        // Create buttons here (left, right, reset)
        let buttonSize = CGSize(width: 80, height: 50)
        
        // Left button
        leftButton = SKShapeNode(rectOf: buttonSize)
        leftButton?.fillColor = .blue
        leftButton?.strokeColor = .white
        leftButton?.position = CGPoint(x: size.width/2 - 100, y: 100)
        leftButton?.name = "leftButton"
        addChild(leftButton!)
        
        // Right button
        rightButton = SKShapeNode(rectOf: buttonSize)
        rightButton?.fillColor = .blue
        rightButton?.strokeColor = .white
        rightButton?.position = CGPoint(x: size.width/2 + 100, y: 100)
        rightButton?.name = "rightButton"
        addChild(rightButton!)
        
        // Reset button
        resetButton = SKShapeNode(rectOf: buttonSize)
        resetButton?.fillColor = .gray
        resetButton?.strokeColor = .white
        resetButton?.position = CGPoint(x: size.width/2, y: 100)
        resetButton?.name = "resetButton"
        addChild(resetButton!)
        
        // Add labels
        let leftLabel = SKLabelNode(text: "←")
        leftLabel.fontSize = 30
        leftLabel.position = CGPoint(x: 0, y: -10)
        leftButton?.addChild(leftLabel)
        
        let rightLabel = SKLabelNode(text: "→")
        rightLabel.fontSize = 30
        rightLabel.position = CGPoint(x: 0, y: -10)
        rightButton?.addChild(rightLabel)
        
        let resetLabel = SKLabelNode(text: "Reset")
        resetLabel.fontSize = 18
        resetLabel.position = CGPoint(x: 0, y: -6)
        resetButton?.addChild(resetLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        pendulum.step()
        pendulumNode?.updatePosition(angle: pendulum.state.angle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes {
                if node.name == "leftButton" {
                    pendulum.applyForce(-0.1)
                } else if node.name == "rightButton" {
                    pendulum.applyForce(0.1)
                } else if node.name == "resetButton" {
                    pendulum.reset()
                }
            }
        }
    }
}
```

### GameViewController.swift
```swift
import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a SpriteKit view
        let skView = SKView(frame: view.bounds)
        skView.showsFPS = true
        skView.showsNodeCount = true
        view.addSubview(skView)
        
        // Create and present the scene
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
```

### AppDelegate.swift (update)
```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override the root view controller for iOS 12 and below
        if #available(iOS 13.0, *) {
            // Use SceneDelegate
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = GameViewController()
            window?.makeKeyAndVisible()
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
```

### SceneDelegate.swift (update)
```swift
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = GameViewController()
        window?.makeKeyAndVisible()
    }
}
```

## Setup Flow

1. Create the project
2. Delete the ContentView.swift file
3. Add all the files above
4. Update Info.plist to include:
   ```xml
   <key>UIApplicationSceneManifest</key>
   <dict>
       <key>UIApplicationSupportsMultipleScenes</key>
       <false/>
       <key>UISceneConfigurations</key>
       <dict>
           <key>UIWindowSceneSessionRoleApplication</key>
           <array>
               <dict>
                   <key>UISceneConfigurationName</key>
                   <string>Default Configuration</string>
                   <key>UISceneDelegateClassName</key>
                   <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
               </dict>
           </array>
       </dict>
   </dict>
   ```
5. Build and run!