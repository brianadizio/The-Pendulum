import UIKit
import MessageUI

class ContactSupportViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contact Support"
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Setup navigation bar
        navigationController?.navigationBar.tintColor = FocusCalendarTheme.primaryTextColor
        navigationController?.navigationBar.barTintColor = FocusCalendarTheme.backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: FocusCalendarTheme.primaryTextColor,
            .font: FocusCalendarTheme.titleFont
        ]
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = closeButton
        
        setupUI()
    }
    
    private func setupUI() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Company info section
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "GoldenEnterprisesLogoNoBG") ?? UIImage(named: "PendulumLogo") ?? UIImage(named: "AppIcon")
        if logoImageView.image == nil {
            logoImageView.backgroundColor = FocusCalendarTheme.accentGold
            logoImageView.layer.cornerRadius = 20
        }
        
        let companyLabel = createLabel(
            text: "Golden Enterprises Solutions Inc.",
            font: FocusCalendarTheme.Fonts.titleFont(size: 22),
            textColor: FocusCalendarTheme.primaryTextColor,
            alignment: .center
        )
        
        let chiefLabel = createLabel(
            text: "Brian DiZio, Chief Mathematician",
            font: FocusCalendarTheme.Fonts.bodyFont(size: 18),
            textColor: FocusCalendarTheme.secondaryTextColor,
            alignment: .center
        )
        
        let locationLabel = createLabel(
            text: "Rhode Island, USA",
            font: FocusCalendarTheme.Fonts.bodyFont(size: 16),
            textColor: FocusCalendarTheme.tertiaryTextColor,
            alignment: .center
        )
        
        // Contact options
        let contactOptionsLabel = createLabel(
            text: "How can we help you?",
            font: FocusCalendarTheme.Fonts.titleFont(size: 20),
            textColor: FocusCalendarTheme.primaryTextColor,
            alignment: .left
        )
        
        // Email support button
        let emailButton = createContactButton(
            title: "Email Support",
            subtitle: "contact@golden-enterprises.com",
            icon: "envelope.fill",
            action: #selector(emailSupportTapped)
        )
        
        // Website button
        let websiteButton = createContactButton(
            title: "Visit Our Website",
            subtitle: "www.golden-enterprises.net",
            icon: "globe",
            action: #selector(websiteTapped)
        )
        
        // Bug report button
        let bugButton = createContactButton(
            title: "Report a Bug",
            subtitle: "Help us improve The Pendulum",
            icon: "ant.fill",
            action: #selector(reportBugTapped)
        )
        
        // Feature request button
        let featureButton = createContactButton(
            title: "Request a Feature",
            subtitle: "Share your ideas with us",
            icon: "lightbulb.fill",
            action: #selector(requestFeatureTapped)
        )
        
        // FAQ section
        let faqLabel = createLabel(
            text: "Frequently Asked Questions",
            font: FocusCalendarTheme.Fonts.titleFont(size: 20),
            textColor: FocusCalendarTheme.primaryTextColor,
            alignment: .left
        )
        
        let faqText = createLabel(
            text: """
            Q: How do I reset my progress?
            A: Go to Settings > Graphics and select "Reset Progress"
            
            Q: Can I export my simulation data?
            A: Yes! Use the Integration tab to export your data in various formats.
            
            Q: How do perturbation modes work?
            A: Each perturbation mode applies different forces to the pendulum. Visit the Modes tab for detailed explanations.
            """,
            font: FocusCalendarTheme.Fonts.bodyFont(size: 16),
            textColor: FocusCalendarTheme.secondaryTextColor,
            alignment: .left
        )
        faqText.numberOfLines = 0
        
        // Add all subviews
        [logoImageView, companyLabel, chiefLabel, locationLabel,
         contactOptionsLabel, emailButton, websiteButton, bugButton, featureButton,
         faqLabel, faqText].forEach { contentView.addSubview($0) }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            companyLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 15),
            companyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            companyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            chiefLabel.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 5),
            chiefLabel.leadingAnchor.constraint(equalTo: companyLabel.leadingAnchor),
            chiefLabel.trailingAnchor.constraint(equalTo: companyLabel.trailingAnchor),
            
            locationLabel.topAnchor.constraint(equalTo: chiefLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: chiefLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: chiefLabel.trailingAnchor),
            
            contactOptionsLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 40),
            contactOptionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contactOptionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailButton.topAnchor.constraint(equalTo: contactOptionsLabel.bottomAnchor, constant: 20),
            emailButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailButton.heightAnchor.constraint(equalToConstant: 70),
            
            websiteButton.topAnchor.constraint(equalTo: emailButton.bottomAnchor, constant: 15),
            websiteButton.leadingAnchor.constraint(equalTo: emailButton.leadingAnchor),
            websiteButton.trailingAnchor.constraint(equalTo: emailButton.trailingAnchor),
            websiteButton.heightAnchor.constraint(equalToConstant: 70),
            
            bugButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 15),
            bugButton.leadingAnchor.constraint(equalTo: emailButton.leadingAnchor),
            bugButton.trailingAnchor.constraint(equalTo: emailButton.trailingAnchor),
            bugButton.heightAnchor.constraint(equalToConstant: 70),
            
            featureButton.topAnchor.constraint(equalTo: bugButton.bottomAnchor, constant: 15),
            featureButton.leadingAnchor.constraint(equalTo: emailButton.leadingAnchor),
            featureButton.trailingAnchor.constraint(equalTo: emailButton.trailingAnchor),
            featureButton.heightAnchor.constraint(equalToConstant: 70),
            
            faqLabel.topAnchor.constraint(equalTo: featureButton.bottomAnchor, constant: 40),
            faqLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            faqLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            faqText.topAnchor.constraint(equalTo: faqLabel.bottomAnchor, constant: 15),
            faqText.leadingAnchor.constraint(equalTo: faqLabel.leadingAnchor),
            faqText.trailingAnchor.constraint(equalTo: faqLabel.trailingAnchor),
            faqText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createLabel(text: String, font: UIFont, textColor: UIColor, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createContactButton(title: String, subtitle: String, icon: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        FocusCalendarTheme.styleCard(button)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Icon
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = FocusCalendarTheme.accentGold
        iconImageView.contentMode = .scaleAspectFit
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 17)
        titleLabel.textColor = FocusCalendarTheme.primaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = FocusCalendarTheme.Fonts.bodyFont(size: FocusCalendarTheme.Fonts.Size.caption)
        subtitleLabel.textColor = FocusCalendarTheme.secondaryTextColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        button.addSubview(iconImageView)
        button.addSubview(titleLabel)
        button.addSubview(subtitleLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 15),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -15),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        return button
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func emailSupportTapped() {
        let email = "contact@golden-enterprises.com"
        let subject = "The Pendulum - Support Request"
        let body = """
        
        
        ---
        App Version: 1.0.0
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func websiteTapped() {
        if let url = URL(string: "https://www.golden-enterprises.net") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func reportBugTapped() {
        let email = "contact@golden-enterprises.com"
        let subject = "The Pendulum - Bug Report"
        let body = """
        Please describe the bug you encountered:
        
        Steps to reproduce:
        1. 
        2. 
        3. 
        
        Expected behavior:
        
        Actual behavior:
        
        ---
        App Version: 1.0.0
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func requestFeatureTapped() {
        let email = "contact@golden-enterprises.com"
        let subject = "The Pendulum - Feature Request"
        let body = """
        I would like to suggest the following feature:
        
        Description:
        
        Why this would be useful:
        
        ---
        App Version: 1.0.0
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ContactSupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}