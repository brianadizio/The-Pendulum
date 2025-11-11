// AchievementSystem.swift
// Real-time achievement and reinforcement system for The Pendulum

import Foundation
import UIKit

// MARK: - Achievement Types

enum AchievementType: String, CaseIterable {
    // Recovery Achievements
    case goodRecovery = "Good Recovery!"
    case amazingRecovery = "Amazing Recovery!"
    case impossibleRecovery = "Impossible Recovery!"
    
    // Balance Achievements
    case steadyHands = "Steady Hands"
    case perfectBalance = "Perfect Balance"
    case zenMaster = "Zen Master"
    
    // Efficiency Achievements  
    case gentleTouch = "Gentle Touch"
    case minimalForce = "Minimal Force"
    case precisionControl = "Precision Control"
    
    // Streak Achievements
    case onFire = "On Fire!"
    case unstoppable = "Unstoppable!"
    case legendary = "Legendary!"
    
    // Learning Achievements
    case quickLearner = "Quick Learner"
    case improvementSpurt = "Improvement Spurt"
    case breakthrough = "Breakthrough!"
    
    var description: String {
        switch self {
        case .goodRecovery:
            return "Recovered from a steep angle!"
        case .amazingRecovery:
            return "Incredible save from near-fall!"
        case .impossibleRecovery:
            return "Physics-defying recovery!"
        case .steadyHands:
            return "Maintained balance for 30 seconds"
        case .perfectBalance:
            return "Perfect vertical balance!"
        case .zenMaster:
            return "Balanced for 2 minutes straight"
        case .gentleTouch:
            return "Used minimal force effectively"
        case .minimalForce:
            return "Achieved balance with tiny pushes"
        case .precisionControl:
            return "Precise timing and control"
        case .onFire:
            return "5 great moves in a row!"
        case .unstoppable:
            return "10 consecutive successes!"
        case .legendary:
            return "25 perfect actions!"
        case .quickLearner:
            return "Rapid improvement detected"
        case .improvementSpurt:
            return "Major skill improvement!"
        case .breakthrough:
            return "Breakthrough performance!"
        }
    }
    
    var icon: String {
        switch self {
        case .goodRecovery, .amazingRecovery, .impossibleRecovery:
            return "arrow.up.circle.fill"
        case .steadyHands, .perfectBalance, .zenMaster:
            return "scale.3d"
        case .gentleTouch, .minimalForce, .precisionControl:
            return "hand.point.up.braille.fill"
        case .onFire, .unstoppable, .legendary:
            return "flame.fill"
        case .quickLearner, .improvementSpurt, .breakthrough:
            return "brain.head.profile"
        }
    }
    
    var color: UIColor {
        switch self {
        case .goodRecovery:
            return .systemGreen
        case .amazingRecovery:
            return .systemOrange
        case .impossibleRecovery:
            return .systemRed
        case .steadyHands, .perfectBalance, .zenMaster:
            return .systemBlue
        case .gentleTouch, .minimalForce, .precisionControl:
            return .systemPurple
        case .onFire, .unstoppable, .legendary:
            return .systemYellow
        case .quickLearner, .improvementSpurt, .breakthrough:
            return .systemTeal
        }
    }
    
    var points: Int {
        switch self {
        case .goodRecovery:
            return 50
        case .amazingRecovery:
            return 100
        case .impossibleRecovery:
            return 200
        case .steadyHands:
            return 75
        case .perfectBalance:
            return 150
        case .zenMaster:
            return 300
        case .gentleTouch:
            return 25
        case .minimalForce:
            return 50
        case .precisionControl:
            return 100
        case .onFire:
            return 100
        case .unstoppable:
            return 250
        case .legendary:
            return 500
        case .quickLearner:
            return 75
        case .improvementSpurt:
            return 150
        case .breakthrough:
            return 300
        }
    }
}

// MARK: - Achievement Data

struct AchievementRecord {
    let type: AchievementType
    let timestamp: Date
    let context: [String: Any] // Additional data like angle, time, etc.
    let level: Int
    
    init(type: AchievementType, level: Int, context: [String: Any] = [:]) {
        self.type = type
        self.timestamp = Date()
        self.level = level
        self.context = context
    }
}

// MARK: - Achievement Manager

class AchievementManager {
    static let shared = AchievementManager()
    
    private var achievements: [AchievementRecord] = []
    private var streakCount = 0
    private var lastBalanceTime: Date?
    private var balanceStartTime: Date?
    private var lastStabilityScore: Double = 0
    private var consecutiveGoodMoves = 0
    
    // Thresholds for achievements - made more challenging
    private let recoveryThresholds = [
        AchievementType.goodRecovery: 1.0,      // 57+ degrees
        AchievementType.amazingRecovery: 1.3,   // 74+ degrees  
        AchievementType.impossibleRecovery: 1.5  // 86+ degrees
    ]
    
    private let balanceTimeThresholds = [
        AchievementType.steadyHands: 60.0,      // 1 minute (increased from 30 seconds)
        AchievementType.zenMaster: 180.0        // 3 minutes (increased from 2 minutes)
    ]
    
    // Add cooldown tracking
    private var lastAchievementTime: Date = Date()
    private let globalAchievementCooldown: TimeInterval = 10.0  // 10 seconds between any achievements
    
    private init() {}
    
    // MARK: - Achievement Tracking
    
    func trackRecovery(fromAngle: Double, toAngle: Double, level: Int) {
        let angleFromVertical = abs(fromAngle - Double.pi)
        let recoveredToAngle = abs(toAngle - Double.pi)
        
        // Only trigger if recovered to within reasonable balance (< 0.3 radians)
        guard recoveredToAngle < 0.3 else { return }
        
        // Check recovery thresholds (highest first)
        if angleFromVertical >= recoveryThresholds[.impossibleRecovery]! {
            triggerAchievement(.impossibleRecovery, level: level, context: [
                "fromAngle": angleFromVertical,
                "toAngle": recoveredToAngle,
                "recoveryMagnitude": angleFromVertical - recoveredToAngle
            ])
        } else if angleFromVertical >= recoveryThresholds[.amazingRecovery]! {
            triggerAchievement(.amazingRecovery, level: level, context: [
                "fromAngle": angleFromVertical,
                "toAngle": recoveredToAngle,
                "recoveryMagnitude": angleFromVertical - recoveredToAngle
            ])
        } else if angleFromVertical >= recoveryThresholds[.goodRecovery]! {
            triggerAchievement(.goodRecovery, level: level, context: [
                "fromAngle": angleFromVertical,
                "toAngle": recoveredToAngle,
                "recoveryMagnitude": angleFromVertical - recoveredToAngle
            ])
        }
    }
    
    func trackBalance(angle: Double, time: Date, level: Int) {
        let angleFromVertical = abs(angle - Double.pi)
        let isBalanced = angleFromVertical < 0.1 // Within ~6 degrees
        
        if isBalanced {
            if balanceStartTime == nil {
                balanceStartTime = time
            }
            
            // Check for perfect balance (< 2 degrees) - only once per balance session
            if angleFromVertical < 0.035 && balanceStartTime != nil {  // ~2 degrees
                let duration = time.timeIntervalSince(balanceStartTime!)
                if duration > 5.0 {  // Only after maintaining balance for 5+ seconds
                    triggerAchievement(.perfectBalance, level: level, context: [
                        "angle": angleFromVertical,
                        "precision": 0.035 - angleFromVertical,
                        "duration": duration
                    ])
                }
            }
            
            // Check balance duration
            if let startTime = balanceStartTime {
                let duration = time.timeIntervalSince(startTime)
                
                if duration >= balanceTimeThresholds[.zenMaster]! {
                    triggerAchievement(.zenMaster, level: level, context: [
                        "duration": duration,
                        "averageAngle": angleFromVertical
                    ])
                } else if duration >= balanceTimeThresholds[.steadyHands]! {
                    triggerAchievement(.steadyHands, level: level, context: [
                        "duration": duration,
                        "averageAngle": angleFromVertical
                    ])
                }
            }
        } else {
            balanceStartTime = nil
        }
        
        lastBalanceTime = time
    }
    
    func trackForceEfficiency(force: Double, improvement: Bool, level: Int) {
        if improvement {
            consecutiveGoodMoves += 1
            
            // Check streak achievements
            if consecutiveGoodMoves == 25 {
                triggerAchievement(.legendary, level: level, context: [
                    "streak": consecutiveGoodMoves
                ])
            } else if consecutiveGoodMoves == 10 {
                triggerAchievement(.unstoppable, level: level, context: [
                    "streak": consecutiveGoodMoves
                ])
            } else if consecutiveGoodMoves == 5 {
                triggerAchievement(.onFire, level: level, context: [
                    "streak": consecutiveGoodMoves
                ])
            }
            
            // Check force efficiency - only for very small forces
            if force < 0.2 {  // Much stricter threshold
                triggerAchievement(.minimalForce, level: level, context: [
                    "force": force,
                    "efficiency": 0.2 - force
                ])
            } else if force < 0.4 {  // Adjusted threshold
                triggerAchievement(.gentleTouch, level: level, context: [
                    "force": force,
                    "efficiency": 0.4 - force
                ])
            }
        } else {
            consecutiveGoodMoves = 0
        }
    }
    
    func trackImprovement(currentScore: Double, level: Int) {
        // Only track meaningful improvements, not small fluctuations
        guard lastStabilityScore > 0 else {
            lastStabilityScore = currentScore
            return
        }
        
        let improvement = currentScore - lastStabilityScore
        
        // Require larger improvements and sustained performance
        if improvement > 20.0 && currentScore > 70.0 {  // Increased thresholds
            triggerAchievement(.breakthrough, level: level, context: [
                "improvement": improvement,
                "previousScore": lastStabilityScore,
                "currentScore": currentScore
            ])
        } else if improvement > 15.0 && currentScore > 50.0 {  // Increased thresholds
            triggerAchievement(.improvementSpurt, level: level, context: [
                "improvement": improvement,
                "previousScore": lastStabilityScore,
                "currentScore": currentScore
            ])
        } else if improvement > 10.0 && currentScore > 30.0 {  // Increased thresholds
            triggerAchievement(.quickLearner, level: level, context: [
                "improvement": improvement,
                "previousScore": lastStabilityScore,
                "currentScore": currentScore
            ])
        }
        
        lastStabilityScore = currentScore
    }
    
    // MARK: - Achievement Management
    
    private func triggerAchievement(_ type: AchievementType, level: Int, context: [String: Any] = [:]) {
        // Global cooldown - prevent any achievement within cooldown period
        guard Date().timeIntervalSince(lastAchievementTime) >= globalAchievementCooldown else { return }
        
        // Prevent duplicate achievements within longer time periods
        let recentAchievements = achievements.filter { 
            $0.type == type && Date().timeIntervalSince($0.timestamp) < 30.0  // Increased from 5 to 30 seconds
        }
        guard recentAchievements.isEmpty else { return }
        
        let achievement = AchievementRecord(type: type, level: level, context: context)
        achievements.append(achievement)
        
        // Update last achievement time
        lastAchievementTime = Date()
        
        // Notify UI to show achievement and add points
        NotificationCenter.default.post(
            name: Notification.Name("AchievementUnlocked"),
            object: nil,
            userInfo: [
                "achievementRecord": achievement,
                "type": type.rawValue,
                "description": type.description,
                "icon": type.icon,
                "color": type.color,
                "points": type.points
            ]
        )
        
        // Also notify to add points to score
        NotificationCenter.default.post(
            name: Notification.Name("AddAchievementPoints"),
            object: nil,
            userInfo: ["points": type.points]
        )
        
        // Track in analytics
        AnalyticsManager.shared.trackAchievement(
            type: type.rawValue,
            level: level,
            context: context
        )
        
        print("🏆 Achievement Unlocked: \(type.rawValue) - \(type.description)")
    }
    
    func getAchievements() -> [AchievementRecord] {
        return achievements
    }
    
    func getTotalPoints() -> Int {
        return achievements.reduce(0) { $0 + $1.type.points }
    }
    
    func getAchievementCount(for type: AchievementType) -> Int {
        return achievements.filter { $0.type == type }.count
    }
    
    func clearAchievements() {
        achievements.removeAll()
        streakCount = 0
        lastBalanceTime = nil
        balanceStartTime = nil
        lastStabilityScore = 0
        consecutiveGoodMoves = 0
    }
}

// MARK: - Analytics Extension

extension AnalyticsManager {
    func trackAchievement(type: String, level: Int, context: [String: Any]) {
        guard isTracking, let sessionId = currentSessionId else { return }
        
        let achievementData: [String: Any] = [
            "sessionId": sessionId.uuidString,
            "achievementType": type,
            "level": level,
            "timestamp": Date(),
            "context": context
        ]
        
        // Store in session metrics
        var currentMetrics = sessionMetrics[sessionId] ?? [:]
        var achievements = currentMetrics["achievements"] as? [[String: Any]] ?? []
        achievements.append(achievementData)
        currentMetrics["achievements"] = achievements
        sessionMetrics[sessionId] = currentMetrics
        
        print("📊 Tracked achievement: \(type) at level \(level)")
    }
}