// ChatBubbleView.swift
// The Pendulum 2.0
// Individual message bubbles for AI chat

import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    let presetQuestion: PresetQuestion?

    init(message: ChatMessage) {
        self.message = message
        // Look up preset question if this message has one
        if let questionId = message.presetQuestionId {
            self.presetQuestion = PresetQuestionsCatalog.allQuestions.first { $0.id == questionId }
        } else {
            self.presetQuestion = nil
        }
    }

    private var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isUser {
                Spacer(minLength: 40)
            } else {
                // Assistant avatar
                assistantAvatar
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Show preset question badge if applicable
                if let question = presetQuestion, isUser {
                    HStack(spacing: 4) {
                        Image(systemName: question.icon)
                            .font(.system(size: 10))
                        Text(question.displayText)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(PendulumColors.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(PendulumColors.gold.opacity(0.15))
                    )
                }

                // Message bubble
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundStyle(isUser ? .white : PendulumColors.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isUser ? PendulumColors.gold : PendulumColors.backgroundTertiary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isUser ? Color.clear : PendulumColors.bronze.opacity(0.2),
                                lineWidth: 1
                            )
                    )

                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundStyle(PendulumColors.textTertiary)
            }

            if !isUser {
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 16)
    }

    private var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [PendulumColors.goldLight, PendulumColors.gold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)

            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }

        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PendulumColors.goldLight, PendulumColors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Typing dots
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(PendulumColors.bronze)
                        .frame(width: 8, height: 8)
                        .opacity(animationPhase == index ? 1 : 0.4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
            )

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 16)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ChatBubbleView(message: ChatMessage(
            role: .user,
            content: "Am I cautious or impulsive?"
        ))

        ChatBubbleView(message: ChatMessage(
            role: .assistant,
            content: "Based on your gameplay data, you show a thoughtful, measured approach. Your reaction time of 0.35s combined with a low overcorrection rate suggests you prefer accuracy over speed."
        ))

        TypingIndicatorView()
    }
    .padding(.vertical, 16)
    .background(PendulumColors.background)
}
