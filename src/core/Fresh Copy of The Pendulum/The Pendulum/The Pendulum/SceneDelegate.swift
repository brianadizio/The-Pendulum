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
        window?.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Brief delay to allow launch screen to show, then transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showMainApp()
        }
        
        // The launch screen storyboard will be shown automatically
        // Create a minimal initial view controller for transition
        let initialVC = UIViewController()
        initialVC.view.backgroundColor = FocusCalendarTheme.backgroundColor
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }
    
    private func showMainApp() {
        guard let window = window else { return }
        
        // Check subscription status before transitioning
        if SubscriptionManager.shared.needsPaywall() {
            // Show subscription view controller with paywall
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                let subscriptionVC = SubscriptionViewController()
                subscriptionVC.isPaywall = true
                let navController = UINavigationController(rootViewController: subscriptionVC)
                navController.modalPresentationStyle = .fullScreen
                window.rootViewController = navController
            }, completion: nil)
        } else {
            // User has access, show main app
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                let mainViewController = PendulumViewController()
                window.rootViewController = mainViewController
            }, completion: nil)
        }
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
