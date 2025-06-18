import UIKit
import CoreData
import FirebaseCore
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase with Firestore
        FirebaseTestConfiguration.initializeFirebaseWithFirestore()
        
        // Apply Focus Calendar theme
        FocusCalendarTheme.applyTheme()
        
        // Request App Tracking Transparency permission and initialize Singular
        // This should be called after the app is fully launched
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.requestTrackingPermissionIfNeeded()
        }
        
        // In iOS 13 and later, scene delegate will handle window creation
        if #available(iOS 13.0, *) {
            // SceneDelegate will handle window setup
        } else {
            // For iOS 12 and earlier, set up window directly
            window = UIWindow(frame: UIScreen.main.bounds)
            let pendulumVC = PendulumViewController()
            window?.rootViewController = pendulumVC
            window?.backgroundColor = FocusCalendarTheme.backgroundColor
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    // MARK: - App Tracking Transparency
    
    private func requestTrackingPermissionIfNeeded() {
        print("📱 Requesting App Tracking Transparency permission...")
        
        AppTrackingManager.shared.requestTrackingPermissionAndInitializeSingular { granted in
            print("📊 ATT Permission result: \(granted ? "Granted" : "Denied")")
            
            if granted {
                print("✅ Full analytics tracking enabled")
                // Track successful permission grant
                SingularTracker.trackInstall()
            } else {
                print("🔒 Limited analytics tracking enabled")
                // Still track install event, but in limited mode
                SingularTracker.trackInstall()
            }
            
            // Print current status for debugging
            AppTrackingManager.shared.printTrackingStatus()
        }
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
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PendulumScoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
