// AppTrackingManager.swift
// The Pendulum 2.0
// Manages App Tracking Transparency permissions and coordinates with Singular SDK

import Foundation
import AppTrackingTransparency
import AdSupport
#if canImport(Singular)
import Singular
#endif

class AppTrackingManager {
    static let shared = AppTrackingManager()

    private var hasRequestedPermission = false

    private init() {}

    // MARK: - Public Interface

    /// Request tracking permission and initialize Singular SDK based on the result
    func requestTrackingAndInitializeSingular(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined:
                requestTrackingPermission(completion: completion)
            case .authorized:
                print("Tracking already authorized")
                initializeSingular(granted: true)
                completion(true)
            case .denied, .restricted:
                print("Tracking denied or restricted")
                initializeSingular(granted: false)
                completion(false)
            @unknown default:
                initializeSingular(granted: false)
                completion(false)
            }
        } else {
            initializeSingular(granted: true)
            completion(true)
        }
    }

    /// Check if tracking is currently authorized
    func isTrackingAuthorized() -> Bool {
        if #available(iOS 14.5, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
        }
        return true
    }

    /// Get current tracking authorization status as string
    func getCurrentTrackingStatus() -> String {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined: return "Not Determined"
            case .authorized: return "Authorized"
            case .denied: return "Denied"
            case .restricted: return "Restricted"
            @unknown default: return "Unknown"
            }
        }
        return "Not Available"
    }

    /// Get IDFA if available and authorized
    func getIDFA() -> String? {
        guard isTrackingAuthorized() else { return nil }

        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        if idfa == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
            return nil
        }
        return idfa.uuidString
    }

    // MARK: - Private Methods

    @available(iOS 14.5, *)
    private func requestTrackingPermission(completion: @escaping (Bool) -> Void) {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true

        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            DispatchQueue.main.async {
                let granted = status == .authorized
                self?.initializeSingular(granted: granted)
                SingularTracker.trackTrackingPermission(
                    granted: granted,
                    idfa: self?.getIDFA()
                )
                completion(granted)
            }
        }
    }

    private func initializeSingular(granted: Bool) {
        #if canImport(Singular)
        guard let config = SingularConfig(
            apiKey: "goldenenterprises_2c52889f",
            andSecret: "df4df5c7bc8cbefe57a359f39950915a"
        ) else {
            print("Failed to create SingularConfig")
            return
        }

        config.skAdNetworkEnabled = true
        config.limitAdvertisingIdentifiers = !granted

        Singular.start(config)
        print("Singular SDK initialized (tracking: \(granted ? "full" : "limited"))")

        // Link Singular to Firebase user ID if available
        if let uid = FirebaseManager.shared.uid {
            Singular.setCustomUserId(uid)
        }
        #else
        print("[Singular] SDK not available — add Singular SPM package to enable attribution")
        #endif
    }
}
