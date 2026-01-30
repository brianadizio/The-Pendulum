// FirebaseCard.swift
// The Pendulum 2.0
// Account sign-in card for Integration tab

import SwiftUI
import AuthenticationServices

struct AccountCard: View {
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @StateObject private var appleSignInHelper = AppleSignInHelper()

    var onShowEmailSignIn: () -> Void

    private var isFullySignedIn: Bool {
        firebaseManager.authMethod == .apple || firebaseManager.authMethod == .email
    }

    private var accountDescription: String {
        if isFullySignedIn {
            if let email = firebaseManager.email {
                return email
            }
            if let name = firebaseManager.displayName {
                return name
            }
            return "Signed in"
        }
        return "Sign in to save your progress"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack(spacing: 12) {
                Image(systemName: isFullySignedIn ? "person.crop.circle.fill" : "person.crop.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isFullySignedIn ? PendulumColors.success : PendulumColors.gold)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Account")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text(accountDescription)
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if isFullySignedIn {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PendulumColors.success)
                }
            }

            // Sign-in buttons (only show when not signed in)
            if !isFullySignedIn {
                Divider()
                    .background(PendulumColors.bronze.opacity(0.2))

                VStack(spacing: 10) {
                    // Apple Sign-In button
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { _ in
                        // Handled by AppleSignInHelper delegate
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 44)
                    .cornerRadius(8)
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                handleAppleSignIn()
                            }
                    )

                    // Email sign-in button
                    Button(action: onShowEmailSignIn) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                            Text("Sign in with Email")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(PendulumColors.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(PendulumColors.bronze.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // Sign out button
                Divider()
                    .background(PendulumColors.bronze.opacity(0.2))

                Button(action: {
                    Task { await firebaseManager.signOut() }
                }) {
                    Text("Sign Out")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(PendulumColors.danger)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Error message
            if let error = appleSignInHelper.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.danger)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFullySignedIn
                        ? PendulumColors.success.opacity(0.3)
                        : PendulumColors.bronze.opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    private func handleAppleSignIn() {
        appleSignInHelper.startSignInWithApple { result in
            switch result {
            case .success(let credential):
                Task {
                    do {
                        try await FirebaseManager.shared.linkAppleCredential(credential)
                    } catch {
                        await MainActor.run {
                            appleSignInHelper.errorMessage = error.localizedDescription
                        }
                    }
                }
            case .failure(let error):
                if (error as NSError).code != 1001 {
                    appleSignInHelper.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    AccountCard(onShowEmailSignIn: {})
        .padding()
        .background(PendulumColors.background)
}
