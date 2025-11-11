// DashboardInfoButton.swift
// Info button component for showing metric descriptions

import UIKit

class DashboardInfoButton: UIButton {
    
    private let metricTitle: String
    private let metricDescription: String
    
    init(title: String, description: String) {
        self.metricTitle = title
        self.metricDescription = description
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Configure button appearance
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let infoImage = UIImage(systemName: "info.circle", withConfiguration: config)
        setImage(infoImage, for: .normal)
        tintColor = .goldenAccent
        
        // Add action
        addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        
        // Set size
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 20),
            heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func showInfo() {
        // Find the parent view controller
        guard let viewController = self.firstAvailableUIViewController() else { return }
        
        // Create alert with description
        let alert = UIAlertController(
            title: metricTitle,
            message: metricDescription,
            preferredStyle: .alert
        )
        
        // Style the alert
        if let titleLabel = alert.view.subviews.first?.subviews.first?.subviews.first as? UILabel {
            titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            titleLabel.textColor = .goldenDark
        }
        
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        
        viewController.present(alert, animated: true)
    }
}

// Extension to find parent view controller
extension UIView {
    func firstAvailableUIViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.firstAvailableUIViewController()
        } else {
            return nil
        }
    }
}