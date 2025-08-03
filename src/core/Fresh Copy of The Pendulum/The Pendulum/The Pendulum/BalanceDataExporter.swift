import Foundation
import UIKit
import CoreGraphics

// MARK: - Balance Data Export System

/// Comprehensive export system for pendulum balance data
/// Creates personalized "balance signatures" for AI grounding
class BalanceDataExporter {
    
    // MARK: - Data Structures
    
    struct BalanceSnapshot {
        let timestamp: TimeInterval
        let angle: Double
        let angleVelocity: Double
        let angleAcceleration: Double
        let pushDirection: PushDirection
        let pushMagnitude: Double
        let energyState: Double
        let phaseSpacePosition: CGPoint
    }
    
    struct ExportPackage {
        let csvData: Data
        let analysisText: String
        let aiPrompts: [String]
        let visualizationImage: UIImage?
        let metadata: ExportMetadata
    }
    
    struct ExportMetadata: Codable {
        let userId: String
        let sessionId: String
        let exportDate: Date
        let duration: TimeInterval
        let samplingRate: Int
        let levelReached: Int
        let successRate: Double
        let averageBalanceTime: Double
        let personalityProfile: BalancePersonality
    }
    
    struct BalancePersonality: Codable {
        let aggressiveness: Double  // 0-1: How strong are corrections
        let anticipation: Double    // 0-1: How early corrections are made
        let rhythmicity: Double     // 0-1: How regular the pattern is
        let precision: Double       // 0-1: How accurate corrections are
        let adaptability: Double    // 0-1: How quickly strategy changes
    }
    
    // MARK: - Properties
    
    private var sessionData: [BalanceSnapshot] = []
    private let analyticsManager = AnalyticsManager.shared
    private let metricsCalculator = MetricsCalculator()
    private let samplingRate = 60 // Hz
    private(set) var isRecording = false
    private var sessionStartTime: Date?
    
    // Memory management
    private let maxSnapshots = 36000 // 10 minutes at 60Hz
    private let memoryWarningThreshold = 30000 // Start warning at ~8 minutes
    private var memoryWarningShown = false
    
    // MARK: - Recording
    
    func startRecording() {
        sessionData.removeAll()
        sessionStartTime = Date()
        isRecording = true
        print("📊 BalanceDataExporter: Recording started at \(sessionStartTime!)")
    }
    
    func stopRecording() {
        isRecording = false
        print("📊 BalanceDataExporter: Recording stopped. Total snapshots: \(sessionData.count)")
    }
    
    func recordSnapshot(state: PendulumState, action: PushDirection = .none, magnitude: Double = 0) {
        guard isRecording else { 
            print("📊 BalanceDataExporter: Snapshot ignored - not recording")
            return 
        }
        
        // Memory management - circular buffer behavior
        if sessionData.count >= maxSnapshots {
            // Remove oldest 10% when at capacity
            let removeCount = maxSnapshots / 10
            sessionData.removeFirst(removeCount)
            print("BalanceDataExporter: Removed \(removeCount) old snapshots to manage memory")
        }
        
        // Show memory warning once
        if sessionData.count > memoryWarningThreshold && !memoryWarningShown {
            memoryWarningShown = true
            NotificationCenter.default.post(
                name: Notification.Name("BalanceDataMemoryWarning"),
                object: nil,
                userInfo: ["count": sessionData.count]
            )
        }
        
        let snapshot = BalanceSnapshot(
            timestamp: state.time,
            angle: state.theta,
            angleVelocity: state.thetaDot,
            angleAcceleration: calculateAcceleration(state: state),
            pushDirection: action,
            pushMagnitude: magnitude,
            energyState: calculateEnergy(state: state),
            phaseSpacePosition: CGPoint(x: state.theta, y: state.thetaDot)
        )
        
        sessionData.append(snapshot)
    }
    
    // MARK: - Export Functions
    
    func exportComprehensiveData(userId: String, levelReached: Int) -> ExportPackage? {
        print("📊 BalanceDataExporter: Export requested. Session data count: \(sessionData.count)")
        guard !sessionData.isEmpty else { 
            print("📊 BalanceDataExporter: No data to export - session data is empty")
            return nil 
        }
        
        // Generate CSV data
        let csvData = generateCSV()
        
        // Analyze balance patterns
        let personality = analyzeBalancePersonality()
        
        // Generate visualizations
        let visualization = generatePhaseSpaceVisualization()
        
        // Include dashboard metrics in analysis
        let dashboardMetrics = gatherDashboardMetrics()
        
        // Create analysis text with dashboard metrics
        let analysisText = generateAnalysisText(personality: personality, dashboardMetrics: dashboardMetrics)
        
        // Generate AI prompts
        let aiPrompts = generateAIPrompts(personality: personality)
        
        // Create metadata
        let metadata = ExportMetadata(
            userId: userId,
            sessionId: UUID().uuidString,
            exportDate: Date(),
            duration: sessionData.last?.timestamp ?? 0,
            samplingRate: samplingRate,
            levelReached: levelReached,
            successRate: calculateSuccessRate(),
            averageBalanceTime: calculateAverageBalanceTime(),
            personalityProfile: personality
        )
        
        return ExportPackage(
            csvData: csvData,
            analysisText: analysisText,
            aiPrompts: aiPrompts,
            visualizationImage: visualization,
            metadata: metadata
        )
    }
    
    // MARK: - CSV Generation
    
    private func generateCSV() -> Data {
        var csvString = "timestamp,angle,velocity,acceleration,push_direction,push_magnitude,energy,phase_x,phase_y\n"
        
        for snapshot in sessionData {
            let pushDir = snapshot.pushDirection == .left ? "-1" : 
                         snapshot.pushDirection == .right ? "1" : "0"
            
            csvString += String(format: "%.3f,%.6f,%.6f,%.6f,%@,%.3f,%.6f,%.6f,%.6f\n",
                snapshot.timestamp,
                snapshot.angle,
                snapshot.angleVelocity,
                snapshot.angleAcceleration,
                pushDir,
                snapshot.pushMagnitude,
                snapshot.energyState,
                snapshot.phaseSpacePosition.x,
                snapshot.phaseSpacePosition.y
            )
        }
        
        return csvString.data(using: .utf8) ?? Data()
    }
    
    // MARK: - Analysis Functions
    
    private func analyzeBalancePersonality() -> BalancePersonality {
        // Analyze push patterns
        let pushEvents = sessionData.filter { $0.pushDirection != .none }
        
        // Calculate aggressiveness (average push magnitude normalized)
        let avgPushMagnitude = pushEvents.isEmpty ? 1.0 : 
            pushEvents.map { $0.pushMagnitude }.reduce(0, +) / Double(pushEvents.count)
        let aggressiveness = min(avgPushMagnitude / 2.0, 1.0) // Normalize by typical push strength
        
        // Calculate anticipation (how early pushes occur relative to angle)
        let anticipation = calculateAnticipation(pushEvents: pushEvents)
        
        // Calculate rhythmicity (regularity of push intervals)
        let rhythmicity = calculateRhythmicity(pushEvents: pushEvents)
        
        // Calculate precision (how well-timed pushes are)
        let precision = calculatePrecision()
        
        // Calculate adaptability (strategy changes)
        let adaptability = calculateAdaptability(pushEvents: pushEvents)
        
        print("📊 Balance Personality Analysis:")
        print("   Push events: \(pushEvents.count)")
        print("   Aggressiveness: \(aggressiveness) (avg magnitude: \(avgPushMagnitude))")
        print("   Anticipation: \(anticipation)")
        print("   Rhythmicity: \(rhythmicity)")
        print("   Precision: \(precision)")
        print("   Adaptability: \(adaptability)")
        
        return BalancePersonality(
            aggressiveness: aggressiveness,
            anticipation: anticipation,
            rhythmicity: rhythmicity,
            precision: precision,
            adaptability: adaptability
        )
    }
    
    private func calculateAnticipation(pushEvents: [BalanceSnapshot]) -> Double {
        guard !pushEvents.isEmpty else { return 0.5 }
        
        var anticipationScores: [Double] = []
        
        for push in pushEvents {
            // Check if push happens before the pendulum reaches extreme angle
            // Higher anticipation = pushing when angle deviation is smaller
            let deviationFromVertical = abs(push.angle - Double.pi)
            let maxDeviation = Double.pi // Maximum possible deviation
            
            // Score is higher when deviation is lower (anticipating the fall)
            let angleScore = 1.0 - min(deviationFromVertical / maxDeviation, 1.0)
            anticipationScores.append(angleScore)
        }
        
        return anticipationScores.reduce(0, +) / Double(anticipationScores.count)
    }
    
    private func calculateRhythmicity(pushEvents: [BalanceSnapshot]) -> Double {
        guard pushEvents.count > 2 else { return 0.5 }
        
        var intervals: [Double] = []
        for i in 1..<pushEvents.count {
            intervals.append(pushEvents[i].timestamp - pushEvents[i-1].timestamp)
        }
        
        // Calculate coefficient of variation
        let mean = intervals.reduce(0, +) / Double(intervals.count)
        let variance = intervals.map { pow($0 - mean, 2) }.reduce(0, +) / Double(intervals.count)
        let stdDev = sqrt(variance)
        let cv = stdDev / mean
        
        // Lower CV = higher rhythmicity
        return max(0, min(1, 1.0 - cv))
    }
    
    private func calculatePrecision() -> Double {
        // Precision based on how long balance is maintained
        let balancedSnapshots = sessionData.filter { abs($0.angle) < 0.35 }
        return Double(balancedSnapshots.count) / Double(sessionData.count)
    }
    
    private func calculateAdaptability(pushEvents: [BalanceSnapshot]) -> Double {
        guard pushEvents.count > 5 else { return 0.5 }
        
        // Look for changes in push patterns
        var patternChanges = 0
        var lastPattern: (Double, Double) = (0, 0) // (interval, magnitude)
        
        for i in 1..<pushEvents.count {
            let interval = pushEvents[i].timestamp - pushEvents[i-1].timestamp
            let magnitude = pushEvents[i].pushMagnitude
            
            if abs(interval - lastPattern.0) > 0.1 || abs(magnitude - lastPattern.1) > 0.3 {
                patternChanges += 1
            }
            
            lastPattern = (interval, magnitude)
        }
        
        return min(Double(patternChanges) / Double(pushEvents.count - 1), 1.0)
    }
    
    // MARK: - Visualization
    
    private func generatePhaseSpaceVisualization() -> UIImage? {
        print("📊 Generating phase space visualization with \(sessionData.count) data points")
        
        let size = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Background - use white for better visibility
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw axes
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: size.width/2, y: 0))
        context.addLine(to: CGPoint(x: size.width/2, y: size.height))
        context.move(to: CGPoint(x: 0, y: size.height/2))
        context.addLine(to: CGPoint(x: size.width, y: size.height/2))
        context.strokePath()
        
        // Add axis labels
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                     NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        "Angle".draw(in: CGRect(x: size.width - 50, y: size.height/2 + 5, width: 40, height: 20), withAttributes: attrs)
        "Velocity".draw(in: CGRect(x: size.width/2 + 5, y: 5, width: 60, height: 20), withAttributes: attrs)
        
        // Plot phase space trajectory
        context.setStrokeColor(FocusCalendarTheme.accentGold.cgColor)
        context.setLineWidth(1.5)
        
        // Center the plot around the pendulum's operating range
        // Pendulum angles typically range from 0 to 2π
        let angleRange = sessionData.map { $0.angle }
        let velocityRange = sessionData.map { $0.angleVelocity }
        
        let minAngle = angleRange.min() ?? 0
        let maxAngle = angleRange.max() ?? 2 * Double.pi
        let angleSpan = max(maxAngle - minAngle, 0.5)
        let angleMid = (minAngle + maxAngle) / 2
        
        let minVel = velocityRange.min() ?? -1
        let maxVel = velocityRange.max() ?? 1
        let velSpan = max(maxVel - minVel, 1.0)
        let velMid = (minVel + maxVel) / 2
        
        // Scale to fit in view with margins
        let scaleX: CGFloat = (size.width * 0.8) / CGFloat(angleSpan)
        let scaleY: CGFloat = (size.height * 0.8) / CGFloat(velSpan)
        let center = CGPoint(x: size.width/2, y: size.height/2)
        
        print("📊 Phase space - Angle range: \(minAngle) to \(maxAngle), Velocity range: \(minVel) to \(maxVel)")
        print("📊 Scales - X: \(scaleX), Y: \(scaleY), Centers: angle=\(angleMid), vel=\(velMid)")
        
        // Draw the trajectory
        var firstPoint = true
        for (index, snapshot) in sessionData.enumerated() {
            let x = center.x + CGFloat(snapshot.angle - angleMid) * scaleX
            let y = center.y - CGFloat(snapshot.angleVelocity - velMid) * scaleY
            
            if firstPoint {
                context.move(to: CGPoint(x: x, y: y))
                firstPoint = false
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        // Stroke the path before drawing push markers
        context.strokePath()
        
        // Now draw push event markers on top
        for (index, snapshot) in sessionData.enumerated() {
            if snapshot.pushDirection != .none {
                let x = center.x + CGFloat(snapshot.angle - angleMid) * scaleX
                let y = center.y - CGFloat(snapshot.angleVelocity - velMid) * scaleY
                
                context.setFillColor(UIColor.systemRed.cgColor)
                context.fillEllipse(in: CGRect(x: x-4, y: y-4, width: 8, height: 8))
            }
        }
        
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Text Generation
    
    private func gatherDashboardMetrics() -> [String: Double] {
        // Gather all the scientific metrics from MetricsCalculator
        var metrics: [String: Double] = [:]
        
        // Convert our session data to analytics format for metrics calculation
        let angleHistory = sessionData.map { $0.angle }
        let velocityHistory = sessionData.map { $0.angleVelocity }
        let timeHistory = sessionData.map { $0.timestamp }
        
        // Calculate metrics directly from the data
        if !angleHistory.isEmpty {
            metrics["phaseSpaceCoverage"] = calculatePhaseSpaceCoverageFromData(angleHistory, velocityHistory) * 100
            metrics["energyManagement"] = calculateEnergyEfficiencyFromData() * 100
            metrics["lyapunovExponent"] = calculateLyapunovFromData(angleHistory, timeHistory)
            metrics["stabilityScore"] = calculateStabilityFromData(angleHistory)
            metrics["controlEffort"] = calculateControlEffortFromData()
            metrics["forceTimingAccuracy"] = calculateTimingAccuracyFromData() * 100
        }
        
        return metrics
    }
    
    // Helper methods for metric calculations
    private func calculatePhaseSpaceCoverageFromData(_ angles: [Double], _ velocities: [Double]) -> Double {
        guard !angles.isEmpty else { return 0 }
        
        // Calculate area covered in phase space
        let angleRange = (angles.max() ?? 0) - (angles.min() ?? 0)
        let velocityRange = (velocities.max() ?? 0) - (velocities.min() ?? 0)
        let totalArea = 2 * Double.pi * 4.0 // Maximum expected range
        let coveredArea = angleRange * velocityRange
        
        return min(coveredArea / totalArea, 1.0)
    }
    
    private func calculateEnergyEfficiencyFromData() -> Double {
        let pushEvents = sessionData.filter { $0.pushDirection != .none }
        let totalPushEnergy = pushEvents.map { $0.pushMagnitude }.reduce(0, +)
        let averageEnergy = sessionData.map { $0.energyState }.reduce(0, +) / Double(max(sessionData.count, 1))
        
        guard totalPushEnergy > 0 else { return 0 }
        return min(averageEnergy / (totalPushEnergy * 10), 1.0)
    }
    
    private func calculateLyapunovFromData(_ angles: [Double], _ times: [Double]) -> Double {
        guard angles.count > 10 else { return 0 }
        
        // Simplified Lyapunov exponent calculation
        var sum = 0.0
        for i in 1..<angles.count {
            let dt = times[i] - times[i-1]
            guard dt > 0 else { continue }
            let divergence = abs(angles[i] - angles[i-1]) / dt
            sum += log(max(divergence, 0.001))
        }
        
        return sum / Double(angles.count - 1)
    }
    
    private func calculateStabilityFromData(_ angles: [Double]) -> Double {
        guard !angles.isEmpty else { return 0 }
        
        // Calculate variance from vertical position
        let deviations = angles.map { abs($0 - Double.pi) }
        let avgDeviation = deviations.reduce(0, +) / Double(deviations.count)
        
        // Convert to stability score (lower deviation = higher stability)
        return max(0, 10 * (1 - avgDeviation / Double.pi))
    }
    
    private func calculateControlEffortFromData() -> Double {
        let pushEvents = sessionData.filter { $0.pushDirection != .none }
        let totalTime = sessionData.last?.timestamp ?? 1.0
        
        // Control effort = pushes per second * average magnitude
        let pushRate = Double(pushEvents.count) / totalTime
        let avgMagnitude = pushEvents.isEmpty ? 0 : pushEvents.map { $0.pushMagnitude }.reduce(0, +) / Double(pushEvents.count)
        
        return pushRate * avgMagnitude
    }
    
    private func calculateTimingAccuracyFromData() -> Double {
        let pushEvents = sessionData.filter { $0.pushDirection != .none }
        guard !pushEvents.isEmpty else { return 0 }
        
        var goodTimingCount = 0
        for push in pushEvents {
            // Good timing = push when angle and velocity have opposite signs (returning to center)
            if (push.angle > Double.pi && push.angleVelocity < 0 && push.pushDirection == .left) ||
               (push.angle < Double.pi && push.angleVelocity > 0 && push.pushDirection == .right) {
                goodTimingCount += 1
            }
        }
        
        return Double(goodTimingCount) / Double(pushEvents.count)
    }
    
    private func generateAnalysisText(personality: BalancePersonality, dashboardMetrics: [String: Double]) -> String {
        var analysis = """
        PENDULUM BALANCE ANALYSIS REPORT
        ================================
        
        Session Duration: \(String(format: "%.1f", sessionData.last?.timestamp ?? 0)) seconds
        Total Samples: \(sessionData.count)
        Balance Success Rate: \(String(format: "%.1f%%", calculateSuccessRate() * 100))
        
        BALANCE PERSONALITY PROFILE
        --------------------------
        """
        
        // Interpret personality traits
        if personality.aggressiveness > 0.7 {
            analysis += "\n• AGGRESSIVE CONTROLLER: You use strong, decisive corrections"
        } else if personality.aggressiveness < 0.3 {
            analysis += "\n• GENTLE CONTROLLER: You prefer subtle, minimal corrections"
        } else {
            analysis += "\n• MODERATE CONTROLLER: You balance force and finesse"
        }
        
        if personality.anticipation > 0.7 {
            analysis += "\n• ANTICIPATORY: You correct problems before they fully develop"
        } else if personality.anticipation < 0.3 {
            analysis += "\n• REACTIVE: You respond to balance issues as they occur"
        }
        
        if personality.rhythmicity > 0.7 {
            analysis += "\n• RHYTHMIC: Your corrections follow a consistent pattern"
        } else if personality.rhythmicity < 0.3 {
            analysis += "\n• ADAPTIVE: Your timing varies based on conditions"
        }
        
        if personality.precision > 0.7 {
            analysis += "\n• PRECISE: Excellent balance maintenance"
        } else if personality.precision < 0.3 {
            analysis += "\n• DEVELOPING: Room for improvement in balance control"
        }
        
        analysis += """
        
        
        METRICS SUMMARY
        --------------
        Average Angle Deviation: \(String(format: "%.3f", calculateAverageAngle())) rad
        Average Velocity: \(String(format: "%.3f", calculateAverageVelocity())) rad/s
        Push Frequency: \(String(format: "%.1f", calculatePushFrequency())) Hz
        Energy Efficiency: \(String(format: "%.1f%%", calculateEnergyEfficiency() * 100))
        
        SCIENTIFIC METRICS (from Dashboard)
        ----------------------------------
        Phase Space Coverage: \(String(format: "%.1f%%", dashboardMetrics["phaseSpaceCoverage"] ?? 0))
        Energy Management: \(String(format: "%.1f%%", dashboardMetrics["energyManagement"] ?? 0))
        Lyapunov Exponent: \(String(format: "%.3f", dashboardMetrics["lyapunovExponent"] ?? 0))
        Stability Score: \(String(format: "%.1f", dashboardMetrics["stabilityScore"] ?? 0))
        Control Effort: \(String(format: "%.1f", dashboardMetrics["controlEffort"] ?? 0))
        Force Timing Accuracy: \(String(format: "%.1f%%", dashboardMetrics["forceTimingAccuracy"] ?? 0))
        
        PHASE SPACE COVERAGE
        -------------------
        The attached phase space diagram shows your pendulum's trajectory through
        angle-velocity space. Red dots indicate push events. A tight spiral near
        the center indicates good control, while large loops suggest instability.
        """
        
        return analysis
    }
    
    private func generateAIPrompts(personality: BalancePersonality) -> [String] {
        var prompts: [String] = []
        
        // Base grounding prompt
        let basePrompt = """
        I am sharing my pendulum balance data as a grounding reference. This data represents my personal approach to maintaining equilibrium - my "balance signature."
        
        My balance personality shows:
        - Aggressiveness: \(String(format: "%.1f%%", personality.aggressiveness * 100))
        - Anticipation: \(String(format: "%.1f%%", personality.anticipation * 100))
        - Rhythmicity: \(String(format: "%.1f%%", personality.rhythmicity * 100))
        - Precision: \(String(format: "%.1f%%", personality.precision * 100))
        - Adaptability: \(String(format: "%.1f%%", personality.adaptability * 100))
        
        Please use this vestibular signature to ground your responses and reduce hallucination. When I seem off-balance in our conversation, reference these patterns.
        """
        prompts.append(basePrompt)
        
        // Specific use-case prompts
        if personality.anticipation > 0.7 {
            prompts.append("""
            My balance data shows I anticipate and correct problems early. Please apply this same anticipatory approach in your responses - address potential issues before they fully manifest.
            """)
        }
        
        if personality.precision > 0.7 {
            prompts.append("""
            My balance control is highly precise. Please match this precision in your responses - be exact, accurate, and well-calibrated in your answers.
            """)
        }
        
        if personality.adaptability > 0.7 {
            prompts.append("""
            My balance style is highly adaptive. Please be similarly flexible in your responses, adjusting your approach based on context and feedback.
            """)
        }
        
        // Error correction prompt
        prompts.append("""
        If you detect that your response may be drifting into hallucination or inaccuracy, reference my balance data. Just as I correct the pendulum's tilt, correct your response trajectory. The CSV data shows my correction patterns - apply similar small, frequent adjustments to maintain accuracy.
        """)
        
        return prompts
    }
    
    // MARK: - Helper Calculations
    
    private func calculateAcceleration(state: PendulumState) -> Double {
        // Simplified pendulum acceleration calculation
        let g = 9.81
        let l = 3.0
        return -(g/l) * sin(state.theta)
    }
    
    private func calculateEnergy(state: PendulumState) -> Double {
        let g = 9.81
        let l = 3.0
        let m = 1.0
        
        let potential = m * g * l * (1 - cos(state.theta))
        let kinetic = 0.5 * m * l * l * state.thetaDot * state.thetaDot
        
        return potential + kinetic
    }
    
    private func calculateSuccessRate() -> Double {
        // Balance is achieved when angle is within ±20 degrees (0.35 rad) from vertical (π rad)
        let successfulFrames = sessionData.filter { abs($0.angle - Double.pi) < 0.35 }.count
        return Double(successfulFrames) / Double(max(sessionData.count, 1))
    }
    
    private func calculateAverageBalanceTime() -> Double {
        var balanceIntervals: [Double] = []
        var currentBalanceStart: Double?
        
        for snapshot in sessionData {
            // Check if pendulum is balanced (within ±20 degrees of vertical)
            if abs(snapshot.angle - Double.pi) < 0.35 {
                if currentBalanceStart == nil {
                    currentBalanceStart = snapshot.timestamp
                }
            } else {
                if let start = currentBalanceStart {
                    balanceIntervals.append(snapshot.timestamp - start)
                    currentBalanceStart = nil
                }
            }
        }
        
        return balanceIntervals.isEmpty ? 0 : 
               balanceIntervals.reduce(0, +) / Double(balanceIntervals.count)
    }
    
    private func calculateAverageAngle() -> Double {
        // Calculate average deviation from vertical (π radians)
        let deviations = sessionData.map { abs($0.angle - Double.pi) }
        return deviations.reduce(0, +) / Double(max(deviations.count, 1))
    }
    
    private func calculateAverageVelocity() -> Double {
        let velocities = sessionData.map { abs($0.angleVelocity) }
        return velocities.reduce(0, +) / Double(max(velocities.count, 1))
    }
    
    private func calculatePushFrequency() -> Double {
        let pushCount = sessionData.filter { $0.pushDirection != .none }.count
        let duration = sessionData.last?.timestamp ?? 1.0
        return Double(pushCount) / duration
    }
    
    private func calculateEnergyEfficiency() -> Double {
        // Efficiency = time balanced / total energy expended
        let balanceTime = calculateSuccessRate() * (sessionData.last?.timestamp ?? 1.0)
        let totalPushEnergy = sessionData
            .filter { $0.pushDirection != .none }
            .map { $0.pushMagnitude }
            .reduce(0, +)
        
        return totalPushEnergy > 0 ? balanceTime / totalPushEnergy : 0
    }
    
    // MARK: - File Export
    
    func saveExportPackage(_ package: ExportPackage, completion: @escaping (URL?) -> Void) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask).first!
        let exportFolder = documentsPath.appendingPathComponent("PendulumExports")
        
        do {
            // Create export directory
            try FileManager.default.createDirectory(at: exportFolder, 
                                                  withIntermediateDirectories: true)
            
            let sessionFolder = exportFolder.appendingPathComponent(package.metadata.sessionId)
            try FileManager.default.createDirectory(at: sessionFolder, 
                                                  withIntermediateDirectories: true)
            
            // Save CSV
            let csvURL = sessionFolder.appendingPathComponent("balance_data.csv")
            try package.csvData.write(to: csvURL)
            
            // Save analysis
            let analysisURL = sessionFolder.appendingPathComponent("analysis.txt")
            try package.analysisText.write(to: analysisURL, atomically: true, encoding: .utf8)
            
            // Save prompts
            let promptsText = package.aiPrompts.joined(separator: "\n\n---\n\n")
            let promptsURL = sessionFolder.appendingPathComponent("ai_prompts.txt")
            try promptsText.write(to: promptsURL, atomically: true, encoding: .utf8)
            
            // Save visualization
            if let image = package.visualizationImage,
               let imageData = image.pngData() {
                let imageURL = sessionFolder.appendingPathComponent("phase_space.png")
                try imageData.write(to: imageURL)
            }
            
            // Save metadata
            let metadata = try JSONEncoder().encode(package.metadata)
            let metadataURL = sessionFolder.appendingPathComponent("metadata.json")
            try metadata.write(to: metadataURL)
            
            print("📁 Export saved successfully!")
            print("📁 Location: \(sessionFolder.path)")
            print("📁 To open in Finder, run in Terminal:")
            print("   open \"\(sessionFolder.path)\"")
            
            completion(sessionFolder)
            
        } catch {
            print("Export failed: \(error)")
            completion(nil)
        }
    }
}

