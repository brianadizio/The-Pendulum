import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

/// Manages syncing gameplay data between Core Data and Firebase Firestore
class FirebaseGameplaySync {
    static let shared = FirebaseGameplaySync()
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private let syncQueue = DispatchQueue(label: "com.pendulum.sync", attributes: .concurrent)
    
    // Sync state
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    private init() {
        setupListeners()
    }
    
    deinit {
        removeListeners()
    }
    
    // MARK: - Setup
    
    private func setupListeners() {
        // Listen for auth state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authStateChanged),
            name: .authStateDidChange,
            object: nil
        )
    }
    
    private func removeListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func authStateChanged() {
        if Auth.auth().currentUser != nil {
            // User logged in, start syncing
            performInitialSync()
            setupRealtimeSync()
        } else {
            // User logged out, stop syncing
            removeListeners()
        }
    }
    
    // MARK: - Initial Sync
    
    /// Performs initial sync when user logs in
    func performInitialSync() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isSyncing = true
        
        Task {
            do {
                // Sync high scores
                try await syncHighScores(userId: userId)
                
                // Sync achievements
                try await syncAchievements(userId: userId)
                
                // Sync play sessions
                try await syncPlaySessions(userId: userId)
                
                // Update last sync date
                lastSyncDate = Date()
                syncError = nil
                
            } catch {
                syncError = error
                print("Initial sync failed: \(error)")
            }
            
            isSyncing = false
        }
    }
    
    // MARK: - High Scores Sync
    
    private func syncHighScores(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let scoresRef = userRef.collection("highScores")
        
        // Get local high scores
        let localScores = CoreDataManager.shared.getTopHighScores(limit: 100)
        
        // Get remote high scores
        let snapshot = try await scoresRef.getDocuments()
        let remoteScores = snapshot.documents.compactMap { doc -> HighScoreData? in
            try? doc.data(as: HighScoreData.self)
        }
        
        // Merge strategy: Keep highest score for each level
        var mergedScores: [Int: HighScoreData] = [:]
        
        // Add remote scores
        for score in remoteScores {
            mergedScores[score.level] = score
        }
        
        // Add/update with local scores if higher
        for localScore in localScores {
            let level = Int(localScore.level)
            let score = Int(localScore.score)
            
            if let existing = mergedScores[level] {
                if score > existing.score {
                    mergedScores[level] = HighScoreData(
                        score: score,
                        level: level,
                        timeBalanced: localScore.timeBalanced,
                        playerName: localScore.playerName ?? "Player",
                        date: localScore.date ?? Date(),
                        deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
                    )
                }
            } else {
                mergedScores[level] = HighScoreData(
                    score: score,
                    level: level,
                    timeBalanced: localScore.timeBalanced,
                    playerName: localScore.playerName ?? "Player",
                    date: localScore.date ?? Date(),
                    deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
                )
            }
        }
        
        // Upload merged scores to Firebase
        for (_, scoreData) in mergedScores {
            let docRef = scoresRef.document("level_\(scoreData.level)")
            try await docRef.setData(scoreData.toDictionary())
        }
        
        // Update user's overall high score
        let highestScore = mergedScores.values.map { $0.score }.max() ?? 0
        try await userRef.updateData([
            "highScore": highestScore,
            "lastSyncDate": FieldValue.serverTimestamp()
        ])
    }
    
    // MARK: - Achievements Sync
    
    private func syncAchievements(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let achievementsRef = userRef.collection("achievements")
        
        // Get local achievements
        let localAchievements = CoreDataManager.shared.getUnlockedAchievements()
        
        // Get remote achievements
        let snapshot = try await achievementsRef.getDocuments()
        var remoteAchievementIds = Set(snapshot.documents.map { $0.documentID })
        
        // Upload local achievements not in remote
        for achievement in localAchievements {
            guard let id = achievement.value(forKey: "id") as? String,
                  let name = achievement.value(forKey: "name") as? String,
                  let achievedDate = achievement.value(forKey: "achievedDate") as? Date else {
                continue
            }
            
            if !remoteAchievementIds.contains(id) {
                let data: [String: Any] = [
                    "id": id,
                    "name": name,
                    "achievedDate": Timestamp(date: achievedDate),
                    "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
                ]
                
                try await achievementsRef.document(id).setData(data)
            }
        }
        
        // Download remote achievements not in local
        for document in snapshot.documents {
            let id = document.documentID
            if !CoreDataManager.shared.achievementExists(id: id) {
                // Achievement doesn't exist locally, but was unlocked remotely
                if let data = document.data() as? [String: Any],
                   let name = data["name"] as? String {
                    
                    // Create and unlock the achievement locally
                    CoreDataManager.shared.createAchievement(
                        id: id,
                        name: name,
                        description: data["description"] as? String ?? "",
                        points: data["points"] as? Int ?? 0
                    )
                    _ = CoreDataManager.shared.unlockAchievement(id: id)
                }
            }
        }
        
        // Update user's total achievements
        let totalAchievements = CoreDataManager.shared.getUnlockedAchievements().count
        try await userRef.updateData([
            "achievements": totalAchievements
        ])
    }
    
    // MARK: - Play Sessions Sync
    
    private func syncPlaySessions(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let sessionsRef = userRef.collection("playSessions")
        
        // For play sessions, we'll only sync summary data to avoid too much data transfer
        // Get total play time from local sessions
        let fetchRequest: NSFetchRequest<PlaySession> = PlaySession.fetchRequest()
        
        do {
            let sessions = try CoreDataManager.shared.context.fetch(fetchRequest)
            let totalPlayTime = sessions.reduce(0) { $0 + $1.duration }
            let totalSessions = sessions.count
            let avgSessionDuration = totalSessions > 0 ? totalPlayTime / Double(totalSessions) : 0
            
            // Update user stats
            try await userRef.updateData([
                "totalPlayTime": totalPlayTime,
                "totalSessions": totalSessions,
                "avgSessionDuration": avgSessionDuration,
                "lastPlayDate": sessions.last?.date ?? Date()
            ])
            
        } catch {
            print("Error syncing play sessions: \(error)")
        }
    }
    
    // MARK: - Real-time Sync
    
    private func setupRealtimeSync() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Listen for high score updates
        let highScoreListener = db.collection("users").document(userId)
            .collection("highScores")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("High score sync error: \(error)")
                    return
                }
                
                // Handle high score updates from other devices
                self?.handleHighScoreUpdates(snapshot: snapshot)
            }
        
        listeners.append(highScoreListener)
        
        // Listen for achievement updates
        let achievementListener = db.collection("users").document(userId)
            .collection("achievements")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Achievement sync error: \(error)")
                    return
                }
                
                // Handle achievement updates from other devices
                self?.handleAchievementUpdates(snapshot: snapshot)
            }
        
        listeners.append(achievementListener)
    }
    
    private func handleHighScoreUpdates(snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else { return }
        
        for document in documents {
            if let scoreData = try? document.data(as: HighScoreData.self) {
                // Check if this score is higher than local
                let localHighScore = CoreDataManager.shared.getHighestScore()
                if scoreData.score > localHighScore {
                    // Update local high score
                    CoreDataManager.shared.saveHighScore(
                        score: scoreData.score,
                        level: scoreData.level,
                        timeBalanced: scoreData.timeBalanced,
                        playerName: scoreData.playerName
                    )
                }
            }
        }
    }
    
    private func handleAchievementUpdates(snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else { return }
        
        for document in documents {
            let id = document.documentID
            if !CoreDataManager.shared.achievementExists(id: id) {
                // New achievement from another device
                if let data = document.data() as? [String: Any],
                   let name = data["name"] as? String {
                    
                    CoreDataManager.shared.createAchievement(
                        id: id,
                        name: name,
                        description: data["description"] as? String ?? "",
                        points: data["points"] as? Int ?? 0
                    )
                    _ = CoreDataManager.shared.unlockAchievement(id: id)
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Saves a new high score and syncs to Firebase
    func saveHighScore(score: Int, level: Int, timeBalanced: Double, playerName: String) {
        // Save locally first
        CoreDataManager.shared.saveHighScore(
            score: score,
            level: level,
            timeBalanced: timeBalanced,
            playerName: playerName
        )
        
        // Then sync to Firebase if logged in
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let scoreData = HighScoreData(
            score: score,
            level: level,
            timeBalanced: timeBalanced,
            playerName: playerName,
            date: Date(),
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        )
        
        Task {
            do {
                let docRef = db.collection("users").document(userId)
                    .collection("highScores").document("level_\(level)")
                
                try await docRef.setData(scoreData.toDictionary())
                
                // Update user's overall high score if needed
                let currentHighScore = CoreDataManager.shared.getHighestScore()
                if score >= currentHighScore {
                    try await db.collection("users").document(userId).updateData([
                        "highScore": score
                    ])
                }
            } catch {
                print("Failed to sync high score: \(error)")
            }
        }
    }
    
    /// Unlocks an achievement and syncs to Firebase
    func unlockAchievement(id: String) {
        // Unlock locally first
        let wasUnlocked = CoreDataManager.shared.unlockAchievement(id: id)
        
        if wasUnlocked {
            // Then sync to Firebase if logged in
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            Task {
                do {
                    // Get achievement details
                    let achievements = CoreDataManager.shared.getAllAchievements()
                    if let achievement = achievements.first(where: { 
                        ($0.value(forKey: "id") as? String) == id 
                    }) {
                        let data: [String: Any] = [
                            "id": id,
                            "name": achievement.value(forKey: "name") as? String ?? "",
                            "achievedDate": Timestamp(date: Date()),
                            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
                        ]
                        
                        try await db.collection("users").document(userId)
                            .collection("achievements").document(id).setData(data)
                        
                        // Update total achievements count
                        let totalAchievements = CoreDataManager.shared.getUnlockedAchievements().count
                        try await db.collection("users").document(userId).updateData([
                            "achievements": totalAchievements
                        ])
                    }
                } catch {
                    print("Failed to sync achievement: \(error)")
                }
            }
        }
    }
}

// MARK: - Data Models

struct HighScoreData: Codable {
    let score: Int
    let level: Int
    let timeBalanced: Double
    let playerName: String
    let date: Date
    let deviceId: String
    
    func toDictionary() -> [String: Any] {
        return [
            "score": score,
            "level": level,
            "timeBalanced": timeBalanced,
            "playerName": playerName,
            "date": Timestamp(date: date),
            "deviceId": deviceId
        ]
    }
}