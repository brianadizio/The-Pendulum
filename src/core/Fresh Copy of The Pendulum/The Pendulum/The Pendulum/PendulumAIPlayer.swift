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
        case .beginner: return 0.08...0.15     // Much faster reactions for frequent touches
        case .intermediate: return 0.06...0.12 // Rapid response time
        case .advanced: return 0.04...0.08     // Very quick reactions
        case .expert: return 0.02...0.05       // Near instant response
        case .perfect: return 0.01...0.03      // Fastest possible reaction
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
        case .beginner: return 0.7       // Lighter touches with some variance
        case .intermediate: return 0.75   // More consistent light touches
        case .advanced: return 0.85      // Precise lighter forces
        case .expert: return 0.92        // Very accurate light touches
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
    
    // Sequential push tracking for human-like patterns
    private var pushSequence: [PushDirection] = []
    private var sequenceStartTime: Date?
    private var currentSequenceCount: Int = 0
    
    // Human-like control patterns
    private var lastPushMagnitude: Double = 0
    private var anticipatoryPushCount: Int = 0
    private var isInRecoveryMode: Bool = false
    
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
        case rhythmic      // Human-like rhythmic tapping
        case microControl  // Very small, frequent adjustments
        case sequential    // Multiple pushes in same direction like humans
    }
    
    struct PendingAction {
        let direction: PushDirection
        let scheduledTime: Date
        let magnitude: Double
        let isAnticipatory: Bool // For human-like early corrections
        
        init(direction: PushDirection, scheduledTime: Date, magnitude: Double, isAnticipatory: Bool = false) {
            self.direction = direction
            self.scheduledTime = scheduledTime
            self.magnitude = magnitude
            self.isAnticipatory = isAnticipatory
        }
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
        
        // Check if pendulum has fallen (past ±75 degrees from vertical)
        let normalizedAngle = atan2(sin(angle), cos(angle))
        let angleFromVertical = abs(normalizedAngle - Double.pi)
        
        if angleFromVertical > 1.309 { // 75 degrees in radians
            // Pendulum has fallen - AI should not try to push
            // Cancel any pending actions
            reactionTimer?.invalidate()
            pendingAction = nil
            return
        }
        
        // Check for anticipatory push opportunity (human-like early correction)
        if shouldMakeAnticipatoryPush(angle: angle, angleVelocity: angleVelocity) {
            let anticipatoryAction = createAnticipatoryAction(angle: angle, angleVelocity: angleVelocity)
            scheduleAction(anticipatoryAction)
            return
        }
        
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
            magnitude: magnitude,
            isAnticipatory: false
        )
    }
    
    private func calculateControl(angle: Double, velocity: Double, strategy: ControlStrategy) -> (PushDirection, Double) {
        // Basic physics constants (should match game physics)
        let gravity = 9.81
        let length = 3.0
        
        // Calculate natural frequency
        let omega0 = sqrt(gravity / length)
        
        // PD controller coefficients (tuned for each strategy)
        let (kp, kd) = getControlGains(strategy: strategy, omega0: omega0)
        
        // Calculate control force using PD control
        // When pendulum tilts right (positive angle), we need negative force (push left) to correct
        let controlForce = -kp * angle - kd * velocity
        
        // Determine direction and magnitude
        let direction: PushDirection
        let magnitude: Double
        
        if abs(controlForce) < 0.005 {  // Ultra-low threshold for maximum responsiveness
            // No action needed
            direction = .none
            magnitude = 0.0
        } else if controlForce > 0 {
            direction = .right
            // Much lighter forces - like gentle taps
            let baseMagnitude = min(abs(controlForce) * 0.3, 0.8)  // Reduced from 0.6 and 1.5
            magnitude = applyForceRamping(baseMagnitude: baseMagnitude, direction: direction)
        } else {
            direction = .left
            let baseMagnitude = min(abs(controlForce) * 0.3, 0.8)  // Much lighter touches
            magnitude = applyForceRamping(baseMagnitude: baseMagnitude, direction: direction)
        }
        
        // Apply skill-based force accuracy
        let accurateMagnitude = magnitude * skillLevel.forceAccuracy
        
        return (direction, accurateMagnitude)
    }
    
    private func applyForceRamping(baseMagnitude: Double, direction: PushDirection) -> Double {
        // Human-like force ramping - very light touches with gradual increase
        var rampedMagnitude = baseMagnitude
        
        // Sequential pushes - gradually increase force like humans do
        if !pushSequence.isEmpty && pushSequence.last == direction {
            let rampFactor = min(1.0 + (Double(currentSequenceCount) * 0.05), 1.2)  // Gentler ramping
            rampedMagnitude *= rampFactor
        } else {
            // New direction - start very light
            rampedMagnitude *= 0.6  // Even lighter start
        }
        
        // Recovery mode - slightly stronger but still gentle
        if isInRecoveryMode {
            rampedMagnitude *= 1.15  // Reduced from 1.3
        }
        
        // Apply micro-adjustments for human-like variation
        let microVariation = Double.random(in: 0.9...1.1)
        rampedMagnitude *= microVariation
        
        // Store for next comparison
        lastPushMagnitude = rampedMagnitude
        
        return rampedMagnitude
    }
    
    private func getControlGains(strategy: ControlStrategy, omega0: Double) -> (kp: Double, kd: Double) {
        switch strategy {
        case .reactive:
            // Lighter, more frequent corrections
            return (kp: 2.0 * omega0 * omega0, kd: 1.8 * omega0)
            
        case .predictive:
            // Anticipatory but gentle
            return (kp: 1.8 * omega0 * omega0, kd: 2.5 * omega0)
            
        case .aggressive:
            // Stronger but still controlled
            return (kp: 2.5 * omega0 * omega0, kd: 2.0 * omega0)
            
        case .gentle:
            // Very light touches
            return (kp: 1.2 * omega0 * omega0, kd: 1.5 * omega0)
            
        case .rhythmic:
            // Human-like tapping pattern
            return (kp: 1.5 * omega0 * omega0, kd: 1.8 * omega0)
            
        case .microControl:
            // Many tiny adjustments
            return (kp: 2.5 * omega0 * omega0, kd: 1.2 * omega0)
            
        case .sequential:
            // Multiple light pushes in sequence
            return (kp: 1.6 * omega0 * omega0, kd: 1.6 * omega0)
        }
    }
    
    private func selectStrategy(angle: Double, velocity: Double) -> ControlStrategy {
        // Dynamic strategy selection based on state
        let absAngle = abs(angle)
        let absVelocity = abs(velocity)
        
        // Update recovery mode status
        isInRecoveryMode = absAngle > 0.25 || absVelocity > 1.0
        
        // Check if we should continue a sequential pattern
        if shouldContinueSequence(angle: angle, velocity: velocity) {
            return .sequential
        }
        
        if absAngle > 0.3 {  // Large angle - need strong control
            return .aggressive
        } else if absAngle < 0.03 && absVelocity < 0.2 {  // Very close to balance
            // Use micro control - many tiny taps
            return .microControl
        } else if absAngle < 0.1 && absVelocity < 0.4 {  // Near equilibrium
            // Check if we should start a sequential pattern
            if shouldStartSequence(angle: angle, velocity: velocity) {
                return .sequential
            }
            // Use rhythmic tapping like humans
            return .rhythmic
        } else if absVelocity > 0.7 {  // High velocity
            return .predictive
        } else if absAngle < 0.2 {  // Medium angle
            return .gentle
        } else {
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
                        magnitude: action.magnitude * 0.7,
                        isAnticipatory: action.isAnticipatory
                    )
                } else if action.direction == .right {
                    modifiedAction = PendingAction(
                        direction: .left,
                        scheduledTime: action.scheduledTime,
                        magnitude: action.magnitude * 0.7,
                        isAnticipatory: action.isAnticipatory
                    )
                }
                
            case 1:
                // Magnitude error
                let errorFactor = Double.random(in: 0.5...1.5)
                modifiedAction = PendingAction(
                    direction: action.direction,
                    scheduledTime: action.scheduledTime,
                    magnitude: action.magnitude * errorFactor,
                    isAnticipatory: action.isAnticipatory
                )
                
            case 2:
                // Timing error
                let timingError = Double.random(in: -0.1...0.1)
                modifiedAction = PendingAction(
                    direction: action.direction,
                    scheduledTime: action.scheduledTime.addingTimeInterval(timingError),
                    magnitude: action.magnitude,
                    isAnticipatory: action.isAnticipatory
                )
                
            default:
                // Missed action
                modifiedAction = PendingAction(
                    direction: .none,
                    scheduledTime: action.scheduledTime,
                    magnitude: 0,
                    isAnticipatory: action.isAnticipatory
                )
            }
        }
        
        // Add natural variance
        if modifiedAction.direction != .none {
            let variance = Double.random(in: 0.9...1.1)
            modifiedAction = PendingAction(
                direction: modifiedAction.direction,
                scheduledTime: modifiedAction.scheduledTime,
                magnitude: modifiedAction.magnitude * variance,
                isAnticipatory: modifiedAction.isAnticipatory
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
            if timeSinceLastAction < 0.01 { // Allow extremely rapid taps (100Hz)
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
        
        // Track push sequence for human-like patterns
        if action.direction != .none {
            updatePushSequence(direction: action.direction)
        }
        
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
    
    // MARK: - Sequential Push Patterns
    
    private func shouldStartSequence(angle: Double, velocity: Double) -> Bool {
        // Start a sequence if we're moving steadily in one direction
        // and haven't pushed recently
        guard let lastTime = lastActionTime else { return false }
        let timeSinceLastPush = Date().timeIntervalSince(lastTime)
        
        // Allow quicker sequence starts for more human-like control
        if timeSinceLastPush < 0.15 { return false }
        
        // Check if pendulum is moving consistently in one direction
        let movingRight = angle > 0.05 && velocity > 0.1
        let movingLeft = angle < -0.05 && velocity < -0.1
        
        return movingRight || movingLeft
    }
    
    private func shouldContinueSequence(angle: Double, velocity: Double) -> Bool {
        // Continue sequence if we're still in the middle of one
        guard !pushSequence.isEmpty,
              let startTime = sequenceStartTime else { return false }
        
        // Sequences can last longer for sustained corrections
        if Date().timeIntervalSince(startTime) > 0.8 { 
            resetSequence()
            return false 
        }
        
        // Continue if we're still moving in the same general direction
        let lastDirection = pushSequence.last!
        let stillNeedsCorrection: Bool
        
        if lastDirection == .left {
            stillNeedsCorrection = angle > 0.03 // Still tilting right
        } else {
            stillNeedsCorrection = angle < -0.03 // Still tilting left
        }
        
        return stillNeedsCorrection && currentSequenceCount < 8 // Allow more pushes per sequence
    }
    
    private func updatePushSequence(direction: PushDirection) {
        // If starting a new sequence or changing direction
        if pushSequence.isEmpty || pushSequence.last != direction {
            resetSequence()
            sequenceStartTime = Date()
        }
        
        pushSequence.append(direction)
        currentSequenceCount += 1
    }
    
    private func resetSequence() {
        pushSequence.removeAll()
        sequenceStartTime = nil
        currentSequenceCount = 0
    }
    
    // MARK: - Anticipatory Push Logic
    
    private func shouldMakeAnticipatoryPush(angle: Double, angleVelocity: Double) -> Bool {
        // Only make anticipatory pushes at higher skill levels
        guard skillLevel == .expert || skillLevel == .perfect else { return false }
        
        // Don't make too many anticipatory pushes
        if anticipatoryPushCount > 2 { return false }
        
        // Check if we have enough time since last action
        guard let lastTime = lastActionTime else { return false }
        if Date().timeIntervalSince(lastTime) < 0.1 { return false }
        
        // Make anticipatory push if pendulum is starting to move away from vertical
        let normalizedAngle = atan2(sin(angle), cos(angle)) - Double.pi
        let absAngle = abs(normalizedAngle)
        
        // More sensitive anticipation for early corrections
        let needsAnticipation = absAngle < 0.08 && abs(angleVelocity) > 0.1 && 
                               (normalizedAngle * angleVelocity > 0) // Moving away from vertical
        
        return needsAnticipation
    }
    
    private func createAnticipatoryAction(angle: Double, angleVelocity: Double) -> PendingAction {
        // Very light anticipatory tap in opposite direction of motion
        let direction: PushDirection = angleVelocity > 0 ? .left : .right
        let magnitude = 0.25 // Extremely light touch
        
        anticipatoryPushCount += 1
        
        // Reset count after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.anticipatoryPushCount = max(0, (self?.anticipatoryPushCount ?? 1) - 1)
        }
        
        return PendingAction(
            direction: direction,
            scheduledTime: Date().addingTimeInterval(0.02), // Very quick reaction
            magnitude: magnitude,
            isAnticipatory: true
        )
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
                currentStrategy = .rhythmic
            case .rhythmic:
                currentStrategy = .microControl
            case .microControl:
                currentStrategy = .sequential
            case .sequential:
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
        
        // Start update loop with much faster updates for rapid corrections
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateAI()
        }
    }
    
    private func setupAICallbacks() {
        switch currentMode {
        case .demo, .compete:
            // AI controls directly
            aiPlayer?.onPushLeft = { [weak self] in
                // Apply lighter force based on AI's calculated magnitude
                let force = -2.0  // Much lighter base force
                self?.viewModel?.applyForce(force)
                self?.showAIActionIndicator(direction: PushDirection.left)
            }
            
            aiPlayer?.onPushRight = { [weak self] in
                // Apply lighter force
                let force = 2.0  // Much lighter base force
                self?.viewModel?.applyForce(force)
                self?.showAIActionIndicator(direction: PushDirection.right)
            }
            
        case .assist:
            // AI only assists when needed
            aiPlayer?.onPushLeft = { [weak self] in
                if self?.isAssisting == true {
                    self?.viewModel?.applyForce(-2.0)  // Lighter assistance
                    self?.showAIAssistIndicator(direction: PushDirection.left)
                }
            }
            
            aiPlayer?.onPushRight = { [weak self] in
                if self?.isAssisting == true {
                    self?.viewModel?.applyForce(2.0)  // Lighter assistance
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