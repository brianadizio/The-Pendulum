//
//  CipherAuthView.swift
//  The Pendulum 2.0
//
//  Presents a cipher authentication challenge as a playable pendulum level.
//  Flow: challenge received -> load level spec -> user plays -> verify -> result
//

import SwiftUI

struct CipherAuthView: View {
    @ObservedObject var gameState: GameState
    let challengeId: String?
    let onComplete: (CipherAuthService.AuthResult?) -> Void

    @State private var phase: AuthPhase = .loading
    @State private var authConfig: LevelConfig?
    @State private var authResult: CipherAuthService.AuthResult?
    @State private var errorMessage: String?

    enum AuthPhase {
        case loading
        case ready
        case playing
        case verifying
        case result
        case error
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                switch phase {
                case .loading:
                    loadingView

                case .ready:
                    readyView

                case .playing:
                    playingView

                case .verifying:
                    verifyingView

                case .result:
                    resultView

                case .error:
                    errorView
                }
            }
            .padding()
            .navigationTitle("Identity Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if phase != .playing && phase != .verifying {
                        Button("Cancel") {
                            GoldenModeManager.shared.cancelAuthChallenge()
                            onComplete(nil)
                        }
                    }
                }
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
            Text("Loading challenge...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var readyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Authentication Required")
                .font(.title2.bold())

            Text("Balance the pendulum to verify your identity. Your unique movement pattern will be compared to your behavioral profile.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let config = authConfig, let countdown = config.countdownTime {
                HStack {
                    Image(systemName: "timer")
                    Text("Time limit: \(Int(countdown))s")
                }
                .font(.subheadline)
                .foregroundStyle(.orange)
            }

            Button {
                startAuthSession()
            } label: {
                Text("Begin Verification")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
    }

    private var playingView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                Text("Verifying...")
            }
            .font(.caption)
            .foregroundStyle(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1))
            .clipShape(Capsule())

            Text("Balance the pendulum")
                .font(.headline)
                .foregroundStyle(.secondary)

            // The actual gameplay happens in the PlayView behind this sheet.
            // This view shows status while the user plays.
            Text("Complete the level to verify your identity")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Done Playing") {
                Task { await verifySession() }
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.green)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 16)
        }
    }

    private var verifyingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing your movement pattern...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            if let result = authResult {
                if result.decision == "ACCEPT" {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)

                    Text("Identity Verified")
                        .font(.title2.bold())

                    Text("Confidence: \(Int(result.confidence * 100))%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let binding = result.s1BindingScore {
                        Text("S\u{00B9} Binding: \(String(format: "%.2f", binding))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else if result.decision == "REJECT" {
                    Image(systemName: "xmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.red)

                    Text("Verification Failed")
                        .font(.title2.bold())

                    Text("Your movement pattern did not match your profile.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)

                    Text("Uncertain")
                        .font(.title2.bold())

                    Text("Please try again for a more confident result.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("Done") {
                    onComplete(result)
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(result.decision == "ACCEPT" ? .green : .blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Challenge Failed")
                .font(.title2.bold())

            Text(errorMessage ?? "Unknown error")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Dismiss") {
                onComplete(nil)
            }
            .font(.headline)
            .padding()
        }
    }

    // MARK: - Actions

    private func loadChallenge() async {
        // If we have a challengeId from push notification, the challenge already exists
        // on the server. We just need to present the level.
        // If no challengeId, request a new challenge.
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

        // Apply the cipher level config to the game
        gameState.levelManager.activeMode = .golden
        gameState.gameMode = .golden

        // The PendulumViewModel will detect isAuthSession and record frames
        // via GoldenModeManager.shared.cipherCollector
        phase = .playing
    }

    private func verifySession() async {
        phase = .verifying

        let sessionDuration = gameState.csvSessionManager?.sessionDuration ?? 0

        do {
            let result = try await GoldenModeManager.shared.verifyAuthSession(
                completionTime: sessionDuration
            )
            authResult = result
            phase = .result
        } catch {
            errorMessage = error.localizedDescription
            phase = .error
        }
    }
}
