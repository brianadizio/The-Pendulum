import SpriteKit

class BalanceEffectManager {
    
    private weak var scene: SKScene?
    private var activeEmitters: [SKEmitterNode] = []
    private var isBalanceEffectActive = false
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    /// Shows a continuous balance effect while the pendulum is balanced
    func showContinuousBalanceEffect(at position: CGPoint, level: Int) {
        guard let scene = scene, !isBalanceEffectActive else { return }
        
        isBalanceEffectActive = true
        
        // Get the color palette for the current level
        let paletteIndex = (level - 1) % DynamicParticleManager.allPalettes.count
        let selectedPalette = DynamicParticleManager.allPalettes[paletteIndex]
        
        // Create floating particles around the balanced pendulum
        for i in 0..<4 {
            let angle = Double(i) * .pi / 2
            let offset = CGPoint(
                x: position.x + cos(angle) * 30,
                y: position.y + sin(angle) * 30
            )
            
            let floatingEmitter = createFloatingParticle(color: selectedPalette[i % selectedPalette.count])
            floatingEmitter.position = offset
            scene.addChild(floatingEmitter)
            activeEmitters.append(floatingEmitter)
        }
        
        // Create a gentle glow effect
        let glowEmitter = createGlowEffect(colors: selectedPalette)
        glowEmitter.position = position
        scene.addChild(glowEmitter)
        activeEmitters.append(glowEmitter)
    }
    
    /// Stops the continuous balance effect
    func stopBalanceEffect() {
        isBalanceEffectActive = false
        
        // Fade out and remove all active emitters
        for emitter in activeEmitters {
            emitter.particleBirthRate = 0
            
            // Remove after particles finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                emitter.removeFromParent()
            }
        }
        
        activeEmitters.removeAll()
    }
    
    /// Creates a floating particle effect
    private func createFloatingParticle(color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Configure for gentle floating particles
        emitter.particleTexture = createSoftGlowTexture()
        emitter.particleBirthRate = 30
        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0
        
        // Soft particles
        emitter.particleSize = CGSize(width: 8, height: 8)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.4
        emitter.particleScaleSpeed = -0.1
        
        // Set color
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.2
        
        // Gentle floating motion
        emitter.emissionAngle = -CGFloat.pi / 2
        emitter.emissionAngleRange = CGFloat.pi / 4
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 10
        
        // Float upward
        emitter.yAcceleration = 15
        
        emitter.particleBlendMode = .add
        emitter.zPosition = 15
        
        return emitter
    }
    
    /// Creates a glow effect
    private func createGlowEffect(colors: [UIColor]) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Configure for soft glow
        emitter.particleTexture = createSoftGlowTexture()
        emitter.particleBirthRate = 10
        emitter.particleLifetime = 4.0
        emitter.particleLifetimeRange = 1.0
        
        // Large soft glows
        emitter.particleSize = CGSize(width: 40, height: 40)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = 0.2
        
        // Cycle through colors
        let colorSequence = createColorSequence(from: colors)
        emitter.particleColorSequence = colorSequence
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.3
        emitter.particleAlphaRange = 0.1
        emitter.particleAlphaSpeed = -0.1
        
        // Stationary glow
        emitter.particleSpeed = 0
        
        emitter.particleBlendMode = .add
        emitter.zPosition = 14
        
        return emitter
    }
    
    /// Creates a soft glow texture
    private func createSoftGlowTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Soft radial gradient
            let colors = [
                UIColor.white.withAlphaComponent(0.8).cgColor,
                UIColor.white.withAlphaComponent(0.4).cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates a color sequence from a palette
    private func createColorSequence(from palette: [UIColor]) -> SKKeyframeSequence {
        var colors: [UIColor] = []
        var times: [NSNumber] = []
        
        // Create smooth transitions between colors
        for (index, color) in palette.enumerated() {
            colors.append(color)
            times.append(NSNumber(value: Double(index) / Double(palette.count - 1)))
        }
        
        // Add fade to transparent at the end
        colors.append(UIColor.clear)
        times.append(1.0)
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
}