import UIKit

// Focus Calendar-inspired theme for The Pendulum
// Based on cream backgrounds with gold text and subtle color spectrum
class FocusCalendarTheme {
    
    // MARK: - Core Colors (from The Focus Calendar)
    
    // Cream background colors
    static let backgroundColor = UIColor(red: 249/255, green: 245/255, blue: 236/255, alpha: 1.0) // #F9F5EC
    static let secondaryBackgroundColor = UIColor(red: 253/255, green: 248/255, blue: 240/255, alpha: 1.0) // #FDF8F0
    static let tertiaryBackgroundColor = UIColor(red: 251/255, green: 246/255, blue: 238/255, alpha: 1.0) // #FBF6EE
    
    // Gold text colors
    static let primaryTextColor = UIColor(red: 139/255, green: 107/255, blue: 47/255, alpha: 1.0) // #8B6B2F - Deep gold
    static let secondaryTextColor = UIColor(red: 168/255, green: 132/255, blue: 65/255, alpha: 1.0) // #A88441 - Medium gold
    static let tertiaryTextColor = UIColor(red: 184/255, green: 151/255, blue: 91/255, alpha: 1.0) // #B8975B - Light gold
    
    // Accent colors (subtle spectrum)
    static let accentGold = UIColor(red: 212/255, green: 175/255, blue: 55/255, alpha: 1.0) // #D4AF37 - Classic gold
    static let accentRose = UIColor(red: 216/255, green: 180/255, blue: 182/255, alpha: 1.0) // #D8B4B6 - Soft rose
    static let accentSage = UIColor(red: 176/255, green: 190/255, blue: 166/255, alpha: 1.0) // #B0BEA6 - Sage green
    static let accentSlate = UIColor(red: 147/255, green: 154/255, blue: 166/255, alpha: 1.0) // #939AA6 - Slate blue
    
    // Black and white for sketchy elements
    static let darkTextColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0) // #333333
    static let lightBorderColor = UIColor(red: 230/255, green: 225/255, blue: 215/255, alpha: 1.0) // #E6E1D7
    
    // Additional colors for specific UI elements
    static let borderColor = UIColor(red: 230/255, green: 225/255, blue: 215/255, alpha: 1.0) // #E6E1D7 (same as lightBorderColor)
    static let cardBackgroundColor = UIColor.white // White for card backgrounds with cream container
    
    // MARK: - Font Configuration
    
    // Static font properties for easy access
    static var titleFont: UIFont {
        return UIFont(name: "Georgia-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
    }
    
    static var bodyFont: UIFont {
        return UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16)
    }
    
    static var buttonFont: UIFont {
        return UIFont(name: "Georgia-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
    }
    
    static var largeTitleFont: UIFont {
        return UIFont(name: "Georgia-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
    }
    
    struct Fonts {
        // Primary fonts - using Georgia/Baskerville for elegance
        static let titleFontName = "Georgia-Bold"
        static let bodyFontName = "Georgia"
        static let alternativeTitleFontName = "Baskerville-Bold"
        static let alternativeBodyFontName = "Baskerville"
        
        // Font sizes
        struct Size {
            static let navigationTitle: CGFloat = 20
            static let sectionHeader: CGFloat = 18
            static let bodyText: CGFloat = 16
            static let subheadline: CGFloat = 14
            static let caption: CGFloat = 12
            static let largeTitle: CGFloat = 24
        }
        
        // Helper methods
        static func titleFont(size: CGFloat) -> UIFont {
            return UIFont(name: titleFontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func bodyFont(size: CGFloat) -> UIFont {
            return UIFont(name: bodyFontName, size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    // MARK: - Theme Application Methods
    
    static func applyTheme() {
        // Apply to navigation bar
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = backgroundColor
            appearance.titleTextAttributes = [
                .foregroundColor: primaryTextColor,
                .font: Fonts.titleFont(size: Fonts.Size.navigationTitle)
            ]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: primaryTextColor,
                .font: Fonts.titleFont(size: Fonts.Size.largeTitle)
            ]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Apply to tab bar
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = backgroundColor
            
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: tertiaryTextColor,
                .font: Fonts.bodyFont(size: Fonts.Size.caption)
            ]
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: primaryTextColor,
                .font: Fonts.bodyFont(size: Fonts.Size.caption)
            ]
            itemAppearance.normal.iconColor = tertiaryTextColor
            itemAppearance.selected.iconColor = primaryTextColor
            
            tabBarAppearance.stackedLayoutAppearance = itemAppearance
            tabBarAppearance.inlineLayoutAppearance = itemAppearance
            tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Apply to table views
        UITableView.appearance().backgroundColor = backgroundColor
        UITableViewCell.appearance().backgroundColor = secondaryBackgroundColor
        
        // Apply to labels
        UILabel.appearance().textColor = primaryTextColor
        
        // Apply to buttons
        UIButton.appearance().tintColor = accentGold
    }
    
    // MARK: - View Styling Methods
    
    static func styleCard(_ view: UIView) {
        view.backgroundColor = secondaryBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = lightBorderColor.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
    }
    
    static func styleButton(_ button: UIButton, isPrimary: Bool = true) {
        button.titleLabel?.font = Fonts.bodyFont(size: Fonts.Size.bodyText)
        button.layer.cornerRadius = 8
        
        if isPrimary {
            button.backgroundColor = accentGold
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = secondaryBackgroundColor
            button.setTitleColor(primaryTextColor, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = lightBorderColor.cgColor
        }
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 3
    }
    
    static func styleLabel(_ label: UILabel, style: TextStyle) {
        switch style {
        case .title:
            label.font = Fonts.titleFont(size: Fonts.Size.largeTitle)
            label.textColor = primaryTextColor
        case .sectionHeader:
            label.font = Fonts.titleFont(size: Fonts.Size.sectionHeader)
            label.textColor = primaryTextColor
        case .body:
            label.font = Fonts.bodyFont(size: Fonts.Size.bodyText)
            label.textColor = darkTextColor
        case .caption:
            label.font = Fonts.bodyFont(size: Fonts.Size.caption)
            label.textColor = secondaryTextColor
        case .subheadline:
            label.font = Fonts.bodyFont(size: Fonts.Size.subheadline)
            label.textColor = secondaryTextColor
        }
    }
    
    enum TextStyle {
        case title
        case sectionHeader
        case body
        case caption
        case subheadline
    }
}

// MARK: - UIColor Extension for Focus Calendar Theme

extension UIColor {
    // Override the existing golden colors with Focus Calendar theme colors
    static var focusCalendarBackground: UIColor {
        return FocusCalendarTheme.backgroundColor
    }
    
    static var focusCalendarText: UIColor {
        return FocusCalendarTheme.primaryTextColor
    }
    
    static var focusCalendarAccent: UIColor {
        return FocusCalendarTheme.accentGold
    }
    
    static var focusCalendarSecondaryBackground: UIColor {
        return FocusCalendarTheme.secondaryBackgroundColor
    }
    
    static var focusCalendarBorder: UIColor {
        return FocusCalendarTheme.lightBorderColor
    }
}

// MARK: - UI Element Creation Methods
extension FocusCalendarTheme {
    static func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Fonts.titleFont(size: Fonts.Size.largeTitle)
        label.textColor = primaryTextColor
        label.textAlignment = .center
        return label
    }
    
    static func createTextButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = buttonFont
        button.tintColor = accentGold
        button.setTitleColor(accentGold, for: .normal)
        return button
    }
    
    static func createStyledButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        styleButton(button, isPrimary: true)
        return button
    }
}