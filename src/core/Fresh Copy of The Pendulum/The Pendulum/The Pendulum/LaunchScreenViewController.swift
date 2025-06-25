import UIKit
import AVFoundation

class LaunchScreenViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Create a container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Logo placeholder (replace with actual logo when available)
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        
        // Try to load the logo
        if let logo = UIImage(named: "PendulumLogo") ?? UIImage(named: "AppIcon") {
            logoImageView.image = logo
        } else {
            // Fallback: Create a placeholder view
            logoImageView.backgroundColor = FocusCalendarTheme.accentGold
            logoImageView.layer.cornerRadius = 20
        }
        
        containerView.addSubview(logoImageView)
        
        // Company name label
        let companyLabel = UILabel()
        companyLabel.text = "Golden Enterprises Solutions Inc."
        companyLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 24)
        companyLabel.textColor = FocusCalendarTheme.primaryTextColor
        companyLabel.textAlignment = .center
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(companyLabel)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "The Pendulum"
        titleLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 32)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Brian DiZio, Chief Mathematician"
        subtitleLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 18)
        subtitleLabel.textColor = FocusCalendarTheme.secondaryTextColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)
        
        // Location label
        let locationLabel = UILabel()
        locationLabel.text = "Rhode Island, USA"
        locationLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 16)
        locationLabel.textColor = FocusCalendarTheme.tertiaryTextColor
        locationLabel.textAlignment = .center
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(locationLabel)
        
        // Copyright label
        let copyrightLabel = UILabel()
        copyrightLabel.text = "© 2025 Golden Enterprises Solutions Inc."
        copyrightLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.caption)
        copyrightLabel.textColor = FocusCalendarTheme.tertiaryTextColor
        copyrightLabel.textAlignment = .center
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(copyrightLabel)
        
        // Video placeholder view
        let videoPlaceholderView = UIView()
        videoPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaceholderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        videoPlaceholderView.layer.cornerRadius = 20
        containerView.addSubview(videoPlaceholderView)
        
        // Placeholder text for video
        let videoPlaceholderLabel = UILabel()
        videoPlaceholderLabel.text = "Video Launch Animation\n(0.75 seconds)"
        videoPlaceholderLabel.numberOfLines = 2
        videoPlaceholderLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: 16)
        videoPlaceholderLabel.textColor = UIColor.white
        videoPlaceholderLabel.textAlignment = .center
        videoPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        videoPlaceholderView.addSubview(videoPlaceholderLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Company label
            companyLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            companyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            companyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Location label
            locationLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Video placeholder
            videoPlaceholderView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 30),
            videoPlaceholderView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            videoPlaceholderView.widthAnchor.constraint(equalToConstant: 280),
            videoPlaceholderView.heightAnchor.constraint(equalToConstant: 200),
            videoPlaceholderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Video placeholder label
            videoPlaceholderLabel.centerXAnchor.constraint(equalTo: videoPlaceholderView.centerXAnchor),
            videoPlaceholderLabel.centerYAnchor.constraint(equalTo: videoPlaceholderView.centerYAnchor),
            
            // Copyright label at bottom
            copyrightLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            copyrightLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            copyrightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Setup video player when video is available
        // setupVideoPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start the launch sequence
        performLaunchSequence()
    }
    
    private func setupVideoPlayer() {
        // This will be implemented when the video asset is provided
        guard let videoPath = Bundle.main.path(forResource: "LaunchVideo", ofType: "mp4"),
              let videoURL = URL(string: videoPath) else {
            return
        }
        
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        
        if let playerLayer = playerLayer {
            playerLayer.frame = CGRect(x: 0, y: 0, width: 280, height: 200)
            playerLayer.videoGravity = .resizeAspectFill
            // Add to the video placeholder view when ready
        }
    }
    
    private func performLaunchSequence() {
        // Animate elements
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            // Fade in animation if needed
        }) { _ in
            // Play video if available
            self.player?.play()
            
            // Wait for video duration (0.75 seconds) or default delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.transitionToMainApp()
            }
        }
    }
    
    private func transitionToMainApp() {
        // Check subscription status before transitioning
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            // Check if user needs to see paywall
            if SubscriptionManager.shared.needsPaywall() {
                // Show subscription view controller with paywall
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    let subscriptionVC = SubscriptionViewController()
                    subscriptionVC.isPaywall = true // We'll add this property
                    let navController = UINavigationController(rootViewController: subscriptionVC)
                    navController.modalPresentationStyle = .fullScreen
                    window.rootViewController = navController
                }, completion: nil)
            } else {
                // User has access, show main app
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    let mainViewController = PendulumViewController()
                    window.rootViewController = mainViewController
                }, completion: nil)
            }
        }
    }
}