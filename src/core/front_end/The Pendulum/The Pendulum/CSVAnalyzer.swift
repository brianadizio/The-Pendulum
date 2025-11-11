import Foundation
import UIKit
// import FirebaseStorage // Uncomment when Firebase Storage is added to project
// import FirebaseFirestore // Uncomment when needed

// MARK: - CSV Analyzer for Dashboard Integration

class CSVAnalyzer {
    
    // MARK: - Data Structures
    
    struct DetailedMetrics {
        // Time-based analysis
        let totalDuration: TimeInterval
        let balancedDuration: TimeInterval
        let balancePercentage: Double
        
        // Push analysis
        let totalPushes: Int
        let leftPushes: Int
        let rightPushes: Int
        let pushFrequency: Double
        let averagePushMagnitude: Double
        
        // Stability analysis
        let averageAngle: Double
        let angleStandardDeviation: Double
        let maxAngleDeviation: Double
        let timeToFirstBalance: TimeInterval?
        
        // Advanced metrics
        let pushEfficiency: Double // Pushes per minute balanced
        let recoverySpeed: Double // How fast user recovers from tilts
        let microAdjustmentRatio: Double // Small vs large corrections
        
        // Pattern analysis
        let dominantPushPattern: String // "alternating", "sequential", "reactive"
        let averageResponseTime: TimeInterval
        let pushRhythmicity: Double // How regular the push timing is
    }
    
    struct SegmentAnalysis {
        let startTime: TimeInterval
        let endTime: TimeInterval
        let metrics: DetailedMetrics
        let difficulty: String // "easy", "moderate", "challenging"
    }
    
    // MARK: - CSV Parsing
    
    static func analyzeCSVData(_ csvData: Data) -> DetailedMetrics? {
        guard let csvString = String(data: csvData, encoding: .utf8) else { return nil }
        
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else { return nil } // Need header + data
        
        // Skip header
        let dataLines = lines.dropFirst().filter { !$0.isEmpty }
        
        // Parse data
        var snapshots: [BalanceDataExporter.BalanceSnapshot] = []
        var pushEvents: [(time: TimeInterval, direction: PushDirection, magnitude: Double)] = []
        
        for line in dataLines {
            let components = line.components(separatedBy: ",")
            guard components.count >= 9 else { continue }
            
            guard let timestamp = Double(components[0]),
                  let angle = Double(components[1]),
                  let velocity = Double(components[2]),
                  let acceleration = Double(components[3]),
                  let pushDir = Int(components[4]),
                  let pushMag = Double(components[5]),
                  let energy = Double(components[6]),
                  let phaseX = Double(components[7]),
                  let phaseY = Double(components[8]) else { continue }
            
            let direction: PushDirection = pushDir < 0 ? .left : pushDir > 0 ? .right : .none
            
            let snapshot = BalanceDataExporter.BalanceSnapshot(
                timestamp: timestamp,
                angle: angle,
                angleVelocity: velocity,
                angleAcceleration: acceleration,
                pushDirection: direction,
                pushMagnitude: pushMag,
                energyState: energy,
                phaseSpacePosition: CGPoint(x: phaseX, y: phaseY)
            )
            
            snapshots.append(snapshot)
            
            if direction != .none {
                pushEvents.append((timestamp, direction, pushMag))
            }
        }
        
        return calculateDetailedMetrics(from: snapshots, pushEvents: pushEvents)
    }
    
    // MARK: - Metrics Calculation
    
    private static func calculateDetailedMetrics(
        from snapshots: [BalanceDataExporter.BalanceSnapshot],
        pushEvents: [(time: TimeInterval, direction: PushDirection, magnitude: Double)]
    ) -> DetailedMetrics? {
        
        guard !snapshots.isEmpty else { return nil }
        
        let totalDuration = snapshots.last!.timestamp - snapshots.first!.timestamp
        
        // Balance analysis
        let balancedSnapshots = snapshots.filter { abs($0.angle) < 0.35 } // Same threshold as game
        let balancedDuration = Double(balancedSnapshots.count) / 60.0 // Convert from samples to seconds
        let balancePercentage = (Double(balancedSnapshots.count) / Double(snapshots.count)) * 100
        
        // Push analysis
        let leftPushes = pushEvents.filter { $0.direction == .left }.count
        let rightPushes = pushEvents.filter { $0.direction == .right }.count
        let totalPushes = leftPushes + rightPushes
        let pushFrequency = totalDuration > 0 ? Double(totalPushes) / totalDuration : 0
        
        let averagePushMagnitude = pushEvents.isEmpty ? 0 :
            pushEvents.map { $0.magnitude }.reduce(0, +) / Double(pushEvents.count)
        
        // Stability analysis
        let angles = snapshots.map { abs($0.angle) }
        let averageAngle = angles.reduce(0, +) / Double(angles.count)
        let maxAngleDeviation = angles.max() ?? 0
        
        // Standard deviation
        let variance = angles.map { pow($0 - averageAngle, 2) }.reduce(0, +) / Double(angles.count)
        let angleStandardDeviation = sqrt(variance)
        
        // Time to first balance
        let timeToFirstBalance = snapshots.first(where: { abs($0.angle) < 0.35 })?.timestamp
        
        // Push efficiency (pushes per minute of balanced time)
        let pushEfficiency = balancedDuration > 0 ? Double(totalPushes) / (balancedDuration / 60) : 0
        
        // Recovery speed (average time to return to balance after deviation)
        let recoverySpeed = calculateRecoverySpeed(snapshots: snapshots)
        
        // Micro adjustment ratio
        let microAdjustmentRatio = calculateMicroAdjustmentRatio(pushEvents: pushEvents)
        
        // Pattern analysis
        let dominantPushPattern = analyzePushPattern(pushEvents: pushEvents)
        let averageResponseTime = calculateAverageResponseTime(snapshots: snapshots, pushEvents: pushEvents)
        let pushRhythmicity = calculatePushRhythmicity(pushEvents: pushEvents)
        
        return DetailedMetrics(
            totalDuration: totalDuration,
            balancedDuration: balancedDuration,
            balancePercentage: balancePercentage,
            totalPushes: totalPushes,
            leftPushes: leftPushes,
            rightPushes: rightPushes,
            pushFrequency: pushFrequency,
            averagePushMagnitude: averagePushMagnitude,
            averageAngle: averageAngle,
            angleStandardDeviation: angleStandardDeviation,
            maxAngleDeviation: maxAngleDeviation,
            timeToFirstBalance: timeToFirstBalance,
            pushEfficiency: pushEfficiency,
            recoverySpeed: recoverySpeed,
            microAdjustmentRatio: microAdjustmentRatio,
            dominantPushPattern: dominantPushPattern,
            averageResponseTime: averageResponseTime,
            pushRhythmicity: pushRhythmicity
        )
    }
    
    // MARK: - Advanced Analysis
    
    private static func calculateRecoverySpeed(snapshots: [BalanceDataExporter.BalanceSnapshot]) -> Double {
        var recoveryTimes: [TimeInterval] = []
        var deviationStartTime: TimeInterval?
        
        for (index, snapshot) in snapshots.enumerated() {
            let isBalanced = abs(snapshot.angle) < 0.35
            
            if !isBalanced && deviationStartTime == nil {
                deviationStartTime = snapshot.timestamp
            } else if isBalanced && deviationStartTime != nil {
                let recoveryTime = snapshot.timestamp - deviationStartTime!
                recoveryTimes.append(recoveryTime)
                deviationStartTime = nil
            }
        }
        
        return recoveryTimes.isEmpty ? 0 : recoveryTimes.reduce(0, +) / Double(recoveryTimes.count)
    }
    
    private static func calculateMicroAdjustmentRatio(
        pushEvents: [(time: TimeInterval, direction: PushDirection, magnitude: Double)]
    ) -> Double {
        guard !pushEvents.isEmpty else { return 0 }
        
        let microThreshold = 1.0 // Pushes with magnitude < 1.0 are "micro"
        let microPushes = pushEvents.filter { $0.magnitude < microThreshold }.count
        
        return Double(microPushes) / Double(pushEvents.count)
    }
    
    private static func analyzePushPattern(
        pushEvents: [(time: TimeInterval, direction: PushDirection, magnitude: Double)]
    ) -> String {
        guard pushEvents.count > 5 else { return "insufficient_data" }
        
        // Check for alternating pattern
        var alternations = 0
        for i in 1..<pushEvents.count {
            if pushEvents[i].direction != pushEvents[i-1].direction &&
               pushEvents[i].direction != .none &&
               pushEvents[i-1].direction != .none {
                alternations += 1
            }
        }
        
        let alternationRatio = Double(alternations) / Double(pushEvents.count - 1)
        
        if alternationRatio > 0.7 {
            return "alternating"
        } else if alternationRatio < 0.3 {
            return "sequential"
        } else {
            return "reactive"
        }
    }
    
    private static func calculateAverageResponseTime(
        snapshots: [BalanceDataExporter.BalanceSnapshot],
        pushEvents: [(time: TimeInterval, direction: PushDirection, magnitude: Double)]
    ) -> TimeInterval {
        // Calculate average time between angle deviation and corrective push
        var responseTimes: [TimeInterval] = []
        
        for push in pushEvents {
            // Find the snapshot just before this push
            if let prePushIndex = snapshots.lastIndex(where: { $0.timestamp < push.time }) {
                let prePushAngle = snapshots[prePushIndex].angle
                
                // Look back to find when deviation started
                var deviationStart = prePushIndex
                while deviationStart > 0 && abs(snapshots[deviationStart].angle) > 0.1 {
                    deviationStart -= 1
                }
                
                if deviationStart < prePushIndex {
                    let responseTime = push.time - snapshots[deviationStart + 1].timestamp
                    responseTimes.append(responseTime)
                }
            }
        }
        
        return responseTimes.isEmpty ? 0 : responseTimes.reduce(0, +) / Double(responseTimes.count)
    }
    
    private static func calculatePushRhythmicity(
        pushEvents: [(time: TimeInterval, direction: PushDirection, magnitude: Double)]
    ) -> Double {
        guard pushEvents.count > 2 else { return 0 }
        
        // Calculate intervals between pushes
        var intervals: [TimeInterval] = []
        for i in 1..<pushEvents.count {
            intervals.append(pushEvents[i].time - pushEvents[i-1].time)
        }
        
        // Calculate coefficient of variation
        let meanInterval = intervals.reduce(0, +) / Double(intervals.count)
        guard meanInterval > 0 else { return 0 }
        
        let variance = intervals.map { pow($0 - meanInterval, 2) }.reduce(0, +) / Double(intervals.count)
        let stdDev = sqrt(variance)
        let cv = stdDev / meanInterval
        
        // Lower CV = higher rhythmicity
        return max(0, min(1, 1.0 - cv))
    }
    
    // MARK: - Time Segmentation
    
    static func analyzeInSegments(_ csvData: Data, segmentDuration: TimeInterval = 30.0) -> [SegmentAnalysis] {
        guard let csvString = String(data: csvData, encoding: .utf8) else { return [] }
        
        // Parse full CSV first
        let lines = csvString.components(separatedBy: .newlines)
        let dataLines = lines.dropFirst().filter { !$0.isEmpty }
        
        var allSnapshots: [BalanceDataExporter.BalanceSnapshot] = []
        // ... (parsing code as above)
        
        // Segment the data
        var segments: [SegmentAnalysis] = []
        guard let firstTime = allSnapshots.first?.timestamp,
              let lastTime = allSnapshots.last?.timestamp else { return [] }
        
        var currentStart = firstTime
        while currentStart < lastTime {
            let currentEnd = min(currentStart + segmentDuration, lastTime)
            
            // Get snapshots for this segment
            let segmentSnapshots = allSnapshots.filter {
                $0.timestamp >= currentStart && $0.timestamp < currentEnd
            }
            
            if let metrics = calculateDetailedMetrics(from: segmentSnapshots, pushEvents: []) {
                let difficulty = categorizeSegmentDifficulty(metrics)
                let segment = SegmentAnalysis(
                    startTime: currentStart,
                    endTime: currentEnd,
                    metrics: metrics,
                    difficulty: difficulty
                )
                segments.append(segment)
            }
            
            currentStart = currentEnd
        }
        
        return segments
    }
    
    private static func categorizeSegmentDifficulty(_ metrics: DetailedMetrics) -> String {
        if metrics.balancePercentage > 80 && metrics.pushFrequency < 2 {
            return "easy"
        } else if metrics.balancePercentage < 50 || metrics.pushFrequency > 4 {
            return "challenging"
        } else {
            return "moderate"
        }
    }
}

// MARK: - Firebase Upload Manager

/* Uncomment when Firebase Storage is added to project
class GameplayDataUploader {
    
    static let shared = GameplayDataUploader()
    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    // MARK: - Upload Configuration
    
    struct UploadConfig {
        let includeRawCSV: Bool
        let includeAnalysis: Bool
        let includeVisualization: Bool
        let anonymize: Bool
        let compress: Bool
    }
    
    // MARK: - Upload Methods
    
    func uploadGameplayData(
        package: BalanceDataExporter.ExportPackage,
        config: UploadConfig = UploadConfig(
            includeRawCSV: true,
            includeAnalysis: true,
            includeVisualization: false,
            anonymize: true,
            compress: true
        ),
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        let sessionId = package.metadata.sessionId
        let userId = config.anonymize ? "anonymous_\(UUID().uuidString.prefix(8))" : package.metadata.userId
        
        // Create Firestore document first
        let docRef = firestore.collection("gameplay_sessions").document(sessionId)
        
        var sessionData: [String: Any] = [
            "sessionId": sessionId,
            "userId": userId,
            "timestamp": package.metadata.exportDate,
            "duration": package.metadata.duration,
            "level": package.metadata.levelReached,
            "successRate": package.metadata.successRate,
            "samplingRate": package.metadata.samplingRate,
            "personality": [
                "aggressiveness": package.metadata.personalityProfile.aggressiveness,
                "anticipation": package.metadata.personalityProfile.anticipation,
                "rhythmicity": package.metadata.personalityProfile.rhythmicity,
                "precision": package.metadata.personalityProfile.precision,
                "adaptability": package.metadata.personalityProfile.adaptability
            ]
        ]
        
        // Add detailed metrics if analyzed
        if let detailedMetrics = CSVAnalyzer.analyzeCSVData(package.csvData) {
            sessionData["detailedMetrics"] = [
                "totalPushes": detailedMetrics.totalPushes,
                "pushFrequency": detailedMetrics.pushFrequency,
                "balancePercentage": detailedMetrics.balancePercentage,
                "averageAngle": detailedMetrics.averageAngle,
                "recoverySpeed": detailedMetrics.recoverySpeed,
                "dominantPattern": detailedMetrics.dominantPushPattern
            ]
        }
        
        // Save to Firestore
        docRef.setData(sessionData) { [weak self] error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Upload files to Storage
            self?.uploadFilesToStorage(
                package: package,
                sessionId: sessionId,
                userId: userId,
                config: config,
                completion: completion
            )
        }
    }
    
    private func uploadFilesToStorage(
        package: BalanceDataExporter.ExportPackage,
        sessionId: String,
        userId: String,
        config: UploadConfig,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        let storageRef = storage.reference()
        let sessionRef = storageRef.child("gameplay_data/\(userId)/\(sessionId)")
        
        var uploadTasks: [StorageUploadTask] = []
        
        // Upload CSV (optionally compressed)
        if config.includeRawCSV {
            let csvData = config.compress ? package.csvData.gzipped() ?? package.csvData : package.csvData
            let csvRef = sessionRef.child(config.compress ? "data.csv.gz" : "data.csv")
            let csvTask = csvRef.putData(csvData, metadata: nil)
            uploadTasks.append(csvTask)
        }
        
        // Upload analysis
        if config.includeAnalysis, let analysisData = package.analysisText.data(using: .utf8) {
            let analysisRef = sessionRef.child("analysis.txt")
            let analysisTask = analysisRef.putData(analysisData, metadata: nil)
            uploadTasks.append(analysisTask)
        }
        
        // Upload visualization
        if config.includeVisualization,
           let image = package.visualizationImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageRef = sessionRef.child("phase_space.jpg")
            let imageTask = imageRef.putData(imageData, metadata: nil)
            uploadTasks.append(imageTask)
        }
        
        // Wait for all uploads to complete
        let group = DispatchGroup()
        var uploadErrors: [Error] = []
        
        for task in uploadTasks {
            group.enter()
            task.observe(.success) { _ in
                group.leave()
            }
            task.observe(.failure) { snapshot in
                if let error = snapshot.error {
                    uploadErrors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if uploadErrors.isEmpty {
                completion(.success(sessionId))
            } else {
                completion(.failure(uploadErrors.first!))
            }
        }
    }
    
    // MARK: - Download Methods
    
    func downloadSessionData(sessionId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let sessionRef = firestore.collection("gameplay_sessions").document(sessionId)
        
        sessionRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document,
                  let data = document.data(),
                  let userId = data["userId"] as? String else {
                completion(.failure(NSError(domain: "GameplayUploader", code: 404, userInfo: nil)))
                return
            }
            
            // Download CSV from Storage
            let csvRef = self.storage.reference().child("gameplay_data/\(userId)/\(sessionId)/data.csv")
            csvRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    // Try compressed version
                    let compressedRef = self.storage.reference().child("gameplay_data/\(userId)/\(sessionId)/data.csv.gz")
                    compressedRef.getData(maxSize: 10 * 1024 * 1024) { compressedData, error in
                        if let error = error {
                            completion(.failure(error))
                        } else if let compressedData = compressedData,
                                  let decompressed = compressedData.gunzipped() {
                            completion(.success(decompressed))
                        } else {
                            completion(.failure(NSError(domain: "GameplayUploader", code: 500, userInfo: nil)))
                        }
                    }
                } else if let data = data {
                    completion(.success(data))
                }
            }
        }
    }
}

// MARK: - Dashboard Integration

extension SimpleDashboard {
    
    /// Add a new section for CSV analysis
    func addCSVAnalysisSection() {
        // This would add UI for:
        // 1. Import CSV button
        // 2. Display detailed metrics
        // 3. Show time-segmented analysis
        // 4. Compare with current session
    }
    
    /// Analyze imported CSV and display results
    func displayCSVAnalysis(csvData: Data) {
        guard let metrics = CSVAnalyzer.analyzeCSVData(csvData) else {
            print("Failed to analyze CSV data")
            return
        }
        
        // Update UI with detailed metrics
        DispatchQueue.main.async {
            // Add new cards or update existing ones with:
            // - Push frequency chart
            // - Balance percentage over time
            // - Recovery speed trends
            // - Pattern analysis visualization
        }
    }
}

*/

// MARK: - Data Compression Extensions

// Compression extensions are commented out since they're only used in the Firebase code
// which is also commented out. Uncomment these when Firebase Storage is added.

/*
extension Data {
    func gzipped() -> Data? {
        // Implement compression when needed
        return nil
    }
    
    func gunzipped() -> Data? {
        // Implement decompression when needed  
        return nil
    }
}
*/