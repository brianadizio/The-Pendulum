import SpriteKit
import UIKit

class DynamicParticleManager {
    
    // MARK: - Texture Cache
    private static var textureCache: [String: SKTexture] = [:]
    
    // MARK: - Color Palettes inspired by the painting
    
    // Yellow/Gold spectrum (top left of painting)
    static let yellowGoldPalette = [
        UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0),    // Bright yellow
        UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0),   // Golden yellow
        UIColor(red: 0.95, green: 0.8, blue: 0.15, alpha: 1.0),  // Deep gold
        UIColor(red: 0.9, green: 0.75, blue: 0.3, alpha: 1.0),   // Warm gold
        UIColor(red: 0.85, green: 0.7, blue: 0.25, alpha: 1.0),  // Olive gold
        UIColor(red: 0.75, green: 0.65, blue: 0.2, alpha: 1.0)   // Dark gold
    ]
    
    // Orange/Red spectrum (top right of painting)
    static let orangeRedPalette = [
        UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),    // Bright orange
        UIColor(red: 1.0, green: 0.5, blue: 0.15, alpha: 1.0),   // Deep orange
        UIColor(red: 0.95, green: 0.4, blue: 0.1, alpha: 1.0),   // Red-orange
        UIColor(red: 0.9, green: 0.3, blue: 0.15, alpha: 1.0),   // Warm red
        UIColor(red: 0.85, green: 0.25, blue: 0.2, alpha: 1.0),  // Deep red
        UIColor(red: 0.75, green: 0.2, blue: 0.15, alpha: 1.0)   // Dark red
    ]
    
    // Blue/Teal spectrum (bottom left of painting)
    static let blueTealPalette = [
        UIColor(red: 0.1, green: 0.4, blue: 0.6, alpha: 1.0),    // Deep blue
        UIColor(red: 0.15, green: 0.5, blue: 0.65, alpha: 1.0),  // Ocean blue
        UIColor(red: 0.2, green: 0.55, blue: 0.6, alpha: 1.0),   // Teal blue
        UIColor(red: 0.15, green: 0.6, blue: 0.55, alpha: 1.0),  // Turquoise
        UIColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 1.0),    // Deep teal
        UIColor(red: 0.05, green: 0.3, blue: 0.4, alpha: 1.0)    // Dark ocean
    ]
    
    // Purple/Magenta spectrum (bottom right of painting)
    static let purpleMagentaPalette = [
        UIColor(red: 0.7, green: 0.2, blue: 0.5, alpha: 1.0),    // Magenta
        UIColor(red: 0.6, green: 0.15, blue: 0.45, alpha: 1.0),  // Deep magenta
        UIColor(red: 0.5, green: 0.2, blue: 0.5, alpha: 1.0),    // Purple
        UIColor(red: 0.45, green: 0.15, blue: 0.4, alpha: 1.0),  // Deep purple
        UIColor(red: 0.4, green: 0.1, blue: 0.35, alpha: 1.0),   // Dark purple
        UIColor(red: 0.5, green: 0.25, blue: 0.4, alpha: 1.0)    // Plum
    ]
    
    // Mixed spectrum (transitions between colors)
    static let mixedSpectrumPalette = [
        UIColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0),    // Yellow-green
        UIColor(red: 0.3, green: 0.6, blue: 0.4, alpha: 1.0),    // Green
        UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0),    // Coral
        UIColor(red: 0.4, green: 0.3, blue: 0.6, alpha: 1.0),    // Indigo
        UIColor(red: 0.7, green: 0.4, blue: 0.5, alpha: 1.0),    // Rose
        UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)     // Gray-blue
    ]
    
    static let allPalettes = [
        yellowGoldPalette,
        orangeRedPalette,
        blueTealPalette,
        purpleMagentaPalette,
        mixedSpectrumPalette
    ]
    
    // MARK: - Available texture names
    static let coastTextures = [
        "textureCoast1", "textureCoast2", "textureCoast3",
        "textureCoast4", "textureCoast5", "textureCoast6",
        "textureCoast7", "textureCoast8", "textureCoast9"
    ]
    
    // MARK: - Texture Loading Methods
    
    /// Loads a random coast texture from assets
    static func getRandomCoastTexture() -> SKTexture? {
        guard let textureName = coastTextures.randomElement() else { return nil }
        
        // Check cache first
        if let cachedTexture = textureCache[textureName] {
            return cachedTexture
        }
        
        // Load from assets
        if let image = UIImage(named: textureName) {
            let texture = SKTexture(image: image)
            textureCache[textureName] = texture
            return texture
        }
        
        return nil
    }
    
    /// Loads a specific coast texture by index
    static func getCoastTexture(index: Int) -> SKTexture? {
        let textureIndex = index % coastTextures.count
        let textureName = coastTextures[textureIndex]
        
        // Check cache first
        if let cachedTexture = textureCache[textureName] {
            return cachedTexture
        }
        
        // Load from assets
        if let image = UIImage(named: textureName) {
            let texture = SKTexture(image: image)
            textureCache[textureName] = texture
            return texture
        }
        
        return nil
    }
    
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
        
        // Always use the full rainbow spectrum for every level
        let fullRainbowPalette = createFullRainbowPalette()
        
        print("Using full rainbow spectrum for level \(level)")
        
        // Create multiple layers of effects with rainbow colors
        createMainExplosion(palette: fullRainbowPalette, at: position, in: scene)
        createRingBurst(palette: fullRainbowPalette, at: position, in: scene, delay: 0.2)
        createSparkleField(palette: fullRainbowPalette, at: position, in: scene)
        createTrailingStars(palette: fullRainbowPalette, at: position, in: scene)
    }
    
    /// Creates a full rainbow palette matching the painting's spectrum
    static func createFullRainbowPalette() -> [UIColor] {
        return [
            // Yellow spectrum (top left of painting) - ENHANCED VIBRANCY
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),    // Pure yellow
            UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0),    // Bright golden yellow
            // Orange spectrum (transition) - ENHANCED VIBRANCY
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),    // Pure orange
            UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0),    // Deep orange
            // Red spectrum (top right) - ENHANCED VIBRANCY
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),    // Pure red
            UIColor(red: 1.0, green: 0.0, blue: 0.2, alpha: 1.0),    // Crimson
            // Purple/Magenta spectrum (bottom right) - ENHANCED VIBRANCY
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),    // Pure magenta
            UIColor(red: 0.6, green: 0.0, blue: 1.0, alpha: 1.0),    // Violet
            // Blue spectrum (bottom left) - ENHANCED VIBRANCY
            UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),    // Pure blue
            UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0),    // Sky blue
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),    // Cyan
            // Green spectrum (transition back to yellow) - ENHANCED VIBRANCY
            UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),    // Pure green
            UIColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 1.0)     // Lime green
        ]
    }
    
    /// Creates the main explosion effect
    private static func createMainExplosion(palette: [UIColor], at position: CGPoint, in scene: SKScene) {
        // Create multiple emitters for different colors to get full rainbow in explosion
        for (index, color) in palette.enumerated() {
            let emitter = SKEmitterNode()
            emitter.position = position
            emitter.zPosition = CGFloat(100 + index)
            
            // Use glow textures for each color
            emitter.particleTexture = createGlowTexture(color: color)
            
            // Explosion configuration - 6x more particles per emitter for debugging
            emitter.particleBirthRate = (800 * 6) / CGFloat(palette.count)  // 6x more particles for debugging
            emitter.numParticlesToEmit = 120  // 6x more particles (20 * 6) for debugging
            emitter.particleLifetime = 2.0
            emitter.particleLifetimeRange = 0.5
            
            emitter.particleSize = CGSize(width: 40, height: 40)
            emitter.particleScale = 1.5
            emitter.particleScaleRange = 1.0
            emitter.particleScaleSpeed = -0.8
            
            // CRITICAL: Blend texture with particle color for more vibrant colors
            emitter.particleColorBlendFactor = 1.0  // Full color blending for maximum vibrancy
            emitter.particleColor = color  // Set particle color explicitly
            
            // Explosion pattern - spread out angles for each color with 1.65x wider range
            let angleSpread = (CGFloat.pi * 2) / CGFloat(palette.count)
            let baseAngle = angleSpread * CGFloat(index)
            emitter.emissionAngle = baseAngle
            emitter.emissionAngleRange = angleSpread * 1.2 * 1.65 // 1.65x wider spatial range
            emitter.particleSpeed = 400 * 1.65  // 1.65x wider speed range for wider distribution
            emitter.particleSpeedRange = 100 * 1.65  // 1.65x wider speed variation
            
            // Physics
            emitter.particleAlpha = 1.0
            emitter.particleAlphaSpeed = -0.5
            emitter.yAcceleration = -200
            
            // Use add blend mode for more vibrant, glowing particles
            emitter.particleBlendMode = .add
            
            scene.addChild(emitter)
            
            // Remove after effect completes
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.removeFromParent()
            ])
            emitter.run(removeAction)
        }
    }
    
    /// Creates a ring burst effect
    private static func createRingBurst(palette: [UIColor], at position: CGPoint, in scene: SKScene, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let emitter = SKEmitterNode()
            emitter.position = position
            emitter.zPosition = 101
            
            // Use coast textures for ring burst
            let ringColor = palette[min(1, palette.count - 1)]
            if let coastTexture = getRandomCoastTexture() {
                emitter.particleTexture = coastTexture
                // Apply color tinting to the texture
                emitter.particleColor = ringColor
                emitter.particleColorBlendFactor = 0.8  // Allow some color blending
            } else {
                // Fallback to glow texture if coast texture not found
                emitter.particleTexture = createGlowTexture(color: ringColor)
                emitter.particleColorBlendFactor = 0.0
            }
            
            // Ring configuration - 6x more particles for debugging
            emitter.particleBirthRate = 800 * 6  // 6x more particles for debugging
            emitter.numParticlesToEmit = 900  // 6x more particles (150 * 6) for debugging
            emitter.particleLifetime = 1.5
            emitter.particleLifetimeRange = 0.3
            
            emitter.particleSize = CGSize(width: 24, height: 24)
            emitter.particleScale = 1.2
            emitter.particleScaleRange = 0.5
            emitter.particleScaleSpeed = -0.7
            
            // Ring pattern - 1.65x wider spatial range
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = CGFloat.pi * 2
            emitter.particleSpeed = 300 * 1.65  // 1.65x wider speed for wider distribution
            emitter.particleSpeedRange = 50 * 1.65  // 1.65x wider speed variation
            
            // Physics
            emitter.particleAlpha = 1.0
            emitter.particleAlphaSpeed = -0.6
            emitter.yAcceleration = -100
            
            // Rotation for sparkle
            emitter.particleRotation = 0
            emitter.particleRotationRange = CGFloat.pi * 2
            emitter.particleRotationSpeed = CGFloat.pi * 4
            
            // Use add blend mode for more vibrant, glowing particles
            emitter.particleBlendMode = .add
            
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
        // 6x more sparkle emitters (20 * 6 = 120) for debugging
        for i in 0..<120 {
            let delay = Double(i) * 0.025  // Reduced delay to accommodate more sparkles
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // 1.65x wider spatial range for sparkle positioning
                let sparklePosition = CGPoint(
                    x: position.x + CGFloat.random(in: -165...165),  // 1.65x wider (-100 * 1.65)
                    y: position.y + CGFloat.random(in: -165...165)   // 1.65x wider (-100 * 1.65)
                )
                
                let emitter = SKEmitterNode()
                emitter.position = sparklePosition
                emitter.zPosition = 102
                
                // Use coast textures for sparkles
                let sparkleColor = palette.randomElement() ?? UIColor.white
                if let coastTexture = getCoastTexture(index: i % coastTextures.count) {
                    emitter.particleTexture = coastTexture
                    emitter.particleColor = sparkleColor
                    emitter.particleColorBlendFactor = 0.9  // Strong color tinting for sparkles
                } else {
                    // Fallback to soft particle if texture not found
                    emitter.particleTexture = createSoftParticle(color: sparkleColor)
                    emitter.particleColorBlendFactor = 0.0
                }
                
                // Sparkle configuration - 6x more particles per sparkle for debugging
                emitter.particleBirthRate = 180  // 6x more particles (30 * 6) for debugging
                emitter.numParticlesToEmit = 60  // 6x more particles (10 * 6) for debugging
                emitter.particleLifetime = 1.0
                emitter.particleLifetimeRange = 0.3
                
                emitter.particleSize = CGSize(width: 16, height: 16)
                emitter.particleScale = 1.0
                emitter.particleScaleRange = 0.5
                emitter.particleScaleSpeed = -0.8
                
                // Gentle movement with 1.65x wider range
                emitter.emissionAngle = -CGFloat.pi / 2
                emitter.emissionAngleRange = CGFloat.pi / 4 * 1.65  // 1.65x wider angle range
                emitter.particleSpeed = 50 * 1.65  // 1.65x wider speed for distribution
                emitter.particleSpeedRange = 30 * 1.65  // 1.65x wider speed variation
                
                emitter.particleAlpha = 0.9
                emitter.particleAlphaSpeed = -0.8
                emitter.yAcceleration = 30  // Float upward
                
                // Use add blend mode for more vibrant, glowing sparkles
                emitter.particleBlendMode = .add
                
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
        // 6x more trailing star directions (6 * 6 = 36) for debugging
        for i in 0..<36 {
            let angle = Double(i) * .pi / 18.0  // Adjusted angle distribution for 36 trails
            let emitter = SKEmitterNode()
            emitter.position = position
            emitter.zPosition = 99
            
            // Use coast textures for trails
            let trailColor = palette[min(2, palette.count - 1)]
            if let coastTexture = getCoastTexture(index: i % coastTextures.count) {
                emitter.particleTexture = coastTexture
                emitter.particleColor = trailColor
                emitter.particleColorBlendFactor = 0.7  // Moderate color blending for trails
            } else {
                // Fallback to flame texture if coast texture not found
                emitter.particleTexture = createFlameTexture(color: trailColor)
                emitter.particleColorBlendFactor = 0.0
            }
            
            // Trail configuration - 6x more particles per trail for debugging
            emitter.particleBirthRate = 1200  // 6x more particles (200 * 6) for debugging
            emitter.numParticlesToEmit = 600  // 6x more particles (100 * 6) for debugging
            emitter.particleLifetime = 1.5
            emitter.particleLifetimeRange = 0.5
            
            emitter.particleSize = CGSize(width: 20, height: 30)
            emitter.particleScale = 1.0
            emitter.particleScaleRange = 0.5
            emitter.particleScaleSpeed = -0.5
            
            // Directional emission with 1.65x wider range
            emitter.emissionAngle = CGFloat(angle)
            emitter.emissionAngleRange = CGFloat.pi / 12 * 1.65  // 1.65x wider angle range
            emitter.particleSpeed = 500 * 1.65  // 1.65x wider speed for distribution
            emitter.particleSpeedRange = 100 * 1.65  // 1.65x wider speed variation
            
            emitter.particleAlpha = 1.0
            emitter.particleAlphaSpeed = -0.6
            emitter.yAcceleration = -80
            
            // Use add blend mode for more vibrant, glowing trails
            emitter.particleBlendMode = .add
            
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