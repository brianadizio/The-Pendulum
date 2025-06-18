import UIKit
import AuthenticationServices
import FirebaseAuth

// Custom scroll view for debugging touch events
class DebugScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("🔍 ScrollView touchesBegan")
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("🔍 ScrollView touchesEnded")
        super.touchesEnded(touches, with: event)
    }
}

class SignInViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = DebugScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let signInButton = UIButton(type: .system)
    private let signUpButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    
    private let orLabel = UILabel()
    private let appleSignInButton = ASAuthorizationAppleIDButton()
    private let googleSignInButton = UIButton(type: .system)
    
    private let anonymousButton = UIButton(type: .system)
    
    private var authManager = AuthenticationManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add navigation bar if we're presented in a navigation controller
        if navigationController != nil {
            navigationItem.title = "Sign In"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeTapped)
            )
        }
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isUserInteractionEnabled = true
        scrollView.addSubview(contentView)
        
        // Logo
        logoImageView.image = UIImage(systemName: "figure.walk.circle.fill")
        logoImageView.tintColor = .systemBlue
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoImageView)
        
        // Title
        titleLabel.text = "The Pendulum"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Sign in to save your progress"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Email TextField
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)
        
        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)
        
        // Sign In Button
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        signInButton.backgroundColor = .systemBlue
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.layer.cornerRadius = 8
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(signInButton)
        
        // Sign Up Button
        signUpButton.setTitle("Create Account", for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(signUpButton)
        
        // Forgot Password Button
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(forgotPasswordButton)
        
        // Or Label
        orLabel.text = "OR"
        orLabel.font = .systemFont(ofSize: 14, weight: .medium)
        orLabel.textColor = .secondaryLabel
        orLabel.textAlignment = .center
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orLabel)
        
        // Apple Sign In Button
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInTouchDown), for: .touchDown)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton.isUserInteractionEnabled = true
        appleSignInButton.backgroundColor = UIColor.red.withAlphaComponent(0.1) // Temporary visual debugging
        print("🍎 Apple Sign In button configured with target-action")
        contentView.addSubview(appleSignInButton)
        
        // Google Sign In Button
        googleSignInButton.setTitle("Sign in with Google", for: .normal)
        googleSignInButton.setImage(UIImage(systemName: "globe"), for: .normal)
        googleSignInButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        googleSignInButton.backgroundColor = .systemBackground
        googleSignInButton.setTitleColor(.label, for: .normal)
        googleSignInButton.layer.cornerRadius = 8
        googleSignInButton.layer.borderWidth = 1
        googleSignInButton.layer.borderColor = UIColor.separator.cgColor
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(googleSignInButton)
        
        // Anonymous Button
        anonymousButton.setTitle("Continue as Guest", for: .normal)
        anonymousButton.titleLabel?.font = .systemFont(ofSize: 16)
        anonymousButton.setTitleColor(.secondaryLabel, for: .normal)
        anonymousButton.addTarget(self, action: #selector(anonymousSignInTapped), for: .touchUpInside)
        anonymousButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(anonymousButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign Up Button
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            signUpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Forgot Password Button
            forgotPasswordButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 8),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Or Label
            orLabel.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 32),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Apple Sign In Button
            appleSignInButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 24),
            appleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            appleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Google Sign In Button
            googleSignInButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 12),
            googleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            googleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Anonymous Button
            anonymousButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 24),
            anonymousButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            anonymousButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }
        
        showLoadingIndicator()
        authManager.signInWithEmail(email: email, password: password) { [weak self] result in
            self?.hideLoadingIndicator()
            switch result {
            case .success:
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showAlert(title: "Sign In Failed", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func signUpTapped() {
        let signUpVC = SignUpViewController()
        present(signUpVC, animated: true)
    }
    
    @objc private func forgotPasswordTapped() {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email to receive a password reset link", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            self?.authManager.resetPassword(email: email) { result in
                switch result {
                case .success:
                    self?.showAlert(title: "Success", message: "Password reset email sent")
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func appleSignInTouchDown() {
        print("🍎 Apple Sign In button TOUCH DOWN detected!")
    }
    
    @objc private func appleSignInTapped() {
        print("🍎 Apple Sign In button tapped!")
        
        // First test with a simple alert to make sure the tap is being detected
        showAlert(title: "Debug", message: "Apple Sign In button tap detected!")
        
        let nonce = authManager.startSignInWithAppleFlow()
        print("🍎 Generated nonce: \(nonce)")
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        print("🍎 Created authorization request")
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        print("🍎 About to perform authorization requests")
        controller.performRequests()
    }
    
    @objc private func googleSignInTapped() {
        showAlert(title: "Coming Soon", message: "Google Sign In will be implemented with Google Sign-In SDK")
        // Note: Google Sign In requires additional setup with Google Sign-In SDK
        // Instructions will be provided in the setup guide
    }
    
    @objc private func anonymousSignInTapped() {
        showLoadingIndicator()
        Auth.auth().signInAnonymously { [weak self] result, error in
            self?.hideLoadingIndicator()
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self?.dismiss(animated: true)
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private var loadingIndicator: UIActivityIndicatorView?
    
    private func showLoadingIndicator() {
        view.isUserInteractionEnabled = false
        
        // Create and add activity indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = FocusCalendarTheme.primaryTextColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        indicator.startAnimating()
        loadingIndicator = indicator
        
        // Dim the background
        view.alpha = 0.6
    }
    
    private func hideLoadingIndicator() {
        view.isUserInteractionEnabled = true
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
        view.alpha = 1.0
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // Don't cancel button touches
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardSize.height
        scrollView.scrollIndicatorInsets.bottom = keyboardSize.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Apple Sign In Delegate
extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        authManager.handleAppleSignIn(authorization: authorization) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showAlert(title: "Sign In Failed", message: error.localizedDescription)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(title: "Sign In Failed", message: error.localizedDescription)
    }
}

// MARK: - Apple Sign In Presentation
extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}