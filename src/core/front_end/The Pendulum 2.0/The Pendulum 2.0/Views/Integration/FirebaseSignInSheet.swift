// FirebaseSignInSheet.swift
// The Pendulum 2.0
// Email/password sign-in and account creation sheet

import SwiftUI

struct FirebaseSignInSheet: View {
    var onDismiss: () -> Void

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isCreatingAccount: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(PendulumColors.gold)
                    .padding(.top, 32)

                // Title
                Text(isCreatingAccount ? "Create Account" : "Sign In")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(PendulumColors.text)

                Text("Sign in to sync your data across devices")
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .multilineTextAlignment(.center)

                // Form fields
                VStack(spacing: 16) {
                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(PendulumColors.textSecondary)

                        TextField("email@example.com", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(PendulumColors.backgroundSecondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(PendulumColors.textSecondary)

                        SecureField("Password", text: $password)
                            .textContentType(isCreatingAccount ? .newPassword : .password)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(PendulumColors.backgroundSecondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)

                // Error
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(PendulumColors.danger)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // Submit button
                Button(action: submit) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isCreatingAccount ? "Create Account" : "Sign In")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFormValid ? PendulumColors.gold : PendulumColors.iron)
                    )
                }
                .disabled(!isFormValid || isLoading)
                .padding(.horizontal, 24)

                // Toggle mode
                Button(action: {
                    withAnimation {
                        isCreatingAccount.toggle()
                        errorMessage = nil
                    }
                }) {
                    Text(isCreatingAccount ? "Already have an account? Sign In" : "Don't have an account? Create One")
                        .font(.system(size: 14))
                        .foregroundStyle(PendulumColors.gold)
                }
                .padding(.bottom, 32)
            }
            .background(PendulumColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(PendulumColors.textSecondary)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6
    }

    private func submit() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                if isCreatingAccount {
                    try await FirebaseManager.shared.createAccount(email: email, password: password)
                } else {
                    try await FirebaseManager.shared.signInWithEmail(email: email, password: password)
                }
                await MainActor.run {
                    isLoading = false
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    FirebaseSignInSheet(onDismiss: {})
}
