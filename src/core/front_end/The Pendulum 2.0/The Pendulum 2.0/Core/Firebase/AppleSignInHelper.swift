// AppleSignInHelper.swift
// The Pendulum 2.0
// Apple Sign-In coordinator for Firebase authentication

import Foundation
import Combine
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class AppleSignInHelper: NSObject, ObservableObject {
    @Published var isSigningIn: Bool = false
    @Published var errorMessage: String?

    private var currentNonce: String?
    private var completion: ((Result<AuthCredential, Error>) -> Void)?

    // MARK: - Nonce Generation

    /// Generate a random nonce for Apple Sign-In security
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    /// SHA256 hash of the nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - SwiftUI SignInWithAppleButton Support

    /// Prepare a nonce for the SwiftUI SignInWithAppleButton request.
    /// Call this in the button's request configuration closure and set `request.nonce` to the return value.
    func prepareRequest() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        isSigningIn = true
        errorMessage = nil
        return sha256(nonce)
    }

    /// Handle the result from a SwiftUI SignInWithAppleButton's onCompletion callback.
    /// Returns a Firebase AuthCredential on success, or nil on failure/cancellation.
    func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) -> AuthCredential? {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                isSigningIn = false
                errorMessage = "Failed to get Apple ID credential"
                return nil
            }

            isSigningIn = false
            return OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )

        case .failure(let error):
            isSigningIn = false
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                print("Apple Sign-In: User cancelled")
            } else {
                errorMessage = error.localizedDescription
                print("Apple Sign-In error: \(error.localizedDescription)")
            }
            return nil
        }
    }

    // MARK: - ASAuthorizationController Flow (used for reauthentication)

    /// Start the Apple Sign-In flow using ASAuthorizationController (for reauthentication before account deletion).
    func startSignInWithApple(completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        self.completion = completion
        isSigningIn = true
        errorMessage = nil

        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInHelper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first ?? ASPresentationAnchor()
        }
        return window
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            isSigningIn = false
            errorMessage = "Failed to get Apple ID credential"
            completion?(.failure(FirebaseError.authFailed("Invalid Apple credential")))
            return
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        isSigningIn = false
        completion?(.success(credential))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isSigningIn = false

        // Don't show error for user cancellation
        if let authError = error as? ASAuthorizationError,
           authError.code == .canceled {
            print("Apple Sign-In: User cancelled")
            completion?(.failure(error))
            return
        }

        errorMessage = error.localizedDescription
        print("Apple Sign-In error: \(error.localizedDescription)")
        completion?(.failure(error))
    }
}
