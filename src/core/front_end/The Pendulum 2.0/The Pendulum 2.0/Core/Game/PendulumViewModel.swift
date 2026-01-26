// PendulumViewModel.swift
// The Pendulum 2.0
// Game state management and physics integration

import Foundation
import Combine
import QuartzCore
import UIKit

class PendulumViewModel: ObservableObject {
    // Physics model
    private var model: InvertedPendulumModel

    // Published state
    @Published private(set) var currentState: PendulumState = .zero
    @Published private(set) var isSimulating: Bool = false
    @Published private(set) var score: Int = 0
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var balanceProgress: Double = 0.0

    // Balance tracking
    private var balanceStartTime: Date?
    private var requiredBalanceTime: TimeInterval = 1.5
    private var balanceThreshold: Double = 0.35 // radians

    // Timer for simulation
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0

    // Level manager reference
    weak var levelManager: LevelManager?

    // Callbacks
    var onStateUpdate: ((PendulumState) -> Void)?
    var onLevelComplete: ((Int) -> Void)?
    var onFall: (() -> Void)?  // Called when pendulum falls past 90 degrees from upright

    // Fall threshold - pendulum has fallen if more than 90 degrees from upright (π)
    // Upright is θ = π, so fallen is when |θ - π| > π/2
    private let fallThreshold: Double = .pi / 2

    init() {
        model = InvertedPendulumModel()
    }

    // MARK: - Parameter Updates

    func updateParameters(mass: Double, length: Double, gravity: Double, damping: Double, springConstant: Double, momentOfInertia: Double = 1.0) {
        model.mass = mass
        model.length = length
        model.gravity = gravity
        model.damping = damping
        model.springConstant = springConstant
        model.momentOfInertia = momentOfInertia
    }

    func applyLevelConfig(_ config: LevelConfig) {
        model.mass = LevelManager.baseMass * config.massMultiplier
        model.length = LevelManager.baseLength * config.lengthMultiplier
        model.gravity = LevelManager.baseGravity * config.gravityMultiplier
        model.damping = config.dampingValue
        model.springConstant = config.springConstantValue

        balanceThreshold = config.balanceThreshold
        requiredBalanceTime = config.balanceRequiredTime

        // Set initial perturbation from upright (π)
        // θ = π is upright, so we start at π + small offset
        let perturbationRadians = config.initialPerturbation * .pi / 180.0
        let direction: Double = Bool.random() ? 1.0 : -1.0
        model.reset(withAngle: .pi + perturbationRadians * direction)
    }

    // MARK: - Simulation Control

    func startSimulation() {
        guard !isSimulating else { return }

        isSimulating = true
        lastUpdateTime = CACurrentMediaTime()

        // Create display link for smooth updates
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }

    func pauseSimulation() {
        displayLink?.invalidate()
        displayLink = nil
        isSimulating = false
    }

    func reset() {
        pauseSimulation()
        model.reset()
        currentState = .zero
        score = 0
        elapsedTime = 0
        balanceProgress = 0.0
        balanceStartTime = nil
    }

    /// Reset with a small initial perturbation (pendulum starts slightly off-center from upright)
    /// In physics model: theta = π is upright, theta = 0 is hanging down
    func resetWithPerturbation(degrees: Double = 8.0) {
        pauseSimulation()
        let perturbationRadians = degrees * .pi / 180.0
        let direction: Double = Bool.random() ? 1.0 : -1.0
        // Start at π (upright) plus small perturbation
        model.reset(withAngle: .pi + perturbationRadians * direction)
        currentState = model.currentState
        score = 0
        elapsedTime = 0
        balanceProgress = 0.0
        balanceStartTime = nil
    }

    // MARK: - Force Application

    func applyForce(_ magnitude: Double) {
        guard isSimulating else { return }
        model.applyForce(magnitude)
        score += 1 // Score for each push
    }

    func applyExternalForce(_ force: Double) {
        guard isSimulating else { return }
        model.applyForce(force)
    }

    // MARK: - Update Loop

    @objc private func update() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Cap delta time to prevent large jumps
        let dt = min(deltaTime, 1.0 / 30.0)

        // Step physics
        model.step(dt: dt)
        elapsedTime += dt

        // Update published state
        currentState = model.currentState

        // Check if pendulum has fallen past 90 degrees from upright (π)
        // Upright is θ = π, so fallen is when |θ - π| > π/2
        if abs(currentState.theta - .pi) > fallThreshold {
            handleFall()
            return
        }

        // Check balance
        checkBalance()

        // Notify observers
        onStateUpdate?(currentState)
    }

    private func checkBalance() {
        // Upright is at θ = π, so check distance from π
        let isBalanced = abs(currentState.theta - .pi) < balanceThreshold

        if isBalanced {
            if balanceStartTime == nil {
                balanceStartTime = Date()
            }

            let balanceDuration = Date().timeIntervalSince(balanceStartTime!)
            balanceProgress = balanceDuration / requiredBalanceTime

            if balanceDuration >= requiredBalanceTime {
                // Level complete!
                handleLevelComplete()
            }
        } else {
            balanceStartTime = nil
            balanceProgress = 0.0
        }
    }

    private func handleLevelComplete() {
        let completedLevel = levelManager?.currentLevel ?? 1
        score += 100 * completedLevel // Bonus for level completion

        onLevelComplete?(completedLevel)

        // Reset balance tracking
        balanceStartTime = nil
        balanceProgress = 0.0
    }

    private func handleFall() {
        // Pause simulation when pendulum falls
        pauseSimulation()
        onFall?()
    }

    // MARK: - Computed Properties

    var angleDegrees: Double {
        currentState.theta * 180.0 / .pi
    }

    var angularVelocity: Double {
        currentState.thetaDot
    }

    var isWithinBalanceThreshold: Bool {
        // Upright is at θ = π, so check distance from π
        abs(currentState.theta - .pi) < balanceThreshold
    }

    // Calculate mechanical energy
    var totalEnergy: Double {
        let ke = 0.5 * model.mass * pow(model.length * currentState.thetaDot, 2)
        let pe = model.mass * model.gravity * model.length * (1 - cos(currentState.theta))
        return ke + pe
    }

    deinit {
        displayLink?.invalidate()
    }
}
