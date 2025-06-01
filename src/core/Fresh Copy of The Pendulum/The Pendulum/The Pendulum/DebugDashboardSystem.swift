import Foundation

/// System for debugging dashboard metrics and generating proper test data
class DebugDashboardSystem {
    
    static let shared = DebugDashboardSystem()
    
    private init() {}
    
    // MARK: - Debug Analysis
    
    /// Analyze current state of analytics and report issues
    func analyzeCurrentMetrics() -> String {
        var report = "=== Dashboard Metrics Debug Report ===\n\n"
        
        // Check if any sessions exist
        let allSessions = AnalyticsManager.shared.getAllSessions()
        report += "Total Sessions: \(allSessions.count)\n"
        
        if let currentSession = AnalyticsManager.shared.currentSessionId {
            report += "Current Session: \(currentSession)\n"
        } else {
            report += "Current Session: None (THIS IS A PROBLEM)\n"
        }
        
        // Check data buffers
        report += "\n--- Data Buffers ---\n"
        report += checkDataBuffers()
        
        // Check each metric type
        report += "\n--- Metric Values ---\n"
        for group in MetricGroupType.allCases {
            report += "\n[\(group.displayName)]\n"
            let metrics = AnalyticsManager.shared.calculateMetrics(for: group)
            
            for metric in metrics {
                let value = formatMetricValue(metric)
                let status = value.contains("0.00") || value.contains("0%") || value == "Unknown" ? "❌" : "✅"
                report += "\(status) \(metric.type.rawValue): \(value)\n"
            }
        }
        
        return report
    }
    
    private func checkDataBuffers() -> String {
        var report = ""
        
        // Use reflection or known properties to check buffer sizes
        let manager = AnalyticsManager.shared
        
        // We need to add debug methods to AnalyticsManager to expose buffer sizes
        // For now, try to infer from calculated metrics
        
        let stabilityScore = manager.calculateStabilityScore()
        if stabilityScore == 0 {
            report += "❌ Angle buffer is likely empty (Stability Score = 0)\n"
        } else {
            report += "✅ Angle buffer has data (Stability Score = \(stabilityScore))\n"
        }
        
        let efficiency = manager.calculateEfficiencyRating()
        if efficiency == 0 {
            report += "❌ Force history is likely empty (Efficiency = 0)\n"
        } else {
            report += "✅ Force history has data (Efficiency = \(efficiency))\n"
        }
        
        return report
    }
    
    private func formatMetricValue(_ metric: MetricValue) -> String {
        switch metric.value {
        case let value as Double:
            return String(format: "%.2f", value) + (metric.type.unit.isEmpty ? "" : " \(metric.type.unit)")
        case let value as Int:
            return "\(value)" + (metric.type.unit.isEmpty ? "" : " \(metric.type.unit)")
        case let value as String:
            return value
        case let values as [Double]:
            return "[\(values.count) values]"
        case let timeSeries as [(Date, Double)]:
            return "[\(timeSeries.count) time points]"
        default:
            return "Unknown"
        }
    }
    
    // MARK: - Test Data Generation
    
    /// Generate comprehensive test data for all metrics
    func generateComprehensiveTestData() {
        print("🔧 Generating comprehensive test data...")
        
        // 1. Start a new session
        let sessionId = UUID()
        AnalyticsManager.shared.startTracking(for: sessionId)
        
        // Set current level for proper tracking
        AnalyticsManager.shared.setCurrentLevel(1)
        
        // 2. Generate angle and velocity data (pendulum motion)
        generatePendulumMotionData(duration: 300) // 5 minutes
        
        // 3. Generate interaction data (pushes)
        generateInteractionData(pushCount: 150)
        
        // 4. Generate phase space data
        generatePhaseSpaceData(points: 500)
        
        // 5. Generate level completion data
        generateLevelCompletionData(levels: 10)
        
        // 6. Generate failure data
        generateFailureData(failures: 5)
        
        // 7. Generate historical session data
        generateHistoricalSessions()
        
        // 8. Stop tracking to save metrics
        AnalyticsManager.shared.stopTracking()
        
        print("✅ Test data generation complete!")
        
        // Print debug info
        let debugInfo = AnalyticsManager.shared.getDebugInfo()
        print("📊 Buffer status after generation:")
        for (buffer, count) in debugInfo {
            print("  \(buffer): \(count) items")
        }
    }
    
    private func generatePendulumMotionData(duration: TimeInterval) {
        let sampleRate = 30.0 // 30 Hz
        let samples = Int(duration * sampleRate)
        
        for i in 0..<samples {
            let t = Double(i) / sampleRate
            
            // Simulate damped oscillation with occasional perturbations
            let baseAngle = 0.2 * sin(2.0 * t) * exp(-0.01 * t)
            let noise = Double.random(in: -0.02...0.02)
            let angle = baseAngle + noise
            
            let velocity = 0.4 * cos(2.0 * t) * exp(-0.01 * t) + Double.random(in: -0.05...0.05)
            
            // Track the state
            AnalyticsManager.shared.trackPendulumState(angle: angle, angleVelocity: velocity)
            
            // Also track phase space point
            AnalyticsManager.shared.trackPhaseSpacePoint(theta: angle, omega: velocity)
        }
    }
    
    private func generateInteractionData(pushCount: Int) {
        for i in 0..<pushCount {
            let force = Double.random(in: 0.5...2.0)
            let direction = Bool.random() ? "left" : "right"
            let angle = Double.random(in: -0.3...0.3)
            
            AnalyticsManager.shared.trackInteraction(
                eventType: "push",
                force: force,
                direction: direction,
                angle: angle,
                velocity: Double.random(in: -0.5...0.5),
                timestamp: Date().addingTimeInterval(Double(i) * 2.0)
            )
        }
    }
    
    private func generatePhaseSpaceData(points: Int) {
        for i in 0..<points {
            let t = Double(i) * 0.1
            let theta = 0.3 * sin(t) * exp(-t * 0.01)
            let omega = 0.6 * cos(t) * exp(-t * 0.01)
            
            AnalyticsManager.shared.trackPhaseSpacePoint(theta: theta, omega: omega)
        }
    }
    
    private func generateLevelCompletionData(levels: Int) {
        for level in 1...levels {
            let completionTime = Double.random(in: 20...60)
            let score = Int.random(in: 1000...5000) * level
            
            AnalyticsManager.shared.trackLevelCompletion(
                level: level,
                completionTime: completionTime,
                score: score,
                perturbationType: "impulse"
            )
        }
    }
    
    private func generateFailureData(failures: Int) {
        let failureModes = ["left_fall", "right_fall", "oscillation_divergence", "timeout"]
        
        for _ in 0..<failures {
            let mode = failureModes.randomElement() ?? "unknown"
            let angle = mode.contains("left") ? -1.57 : (mode.contains("right") ? 1.57 : 0.0)
            let velocity = Double.random(in: -2.0...2.0)
            
            AnalyticsManager.shared.trackFailure(
                reason: mode,
                finalAngle: angle,
                finalVelocity: velocity,
                level: Int.random(in: 1...10)
            )
        }
    }
    
    // MARK: - Quick Fix Methods
    
    /// Quick fix to ensure dashboard shows data
    func quickFixDashboard() {
        // Generate minimal data to make dashboard show values
        generateComprehensiveTestData()
        
        // Force a dashboard refresh
        NotificationCenter.default.post(name: Notification.Name("RefreshDashboard"), object: nil)
    }
    
    /// Generate historical session data
    private func generateHistoricalSessions() {
        // Generate 5 historical sessions
        for i in 1...5 {
            let sessionId = UUID()
            AnalyticsManager.shared.startTracking(for: sessionId)
            
            // Generate data for each session
            generatePendulumMotionData(duration: 60 * Double(i))
            generateInteractionData(pushCount: 20 * i)
            
            // Complete the session with metrics
            AnalyticsManager.shared.completeSession(
                stabilityScore: 70.0 + Double(i * 5),
                level: i
            )
            
            AnalyticsManager.shared.stopTracking()
        }
    }
    
    /// Generate data for specific metric type
    func generateDataForMetric(_ metricType: MetricType) {
        switch metricType {
        case .stabilityScore, .angularDeviation:
            generatePendulumMotionData(duration: 60)
            
        case .efficiencyRating, .forceDistribution, .pushMagnitudeDistribution:
            generateInteractionData(pushCount: 50)
            
        case .averageCorrectionTime, .responseDelay, .reactionTimeAnalysis:
            // Generate timed interactions
            for i in 0..<30 {
                let reactionTime = Double.random(in: 0.2...0.8)
                AnalyticsManager.shared.trackReactionTime(reactionTime)
            }
            
        case .phaseTrajectory, .phaseSpaceCoverage:
            generatePhaseSpaceData(points: 200)
            
        case .levelCompletionsOverTime:
            generateLevelCompletionData(levels: 5)
            
        default:
            // Generate general data
            generatePendulumMotionData(duration: 30)
            generateInteractionData(pushCount: 20)
        }
    }
}