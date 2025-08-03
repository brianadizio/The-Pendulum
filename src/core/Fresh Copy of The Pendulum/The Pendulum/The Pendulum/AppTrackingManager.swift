import Foundation
import AppTrackingTransparency
import AdSupport
import Singular

/// Manages App Tracking Transparency permissions and coordinates with Singular SDK
class AppTrackingManager {
    
    static let shared = AppTrackingManager()
    
    private var trackingCompletionHandler: ((Bool) -> Void)?
    private var hasRequestedPermission = false
    
    private init() {}
    
    // MARK: - Public Interface
    
    /// Request tracking permission and initialize Singular SDK based on the result
    /// - Parameter completion: Called when permission flow is complete with granted status
    func requestTrackingPermissionAndInitializeSingular(completion: @escaping (Bool) -> Void) {
        trackingCompletionHandler = completion
        
        // Check if we need to request permission
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined:
                requestTrackingPermission()
            case .authorized:
                print("✅ Tracking already authorized")
                initializeSingularWithTracking(granted: true)
            case .denied, .restricted:
                print("❌ Tracking denied or restricted")
                initializeSingularWithTracking(granted: false)
            @unknown default:
                print("⚠️ Unknown tracking authorization status")
                initializeSingularWithTracking(granted: false)
            }
        } else {
            // iOS < 14.5, no ATT required
            print("ℹ️ iOS < 14.5, no ATT required")
            initializeSingularWithTracking(granted: true)
        }
    }
    
    /// Get current tracking authorization status
    func getCurrentTrackingStatus() -> String {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined:
                return "Not Determined"
            case .authorized:
                return "Authorized"
            case .denied:
                return "Denied"
            case .restricted:
                return "Restricted"
            @unknown default:
                return "Unknown"
            }
        } else {
            return "Not Available (iOS < 14.5)"
        }
    }
    
    /// Check if tracking is currently authorized
    func isTrackingAuthorized() -> Bool {
        if #available(iOS 14.5, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
        } else {
            return true // No restrictions on older iOS versions
        }
    }
    
    /// Get IDFA if available and authorized
    func getIDFA() -> String? {
        guard isTrackingAuthorized() else {
            print("📱 IDFA not available - tracking not authorized")
            return nil
        }
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        if idfa == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
            print("📱 IDFA is zeros - limit ad tracking enabled or simulator")
            return nil
        }
        
        print("📱 IDFA available: \(idfa.uuidString)")
        return idfa.uuidString
    }
    
    // MARK: - Private Methods
    
    @available(iOS 14.5, *)
    private func requestTrackingPermission() {
        guard !hasRequestedPermission else {
            print("⚠️ ATT permission already requested this session")
            return
        }
        
        hasRequestedPermission = true
        print("📱 Requesting App Tracking Transparency permission...")
        
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.handleTrackingPermissionResult(status)
            }
        }
    }
    
    @available(iOS 14.5, *)
    private func handleTrackingPermissionResult(_ status: ATTrackingManager.AuthorizationStatus) {
        let granted = status == .authorized
        
        switch status {
        case .authorized:
            print("✅ Tracking permission granted")
        case .denied:
            print("❌ Tracking permission denied")
        case .restricted:
            print("❌ Tracking permission restricted")
        case .notDetermined:
            print("⚠️ Tracking permission still not determined")
        @unknown default:
            print("⚠️ Unknown tracking permission status")
        }
        
        initializeSingularWithTracking(granted: granted)
    }
    
    private func initializeSingularWithTracking(granted: Bool) {
        print("🔧 Initializing Singular SDK with tracking permission: \(granted)")
        
        // Update Singular configuration based on tracking permission
        if granted {
            print("📊 Full tracking enabled - initializing Singular with IDFA")
            // Initialize Singular with full tracking capabilities
            SingularTestConfiguration.initializeSingular()
            
            // Log tracking status to Singular
            SingularTracker.trackTrackingPermission(granted: true, idfa: getIDFA())
        } else {
            print("🔒 Limited tracking - initializing Singular without IDFA")
            // Initialize Singular in limited tracking mode
            SingularTestConfiguration.initializeSingularLimitedTracking()
            
            // Log tracking status to Singular
            SingularTracker.trackTrackingPermission(granted: false, idfa: nil)
        }
        
        // Call completion handler
        trackingCompletionHandler?(granted)
        trackingCompletionHandler = nil
    }
    
    // MARK: - Debug Helpers
    
    func printTrackingStatus() {
        print("""
        
        📱 App Tracking Transparency Status:
        ===================================
        Current Status: \(getCurrentTrackingStatus())
        Is Authorized: \(isTrackingAuthorized())
        IDFA Available: \(getIDFA() != nil)
        IDFA Value: \(getIDFA() ?? "Not Available")
        Has Requested: \(hasRequestedPermission)
        
        """)
    }
}

// MARK: - SingularTracker Extension

extension SingularTracker {
    
    /// Track the App Tracking Transparency permission result
    static func trackTrackingPermission(granted: Bool, idfa: String?) {
        var attributes = [
            "att_permission_granted": granted ? "true" : "false",
            "att_status": AppTrackingManager.shared.getCurrentTrackingStatus(),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let idfa = idfa {
            attributes["idfa"] = idfa
        }
        
        Singular.event("att_permission_result", withArgs: attributes)
        print("📊 ATT permission result tracked: \(granted)")
    }
    
    /// Track when user opens settings to change tracking permission
    static func trackTrackingSettingsOpened() {
        let attributes = [
            "current_status": AppTrackingManager.shared.getCurrentTrackingStatus(),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("att_settings_opened", withArgs: attributes)
        print("⚙️ ATT settings opened tracked")
    }
}