// GoldenChatView.swift
// Golden Enterprises Theme System
// AI Chat assistant component for app guidance

import SwiftUI

// MARK: - Message Model

/// Represents a chat message
public struct ChatMessage: Identifiable, Equatable {
    public let id: UUID
    public let content: String
    public let isFromUser: Bool
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

// MARK: - Chat View Model Protocol

/// Protocol for chat view model implementations
public protocol ChatViewModelProtocol: ObservableObject {
    var messages: [ChatMessage] { get }
    var isLoading: Bool { get }
    var inputText: String { get set }

    func sendMessage()
}

// MARK: - Chat Message Bubble

/// Individual message bubble
public struct ChatMessageBubble: View {
    let message: ChatMessage

    @Environment(\.goldenTheme) var theme

    public init(message: ChatMessage) {
        self.message = message
    }

    public var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Group {
                    if message.isFromUser {
                        Text(message.content)
                            .font(.golden(.body))
                            .foregroundStyle(.white)
                    } else {
                        MarkdownText(message.content)
                    }
                }
                .padding(.horizontal, GoldenTheme.spacing.medium)
                .padding(.vertical, GoldenTheme.spacing.small + 4)
                .background(
                    RoundedRectangle(cornerRadius: GoldenGeometry.cornerLarge, style: .continuous)
                        .fill(message.isFromUser ? theme.accent : theme.backgroundTertiary)
                )
                .contextMenu {
                    Button {
                        #if os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(message.content, forType: .string)
                        #else
                        UIPasteboard.general.string = message.content
                        #endif
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }

                    ShareLink(item: message.content) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }

                Text(formatTime(message.timestamp))
                    .font(.golden(.micro))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.horizontal, GoldenTheme.spacing.small)
            }

            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator

/// Shows when AI is generating a response
public struct TypingIndicator: View {
    @State private var phase = 0
    @Environment(\.goldenTheme) var theme

    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(theme.textTertiary)
                        .frame(width: 8, height: 8)
                        .offset(y: phase == index ? -4 : 0)
                        .animation(.goldenSpringQuick, value: phase)
                }
            }
            .padding(.horizontal, GoldenTheme.spacing.medium)
            .padding(.vertical, GoldenTheme.spacing.small + 6)
            .background(
                RoundedRectangle(cornerRadius: GoldenGeometry.cornerLarge, style: .continuous)
                    .fill(theme.backgroundTertiary)
            )

            Spacer()
        }
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}

// MARK: - Chat Input Field

/// Input field with send button (Claude-style)
public struct ChatInputField: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void

    @Environment(\.goldenTheme) var theme
    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "Chat with AI",
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSend = onSend
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: GoldenTheme.spacing.small) {
            // Text input
            TextField(placeholder, text: $text)
                .font(.golden(.body))
                .foregroundStyle(theme.text)
                .focused($isFocused)
                .lineLimit(1...5)
                .padding(.horizontal, GoldenTheme.spacing.medium)
                .padding(.vertical, GoldenTheme.spacing.small + 4)

            // Send button
            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HapticManager.shared.play(.medium)
                    onSend()
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? theme.textTertiary
                            : theme.accent
                    )
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.trailing, GoldenTheme.spacing.small)
            .padding(.bottom, GoldenTheme.spacing.micro)
        }
        .background(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerLarge, style: .continuous)
                .fill(theme.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerLarge, style: .continuous)
                .stroke(isFocused ? theme.accent.opacity(0.5) : theme.backgroundSecondary, lineWidth: 1)
        )
    }
}

// MARK: - Complete Chat View

/// Full chat interface component
public struct GoldenChatView<ViewModel: ChatViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let title: String
    let welcomeMessage: String?
    let onClose: (() -> Void)?

    @Environment(\.goldenTheme) var theme

    public init(
        viewModel: ViewModel,
        title: String = "AI Assistant",
        welcomeMessage: String? = "How can I help you today?",
        onClose: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.title = title
        self.welcomeMessage = welcomeMessage
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: GoldenTheme.spacing.medium) {
                        // Welcome message
                        if let welcome = welcomeMessage, viewModel.messages.isEmpty {
                            welcomeView(welcome)
                        }

                        // Messages
                        ForEach(viewModel.messages) { message in
                            ChatMessageBubble(message: message)
                                .id(message.id)
                        }

                        // Typing indicator
                        if viewModel.isLoading {
                            TypingIndicator()
                        }
                    }
                    .padding(GoldenTheme.spacing.medium)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input
            ChatInputField(
                text: $viewModel.inputText,
                placeholder: "Ask about this app...",
                onSend: viewModel.sendMessage
            )
            .padding(GoldenTheme.spacing.medium)
        }
        .background(theme.background)
    }

    private var header: some View {
        HStack {
            if let onClose = onClose {
                Button(action: {
                    HapticManager.shared.play(.light)
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 32, height: 32)
                }
            }

            Spacer()

            Text(title)
                .font(.golden(.headline))
                .foregroundStyle(theme.text)

            Spacer()

            // Balance the close button
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.medium)
    }

    private func welcomeView(_ message: String) -> some View {
        VStack(spacing: GoldenTheme.spacing.medium) {
            // Could show logo here
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(theme.accent)

            Text(message)
                .font(.golden(.headline))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, GoldenTheme.spacing.xxlarge)
    }
}

// MARK: - Sample Chat View Model

/// Example implementation of chat view model
@MainActor
public class SampleChatViewModel: ChatViewModelProtocol {
    @Published public var messages: [ChatMessage] = []
    @Published public var isLoading: Bool = false
    @Published public var inputText: String = ""

    public init() {}

    public func sendMessage() {
        let userMessage = ChatMessage(
            content: inputText,
            isFromUser: true
        )
        messages.append(userMessage)
        inputText = ""

        // Simulate AI response
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            let aiResponse = ChatMessage(
                content: "This is a sample response. In a real implementation, this would connect to an AI backend to provide helpful information about the app.",
                isFromUser: false
            )
            messages.append(aiResponse)
            isLoading = false
        }
    }
}

// MARK: - Chat Sheet Modifier

public extension View {
    /// Present a chat assistant as a sheet
    func goldenChatSheet<ViewModel: ChatViewModelProtocol>(
        isPresented: Binding<Bool>,
        viewModel: ViewModel,
        title: String = "AI Assistant",
        welcomeMessage: String? = "How can I help you?"
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            GoldenChatView(
                viewModel: viewModel,
                title: title,
                welcomeMessage: welcomeMessage,
                onClose: { isPresented.wrappedValue = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
