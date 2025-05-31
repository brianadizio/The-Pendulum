// AITestingSystemExtensions.swift
// Extensions to generate months of historical gameplay data

import Foundation

extension AITestingSystem {
    
    /// Generate months of historical gameplay data
    static func generateMonthsOfGameplayData(months: Int = 3, completion: @escaping (Bool) -> Void) {
        let tester = AITestingSystem()
        
        print("🚀 Generating \(months) months of gameplay data...")
        
        // Calculate sessions needed
        let daysPerMonth = 30
        let totalDays = months * daysPerMonth
        let sessionsPerDay = 3 // Morning, afternoon, evening
        let totalSessions = totalDays * sessionsPerDay
        
        // Create a custom configuration for historical data
        let historicalConfig = AITestConfiguration(
            skillLevel: .intermediate,
            duration: 600, // 10 minutes per session (realistic play time)
            perturbationModes: ["Primary", "Progressive", "Random Impulses", "Sine Wave"],
            parameterVariations: true,
            numberOfSessions: totalSessions,
            timeBetweenSessions: 0 // No delay for historical generation
        )
        
        // Override dates to create historical data
        var currentDate = Date()
        let calendar = Calendar.current
        
        // Start from X months ago
        if let startDate = calendar.date(byAdding: .month, value: -months, to: currentDate) {
            currentDate = startDate
        }
        
        print("📅 Starting from: \(currentDate)")
        print("📊 Total sessions to generate: \(totalSessions)")
        
        // Generate sessions with progression
        generateHistoricalSessions(
            tester: tester,
            totalSessions: totalSessions,
            startDate: currentDate,
            completion: completion
        )
    }
    
    private static func generateHistoricalSessions(
        tester: AITestingSystem,
        totalSessions: Int,
        startDate: Date,
        completion: @escaping (Bool) -> Void
    ) {
        
        var currentDate = startDate
        let calendar = Calendar.current
        var sessionCount = 0
        
        // Skill progression over time
        let skillProgression: [(sessions: Int, skill: AISkillLevel)] = [
            (0, .beginner),      // First 20% of sessions
            (totalSessions / 5, .intermediate),  // Next 30%
            (totalSessions / 2, .advanced),      // Next 30%
            (totalSessions * 4 / 5, .expert)     // Final 20%
        ]
        
        // Generate sessions day by day
        DispatchQueue.global(qos: .background).async {
            for day in 0..<(totalSessions / 3) {
                // Morning session (7-9 AM)
                let morningHour = Int.random(in: 7...9)
                if let morningDate = calendar.date(bySettingHour: morningHour, 
                                                  minute: Int.random(in: 0...59), 
                                                  second: 0, 
                                                  of: currentDate) {
                    generateSession(
                        tester: tester,
                        date: morningDate,
                        sessionNumber: sessionCount,
                        totalSessions: totalSessions,
                        skillProgression: skillProgression
                    )
                    sessionCount += 1
                }
                
                // Afternoon session (12-2 PM) - 70% chance
                if Double.random(in: 0...1) < 0.7 {
                    let afternoonHour = Int.random(in: 12...14)
                    if let afternoonDate = calendar.date(bySettingHour: afternoonHour,
                                                        minute: Int.random(in: 0...59),
                                                        second: 0,
                                                        of: currentDate) {
                        generateSession(
                            tester: tester,
                            date: afternoonDate,
                            sessionNumber: sessionCount,
                            totalSessions: totalSessions,
                            skillProgression: skillProgression
                        )
                        sessionCount += 1
                    }
                }
                
                // Evening session (6-9 PM) - 80% chance
                if Double.random(in: 0...1) < 0.8 {
                    let eveningHour = Int.random(in: 18...21)
                    if let eveningDate = calendar.date(bySettingHour: eveningHour,
                                                      minute: Int.random(in: 0...59),
                                                      second: 0,
                                                      of: currentDate) {
                        generateSession(
                            tester: tester,
                            date: eveningDate,
                            sessionNumber: sessionCount,
                            totalSessions: totalSessions,
                            skillProgression: skillProgression
                        )
                        sessionCount += 1
                    }
                }
                
                // Move to next day
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                }
                
                // Progress update every week
                if day % 7 == 0 {
                    let progress = Float(sessionCount) / Float(totalSessions) * 100
                    print("📈 Progress: \(String(format: "%.1f", progress))% - Generated \(sessionCount) sessions")
                }
            }
            
            DispatchQueue.main.async {
                print("✅ Historical data generation complete!")
                print("📊 Total sessions generated: \(sessionCount)")
                
                // Update aggregated analytics
                AnalyticsManager.shared.updateAggregatedAnalytics()
                
                completion(true)
            }
        }
    }
    
    private static func generateSession(
        tester: AITestingSystem,
        date: Date,
        sessionNumber: Int,
        totalSessions: Int,
        skillProgression: [(sessions: Int, skill: AISkillLevel)]
    ) {
        // Determine skill level based on progression
        var skillLevel = AISkillLevel.beginner
        for (threshold, skill) in skillProgression.reversed() {
            if sessionNumber >= threshold {
                skillLevel = skill
                break
            }
        }
        
        // Create session with historical date
        let sessionId = UUID()
        
        // Simulate gameplay with appropriate duration
        let duration = TimeInterval.random(in: 300...900) // 5-15 minutes
        let levelsCompleted = Int(duration / 180) + Int.random(in: 0...2) // ~3 min per level + variance
        
        // Generate performance metrics based on skill level
        let baseScore = calculateBaseScore(for: skillLevel)
        let score = baseScore + Int.random(in: -200...500) // Add variance
        
        // Create analytics data
        AnalyticsManager.shared.createHistoricalSession(
            sessionId: sessionId,
            date: date,
            duration: duration,
            score: score,
            levelsCompleted: levelsCompleted,
            skillLevel: skillLevel
        )
        
        // Generate detailed interaction data
        generateDetailedInteractions(
            sessionId: sessionId,
            date: date,
            duration: duration,
            skillLevel: skillLevel
        )
    }
    
    private static func calculateBaseScore(for skillLevel: AISkillLevel) -> Int {
        switch skillLevel {
        case .beginner:
            return 500
        case .intermediate:
            return 1500
        case .advanced:
            return 3000
        case .expert:
            return 5000
        case .perfect:
            return 8000
        }
    }
    
    private static func generateDetailedInteractions(
        sessionId: UUID,
        date: Date,
        duration: TimeInterval,
        skillLevel: AISkillLevel
    ) {
        // Generate push frequency based on skill level
        let pushesPerMinute = getPushFrequency(for: skillLevel)
        let totalPushes = Int(duration / 60 * pushesPerMinute)
        
        // Generate push events throughout the session
        for i in 0..<totalPushes {
            let pushTime = date.addingTimeInterval(Double(i) * 60 / pushesPerMinute)
            let direction = Bool.random() ? "left" : "right"
            let magnitude = Double.random(in: 1.5...2.5)
            
            // Create interaction record
            AnalyticsManager.shared.createHistoricalInteraction(
                sessionId: sessionId,
                timestamp: pushTime,
                eventType: "push",
                direction: direction,
                magnitude: magnitude
            )
        }
        
        // Add level completion events
        let levelsPerSession = Int(duration / 180) // ~3 min per level
        for level in 1...levelsPerSession {
            let levelTime = date.addingTimeInterval(Double(level) * 180)
            AnalyticsManager.shared.createHistoricalInteraction(
                sessionId: sessionId,
                timestamp: levelTime,
                eventType: "level_complete_\(level)",
                direction: "none",
                magnitude: 0
            )
        }
    }
    
    private static func getPushFrequency(for skillLevel: AISkillLevel) -> Double {
        switch skillLevel {
        case .beginner:
            return 8.0  // 8 pushes per minute
        case .intermediate:
            return 6.0  // 6 pushes per minute
        case .advanced:
            return 4.5  // 4.5 pushes per minute
        case .expert:
            return 3.0  // 3 pushes per minute
        case .perfect:
            return 2.0  // 2 pushes per minute
        }
    }
}

// The historical data methods are now implemented in AnalyticsManager.swift