import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit
import UIKit

// MARK: - Authentication Manager
class AuthenticationManager: NSObject, ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var authError: String?
    
    private var currentNonce: String?
    private let db = Firestore.firestore()
    
    override init() {
        super.init()
        checkAuthStatus()
    }
    
    // MARK: - Check Current Auth Status
    func checkAuthStatus() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
            
            if let user = user {
                print("🔐 User authenticated: \(user.uid)")
                self?.fetchUserProfile(userId: user.uid)
            }
            
            // Post notification when auth state changes
            NotificationCenter.default.post(name: .authStateDidChange, object: nil)
        }
    }
    
    // MARK: - Email/Password Sign In
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.authError = error.localizedDescription
                completion(.failure(error))
            } else if let user = result?.user {
                self?.fetchUserProfile(userId: user.uid)
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Email/Password Sign Up
    func signUpWithEmail(email: String, password: String, displayName: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.authError = error.localizedDescription
                completion(.failure(error))
            } else if let user = result?.user {
                // Update display name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating display name: \(error)")
                    }
                }
                
                // Create user profile in Firestore
                self?.createUserProfile(user: user, displayName: displayName)
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Apple Sign In
    func handleAppleSignIn(authorization: ASAuthorization, completion: @escaping (Result<User, Error>) -> Void) {
        print("🍎 Starting Apple Sign-In handling")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ Failed to get Apple ID credential")
            completion(.failure(AuthError.invalidCredential))
            return
        }
        
        print("🍎 Got Apple ID credential for user: \(appleIDCredential.user)")
        
        guard let nonce = currentNonce else {
            print("❌ Missing nonce")
            completion(.failure(AuthError.missingNonce))
            return
        }
        
        print("🍎 Using nonce: \(nonce)")
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("❌ Missing identity token")
            completion(.failure(AuthError.missingToken))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("❌ Failed to convert token to string")
            completion(.failure(AuthError.invalidToken))
            return
        }
        
        print("🍎 Successfully got ID token string")
        
        // Create Firebase credential
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        
        print("🍎 Created Firebase credential, attempting sign in...")
        
        // Sign in with Firebase
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                print("❌ Firebase sign in failed: \(error.localizedDescription)")
                self?.authError = error.localizedDescription
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else if let user = result?.user {
                print("✅ Firebase sign in successful for user: \(user.uid)")
                
                // Get display name from Apple if available
                let displayName = appleIDCredential.fullName?.givenName ?? "Player"
                print("🍎 Display name: \(displayName)")
                
                // Update user profile if needed
                if user.displayName == nil {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("⚠️ Failed to update display name: \(error)")
                        } else {
                            print("✅ Display name updated successfully")
                        }
                    }
                }
                
                self?.createUserProfile(user: user, displayName: displayName)
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            } else {
                print("❌ Unknown error: no user and no error")
                DispatchQueue.main.async {
                    completion(.failure(AuthError.invalidCredential))
                }
            }
        }
    }
    
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - User Profile Management
    private func createUserProfile(user: User, displayName: String) {
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "displayName": displayName,
            "createdAt": FieldValue.serverTimestamp(),
            "highScore": 0,
            "levelsCompleted": 0,
            "totalPlayTime": 0,
            "achievements": []
        ]
        
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Error creating user profile: \(error)")
            } else {
                print("User profile created successfully")
            }
        }
    }
    
    private func fetchUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error)")
            } else if let data = snapshot?.data() {
                print("User profile fetched: \(data)")
                // You can store additional user data here if needed
            }
        }
    }
    
    // MARK: - Apple Sign In Helpers
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func startSignInWithAppleFlow() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
}

// MARK: - Custom Error Types
enum AuthError: LocalizedError {
    case invalidCredential
    case missingNonce
    case missingToken
    case invalidToken
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid authentication credential"
        case .missingNonce:
            return "Missing authentication nonce"
        case .missingToken:
            return "Missing authentication token"
        case .invalidToken:
            return "Invalid authentication token"
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let authStateDidChange = Notification.Name("authStateDidChange")
}