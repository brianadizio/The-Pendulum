import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // In iOS 13 and later, scene delegate will handle window creation
        if #available(iOS 13.0, *) {
            // SceneDelegate will handle window setup
        } else {
            // For iOS 12 and earlier, set up window directly
            window = UIWindow(frame: UIScreen.main.bounds)
            let pendulumVC = PendulumViewController()
            window?.rootViewController = pendulumVC
            window?.backgroundColor = .white
            window?.makeKeyAndVisible()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("AppDelegate: Configuring scene session")
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("AppDelegate: Did discard scene sessions")
    }
}
