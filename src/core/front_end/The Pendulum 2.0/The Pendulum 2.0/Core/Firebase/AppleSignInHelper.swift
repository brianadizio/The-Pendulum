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

    // MARK: - Sign-In Flow

    /// Start the Apple Sign-In flow
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
        controller.performRequests()
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
