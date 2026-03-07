//
//  CipherAuthView.swift
//  The Pendulum 2.0
//
//  Presents a cipher authentication challenge as a playable pendulum level.
//  Flow: load challenge -> show ready screen -> dismiss to play -> auto-verify on session end
//

import SwiftUI

struct CipherAuthView: View {
    @ObservedObject var gameState: GameState
    let challengeId: String?
    let onComplete: (CipherAuthService.AuthResult?) -> Void
    /// Called when the user starts playing — dismisses the cover so the Play tab is visible
    var onStartPlaying: (() -> Void)?

    @State private var phase: AuthPhase = .loading
    @State private var authConfig: LevelConfig?
    @State private var authResult: CipherAuthService.AuthResult?
    @State private var errorMessage: String?

    enum AuthPhase {
        case loading
        case ready
        case error
    }

    var body: some View {
        ZStack {
            PendulumColors.background.ignoresSafeArea()

            VStack(spacing: 24) {
                // Header bar
                HStack {
                    Button("Cancel") {
                        GoldenModeManager.shared.cancelAuthChallenge()
                        onComplete(nil)
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(PendulumColors.textSecondary)

                    Spacer()

                    Text("Identity Verification")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(PendulumColors.text)

                    Spacer()

                    // Balance the layout
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .hidden()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                switch phase {
                case .loading:
                    loadingView
                case .ready:
                    readyView
                case .error:
                    errorView
                }

                Spacer()
            }
        }
        .task {
            await loadChallenge()
        }
    }

    // MARK: - Phase Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(PendulumColors.gold)

            Text("Loading challenge...")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(PendulumColors.textSecondary)
        }
    }

    private var readyView: some View {
        VStack(spacing: 24) {
            // Shield icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PendulumColors.gold.opacity(0.2), PendulumColors.bronze.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PendulumColors.gold, PendulumColors.bronze],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("Authentication Required")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Text("Balance the pendulum to verify your identity. Your unique movement pattern will be compared to your behavioral profile.")
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let config = authConfig, let countdown = config.countdownTime {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                    Text("Time limit: \(Int(countdown))s")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(PendulumColors.caution)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(PendulumColors.caution.opacity(0.12))
                )
            }

            Button {
                startAuthSession()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Begin Verification")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [PendulumColors.gold, PendulumColors.bronze],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: PendulumColors.gold.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(PendulumColors.caution.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(PendulumColors.caution)
            }

            Text("Challenge Failed")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Text(errorMessage ?? "Unknown error")
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Dismiss") {
                onComplete(nil)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(PendulumColors.text)
            .padding(.vertical, 12)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Actions

    private func loadChallenge() async {
        do {
            let (_, config) = try await GoldenModeManager.shared.requestAuthChallenge(
                action: "verify_identity",
                actionType: "authentication",
                tier: 1
            )
            authConfig = config
            phase = .ready
        } catch {
            errorMessage = error.localizedDescription
            phase = .error
        }
    }

    private func startAuthSession() {
        guard authConfig != nil else { return }

        // Configure game for auth level
        gameState.levelManager.activeMode = .golden
        gameState.gameMode = .golden

        // Dismiss the cover — user plays on the Play tab
        // GoldenModeManager.isAuthSession is now true, so PendulumViewModel
        // feeds data to the cipher collector, and ContentView auto-verifies
        // when the session ends.
        if let onStartPlaying = onStartPlaying {
            onStartPlaying()
        } else {
            onComplete(nil)
        }
    }
}

// MARK: - Auth Result Sheet (shown after auto-verify in ContentView)

struct CipherAuthResultView: View {
    let result: CipherAuthService.AuthResult
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            PendulumColors.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: iconName)
                        .font(.system(size: 44))
                        .foregroundStyle(iconColor)
                }

                // Title
                Text(titleText)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(PendulumColors.text)

                // Subtitle
                Text(subtitleText)
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Confidence score
                VStack(spacing: 8) {
                    Text("Confidence")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PendulumColors.textTertiary)

                    Text("\(Int(result.confidence * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(iconColor)

                    if let binding = result.s1BindingScore {
                        Text("S\u{00B9} Binding: \(String(format: "%.2f", binding))")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(PendulumColors.textTertiary)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PendulumColors.backgroundTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(iconColor.opacity(0.3), lineWidth: 1)
                )

                Spacer()

                // Dismiss button
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [PendulumColors.gold, PendulumColors.bronze],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }

    private var iconName: String {
        switch result.decision {
        case "ACCEPT": return "checkmark.seal.fill"
        case "REJECT": return "xmark.seal.fill"
        default: return "questionmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch result.decision {
        case "ACCEPT": return PendulumColors.success
        case "REJECT": return PendulumColors.danger
        default: return PendulumColors.caution
        }
    }

    private var iconBackgroundColor: Color { iconColor }

    private var titleText: String {
        switch result.decision {
        case "ACCEPT": return "Identity Verified"
        case "REJECT": return "Verification Failed"
        default: return "Uncertain"
        }
    }

    private var subtitleText: String {
        switch result.decision {
        case "ACCEPT": return "Your movement pattern matched your behavioral profile."
        case "REJECT": return "Your movement pattern did not match your profile."
        default: return "Please try again for a more confident result."
        }
    }
}
