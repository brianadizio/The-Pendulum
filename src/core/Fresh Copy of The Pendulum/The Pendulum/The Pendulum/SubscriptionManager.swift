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
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Check current subscription status
        Task {
            await checkSubscriptionStatus()
        }
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
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    await self.updateSubscriptionStatus(from: transaction)
                } catch {
                    print("Transaction update error: \(error)")
                }
            }
        }
    }
    
    /// Check current subscription status
    @MainActor
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try result.payloadValue
                if transaction.productID == productID {
                    await updateSubscriptionStatus(from: transaction)
                    return
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        // No active subscription found
        isPremium = false
        subscriptionStatus = .none
        expirationDate = nil
        isInFreeTrial = false
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
                return
            }
            
            // For subscription products, we need to check subscription status differently
            self.isPremium = true
            self.subscriptionStatus = .active
            self.isInFreeTrial = false
            self.expirationDate = transaction.expirationDate
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