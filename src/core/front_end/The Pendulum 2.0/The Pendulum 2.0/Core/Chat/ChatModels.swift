// ChatModels.swift
// The Pendulum 2.0
// Data models for AI chat feature - "Your Play Style, Decoded"

import Foundation

// MARK: - Question Tier

enum QuestionTier: String, Codable {
    case tier1 = "Quick Insights"
    case tier2 = "Deep Analysis"
}

// MARK: - Preset Question

struct PresetQuestion: Identifiable, Codable {
    let id: String
    let tier: QuestionTier
    let displayText: String
    let promptText: String
    let icon: String
    let requiresHealthData: Bool
    let requiresMazeData: Bool

    /// Check if this question is available based on current data availability
    func isAvailable(hasHealthData: Bool, hasMazeData: Bool) -> Bool {
        if requiresHealthData && !hasHealthData { return false }
        if requiresMazeData && !hasMazeData { return false }
        return true
    }
}

// MARK: - Preset Questions Catalog

struct PresetQuestionsCatalog {
    /// Tier 1: Quick Insights - always available
    static let tier1Questions: [PresetQuestion] = [
        PresetQuestion(
            id: "cautious_impulsive",
            tier: .tier1,
            displayText: "Am I cautious or impulsive?",
            promptText: "Based on my gameplay patterns, reaction times, and overcorrection rate, would you say I tend to be more cautious or impulsive when making decisions? What specific behaviors indicate this?",
            icon: "brain.head.profile",
            requiresHealthData: false,
            requiresMazeData: false
        ),
        PresetQuestion(
            id: "repeating_patterns",
            tier: .tier1,
            displayText: "What patterns do I repeat?",
            promptText: "What recurring patterns do you notice in my gameplay? Are there specific habits, tendencies, or strategies I tend to fall back on? How might these patterns reflect my broader approach to challenges?",
            icon: "repeat",
            requiresHealthData: false,
            requiresMazeData: false
        ),
        PresetQuestion(
            id: "focus_changes",
            tier: .tier1,
            displayText: "How has my focus changed?",
            promptText: "Looking at my session data over time, how has my focus and attention changed? Am I improving in sustained concentration? What does my learning curve tell you about my engagement style?",
            icon: "eye",
            requiresHealthData: false,
            requiresMazeData: false
        ),
        PresetQuestion(
            id: "problem_solving",
            tier: .tier1,
            displayText: "What's my problem-solving style?",
            promptText: "Based on my directional bias, reaction patterns, and how I handle increasing difficulty, what can you tell me about my problem-solving style? Am I systematic or intuitive?",
            icon: "lightbulb",
            requiresHealthData: false,
            requiresMazeData: false
        )
    ]

    /// Tier 2: Deep Analysis - some require additional data
    static let tier2Questions: [PresetQuestion] = [
        PresetQuestion(
            id: "maze_comparison",
            tier: .tier2,
            displayText: "Balance vs maze navigation?",
            promptText: "How does my pendulum balance performance compare to my maze navigation patterns? Are there correlations between how I handle balance control and how I navigate spatial challenges?",
            icon: "square.grid.3x3",
            requiresHealthData: false,
            requiresMazeData: true
        ),
        PresetQuestion(
            id: "reaction_correlation",
            tier: .tier2,
            displayText: "How does reaction time evolve?",
            promptText: "How has my reaction time correlated with the number of sessions I've played? Am I getting faster? Are there any patterns in when I perform best or worst?",
            icon: "bolt",
            requiresHealthData: false,
            requiresMazeData: false
        ),
        PresetQuestion(
            id: "sleep_accuracy",
            tier: .tier2,
            displayText: "How does sleep affect accuracy?",
            promptText: "Based on my health data and gameplay sessions, is there a correlation between my sleep patterns and my balance accuracy? Do I perform better on well-rested days?",
            icon: "bed.double.fill",
            requiresHealthData: true,
            requiresMazeData: false
        ),
        PresetQuestion(
            id: "stress_response",
            tier: .tier2,
            displayText: "What's my stress response?",
            promptText: "Looking at my heart rate variability data alongside my gameplay patterns, what can you tell me about how I handle stress? Do I maintain composure under pressure?",
            icon: "heart.text.square",
            requiresHealthData: true,
            requiresMazeData: false
        )
    ]

    /// All questions combined
    static var allQuestions: [PresetQuestion] {
        tier1Questions + tier2Questions
    }

    /// Get available questions based on current data state
    static func availableQuestions(hasHealthData: Bool, hasMazeData: Bool) -> [PresetQuestion] {
        allQuestions.filter { $0.isAvailable(hasHealthData: hasHealthData, hasMazeData: hasMazeData) }
    }
}

// MARK: - Chat Message

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    let presetQuestionId: String?

    // AI response metadata (only for assistant messages)
    var tokenUsage: TokenUsage?
    var responseLatencyMs: Int?
    var modelName: String?
    var isFallback: Bool?

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        presetQuestionId: String? = nil,
        tokenUsage: TokenUsage? = nil,
        responseLatencyMs: Int? = nil,
        modelName: String? = nil,
        isFallback: Bool? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.presetQuestionId = presetQuestionId
        self.tokenUsage = tokenUsage
        self.responseLatencyMs = responseLatencyMs
        self.modelName = modelName
        self.isFallback = isFallback
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}

// MARK: - Token Usage

struct TokenUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    init(promptTokens: Int = 0, completionTokens: Int = 0, totalTokens: Int = 0) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

// MARK: - Chat Conversation

struct ChatConversation: Identifiable, Codable {
    let id: UUID
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var analyticsContext: GameplaySummary?

    init(
        id: UUID = UUID(),
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        analyticsContext: GameplaySummary? = nil
    ) {
        self.id = id
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.analyticsContext = analyticsContext
    }

    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updatedAt = Date()
    }
}

// MARK: - Gameplay Summary (Context for AI)

struct GameplaySummary: Codable {
    // Basic metrics (from CSVMetricsCalculator.basicMetrics)
    let sessionsPlayed: Int
    let totalPlayTime: TimeInterval
    let maxLevel: Int
    let stabilityScore: Double
    let efficiencyRating: Double
    let totalPushes: Int

    // Advanced metrics (from advancedMetrics)
    let directionalBias: Double
    let overcorrectionRate: Double
    let averageReactionTime: Double

    // Scientific metrics (from scientificMetrics)
    let phaseSpaceCoverage: Double
    let lyapunovExponent: Double
    let angularDeviationStdDev: Double
    let energyManagement: Double

    // Topology metrics (from topologyMetrics)
    let windingNumber: Double
    let basinStability: Double
    let periodicOrbitCount: Int

    // Educational metrics (from educationalMetrics)
    let learningCurveSlope: Double
    let skillRetention: Double

    // AI metrics (if available)
    let aiModeUsed: String?
    let aiAssistancePercent: Double?

    // Health data (if HealthKit authorized)
    let healthSteps: Int?
    let healthRestingHR: Double?
    let healthHRV: Double?
    let healthSleepHours: Double?

    // Profile data (from ProfileManager)
    let trainingGoal: String?
    let ageRange: String?
    let dominantHand: String?

    // Cross-app data (if Maze connected)
    let mazeSessions: Int?
    let mazeMotorScore: Double?
    let mazeFlowScore: Double?
    let mazeCognitiveScore: Double?

    // Timestamp for context freshness
    let generatedAt: Date

    /// Format as human-readable text for the AI prompt
    func toContextString() -> String {
        var lines: [String] = []

        lines.append("=== GAMEPLAY SUMMARY ===")
        lines.append("")

        // Basic stats
        lines.append("SESSIONS & TIME:")
        lines.append("• Sessions played: \(sessionsPlayed)")
        lines.append("• Total play time: \(formatDuration(totalPlayTime))")
        lines.append("• Max level reached: \(maxLevel)")
        lines.append("• Total pushes: \(totalPushes)")
        lines.append("")

        // Performance
        lines.append("PERFORMANCE:")
        lines.append("• Stability score: \(String(format: "%.1f%%", stabilityScore))")
        lines.append("• Efficiency rating: \(String(format: "%.1f%%", efficiencyRating))")
        lines.append("• Overcorrection rate: \(String(format: "%.1f%%", overcorrectionRate))")
        lines.append("• Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
        lines.append("")

        // Behavioral patterns
        lines.append("BEHAVIORAL PATTERNS:")
        let biasDescription = directionalBias < -0.1 ? "left-leaning" : (directionalBias > 0.1 ? "right-leaning" : "balanced")
        lines.append("• Directional bias: \(biasDescription) (\(String(format: "%.2f", directionalBias)))")
        lines.append("• Basin stability: \(String(format: "%.1f%%", basinStability))")
        lines.append("")

        // Scientific metrics
        lines.append("SCIENTIFIC ANALYSIS:")
        lines.append("• Phase space coverage: \(String(format: "%.1f%%", phaseSpaceCoverage))")
        lines.append("• Energy management: \(String(format: "%.1f%%", energyManagement))")
        lines.append("• Lyapunov exponent: \(String(format: "%.3f", lyapunovExponent)) (chaos measure)")
        lines.append("• Angular deviation σ: \(String(format: "%.1f°", angularDeviationStdDev))")
        lines.append("• Winding number: \(String(format: "%.1f", windingNumber))")
        lines.append("• Periodic orbits detected: \(periodicOrbitCount)")
        lines.append("")

        // Learning
        lines.append("LEARNING & PROGRESS:")
        lines.append("• Learning curve slope: \(String(format: "%.2f%%", learningCurveSlope)) per session")
        if skillRetention >= 0 {
            lines.append("• Skill retention: \(String(format: "%.1f%%", skillRetention))")
        }
        lines.append("")

        // AI assistance (if used)
        if let aiMode = aiModeUsed, !aiMode.isEmpty {
            lines.append("AI ASSISTANCE:")
            lines.append("• Mode used: \(aiMode)")
            if let assist = aiAssistancePercent {
                lines.append("• Assistance percent: \(String(format: "%.1f%%", assist))")
            }
            lines.append("")
        }

        // Health data (if available)
        if healthSteps != nil || healthRestingHR != nil || healthHRV != nil || healthSleepHours != nil {
            lines.append("HEALTH CONTEXT (today):")
            if let steps = healthSteps {
                lines.append("• Steps: \(steps)")
            }
            if let hr = healthRestingHR {
                lines.append("• Resting heart rate: \(Int(hr)) BPM")
            }
            if let hrv = healthHRV {
                lines.append("• Heart rate variability: \(String(format: "%.0f", hrv)) ms")
            }
            if let sleep = healthSleepHours {
                lines.append("• Sleep last night: \(String(format: "%.1f", sleep)) hours")
            }
            lines.append("")
        }

        // Profile (if available)
        if trainingGoal != nil || ageRange != nil || dominantHand != nil {
            lines.append("USER PROFILE:")
            if let goal = trainingGoal {
                lines.append("• Training goal: \(goal)")
            }
            if let age = ageRange {
                lines.append("• Age range: \(age)")
            }
            if let hand = dominantHand {
                lines.append("• Dominant hand: \(hand)")
            }
            lines.append("")
        }

        // Maze data (if available)
        if let mazeSessions = mazeSessions, mazeSessions > 0 {
            lines.append("CROSS-APP DATA (The Maze):")
            lines.append("• Maze sessions: \(mazeSessions)")
            if let motor = mazeMotorScore {
                lines.append("• Motor score: \(String(format: "%.0f%%", motor * 100))")
            }
            if let flow = mazeFlowScore {
                lines.append("• Flow state score: \(String(format: "%.0f%%", flow * 100))")
            }
            if let cognitive = mazeCognitiveScore {
                lines.append("• Cognitive score: \(String(format: "%.0f%%", cognitive * 100))")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m \(Int(seconds) % 60)s"
        }
    }
}

// MARK: - Chat API Request/Response

struct ChatRequest: Codable {
    let userId: String
    let conversationId: String
    let message: String
    let gameplayContext: GameplaySummary
    let presetQuestionId: String?
}

struct ChatResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let conversationId: String?
}

// MARK: - Conversation Stats (for monitoring fine-tuning data)

struct ConversationStats {
    let messageCount: Int
    let aiResponseCount: Int
    let totalTokensUsed: Int
    let averageLatencyMs: Int
    let fallbackResponseCount: Int
    let modelName: String

    var description: String {
        """
        Messages: \(messageCount) (\(aiResponseCount) AI responses)
        Tokens used: \(totalTokensUsed)
        Avg latency: \(averageLatencyMs)ms
        Fallbacks: \(fallbackResponseCount)
        Model: \(modelName)
        """
    }
}
