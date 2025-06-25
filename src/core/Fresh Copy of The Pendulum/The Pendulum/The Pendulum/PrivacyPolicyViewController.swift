import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, WKNavigationDelegate {
    
    private let webView = WKWebView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Setup activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = FocusCalendarTheme.primaryTextColor
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadPrivacyPolicy() {
        // Load privacy policy from centralized URL configuration
        let privacyPolicyURLString = AppConstants.URLs.privacyPolicy
        
        guard let url = URL(string: privacyPolicyURLString) else {
            // Fallback to embedded HTML if URL is invalid
            loadFallbackPrivacyPolicy()
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func loadFallbackPrivacyPolicy() {
        // Fallback HTML content in case the URL fails to load
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
                h1 {
                    color: #007AFF;
                    font-size: 24px;
                    margin-bottom: 20px;
                }
                p {
                    margin-bottom: 15px;
                }
            </style>
        </head>
        <body>
            <h1>Privacy Policy</h1>
            <p>Unable to load the privacy policy. Please check your internet connection and try again.</p>
            <p>You can also visit our website at goldenenterprises.com for more information.</p>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        loadFallbackPrivacyPolicy()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        loadFallbackPrivacyPolicy()
    }
}