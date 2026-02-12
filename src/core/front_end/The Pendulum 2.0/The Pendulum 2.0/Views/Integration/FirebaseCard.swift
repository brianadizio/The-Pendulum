// FirebaseCard.swift
// The Pendulum 2.0
// Account sign-in card for Integration tab

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct AccountCard: View {
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @StateObject private var appleSignInHelper = AppleSignInHelper()

    var onShowEmailSignIn: () -> Void
    var onAccountDeleted: (() -> Void)?

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

    // Delete account state
    @State private var showingDeleteConfirmation = false
    @State private var showingReauthPassword = false
    @State private var reauthPassword = ""
    @State private var isDeleting = false
    @State private var deleteError: String?

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

                // Delete Account button
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack(spacing: 6) {
                        if isDeleting {
                            ProgressView()
                                .controlSize(.small)
                                .tint(PendulumColors.danger)
                        }
                        Text("Delete Account")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(PendulumColors.danger.opacity(0.7))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isDeleting)
            }

            // Error messages
            if let error = appleSignInHelper.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.danger)
            }

            if let error = deleteError {
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
        .alert("Delete Account?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                performAccountDeletion()
            }
        } message: {
            Text("This will permanently delete your account, all cloud data, and local data. This action cannot be undone.")
        }
        .alert("Re-enter Password", isPresented: $showingReauthPassword) {
            SecureField("Password", text: $reauthPassword)
            Button("Cancel", role: .cancel) {
                reauthPassword = ""
                isDeleting = false
            }
            Button("Confirm", role: .destructive) {
                performReauthAndDelete()
            }
        } message: {
            Text("For security, please re-enter your password to delete your account.")
        }
    }

    // MARK: - Apple Sign-In

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

    // MARK: - Account Deletion

    private func performAccountDeletion() {
        isDeleting = true
        deleteError = nil

        Task {
            do {
                try await firebaseManager.deleteAccount()
                await MainActor.run {
                    isDeleting = false
                    onAccountDeleted?()
                }
            } catch let error as NSError {
                await MainActor.run {
                    if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        if firebaseManager.authMethod == .email {
                            showingReauthPassword = true
                        } else if firebaseManager.authMethod == .apple {
                            handleAppleReauthForDeletion()
                        }
                    } else {
                        deleteError = error.localizedDescription
                        isDeleting = false
                    }
                }
            }
        }
    }

    private func performReauthAndDelete() {
        guard !reauthPassword.isEmpty, let email = firebaseManager.email else {
            deleteError = "Please enter your password"
            isDeleting = false
            return
        }

        deleteError = nil

        Task {
            do {
                try await firebaseManager.reauthenticateWithEmail(email: email, password: reauthPassword)
                reauthPassword = ""
                try await firebaseManager.deleteAccount()
                await MainActor.run {
                    isDeleting = false
                    onAccountDeleted?()
                }
            } catch {
                await MainActor.run {
                    deleteError = error.localizedDescription
                    reauthPassword = ""
                    isDeleting = false
                }
            }
        }
    }

    private func handleAppleReauthForDeletion() {
        appleSignInHelper.startSignInWithApple { result in
            switch result {
            case .success(let credential):
                Task {
                    do {
                        try await firebaseManager.reauthenticateWithApple(credential)
                        try await firebaseManager.deleteAccount()
                        await MainActor.run {
                            isDeleting = false
                            onAccountDeleted?()
                        }
                    } catch {
                        await MainActor.run {
                            deleteError = error.localizedDescription
                            isDeleting = false
                        }
                    }
                }
            case .failure(let error):
                if (error as NSError).code != 1001 {
                    deleteError = error.localizedDescription
                }
                isDeleting = false
            }
        }
    }
}

#Preview {
    AccountCard(onShowEmailSignIn: {})
        .padding()
        .background(PendulumColors.background)
}
