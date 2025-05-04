import SpriteKit

// MARK: - Perturbation Visual Effects

class PerturbationEffects {
    // Shared instance
    static let shared = PerturbationEffects()
    
    // Create particle effect for impulse (strong force)
    func createImpulseEffect(at position: CGPoint, direction: CGFloat, magnitude: Double) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Base particle properties
        emitter.particleBirthRate = 300
        emitter.numParticlesToEmit = Int(50 * min(magnitude * 2, 3))
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        emitter.particleSize = CGSize(width: 5, height: 5)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.4
        emitter.particleColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 50
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -1.5
        emitter.emissionAngle = direction > 0 ? 0 : .pi
        emitter.emissionAngleRange = 0.5
        emitter.position = position
        
        // Scale effect based on magnitude
        emitter.particleScale *= CGFloat(min(1.0 + abs(magnitude), 2.0))
        
        // Color based on direction (warm for right, cool for left)
        if direction > 0 {
            emitter.particleColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0) // Warm orange
        } else {
            emitter.particleColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0) // Cool blue
        }
        
        return emitter
    }
    
    // Create particle effect for wind (gentle force)
    func createWindEffect(at position: CGPoint, direction: CGFloat, magnitude: Double) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Base particle properties for wind
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = Int(30 * min(magnitude * 2, 3))
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.3
        emitter.particleSize = CGSize(width: 2, height: 2)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.2
        emitter.particleColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.5)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 30
        emitter.particleAlpha = 0.5
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.5
        emitter.emissionAngle = direction > 0 ? 0 : .pi
        emitter.emissionAngleRange = 0.3
        emitter.position = position
        
        // Scale effect based on magnitude
        emitter.particleScale *= CGFloat(min(1.0 + abs(magnitude), 2.0))
        
        // Color based on direction (with different hues)
        if direction > 0 {
            emitter.particleColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.5) // Light blue
        } else {
            emitter.particleColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.5) // White blue
        }
        
        return emitter
    }
    
    // Create warning indicator for upcoming perturbations
    func createWarningIndicator(direction: CGFloat) -> SKNode {
        let warningNode = SKNode()
        
        // Create arrow shape pointing in perturbation direction
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -20, y: 0))
        arrowPath.addLine(to: CGPoint(x: 20, y: 0))
        arrowPath.move(to: CGPoint(x: 20, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: 10))
        arrowPath.move(to: CGPoint(x: 20, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: -10))
        
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0) // Red
        arrow.lineWidth = 3
        warningNode.addChild(arrow)
        
        // Add glow effect
        arrow.glowWidth = 2
        
        // Add exclamation mark
        let exclamation = SKLabelNode(text: "!")
        exclamation.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0) // Red
        exclamation.fontSize = 24
        exclamation.fontName = "Helvetica-Bold"
        exclamation.position = CGPoint(x: 0, y: -30)
        warningNode.addChild(exclamation)
        
        // Set rotation based on direction
        warningNode.zRotation = direction > 0 ? 0 : .pi
        
        return warningNode
    }
    
    // Configure screen shake effect
    func screenShake(for node: SKNode, magnitude: Double) -> SKAction {
        // Calculate shake amount based on magnitude (limit maximum)
        let shakeAmount = CGFloat(min(abs(magnitude) * 5, 10))
        
        // Create shake sequence
        let shakeSequence = SKAction.sequence([
            SKAction.moveBy(x: -shakeAmount, y: -shakeAmount/2, duration: 0.05),
            SKAction.moveBy(x: shakeAmount*2, y: 0, duration: 0.05),
            SKAction.moveBy(x: -shakeAmount*2, y: shakeAmount, duration: 0.05),
            SKAction.moveBy(x: 0, y: -shakeAmount, duration: 0.05),
            SKAction.moveBy(x: shakeAmount, y: shakeAmount/2, duration: 0.05)
        ])
        
        return shakeSequence
    }
    
    // Create haptic feedback based on perturbation strength
    func generateHapticFeedback(for magnitude: Double) {
        #if os(iOS)
        let feedbackGenerator: UIFeedbackGenerator
        
        // Choose type of feedback based on magnitude
        if abs(magnitude) > 0.7 {
            // Strong impact
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
        } else if abs(magnitude) > 0.3 {
            // Medium impact
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        } else {
            // Light impact
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
        #endif
    }
}