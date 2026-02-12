// ChatView.swift
// The Pendulum 2.0
// Main chat interface - "Your Play Style, Decoded"

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatService = ChatService.shared
    @ObservedObject var metricsCalculator: CSVMetricsCalculator

    @State private var inputText = ""
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message if no messages
                            if chatService.currentConversation?.messages.isEmpty ?? true {
                                welcomeSection
                            }

                            // Messages
                            if let conversation = chatService.currentConversation {
                                ForEach(conversation.messages) { message in
                                    ChatBubbleView(message: message)
                                        .id(message.id)
                                }
                            }

                            // Typing indicator
                            if chatService.isLoading {
                                TypingIndicatorView()
                            }

                            // Error message
                            if let error = chatService.errorMessage {
                                errorView(error)
                            }

                            // Bottom spacer for scroll
                            Color.clear
                                .frame(height: 20)
                                .id("bottom")
                        }
                        .padding(.vertical, 16)
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                    .onChange(of: chatService.currentConversation?.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }

                // Input bar
                ChatInputView(
                    text: $inputText,
                    isLoading: chatService.isLoading
                ) {
                    sendMessage()
                }
            }
            .background(PendulumColors.background)
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(PendulumColors.gold)
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            chatService.clearConversation()
                        }) {
                            Label("New Conversation", systemImage: "plus.bubble")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(PendulumColors.bronze)
                    }
                }
            }
        }
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(PendulumColors.gold)

                Text("Your Play Style, Decoded")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(PendulumColors.text)

                Text("Ask questions about your gameplay patterns and discover insights about your cognitive style.")
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 24)

            // Tier 1 Questions
            VStack(alignment: .leading, spacing: 12) {
                Text("QUICK INSIGHTS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(PendulumColors.textTertiary)
                    .padding(.horizontal, 16)

                VStack(spacing: 8) {
                    ForEach(chatService.tier1Questions) { question in
                        PresetQuestionButton(question: question) {
                            sendPresetQuestion(question)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Tier 2 Questions (if available)
            let tier2 = chatService.availableTier2Questions
            if !tier2.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("DEEP ANALYSIS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(PendulumColors.textTertiary)
                        .padding(.horizontal, 16)

                    VStack(spacing: 8) {
                        ForEach(tier2) { question in
                            PresetQuestionButton(question: question) {
                                sendPresetQuestion(question)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            // Unavailable questions hint
            if tier2.count < PresetQuestionsCatalog.tier2Questions.count {
                unavailableQuestionsHint
            }
        }
    }

    private var unavailableQuestionsHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))

            Text("Connect Apple Health or The Maze to unlock more insights")
                .font(.system(size: 12))
        }
        .foregroundStyle(PendulumColors.textTertiary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(PendulumColors.backgroundSecondary)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func errorView(_ error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(PendulumColors.caution)

            Text(error)
                .font(.system(size: 13))
                .foregroundStyle(PendulumColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PendulumColors.caution.opacity(0.1))
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Actions

    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let context = GameplaySummaryBuilder.build(from: metricsCalculator)
        inputText = ""

        Task {
            await chatService.sendMessage(trimmedText, context: context)
        }
    }

    private func sendPresetQuestion(_ question: PresetQuestion) {
        let context = GameplaySummaryBuilder.build(from: metricsCalculator)

        Task {
            await chatService.sendPresetQuestion(question, context: context)
        }
    }
}

// MARK: - Preset Question Button

struct PresetQuestionButton: View {
    let question: PresetQuestion
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: question.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(PendulumColors.gold)
                    .frame(width: 24)

                Text(question.displayText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(PendulumColors.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PendulumColors.bronze)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PendulumColors.bronze.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ChatView(metricsCalculator: CSVMetricsCalculator())
}
