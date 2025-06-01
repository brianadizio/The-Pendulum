import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // Run initial setup
        setupDataStores()
    }
    
    // MARK: - Core Data Context
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        return appDelegate.persistentContainer
    }()
    
    // MARK: - Save Context
    
    func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
    
    // MARK: - High Score Methods
    
    func saveHighScore(score: Int, level: Int, timeBalanced: Double, playerName: String = "Player") {
        let highScore = HighScore(context: context)
        highScore.score = Int32(score)
        highScore.level = Int32(level)
        highScore.timeBalanced = timeBalanced
        highScore.playerName = playerName
        highScore.date = Date()
        
        saveContext()
    }
    
    func getTopHighScores(limit: Int = 10) -> [HighScore] {
        let fetchRequest: NSFetchRequest<HighScore> = HighScore.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        fetchRequest.fetchLimit = limit
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching high scores: \(error)")
            return []
        }
    }
    
    func getHighestScore() -> Int {
        let fetchRequest: NSFetchRequest<HighScore> = HighScore.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first?.score != nil ? Int(result.first!.score) : 0
        } catch {
            print("Error fetching highest score: \(error)")
            return 0
        }
    }
    
    // MARK: - Achievement Methods
    
    func achievementExists(id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Achievement")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking for achievement: \(error)")
            return false
        }
    }
    
    func createAchievement(id: String, name: String, description: String, points: Int) {
        // Only create if it doesn't exist
        if !achievementExists(id: id) {
            let achievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into: context)
            achievement.setValue(id, forKey: "id")
            achievement.setValue(name, forKey: "name")
            achievement.setValue(description, forKey: "achievementDescription")
            achievement.setValue(Int32(points), forKey: "points")
            achievement.setValue(false, forKey: "unlocked")
            
            saveContext()
        }
    }
    
    func unlockAchievement(id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Achievement")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let achievements = try context.fetch(fetchRequest)
            if let achievement = achievements.first,
               let unlocked = achievement.value(forKey: "unlocked") as? Bool,
               !unlocked {
                achievement.setValue(true, forKey: "unlocked")
                achievement.setValue(Date(), forKey: "achievedDate")
                saveContext()
                return true
            }
            return false
        } catch {
            print("Error unlocking achievement: \(error)")
            return false
        }
    }
    
    func getUnlockedAchievements() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Achievement")
        fetchRequest.predicate = NSPredicate(format: "unlocked == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "achievedDate", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching unlocked achievements: \(error)")
            return []
        }
    }
    
    func getAllAchievements() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Achievement")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching all achievements: \(error)")
            return []
        }
    }
    
    // MARK: - Play Session Methods
    
    func startPlaySession() -> UUID {
        let session = PlaySession(context: context)
        let sessionId = UUID()
        session.sessionId = sessionId
        session.date = Date()
        session.score = 0
        session.duration = 0
        session.highestLevel = 1
        session.maxAngle = 0
        saveContext()
        return sessionId
    }
    
    func updatePlaySession(sessionId: UUID, score: Int, level: Int, duration: Double, maxAngle: Double) {
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        
        do {
            if let session = try context.fetch(fetchRequest).first {
                session.score = Int32(score)
                session.highestLevel = Int32(level)
                session.duration = duration
                session.maxAngle = maxAngle
                saveContext()
            }
        } catch {
            print("Error updating play session: \(error)")
        }
    }
    
    func endPlaySession(sessionId: UUID, achievements: [String]) {
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        
        do {
            if let session = try context.fetch(fetchRequest).first {
                // Link earned achievements to this session
                for achievementId in achievements {
                    let achievementFetch = NSFetchRequest<NSManagedObject>(entityName: "Achievement")
                    achievementFetch.predicate = NSPredicate(format: "id == %@", achievementId)
                    
                    if let achievement = try context.fetch(achievementFetch).first {
                        // Use setValue instead of direct property access
                        var achievementSet = session.value(forKey: "achievements") as? NSMutableSet ?? NSMutableSet()
                        achievementSet.add(achievement)
                        session.setValue(achievementSet, forKey: "achievements")
                    }
                }
                saveContext()
            }
        } catch {
            print("Error ending play session: \(error)")
        }
    }
    
    // MARK: - Setup Initial Achievements

    func setupInitialAchievements() {
        // Define all achievements for the game
        let achievements = [
            // Balance achievements
            ("balance_5sec", "Steady Hand", "Balance the pendulum for 5 seconds", 10),
            ("balance_30sec", "Rock Solid", "Balance the pendulum for 30 seconds", 25),
            ("balance_60sec", "Zen Master", "Balance the pendulum for 1 minute", 50),
            
            // Level achievements
            ("reach_level_3", "Apprentice", "Reach level 3", 15),
            ("reach_level_5", "Expert", "Reach level 5", 30),
            ("reach_level_10", "Grandmaster", "Reach level 10", 100),
            
            // Score achievements
            ("score_500", "Point Collector", "Score 500 points", 20),
            ("score_1000", "High Scorer", "Score 1000 points", 40),
            ("score_5000", "Pendulum Legend", "Score 5000 points", 75),
            
            // Special achievements
            ("perfect_recovery", "Perfect Recovery", "Recover from a steep angle", 35),
            ("no_push_10sec", "Hands Free", "Balance for 10 seconds without pushing", 30),
            ("quick_level", "Speed Runner", "Complete a level in under 10 seconds", 45)
        ]
        
        for achievement in achievements {
            createAchievement(id: achievement.0, name: achievement.1, description: achievement.2, points: achievement.3)
        }
    }
    
    // MARK: - Analytics Methods
    
    // Store an interaction event
    func saveInteractionEvent(sessionId: UUID, 
                             eventType: String,
                             angle: Double,
                             angleVelocity: Double,
                             magnitude: Double,
                             direction: String,
                             reactionTime: Double) {
        guard let playSession = getPlaySession(with: sessionId) else {
            print("Error: No play session found for ID \(sessionId)")
            return
        }
        
        let event = InteractionEvent(context: context)
        event.sessionId = sessionId
        event.timestamp = Date()
        event.eventType = eventType
        event.angle = angle
        event.angleVelocity = angleVelocity
        event.magnitude = magnitude
        event.direction = direction
        event.reactionTime = reactionTime
        event.playSession = playSession
        
        saveContext()
    }
    
    // Store performance metrics
    func savePerformanceMetrics(sessionId: UUID,
                               stabilityScore: Double,
                               efficiencyRating: Double,
                               averageCorrectionTime: Double,
                               directionalBias: Double,
                               overcorrectionRate: Double,
                               playerStyle: String) {
        guard let playSession = getPlaySession(with: sessionId) else {
            print("Error: No play session found for ID \(sessionId)")
            return
        }
        
        // Check for existing metrics for this session
        let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        
        do {
            let existingMetrics = try context.fetch(fetchRequest)
            
            let metrics: PerformanceMetrics
            
            if let existingMetric = existingMetrics.first {
                // Update existing metrics
                metrics = existingMetric
            } else {
                // Create new metrics
                metrics = PerformanceMetrics(context: context)
                metrics.sessionId = sessionId
            }
            
            // Set or update properties
            metrics.timestamp = Date()
            metrics.stabilityScore = stabilityScore
            metrics.efficiencyRating = efficiencyRating
            metrics.averageCorrectionTime = averageCorrectionTime
            metrics.directionalBias = directionalBias
            metrics.overcorrectionRate = overcorrectionRate
            metrics.playerStyle = playerStyle
            metrics.playSession = playSession
            
            saveContext()
        } catch {
            print("Error saving performance metrics: \(error)")
        }
    }
    
    // Aggregate analytics over a time period
    func saveAggregatedAnalytics(period: String,
                                startDate: Date,
                                endDate: Date,
                                sessionCount: Int,
                                totalPlayTime: Double,
                                averageStabilityScore: Double,
                                averageEfficiencyRating: Double,
                                learningCurveSlope: Double,
                                playerStyleTrend: String) {
        // Check for existing aggregation for this period
        let fetchRequest: NSFetchRequest<AggregatedAnalytics> = AggregatedAnalytics.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "period == %@ AND startDate == %@", period, startDate as NSDate)
        
        do {
            let existingAggregations = try context.fetch(fetchRequest)
            
            let aggregation: AggregatedAnalytics
            
            if let existing = existingAggregations.first {
                // Update existing aggregation
                aggregation = existing
            } else {
                // Create new aggregation
                aggregation = AggregatedAnalytics(context: context)
                aggregation.period = period
                aggregation.startDate = startDate
            }
            
            // Set or update properties
            aggregation.endDate = endDate
            aggregation.sessionCount = Int32(sessionCount)
            aggregation.totalPlayTime = totalPlayTime
            aggregation.averageStabilityScore = averageStabilityScore
            aggregation.averageEfficiencyRating = averageEfficiencyRating
            aggregation.learningCurveSlope = learningCurveSlope
            aggregation.playerStyleTrend = playerStyleTrend
            
            saveContext()
        } catch {
            print("Error saving aggregated analytics: \(error)")
        }
    }
    
    // Fetch interaction events for a session
    func getInteractionEvents(for sessionId: UUID, limit: Int = 0) -> [InteractionEvent] {
        let fetchRequest: NSFetchRequest<InteractionEvent> = InteractionEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        if limit > 0 {
            fetchRequest.fetchLimit = limit
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching interaction events: \(error)")
            return []
        }
    }
    
    // Fetch performance metrics for a session
    func getPerformanceMetrics(for sessionId: UUID) -> PerformanceMetrics? {
        let fetchRequest: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching performance metrics: \(error)")
            return nil
        }
    }
    
    // Fetch aggregated analytics for a period
    func getAggregatedAnalytics(for period: String) -> AggregatedAnalytics? {
        let fetchRequest: NSFetchRequest<AggregatedAnalytics> = AggregatedAnalytics.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "period == %@", period)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching aggregated analytics: \(error)")
            return nil
        }
    }
    
    // Get a play session by ID
    private func getPlaySession(with sessionId: UUID) -> PlaySession? {
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching play session: \(error)")
            return nil
        }
    }
    
    // Setup all data stores
    private func setupDataStores() {
        // Setup achievements
        setupInitialAchievements()
        
        // Ensure the Core Data model is properly configured
        ensureDataSchemaExists()
    }
    
    // Ensure data schema exists
    private func ensureDataSchemaExists() {
        // Core Data will auto-create tables, but this function can be used
        // to validate the schema or run migrations in the future if needed
        print("Ensuring Core Data schema is up to date...")
    }
}

// Note: No extensions for fetchRequest() needed as CoreData generates them automatically