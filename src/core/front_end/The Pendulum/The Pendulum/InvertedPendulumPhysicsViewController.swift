import UIKit

class InvertedPendulumPhysicsViewController: UIViewController {
    private let physicsView = InvertedPendulumPhysicsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Add physics view
        physicsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(physicsView)
        
        // Add back button
        let backButton = FocusCalendarTheme.createStyledButton("Back to Modes")
        backButton.addTarget(self, action: #selector(backToModes), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 120),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            physicsView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            physicsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            physicsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            physicsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backToModes() {
        dismiss(animated: true)
    }
}