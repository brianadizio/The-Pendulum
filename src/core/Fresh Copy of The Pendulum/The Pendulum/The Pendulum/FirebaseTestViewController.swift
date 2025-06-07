import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics

class FirebaseTestViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let statusLabel = UILabel()
    private let resultTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Firebase Test"
        view.backgroundColor = .systemBackground
        
        setupUI()
        checkFirebaseStatus()
    }
    
    private func setupUI() {
        // Navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Status Label
        statusLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // Result Text View
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        resultTextView.isEditable = false
        resultTextView.backgroundColor = .secondarySystemBackground
        resultTextView.layer.cornerRadius = 8
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultTextView)
        
        // Test Buttons
        let testImportsButton = createButton(title: "Test Imports", action: #selector(testImports))
        let testAuthButton = createButton(title: "Test Auth", action: #selector(testAuth))
        let testDatabaseButton = createButton(title: "Test Firestore", action: #selector(testDatabase))
        let testAnalyticsButton = createButton(title: "Test Analytics", action: #selector(testAnalytics))
        let runAllTestsButton = createButton(title: "Run All Tests", action: #selector(runAllTests))
        runAllTestsButton.backgroundColor = .systemGreen
        
        let debugButton = createButton(title: "Run Debug Diagnostics", action: #selector(runDebugDiagnostics))
        debugButton.backgroundColor = .systemOrange
        
        let buttonStack = UIStackView(arrangedSubviews: [
            testImportsButton,
            testAuthButton,
            testDatabaseButton,
            testAnalyticsButton,
            runAllTestsButton,
            debugButton
        ])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            buttonStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            resultTextView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            resultTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func checkFirebaseStatus() {
        var status = "🔥 Firebase Status\n\n"
        
        // Check GoogleService-Info.plist
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            status += "✅ GoogleService-Info.plist found\n"
            statusLabel.textColor = .systemGreen
        } else {
            status += "❌ GoogleService-Info.plist NOT found\n"
            status += "Please download from Firebase Console\n"
            statusLabel.textColor = .systemRed
        }
        
        statusLabel.text = status
    }
    
    @objc private func testImports() {
        logResult("Testing Firebase imports...")
        let success = FirebaseTestConfiguration.testFirebaseImports()
        if success {
            logResult("✅ All imports successful!")
        }
    }
    
    @objc private func testAuth() {
        logResult("\n🔐 Testing Authentication...")
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                self?.logResult("❌ Auth failed: \(error.localizedDescription)")
            } else if let user = result?.user {
                self?.logResult("✅ Auth successful!")
                self?.logResult("User ID: \(user.uid)")
                self?.logResult("Is Anonymous: \(user.isAnonymous)")
            }
        }
    }
    
    @objc private func testDatabase() {
        logResult("\n💾 Testing Cloud Firestore...")
        
        let db = Firestore.firestore()
        let testData: [String: Any] = [
            "timestamp": FieldValue.serverTimestamp(),
            "device": UIDevice.current.name,
            "test_time": Date().description,
            "platform": "iOS"
        ]
        
        // Write to Firestore
        db.collection("pendulum_test").addDocument(data: testData) { [weak self] error in
            if let error = error {
                self?.logResult("❌ Firestore write failed: \(error.localizedDescription)")
                self?.logResult("💡 Check Firestore rules in Firebase Console")
            } else {
                self?.logResult("✅ Firestore write successful!")
                
                // Read it back
                db.collection("pendulum_test")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            self?.logResult("❌ Firestore read failed: \(error.localizedDescription)")
                        } else if let document = querySnapshot?.documents.first {
                            self?.logResult("✅ Firestore read successful!")
                            self?.logResult("Document ID: \(document.documentID)")
                            self?.logResult("Data: \(document.data())")
                        }
                    }
            }
        }
    }
    
    @objc private func testAnalytics() {
        logResult("\n📊 Testing Analytics...")
        
        Analytics.logEvent("firebase_test_event", parameters: [
            "test_type": "manual",
            "timestamp": Date().timeIntervalSince1970,
            "device": UIDevice.current.model
        ])
        
        Analytics.setUserProperty("firebase_tester", forName: "user_type")
        
        logResult("✅ Analytics event logged!")
        logResult("Note: Events may take time to appear in console")
    }
    
    @objc private func runAllTests() {
        resultTextView.text = ""
        logResult("🧪 Running all Firebase tests...\n")
        
        testImports()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.testAuth()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.testDatabase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.testAnalytics()
            self?.logResult("\n🎉 All tests completed!")
        }
    }
    
    private func logResult(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.resultTextView.text += message + "\n"
            
            // Auto-scroll to bottom
            if let textView = self?.resultTextView {
                let bottom = NSMakeRange(textView.text.count - 1, 1)
                textView.scrollRangeToVisible(bottom)
            }
        }
    }
    
    @objc private func runDebugDiagnostics() {
        resultTextView.text = ""
        logResult("🔍 Running comprehensive Firebase diagnostics...\n")
        logResult("Please wait, this may take a few seconds...\n")
        
        FirebaseDebugHelper.runComprehensiveDebug { [weak self] debugReport in
            DispatchQueue.main.async {
                self?.resultTextView.text = debugReport
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}