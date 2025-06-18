import Foundation
import UIKit

// Note: After adding Singular SDK via SPM, uncomment the import below
// import Singular

class SingularTestConfiguration {
    
    // MARK: - Configuration
    
    static func initializeSingular() {
        #if SINGULAR_SDK_AVAILABLE
        // Initialize Singular with your API Key and Secret
        // These will need to be replaced with your actual credentials from Singular
        let config = SingularConfig(apiKey: "goldenenterprises_2c52889f", andSecret: "df4df5c7bc8cbefe57a359f39950915a")
        
        // Optional: Enable debug logging
        config.logLevel = SingularLogLevelDebug
        
        // Optional: Set custom user ID if you have one
        // config.customUserId = "user123"
        
        // Optional: Enable SKAdNetwork support
        config.skAdNetworkEnabled = true
        
        // Full tracking mode - IDFA available
        config.limitDataSharing = false
        
        // Initialize Singular
        Singular.start(config)
        
        print("✅ Singular SDK initialized successfully with full tracking")
        #else
        print("⚠️ Singular SDK not available - please add it via Swift Package Manager first")
        #endif
    }
    
    static func initializeSingularLimitedTracking() {
        #if SINGULAR_SDK_AVAILABLE
        // Initialize Singular with your API Key and Secret in limited tracking mode
        let config = SingularConfig(apiKey: "goldenenterprises_2c52889f", andSecret: "df4df5c7bc8cbefe57a359f39950915a")
        
        // Enable debug logging
        config.logLevel = SingularLogLevelDebug
        
        // Enable SKAdNetwork support (this works without IDFA)
        config.skAdNetworkEnabled = true
        
        // Limited tracking mode - no IDFA
        config.limitDataSharing = true
        
        // Initialize Singular
        Singular.start(config)
        
        print("✅ Singular SDK initialized successfully with limited tracking")
        #else
        print("⚠️ Singular SDK not available - please add it via Swift Package Manager first")
        #endif
    }
    
    // MARK: - Test Methods
    
    static func testSingularImports() -> Bool {
        #if SINGULAR_SDK_AVAILABLE
        // Test that we can access Singular classes
        let _ = SingularConfig.self
        let _ = Singular.self
        print("✅ Singular imports successful")
        return true
        #else
        print("❌ Singular imports failed - SDK not available")
        return false
        #endif
    }
    
    static func testTrackEvent() {
        #if SINGULAR_SDK_AVAILABLE
        // Track a simple event
        Singular.event("test_event")
        print("✅ Test event tracked")
        
        // Track event with attributes
        let attributes = [
            "test_key": "test_value",
            "timestamp": "\(Date().timeIntervalSince1970)"
        ]
        Singular.event(withArgs: "test_event_with_attributes", withAttributes: attributes)
        print("✅ Test event with attributes tracked")
        #else
        print("⚠️ Cannot track events - Singular SDK not available")
        #endif
    }
    
    static func testRevenue() {
        #if SINGULAR_SDK_AVAILABLE
        // Track revenue event
        Singular.revenue("USD", amount: 9.99)
        print("✅ Revenue tracked: $9.99 USD")
        
        // Track custom revenue event
        Singular.customRevenue("test_purchase", currency: "USD", amount: 4.99)
        print("✅ Custom revenue tracked: $4.99 USD")
        #else
        print("⚠️ Cannot track revenue - Singular SDK not available")
        #endif
    }
    
    static func testDeepLinks() {
        #if SINGULAR_SDK_AVAILABLE
        // Test deep link handling
        if let url = URL(string: "pendulum://test/deeplink") {
            let handled = Singular.handleOpenURL(url, options: nil)
            print("✅ Deep link handled: \(handled)")
        }
        #else
        print("⚠️ Cannot test deep links - Singular SDK not available")
        #endif
    }
    
    static func testUserAttributes() {
        #if SINGULAR_SDK_AVAILABLE
        // Set custom user ID
        Singular.setCustomUserId("test_user_123")
        print("✅ Custom user ID set")
        
        // Unset custom user ID
        Singular.unsetCustomUserId()
        print("✅ Custom user ID unset")
        #else
        print("⚠️ Cannot set user attributes - Singular SDK not available")
        #endif
    }
    
    static func getSDKVersion() -> String {
        #if SINGULAR_SDK_AVAILABLE
        return Singular.version() ?? "Unknown"
        #else
        return "SDK Not Available"
        #endif
    }
    
    // MARK: - Debug Helper
    
    static func printConfiguration() {
        print("""
        
        📊 Singular SDK Configuration:
        ================================
        SDK Available: \(isSingularAvailable())
        SDK Version: \(getSDKVersion())
        
        To complete setup:
        1. Add Singular SDK via Swift Package Manager
        2. Get your API Key and Secret from Singular Dashboard
        3. Update the configuration in this file
        4. Create bridging header if needed
        5. Add required frameworks and linker flags
        
        """)
    }
    
    static func isSingularAvailable() -> Bool {
        #if SINGULAR_SDK_AVAILABLE
        return true
        #else
        return false
        #endif
    }
}

// MARK: - Placeholder Implementations
// These will be replaced with actual Singular SDK types when available

#if !SINGULAR_SDK_AVAILABLE

// Placeholder for SingularConfig
class SingularConfig {
    var logLevel: Int = 0
    var skAdNetworkEnabled: Bool = false
    var customUserId: String?
    var limitDataSharing: Bool = false
    
    init(apiKey: String, andSecret secret: String) {
        print("⚠️ Using placeholder SingularConfig - add real SDK")
    }
}

// Placeholder for Singular
class Singular {
    static func start(_ config: SingularConfig) {
        print("⚠️ Using placeholder Singular.start - add real SDK")
    }
    
    static func event(_ name: String) {
        print("⚠️ Using placeholder Singular.event - add real SDK")
    }
    
    static func event(withArgs name: String, withAttributes: [String: String]) {
        print("⚠️ Using placeholder Singular.event(withArgs) - add real SDK")
    }
    
    static func revenue(_ currency: String, amount: Double) {
        print("⚠️ Using placeholder Singular.revenue - add real SDK")
    }
    
    static func customRevenue(_ name: String, currency: String, amount: Double) {
        print("⚠️ Using placeholder Singular.customRevenue - add real SDK")
    }
    
    static func handleOpenURL(_ url: URL, options: [String: Any]?) -> Bool {
        print("⚠️ Using placeholder Singular.handleOpenURL - add real SDK")
        return false
    }
    
    static func setCustomUserId(_ userId: String) {
        print("⚠️ Using placeholder Singular.setCustomUserId - add real SDK")
    }
    
    static func unsetCustomUserId() {
        print("⚠️ Using placeholder Singular.unsetCustomUserId - add real SDK")
    }
    
    static func version() -> String? {
        return "Placeholder"
    }
}

let SingularLogLevelDebug = 1

#endif