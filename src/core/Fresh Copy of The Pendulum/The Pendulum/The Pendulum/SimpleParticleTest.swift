import UIKit
import SpriteKit

// Simple test to verify particle colors
class SimpleParticleTest {
    
    static func testParticleColors() {
        // Create test scene
        let scene = SKScene(size: CGSize(width: 500, height: 500))
        scene.backgroundColor = .darkGray
        
        // Test each color palette
        for (index, palette) in DynamicParticleManager.allPalettes.enumerated() {
            print("Testing palette \(index):")
            
            for (colorIndex, color) in palette.enumerated() {
                // Get RGB values
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                print("  Color \(colorIndex): R:\(red), G:\(green), B:\(blue), A:\(alpha)")
                
                // Create simple emitter
                let emitter = SKEmitterNode()
                emitter.position = CGPoint(x: 100 + CGFloat(colorIndex) * 50, y: 250)
                
                // Create colored texture using new texture methods
                let texture = DynamicParticleManager.createGlowTexture(color: color, size: CGSize(width: 64, height: 64))
                emitter.particleTexture = texture
                
                // Simple settings
                emitter.particleBirthRate = 10
                emitter.particleLifetime = 2
                emitter.particleSize = CGSize(width: 30, height: 30)
                emitter.particleScale = 1.0
                emitter.particleScaleRange = 0
                emitter.particleScaleSpeed = 0
                
                // Direct color assignment
                emitter.particleColor = color
                emitter.particleColorBlendFactor = 0.0  // No blending
                
                emitter.particleSpeed = 0
                emitter.yAcceleration = 0
                
                scene.addChild(emitter)
            }
            
            // Save scene as image for debugging
            let renderer = UIGraphicsImageRenderer(size: scene.size)
            let image = renderer.image { context in
                scene.view?.layer.render(in: context.cgContext)
            }
            
            print("Created test scene for palette \(index)")
        }
    }
    
    static func createSimpleColoredParticle(color: UIColor, at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Create a simple colored dot texture
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Fill with solid color
            ctx.setFillColor(color.cgColor)
            ctx.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        
        emitter.particleTexture = SKTexture(image: image)
        emitter.position = position
        
        // Simple settings
        emitter.particleBirthRate = 100
        emitter.particleLifetime = 1
        emitter.particleSize = size
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5
        
        // No color blending - use texture color
        emitter.particleColorBlendFactor = 0.0
        
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2
        
        return emitter
    }
}