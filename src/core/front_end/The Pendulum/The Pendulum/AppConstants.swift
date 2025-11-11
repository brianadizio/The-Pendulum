import Foundation

/// Central location for app-wide constants and configuration
struct AppConstants {
    
    // MARK: - URLs
    struct URLs {
        /// Privacy Policy URL - Update this when your privacy policy URL changes
        static let privacyPolicy = "https://www.goldenenterprises.com/the-pendulum/privacy-policy"
        
        /// Terms of Service URL
        static let termsOfService = "https://www.goldenenterprises.com/the-pendulum/terms"
        
        /// Support/Contact URL
        static let support = "https://www.goldenenterprises.com/support"
        
        /// Company Website
        static let companyWebsite = "https://www.goldenenterprises.com"
    }
    
    // MARK: - Company Information
    struct Company {
        static let name = "Golden Enterprises Solutions Inc."
        static let location = "Rhode Island, USA"
        static let supportEmail = "support@goldenenterprises.com"
        static let copyright = "© 2025 Golden Enterprises Solutions Inc. All rights reserved."
    }
    
    // MARK: - App Information
    struct App {
        static let name = "The Pendulum"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}