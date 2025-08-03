import Foundation
import Singular

// Game-specific tracking wrapper for Singular SDK
class SingularTracker {
    
    // MARK: - Install Tracking
    
    static func trackInstall() {
        // Track install event with app-specific attributes
        let attributes = [
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("app_install", withArgs: attributes)
        print("📱 Install tracked with attributes: \(attributes)")
    }
    
    // MARK: - Download Tracking
    
    static func trackDownloadCompleted(source: String? = nil) {
        var attributes = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        ]
        
        if let source = source {
            attributes["download_source"] = source
        }
        
        Singular.event("download_completed", withArgs: attributes)
        print("⬇️ Download tracked from source: \(source ?? "organic")")
    }
    
    // MARK: - Pendulum Level Tracking
    
    static func trackLevelBalanced(level: Int, balanceTime: Double, score: Int, attempts: Int) {
        // Calculate performance metrics
        let efficiency = Double(score) / balanceTime
        let difficulty = calculateDifficulty(level: level)
        
        let attributes: [String: String] = [
            "level": "\(level)",
            "balance_time": String(format: "%.2f", balanceTime),
            "score": "\(score)",
            "attempts": "\(attempts)",
            "efficiency": String(format: "%.2f", efficiency),
            "difficulty": difficulty,
            "perfect_balance": balanceTime > 60 ? "true" : "false",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("pendulum_level_balanced", withArgs: attributes)
        print("🎮 Level balanced tracked: Level \(level), Time: \(balanceTime)s, Score: \(score)")
        
        // Track achievement if applicable
        if balanceTime > 60 {
            trackAchievement(type: "perfect_balance", level: level)
        }
        
        // Track revenue if this was a premium level
        if level > 5 {
            trackLevelRevenue(level: level, score: score)
        }
    }
    
    // MARK: - Session Tracking
    
    static func trackSessionStart() {
        let attributes = [
            "session_id": UUID().uuidString,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "device_battery": "\(Int(UIDevice.current.batteryLevel * 100))%"
        ]
        
        Singular.event("session_start", withArgs: attributes)
        print("▶️ Session start tracked")
    }
    
    static func trackSessionEnd(duration: TimeInterval, levelsPlayed: Int) {
        let attributes = [
            "duration": String(format: "%.0f", duration),
            "levels_played": "\(levelsPlayed)",
            "avg_time_per_level": String(format: "%.1f", duration / Double(max(levelsPlayed, 1))),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("session_end", withArgs: attributes)
        print("⏹️ Session end tracked: Duration \(duration)s, Levels: \(levelsPlayed)")
    }
    
    // MARK: - Achievement Tracking
    
    static func trackAchievement(type: String, level: Int? = nil) {
        var attributes = [
            "achievement_type": type,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let level = level {
            attributes["level"] = "\(level)"
        }
        
        Singular.event("achievement_unlocked", withArgs: attributes)
        print("🏆 Achievement tracked: \(type)")
    }
    
    // MARK: - In-App Purchase Tracking
    
    static func trackPurchase(productId: String, price: Double, currency: String = "USD") {
        // Track as custom revenue event
        Singular.customRevenue("iap_purchase", currency: currency, amount: price)
        
        // Also track as detailed event
        let attributes = [
            "product_id": productId,
            "price": String(format: "%.2f", price),
            "currency": currency,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("purchase_completed", withArgs: attributes)
        print("💰 Purchase tracked: \(productId) for \(price) \(currency)")
    }
    
    // MARK: - Tutorial Tracking
    
    static func trackTutorialStep(step: Int, completed: Bool) {
        let attributes = [
            "tutorial_step": "\(step)",
            "completed": completed ? "true" : "false",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        let eventName = completed ? "tutorial_step_completed" : "tutorial_step_skipped"
        Singular.event(eventName, withArgs: attributes)
        print("📚 Tutorial step \(step) tracked: \(completed ? "completed" : "skipped")")
    }
    
    // MARK: - Error Tracking
    
    static func trackError(error: String, context: String) {
        let attributes = [
            "error_message": error,
            "error_context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("app_error", withArgs: attributes)
        print("❌ Error tracked: \(error) in \(context)")
    }
    
    // MARK: - Helper Methods
    
    private static func calculateDifficulty(level: Int) -> String {
        switch level {
        case 1...3:
            return "easy"
        case 4...6:
            return "medium"
        case 7...9:
            return "hard"
        default:
            return "expert"
        }
    }
    
    private static func trackLevelRevenue(level: Int, score: Int) {
        // Track virtual currency earned
        let coinsEarned = score / 100
        if coinsEarned > 0 {
            Singular.customRevenue("coins_earned", currency: "COINS", amount: Double(coinsEarned))
        }
    }
    
    // MARK: - Batch Event Tracking
    
    static func trackGameStats(stats: GameStats) {
        let attributes = [
            "total_levels_played": "\(stats.totalLevelsPlayed)",
            "highest_level": "\(stats.highestLevel)",
            "total_score": "\(stats.totalScore)",
            "avg_balance_time": String(format: "%.1f", stats.averageBalanceTime),
            "perfect_balances": "\(stats.perfectBalances)",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event("game_stats_update", withArgs: attributes)
        print("📊 Game stats tracked")
    }
}

// MARK: - Game Stats Model

struct GameStats {
    let totalLevelsPlayed: Int
    let highestLevel: Int
    let totalScore: Int
    let averageBalanceTime: Double
    let perfectBalances: Int
}

