import SpriteKit
import UIKit

class DynamicParticleManager {
    
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
    
    // MARK: - Simplified shape-based particle creation for color debugging
    
    /// Creates a simple shape-based particle effect using the proper color palette
    static func createLevelCompletionEffect(for level: Int, at position: CGPoint, in scene: SKScene) {
        print("Creating level completion effect for level \(level)")
        
        // Select color palette based on level
        let paletteIndex = (level - 1) % allPalettes.count
        let selectedPalette = allPalettes[paletteIndex]
        
        print("Using palette index \(paletteIndex) for level \(level)")
        print("Selected palette has \(selectedPalette.count) colors")
        
        // Create simple shape-based particles first to ensure colors work
        createSimpleColoredShapes(palette: selectedPalette, at: position, in: scene)
        
        // Create emitter with proper colors
        let mainEffect = createColoredFireworkEmitter(palette: selectedPalette, at: position)
        scene.addChild(mainEffect)
        
        // Remove after effect completes
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ])
        mainEffect.run(removeAction)
    }
    
    /// Creates simple colored shapes to verify colors are working
    static func createSimpleColoredShapes(palette: [UIColor], at position: CGPoint, in scene: SKScene) {
        // Create 30 colored circles using the palette
        for i in 0..<30 {
            let colorIndex = i % palette.count
            let color = palette[colorIndex]
            
            // Create a simple colored circle
            let circle = SKShapeNode(circleOfRadius: 8)
            circle.fillColor = color
            circle.strokeColor = .clear
            circle.position = position
            circle.zPosition = 150
            
            scene.addChild(circle)
            
            // Animate outward in a firework pattern
            let angle = CGFloat(i) * (CGFloat.pi * 2) / 30
            let distance = CGFloat.random(in: 150...300)
            
            let moveAction = SKAction.move(by: CGVector(
                dx: cos(angle) * distance,
                dy: sin(angle) * distance
            ), duration: 1.5)
            
            let fadeAction = SKAction.fadeOut(withDuration: 1.5)
            let scaleAction = SKAction.scale(to: 0.2, duration: 1.5)
            
            let groupAction = SKAction.group([moveAction, fadeAction, scaleAction])
            let sequence = SKAction.sequence([
                groupAction,
                SKAction.removeFromParent()
            ])
            
            circle.run(sequence)
        }
    }
    
    /// Creates a colored particle texture (made public for testing)
    public static func createColoredParticleTexture(color: UIColor) -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Draw a simple colored circle
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Get the image
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    /// Creates a colored emitter with no texture - just colored particles
    static func createColoredFireworkEmitter(palette: [UIColor], at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // No texture - just basic colored dots
        emitter.particleTexture = nil
        
        // Firework burst configuration
        emitter.particleBirthRate = 800
        emitter.numParticlesToEmit = 200
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5
        
        // Size
        emitter.particleSize = CGSize(width: 12, height: 12)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.4
        
        // Use first color from palette directly
        emitter.particleColor = palette.first ?? UIColor.orange
        emitter.particleColorBlendFactor = 1.0
        
        // Create color sequence to cycle through palette
        if palette.count > 1 {
            var keyframeValues: [UIColor] = []
            var times: [NSNumber] = []
            
            for (index, color) in palette.enumerated() {
                keyframeValues.append(color)
                times.append(NSNumber(value: Float(index) / Float(palette.count - 1)))
            }
            
            emitter.particleColorSequence = SKKeyframeSequence(
                keyframeValues: keyframeValues,
                times: times
            )
        }
        
        // Burst pattern
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2
        emitter.particleSpeed = 300
        emitter.particleSpeedRange = 100
        
        // Physics
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.5
        emitter.yAcceleration = -100
        
        // Position and blend mode
        emitter.position = position
        emitter.zPosition = 100
        emitter.particleBlendMode = .alpha
        
        return emitter
    }
}