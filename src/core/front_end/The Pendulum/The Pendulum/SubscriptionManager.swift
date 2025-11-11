import Foundation
import StoreKit

/// Manages subscription status and premium features access
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Properties
    @Published var isPremium: Bool = false
    @Published var subscriptionStatus: SubscriptionStatus = .none
    @Published var expirationDate: Date?
    @Published var isInFreeTrial: Bool = false
    
    private let productID = "com.golden_enterprises.thependulum.yearly.2024"
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Subscription Status
    enum SubscriptionStatus {
        case none
        case freeTrial
        case active
        case expired
        case canceled
    }
    
    // MARK: - Initialization
    private init() {
        // Set first launch date if not already set
        if UserDefaults.standard.firstLaunchDate == nil {
            UserDefaults.standard.firstLaunchDate = Date()
        }
        
        // Check cached subscription status for immediate availability
        if let hasSubscription = UserDefaults.standard.object(forKey: "has_active_subscription") as? Bool,
           hasSubscription,
           let expirationDate = UserDefaults.standard.object(forKey: "subscription_expiration_date") as? Date {
            if expirationDate > Date() {
                // Set initial status from cache
                self.isPremium = true
                self.subscriptionStatus = .active
                self.expirationDate = expirationDate
            }
        }
        
        // Completely disable StoreKit in simulator to prevent prompts
        #if targetEnvironment(simulator)
        print("📱 Running in Simulator - StoreKit disabled to prevent Apple Account prompts")
        print("📱 On real devices, subscriptions will work normally")
        // Don't start any StoreKit listeners or checks in simulator
        #else
        // Real device - check StoreKit normally
        if !UserDefaults.standard.bool(forKey: "skip_storekit_checks") {
            // Start listening for transaction updates
            updateListenerTask = listenForTransactions()
            
            // Delay subscription check to avoid immediate prompt on app launch
            Task {
                // Wait a bit before checking to allow user to start using the app
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                await checkSubscriptionStatus()
            }
        } else {
            print("Skipping StoreKit initialization (no Apple Account)")
        }
        #endif
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Check if the 3-day trial period has expired
    func isTrialExpired() -> Bool {
        guard let firstLaunchDate = UserDefaults.standard.firstLaunchDate else {
            return false
        }
        
        let trialDuration: TimeInterval = 3 * 24 * 60 * 60 // 3 days in seconds
        let trialEndDate = firstLaunchDate.addingTimeInterval(trialDuration)
        
        return Date() > trialEndDate
    }
    
    /// Get remaining trial days
    func getRemainingTrialDays() -> Int {
        guard let firstLaunchDate = UserDefaults.standard.firstLaunchDate else {
            return 3
        }
        
        let trialDuration: TimeInterval = 3 * 24 * 60 * 60 // 3 days in seconds
        let trialEndDate = firstLaunchDate.addingTimeInterval(trialDuration)
        let remainingTime = trialEndDate.timeIntervalSince(Date())
        
        if remainingTime <= 0 {
            return 0
        }
        
        return Int(ceil(remainingTime / (24 * 60 * 60)))
    }
    
    /// Check if user has access to premium features (including trial period)
    func hasPremiumAccess() -> Bool {
        // First check cached subscription status for quick response
        if let hasSubscription = UserDefaults.standard.object(forKey: "has_active_subscription") as? Bool,
           hasSubscription,
           let expirationDate = UserDefaults.standard.object(forKey: "subscription_expiration_date") as? Date,
           expirationDate > Date() {
            // User has a valid cached subscription
            return true
        }
        
        // If user has active subscription, grant access
        if isPremium || isInFreeTrial {
            return true
        }
        
        // If within 3-day trial period, grant access
        if !isTrialExpired() {
            return true
        }
        
        return false
    }
    
    /// Check if user needs to see paywall
    func needsPaywall() -> Bool {
        // First check cached subscription status for quick response
        if let hasSubscription = UserDefaults.standard.object(forKey: "has_active_subscription") as? Bool,
           hasSubscription,
           let expirationDate = UserDefaults.standard.object(forKey: "subscription_expiration_date") as? Date,
           expirationDate > Date() {
            // User has a valid cached subscription
            return false
        }
        
        // If has active subscription, no paywall needed
        if isPremium || isInFreeTrial {
            return false
        }
        
        // If trial has expired, show paywall
        return isTrialExpired()
    }
    
    /// Check if specific feature is available
    func isFeatureAvailable(_ feature: PremiumFeature) -> Bool {
        switch feature {
        case .basicFeatures:
            return true // Always available
        case .advancedAnalytics, .aiAssistance, .historicalData, .customPhysics, .cloudSync, .achievements, .prioritySupport:
            return hasPremiumAccess()
        }
    }
    
    /// Get subscription status text for UI
    @MainActor
    func getStatusText() -> String {
        switch subscriptionStatus {
        case .none:
            return "No active subscription"
        case .freeTrial:
            if let expirationDate = expirationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Free trial until \(formatter.string(from: expirationDate))"
            }
            return "Free trial active"
        case .active:
            if let expirationDate = expirationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Premium until \(formatter.string(from: expirationDate))"
            }
            return "Premium active"
        case .expired:
            return "Subscription expired"
        case .canceled:
            return "Subscription canceled"
        }
    }
    
    // MARK: - Private Methods
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            do {
                for await result in Transaction.updates {
                    do {
                        let transaction = try result.payloadValue
                        await self.updateSubscriptionStatus(from: transaction)
                    } catch {
                        print("Transaction update error: \(error)")
                    }
                }
            } catch {
                // Silently fail if no Apple Account is configured
                if error.localizedDescription.contains("No active account") {
                    print("StoreKit: No Apple Account configured - skipping transaction updates")
                } else {
                    print("Transaction listener error: \(error)")
                }
            }
        }
    }
    
    /// Check current subscription status
    @MainActor
    func checkSubscriptionStatus() async {
        // Always skip StoreKit checks in simulator
        #if targetEnvironment(simulator)
        print("📱 Simulator detected - skipping subscription status check")
        return
        #endif
        
        // First try to restore purchases to ensure we have the latest status
        do {
            try await AppStore.sync()
        } catch {
            // Handle the specific "No active account" error gracefully
            let errorString = error.localizedDescription
            if errorString.contains("No active account") || errorString.contains("userCancelled") {
                print("StoreKit: No Apple Account or user cancelled - using local status")
                // Set flag to skip future StoreKit checks in this session
                UserDefaults.standard.set(true, forKey: "skip_storekit_checks")
                return
            }
            print("Failed to sync with App Store: \(error)")
        }
        
        var hasActiveSubscription = false
        
        do {
            for await result in Transaction.currentEntitlements {
                do {
                    let transaction = try result.payloadValue
                    if transaction.productID == productID {
                        await updateSubscriptionStatus(from: transaction)
                        hasActiveSubscription = true
                        
                        // Persist subscription status
                        UserDefaults.standard.set(true, forKey: "has_active_subscription")
                        UserDefaults.standard.set(transaction.expirationDate, forKey: "subscription_expiration_date")
                        UserDefaults.standard.lastSubscriptionCheck = Date()
                        return
                    }
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        } catch {
            // Handle errors when checking entitlements
            let errorString = error.localizedDescription
            if errorString.contains("No active account") {
                print("StoreKit: No Apple Account for entitlements check - using local status")
                UserDefaults.standard.set(true, forKey: "skip_storekit_checks")
                return
            }
            print("Error checking entitlements: \(error)")
        }
        
        // No active subscription found
        isPremium = false
        subscriptionStatus = .none
        expirationDate = nil
        isInFreeTrial = false
        
        // Clear persisted subscription status
        UserDefaults.standard.set(false, forKey: "has_active_subscription")
        UserDefaults.standard.removeObject(forKey: "subscription_expiration_date")
        UserDefaults.standard.lastSubscriptionCheck = Date()
    }
    
    /// Update subscription status from transaction
    private func updateSubscriptionStatus(from transaction: Transaction) async {
        guard transaction.productID == productID else { return }
        
        await MainActor.run {
            // Check if transaction is revoked
            if transaction.revocationDate != nil {
                self.isPremium = false
                self.subscriptionStatus = .canceled
                self.isInFreeTrial = false
                
                // Clear persisted subscription status
                UserDefaults.standard.set(false, forKey: "has_active_subscription")
                UserDefaults.standard.removeObject(forKey: "subscription_expiration_date")
                return
            }
            
            // For subscription products, we need to check subscription status differently
            self.isPremium = true
            self.subscriptionStatus = .active
            self.isInFreeTrial = false
            self.expirationDate = transaction.expirationDate
            
            // Persist subscription status
            UserDefaults.standard.set(true, forKey: "has_active_subscription")
            UserDefaults.standard.set(transaction.expirationDate, forKey: "subscription_expiration_date")
            UserDefaults.standard.lastSubscriptionCheck = Date()
        }
    }
    
}

// MARK: - Premium Features

enum PremiumFeature {
    case basicFeatures
    case advancedAnalytics
    case aiAssistance
    case historicalData
    case customPhysics
    case cloudSync
    case achievements
    case prioritySupport
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    private enum Keys {
        static let subscriptionStatus = "subscription_status"
        static let lastSubscriptionCheck = "last_subscription_check"
        static let firstLaunchDate = "first_launch_date"
        static let hasSeenPaywall = "has_seen_paywall"
    }
    
    var lastSubscriptionCheck: Date? {
        get { object(forKey: Keys.lastSubscriptionCheck) as? Date }
        set { set(newValue, forKey: Keys.lastSubscriptionCheck) }
    }
    
    var firstLaunchDate: Date? {
        get { object(forKey: Keys.firstLaunchDate) as? Date }
        set { set(newValue, forKey: Keys.firstLaunchDate) }
    }
    
    var hasSeenPaywall: Bool {
        get { bool(forKey: Keys.hasSeenPaywall) }
        set { set(newValue, forKey: Keys.hasSeenPaywall) }
    }
}