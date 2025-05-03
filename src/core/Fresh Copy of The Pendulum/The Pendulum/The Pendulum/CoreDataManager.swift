import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
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
        let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
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
            let achievement = Achievement(context: context)
            achievement.id = id
            achievement.name = name
            achievement.achievementDescription = description
            achievement.points = Int32(points)
            achievement.unlocked = false
            
            saveContext()
        }
    }
    
    func unlockAchievement(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let achievements = try context.fetch(fetchRequest)
            if let achievement = achievements.first, !achievement.unlocked {
                achievement.unlocked = true
                achievement.achievedDate = Date()
                saveContext()
                return true
            }
            return false
        } catch {
            print("Error unlocking achievement: \(error)")
            return false
        }
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unlocked == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "achievedDate", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching unlocked achievements: \(error)")
            return []
        }
    }
    
    func getAllAchievements() -> [Achievement] {
        let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
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
                    let achievementFetch: NSFetchRequest<Achievement> = Achievement.fetchRequest()
                    achievementFetch.predicate = NSPredicate(format: "id == %@", achievementId)
                    
                    if let achievement = try context.fetch(achievementFetch).first {
                        session.addToAchievements(achievement)
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
}

// Note: No extensions for fetchRequest() needed as CoreData generates them automatically