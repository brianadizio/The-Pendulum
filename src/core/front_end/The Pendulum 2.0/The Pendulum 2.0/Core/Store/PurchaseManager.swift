// PurchaseManager.swift
// The Pendulum 2.0
// Singleton managing trial period and one-time purchase via StoreKit 2

import Foundation
import Combine
import StoreKit
import FirebaseStorage

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    // MARK: - Product ID

    static let productId = "com.goldenenterprises.thependulum.fullaccess"

    // MARK: - Published State

    @Published private(set) var isUnlocked: Bool = false
    @Published private(set) var trialDaysRemaining: Int = 3
    @Published private(set) var isTrialActive: Bool = true
    @Published private(set) var product: Product?
    @Published private(set) var isPurchasing: Bool = false
    @Published private(set) var purchaseError: String?

    // MARK: - Trial Constants

    static let trialDuration: TimeInterval = 3 * 24 * 60 * 60  // 3 days in seconds

    // MARK: - Private Properties

    private var transactionListener: Task<Void, Never>?

    private enum Keys {
        static let trialStartDate = "pendulum_trial_start_date"
        static let purchaseUnlocked = "pendulum_purchase_unlocked"
    }

    // MARK: - Initialization

    private init() {
        // Check cached purchase state first (fast)
        isUnlocked = UserDefaults.standard.bool(forKey: Keys.purchaseUnlocked)

        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Load product and verify entitlements asynchronously
        Task {
            await loadProduct()
            await verifyEntitlements()
            recordTrialStartIfNeeded()
            updateTrialStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Trial Management

    /// Record first launch date for trial tracking
    func recordTrialStartIfNeeded() {
        if UserDefaults.standard.object(forKey: Keys.trialStartDate) == nil {
            let now = Date()
            UserDefaults.standard.set(now, forKey: Keys.trialStartDate)

            // Back up to Firebase
            Task {
                await saveTrialStartToFirebase(now)
            }
        }
    }

    /// Sync trial start date with Firebase (use earliest date to prevent gaming)
    func syncTrialStartWithFirebase() async {
        let localDate = UserDefaults.standard.object(forKey: Keys.trialStartDate) as? Date
        let firebaseDate = await fetchTrialStartFromFirebase()

        // Use the earliest date between local and Firebase
        if let local = localDate, let firebase = firebaseDate {
            let earliest = min(local, firebase)
            UserDefaults.standard.set(earliest, forKey: Keys.trialStartDate)
            if firebase != earliest {
                await saveTrialStartToFirebase(earliest)
            }
        } else if let firebase = firebaseDate, localDate == nil {
            // Only Firebase has a date (reinstall scenario)
            UserDefaults.standard.set(firebase, forKey: Keys.trialStartDate)
        } else if let local = localDate, firebaseDate == nil {
            // Only local has a date
            await saveTrialStartToFirebase(local)
        }

        updateTrialStatus()
    }

    /// Update published trial state
    func updateTrialStatus() {
        if isUnlocked { return }

        guard let startDate = UserDefaults.standard.object(forKey: Keys.trialStartDate) as? Date else {
            // No start date yet — trial is active
            isTrialActive = true
            trialDaysRemaining = 3
            return
        }

        let elapsed = Date().timeIntervalSince(startDate)
        let remaining = Self.trialDuration - elapsed

        if remaining > 0 {
            isTrialActive = true
            trialDaysRemaining = max(1, Int(ceil(remaining / (24 * 60 * 60))))
        } else {
            isTrialActive = false
            trialDaysRemaining = 0
        }
    }

    /// Whether the app content should be accessible
    var canAccessApp: Bool {
        isUnlocked || isTrialActive
    }

    // MARK: - StoreKit 2 Product

    /// Load the product from the App Store
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productId])
            product = products.first
            if let p = product {
                print("PurchaseManager: Loaded product '\(p.displayName)' at \(p.displayPrice)")
            } else {
                print("PurchaseManager: No product found for ID '\(Self.productId)'. Check that the StoreKit Configuration is set in the scheme (Product > Scheme > Edit Scheme > Run > Options > StoreKit Configuration).")
            }
        } catch {
            print("PurchaseManager: Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    /// Purchase the full access product
    func purchase() async {
        guard let product = product else {
            purchaseError = "Product not available. Please try again."
            return
        }

        isPurchasing = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await handlePurchaseSuccess(transaction)
                await transaction.finish()

            case .userCancelled:
                break

            case .pending:
                purchaseError = "Purchase is pending approval."

            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }

        isPurchasing = false
    }

    /// Restore purchases
    func restorePurchases() async {
        // Sync with App Store
        try? await AppStore.sync()

        // Re-check entitlements
        await verifyEntitlements()
    }

    // MARK: - Transaction Handling

    /// Listen for transaction updates (renewals, revocations, etc.)
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                if let transaction = try? result.payloadValue {
                    await self.handlePurchaseSuccess(transaction)
                    await transaction.finish()
                }
            }
        }
    }

    /// Verify current entitlements from StoreKit
    private func verifyEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.productId {
                await handlePurchaseSuccess(transaction)
                return
            }
        }
    }

    /// Process a successful purchase
    private func handlePurchaseSuccess(_ transaction: Transaction) async {
        guard transaction.productID == Self.productId else { return }
        isUnlocked = true
        UserDefaults.standard.set(true, forKey: Keys.purchaseUnlocked)
    }

    /// Verify a transaction result
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    // MARK: - Firebase Backup

    /// Save trial start date to Firebase Storage
    private func saveTrialStartToFirebase(_ date: Date) async {
        guard let uid = FirebaseManager.shared.uid else { return }

        let path = "users/\(uid)/\(FirebaseManager.goldenModePath)/trial_start.json"
        let ref = FirebaseManager.shared.storageRef(for: path)
        let metadata = FirebaseManager.shared.jsonMetadata()

        let payload: [String: String] = [
            "trialStartDate": ISO8601DateFormatter().string(from: date)
        ]

        guard let data = try? JSONEncoder().encode(payload) else { return }

        do {
            _ = try await ref.putDataAsync(data, metadata: metadata)
        } catch {
            print("PurchaseManager: Failed to save trial start to Firebase: \(error)")
        }
    }

    /// Fetch trial start date from Firebase Storage
    private func fetchTrialStartFromFirebase() async -> Date? {
        guard let uid = FirebaseManager.shared.uid else { return nil }

        let path = "users/\(uid)/\(FirebaseManager.goldenModePath)/trial_start.json"
        let ref = FirebaseManager.shared.storageRef(for: path)

        do {
            let data = try await ref.data(maxSize: 1024)
            if let dict = try? JSONDecoder().decode([String: String].self, from: data),
               let dateString = dict["trialStartDate"] {
                return ISO8601DateFormatter().date(from: dateString)
            }
        } catch {
            // File doesn't exist yet — that's fine
        }

        return nil
    }

    // MARK: - Debug Helpers

    #if DEBUG
    /// Override trial start date for testing (debug builds only)
    func debugSetTrialStart(_ date: Date) {
        UserDefaults.standard.set(date, forKey: Keys.trialStartDate)
        updateTrialStatus()
    }

    /// Reset purchase state for testing (debug builds only)
    func debugResetPurchase() {
        isUnlocked = false
        UserDefaults.standard.set(false, forKey: Keys.purchaseUnlocked)
        updateTrialStatus()
    }
    #endif
}
