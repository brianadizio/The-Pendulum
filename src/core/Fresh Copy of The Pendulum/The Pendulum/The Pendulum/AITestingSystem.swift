// AITestingSystem.swift
// System for running AI players to generate test data for the dashboard

import Foundation
import UIKit

// MARK: - AI Test Configuration

struct AITestConfiguration {
    let skillLevel: AISkillLevel
    let duration: TimeInterval
    let perturbationModes: [String]
    let parameterVariations: Bool
    let numberOfSessions: Int
    let timeBetweenSessions: TimeInterval
    
    static let quickTest = AITestConfiguration(
        skillLevel: .intermediate,
        duration: 300, // 5 minutes
        perturbationModes: ["Primary"],
        parameterVariations: false,
        numberOfSessions: 1,
        timeBetweenSessions: 0
    )
    
    static let comprehensiveTest = AITestConfiguration(
        skillLevel: .intermediate,
        duration: 600, // 10 minutes per session
        perturbationModes: ["Primary", "Progressive", "Random Impulses", "Sine Wave"],
        parameterVariations: true,
        numberOfSessions: 5,
        timeBetweenSessions: 60 // 1 minute between sessions
    )
    
    static let longTermTest = AITestConfiguration(
        skillLevel: .advanced,
        duration: 1800, // 30 minutes per session
        perturbationModes: ["Primary", "Progressive", "Random Impulses", "Sine Wave", "Compound"],
        parameterVariations: true,
        numberOfSessions: 20,
        timeBetweenSessions: 300 // 5 minutes between sessions
    )
}

// MARK: - AI Testing System

class AITestingSystem {
    
    private let gameplaySimulator = GameplayDataSimulator()
    private var currentTestConfig: AITestConfiguration?
    private var testProgress: TestProgress?
    private var completionHandler: ((TestResults) -> Void)?
    
    struct TestProgress {
        var completedSessions: Int = 0
        var currentSession: Int = 0
        var totalLevelsCompleted: Int = 0
        var totalScore: Int = 0
        var sessionResults: [SessionResult] = []
    }
    
    struct SessionResult {
        let sessionId: UUID
        let skillLevel: AISkillLevel
        let duration: TimeInterval
        let levelsCompleted: Int
        let finalScore: Int
        let perturbationMode: String
        let metrics: [String: Any]
    }
    
    struct TestResults {
        let totalSessions: Int
        let totalDuration: TimeInterval
        let averageScore: Double
        let averageLevelsPerSession: Double
        let sessionResults: [SessionResult]
        let dashboardDataGenerated: Bool
    }
    
    // MARK: - Public Interface
    
    /// Run a quick AI test to generate basic dashboard data
    func runQuickTest(completion: @escaping (TestResults) -> Void) {
        runTest(configuration: .quickTest, completion: completion)
    }
    
    /// Run a comprehensive AI test to generate full dashboard data
    func runComprehensiveTest(completion: @escaping (TestResults) -> Void) {
        runTest(configuration: .comprehensiveTest, completion: completion)
    }
    
    /// Run a long-term AI test to generate extensive historical data
    func runLongTermTest(completion: @escaping (TestResults) -> Void) {
        runTest(configuration: .longTermTest, completion: completion)
    }
    
    /// Run a custom AI test with specified configuration
    func runTest(configuration: AITestConfiguration, completion: @escaping (TestResults) -> Void) {
        currentTestConfig = configuration
        completionHandler = completion
        testProgress = TestProgress()
        
        print("🤖 Starting AI Test with configuration:")
        print("   Skill Level: \(configuration.skillLevel)")
        print("   Sessions: \(configuration.numberOfSessions)")
        print("   Duration per session: \(configuration.duration)s")
        print("   Perturbation modes: \(configuration.perturbationModes)")
        
        // Start the first session
        runNextSession()
    }
    
    // MARK: - Test Execution
    
    private func runNextSession() {
        guard let config = currentTestConfig,
              let progress = testProgress else { return }
        
        if progress.currentSession >= config.numberOfSessions {
            // All sessions complete
            completeTest()
            return
        }
        
        // Select perturbation mode for this session
        let modeIndex = progress.currentSession % config.perturbationModes.count
        let perturbationMode = config.perturbationModes[modeIndex]
        
        print("\n🎮 Running session \(progress.currentSession + 1) of \(config.numberOfSessions)")
        print("   Mode: \(perturbationMode)")
        
        // Generate AI gameplay session
        let sessionId = simulateAIGameplay(
            skillLevel: config.skillLevel,
            duration: config.duration,
            perturbationMode: perturbationMode,
            varyParameters: config.parameterVariations
        )
        
        // Collect session results
        collectSessionResults(sessionId: sessionId, perturbationMode: perturbationMode)
        
        // Update progress
        testProgress?.currentSession += 1
        testProgress?.completedSessions += 1
        
        // Schedule next session
        if progress.currentSession + 1 < config.numberOfSessions {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.timeBetweenSessions) { [weak self] in
                self?.runNextSession()
            }
        } else {
            // Complete test
            completeTest()
        }
    }
    
    private func simulateAIGameplay(
        skillLevel: AISkillLevel,
        duration: TimeInterval,
        perturbationMode: String,
        varyParameters: Bool
    ) -> UUID {
        
        // Create simulation parameters based on AI skill
        let parameters = createAISimulationParameters(
            skillLevel: skillLevel,
            varyParameters: varyParameters
        )
        
        // Map perturbation mode to simulation profile
        let profile = mapPerturbationModeToProfile(perturbationMode)
        
        // Run simulation
        let sessionId = gameplaySimulator.simulateGameplay(
            profile: profile,
            duration: duration,
            levels: Int(duration / 30), // Estimate ~30s per level
            startDate: Date()
        )
        
        return sessionId
    }
    
    private func createAISimulationParameters(
        skillLevel: AISkillLevel,
        varyParameters: Bool
    ) -> GameplayDataSimulator.SimulationParameters {
        
        // Base parameters on AI skill level
        let baseStability: Double
        let reactionTimeBase: Double
        let overcorrectionProbability: Double
        
        switch skillLevel {
        case .beginner:
            baseStability = 40.0
            reactionTimeBase = 0.6
            overcorrectionProbability = 0.4
        case .intermediate:
            baseStability = 60.0
            reactionTimeBase = 0.4
            overcorrectionProbability = 0.2
        case .advanced:
            baseStability = 75.0
            reactionTimeBase = 0.3
            overcorrectionProbability = 0.1
        case .expert:
            baseStability = 85.0
            reactionTimeBase = 0.2
            overcorrectionProbability = 0.05
        case .perfect:
            baseStability = 95.0
            reactionTimeBase = 0.1
            overcorrectionProbability = 0.0
        }
        
        // Add parameter variations if requested
        let stabilityVariance = varyParameters ? 10.0 : 5.0
        let forceMultiplier = varyParameters ? Double.random(in: 0.8...1.2) : 1.0
        
        return GameplayDataSimulator.SimulationParameters(
            baseStability: baseStability,
            stabilityVariance: stabilityVariance,
            improvementRate: 0.1,
            reactionTimeBase: reactionTimeBase,
            reactionTimeVariance: 0.1,
            directionalBias: Double.random(in: -0.1...0.1),
            overcorrectionProbability: overcorrectionProbability,
            forceMultiplier: forceMultiplier
        )
    }
    
    private func mapPerturbationModeToProfile(_ mode: String) -> GameplayDataSimulator.SimulationProfile {
        // For AI testing, we use custom profiles that match the game modes
        switch mode {
        case "Progressive":
            return .improver // Shows progression over time
        case "Random Impulses":
            return .erratic // Handles random disturbances
        case "Sine Wave":
            return .intermediate // Steady periodic forces
        case "Compound":
            return .expert // Complex multi-force scenarios
        default:
            return .intermediate // Default/Primary mode
        }
    }
    
    private func collectSessionResults(sessionId: UUID, perturbationMode: String) {
        // Get metrics from the completed session
        let metrics = AnalyticsManager.shared.getPerformanceMetrics(for: sessionId)
        
        // Extract key values
        let score = Int(metrics["finalScore"] as? Double ?? 0)
        let levelsCompleted = Int(metrics["levelsCompleted"] as? Double ?? 3)
        let duration = metrics["totalPlayTime"] as? TimeInterval ?? 0
        
        let result = SessionResult(
            sessionId: sessionId,
            skillLevel: currentTestConfig?.skillLevel ?? .intermediate,
            duration: duration,
            levelsCompleted: levelsCompleted,
            finalScore: score,
            perturbationMode: perturbationMode,
            metrics: metrics
        )
        
        // Update progress
        testProgress?.sessionResults.append(result)
        testProgress?.totalLevelsCompleted += levelsCompleted
        testProgress?.totalScore += score
    }
    
    private func completeTest() {
        guard let config = currentTestConfig,
              let progress = testProgress else { return }
        
        // Calculate aggregate results
        let totalDuration = Double(progress.completedSessions) * config.duration
        let averageScore = progress.completedSessions > 0 ?
            Double(progress.totalScore) / Double(progress.completedSessions) : 0
        let averageLevels = progress.completedSessions > 0 ?
            Double(progress.totalLevelsCompleted) / Double(progress.completedSessions) : 0
        
        let results = TestResults(
            totalSessions: progress.completedSessions,
            totalDuration: totalDuration,
            averageScore: averageScore,
            averageLevelsPerSession: averageLevels,
            sessionResults: progress.sessionResults,
            dashboardDataGenerated: true
        )
        
        print("\n✅ AI Test Complete!")
        print("   Total sessions: \(results.totalSessions)")
        print("   Average score: \(String(format: "%.1f", results.averageScore))")
        print("   Average levels/session: \(String(format: "%.1f", results.averageLevelsPerSession))")
        print("   Dashboard data generated: ✓")
        
        // Trigger analytics aggregation
        AnalyticsManager.shared.updateAggregatedAnalytics()
        
        // Call completion handler
        completionHandler?(results)
        
        // Reset state
        currentTestConfig = nil
        testProgress = nil
        completionHandler = nil
    }
}

// MARK: - Convenience Methods for Testing

extension AITestingSystem {
    
    /// Generate data for all dashboard views quickly
    static func generateQuickDashboardData() {
        let tester = AITestingSystem()
        
        print("🚀 Generating quick dashboard data...")
        
        tester.runQuickTest { results in
            print("\n📊 Dashboard data generation complete!")
            print("You can now view populated charts and metrics in the dashboard.")
        }
    }
    
    /// Generate comprehensive test data over multiple skill levels
    static func generateComprehensiveTestData() {
        let tester = AITestingSystem()
        
        print("🚀 Generating comprehensive test data...")
        
        // Run tests for different skill levels
        let skillLevels: [AISkillLevel] = [.beginner, .intermediate, .advanced]
        var currentIndex = 0
        
        func runNextSkillLevel() {
            guard currentIndex < skillLevels.count else {
                print("\n🎉 All skill level tests complete!")
                return
            }
            
            let skill = skillLevels[currentIndex]
            let config = AITestConfiguration(
                skillLevel: skill,
                duration: 300,
                perturbationModes: ["Primary", "Progressive", "Random Impulses"],
                parameterVariations: true,
                numberOfSessions: 3,
                timeBetweenSessions: 30
            )
            
            tester.runTest(configuration: config) { _ in
                currentIndex += 1
                runNextSkillLevel()
            }
        }
        
        runNextSkillLevel()
    }
}

// MARK: - Integration with View Controllers

extension PendulumViewController {
    
    /// Add AI test button to the UI (for development/testing)
    func addAITestButton() {
        let testButton = UIButton(type: .system)
        testButton.setTitle("AI Test", for: .normal)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 8
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(testButton)
        
        NSLayoutConstraint.activate([
            testButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            testButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testButton.widthAnchor.constraint(equalToConstant: 80),
            testButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        testButton.addTarget(self, action: #selector(showTestMenu), for: .touchUpInside)
    }
    
    @objc private func showTestMenu() {
        let alert = UIAlertController(title: "AI Test", message: "Select test type", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Quick Test (5 min)", style: .default) { _ in
            AITestingSystem.generateQuickDashboardData()
        })
        
        alert.addAction(UIAlertAction(title: "Comprehensive Test", style: .default) { _ in
            AITestingSystem.generateComprehensiveTestData()
        })
        
        alert.addAction(UIAlertAction(title: "Play vs AI", style: .default) { [weak self] _ in
            self?.startAIOpponent()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func startAIOpponent() {
        // Start AI player as opponent
        PendulumAIManager.shared.startAIPlayer(skillLevel: .intermediate, viewModel: viewModel)
        
        let alert = UIAlertController(
            title: "AI Opponent Active",
            message: "The AI is now playing. Watch it balance the pendulum!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Stop AI", style: .destructive) { _ in
            PendulumAIManager.shared.stopAIPlayer()
        })
        
        present(alert, animated: true)
    }
}