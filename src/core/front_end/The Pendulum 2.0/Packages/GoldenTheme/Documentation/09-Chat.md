# AI Chat Assistant

Golden Theme includes a built-in chat component for providing AI-powered guidance about how to use your Solutions, what the data means, and how to apply them across your life for optimal topological embedding.

---

## Overview

The chat system provides:
- Claude-style chat interface
- Shimmer loading effect
- Typing indicator
- Message bubbles
- Input field with send button
- Sheet presentation

---

## Quick Start

```swift
@State private var showChat = false
@StateObject private var chatVM = SampleChatViewModel()

MyView()
    .goldenChatSheet(
        isPresented: $showChat,
        viewModel: chatVM,
        title: "Maze Assistant",
        welcomeMessage: "How can I help you with The Maze?"
    )
```

---

## Chat View Model

Implement the `ChatViewModelProtocol` for your chat backend:

```swift
public protocol ChatViewModelProtocol: ObservableObject {
    var messages: [ChatMessage] { get }
    var isLoading: Bool { get }
    var inputText: String { get set }

    func sendMessage()
}
```

### Sample Implementation

```swift
@MainActor
class MazeChatViewModel: ChatViewModelProtocol {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var inputText = ""

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            content: inputText,
            isFromUser: true
        )
        messages.append(userMessage)
        inputText = ""

        // Call your AI backend
        isLoading = true
        Task {
            let response = await callAIBackend(userMessage.content)

            let aiMessage = ChatMessage(
                content: response,
                isFromUser: false
            )
            messages.append(aiMessage)
            isLoading = false
        }
    }

    private func callAIBackend(_ message: String) async -> String {
        // Your AI integration here
        // Could be OpenAI, Claude API, local model, etc.
        return "This is a response about The Maze..."
    }
}
```

---

## Chat Message

The message model:

```swift
public struct ChatMessage: Identifiable, Equatable {
    public let id: UUID
    public let content: String
    public let isFromUser: Bool
    public let timestamp: Date
}
```

---

## Full Chat View

For more control, use the full chat view:

```swift
@StateObject private var chatVM = MazeChatViewModel()

GoldenChatView(
    viewModel: chatVM,
    title: "Maze Assistant",
    welcomeMessage: "How can I help you?",
    onClose: { dismiss() }
)
```

---

## Components

### Message Bubble

Individual message display:

```swift
ChatMessageBubble(message: message)
```

**User messages:**
- Right-aligned
- Accent color background
- White text

**AI messages:**
- Left-aligned
- Tertiary background
- Theme text color

Both show timestamp below.

### Typing Indicator

Shows when AI is generating:

```swift
if viewModel.isLoading {
    TypingIndicator()
}
```

Three dots that bounce in sequence.

### Input Field

Claude-style input with send button:

```swift
ChatInputField(
    text: $inputText,
    placeholder: "Ask about this app...",
    onSend: { sendMessage() }
)
```

**Features:**
- Multi-line expansion (1-5 lines)
- Send button (arrow up circle)
- Disabled when empty
- Focus border animation

---

## Sheet Presentation

Present as a sheet with detents:

```swift
.goldenChatSheet(
    isPresented: $showChat,
    viewModel: chatVM,
    title: "Assistant",
    welcomeMessage: "How can I help?"
)
```

**Presentation:**
- Medium and large detents
- Drag indicator visible
- Close button in header

---

## Welcome State

When no messages exist:

```swift
// Shows sparkles icon + welcome message
```

**Appearance:**
- Sparkles icon in accent color
- Welcome text centered
- Generous vertical padding

---

## Integration Points

### Toolbar Button

Add chat button to navigation:

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button(action: { showChat = true }) {
            Image(systemName: "sparkles")
                .foregroundStyle(theme.accent)
        }
    }
}
```

### Floating Button

Or as a floating action button:

```swift
ZStack {
    MainContent()

    VStack {
        Spacer()
        HStack {
            Spacer()
            Button(action: { showChat = true }) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(theme.accent))
                    .shadow(radius: 4)
            }
            .padding()
        }
    }
}
```

---

## AI Backend Options

The chat view model is backend-agnostic. Options include:

1. **OpenAI API** - GPT-4 for general assistance
2. **Claude API** - Anthropic's Claude
3. **Local LLM** - On-device inference
4. **Custom Backend** - Your own API
5. **Pre-scripted** - FAQ-style responses

### Example with OpenAI

```swift
private func callOpenAI(_ message: String) async -> String {
    // Simplified example
    let request = OpenAIRequest(
        model: "gpt-4",
        messages: [
            .system("You are an assistant for The Maze app..."),
            .user(message)
        ]
    )

    let response = try await openAIClient.chat(request)
    return response.choices.first?.message.content ?? "Sorry, I couldn't respond."
}
```

---

## Context-Aware Responses

Make the AI aware of app state:

```swift
func sendMessage() {
    let context = """
    User is on: \(currentTab.rawValue)
    Current mode: \(selectedMode.name)
    Session stats: \(sessionStats.summary)
    """

    let enrichedMessage = """
    Context: \(context)
    User question: \(inputText)
    """

    // Send enrichedMessage to AI backend
}
```

---

## Suggested Topics

Show quick-tap suggestions:

```swift
let suggestions = [
    "How do I play?",
    "What does this metric mean?",
    "How to improve my score?",
    "Connect with other apps"
]

// Display as horizontal scroll of chips
```

---

## Best Practices

1. **Solution-specific context** - Tell the AI about your specific app
2. **Pre-load common questions** - Faster responses for FAQs
3. **Loading indicator** - Always show typing indicator
4. **Error handling** - Gracefully handle API failures
5. **Offline fallback** - Provide basic help without connection
6. **Session memory** - Keep context across the conversation
7. **Privacy** - Be clear about what data is sent to AI
