import UIKit

// MARK: - Header Style Creator
class HeaderViewCreator {
    
    // Creates a consistent header view with logo and title
    static func createHeaderView(title: String, fontSize: CGFloat = 28) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Logo image view
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "PendulumLogo-removebg-preview")
        containerView.addSubview(logoImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = FocusCalendarTheme.Fonts.titleFont(size: fontSize)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.textAlignment = .left
        containerView.addSubview(titleLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Container height
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return containerView
    }
    
    // Creates a section header with smaller styling
    static func createSectionHeader(title: String) -> UIView {
        return createHeaderView(title: title, fontSize: 20)
    }
    
    // Creates a header with an AI Test button on the right
    static func createHeaderWithAIButton(title: String, aiAction: @escaping () -> Void, fontSize: CGFloat = 28) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Logo image view
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "PendulumLogo-removebg-preview")
        containerView.addSubview(logoImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = FocusCalendarTheme.Fonts.titleFont(size: fontSize)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.textAlignment = .left
        containerView.addSubview(titleLabel)
        
        // AI Test button with brain icon
        let aiButton = UIButton(type: .system)
        aiButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure brain icon
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let brainImage = UIImage(systemName: "brain.head.profile", withConfiguration: config)
        aiButton.setImage(brainImage, for: .normal)
        aiButton.tintColor = .systemBlue
        
        // Style the button
        aiButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        aiButton.layer.cornerRadius = 16
        aiButton.layer.borderWidth = 1
        aiButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Add action
        aiButton.addAction(UIAction { _ in aiAction() }, for: .touchUpInside)
        
        containerView.addSubview(aiButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: aiButton.leadingAnchor, constant: -10),
            
            // AI button constraints
            aiButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            aiButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            aiButton.widthAnchor.constraint(equalToConstant: 32),
            aiButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Container height
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return containerView
    }
    
    // Creates the header view for view controllers
    static func createViewControllerHeader(title: String) -> UIView {
        let headerView = createHeaderView(title: title, fontSize: 34)
        
        // Add subtle separator line
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = FocusCalendarTheme.lightBorderColor
        headerView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Increase height to accommodate separator
        headerView.constraints.first(where: { $0.firstAttribute == .height })?.constant = 45
        
        return headerView
    }
}