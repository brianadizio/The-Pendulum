import UIKit

// Extension to define Golden Enterprise Solutions color scheme
extension UIColor {
    // Primary colors
    static let goldenPrimary = UIColor(red: 0.85, green: 0.7, blue: 0.2, alpha: 1.0) // Main gold color
    static let goldenSecondary = UIColor(red: 0.9, green: 0.85, blue: 0.6, alpha: 1.0) // Light gold/cream color
    static let goldenAccent = UIColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 1.0) // Deep gold accent
    static let goldenDark = UIColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1.0) // Dark gold/brown
    
    // Background colors
    static let goldenBackground = UIColor(red: 0.96, green: 0.94, blue: 0.85, alpha: 1.0) // Cream background
    static let goldenBackgroundAlt = UIColor(red: 0.93, green: 0.89, blue: 0.75, alpha: 1.0) // Alternate cream background
    
    // Text colors
    static let goldenText = UIColor(red: 0.3, green: 0.25, blue: 0.1, alpha: 1.0) // Dark brown text
    static let goldenTextLight = UIColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 1.0) // Medium brown text
    
    // Functional colors
    static let goldenSuccess = UIColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0) // Green for success
    static let goldenError = UIColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0) // Reddish for errors
    static let goldenWarning = UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0) // Orange for warnings
    
    // Additional accent colors that complement gold
    static let goldenAccentBlue = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0) // Complementary blue
    static let goldenAccentGreen = UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0) // Complementary green
}

// Extension for Golden Enterprise UI styles
extension UIView {
    func applyGoldenStyle() {
        // Apply shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 3
        
        // Apply rounded corners
        self.layer.cornerRadius = 12
    }
    
    func applyGoldenCard() {
        applyGoldenStyle()
        backgroundColor = .goldenBackground
        layer.borderWidth = 1
        layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
    }
}

// Extension for Golden Enterprise button styles
extension UIButton {
    func applyGoldenButtonStyle(isPrimary: Bool = true) {
        if isPrimary {
            backgroundColor = .goldenPrimary
            setTitleColor(.white, for: .normal)
        } else {
            backgroundColor = .goldenSecondary
            setTitleColor(.goldenDark, for: .normal)
        }
        
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 3
    }
}

// Helper functions for creating gradient layers with Golden Enterprise colors
class GoldenGradients {
    static func createHeaderGradient(for view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.goldenPrimary.cgColor,
            UIColor.goldenAccent.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }
    
    static func createBackgroundGradient(for view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.goldenBackground.cgColor,
            UIColor.goldenBackgroundAlt.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        return gradient
    }
}