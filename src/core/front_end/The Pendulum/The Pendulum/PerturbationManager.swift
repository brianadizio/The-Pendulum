import Foundation
import SpriteKit

// MARK: - Perturbation Types

enum PerturbationType {
    case impulse           // Instant force applied at random intervals
    case sine              // Continuous sinusoidal perturbation
    case dataSet           // Perturbation from loaded data files
    case random            // Random variation (noise-like)
    case compound          // Combination of multiple perturbation types
}

// MARK: - Perturbation Profile

struct PerturbationProfile {
    let name: String
    let types: [PerturbationType]
    let strength: Double       // Base strength multiplier
    let frequency: Double      // For periodic perturbations (Hz)
    let randomInterval: ClosedRange<Double>  // Time range between random perturbations (seconds)
    let dataSource: String?    // Filename for data-driven perturbations
    let showWarnings: Bool     // Whether to show warnings for upcoming perturbations
    
    // Additional parameters for compound perturbations
    var subProfiles: [PerturbationProfile]?
    
    // Factory method for level-specific profiles
    static func forLevel(_ level: Int) -> PerturbationProfile {
        switch level {
        case 1:
            // Beginner level - gentle, predictable impulses
            return PerturbationProfile(
                name: "Gentle Breeze",
                types: [.impulse],
                strength: 0.3,
                frequency: 0.0,
                randomInterval: 4.0...6.0,
                dataSource: nil,
                showWarnings: true
            )
            
        case 2:
            // Level 2 - slightly stronger impulses
            return PerturbationProfile(
                name: "Moderate Wind",
                types: [.impulse],
                strength: 0.5,
                frequency: 0.0,
                randomInterval: 3.0...5.0,
                dataSource: nil,
                showWarnings: true
            )
            
        case 3:
            // Level 3 - gentle sine wave added
            return PerturbationProfile(
                name: "Rhythmic Current",
                types: [.impulse, .sine],
                strength: 0.6,
                frequency: 0.2,
                randomInterval: 3.0...5.0,
                dataSource: nil,
                showWarnings: true
            )
            
        case 4:
            // Level 4 - more pronounced sine wave
            return PerturbationProfile(
                name: "Ocean Waves",
                types: [.sine],
                strength: 0.7,
                frequency: 0.3,
                randomInterval: 3.0...4.0,
                dataSource: nil,
                showWarnings: true
            )
            
        case 5:
            // Level 5 - sine wave with occasional impulses
            return PerturbationProfile(
                name: "Stormy Waters",
                types: [.sine, .impulse],
                strength: 0.8,
                frequency: 0.4,
                randomInterval: 2.5...4.0,
                dataSource: nil,
                showWarnings: true
            )
            
        case 6:
            // Level 6 - introduce data-driven perturbations
            return PerturbationProfile(
                name: "Seismic Tremors",
                types: [.dataSet, .impulse],
                strength: 0.9,
                frequency: 0.0,
                randomInterval: 2.0...3.5,
                dataSource: "PerturbationData.csv",
                showWarnings: false
            )
            
        case 7:
            // Level 7 - random perturbations
            return PerturbationProfile(
                name: "Chaotic Turbulence",
                types: [.random],
                strength: 1.0,
                frequency: 0.0,
                randomInterval: 1.5...3.0,
                dataSource: nil,
                showWarnings: false
            )
            
        case 8...10:
            // Higher levels - compound perturbations
            return PerturbationProfile(
                name: "Perfect Storm",
                types: [.compound],
                strength: 1.0 + Double(level - 8) * 0.2,
                frequency: 0.5,
                randomInterval: 1.0...2.0,
                dataSource: "PerturbationData.csv",
                showWarnings: false,
                subProfiles: [
                    PerturbationProfile(
                        name: "Base Sine",
                        types: [.sine],
                        strength: 0.8,
                        frequency: 0.3,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Random Gusts",
                        types: [.impulse],
                        strength: 1.2,
                        frequency: 0.0,
                        randomInterval: 1.5...3.0,
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Background Noise",
                        types: [.random],
                        strength: 0.4,
                        frequency: 0.0,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    )
                ]
            )
            
        default:
            // For levels beyond 10, procedurally generate
            let baseStrength = min(1.0 + Double(level - 10) * 0.1, 2.0)
            let baseFrequency = min(0.5 + Double(level - 10) * 0.05, 1.0)
            
            return PerturbationProfile(
                name: "Extreme Challenge \(level)",
                types: [.compound],
                strength: baseStrength,
                frequency: baseFrequency,
                randomInterval: max(0.5, 3.0 - Double(level - 10) * 0.1)...max(1.0, 3.5 - Double(level - 10) * 0.1),
                dataSource: "PerturbationData.csv",
                showWarnings: false,
                subProfiles: [
                    PerturbationProfile(
                        name: "Primary Wave",
                        types: [.sine],
                        strength: baseStrength * 0.8,
                        frequency: baseFrequency,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Secondary Wave",
                        types: [.sine],
                        strength: baseStrength * 0.4,
                        frequency: baseFrequency * 2.0,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Impulse Bursts",
                        types: [.impulse],
                        strength: baseStrength * 1.2,
                        frequency: 0.0,
                        randomInterval: max(0.5, 2.0 - Double(level - 10) * 0.1)...max(1.0, 3.0 - Double(level - 10) * 0.1),
                        dataSource: nil,
                        showWarnings: false
                    ),
                    PerturbationProfile(
                        name: "Noise Layer",
                        types: [.random],
                        strength: baseStrength * 0.3,
                        frequency: 0.0,
                        randomInterval: 0...0,
                        dataSource: nil,
                        showWarnings: false
                    )
                ]
            )
        }
    }
    
    // Factory method for perturbation modes
    static func forMode(_ mode: Int) -> PerturbationProfile {
        switch mode {
        case 1:
            // Mode 1 - Joshua Tree (gravitational perturbations)
            return PerturbationProfile(
                name: "Joshua Tree",
                types: [.sine, .random],
                strength: 0.8,
                frequency: 0.3,
                randomInterval: 2.0...4.0,
                dataSource: nil,
                showWarnings: true
            )
            
        case 2:
            // Mode 2 - Zero-G Space (microgravity perturbations)
            return PerturbationProfile(
                name: "Zero-G Space",
                types: [.impulse, .random],
                strength: 0.4,
                frequency: 0.0,
                randomInterval: 3.0...7.0,
                dataSource: nil,
                showWarnings: true
            )
            
        default:
            // Default experiment mode
            return PerturbationProfile(
                name: "Experiment",
                types: [.dataSet],
                strength: 1.0,
                frequency: 0.0,
                randomInterval: 0...0,
                dataSource: "PerturbationData.csv",
                showWarnings: true
            )
        }
    }
}

// MARK: - Perturbation Manager

class PerturbationManager {
    // Current active profile
    private(set) var activeProfile: PerturbationProfile?
    
    // Data source for data-driven perturbations
    private var perturbationData: [Double] = []
    private var dataIndex: Int = 0
    
    // Timing variables
    private var lastUpdateTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var timeUntilNextImpulse: TimeInterval = 0
    
    // View model reference
    weak var viewModel: PendulumViewModel?
    
    // Scene reference for visual effects
    weak var scene: PendulumScene?
    
    // Warning indicator node
    private var warningIndicator: SKNode?
    
    // Track if manager is active
    private var isActive: Bool = true
    
    // Perturbation visualizer
    private var visualizer: PerturbationVisualizer?
    
    // Initialize with optional profile
    init(profile: PerturbationProfile? = nil) {
        if let profile = profile {
            activateProfile(profile)
        }
        
        // Listen for stop notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStopNotification),
            name: NSNotification.Name("StopAllPerturbations"),
            object: nil
        )
        
        // Listen for resume notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleResumeNotification),
            name: NSNotification.Name("ResumeAllPerturbations"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleStopNotification() {
        stop()
    }
    
    @objc private func handleResumeNotification() {
        resume()
    }
    
    // Stop all perturbations
    func stop() {
        isActive = false
        
        // Clear any visual warnings
        warningIndicator?.removeFromParent()
        warningIndicator = nil
        
        // Deactivate visualizer
        visualizer?.deactivate()
        
        print("PerturbationManager stopped")
    }
    
    // Resume perturbations
    func resume() {
        isActive = true
        resetImpulseTiming()
        lastUpdateTime = 0
        
        print("PerturbationManager resumed")
    }
    
    // Activate a perturbation profile
    func activateProfile(_ profile: PerturbationProfile) {
        activeProfile = profile
        
        // Reset timing
        elapsedTime = 0
        lastUpdateTime = 0
        resetImpulseTiming()
        
        // Load data if needed
        if let dataSource = profile.dataSource {
            loadPerturbationData(from: dataSource)
        }
        
        print("Activated perturbation profile: \(profile.name)")
        print("Types: \(profile.types)")
        print("Strength: \(profile.strength)")
        
        // Create warning indicator if needed
        if profile.showWarnings {
            setupWarningIndicator()
        }
        
        // Setup visualizer if scene is available
        if let scene = scene {
            visualizer = PerturbationVisualizer(scene: scene)
            
            // Activate visualizer for all perturbation types with enhanced visibility
            if profile.types.contains(.sine) {
                visualizer?.activateForMode("sine")
            } else if profile.types.contains(.dataSet) {
                visualizer?.activateForMode("data")
            } else if profile.types.contains(.compound) {
                visualizer?.activateForMode("compound")
            } else if profile.types.contains(.random) {
                visualizer?.activateForMode("random")
            } else if profile.types.contains(.impulse) {
                visualizer?.activateForMode("impulse")
            }
        }
    }
    
    // Reset impulse timing
    private func resetImpulseTiming() {
        if let profile = activeProfile {
            // Set random time for next impulse within the specified interval
            timeUntilNextImpulse = Double.random(in: profile.randomInterval)
        }
    }
    
    // Set up warning indicator
    private func setupWarningIndicator() {
        guard let scene = scene else { return }
        
        // Remove any existing warning indicator
        warningIndicator?.removeFromParent()
        
        // Create new warning indicator (arrow pointing in perturbation direction)
        let warningNode = SKNode()
        
        // Arrow shape
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -15, y: 0))
        arrowPath.addLine(to: CGPoint(x: 15, y: 0))
        arrowPath.move(to: CGPoint(x: 15, y: 0))
        arrowPath.addLine(to: CGPoint(x: 5, y: 10))
        arrowPath.move(to: CGPoint(x: 15, y: 0))
        arrowPath.addLine(to: CGPoint(x: 5, y: -10))
        
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = .red
        arrow.lineWidth = 3
        arrow.alpha = 0
        warningNode.addChild(arrow)
        
        // Add exclamation mark
        let exclamation = SKLabelNode(text: "!")
        exclamation.fontColor = .red
        exclamation.fontSize = 24
        exclamation.fontName = "Helvetica-Bold"
        exclamation.alpha = 0
        exclamation.position = CGPoint(x: 0, y: -40)
        warningNode.addChild(exclamation)
        
        // Set initial position off-screen
        warningNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        warningNode.isHidden = true
        warningNode.zPosition = 100
        
        scene.addChild(warningNode)
        warningIndicator = warningNode
    }
    
    // Show warning before perturbation
    private func showWarning(direction: CGFloat) {
        guard let warningIndicator = warningIndicator else { return }
        
        warningIndicator.isHidden = false
        
        // Set arrow direction based on perturbation direction
        warningIndicator.zRotation = direction > 0 ? 0 : .pi
        
        // Animate warning indicator
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let wait = SKAction.wait(forDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        
        // Apply animations to children
        for child in warningIndicator.children {
            child.run(SKAction.sequence([fadeIn, SKAction.repeat(pulse, count: 2), wait, fadeOut]))
        }
        
        // Hide after animation
        warningIndicator.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.4),
            SKAction.run { [weak self] in
                self?.warningIndicator?.isHidden = true
            }
        ]))
    }
    
    // Load perturbation data from a file
    private func loadPerturbationData(from filename: String) {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Failed to find perturbation data file: \(filename)")
            return
        }
        
        do {
            let contents = try String(contentsOf: fileURL)
            let lines = contents.split(separator: "\n")
            
            perturbationData = lines.compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                return Double(trimmed)
            }
            
            print("Loaded \(perturbationData.count) data points from \(filename)")
            dataIndex = 0
        } catch {
            print("Error loading perturbation data: \(error)")
        }
    }
    
    // Update the perturbation manager
    func update(currentTime: TimeInterval) {
        guard isActive, let profile = activeProfile, let viewModel = viewModel else { return }
        
        // Calculate delta time
        let deltaTime: TimeInterval
        if lastUpdateTime == 0 {
            deltaTime = 0
        } else {
            deltaTime = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime
        
        // Update elapsed time
        elapsedTime += deltaTime
        
        // Process all perturbation types in the profile
        var totalPerturbation: Double = 0
        
        for type in profile.types {
            switch type {
            case .impulse:
                totalPerturbation += processImpulsePerturbation(deltaTime, profile: profile)
                
            case .sine:
                totalPerturbation += processSinePerturbation(profile: profile)
                
            case .dataSet:
                totalPerturbation += processDataSetPerturbation(profile: profile)
                
            case .random:
                totalPerturbation += processRandomPerturbation(profile: profile)
                
            case .compound:
                totalPerturbation += processCompoundPerturbation(deltaTime, profile: profile)
            }
        }
        
        // Apply the total perturbation if non-zero
        if abs(totalPerturbation) > 0.001 {
            // Apply force through the view model
            viewModel.applyForce(totalPerturbation)
            
            // Update visualizer
            visualizer?.updateVisualization(magnitude: totalPerturbation, elapsedTime: elapsedTime)
            
            // Play correlated sound
            visualizer?.playSoundForPerturbation(totalPerturbation)
            
            // Generate visual effect if significant perturbation
            if abs(totalPerturbation) > 0.1 {
                generateVisualEffect(magnitude: totalPerturbation)
            }
        }
    }
    
    // Process impulse perturbation (random interval strong forces)
    private func processImpulsePerturbation(_ deltaTime: TimeInterval, profile: PerturbationProfile) -> Double {
        // Countdown to next impulse
        timeUntilNextImpulse -= deltaTime
        
        // Check if it's time for an impulse
        if timeUntilNextImpulse <= 0 {
            // Calculate impulse magnitude (with random direction)
            let direction: Double = Bool.random() ? 1.0 : -1.0
            let magnitude = direction * profile.strength * Double.random(in: 0.8...1.2)
            
            // Show warning if enabled (gives player time to react)
            if profile.showWarnings {
                showWarning(direction: CGFloat(direction))
                
                // Delay the actual impulse application
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.viewModel?.applyForce(magnitude)
                    self?.generateVisualEffect(magnitude: magnitude)
                }
                
                // Reset for next impulse
                resetImpulseTiming()
                
                // Return 0 since the force will be applied later after warning
                return 0
            } else {
                // Reset for next impulse
                resetImpulseTiming()
                
                // Return the impulse magnitude to apply immediately
                return magnitude
            }
        }
        
        // No impulse this update
        return 0
    }
    
    // Process sine wave perturbation (smooth oscillating forces)
    private func processSinePerturbation(profile: PerturbationProfile) -> Double {
        // Calculate sine wave based on elapsed time and frequency
        let radians = 2.0 * Double.pi * profile.frequency * elapsedTime
        let sinValue = sin(radians)
        
        // Apply profile strength as amplitude modifier
        // Note: Multiplier reduced from 0.3 to 0.225 (25% reduction) as requested
        let result = sinValue * profile.strength * 0.225
        
        // Generate visual effect for significant sine perturbations
        if abs(result) > 0.05 {
            generateSineVisualization(magnitude: result)
        }
        
        return result
    }
    
    // Process data-driven perturbation (from file)
    private func processDataSetPerturbation(profile: PerturbationProfile) -> Double {
        guard !perturbationData.isEmpty else {
            return 0
        }
        
        // Get current data point
        let value = perturbationData[dataIndex]
        
        // Visualize the data point
        visualizer?.visualizeDataPoint(value, index: dataIndex)
        
        // Move to next data point (loop if at end)
        dataIndex = (dataIndex + 1) % perturbationData.count
        
        // Apply profile strength as scale factor
        let result = value * profile.strength * 0.5
        
        // Generate a visualization for data-driven perturbation if significant
        if abs(result) > 0.05 {
            // Create data-specific visualization based on the current value
            generateDataVisualization(magnitude: result)
        }
        
        return result
    }
    
    // Create a specific visualization for data-driven perturbations
    private func generateDataVisualization(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Generate particles with distinct appearance for data-driven perturbations
        let particleCount = Int(min(abs(magnitude) * 30, 50))
        let dataParticles = SKNode()
        dataParticles.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        scene.addChild(dataParticles)
        
        // Set z-position to ensure visibility
        dataParticles.zPosition = 50
        
        // Color based on magnitude (blue-white for positive, red-orange for negative)
        let baseColor = magnitude > 0 
            ? SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.7)
            : SKColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 0.7)
        
        // Create data visualization particles in a ring pattern
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3.5))
            
            // Calculate position in circle around pendulum
            let angle = (CGFloat(i) / CGFloat(particleCount)) * CGFloat.pi * 2.0
            let distance = CGFloat.random(in: 80...120)
            let xPos = cos(angle) * distance
            let yPos = sin(angle) * distance
            
            particle.position = CGPoint(x: xPos, y: yPos)
            particle.fillColor = baseColor
            particle.strokeColor = baseColor.withAlphaComponent(0.3)
            particle.glowWidth = 2.0
            
            dataParticles.addChild(particle)
            
            // Add pulsing animation
            let pulseAction = SKAction.sequence([
                SKAction.scale(to: CGFloat.random(in: 1.5...2.5), duration: CGFloat.random(in: 0.2...0.5)),
                SKAction.scale(to: CGFloat.random(in: 0.5...0.8), duration: CGFloat.random(in: 0.2...0.5))
            ])
            
            // Move particles based on data value
            let moveAction = SKAction.move(
                to: CGPoint(x: xPos * 1.5, y: yPos * 1.5),
                duration: CGFloat.random(in: 0.5...1.0)
            )
            
            // Fade out
            let fadeAction = SKAction.sequence([
                SKAction.wait(forDuration: CGFloat.random(in: 0.2...0.5)),
                SKAction.fadeOut(withDuration: CGFloat.random(in: 0.3...0.7))
            ])
            
            // Run actions
            particle.run(SKAction.group([
                SKAction.repeat(pulseAction, count: 2),
                moveAction,
                fadeAction
            ]))
        }
        
        // Remove node after animation completes
        dataParticles.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
    }
    
    // Process random perturbation (noise)
    private func processRandomPerturbation(profile: PerturbationProfile) -> Double {
        // Generate random noise
        let noise = Double.random(in: -1.0...1.0)
        
        // Scale by profile strength but make it smaller than other perturbations
        let result = noise * profile.strength * 0.1
        
        // Generate visual effect for significant random perturbations (less frequent)
        if abs(result) > 0.08 && Double.random(in: 0...1) > 0.7 {
            generateRandomVisualization(magnitude: result)
        }
        
        return result
    }
    
    // Process compound perturbation (combination)
    private func processCompoundPerturbation(_ deltaTime: TimeInterval, profile: PerturbationProfile) -> Double {
        guard let subProfiles = profile.subProfiles else {
            return 0
        }
        
        // Process each sub-profile and sum the results
        var totalEffect: Double = 0
        
        for subProfile in subProfiles {
            for type in subProfile.types {
                switch type {
                case .impulse:
                    totalEffect += processImpulsePerturbation(deltaTime, profile: subProfile)
                case .sine:
                    totalEffect += processSinePerturbation(profile: subProfile)
                case .dataSet:
                    totalEffect += processDataSetPerturbation(profile: subProfile)
                case .random:
                    totalEffect += processRandomPerturbation(profile: subProfile)
                case .compound:
                    // Avoid infinite recursion by not handling nested compounds
                    break
                }
            }
        }
        
        // Apply an additional 25% reduction to the total effect for compound perturbations
        let result = totalEffect * 0.75
        
        // Generate visual effect for significant compound perturbations
        if abs(result) > 0.05 {
            generateCompoundVisualization(magnitude: result)
        }
        
        return result
    }
    
    // Generate visual effects for perturbations
    func generateVisualEffect(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Determine which particle effect to use based on magnitude and direction
        let effectType: String = abs(magnitude) > 0.5 ? "impulse" : "wind"
        let direction: CGFloat = magnitude < 0 ? -1.0 : 1.0
        
        // Create particle system based on type
        let particles: SKEmitterNode
        if effectType == "impulse" {
            if let impulseParticles = SKEmitterNode(fileNamed: "ImpulseParticle") {
                particles = impulseParticles
                // Override color settings to fix white particle issue
                particles.particleColorBlendFactor = 0.0
                particles.particleTexture = createSunsetParticleTexture()
            } else {
                // Fallback if file doesn't exist
                particles = createImpulseParticles()
            }
        } else {
            if let windParticles = SKEmitterNode(fileNamed: "WindParticle") {
                particles = windParticles
                // Override color settings to fix white particle issue
                particles.particleColorBlendFactor = 0.0
                particles.particleTexture = createSunsetParticleTexture(useLighterColors: true)
            } else {
                // Fallback if file doesn't exist
                particles = createWindParticles()
            }
        }
        
        // Configure particle position - start from side based on direction
        // Position particles at pendulum height (15% from bottom)
        let xPosition = direction < 0 ? scene.size.width + 50 : -50
        let yPosition = scene.size.height * 0.15  // Same height as pendulum pivot
        particles.position = CGPoint(x: xPosition, y: yPosition)
        
        // Configure particle direction and spread
        particles.emissionAngle = direction < 0 ? .pi : 0
        particles.emissionAngleRange = .pi / 4  // 45-degree spread
        
        // Scale particles based on magnitude
        let scale = min(0.8 + abs(magnitude) * 0.5, 1.5)
        particles.particleScale = particles.particleScale * CGFloat(scale)
        
        // Set particle lifetime based on effect type
        particles.particleLifetime = effectType == "impulse" ? 0.8 : 1.5
        
        // Add horizontal movement to particles
        particles.xAcceleration = direction * -100 * CGFloat(abs(magnitude))
        
        // Add to scene with higher z-position for visibility
        particles.zPosition = 20
        scene.addChild(particles)
        
        // Remove particle system after effect completes
        particles.run(SKAction.sequence([
            SKAction.wait(forDuration: effectType == "impulse" ? 1.0 : 2.0),
            SKAction.removeFromParent()
        ]))
        
        // Add screen shake for strong impacts
        if abs(magnitude) > 0.7 {
            addScreenShake(magnitude: magnitude)
        }
    }
    
    // Add screen shake effect
    private func addScreenShake(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Calculate shake amount based on magnitude
        let shakeAmount = CGFloat(min(abs(magnitude) * 5, 10))
        
        // Create shake actions
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -shakeAmount, y: -shakeAmount, duration: 0.05),
            SKAction.moveBy(x: shakeAmount * 2, y: 0, duration: 0.05),
            SKAction.moveBy(x: -shakeAmount * 2, y: shakeAmount * 2, duration: 0.05),
            SKAction.moveBy(x: 0, y: -shakeAmount * 2, duration: 0.05),
            SKAction.moveBy(x: shakeAmount, y: shakeAmount, duration: 0.05)
        ])
        
        // Apply shake to scene's camera if available, otherwise to scene itself
        if let camera = scene.camera {
            camera.run(shake)
        } else {
            scene.run(shake)
        }
    }
    
    // Create impulse particles fallback
    private func createImpulseParticles() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 300
        emitter.numParticlesToEmit = 100
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        emitter.particleSize = CGSize(width: 8, height: 8)
        
        // Create sunset colored texture programmatically
        let sunsetTexture = createSunsetParticleTexture()
        emitter.particleTexture = sunsetTexture
        
        // Set color blend factor to 0 to use texture colors directly
        emitter.particleColorBlendFactor = 0.0
        
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 80
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -1.2
        emitter.xAcceleration = 0
        emitter.yAcceleration = 0
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = 0.8
        
        // Add scale animations for more dynamic effect
        emitter.particleScale = 0.2  // Much smaller for firework effect
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.3
        
        // Set blend mode for better visibility
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    // Create wind particles fallback
    private func createWindParticles() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 80
        emitter.numParticlesToEmit = 60
        emitter.particleLifetime = 1.5
        emitter.particleLifetimeRange = 0.5
        emitter.particleSize = CGSize(width: 6, height: 6)
        
        // Create sunset colored texture
        let sunsetTexture = createSunsetParticleTexture(useLighterColors: true)
        emitter.particleTexture = sunsetTexture
        
        // Set color blend factor to 0 to use texture colors directly
        emitter.particleColorBlendFactor = 0.0
        
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 50
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -0.5
        emitter.xAcceleration = 0
        emitter.yAcceleration = 0
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = 0.5
        
        // Add gentle scale animation
        emitter.particleScale = 0.15  // Much smaller for firework effect
        emitter.particleScaleRange = 0.08
        emitter.particleScaleSpeed = -0.2
        
        // Set blend mode for better visibility
        emitter.particleBlendMode = .alpha
        
        return emitter
    }
    
    // Create sunset colored particle texture
    private func createSunsetParticleTexture(useLighterColors: Bool = false) -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Define sunset colors
        let colors: [UIColor]
        if useLighterColors {
            colors = [
                UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0),  // Light peach
                UIColor(red: 1.0, green: 0.7, blue: 0.5, alpha: 1.0),  // Light coral
                UIColor(red: 0.9, green: 0.6, blue: 0.7, alpha: 1.0),  // Light pink
                UIColor(red: 0.8, green: 0.7, blue: 0.9, alpha: 1.0)   // Light lavender
            ]
        } else {
            colors = [
                UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0),  // Orange
                UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0),  // Coral
                UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0),  // Pink
                UIColor(red: 0.7, green: 0.3, blue: 0.8, alpha: 1.0)   // Purple
            ]
        }
        
        // Create gradient
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors.map { $0.cgColor } as CFArray,
            locations: [0.0, 0.33, 0.66, 1.0]
        )!
        
        // Draw radial gradient
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        context.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: size.width / 2,
            options: []
        )
        
        // Add soft glow effect
        context.setBlendMode(.screen)
        context.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
        context.fillEllipse(in: CGRect(x: 2, y: 2, width: 12, height: 12))
        
        // Get image and create texture
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    // Create sine wave visualization
    private func generateSineVisualization(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Create the sine wave effect using the curved effects from PerturbationEffects
        let direction: CGFloat = magnitude < 0 ? -1.0 : 1.0
        let sineEffect = PerturbationEffects.shared.createCurvedPerturbationEffect(
            mode: .sine,
            at: CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.15),
            direction: direction,
            magnitude: abs(magnitude),
            scene: scene
        )
        
        // Set z-position to ensure visibility
        sineEffect.zPosition = 100
        
        scene.addChild(sineEffect)
        
        // Add subtle screen pulse for sine waves
        if abs(magnitude) > 0.15 {
            let pulseAmount = CGFloat(min(abs(magnitude) * 2, 3))
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.0 + pulseAmount * 0.01, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            
            if let camera = scene.camera {
                camera.run(pulse)
            }
        }
    }
    
    // Create compound perturbation visualization
    private func generateCompoundVisualization(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Create the compound effect using the curved effects from PerturbationEffects
        let direction: CGFloat = magnitude < 0 ? -1.0 : 1.0
        let compoundEffect = PerturbationEffects.shared.createCurvedPerturbationEffect(
            mode: .compound,
            at: CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.15),
            direction: direction,
            magnitude: abs(magnitude),
            scene: scene
        )
        
        // Set z-position to ensure visibility
        compoundEffect.zPosition = 100
        
        scene.addChild(compoundEffect)
        
        // Add more dramatic screen effects for compound perturbations
        if abs(magnitude) > 0.2 {
            addScreenShake(magnitude: magnitude * 0.7)
            
            // Add haptic feedback
            PerturbationEffects.shared.generateHapticFeedback(for: magnitude)
        }
    }
    
    // Create random perturbation visualization
    private func generateRandomVisualization(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Create the random effect using the curved effects from PerturbationEffects
        let direction: CGFloat = magnitude < 0 ? -1.0 : 1.0
        let randomEffect = PerturbationEffects.shared.createCurvedPerturbationEffect(
            mode: .random,
            at: CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.15),
            direction: direction,
            magnitude: abs(magnitude),
            scene: scene
        )
        
        // Set z-position to ensure visibility
        randomEffect.zPosition = 100
        
        scene.addChild(randomEffect)
    }
    
    // Clear any visual indicators
    func clearVisualizer() {
        visualizer?.deactivate()
    }
}