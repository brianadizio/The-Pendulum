// PendulumAIPlayer.swift
// AI player that can balance the pendulum with configurable skill levels

import Foundation
import CoreGraphics

// MARK: - Shared Enums

enum PushDirection {
    case left
    case right
    case none
}

// MARK: - AI Player Configuration

enum AISkillLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    case perfect = "Perfect"
    
    var reactionTimeRange: ClosedRange<Double> {
        switch self {
        case .beginner: return 0.2...0.4      // Faster reactions (was 0.4...0.8)
        case .intermediate: return 0.15...0.25 // Faster reactions (was 0.3...0.5)
        case .advanced: return 0.1...0.2       // Faster reactions (was 0.2...0.4)
        case .expert: return 0.05...0.15       // Faster reactions (was 0.1...0.3)
        case .perfect: return 0.02...0.05      // Near instant (was 0.05...0.1)
        }
    }
    
    var errorRate: Double {
        switch self {
        case .beginner: return 0.3      // 30% chance of error
        case .intermediate: return 0.2   // 20% chance of error
        case .advanced: return 0.1       // 10% chance of error
        case .expert: return 0.05        // 5% chance of error
        case .perfect: return 0.0        // No errors
        }
    }
    
    var forceAccuracy: Double {
        switch self {
        case .beginner: return 0.8       // 80% accurate force (was 0.6)
        case .intermediate: return 0.85   // 85% accurate force (was 0.75)
        case .advanced: return 0.92      // 92% accurate force (was 0.85)
        case .expert: return 0.98        // 98% accurate force (was 0.95)
        case .perfect: return 1.0        // Perfect force calculation
        }
    }
    
    var anticipationFactor: Double {
        switch self {
        case .beginner: return 0.4       // Better anticipation (was 0.2)
        case .intermediate: return 0.6    // Good anticipation (was 0.4)
        case .advanced: return 0.8       // Great anticipation (was 0.6)
        case .expert: return 0.9         // Excellent anticipation (was 0.8)
        case .perfect: return 1.0        // Perfect anticipation
        }
    }
}

// MARK: - AI Player

class PendulumAIPlayer {
    
    // Configuration
    var skillLevel: AISkillLevel = .intermediate
    var humanErrorEnabled: Bool = true
    var learningEnabled: Bool = false
    var adaptiveStrategy: Bool = true
    
    // State tracking
    private var lastActionTime: Date?
    private var reactionTimer: Timer?
    private var isPlaying: Bool = false
    private var pendingAction: PendingAction?
    
    // Performance tracking for learning
    private var successfulActions: Int = 0
    private var totalActions: Int = 0
    private var currentStrategy: ControlStrategy = .reactive
    
    // Callbacks
    var onPushLeft: (() -> Void)?
    var onPushRight: (() -> Void)?
    
    // Control strategies
    enum ControlStrategy {
        case reactive      // React to current state
        case predictive    // Predict future state
        case aggressive    // Strong corrections
        case gentle        // Minimal corrections
    }
    
    struct PendingAction {
        let direction: PushDirection
        let scheduledTime: Date
        let magnitude: Double
    }
    
    // MARK: - Initialization
    
    init(skillLevel: AISkillLevel = .intermediate) {
        self.skillLevel = skillLevel
    }
    
    // MARK: - Public Interface
    
    /// Start the AI player
    func startPlaying() {
        isPlaying = true
        lastActionTime = Date()
        
        // Reset performance tracking
        successfulActions = 0
        totalActions = 0
    }
    
    /// Stop the AI player
    func stopPlaying() {
        isPlaying = false
        reactionTimer?.invalidate()
        reactionTimer = nil
        pendingAction = nil
    }
    
    /// Update the AI with current pendulum state
    func updatePendulumState(angle: Double, angleVelocity: Double, time: Double) {
        guard isPlaying else { return }
        
        // Calculate the optimal action
        let optimalAction = calculateOptimalAction(
            angle: angle,
            angleVelocity: angleVelocity,
            time: time
        )
        
        // Apply human error if enabled
        let finalAction = humanErrorEnabled ? applyHumanError(to: optimalAction) : optimalAction
        
        // Schedule the action with reaction time
        scheduleAction(finalAction)
    }
    
    /// Notify AI of successful balance (for learning)
    func notifyBalanceSuccess() {
        if learningEnabled {
            successfulActions += 1
            updateStrategy()
        }
    }
    
    /// Notify AI of balance failure (for learning)
    func notifyBalanceFailure() {
        if learningEnabled {
            updateStrategy()
        }
    }
    
    // MARK: - Core AI Logic
    
    private func calculateOptimalAction(angle: Double, angleVelocity: Double, time: Double) -> PendingAction {
        // Normalize angle to [-π, π]
        let normalizedAngle = atan2(sin(angle), cos(angle))
        let angleFromVertical = normalizedAngle - Double.pi
        
        // Predict future state based on current velocity
        let anticipation = skillLevel.anticipationFactor
        let predictedAngle = angleFromVertical + angleVelocity * anticipation * 0.2  // More lookahead (was 0.1)
        
        // Determine control strategy
        let strategy = adaptiveStrategy ? selectStrategy(angle: angleFromVertical, velocity: angleVelocity) : currentStrategy
        
        // Calculate required force
        let (direction, magnitude) = calculateControl(
            angle: predictedAngle,
            velocity: angleVelocity,
            strategy: strategy
        )
        
        // Determine action timing
        let reactionTime = calculateReactionTime(urgency: abs(angleFromVertical))
        let scheduledTime = Date().addingTimeInterval(reactionTime)
        
        totalActions += 1
        
        return PendingAction(
            direction: direction,
            scheduledTime: scheduledTime,
            magnitude: magnitude
        )
    }
    
    private func calculateControl(angle: Double, velocity: Double, strategy: ControlStrategy) -> (PushDirection, Double) {
        // Basic physics constants (should match game physics)
        let gravity = 9.81
        let length = 3.0
        let damping = 0.1
        
        // Calculate natural frequency
        let omega0 = sqrt(gravity / length)
        
        // PD controller coefficients (tuned for each strategy)
        let (kp, kd) = getControlGains(strategy: strategy, omega0: omega0)
        
        // Calculate control force using PD control
        let controlForce = -kp * angle - kd * velocity
        
        // Determine direction and magnitude
        let direction: PushDirection
        let magnitude: Double
        
        if abs(controlForce) < 0.02 {  // Much lower threshold (was 0.1)
            // No action needed
            direction = .none
            magnitude = 0.0
        } else if controlForce > 0 {
            direction = .right
            magnitude = min(abs(controlForce) * 1.5, 4.0) // Stronger forces (was 3.0)
        } else {
            direction = .left
            magnitude = min(abs(controlForce) * 1.5, 4.0) // Stronger forces (was 3.0)
        }
        
        // Apply skill-based force accuracy
        let accurateMagnitude = magnitude * skillLevel.forceAccuracy
        
        return (direction, accurateMagnitude)
    }
    
    private func getControlGains(strategy: ControlStrategy, omega0: Double) -> (kp: Double, kd: Double) {
        switch strategy {
        case .reactive:
            // More responsive gains
            return (kp: 3.0 * omega0 * omega0, kd: 2.5 * omega0)
            
        case .predictive:
            // Higher derivative gain for anticipation
            return (kp: 2.5 * omega0 * omega0, kd: 3.5 * omega0)
            
        case .aggressive:
            // Much stronger control
            return (kp: 4.0 * omega0 * omega0, kd: 3.0 * omega0)
            
        case .gentle:
            // Still responsive but smoother
            return (kp: 1.5 * omega0 * omega0, kd: 2.0 * omega0)
        }
    }
    
    private func selectStrategy(angle: Double, velocity: Double) -> ControlStrategy {
        // Dynamic strategy selection based on state
        let absAngle = abs(angle)
        let absVelocity = abs(velocity)
        
        if absAngle > 0.3 {  // Lower threshold (was 0.5)
            // Large angle - need aggressive control
            return .aggressive
        } else if absAngle < 0.05 && absVelocity < 0.3 {  // Tighter equilibrium
            // Near equilibrium - gentle touches
            return .gentle
        } else if absVelocity > 0.7 {  // Lower velocity threshold (was 1.0)
            // High velocity - need predictive control
            return .predictive
        } else {
            // Default reactive control - but more active
            return .reactive
        }
    }
    
    private func calculateReactionTime(urgency: Double) -> Double {
        let baseReactionTime = Double.random(in: skillLevel.reactionTimeRange)
        
        // Faster reaction for more urgent situations
        let urgencyFactor = 1.0 - min(urgency / 0.5, 0.5) // Up to 50% faster
        
        return baseReactionTime * urgencyFactor
    }
    
    // MARK: - Human Error Simulation
    
    private func applyHumanError(to action: PendingAction) -> PendingAction {
        var modifiedAction = action
        
        // Random error chance
        if Double.random(in: 0...1) < skillLevel.errorRate {
            let errorType = Int.random(in: 0...3)
            
            switch errorType {
            case 0:
                // Wrong direction error
                if action.direction == .left {
                    modifiedAction = PendingAction(
                        direction: .right,
                        scheduledTime: action.scheduledTime,
                        magnitude: action.magnitude * 0.7
                    )
                } else if action.direction == .right {
                    modifiedAction = PendingAction(
                        direction: .left,
                        scheduledTime: action.scheduledTime,
                        magnitude: action.magnitude * 0.7
                    )
                }
                
            case 1:
                // Magnitude error
                let errorFactor = Double.random(in: 0.5...1.5)
                modifiedAction = PendingAction(
                    direction: action.direction,
                    scheduledTime: action.scheduledTime,
                    magnitude: action.magnitude * errorFactor
                )
                
            case 2:
                // Timing error
                let timingError = Double.random(in: -0.1...0.1)
                modifiedAction = PendingAction(
                    direction: action.direction,
                    scheduledTime: action.scheduledTime.addingTimeInterval(timingError),
                    magnitude: action.magnitude
                )
                
            default:
                // Missed action
                modifiedAction = PendingAction(
                    direction: .none,
                    scheduledTime: action.scheduledTime,
                    magnitude: 0
                )
            }
        }
        
        // Add natural variance
        if modifiedAction.direction != .none {
            let variance = Double.random(in: 0.9...1.1)
            modifiedAction = PendingAction(
                direction: modifiedAction.direction,
                scheduledTime: modifiedAction.scheduledTime,
                magnitude: modifiedAction.magnitude * variance
            )
        }
        
        return modifiedAction
    }
    
    // MARK: - Action Scheduling
    
    private func scheduleAction(_ action: PendingAction) {
        // Cancel any pending action
        reactionTimer?.invalidate()
        
        // Don't schedule if no action needed
        guard action.direction != .none else { return }
        
        // Check if we're pushing too frequently
        if let lastTime = lastActionTime {
            let timeSinceLastAction = Date().timeIntervalSince(lastTime)
            if timeSinceLastAction < 0.05 { // Faster actions (was 0.1)
                return
            }
        }
        
        // Calculate delay until action
        let delay = action.scheduledTime.timeIntervalSinceNow
        
        if delay <= 0 {
            // Execute immediately
            executeAction(action)
        } else {
            // Schedule for later
            pendingAction = action
            reactionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.executeAction(action)
            }
        }
    }
    
    private func executeAction(_ action: PendingAction) {
        guard isPlaying else { return }
        
        lastActionTime = Date()
        
        switch action.direction {
        case .left:
            onPushLeft?()
        case .right:
            onPushRight?()
        case .none:
            break
        }
        
        pendingAction = nil
    }
    
    // MARK: - Learning System
    
    private func updateStrategy() {
        let successRate = totalActions > 0 ? Double(successfulActions) / Double(totalActions) : 0
        
        // Adjust strategy based on performance
        if successRate < 0.3 {
            // Poor performance - try different strategy
            switch currentStrategy {
            case .reactive:
                currentStrategy = .predictive
            case .predictive:
                currentStrategy = .aggressive
            case .aggressive:
                currentStrategy = .gentle
            case .gentle:
                currentStrategy = .reactive
            }
        }
        
        // Reset counters periodically
        if totalActions > 100 {
            successfulActions = Int(Double(successfulActions) * 0.8)
            totalActions = Int(Double(totalActions) * 0.8)
        }
    }
}

// MARK: - AI Player Manager

class PendulumAIManager {
    static let shared = PendulumAIManager()
    
    internal var aiPlayer: PendulumAIPlayer?
    internal var updateTimer: Timer?
    weak var viewModel: PendulumViewModel? // Made public for AI testing
    internal var currentMode: AIMode = .demo
    private var isAssisting: Bool = false
    private var competitionScore: Int = 0
    internal var tutorialStep: Int = 0
    
    // AI Modes
    enum AIMode {
        case demo      // AI plays on its own
        case assist    // AI helps when player struggles
        case compete   // Player vs AI competition
        case tutorial  // AI guides through basics
    }
    
    private init() {}
    
    /// Start AI playing with specified skill level and mode
    func startAIPlayer(skillLevel: AISkillLevel, viewModel: PendulumViewModel, mode: AIMode = .demo) {
        self.viewModel = viewModel
        self.currentMode = mode
        
        // Configure AI based on mode
        switch mode {
        case .demo:
            // AI plays autonomously
            aiPlayer = PendulumAIPlayer(skillLevel: skillLevel)
            aiPlayer?.humanErrorEnabled = true
            
        case .assist:
            // AI helps when needed
            aiPlayer = PendulumAIPlayer(skillLevel: .expert)
            aiPlayer?.humanErrorEnabled = false
            isAssisting = false // Only assist when needed
            
        case .compete:
            // AI plays at specified skill level
            aiPlayer = PendulumAIPlayer(skillLevel: skillLevel)
            aiPlayer?.humanErrorEnabled = true
            competitionScore = 0
            
        case .tutorial:
            // Use enhanced tutorial mode
            startEnhancedTutorial(viewModel: viewModel)
            return
        }
        
        // Set up callbacks based on mode
        setupAICallbacks()
        
        // Start playing for demo and compete modes
        if mode == .demo || mode == .compete {
            aiPlayer?.startPlaying()
        }
        
        // Start update loop with faster updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { [weak self] _ in
            self?.updateAI()
        }
    }
    
    private func setupAICallbacks() {
        switch currentMode {
        case .demo, .compete:
            // AI controls directly
            aiPlayer?.onPushLeft = { [weak self] in
                print("🔵 AI PUSHING LEFT (force: -4.0)")
                self?.viewModel?.applyForce(-4.0)  // Stronger force (was -3.0)
                self?.showAIActionIndicator(direction: PushDirection.left)
            }
            
            aiPlayer?.onPushRight = { [weak self] in
                print("🔴 AI PUSHING RIGHT (force: 4.0)")
                self?.viewModel?.applyForce(4.0)  // Stronger force (was 3.0)
                self?.showAIActionIndicator(direction: PushDirection.right)
            }
            
        case .assist:
            // AI only assists when needed
            aiPlayer?.onPushLeft = { [weak self] in
                if self?.isAssisting == true {
                    print("🔵 AI ASSIST LEFT (force: -4.0)")
                    self?.viewModel?.applyForce(-4.0)  // Stronger assistance (was -3.0)
                    self?.showAIAssistIndicator(direction: PushDirection.left)
                }
            }
            
            aiPlayer?.onPushRight = { [weak self] in
                if self?.isAssisting == true {
                    print("🔴 AI ASSIST RIGHT (force: 4.0)")
                    self?.viewModel?.applyForce(4.0)  // Stronger assistance (was 3.0)
                    self?.showAIAssistIndicator(direction: PushDirection.right)
                }
            }
            
        case .tutorial:
            // AI provides guidance
            aiPlayer?.onPushLeft = { [weak self] in
                self?.showTutorialHint(direction: PushDirection.left)
            }
            
            aiPlayer?.onPushRight = { [weak self] in
                self?.showTutorialHint(direction: PushDirection.right)
            }
        }
    }
    
    /// Stop AI player
    func stopAIPlayer() {
        aiPlayer?.stopPlaying()
        aiPlayer = nil
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    /// Check if AI is currently playing
    func isAIPlaying() -> Bool {
        return aiPlayer != nil
    }
    
    private func updateAI() {
        guard let viewModel = viewModel,
              let aiPlayer = aiPlayer else { return }
        
        // Get current pendulum state
        let state = viewModel.currentState
        
        // Update AI with current state
        aiPlayer.updatePendulumState(
            angle: state.theta,
            angleVelocity: state.thetaDot,
            time: state.time
        )
        
        // Handle mode-specific logic
        switch currentMode {
        case .assist:
            // Check if player needs assistance
            let angleFromVertical = abs(atan2(sin(state.theta), cos(state.theta)) - Double.pi)
            if angleFromVertical > 0.35 && !isAssisting {  // Earlier assistance (was 0.5)
                // Player is struggling, start assisting
                isAssisting = true
                aiPlayer.startPlaying()
                showAssistanceStarted()
            } else if angleFromVertical < 0.15 && isAssisting {  // Tighter recovery (was 0.2)
                // Player has recovered, stop assisting
                isAssisting = false
                aiPlayer.stopPlaying()
                showAssistanceStopped()
            }
            
        case .compete:
            // Track AI's performance for competition
            if state.time.truncatingRemainder(dividingBy: 1.0) < 0.05 {
                competitionScore += 1
                updateCompetitionDisplay()
            }
            
        case .tutorial:
            // Provide tutorial guidance
            checkTutorialProgress(state: state)
            
        default:
            break
        }
        
        // Notify AI of balance status
        let angleFromVertical = abs(atan2(sin(state.theta), cos(state.theta)) - Double.pi)
        if angleFromVertical < 0.15 {
            aiPlayer.notifyBalanceSuccess()
        } else if angleFromVertical > 1.5 {
            aiPlayer.notifyBalanceFailure()
        }
    }
    
    // MARK: - Visualization Methods
    
    private func showAIActionIndicator(direction: PushDirection) {
        NotificationCenter.default.post(
            name: Notification.Name("AIActionIndicator"),
            object: nil,
            userInfo: [
                "direction": direction == PushDirection.left ? "left" : "right",
                "mode": "demo"
            ]
        )
    }
    
    private func showAIAssistIndicator(direction: PushDirection) {
        NotificationCenter.default.post(
            name: Notification.Name("AIActionIndicator"),
            object: nil,
            userInfo: [
                "direction": direction == PushDirection.left ? "left" : "right",
                "mode": "assist"
            ]
        )
    }
    
    private func showTutorialHint(direction: PushDirection) {
        NotificationCenter.default.post(
            name: Notification.Name("AITutorialHint"),
            object: nil,
            userInfo: [
                "direction": direction == PushDirection.left ? "left" : "right",
                "step": tutorialStep
            ]
        )
    }
    
    private func showAssistanceStarted() {
        NotificationCenter.default.post(
            name: Notification.Name("AIAssistanceStatus"),
            object: nil,
            userInfo: ["status": "started"]
        )
    }
    
    private func showAssistanceStopped() {
        NotificationCenter.default.post(
            name: Notification.Name("AIAssistanceStatus"),
            object: nil,
            userInfo: ["status": "stopped"]
        )
    }
    
    private func updateCompetitionDisplay() {
        NotificationCenter.default.post(
            name: Notification.Name("AICompetitionUpdate"),
            object: nil,
            userInfo: ["aiScore": competitionScore]
        )
    }
    
    private func checkTutorialProgress(state: PendulumState) {
        // Check tutorial milestones
        let angleFromVertical = abs(atan2(sin(state.theta), cos(state.theta)) - Double.pi)
        
        switch tutorialStep {
        case 0:
            // Step 1: Get pendulum upright
            if angleFromVertical < 0.3 {
                tutorialStep = 1
                showTutorialProgress(message: "Great! Now try to keep it balanced.")
            }
        case 1:
            // Step 2: Keep balanced for 5 seconds
            if state.time > 5.0 && angleFromVertical < 0.3 {
                tutorialStep = 2
                showTutorialProgress(message: "Excellent! Now try using gentler pushes.")
            }
        case 2:
            // Step 3: Use minimal force
            if state.time > 10.0 {
                tutorialStep = 3
                showTutorialProgress(message: "You're doing great! Keep practicing!")
            }
        default:
            break
        }
    }
    
    private func showTutorialProgress(message: String) {
        NotificationCenter.default.post(
            name: Notification.Name("AITutorialProgress"),
            object: nil,
            userInfo: ["message": message]
        )
    }
}