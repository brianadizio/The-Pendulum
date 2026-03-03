import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {

    // MARK: - Properties
    var isPaywall: Bool = false

    // MARK: - StoreKit Properties
    private let productID = "com.goldenenterprises.thependulum.fullaccess"
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
        navigationItem.title = isPaywall ? "Trial Expired" : "Lifetime Access"

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
            titleLabel.text = "Unlock Lifetime Access"
            titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        }
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Subtitle
        if isPaywall {
            subtitleLabel.text = "Purchase lifetime access to continue using The Pendulum and unlock all premium features"
        } else {
            subtitleLabel.text = "Get lifetime access to The Pendulum with premium analytics and advanced physics modeling"
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
            "Advanced Scientific Analytics",
            "Detailed Performance Metrics",
            "AI-Powered Assistance",
            "Historical Data Analysis",
            "Custom Physics Parameters",
            "Cloud Data Sync",
            "Achievement System",
            "Priority Support"
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
        trialLabel.text = "One-time purchase — yours forever"
        trialLabel.font = .systemFont(ofSize: 14, weight: .medium)
        trialLabel.textColor = .secondaryLabel
        trialLabel.textAlignment = .center
        trialLabel.numberOfLines = 0
        trialLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trialLabel)

        // Subscribe Button
        subscribeButton.setTitle("Buy Now", for: .normal)
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

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmark.tintColor = .systemBlue
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(checkmark)

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            checkmark.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            checkmark.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 22),
            checkmark.heightAnchor.constraint(equalToConstant: 22),
            label.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 10),
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
        print("📱 Simulator detected - purchase UI shown but purchases disabled")
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
        priceLabel.text = product.displayPrice
        trialLabel.text = "One-time purchase — yours forever"
        subscribeButton.setTitle("Buy Now — \(product.displayPrice)", for: .normal)
    }

    private func checkPurchaseStatus() async {
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
                title: "Welcome!",
                message: "You now have lifetime access to all features. Enjoy The Pendulum!",
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
            // Normal purchase flow
            let alert = UIAlertController(
                title: "Welcome!",
                message: "You now have lifetime access to all premium features of The Pendulum.",
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
                await checkPurchaseStatus()

                // Check if purchase was restored
                await MainActor.run {
                    if SubscriptionManager.shared.hasPremiumAccess() && SubscriptionManager.shared.isPremium {
                        // Purchase restored successfully
                        if self.isPaywall {
                            // Transition to main app from paywall
                            let alert = UIAlertController(
                                title: "Purchase Restored!",
                                message: "Your lifetime access has been restored. Enjoy The Pendulum!",
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
                                message: "Your lifetime access has been restored.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    } else {
                        // No purchase found
                        let alert = UIAlertController(
                            title: "No Purchase Found",
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
        if let product = product {
            subscribeButton.setTitle("Buy Now — \(product.displayPrice)", for: .normal)
        } else {
            subscribeButton.setTitle("Buy Now", for: .normal)
        }
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
