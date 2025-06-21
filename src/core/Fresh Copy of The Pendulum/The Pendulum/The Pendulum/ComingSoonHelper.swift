import UIKit

// MARK: - Coming Soon Helper
// Unified "Coming Soon" messaging across the application

extension UIViewController {
    
    /// Shows a standardized "Coming Soon" alert
    /// - Parameter feature: The name of the feature that's coming soon
    func showComingSoonAlert(for feature: String) {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "\(feature) will be available in a future update.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - Coming Soon Badge Configuration

struct ComingSoonBadge {
    static let text = "SOON"
    static let font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    static let textColor = UIColor.systemOrange
    static let backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
    static let cornerRadius: CGFloat = 4
    static let width: CGFloat = 45
    static let height: CGFloat = 20
    
    /// Creates a standardized "Coming Soon" badge label
    static func createBadgeLabel() -> UILabel {
        let badge = UILabel()
        badge.text = text
        badge.font = font
        badge.textColor = textColor
        badge.backgroundColor = backgroundColor
        badge.layer.cornerRadius = cornerRadius
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }
    
    /// Creates a badge view with proper constraints
    static func createBadgeView() -> UIView {
        let badge = createBadgeLabel()
        let containerView = UIView()
        containerView.addSubview(badge)
        
        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            badge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            badge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: width),
            badge.heightAnchor.constraint(equalToConstant: height)
        ])
        
        return containerView
    }
}

// MARK: - Coming Soon Subtitle Format

extension String {
    /// Returns a standardized "Coming Soon" subtitle
    /// - Parameter description: Optional description of the feature
    /// - Returns: Formatted subtitle string
    static func comingSoonSubtitle(with description: String? = nil) -> String {
        if let description = description {
            return "Coming Soon - \(description)"
        }
        return "Coming Soon"
    }
}