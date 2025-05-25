import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    
    private let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Privacy Policy"
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Add navigation bar with close button
        navigationController?.navigationBar.tintColor = FocusCalendarTheme.primaryTextColor
        navigationController?.navigationBar.barTintColor = FocusCalendarTheme.backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: FocusCalendarTheme.primaryTextColor,
            .font: FocusCalendarTheme.titleFont
        ]
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = closeButton
        
        // Setup web view
        setupWebView()
        
        // Load privacy policy content
        loadPrivacyPolicy()
    }
    
    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = FocusCalendarTheme.backgroundColor
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadPrivacyPolicy() {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    padding: 20px;
                    line-height: 1.6;
                    color: #333;
                    background-color: #f5f5f5;
                }
                h1, h2 {
                    color: #007AFF;
                }
                h1 {
                    font-size: 24px;
                    margin-bottom: 20px;
                }
                h2 {
                    font-size: 18px;
                    margin-top: 25px;
                    margin-bottom: 10px;
                }
                p {
                    margin-bottom: 15px;
                }
                .date {
                    color: #666;
                    font-size: 14px;
                    margin-bottom: 20px;
                }
            </style>
        </head>
        <body>
            <h1>Privacy Policy</h1>
            <p class="date">Last updated: May 2025</p>
            
            <p>Golden Enterprises Solutions Inc. ("we," "our," or "us") respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your information when you use The Pendulum application.</p>
            
            <h2>Information We Collect</h2>
            <p>The Pendulum collects minimal information to provide you with the best possible experience:</p>
            <ul>
                <li><strong>Usage Data:</strong> We may collect anonymous data about how you interact with the app, including feature usage and performance metrics.</li>
                <li><strong>Device Information:</strong> Basic device information such as device type and operating system version for compatibility and optimization purposes.</li>
                <li><strong>Game Progress:</strong> Your simulation progress, achievements, and preferences are stored locally on your device.</li>
            </ul>
            
            <h2>How We Use Your Information</h2>
            <p>We use the collected information solely to:</p>
            <ul>
                <li>Improve app performance and user experience</li>
                <li>Fix bugs and technical issues</li>
                <li>Develop new features based on usage patterns</li>
                <li>Provide customer support when requested</li>
            </ul>
            
            <h2>Data Storage and Security</h2>
            <p>All game progress and personal preferences are stored locally on your device. We do not collect or store personal information on our servers. We implement appropriate security measures to protect your data from unauthorized access.</p>
            
            <h2>Third-Party Services</h2>
            <p>The Pendulum does not share your personal information with third parties. We do not use advertising networks or analytics services that collect personal data.</p>
            
            <h2>Children's Privacy</h2>
            <p>The Pendulum is suitable for all ages. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.</p>
            
            <h2>Changes to This Policy</h2>
            <p>We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the app. Your continued use of The Pendulum after changes indicates your acceptance of the updated policy.</p>
            
            <h2>Contact Us</h2>
            <p>If you have any questions about this Privacy Policy or our practices, please contact us at:</p>
            <p>
                Golden Enterprises Solutions Inc.<br>
                Rhode Island, USA<br>
                support@goldenenterprises.com
            </p>
            
            <p><em>© 2025 Golden Enterprises Solutions Inc. All rights reserved.</em></p>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}