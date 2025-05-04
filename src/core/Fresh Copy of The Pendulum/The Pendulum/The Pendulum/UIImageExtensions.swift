import UIKit

// Extension to create app logo image
extension UIImage {
    static var appLogo: UIImage? {
        // Try to load from various potential locations
        if let appIcon = UIImage(named: "GoldenLogo") {
            return appIcon
        }
        
        if let appIcon = UIImage(named: "AppIcon") {
            return appIcon
        }
        
        if let appIcon = UIImage(named: "AppIcon.appiconset/AppIcon1024") {
            return appIcon
        }
        
        if let appIcon = UIImage(named: "AppIcon1024") {
            return appIcon
        }
        
        // If all else fails, create a simple SF Symbol as a fallback
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        return UIImage(systemName: "circle.hexagongrid.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
    }
}