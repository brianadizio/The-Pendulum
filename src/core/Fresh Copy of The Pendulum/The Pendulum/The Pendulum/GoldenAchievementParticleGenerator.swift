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
    
    /// Saves the emitter to a .sks file
    static func saveEmitterToFile() {
        let emitter = createGoldenAchievementParticle()
        // Note: In a real app, we would save this to a .sks file here
        // This requires using Xcode's particle editor or the SKEmitterNode archiving methods
        // For this example, we've created the code that should be used to generate the particle effect
    }
}