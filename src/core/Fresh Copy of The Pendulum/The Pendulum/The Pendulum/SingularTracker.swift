import Foundation

// Game-specific tracking wrapper for Singular SDK
class SingularTracker {
    
    // MARK: - Install Tracking
    
    static func trackInstall() {
        #if SINGULAR_SDK_AVAILABLE
        // Track install event with app-specific attributes
        let attributes = [
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event(withArgs: "app_install", withAttributes: attributes)
        print("📱 Install tracked with attributes: \(attributes)")
        #else
        print("⚠️ SingularTracker: Cannot track install - SDK not available")
        #endif
    }
    
    // MARK: - Download Tracking
    
    static func trackDownloadCompleted(source: String? = nil) {
        #if SINGULAR_SDK_AVAILABLE
        var attributes = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        ]
        
        if let source = source {
            attributes["download_source"] = source
        }
        
        Singular.event(withArgs: "download_completed", withAttributes: attributes)
        print("⬇️ Download tracked from source: \(source ?? "organic")")
        #else
        print("⚠️ SingularTracker: Cannot track download - SDK not available")
        #endif
    }
    
    // MARK: - Pendulum Level Tracking
    
    static func trackLevelBalanced(level: Int, balanceTime: Double, score: Int, attempts: Int) {
        #if SINGULAR_SDK_AVAILABLE
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
        
        Singular.event(withArgs: "pendulum_level_balanced", withAttributes: attributes)
        print("🎮 Level balanced tracked: Level \(level), Time: \(balanceTime)s, Score: \(score)")
        
        // Track achievement if applicable
        if balanceTime > 60 {
            trackAchievement(type: "perfect_balance", level: level)
        }
        
        // Track revenue if this was a premium level
        if level > 5 {
            trackLevelRevenue(level: level, score: score)
        }
        #else
        print("⚠️ SingularTracker: Cannot track level balanced - SDK not available")
        #endif
    }
    
    // MARK: - Session Tracking
    
    static func trackSessionStart() {
        #if SINGULAR_SDK_AVAILABLE
        let attributes = [
            "session_id": UUID().uuidString,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "device_battery": "\(Int(UIDevice.current.batteryLevel * 100))%"
        ]
        
        Singular.event(withArgs: "session_start", withAttributes: attributes)
        print("▶️ Session start tracked")
        #else
        print("⚠️ SingularTracker: Cannot track session start - SDK not available")
        #endif
    }
    
    static func trackSessionEnd(duration: TimeInterval, levelsPlayed: Int) {
        #if SINGULAR_SDK_AVAILABLE
        let attributes = [
            "duration": String(format: "%.0f", duration),
            "levels_played": "\(levelsPlayed)",
            "avg_time_per_level": String(format: "%.1f", duration / Double(max(levelsPlayed, 1))),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event(withArgs: "session_end", withAttributes: attributes)
        print("⏹️ Session end tracked: Duration \(duration)s, Levels: \(levelsPlayed)")
        #else
        print("⚠️ SingularTracker: Cannot track session end - SDK not available")
        #endif
    }
    
    // MARK: - Achievement Tracking
    
    static func trackAchievement(type: String, level: Int? = nil) {
        #if SINGULAR_SDK_AVAILABLE
        var attributes = [
            "achievement_type": type,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let level = level {
            attributes["level"] = "\(level)"
        }
        
        Singular.event(withArgs: "achievement_unlocked", withAttributes: attributes)
        print("🏆 Achievement tracked: \(type)")
        #else
        print("⚠️ SingularTracker: Cannot track achievement - SDK not available")
        #endif
    }
    
    // MARK: - In-App Purchase Tracking
    
    static func trackPurchase(productId: String, price: Double, currency: String = "USD") {
        #if SINGULAR_SDK_AVAILABLE
        // Track as custom revenue event
        Singular.customRevenue("iap_purchase", currency: currency, amount: price)
        
        // Also track as detailed event
        let attributes = [
            "product_id": productId,
            "price": String(format: "%.2f", price),
            "currency": currency,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event(withArgs: "purchase_completed", withAttributes: attributes)
        print("💰 Purchase tracked: \(productId) for \(price) \(currency)")
        #else
        print("⚠️ SingularTracker: Cannot track purchase - SDK not available")
        #endif
    }
    
    // MARK: - Tutorial Tracking
    
    static func trackTutorialStep(step: Int, completed: Bool) {
        #if SINGULAR_SDK_AVAILABLE
        let attributes = [
            "tutorial_step": "\(step)",
            "completed": completed ? "true" : "false",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        let eventName = completed ? "tutorial_step_completed" : "tutorial_step_skipped"
        Singular.event(withArgs: eventName, withAttributes: attributes)
        print("📚 Tutorial step \(step) tracked: \(completed ? "completed" : "skipped")")
        #else
        print("⚠️ SingularTracker: Cannot track tutorial - SDK not available")
        #endif
    }
    
    // MARK: - Error Tracking
    
    static func trackError(error: String, context: String) {
        #if SINGULAR_SDK_AVAILABLE
        let attributes = [
            "error_message": error,
            "error_context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event(withArgs: "app_error", withAttributes: attributes)
        print("❌ Error tracked: \(error) in \(context)")
        #else
        print("⚠️ SingularTracker: Cannot track error - SDK not available")
        #endif
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
        #if SINGULAR_SDK_AVAILABLE
        // Track virtual currency earned
        let coinsEarned = score / 100
        if coinsEarned > 0 {
            Singular.customRevenue("coins_earned", currency: "COINS", amount: Double(coinsEarned))
        }
        #endif
    }
    
    // MARK: - Batch Event Tracking
    
    static func trackGameStats(stats: GameStats) {
        #if SINGULAR_SDK_AVAILABLE
        let attributes = [
            "total_levels_played": "\(stats.totalLevelsPlayed)",
            "highest_level": "\(stats.highestLevel)",
            "total_score": "\(stats.totalScore)",
            "avg_balance_time": String(format: "%.1f", stats.averageBalanceTime),
            "perfect_balances": "\(stats.perfectBalances)",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        Singular.event(withArgs: "game_stats_update", withAttributes: attributes)
        print("📊 Game stats tracked")
        #else
        print("⚠️ SingularTracker: Cannot track game stats - SDK not available")
        #endif
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

// MARK: - Placeholder Implementations

#if !SINGULAR_SDK_AVAILABLE

// These placeholders allow the code to compile before Singular SDK is added
extension Singular {
    static func event(withArgs name: String, withAttributes attributes: [String: String]) {
        print("⚠️ Placeholder: Would track event '\(name)' with attributes: \(attributes)")
    }
    
    static func customRevenue(_ name: String, currency: String, amount: Double) {
        print("⚠️ Placeholder: Would track revenue '\(name)': \(amount) \(currency)")
    }
}

#endif