import SpriteKit

class GoldenAchievementParticleGenerator {
    
    /// Creates a golden achievement particle effect
    /// - Returns: SKEmitterNode configured with golden particles for achievement celebration
    static func createGoldenAchievementParticle() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties - more intense celebration
        emitter.particleTexture = SKTexture(imageNamed: "spark") // Using default spark texture
        emitter.particleBirthRate = 800
        emitter.numParticlesToEmit = 500
        emitter.particleLifetime = 2.5
        emitter.particleLifetimeRange = 0.8
        
        // Particle appearance
        emitter.particleSize = CGSize(width: 8, height: 8)
        // SKEmitterNode doesn't have particleSizeRange property, use particleScaleRange instead
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5 // Increased to account for size range
        emitter.particleScaleSpeed = -0.2
        
        // Colors - using Golden Enterprise theme colors
        let startColor = UIColor(red: 0.85, green: 0.7, blue: 0.2, alpha: 1.0) // goldenPrimary
        let endColor = UIColor(red: 0.9, green: 0.85, blue: 0.6, alpha: 0.0) // goldenSecondary with fade
        
        emitter.particleColor = startColor
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            startColor.cgColor,
            UIColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 1.0).cgColor, // goldenAccent
            endColor.cgColor
        ], times: [0.0, 0.5, 1.0])
        
        // Emission pattern
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2 // 360 degrees
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 50
        
        // Physics
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.4
        emitter.xAcceleration = 0
        emitter.yAcceleration = -50 // Slight gravity effect
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi * 2
        emitter.particleRotationSpeed = CGFloat.pi
        
        // Blend mode
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    /// Creates a firework-style particle effect with sunset colors
    /// - Returns: SKEmitterNode configured with firework particles for achievement celebration
    static func createFireworkParticle() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties - firework style
        emitter.particleTexture = SKTexture(imageNamed: "spark") // Using default spark texture
        emitter.particleBirthRate = 1200
        emitter.numParticlesToEmit = 600
        emitter.particleLifetime = 2.3 // 0.2 seconds shorter than before
        emitter.particleLifetimeRange = 0.5
        
        // Particle appearance - smaller size
        emitter.particleSize = CGSize(width: 4, height: 4) // Smaller particles
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.8
        emitter.particleScaleSpeed = -0.5 // Faster shrinking
        
        // Sunset colors
        let sunsetColors = [
            UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1.0),    // Bright orange
            UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0),    // Golden yellow
            UIColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1.0),    // Pink
            UIColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1.0),    // Magenta
            UIColor(red: 0.7, green: 0.4, blue: 0.7, alpha: 1.0),    // Purple
            UIColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0)     // Deep purple
        ]
        
        // Random sunset color
        let randomColor = sunsetColors.randomElement() ?? sunsetColors[0]
        
        emitter.particleColor = randomColor
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            randomColor.cgColor,
            randomColor.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ], times: [0.0, 0.7, 1.0])
        
        // Radial emission pattern - firework explosion
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2 // 360 degrees
        emitter.particleSpeed = 300 // Faster initial speed
        emitter.particleSpeedRange = 100
        
        // Physics
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.1
        emitter.particleAlphaSpeed = -0.6
        emitter.xAcceleration = 0
        emitter.yAcceleration = -120 // Stronger gravity for more realistic firework
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi * 2
        emitter.particleRotationSpeed = CGFloat.pi * 2
        
        // Blend mode
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    /// Creates a balanced particle effect (for pause)
    /// - Returns: SKEmitterNode configured for balance/pause effect
    static func createBalanceParticle() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties - gentle floating effect
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 400
        emitter.numParticlesToEmit = 200
        emitter.particleLifetime = 2.3 // Shorter duration
        emitter.particleLifetimeRange = 0.5
        
        // Smaller particles
        emitter.particleSize = CGSize(width: 3, height: 3)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.2
        
        // Soft sunset colors
        let softSunsetColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0) // Soft yellow
        let endColor = UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 0.0) // Fade to orange
        
        emitter.particleColor = softSunsetColor
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            softSunsetColor.cgColor,
            endColor.cgColor
        ], times: [0.0, 1.0])
        
        // Gentle radial pattern
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 30
        
        // Physics - floating effect
        emitter.particleAlpha = 0.7
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.3
        emitter.xAcceleration = 0
        emitter.yAcceleration = 10 // Slight upward drift
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi
        emitter.particleRotationSpeed = CGFloat.pi * 0.5
        
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    /// Creates an impulse particle effect
    /// - Returns: SKEmitterNode configured for impulse effect
    static func createImpulseParticle() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties - burst effect
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 1500
        emitter.numParticlesToEmit = 300
        emitter.particleLifetime = 2.3 // Shorter duration
        emitter.particleLifetimeRange = 0.3
        
        // Smaller particles
        emitter.particleSize = CGSize(width: 5, height: 5)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.7
        emitter.particleScaleSpeed = -0.6
        
        // Intense sunset colors
        let intenseOrange = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0)
        let deepRed = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.0)
        
        emitter.particleColor = intenseOrange
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            intenseOrange.cgColor,
            deepRed.cgColor
        ], times: [0.0, 1.0])
        
        // Directional burst
        emitter.emissionAngle = CGFloat.pi / 2 // Upward
        emitter.emissionAngleRange = CGFloat.pi * 0.5 // 90 degree spread
        emitter.particleSpeed = 350
        emitter.particleSpeedRange = 100
        
        // Physics
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.1
        emitter.particleAlphaSpeed = -0.7
        emitter.xAcceleration = 0
        emitter.yAcceleration = -200 // Strong gravity
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi * 2
        emitter.particleRotationSpeed = CGFloat.pi * 3
        
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    /// Saves the emitter to a .sks file
    static func saveEmitterToFile() {
        let emitter = createGoldenAchievementParticle()
        // Note: In a real app, we would save this to a .sks file here
        // This requires using Xcode's particle editor or the SKEmitterNode archiving methods
        // For this example, we've created the code that should be used to generate the particle effect
    }
}