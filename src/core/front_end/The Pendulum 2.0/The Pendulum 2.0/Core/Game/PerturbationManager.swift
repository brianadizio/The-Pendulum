// PerturbationManager.swift
// The Pendulum 2.0
// Simplified perturbation system - external force generation

import Foundation
import Combine

// MARK: - Perturbation Types

enum PerturbationType {
    case impulse           // Instant force applied at random intervals
    case sine              // Continuous sinusoidal perturbation
    case dataSet           // Perturbation from loaded data files
    case random            // Random variation (noise-like)
    case compound          // Combination of multiple perturbation types
    case none              // No perturbations (Zen mode)
}

// MARK: - Perturbation Profile

struct PerturbationProfile {
    let name: String
    let types: [PerturbationType]
    let strength: Double       // Base strength multiplier
    let frequency: Double      // For periodic perturbations (Hz)
    let randomInterval: ClosedRange<Double>  // Time range between random perturbations
    let dataSource: String?    // Filename for data-driven perturbations
    var subProfiles: [PerturbationProfile]?

    // Factory method for level-specific profiles (rebalanced: levels 1-10 accessible)
    static func forLevel(_ level: Int) -> PerturbationProfile {
        switch level {
        case 1:
            return PerturbationProfile(
                name: "Gentle Breeze",
                types: [.impulse],
                strength: 0.15,
                frequency: 0.0,
                randomInterval: 5.0...8.0,
                dataSource: nil
            )

        case 2:
            return PerturbationProfile(
                name: "Moderate Wind",
                types: [.impulse],
                strength: 0.20,
                frequency: 0.0,
                randomInterval: 4.0...7.0,
                dataSource: nil
            )

        case 3:
            return PerturbationProfile(
                name: "Steady Push",
                types: [.impulse],
                strength: 0.25,
                frequency: 0.0,
                randomInterval: 4.0...6.0,
                dataSource: nil
            )

        case 4:
            return PerturbationProfile(
                name: "Rhythmic Current",
                types: [.impulse],
                strength: 0.30,
                frequency: 0.0,
                randomInterval: 3.5...6.0,
                dataSource: nil
            )

        case 5:
            return PerturbationProfile(
                name: "Ocean Waves",
                types: [.impulse, .sine],
                strength: 0.35,
                frequency: 0.15,
                randomInterval: 3.0...5.5,
                dataSource: nil
            )

        case 6:
            return PerturbationProfile(
                name: "Stormy Waters",
                types: [.impulse, .sine],
                strength: 0.40,
                frequency: 0.2,
                randomInterval: 3.0...5.0,
                dataSource: nil
            )

        case 7:
            return PerturbationProfile(
                name: "Seismic Tremors",
                types: [.sine, .impulse],
                strength: 0.50,
                frequency: 0.25,
                randomInterval: 2.5...4.5,
                dataSource: nil
            )

        case 8:
            return PerturbationProfile(
                name: "Chaotic Turbulence",
                types: [.sine, .impulse],
                strength: 0.60,
                frequency: 0.3,
                randomInterval: 2.0...4.0,
                dataSource: nil
            )

        case 9:
            return PerturbationProfile(
                name: "Wild Gusts",
                types: [.random, .impulse],
                strength: 0.70,
                frequency: 0.0,
                randomInterval: 2.0...3.5,
                dataSource: nil
            )

        case 10:
            return PerturbationProfile(
                name: "Perfect Storm",
                types: [.compound],
                strength: 0.80,
                frequency: 0.35,
                randomInterval: 1.5...3.0,
                dataSource: nil,
                subProfiles: [
                    PerturbationProfile(
                        name: "Base Sine",
                        types: [.sine],
                        strength: 0.5,
                        frequency: 0.3,
                        randomInterval: 0...0,
                        dataSource: nil
                    ),
                    PerturbationProfile(
                        name: "Random Gusts",
                        types: [.impulse],
                        strength: 0.8,
                        frequency: 0.0,
                        randomInterval: 1.5...3.0,
                        dataSource: nil
                    )
                ]
            )

        default:
            // Procedural generation for levels beyond 10 (lower base than before)
            let baseStrength = min(0.8 + Double(level - 10) * 0.08, 2.0)
            let baseFrequency = min(0.35 + Double(level - 10) * 0.05, 1.0)

            return PerturbationProfile(
                name: "Extreme Challenge \(level)",
                types: [.compound],
                strength: baseStrength,
                frequency: baseFrequency,
                randomInterval: max(0.5, 3.0 - Double(level - 10) * 0.1)...max(1.0, 3.5 - Double(level - 10) * 0.1),
                dataSource: nil,
                subProfiles: [
                    PerturbationProfile(
                        name: "Primary Wave",
                        types: [.sine],
                        strength: baseStrength * 0.8,
                        frequency: baseFrequency,
                        randomInterval: 0...0,
                        dataSource: nil
                    ),
                    PerturbationProfile(
                        name: "Impulse Bursts",
                        types: [.impulse],
                        strength: baseStrength * 1.2,
                        frequency: 0.0,
                        randomInterval: max(0.5, 2.0 - Double(level - 10) * 0.1)...max(1.0, 3.0 - Double(level - 10) * 0.1),
                        dataSource: nil
                    )
                ]
            )
        }
    }

    /// Progressive mode: impulse-only with gentle strength ramp.
    /// No sine or compound perturbations — difficulty comes from longer balance time.
    static func forProgressiveLevel(_ level: Int) -> PerturbationProfile {
        let strength = min(0.8, 0.10 + Double(level - 1) * 0.03)
        let intervalLow = max(2.5, 6.0 - Double(level) * 0.25)
        let intervalHigh = max(3.5, 8.0 - Double(level) * 0.25)
        return PerturbationProfile(
            name: "Progressive L\(level)",
            types: [.impulse],
            strength: strength,
            frequency: 0.0,
            randomInterval: intervalLow...intervalHigh,
            dataSource: nil
        )
    }

    // Zen mode - no perturbations
    static var zen: PerturbationProfile {
        PerturbationProfile(
            name: "Zen",
            types: [.none],
            strength: 0.0,
            frequency: 0.0,
            randomInterval: 0...0,
            dataSource: nil
        )
    }

    /// Jiggle mode - continuous per-frame random noise at given intensity
    /// Intensity ranges from ~0.3 (gentle) to ~1.5 (intense)
    static func jiggle(intensity: Double) -> PerturbationProfile {
        PerturbationProfile(
            name: "Jiggle (\(String(format: "%.1f", intensity)))",
            types: [.random],
            strength: intensity,
            frequency: 0.0,
            randomInterval: 0...0,
            dataSource: nil
        )
    }
}

// MARK: - Perturbation Manager

class PerturbationManager: ObservableObject {
    // Current active profile
    @Published private(set) var activeProfile: PerturbationProfile?

    /// Current pendulum angle — set by PendulumViewModel each frame.
    /// Default .pi (upright) is a safe fallback (full jiggle strength).
    var currentTheta: Double = .pi

    // Timing variables
    private var lastUpdateTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var timeUntilNextImpulse: TimeInterval = 0

    // Grace period: forces ramp from 0% to 100% over this duration (seconds)
    var gracePeriod: TimeInterval = 2.0
    private var graceTimeRemaining: TimeInterval = 0

    // Track if manager is active
    private var isActive: Bool = false

    // Callback when perturbation force should be applied
    var onApplyForce: ((Double) -> Void)?

    // Initialize with optional profile
    init(profile: PerturbationProfile? = nil) {
        if let profile = profile {
            activateProfile(profile)
        }
    }

    // Activate a perturbation profile
    func activateProfile(_ profile: PerturbationProfile) {
        activeProfile = profile
        elapsedTime = 0
        lastUpdateTime = 0
        graceTimeRemaining = gracePeriod
        resetImpulseTiming()
        isActive = true
    }

    // Stop perturbations
    func stop() {
        isActive = false
    }

    // Resume perturbations
    func resume() {
        isActive = true
        resetImpulseTiming()
        lastUpdateTime = 0
    }

    /// Scale perturbation strength by a factor (used by Golden Mode mid-session adaptation)
    func scaleIntensity(by factor: Double) {
        guard let profile = activeProfile else { return }
        let newStrength = max(0.05, min(5.0, profile.strength * factor))
        var scaled = PerturbationProfile(
            name: profile.name,
            types: profile.types,
            strength: newStrength,
            frequency: profile.frequency,
            randomInterval: profile.randomInterval,
            dataSource: profile.dataSource
        )
        scaled.subProfiles = profile.subProfiles
        activeProfile = scaled
    }

    // Reset to no perturbations
    func deactivate() {
        activeProfile = nil
        isActive = false
    }

    // Reset impulse timing
    private func resetImpulseTiming() {
        if let profile = activeProfile {
            timeUntilNextImpulse = Double.random(in: profile.randomInterval)
        }
    }

    // Update the perturbation manager - call this from game loop
    func update(currentTime: TimeInterval) {
        guard isActive, let profile = activeProfile else { return }

        // Skip if no perturbation types
        if profile.types.contains(.none) { return }

        // Calculate delta time
        let deltaTime: TimeInterval
        if lastUpdateTime == 0 {
            deltaTime = 0
        } else {
            deltaTime = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime

        // Skip very small time steps
        guard deltaTime > 0 && deltaTime < 1.0 else { return }

        elapsedTime += deltaTime

        // Count down grace period
        if graceTimeRemaining > 0 {
            graceTimeRemaining -= deltaTime
        }

        var totalForce: Double = 0.0

        // Process each perturbation type
        for type in profile.types {
            switch type {
            case .impulse:
                timeUntilNextImpulse -= deltaTime
                if timeUntilNextImpulse <= 0 {
                    // Apply impulse
                    let direction: Double = Bool.random() ? 1.0 : -1.0
                    let magnitude = profile.strength * Double.random(in: 0.8...1.2)
                    totalForce += direction * magnitude
                    resetImpulseTiming()
                }

            case .sine:
                // Continuous sinusoidal perturbation
                let sineValue = sin(2.0 * .pi * profile.frequency * elapsedTime)
                totalForce += sineValue * profile.strength * 0.5

            case .random:
                // Random noise with angle-dependent attenuation:
                // Full jiggle near upright (pi), reduced to 15% at 90 deg from upright
                let angleFromUpright = abs(currentTheta - .pi)
                let attenuation = max(0.15, 1.0 - (angleFromUpright / (.pi / 2.0)) * 0.85)
                let noise = Double.random(in: -1.0...1.0) * profile.strength * attenuation
                totalForce += noise

            case .compound:
                // Process sub-profiles
                if let subProfiles = profile.subProfiles {
                    for subProfile in subProfiles {
                        for subType in subProfile.types {
                            switch subType {
                            case .sine:
                                let sineValue = sin(2.0 * .pi * subProfile.frequency * elapsedTime)
                                totalForce += sineValue * subProfile.strength * 0.5
                            case .impulse:
                                // Sub-impulses handled separately with their own timing
                                break
                            case .random:
                                let angleFromUpright = abs(currentTheta - .pi)
                                let attenuation = max(0.15, 1.0 - (angleFromUpright / (.pi / 2.0)) * 0.85)
                                let noise = Double.random(in: -1.0...1.0) * subProfile.strength * attenuation
                                totalForce += noise
                            default:
                                break
                            }
                        }
                    }
                }

            case .dataSet:
                // Data-driven perturbations would load from CSV
                // Placeholder for now
                break

            case .none:
                break
            }
        }

        // Grace period ramp: scale forces from 0% → 100% over gracePeriod
        if graceTimeRemaining > 0 {
            let ramp = min(1.0, (gracePeriod - graceTimeRemaining) / gracePeriod)
            totalForce *= ramp
        }

        // Apply the combined force (low threshold to allow subtle jiggle noise through)
        if abs(totalForce) > 0.001 {
            onApplyForce?(totalForce)
        }
    }
}
