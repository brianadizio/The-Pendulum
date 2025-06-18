import UIKit
import CoreData
import FirebaseCore
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

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
    
    // MARK: - App Tracking Transparency
    
    private func requestTrackingPermissionIfNeeded() {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("✅ ATT: Tracking authorized")
                        self.initializeSingularSDK(withTracking: true)
                    case .denied:
                        print("❌ ATT: Tracking denied")
                        self.initializeSingularSDK(withTracking: false)
                    case .restricted:
                        print("⚠️ ATT: Tracking restricted")
                        self.initializeSingularSDK(withTracking: false)
                    case .notDetermined:
                        print("⏳ ATT: Tracking not determined")
                        self.initializeSingularSDK(withTracking: false)
                    @unknown default:
                        print("❓ ATT: Unknown status")
                        self.initializeSingularSDK(withTracking: false)
                    }
                }
            }
        } else {
            // iOS 13 and earlier - tracking is allowed by default
            print("📱 ATT: iOS < 14, initializing with tracking")
            initializeSingularSDK(withTracking: true)
        }
        #else
        // AppTrackingTransparency not available, skip ATT but still initialize SDK
        print("⚠️ ATT: Framework not available, initializing without permission")
        initializeSingularSDK(withTracking: false)
        #endif
    }
    
    private func initializeSingularSDK(withTracking: Bool) {
        #if SINGULAR_SDK_AVAILABLE
        // Initialize Singular SDK with appropriate configuration
        if withTracking {
            print("🎯 Initializing Singular SDK with full tracking")
            // Singular will have access to IDFA and full tracking capabilities
        } else {
            print("🔒 Initializing Singular SDK with limited tracking")
            // Singular will use limited tracking without IDFA
        }
        
        // Track the install event
        SingularTracker.trackInstall()
        
        // Track the session start
        SingularTracker.trackSessionStart()
        #else
        print("⚠️ Singular SDK not available")
        #endif
    }
}
