# Fresh Pendulum Project Setup Instructions

These instructions will guide you through creating a clean, working version of The Pendulum simulation without any of the maze-related functionality.

## Step 1: Create a New Xcode Project

1. Open Xcode
2. Select File > New > Project
3. Choose "App" under iOS
4. Enter the following details:
   - Product Name: The Pendulum
   - Organization Identifier: com.golden-enterprises
   - Interface: SwiftUI (we'll add UIKit components later)
   - Life Cycle: UIKit App Delegate
   - Language: Swift
   - Include Tests: Optional
5. Choose a location to save the project

## Step 2: Copy Core Files

Copy the following files from the original project:

### Core Files
1. Copy `/Users/briandizio/Documents/2023-Now/GES/Solutions/The Pendulum/src/core/The Pendulum/The Pendulum/FirstClaude/pendulum-model.swift` to your new project and rename it to `PendulumModel.swift`

2. Copy `/Users/briandizio/Documents/2023-Now/GES/Solutions/The Pendulum/src/core/The Pendulum/The Pendulum/NumericalODESolvers.swift` to your new project

3. Copy `/Users/briandizio/Documents/2023-Now/GES/Solutions/The Pendulum/src/core/The Pendulum/The Pendulum/FirstClaude/pendulum-scene.swift` to your new project and rename it to `PendulumScene.swift`

4. Copy `/Users/briandizio/Documents/2023-Now/GES/Solutions/The Pendulum/src/core/The Pendulum/The Pendulum/FirstClaude/pendulum-button-controls.swift` (if it exists) or create a new file called `PendulumControls.swift`

### Data Files (Optional)
5. Copy `/Users/briandizio/Documents/2023-Now/GES/Solutions/The Pendulum/src/core/InputPendulumSim.csv` to your new project's Resources

## Step 3: Set Up the Main Files

### AppDelegate.swift
Replace the content with:

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate: Application launching...")
        
        // Only set up the window if we're not using SceneDelegate (iOS 12 and below)
        if #available(iOS 13.0, *) {
            // Use SceneDelegate
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = PendulumViewController()
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

### SceneDelegate.swift
Replace the content with:

```swift
import UIKit
import SpriteKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: Connecting scene")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Set the main pendulum view controller
        window?.rootViewController = PendulumViewController()
        window?.makeKeyAndVisible()
        
        print("SceneDelegate: Window made visible")
    }
}
```

### PendulumViewController.swift
Create a new file and add:

```swift
import UIKit
import SpriteKit

class PendulumViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PendulumViewController: viewDidLoad")
        
        // Set up the SpriteKit view
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        // Configure the view
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Create and present the scene
        let scene = PendulumScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        print("PendulumViewController: Scene presented")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
```

## Step 4: Create the Info.plist File

If your project doesn't already have an Info.plist file, create one with these essential entries:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.golden-enterprises.The-Pendulum</string>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
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
    <key>UIStatusBarHidden</key>
    <true/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
```

## Step 5: Adapt the Pendulum Model and Scene Files

You may need to make minor adjustments to the model and scene files to work with your new project structure. Check for import statements, class names, and any file path references that might need updating.

## Step 6: Build and Run

1. Select a simulator or device
2. Run the app (Command+R)
3. You should see a red pendulum that can be controlled

## Troubleshooting

If you encounter issues:

1. **Black Screen**: Make sure the PendulumScene is properly initialized and presented
2. **Build Errors**: Check that all files are added to the build target
3. **Missing Connections**: Verify that your view controller is correctly setting up the scene

## Key Components to Verify

The core functionality is contained in these components:

1. **PendulumModel**: The physics simulation
2. **NumericalODESolvers**: The mathematical foundation
3. **PendulumScene**: The visual representation
4. **PendulumViewController**: The bridge between UIKit and SpriteKit

Each component should be properly connected with correct references.