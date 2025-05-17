import SpriteKit
import UIKit

class DynamicParticleManager {
    
    // MARK: - Texture Cache
    private static var textureCache: [String: SKTexture] = [:]
    
    // MARK: - Color Palettes extracted from reference images
    
    // Sunset over water (IMG_5043)
    static let sunsetWaterPalette = [
        UIColor(red: 1.0, green: 0.85, blue: 0.65, alpha: 1.0),  // Warm peach
        UIColor(red: 1.0, green: 0.7, blue: 0.4, alpha: 1.0),    // Golden orange
        UIColor(red: 0.95, green: 0.6, blue: 0.35, alpha: 1.0),  // Deep orange
        UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0),    // Coral
        UIColor(red: 0.85, green: 0.4, blue: 0.25, alpha: 1.0),  // Burnt orange
        UIColor(red: 0.7, green: 0.3, blue: 0.2, alpha: 1.0)     // Deep sunset
    ]
    
    // Ocean and sky (IMG_5536)
    static let oceanSkyPalette = [
        UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0),    // Deep ocean blue
        UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0),    // Ocean blue
        UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0),    // Sky blue
        UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0),    // Light sky
        UIColor(red: 0.75, green: 0.65, blue: 0.5, alpha: 1.0),  // Sand/rocks
        UIColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0)    // Light clouds
    ]
    
    // Vibrant autumn (IMG_3145)
    static let vibrantAutumnPalette = [
        UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1.0),    // Bright red
        UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0),    // Orange-red
        UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),    // Orange
        UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0),    // Yellow-orange
        UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0),    // Forest green
        UIColor(red: 0.2, green: 0.3, blue: 0.2, alpha: 1.0)     // Dark green
    ]
    
    // Abstract art palette (IMG_3149)
    static let abstractArtPalette = [
        UIColor(red: 0.15, green: 0.25, blue: 0.45, alpha: 1.0), // Deep blue
        UIColor(red: 0.25, green: 0.35, blue: 0.5, alpha: 1.0),  // Mid blue
        UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0),    // Light blue-gray
        UIColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1.0),    // Gold
        UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0),    // Light gold
        UIColor(red: 0.7, green: 0.5, blue: 0.4, alpha: 1.0)     // Bronze
    ]
    
    // Desert landscape (IMG_4506)
    static let desertLandscapePalette = [
        UIColor(red: 0.85, green: 0.7, blue: 0.5, alpha: 1.0),   // Light sand
        UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0),    // Sand
        UIColor(red: 0.7, green: 0.5, blue: 0.35, alpha: 1.0),   // Desert rock
        UIColor(red: 0.6, green: 0.4, blue: 0.3, alpha: 1.0),    // Dark rock
        UIColor(red: 0.5, green: 0.3, blue: 0.25, alpha: 1.0),   // Shadow
        UIColor(red: 0.8, green: 0.7, blue: 0.9, alpha: 1.0)     // Twilight sky
    ]
    
    static let allPalettes = [
        sunsetWaterPalette,
        oceanSkyPalette,
        vibrantAutumnPalette,
        abstractArtPalette,
        desertLandscapePalette
    ]
    
    // MARK: - Texture Creation Methods
    
    /// Creates a gradient glow texture
    static func createGlowTexture(color: UIColor, size: CGSize = CGSize(width: 128, height: 128)) -> SKTexture {
        let cacheKey = "glow_\(color.hash)_\(Int(size.width))x\(Int(size.height))"
        
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            // Create radial gradient from color to transparent
            let colors = [
                color.withAlphaComponent(1.0).cgColor,
                color.withAlphaComponent(0.8).cgColor,
                color.withAlphaComponent(0.4).cgColor,
                color.withAlphaComponent(0.1).cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.15, 0.4, 0.8, 1.0]
            
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            ) else { return }
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        
        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }
    
    /// Creates a star-shaped texture
    static func createStarTexture(color: UIColor, points: Int = 5, size: CGSize = CGSize(width: 64, height: 64)) -> SKTexture {
        let cacheKey = "star_\(color.hash)_\(points)_\(Int(size.width))x\(Int(size.height))"
        
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            
            let outerRadius = min(size.width, size.height) / 2 * 0.8
            let innerRadius = outerRadius * 0.4
            
            let path = UIBezierPath()
            for i in 0..<points * 2 {
                let angle = CGFloat(i) * CGFloat.pi / CGFloat(points) - CGFloat.pi / 2
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.close()
            
            // Add glow effect
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 8, color: color.cgColor)
            color.setFill()
            path.fill()
            ctx.restoreGState()
            
            // Draw the star with gradient
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    color.withAlphaComponent(1.0).cgColor,
                    color.withAlphaComponent(0.6).cgColor
                ] as CFArray,
                locations: [0.0, 1.0]
            )!
            
            path.addClip()
            ctx.drawRadialGradient(
                gradient,
                startCenter: CGPoint.zero,
                startRadius: 0,
                endCenter: CGPoint.zero,
                endRadius: outerRadius,
                options: []
            )
        }
        
        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }
    
    /// Creates a soft circular particle texture
    static func createSoftParticle(color: UIColor, size: CGSize = CGSize(width: 64, height: 64)) -> SKTexture {
        let cacheKey = "soft_\(color.hash)_\(Int(size.width))x\(Int(size.height))"
        
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            // Create soft edge gradient
            let colors = [
                color.withAlphaComponent(1.0).cgColor,
                color.withAlphaComponent(0.9).cgColor,
                color.withAlphaComponent(0.5).cgColor,
                color.withAlphaComponent(0.1).cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.3, 0.6, 0.85, 1.0]
            
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            ) else { return }
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        
        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }
    
    /// Creates a flame/teardrop shaped texture for trails
    static func createFlameTexture(color: UIColor, size: CGSize = CGSize(width: 32, height: 48)) -> SKTexture {
        let cacheKey = "flame_\(color.hash)_\(Int(size.width))x\(Int(size.height))"
        
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Create flame shape path
            let path = UIBezierPath()
            let centerX = size.width / 2
            
            // Bottom of flame (circular)
            path.move(to: CGPoint(x: centerX, y: size.height * 0.9))
            path.addQuadCurve(
                to: CGPoint(x: centerX * 0.2, y: size.height * 0.7),
                controlPoint: CGPoint(x: centerX * 0.1, y: size.height * 0.85)
            )
            
            // Left side curve
            path.addQuadCurve(
                to: CGPoint(x: centerX, y: size.height * 0.1),
                controlPoint: CGPoint(x: centerX * 0.3, y: size.height * 0.4)
            )
            
            // Right side curve
            path.addQuadCurve(
                to: CGPoint(x: centerX * 1.8, y: size.height * 0.7),
                controlPoint: CGPoint(x: centerX * 1.7, y: size.height * 0.4)
            )
            
            // Complete the shape
            path.addQuadCurve(
                to: CGPoint(x: centerX, y: size.height * 0.9),
                controlPoint: CGPoint(x: centerX * 1.9, y: size.height * 0.85)
            )
            
            path.close()
            
            // Create gradient fill
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    color.withAlphaComponent(1.0).cgColor,
                    color.withAlphaComponent(0.6).cgColor,
                    color.withAlphaComponent(0.2).cgColor
                ] as CFArray,
                locations: [0.0, 0.5, 1.0]
            )!
            
            path.addClip()
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: centerX, y: size.height),
                end: CGPoint(x: centerX, y: 0),
                options: []
            )
        }
        
        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }
    
    // MARK: - Main Particle Effect Creation
    
    /// Creates a level completion effect with texture-based particles
    static func createLevelCompletionEffect(for level: Int, at position: CGPoint, in scene: SKScene) {
        print("Creating level completion effect for level \(level)")
        
        // Select color palette based on level
        let paletteIndex = (level - 1) % allPalettes.count
        let selectedPalette = allPalettes[paletteIndex]
        
        print("Using palette index \(paletteIndex) for level \(level)")
        
        // Create multiple layers of effects
        createMainExplosion(palette: selectedPalette, at: position, in: scene)
        createRingBurst(palette: selectedPalette, at: position, in: scene, delay: 0.2)
        createSparkleField(palette: selectedPalette, at: position, in: scene)
        createTrailingStars(palette: selectedPalette, at: position, in: scene)
    }
    
    /// Creates the main explosion effect
    private static func createMainExplosion(palette: [UIColor], at position: CGPoint, in scene: SKScene) {
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.zPosition = 100
        
        // Use glow textures for main explosion
        let mainColor = palette.first ?? UIColor.orange
        emitter.particleTexture = createGlowTexture(color: mainColor)
        
        // Explosion configuration
        emitter.particleBirthRate = 1000
        emitter.numParticlesToEmit = 200
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5
        
        emitter.particleSize = CGSize(width: 40, height: 40)
        emitter.particleScale = 1.5
        emitter.particleScaleRange = 1.0
        emitter.particleScaleSpeed = -0.8
        
        // CRITICAL: Use texture color, not particle color
        emitter.particleColorBlendFactor = 0.0  // Use texture color ONLY
        // Remove color sequence to avoid overriding texture colors
        // emitter.particleColorSequence = createColorSequence(from: palette)
        
        // Explosion pattern
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2
        emitter.particleSpeed = 400
        emitter.particleSpeedRange = 100
        
        // Physics
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.5
        emitter.yAcceleration = -200
        
        // Use alpha blend instead of add to preserve colors
        emitter.particleBlendMode = .alpha
        
        scene.addChild(emitter)
        
        // Remove after effect completes
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ])
        emitter.run(removeAction)
    }
    
    /// Creates a ring burst effect
    private static func createRingBurst(palette: [UIColor], at position: CGPoint, in scene: SKScene, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let emitter = SKEmitterNode()
            emitter.position = position
            emitter.zPosition = 101
            
            // Use star textures for ring burst
            let ringColor = palette[min(1, palette.count - 1)]
            emitter.particleTexture = createStarTexture(color: ringColor)
            
            // Ring configuration
            emitter.particleBirthRate = 800
            emitter.numParticlesToEmit = 150
            emitter.particleLifetime = 1.5
            emitter.particleLifetimeRange = 0.3
            
            emitter.particleSize = CGSize(width: 24, height: 24)
            emitter.particleScale = 1.2
            emitter.particleScaleRange = 0.5
            emitter.particleScaleSpeed = -0.7
            
            // CRITICAL: Use texture color ONLY
            emitter.particleColorBlendFactor = 0.0
            // Remove particle color override
            // emitter.particleColor = ringColor
            
            // Ring pattern
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = CGFloat.pi * 2
            emitter.particleSpeed = 300
            emitter.particleSpeedRange = 50
            
            // Physics
            emitter.particleAlpha = 1.0
            emitter.particleAlphaSpeed = -0.6
            emitter.yAcceleration = -100
            
            // Rotation for sparkle
            emitter.particleRotation = 0
            emitter.particleRotationRange = CGFloat.pi * 2
            emitter.particleRotationSpeed = CGFloat.pi * 4
            
            // Use alpha blend for better color preservation
            emitter.particleBlendMode = .alpha
            
            scene.addChild(emitter)
            
            // Remove after effect completes
            emitter.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.5),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    /// Creates a field of sparkles
    private static func createSparkleField(palette: [UIColor], at position: CGPoint, in scene: SKScene) {
        for i in 0..<20 {
            let delay = Double(i) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let sparklePosition = CGPoint(
                    x: position.x + CGFloat.random(in: -100...100),
                    y: position.y + CGFloat.random(in: -100...100)
                )
                
                let emitter = SKEmitterNode()
                emitter.position = sparklePosition
                emitter.zPosition = 102
                
                // Use soft particles for sparkles
                let sparkleColor = palette.randomElement() ?? UIColor.white
                emitter.particleTexture = createSoftParticle(color: sparkleColor)
                
                // Sparkle configuration
                emitter.particleBirthRate = 30
                emitter.numParticlesToEmit = 10
                emitter.particleLifetime = 1.0
                emitter.particleLifetimeRange = 0.3
                
                emitter.particleSize = CGSize(width: 16, height: 16)
                emitter.particleScale = 1.0
                emitter.particleScaleRange = 0.5
                emitter.particleScaleSpeed = -0.8
                
                // CRITICAL: Use texture color ONLY
                emitter.particleColorBlendFactor = 0.0
                
                // Gentle movement
                emitter.emissionAngle = -CGFloat.pi / 2
                emitter.emissionAngleRange = CGFloat.pi / 4
                emitter.particleSpeed = 50
                emitter.particleSpeedRange = 30
                
                emitter.particleAlpha = 0.9
                emitter.particleAlphaSpeed = -0.8
                emitter.yAcceleration = 30  // Float upward
                
                // Use alpha blend to preserve colors
                emitter.particleBlendMode = .alpha
                
                scene.addChild(emitter)
                
                // Remove after effect completes
                emitter.run(SKAction.sequence([
                    SKAction.wait(forDuration: 1.5),
                    SKAction.removeFromParent()
                ]))
            }
        }
    }
    
    /// Creates trailing star effects
    private static func createTrailingStars(palette: [UIColor], at position: CGPoint, in scene: SKScene) {
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3.0
            let emitter = SKEmitterNode()
            emitter.position = position
            emitter.zPosition = 99
            
            // Use flame textures for trails
            let trailColor = palette[min(2, palette.count - 1)]
            emitter.particleTexture = createFlameTexture(color: trailColor)
            
            // Trail configuration
            emitter.particleBirthRate = 200
            emitter.numParticlesToEmit = 100
            emitter.particleLifetime = 1.5
            emitter.particleLifetimeRange = 0.5
            
            emitter.particleSize = CGSize(width: 20, height: 30)
            emitter.particleScale = 1.0
            emitter.particleScaleRange = 0.5
            emitter.particleScaleSpeed = -0.5
            
            // CRITICAL: Use texture color ONLY
            emitter.particleColorBlendFactor = 0.0
            
            // Directional emission
            emitter.emissionAngle = CGFloat(angle)
            emitter.emissionAngleRange = CGFloat.pi / 12
            emitter.particleSpeed = 500
            emitter.particleSpeedRange = 100
            
            emitter.particleAlpha = 1.0
            emitter.particleAlphaSpeed = -0.6
            emitter.yAcceleration = -80
            
            // Use alpha blend to preserve colors
            emitter.particleBlendMode = .alpha
            
            scene.addChild(emitter)
            
            // Remove after effect completes
            emitter.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a color sequence from a palette
    private static func createColorSequence(from palette: [UIColor]) -> SKKeyframeSequence {
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
    
    /// Clear texture cache if needed
    static func clearTextureCache() {
        textureCache.removeAll()
    }
}