// ChatService.swift
// The Pendulum 2.0
// Singleton manager for AI chat functionality with Firebase Vertex AI

import Foundation
import Combine
import FirebaseAuth
import FirebaseAI
import FirebaseStorage

class ChatService: ObservableObject {
    static let shared = ChatService()

    // Model name constant for tracking
    private let modelName = "gemini-2.5-flash-lite"

    // MARK: - Published Properties

    @Published private(set) var currentConversation: ChatConversation?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private var model: GenerativeModel?
    private var chat: Chat?
    private var cancellables = Set<AnyCancellable>()

    // UserDefaults keys for persistence
    private enum Keys {
        static let currentConversationId = "chat_current_conversation_id"
        static let conversationCache = "chat_conversation_cache"
    }

    // MARK: - System Prompt

    private let systemPrompt = """
    You are a warm, insightful AI companion within The Pendulum app—a physics-based balance game that doubles as a cognitive assessment tool. Your role is to help users understand their gameplay patterns and what they might reveal about their cognitive style.

    PERSONALITY:
    - Be like a supportive friend who happens to be a neuroscientist
    - Warm and encouraging, but grounded in data
    - Use conversational language, avoid jargon
    - Keep responses concise (2-4 paragraphs max)
    - Be genuinely curious about the user's patterns

    GUIDELINES:
    - Only reference data that's actually provided in the context
    - Never fabricate or assume data that isn't present
    - If data is insufficient, acknowledge it kindly and suggest playing more sessions
    - Relate patterns to real-life applications when appropriate (e.g., "This balance between speed and accuracy might show up in how you approach decisions...")
    - Celebrate strengths while offering growth opportunities
    - Be specific—cite actual numbers from their data

    IMPORTANT:
    - The pendulum is INVERTED (balancing upright, like a pencil on your finger)
    - Stability score = % of time in the balanced "green zone"
    - Directional bias shows left/right push preference (-1 to 1 scale)
    - Reaction time is how quickly they respond to instability
    - Higher Lyapunov exponent = more chaotic/unpredictable control style

    When answering questions, structure your response naturally but include:
    1. A direct answer to their question
    2. Supporting evidence from their data
    3. A relatable real-life connection or actionable insight
    """

    // MARK: - Initialization

    private init() {
        loadCachedConversation()
        initializeModel()
    }

    private func initializeModel() {
        // Initialize Firebase Vertex AI with Gemini 2.5 Flash Lite
        let ai = FirebaseAI.firebaseAI(backend: .vertexAI(location: "us-central1"))
        model = ai.generativeModel(
            modelName: modelName,
            generationConfig: GenerationConfig(
                temperature: 0.7,
                topP: 0.9,
                topK: 40,
                maxOutputTokens: 1024
            ),
            systemInstruction: ModelContent(role: "system", parts: systemPrompt)
        )
    }

    // MARK: - Public API

    /// Start a new conversation
    func startNewConversation(with context: GameplaySummary? = nil) {
        currentConversation = ChatConversation(analyticsContext: context)
        errorMessage = nil

        // Start a new chat session with the model
        chat = model?.startChat()

        saveConversation()
    }

    /// Send a message (either preset question or free-form)
    @MainActor
    func sendMessage(
        _ content: String,
        presetQuestionId: String? = nil,
        context: GameplaySummary
    ) async {
        // Start conversation if needed
        if currentConversation == nil {
            startNewConversation(with: context)
        }

        guard var conversation = currentConversation else { return }

        // Add user message
        let userMessage = ChatMessage(
            role: .user,
            content: content,
            presetQuestionId: presetQuestionId
        )
        conversation.addMessage(userMessage)
        conversation.analyticsContext = context
        currentConversation = conversation
        saveConversation()

        // Show loading state
        isLoading = true
        errorMessage = nil

        do {
            // Build the full prompt with context
            let promptWithContext = buildPromptWithContext(message: content, context: context)

            // Get response from Gemini via Firebase AI
            let geminiResponse = try await sendToGemini(prompt: promptWithContext)

            // Add assistant response with all metadata for fine-tuning
            let assistantMessage = ChatMessage(
                role: .assistant,
                content: geminiResponse.text,
                tokenUsage: geminiResponse.tokenUsage,
                responseLatencyMs: geminiResponse.latencyMs,
                modelName: modelName,
                isFallback: false
            )
            conversation.addMessage(assistantMessage)
            currentConversation = conversation
            saveConversation()

            // Save to Firestore for fine-tuning data collection
            await saveToFirestore(conversation: conversation)

        } catch {
            print("ChatService error: \(error)")
            print("ChatService error type: \(type(of: error))")
            print("ChatService error debug: \(String(describing: error))")
            // Don't show error to user since fallback will provide a response
            // errorMessage = "Failed to get response: \(error.localizedDescription)"

            // Fallback: provide a local response if Firebase AI fails
            let fallbackMessage = ChatMessage(
                role: .assistant,
                content: generateFallbackResponse(for: content, context: context),
                isFallback: true
            )
            conversation.addMessage(fallbackMessage)
            currentConversation = conversation
            saveConversation()

            // Still save fallback responses to Firebase Storage for analysis
            await saveToFirestore(conversation: conversation)
        }

        isLoading = false
    }

    /// Send a preset question
    @MainActor
    func sendPresetQuestion(_ question: PresetQuestion, context: GameplaySummary) async {
        await sendMessage(question.promptText, presetQuestionId: question.id, context: context)
    }

    /// Clear current conversation
    func clearConversation() {
        currentConversation = nil
        chat = nil
        UserDefaults.standard.removeObject(forKey: Keys.currentConversationId)
        UserDefaults.standard.removeObject(forKey: Keys.conversationCache)

        // Start fresh chat session
        chat = model?.startChat()
    }

    /// Get available preset questions based on current data state
    func getAvailableQuestions() -> [PresetQuestion] {
        let hasHealth = GameplaySummaryBuilder.hasHealthData
        let hasMaze = GameplaySummaryBuilder.hasMazeData
        return PresetQuestionsCatalog.availableQuestions(hasHealthData: hasHealth, hasMazeData: hasMaze)
    }

    /// Get Tier 1 questions (always available)
    var tier1Questions: [PresetQuestion] {
        PresetQuestionsCatalog.tier1Questions
    }

    /// Get available Tier 2 questions
    var availableTier2Questions: [PresetQuestion] {
        let hasHealth = GameplaySummaryBuilder.hasHealthData
        let hasMaze = GameplaySummaryBuilder.hasMazeData
        return PresetQuestionsCatalog.tier2Questions.filter {
            $0.isAvailable(hasHealthData: hasHealth, hasMazeData: hasMaze)
        }
    }

    /// Get current conversation stats for debugging/monitoring
    var conversationStats: ConversationStats? {
        guard let conversation = currentConversation else { return nil }

        let aiMessages = conversation.messages.filter { $0.role == .assistant }
        let totalTokens = aiMessages.compactMap { $0.tokenUsage?.totalTokens }.reduce(0, +)
        let avgLatency = aiMessages.compactMap { $0.responseLatencyMs }.reduce(0, +) / max(aiMessages.count, 1)
        let fallbackCount = aiMessages.filter { $0.isFallback == true }.count

        return ConversationStats(
            messageCount: conversation.messages.count,
            aiResponseCount: aiMessages.count,
            totalTokensUsed: totalTokens,
            averageLatencyMs: avgLatency,
            fallbackResponseCount: fallbackCount,
            modelName: modelName
        )
    }

    // MARK: - Firebase Vertex AI Call

    private func buildPromptWithContext(message: String, context: GameplaySummary) -> String {
        let contextString = context.toContextString()

        return """
        USER'S GAMEPLAY DATA:
        \(contextString)

        USER'S QUESTION:
        \(message)
        """
    }

    /// Response with metadata for fine-tuning data collection
    struct GeminiResponse {
        let text: String
        let tokenUsage: TokenUsage?
        let latencyMs: Int
    }

    private func sendToGemini(prompt: String) async throws -> GeminiResponse {
        let startTime = Date()

        guard let chat = chat else {
            // If no chat session, create one
            self.chat = model?.startChat()
            guard let newChat = self.chat else {
                throw ChatError.modelNotInitialized
            }
            let response = try await newChat.sendMessage(prompt)
            return buildGeminiResponse(from: response, startTime: startTime)
        }

        let response = try await chat.sendMessage(prompt)
        return buildGeminiResponse(from: response, startTime: startTime)
    }

    private func buildGeminiResponse(from response: GenerateContentResponse, startTime: Date) -> GeminiResponse {
        let latencyMs = Int(Date().timeIntervalSince(startTime) * 1000)

        // Extract token usage from response metadata
        var tokenUsage: TokenUsage? = nil
        if let usageMetadata = response.usageMetadata {
            tokenUsage = TokenUsage(
                promptTokens: Int(usageMetadata.promptTokenCount),
                completionTokens: Int(usageMetadata.candidatesTokenCount),
                totalTokens: Int(usageMetadata.totalTokenCount)
            )
        }

        let text = response.text ?? "I couldn't generate a response. Please try again."

        return GeminiResponse(text: text, tokenUsage: tokenUsage, latencyMs: latencyMs)
    }

    // MARK: - Fallback Response (Local)

    /// Generate a local response when Firebase AI is unavailable
    private func generateFallbackResponse(for message: String, context: GameplaySummary) -> String {
        var insights: [String] = []

        // Stability insight
        if context.stabilityScore > 70 {
            insights.append("Your stability score of \(String(format: "%.0f%%", context.stabilityScore)) shows excellent balance control. You're demonstrating strong spatial awareness and fine motor coordination.")
        } else if context.stabilityScore > 40 {
            insights.append("Your stability score of \(String(format: "%.0f%%", context.stabilityScore)) suggests you're developing good balance intuition. Focus on anticipating the pendulum's movement rather than reacting to it.")
        } else {
            insights.append("Building balance skills takes time. Your current stability score of \(String(format: "%.0f%%", context.stabilityScore)) will improve with practice. Try making smaller, more frequent adjustments.")
        }

        // Directional bias insight
        if abs(context.directionalBias) > 0.2 {
            let direction = context.directionalBias > 0 ? "right" : "left"
            insights.append("I notice you tend to push \(direction) more often. This might reflect your dominant hand preference or a subconscious pattern. Try consciously balancing your directional inputs.")
        } else {
            insights.append("Your directional control is well-balanced, showing adaptability in your responses.")
        }

        // Reaction time insight
        if context.averageReactionTime > 0 {
            if context.averageReactionTime < 0.3 {
                insights.append("Your reaction time of \(String(format: "%.2fs", context.averageReactionTime)) is impressively quick! This suggests strong reflexes and attentional focus.")
            } else if context.averageReactionTime < 0.5 {
                insights.append("Your reaction time of \(String(format: "%.2fs", context.averageReactionTime)) is in a healthy range, balancing speed with accuracy.")
            } else {
                insights.append("Your measured reaction time suggests you take a more deliberate approach. This can actually lead to better precision in your corrections.")
            }
        }

        // Learning curve insight
        if context.learningCurveSlope > 1 {
            insights.append("Your learning curve shows positive progression—you're getting better with each session!")
        }

        let intro = "Based on your gameplay data, here's what I can see:\n\n"
        let closing = "\n\nKeep playing to discover more about your unique patterns. Each session adds to your personal insights."

        return intro + insights.joined(separator: "\n\n") + closing
    }

    // MARK: - Firebase Storage Persistence (for Fine-Tuning Data)

    private var storageRef: StorageReference {
        Storage.storage().reference()
    }

    /// Save conversation to Firebase Storage for fine-tuning data collection
    private func saveToFirestore(conversation: ChatConversation) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ChatService: No authenticated user, skipping cloud save")
            return
        }

        do {
            // Create a complete fine-tuning export struct
            let exportData = FineTuningExport(
                conversationId: conversation.id.uuidString,
                userId: userId,
                createdAt: conversation.createdAt,
                updatedAt: conversation.updatedAt,
                messages: conversation.messages.map { message in
                    FineTuningMessage(
                        id: message.id.uuidString,
                        role: message.role.rawValue,
                        content: message.content,
                        timestamp: message.timestamp,
                        presetQuestionId: message.presetQuestionId,
                        tokenUsage: message.tokenUsage,
                        responseLatencyMs: message.responseLatencyMs,
                        modelName: message.modelName,
                        isFallback: message.isFallback
                    )
                },
                gameplayContext: conversation.analyticsContext
            )

            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(exportData)

            // Upload to Firebase Storage
            let path = "users/\(userId)/chat_finetuning/\(conversation.id.uuidString).json"
            let fileRef = storageRef.child(path)

            let metadata = StorageMetadata()
            metadata.contentType = "application/json"

            _ = try await fileRef.putDataAsync(jsonData, metadata: metadata)

            print("ChatService: Saved conversation to Firebase Storage at \(path)")

        } catch {
            print("ChatService: Failed to save to Firebase Storage: \(error)")
        }
    }

    // MARK: - Fine-Tuning Export Models

    /// Complete export structure for fine-tuning data
    private struct FineTuningExport: Codable {
        let conversationId: String
        let userId: String
        let createdAt: Date
        let updatedAt: Date
        let messages: [FineTuningMessage]
        let gameplayContext: GameplaySummary?
    }

    /// Message structure optimized for fine-tuning export
    private struct FineTuningMessage: Codable {
        let id: String
        let role: String
        let content: String
        let timestamp: Date
        let presetQuestionId: String?
        let tokenUsage: TokenUsage?
        let responseLatencyMs: Int?
        let modelName: String?
        let isFallback: Bool?
    }

    // MARK: - Local Persistence (UserDefaults)

    private func saveConversation() {
        guard let conversation = currentConversation else { return }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(conversation) {
            UserDefaults.standard.set(data, forKey: Keys.conversationCache)
            UserDefaults.standard.set(conversation.id.uuidString, forKey: Keys.currentConversationId)
        }
    }

    private func loadCachedConversation() {
        guard let data = UserDefaults.standard.data(forKey: Keys.conversationCache) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let conversation = try? decoder.decode(ChatConversation.self, from: data) {
            // Only restore if less than 24 hours old
            if Date().timeIntervalSince(conversation.updatedAt) < 86400 {
                currentConversation = conversation
            } else {
                // Clear stale conversation
                clearConversation()
            }
        }
    }
}

// MARK: - Chat Errors

enum ChatError: LocalizedError {
    case notAuthenticated
    case invalidResponse
    case modelNotInitialized
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to use AI insights"
        case .invalidResponse:
            return "Received invalid response from AI"
        case .modelNotInitialized:
            return "AI model not ready. Please try again."
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
