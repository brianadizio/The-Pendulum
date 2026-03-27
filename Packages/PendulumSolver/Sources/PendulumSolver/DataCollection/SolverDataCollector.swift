import Foundation

/// Collects gameplay data for ML training (MARS-compatible format)
public class SolverDataCollector {

    // MARK: - Types

    /// Single data record matching MARS format
    public struct DataRecord: Codable {
        public var timestamp: Double           // seconds
        public var theta: Double               // degrees (converted from radians)
        public var thetaDot: Double            // degrees/second
        public var joystickDeflection: Double  // -1 to 1
        public var actionSource: String        // "player" or "ai"
        public var playerAction: Double        // raw player input
        public var aiAction: Double            // MPC computed action
        public var crashProbability: Double    // 0-1 likelihood of failure
        public var isCrashTriggered: Bool

        // Extended fields
        public var mpcHorizon: Int
        public var mpcSolveTimeMs: Double
        public var sessionId: String
        public var level: Int
        public var mode: String

        public init(timestamp: Double, theta: Double, thetaDot: Double,
                    joystickDeflection: Double, actionSource: String,
                    playerAction: Double, aiAction: Double,
                    crashProbability: Double, isCrashTriggered: Bool,
                    mpcHorizon: Int, mpcSolveTimeMs: Double,
                    sessionId: String, level: Int, mode: String) {
            self.timestamp = timestamp
            self.theta = theta
            self.thetaDot = thetaDot
            self.joystickDeflection = joystickDeflection
            self.actionSource = actionSource
            self.playerAction = playerAction
            self.aiAction = aiAction
            self.crashProbability = crashProbability
            self.isCrashTriggered = isCrashTriggered
            self.mpcHorizon = mpcHorizon
            self.mpcSolveTimeMs = mpcSolveTimeMs
            self.sessionId = sessionId
            self.level = level
            self.mode = mode
        }
    }

    // MARK: - Properties

    /// Current session ID
    public private(set) var sessionId: UUID

    /// Start time of current session
    private var sessionStartTime: Date

    /// Collected records for current session
    private var records: [DataRecord] = []

    /// Current level
    public var currentLevel: Int = 1

    /// Maximum records to keep in memory
    public var maxRecordsInMemory: Int = 10000

    /// Whether to auto-save when reaching max records
    public var autoSaveEnabled: Bool = true

    /// Directory for auto-saved data
    public var autoSaveDirectory: URL?

    // MARK: - Initialization

    public init() {
        self.sessionId = UUID()
        self.sessionStartTime = Date()

        // Set up auto-save directory
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            autoSaveDirectory = documentsURL.appendingPathComponent("PendulumSolverData", isDirectory: true)
            try? FileManager.default.createDirectory(at: autoSaveDirectory!, withIntermediateDirectories: true)
        }
    }

    // MARK: - Public Methods

    /// Start a new session
    public func startNewSession() {
        sessionId = UUID()
        sessionStartTime = Date()
        records.removeAll()
    }

    /// Record a single data point
    /// - Parameters:
    ///   - state: Current pendulum state
    ///   - control: Control action taken
    ///   - playerInput: Optional player input
    ///   - mode: Current solver mode
    ///   - solveTimeMs: MPC solve time in milliseconds
    public func record(state: HybridPendulumSolver.PendulumState,
                       control: Double,
                       playerInput: Double?,
                       mode: HybridPendulumSolver.Mode,
                       solveTimeMs: Double) {

        let timestamp = Date().timeIntervalSince(sessionStartTime)

        // Convert radians to degrees for MARS compatibility
        let thetaDeg = state.theta * 180.0 / .pi
        let thetaDotDeg = state.thetaDot * 180.0 / .pi

        // Determine action source
        let actionSource: String
        let playerAction: Double
        let aiAction: Double

        if let input = playerInput, abs(input) > 0.01 {
            actionSource = "player"
            playerAction = input
            aiAction = control
        } else {
            actionSource = "ai"
            playerAction = 0
            aiAction = control
        }

        // Compute crash probability (heuristic)
        let angleFromVertical = abs(state.angleFromVertical)
        let crashProb = min(1.0, angleFromVertical / 1.3)  // 1.3 rad ≈ crash threshold
        let isCrash = angleFromVertical > 1.3

        let record = DataRecord(
            timestamp: timestamp,
            theta: thetaDeg,
            thetaDot: thetaDotDeg,
            joystickDeflection: playerInput ?? control,
            actionSource: actionSource,
            playerAction: playerAction,
            aiAction: aiAction,
            crashProbability: crashProb,
            isCrashTriggered: isCrash,
            mpcHorizon: 30,  // Default
            mpcSolveTimeMs: solveTimeMs,
            sessionId: sessionId.uuidString,
            level: currentLevel,
            mode: mode.rawValue
        )

        records.append(record)

        // Auto-save if needed
        if autoSaveEnabled && records.count >= maxRecordsInMemory {
            autoSave()
        }
    }

    /// Export all records to a file
    /// - Parameter url: File URL to export to
    public func export(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(records)
        try data.write(to: url)

        print("Exported \(records.count) records to \(url.path)")
    }

    /// Export to CSV format (MARS-compatible)
    /// - Parameter url: File URL to export to
    public func exportCSV(to url: URL) throws {
        var csv = "timestamp,theta,thetaDot,joystickDeflection,actionSource,playerAction,aiAction,crashProbability,isCrashTriggered,sessionId,level,mode\n"

        for record in records {
            csv += "\(record.timestamp),\(record.theta),\(record.thetaDot),\(record.joystickDeflection),"
            csv += "\(record.actionSource),\(record.playerAction),\(record.aiAction),"
            csv += "\(record.crashProbability),\(record.isCrashTriggered),"
            csv += "\(record.sessionId),\(record.level),\(record.mode)\n"
        }

        try csv.write(to: url, atomically: true, encoding: .utf8)

        print("Exported \(records.count) records to CSV: \(url.path)")
    }

    /// Get record count
    public var recordCount: Int {
        return records.count
    }

    /// Clear all records
    public func clearRecords() {
        records.removeAll()
    }

    // MARK: - Private Methods

    private func autoSave() {
        guard let directory = autoSaveDirectory else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())

        let filename = "session_\(sessionId.uuidString.prefix(8))_\(timestamp).json"
        let url = directory.appendingPathComponent(filename)

        do {
            try export(to: url)
            print("Auto-saved \(records.count) records")

            // Keep recent records, remove old ones
            let keepCount = maxRecordsInMemory / 10
            if records.count > keepCount {
                records = Array(records.suffix(keepCount))
            }
        } catch {
            print("Auto-save failed: \(error)")
        }
    }
}
