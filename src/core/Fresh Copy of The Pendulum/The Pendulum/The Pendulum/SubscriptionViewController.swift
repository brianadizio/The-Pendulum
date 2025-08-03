import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    
    // MARK: - Properties
    var isPaywall: Bool = false
    
    // MARK: - StoreKit Properties
    private let productID = "com.golden_enterprises.thependulum.yearly.2024"
    private var product: Product?
    private var purchaseTask: Task<Void, Never>?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let featuresStackView = UIStackView()
    
    private let priceLabel = UILabel()
    private let trialLabel = UILabel()
    private let subscribeButton = UIButton(type: .system)
    private let restoreButton = UIButton(type: .system)
    private let termsButton = UIButton(type: .system)
    private let privacyButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadProduct()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        purchaseTask?.cancel()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation
        navigationItem.title = isPaywall ? "Trial Expired" : "Premium Features"
        
        // Only show close button if not paywall
        if !isPaywall {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeTapped)
            )
        }
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        if isPaywall {
            titleLabel.text = "Your 3-Day Free Trial Has Ended"
            titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        } else {
            titleLabel.text = "Unlock Advanced Features"
            titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        }
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Subtitle
        if isPaywall {
            let remainingDays = SubscriptionManager.shared.getRemainingTrialDays()
            if remainingDays > 0 {
                subtitleLabel.text = "You have \(remainingDays) day\(remainingDays == 1 ? "" : "s") left in your free trial. Continue exploring The Pendulum's features!"
            } else {
                subtitleLabel.text = "Subscribe now to continue using The Pendulum and unlock all premium features"
            }
        } else {
            subtitleLabel.text = "Get the most out of The Pendulum with premium analytics and advanced physics modeling"
        }
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Features Stack View
        featuresStackView.axis = .vertical
        featuresStackView.spacing = 16
        featuresStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(featuresStackView)
        
        // Add feature items
        let features = [
            "🔬 Advanced Scientific Analytics",
            "📊 Detailed Performance Metrics", 
            "🎯 AI-Powered Assistance",
            "📈 Historical Data Analysis",
            "🔧 Custom Physics Parameters",
            "☁️ Cloud Data Sync",
            "🏆 Achievement System",
            "📱 Priority Support"
        ]
        
        for feature in features {
            let featureView = createFeatureView(text: feature)
            featuresStackView.addArrangedSubview(featureView)
        }
        
        // Price Label
        priceLabel.text = "Loading..."
        priceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        priceLabel.textColor = .systemBlue
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        // Trial Label
        trialLabel.text = "Start with 3-day free trial, then $4.99/year\nCancel anytime in Settings"
        trialLabel.font = .systemFont(ofSize: 14, weight: .medium)
        trialLabel.textColor = .secondaryLabel
        trialLabel.textAlignment = .center
        trialLabel.numberOfLines = 0
        trialLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trialLabel)
        
        // Subscribe Button
        subscribeButton.setTitle("Start Free Trial", for: .normal)
        subscribeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        subscribeButton.backgroundColor = .systemBlue
        subscribeButton.setTitleColor(.white, for: .normal)
        subscribeButton.layer.cornerRadius = 12
        subscribeButton.addTarget(self, action: #selector(subscribeTapped), for: .touchUpInside)
        subscribeButton.isEnabled = false // Disabled until product loads
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subscribeButton)
        
        // Restore Button
        restoreButton.setTitle("Restore Purchases", for: .normal)
        restoreButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        restoreButton.setTitleColor(.systemBlue, for: .normal)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(restoreButton)
        
        // Terms Button
        termsButton.setTitle("Terms of Service", for: .normal)
        termsButton.titleLabel?.font = .systemFont(ofSize: 14)
        termsButton.setTitleColor(.systemBlue, for: .normal)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(termsButton)
        
        // Privacy Button
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.titleLabel?.font = .systemFont(ofSize: 14)
        privacyButton.setTitleColor(.systemBlue, for: .normal)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(privacyButton)
    }
    
    private func createFeatureView(text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Features Stack View
            featuresStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            featuresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            featuresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            // Price Label
            priceLabel.topAnchor.constraint(equalTo: featuresStackView.bottomAnchor, constant: 32),
            priceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Trial Label
            trialLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            trialLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Subscribe Button
            subscribeButton.topAnchor.constraint(equalTo: trialLabel.bottomAnchor, constant: 24),
            subscribeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subscribeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            subscribeButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Restore Button
            restoreButton.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 16),
            restoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Terms Button
            termsButton.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: 32),
            termsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            
            // Privacy Button
            privacyButton.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: 32),
            privacyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            privacyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    // MARK: - StoreKit Methods
    private func loadProduct() {
        #if targetEnvironment(simulator)
        print("📱 Simulator detected - subscription UI shown but purchases disabled")
        subscribeButton.setTitle("Simulator Mode", for: .normal)
        subscribeButton.isEnabled = false
        return
        #endif
        
        Task {
            do {
                print("📱 Loading product with ID: \(productID)")
                let products = try await Product.products(for: [productID])
                print("📱 Found \(products.count) products")
                
                if let product = products.first {
                    print("✅ Product loaded: \(product.id) - \(product.displayName)")
                    await MainActor.run {
                        self.product = product
                        self.updatePriceDisplay()
                        self.subscribeButton.isEnabled = true
                    }
                } else {
                    print("❌ No products found for ID: \(productID)")
                    print("❓ Make sure product ID matches App Store Connect configuration")
                    await MainActor.run {
                        self.priceLabel.text = "Product not available"
                        self.subscribeButton.isEnabled = false
                    }
                }
            } catch {
                print("❌ Error loading products: \(error.localizedDescription)")
                await MainActor.run {
                    self.priceLabel.text = "Error loading price"
                    self.subscribeButton.isEnabled = false
                }
            }
        }
    }
    
    private func updatePriceDisplay() {
        guard let product = product else { return }
        priceLabel.text = "\(product.displayPrice)/year"
        
        // Update trial label to clearly show pricing after trial
        if let introOffer = product.subscription?.introductoryOffer {
            let trialDays = introOffer.period.unit == .day ? introOffer.period.value : 0
            if trialDays > 0 {
                trialLabel.text = "Start with \(trialDays)-day free trial, then \(product.displayPrice)/year\nCancel anytime in Settings • Billed yearly after trial"
            } else {
                trialLabel.text = "\(product.displayPrice)/year • Cancel anytime in Settings"
            }
        } else {
            // No trial offer
            trialLabel.text = "\(product.displayPrice)/year • Cancel anytime in Settings"
        }
    }
    
    private func checkSubscriptionStatus() async {
        guard let product = product else { return }
        
        do {
            for await result in Transaction.currentEntitlements {
                do {
                    let transaction = try result.payloadValue
                    if transaction.productID == product.id {
                        await MainActor.run {
                            self.handleSuccessfulPurchase()
                        }
                        return
                    }
                } catch {
                    // Handle verification failure
                    print("Transaction verification failed: \(error)")
                }
            }
        } catch {
            // Handle errors accessing entitlements
            if error.localizedDescription.contains("No active account") {
                print("No Apple Account configured - cannot check entitlements")
            } else {
                print("Error checking entitlements: \(error)")
            }
        }
    }
    
    private func handleSuccessfulPurchase() {
        // Notify SubscriptionManager to refresh status
        Task {
            await SubscriptionManager.shared.checkSubscriptionStatus()
        }
        
        if isPaywall {
            // If coming from paywall, transition to main app
            let alert = UIAlertController(
                title: "Welcome to Premium!",
                message: "You now have access to all premium features. Enjoy The Pendulum!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                // Transition to main app
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        let mainViewController = PendulumViewController()
                        window.rootViewController = mainViewController
                    }, completion: nil)
                }
            })
            present(alert, animated: true)
        } else {
            // Normal subscription flow
            let alert = UIAlertController(
                title: "Welcome to Premium!",
                message: "Your subscription has started. You now have access to all premium features.\n\nYou will be charged $4.99/year unless you cancel in Settings.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func subscribeTapped() {
        guard let product = product else { return }
        
        subscribeButton.isEnabled = false
        subscribeButton.setTitle("Processing...", for: .normal)
        
        purchaseTask = Task {
            do {
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        // Transaction is verified
                        await transaction.finish()
                        await MainActor.run {
                            self.handleSuccessfulPurchase()
                        }
                    case .unverified(_, let error):
                        // Transaction failed verification
                        await MainActor.run {
                            self.showError("Purchase verification failed: \(error)")
                        }
                    }
                case .userCancelled:
                    await MainActor.run {
                        self.resetSubscribeButton()
                    }
                case .pending:
                    await MainActor.run {
                        self.showError("Purchase is pending approval")
                        self.resetSubscribeButton()
                    }
                @unknown default:
                    await MainActor.run {
                        self.showError("Unknown purchase result")
                        self.resetSubscribeButton()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showError("Purchase failed: \(error.localizedDescription)")
                    self.resetSubscribeButton()
                }
            }
        }
    }
    
    @objc private func restoreTapped() {
        Task {
            do {
                try await AppStore.sync()
                await checkSubscriptionStatus()
                
                // Check if subscription was restored
                await MainActor.run {
                    if SubscriptionManager.shared.hasPremiumAccess() {
                        // Subscription restored successfully
                        if self.isPaywall {
                            // Transition to main app from paywall
                            let alert = UIAlertController(
                                title: "Subscription Restored!",
                                message: "Your premium subscription has been restored. Enjoy The Pendulum!",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                        let mainViewController = PendulumViewController()
                                        window.rootViewController = mainViewController
                                    }, completion: nil)
                                }
                            })
                            self.present(alert, animated: true)
                        } else {
                            // Normal restore flow
                            let alert = UIAlertController(
                                title: "Restore Complete",
                                message: "Your subscription has been restored.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    } else {
                        // No subscription found
                        let alert = UIAlertController(
                            title: "No Subscription Found",
                            message: "No previous purchases were found to restore.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            } catch {
                let errorString = error.localizedDescription
                if errorString.contains("No active account") || errorString.contains("userCancelled") {
                    await MainActor.run {
                        let alert = UIAlertController(
                            title: "Apple Account Required",
                            message: "Please sign in to the App Store to restore purchases.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                } else {
                    await MainActor.run {
                        self.showError("Failed to restore purchases: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func resetSubscribeButton() {
        subscribeButton.isEnabled = true
        subscribeButton.setTitle("Start Free Trial", for: .normal)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func termsTapped() {
        // Open Apple's standard Terms of Use
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func privacyTapped() {
        // Open privacy policy in Safari
        if let url = URL(string: "https://www.freeprivacypolicy.com/live/62c8e11c-18fe-4b53-82c6-b722c4ac9b6e") {
            UIApplication.shared.open(url)
        }
    }
}