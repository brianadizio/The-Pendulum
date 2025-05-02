import UIKit
import SpriteKit
import QuartzCore

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Create the window with the window scene
        window = UIWindow(windowScene: windowScene)
        
        // Set the PendulumViewController as root
        let pendulumVC = PendulumViewController()
        window?.rootViewController = pendulumVC
        window?.makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any tasks that were paused when the scene was inactive
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data if appropriate
    }
}
