// CSVSessionManager.swift
// The Pendulum 2.0
// CSV-based data storage for gameplay sessions

import Foundation
import Combine

// MARK: - Level Config Snapshot (Codable mirror of LevelConfig)
struct LevelConfigSnapshot: Codable {
    let level: Int
    let balanceThreshold: Double
    let balanceRequiredTime: Double
    let initialPerturbation: Double
    let massMultiplier: Double
    let lengthMultiplier: Double
    let dampingValue: Double
    let gravityMultiplier: Double
    let springConstantValue: Double
    let countdownTime: TimeInterval?
    let jiggleIntensity: Double

    init(from config: LevelConfig) {
        self.level = config.number
        self.balanceThreshold = config.balanceThreshold
        self.balanceRequiredTime = config.balanceRequiredTime
        self.initialPerturbation = config.initialPerturbation
        self.massMultiplier = config.massMultiplier
        self.lengthMultiplier = config.lengthMultiplier
        self.dampingValue = config.dampingValue
        self.gravityMultiplier = config.gravityMultiplier
        self.springConstantValue = config.springConstantValue
        self.countdownTime = config.countdownTime
        self.jiggleIntensity = config.jiggleIntensity
    }
}

// MARK: - Session Metadata
struct SessionMetadata: Codable {
    let sessionId: String
    let startTime: Date
    var endTime: Date?
    var totalDuration: TimeInterval
    var levelsCompleted: [Int]
    var maxLevel: Int
    var totalPushes: Int
    var averageBalanceTime: Double
    var gameMode: String
    var totalForceApplied: Double
    var maxScore: Int
    var levelConfigs: [LevelConfigSnapshot]

    // AI fields (optional for backward compatibility)
    var aiMode: String?
    var aiDifficulty: Double?
    var aiControlCalls: Int?
    var aiInterventions: Int?
}

// MARK: - CSV Session Manager
class CSVSessionManager: ObservableObject {
    // Current session info
    @Published private(set) var currentSessionId: String?
    @Published private(set) var isRecording: Bool = false

    // File handles
    private var csvFileHandle: FileHandle?
    private(set) var csvFilePath: URL?
    private(set) var metadataFilePath: URL?

    // Session tracking (public getters for HealthKit integration)
    private(set) var sessionStartTime: Date?
    private var currentLevel: Int = 1

    /// Current session duration in seconds
    var sessionDuration: TimeInterval {
        guard let startTime = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    private var metadata: SessionMetadata?
    private var pushCount: Int = 0
    private var levelsCompleted: [Int] = []
    private var totalForceApplied: Double = 0.0
    private var currentScore: Int = 0
    private var maxScore: Int = 0
    private var lastInstabilityTime: Double = -1.0
    private var currentBalanceThreshold: Double = 0.35  // Default ~20 degrees
    private var levelConfigSnapshots: [LevelConfigSnapshot] = []

    // Documents directory
    private var sessionsDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let sessionsPath = documentsPath.appendingPathComponent("Sessions", isDirectory: true)

        // Create directory if needed
        if !FileManager.default.fileExists(atPath: sessionsPath.path) {
            try? FileManager.default.createDirectory(at: sessionsPath, withIntermediateDirectories: true)
        }

        return sessionsPath
    }

    // MARK: - Session Management

    /// Start a new recording session
    func startSession(mode: GameMode) {
        // End any existing session
        if isRecording {
            endSession()
        }

        // Generate session ID
        let sessionId = UUID().uuidString
        currentSessionId = sessionId
        sessionStartTime = Date()
        pushCount = 0
        levelsCompleted = []
        currentLevel = 1
        totalForceApplied = 0.0
        currentScore = 0
        maxScore = 0
        lastInstabilityTime = -1.0
        levelConfigSnapshots = []

        // Create CSV file
        csvFilePath = sessionsDirectory.appendingPathComponent("session_\(sessionId).csv")
        metadataFilePath = sessionsDirectory.appendingPathComponent("session_\(sessionId)_meta.json")

        // Write CSV header (expanded schema with AI columns)
        let header = "timestamp,angle,angleVelocity,pushDirection,pushMagnitude,isBalanced,level,energy,gameMode,score,balanceThreshold,reactionTime,aiMode,aiForce\n"

        do {
            try header.write(to: csvFilePath!, atomically: true, encoding: .utf8)
            csvFileHandle = try FileHandle(forWritingTo: csvFilePath!)
            csvFileHandle?.seekToEndOfFile()
        } catch {
            print("Error creating CSV file: \(error)")
            return
        }

        // Initialize metadata
        metadata = SessionMetadata(
            sessionId: sessionId,
            startTime: sessionStartTime!,
            endTime: nil,
            totalDuration: 0,
            levelsCompleted: [],
            maxLevel: 1,
            totalPushes: 0,
            averageBalanceTime: 0,
            gameMode: mode.rawValue,
            totalForceApplied: 0,
            maxScore: 0,
            levelConfigs: []
        )

        isRecording = true
        print("Started session: \(sessionId)")
    }

    /// Record a pendulum state snapshot
    func recordState(angle: Double, angleVelocity: Double, isBalanced: Bool, energy: Double? = nil, score: Int? = nil, aiMode: String = "", aiForce: Double = 0.0) {
        guard isRecording, let handle = csvFileHandle, let startTime = sessionStartTime else { return }

        let timestamp = Date().timeIntervalSince(startTime)
        let energyStr = energy.map { String(format: "%.4f", $0) } ?? ""
        let gameModeStr = metadata?.gameMode ?? "classic"

        // Update score tracking
        if let s = score {
            currentScore = s
            maxScore = max(maxScore, s)
        }

        // Track instability for reaction time calculation
        let deviationFromUpright = abs(angle - .pi)
        if deviationFromUpright > currentBalanceThreshold && lastInstabilityTime < 0 {
            lastInstabilityTime = timestamp
        } else if deviationFromUpright <= currentBalanceThreshold {
            lastInstabilityTime = -1.0  // Reset when stable
        }

        // Format: timestamp,angle,angleVelocity,pushDirection,pushMagnitude,isBalanced,level,energy,gameMode,score,balanceThreshold,reactionTime,aiMode,aiForce
        let row = String(format: "%.3f,%.4f,%.4f,0,0.0,%@,%d,%@,%@,%d,%.4f,,%@,%.4f\n",
                        timestamp,
                        angle,
                        angleVelocity,
                        isBalanced ? "true" : "false",
                        currentLevel,
                        energyStr,
                        gameModeStr,
                        currentScore,
                        currentBalanceThreshold,
                        aiMode,
                        aiForce)

        if let data = row.data(using: .utf8) {
            handle.write(data)
        }
    }

    /// Record a push event
    func recordPush(direction: PushDirection, magnitude: Double, aiMode: String = "", aiForce: Double = 0.0) {
        guard isRecording, let handle = csvFileHandle, let startTime = sessionStartTime else { return }

        let timestamp = Date().timeIntervalSince(startTime)
        pushCount += 1
        totalForceApplied += magnitude

        // Calculate reaction time (time since last instability)
        let reactionTime = lastInstabilityTime >= 0 ? timestamp - lastInstabilityTime : 0.0
        let gameModeStr = metadata?.gameMode ?? "classic"

        // Format: timestamp,angle,angleVelocity,pushDirection,pushMagnitude,isBalanced,level,energy,gameMode,score,balanceThreshold,reactionTime,aiMode,aiForce
        let row = String(format: "%.3f,0.0,0.0,%d,%.2f,false,%d,,%@,%d,%.4f,%.3f,%@,%.4f\n",
                        timestamp,
                        direction.rawValue,
                        magnitude,
                        currentLevel,
                        gameModeStr,
                        currentScore,
                        currentBalanceThreshold,
                        reactionTime,
                        aiMode,
                        aiForce)

        if let data = row.data(using: .utf8) {
            handle.write(data)
        }
    }

    /// Record a combined state and push event
    func recordInteraction(angle: Double, angleVelocity: Double, pushDirection: PushDirection, pushMagnitude: Double, isBalanced: Bool, energy: Double? = nil, score: Int? = nil, aiMode: String = "", aiForce: Double = 0.0) {
        guard isRecording, let handle = csvFileHandle, let startTime = sessionStartTime else { return }

        let timestamp = Date().timeIntervalSince(startTime)
        let energyStr = energy.map { String(format: "%.4f", $0) } ?? ""
        let gameModeStr = metadata?.gameMode ?? "classic"

        // Update score tracking
        if let s = score {
            currentScore = s
            maxScore = max(maxScore, s)
        }

        if pushDirection != .none {
            pushCount += 1
            totalForceApplied += pushMagnitude
        }

        // Track instability for reaction time calculation
        let deviationFromUpright = abs(angle - .pi)
        var reactionTime: Double = 0.0

        if pushDirection != .none && lastInstabilityTime >= 0 {
            reactionTime = timestamp - lastInstabilityTime
        }

        if deviationFromUpright > currentBalanceThreshold && lastInstabilityTime < 0 {
            lastInstabilityTime = timestamp
        } else if deviationFromUpright <= currentBalanceThreshold {
            lastInstabilityTime = -1.0
        }

        // Format: timestamp,angle,angleVelocity,pushDirection,pushMagnitude,isBalanced,level,energy,gameMode,score,balanceThreshold,reactionTime,aiMode,aiForce
        let row = String(format: "%.3f,%.4f,%.4f,%d,%.2f,%@,%d,%@,%@,%d,%.4f,%.3f,%@,%.4f\n",
                        timestamp,
                        angle,
                        angleVelocity,
                        pushDirection.rawValue,
                        pushMagnitude,
                        isBalanced ? "true" : "false",
                        currentLevel,
                        energyStr,
                        gameModeStr,
                        currentScore,
                        currentBalanceThreshold,
                        reactionTime,
                        aiMode,
                        aiForce)

        if let data = row.data(using: .utf8) {
            handle.write(data)
        }
    }

    /// Update the current level
    func updateLevel(_ level: Int) {
        if level > currentLevel && !levelsCompleted.contains(currentLevel) {
            levelsCompleted.append(currentLevel)
        }
        currentLevel = level
    }

    /// Mark a level as completed
    func levelCompleted(_ level: Int) {
        if !levelsCompleted.contains(level) {
            levelsCompleted.append(level)
        }
    }

    /// Update the current score
    func updateScore(_ score: Int) {
        currentScore = score
        maxScore = max(maxScore, score)
    }

    /// Record the config for a level (call at session start and each level change)
    func recordLevelConfig(_ config: LevelConfig) {
        let snapshot = LevelConfigSnapshot(from: config)
        // Replace if same level already recorded (e.g. restart), otherwise append
        if let idx = levelConfigSnapshots.firstIndex(where: { $0.level == snapshot.level }) {
            levelConfigSnapshots[idx] = snapshot
        } else {
            levelConfigSnapshots.append(snapshot)
        }
    }

    /// Update the balance threshold for current level
    func updateBalanceThreshold(_ threshold: Double) {
        currentBalanceThreshold = threshold
    }

    /// End the current session
    func endSession() {
        guard isRecording, let sessionId = currentSessionId else { return }

        // Close file handle
        csvFileHandle?.closeFile()
        csvFileHandle = nil

        // Capture AI session summary
        let aiSummary = AIManager.shared.sessionSummary

        // Update and save metadata
        if var meta = metadata, let startTime = sessionStartTime {
            meta.endTime = Date()
            meta.totalDuration = Date().timeIntervalSince(startTime)
            meta.levelsCompleted = levelsCompleted
            meta.maxLevel = levelsCompleted.max() ?? currentLevel
            meta.totalPushes = pushCount
            meta.totalForceApplied = totalForceApplied
            meta.maxScore = maxScore
            meta.levelConfigs = levelConfigSnapshots

            // AI metadata
            meta.aiMode = aiSummary.mode
            meta.aiDifficulty = aiSummary.difficulty
            meta.aiControlCalls = aiSummary.controlCalls
            meta.aiInterventions = aiSummary.interventions

            // Save metadata
            if let metaPath = metadataFilePath {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted

                if let data = try? encoder.encode(meta) {
                    try? data.write(to: metaPath)
                }
            }
        }

        isRecording = false
        currentSessionId = nil
        print("Ended session: \(sessionId)")
    }

    // MARK: - Data Retrieval

    /// Get all session files
    func getAllSessions() -> [URL] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: sessionsDirectory, includingPropertiesForKeys: [.creationDateKey]) else {
            return []
        }

        return files.filter { $0.pathExtension == "csv" }
            .sorted { (url1, url2) -> Bool in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }
    }

    /// Get sessions within a time range
    func getSessions(in range: AnalyticsTimeRange) -> [URL] {
        let allSessions = getAllSessions()
        let now = Date()
        let calendar = Calendar.current

        let startDate: Date
        switch range {
        case .session:
            // Return only current session
            if let currentPath = csvFilePath {
                return [currentPath]
            }
            return []

        case .daily:
            startDate = calendar.startOfDay(for: now)

        case .weekly:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        case .monthly:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now

        case .yearly:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now

        case .allTime:
            return allSessions
        }

        return allSessions.filter { url in
            if let creationDate = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) {
                return creationDate >= startDate
            }
            return false
        }
    }

    /// Read CSV data from a session file
    func readSessionData(from url: URL) -> [[String: String]]? {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }

        var lines = content.components(separatedBy: "\n")
        guard lines.count > 1 else { return nil }

        // Parse header
        let header = lines.removeFirst().components(separatedBy: ",")

        // Parse data rows
        var data: [[String: String]] = []
        for line in lines {
            let values = line.components(separatedBy: ",")
            guard values.count == header.count else { continue }

            var row: [String: String] = [:]
            for (index, key) in header.enumerated() {
                row[key.trimmingCharacters(in: .whitespaces)] = values[index].trimmingCharacters(in: .whitespaces)
            }
            data.append(row)
        }

        return data
    }

    /// Get session metadata
    func getMetadata(for sessionUrl: URL) -> SessionMetadata? {
        let metaUrl = sessionUrl.deletingPathExtension().appendingPathExtension("_meta.json")
        let altMetaUrl = URL(fileURLWithPath: sessionUrl.path.replacingOccurrences(of: ".csv", with: "_meta.json"))

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let data = try? Data(contentsOf: metaUrl),
           let metadata = try? decoder.decode(SessionMetadata.self, from: data) {
            return metadata
        }

        if let data = try? Data(contentsOf: altMetaUrl),
           let metadata = try? decoder.decode(SessionMetadata.self, from: data) {
            return metadata
        }

        return nil
    }

    /// Clear all session data
    func clearAllSessions() {
        // End any current session first
        if isRecording {
            endSession()
        }

        let fileManager = FileManager.default

        // Get all files in sessions directory
        guard let files = try? fileManager.contentsOfDirectory(at: sessionsDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        // Delete each file
        for file in files {
            try? fileManager.removeItem(at: file)
        }

        print("Cleared all session data")
    }
}

// MARK: - Analytics Time Range
enum AnalyticsTimeRange: String, CaseIterable, Identifiable {
    case session = "Session"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case allTime = "All Time"

    var id: String { rawValue }
}
