// CSVSessionManager.swift
// The Pendulum 2.0
// CSV-based data storage for gameplay sessions

import Foundation
import Combine

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
}

// MARK: - CSV Session Manager
class CSVSessionManager: ObservableObject {
    // Current session info
    @Published private(set) var currentSessionId: String?
    @Published private(set) var isRecording: Bool = false

    // File handles
    private var csvFileHandle: FileHandle?
    private var csvFilePath: URL?
    private var metadataFilePath: URL?

    // Session tracking
    private var sessionStartTime: Date?
    private var currentLevel: Int = 1
    private var metadata: SessionMetadata?
    private var pushCount: Int = 0
    private var levelsCompleted: [Int] = []

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

        // Create CSV file
        csvFilePath = sessionsDirectory.appendingPathComponent("session_\(sessionId).csv")
        metadataFilePath = sessionsDirectory.appendingPathComponent("session_\(sessionId)_meta.json")

        // Write CSV header
        let header = "timestamp,angle,angleVelocity,pushDirection,pushMagnitude,isBalanced,level,energy\n"

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
            gameMode: mode.rawValue
        )

        isRecording = true
        print("Started session: \(sessionId)")
    }

    /// Record a pendulum state snapshot
    func recordState(angle: Double, angleVelocity: Double, isBalanced: Bool, energy: Double? = nil) {
        guard isRecording, let handle = csvFileHandle, let startTime = sessionStartTime else { return }

        let timestamp = Date().timeIntervalSince(startTime)
        let energyStr = energy.map { String(format: "%.4f", $0) } ?? ""

        let row = String(format: "%.3f,%.4f,%.4f,0,0.0,%@,%d,%@\n",
                        timestamp,
                        angle,
                        angleVelocity,
                        isBalanced ? "true" : "false",
                        currentLevel,
                        energyStr)

        if let data = row.data(using: .utf8) {
            handle.write(data)
        }
    }

    /// Record a push event
    func recordPush(direction: PushDirection, magnitude: Double) {
        guard isRecording, let handle = csvFileHandle, let startTime = sessionStartTime else { return }

        let timestamp = Date().timeIntervalSince(startTime)
        pushCount += 1

        let row = String(format: "%.3f,0.0,0.0,%d,%.2f,false,%d,\n",
                        timestamp,
                        direction.rawValue,
                        magnitude,
                        currentLevel)

        if let data = row.data(using: .utf8) {
            handle.write(data)
        }
    }

    /// Record a combined state and push event
    func recordInteraction(angle: Double, angleVelocity: Double, pushDirection: PushDirection, pushMagnitude: Double, isBalanced: Bool, energy: Double? = nil) {
        guard isRecording, let handle = csvFileHandle, let startTime = sessionStartTime else { return }

        let timestamp = Date().timeIntervalSince(startTime)
        let energyStr = energy.map { String(format: "%.4f", $0) } ?? ""

        if pushDirection != .none {
            pushCount += 1
        }

        let row = String(format: "%.3f,%.4f,%.4f,%d,%.2f,%@,%d,%@\n",
                        timestamp,
                        angle,
                        angleVelocity,
                        pushDirection.rawValue,
                        pushMagnitude,
                        isBalanced ? "true" : "false",
                        currentLevel,
                        energyStr)

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

    /// End the current session
    func endSession() {
        guard isRecording, let sessionId = currentSessionId else { return }

        // Close file handle
        csvFileHandle?.closeFile()
        csvFileHandle = nil

        // Update and save metadata
        if var meta = metadata, let startTime = sessionStartTime {
            meta.endTime = Date()
            meta.totalDuration = Date().timeIntervalSince(startTime)
            meta.levelsCompleted = levelsCompleted
            meta.maxLevel = levelsCompleted.max() ?? currentLevel
            meta.totalPushes = pushCount

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
