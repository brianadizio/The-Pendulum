// ChatInputView.swift
// The Pendulum 2.0
// Text input with send button for AI chat

import SwiftUI

struct ChatInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Text field
            HStack {
                TextField("Ask about your play style...", text: $text, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundStyle(PendulumColors.text)
                    .lineLimit(1...4)
                    .focused($isFocused)
                    .disabled(isLoading)

                // Clear button (when text exists)
                if !text.isEmpty && !isLoading {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(PendulumColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isFocused ? PendulumColors.gold.opacity(0.5) : PendulumColors.bronze.opacity(0.2),
                        lineWidth: 1
                    )
            )

            // Send button
            Button(action: {
                if canSend {
                    onSend()
                    isFocused = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(canSend ? PendulumColors.gold : PendulumColors.silver)
                        .frame(width: 40, height: 40)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .disabled(!canSend)
            .animation(.spring(response: 0.3), value: canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            PendulumColors.background
                .shadow(color: PendulumColors.iron.opacity(0.1), radius: 8, y: -4)
        )
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        ChatInputView(
            text: .constant(""),
            isLoading: false,
            onSend: {}
        )
    }
    .background(PendulumColors.background)
}
