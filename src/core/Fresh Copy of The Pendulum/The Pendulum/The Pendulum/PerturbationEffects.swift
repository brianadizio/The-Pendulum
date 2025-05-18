import SpriteKit

// MARK: - Perturbation Visual Effects

class PerturbationEffects {
    // Shared instance
    static let shared = PerturbationEffects()
    
    // Create particle effect for impulse (strong force)
    func createImpulseEffect(at position: CGPoint, direction: CGFloat, magnitude: Double) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Enhanced particle properties for more immersive effect with randomness
        emitter.particleBirthRate = 500 + CGFloat.random(in: -100...100)
        emitter.numParticlesToEmit = Int(100 * min(magnitude * 3, 5))
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.5
        emitter.particleSize = CGSize(width: 12, height: 12)
        emitter.particleScale = 1.5
        emitter.particleScaleRange = 1.0
        emitter.particleScaleSpeed = -1.2
        emitter.particleColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleSpeed = 300 + CGFloat.random(in: -50...50)
        emitter.particleSpeedRange = 150
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.5
        emitter.particleAlphaSpeed = -1.8
        emitter.emissionAngle = direction > 0 ? 0 : .pi
        emitter.emissionAngleRange = 1.2
        emitter.position = position
        
        // Add rotation for more dynamic effects
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = CGFloat.random(in: -2...2)
        
        // Enhanced glow effect
        emitter.particleBlendMode = .add
        emitter.targetNode = nil
        
        // Scale effect based on magnitude with increased impact
        emitter.particleScale *= CGFloat(min(1.5 + abs(magnitude) * 1.5, 3.0))
        
        // More vibrant colors based on direction and theme
        let currentTheme = BackgroundManager.shared.getThemeColors()
        if direction > 0 {
            emitter.particleColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0) // Intense orange
            // Create diverse color sequence based on theme
            let colorVariants = getImpulseColorVariants(for: currentTheme, positive: true)
            emitter.particleColorSequence = SKKeyframeSequence(
                keyframeValues: colorVariants,
                times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            )
        } else {
            emitter.particleColor = SKColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0) // Intense blue
            // Create diverse color sequence based on theme
            let colorVariants = getImpulseColorVariants(for: currentTheme, positive: false)
            emitter.particleColorSequence = SKKeyframeSequence(
                keyframeValues: colorVariants,
                times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            )
        }
        
        // Add color blend factor randomness
        emitter.particleColorBlendFactorRange = 0.3
        emitter.particleColorBlendFactorSpeed = 0.5
        
        return emitter
    }
    
    // Create particle effect for wind (gentle force)
    func createWindEffect(at position: CGPoint, direction: CGFloat, magnitude: Double) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Enhanced wind particle properties for more immersive effect with randomness
        emitter.particleBirthRate = 200 + CGFloat.random(in: -50...50)
        emitter.numParticlesToEmit = Int(80 * min(magnitude * 3, 5))
        emitter.particleLifetime = 1.5
        emitter.particleLifetimeRange = 0.8
        emitter.particleSize = CGSize(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 2...4))
        emitter.particleScale = 1.5
        emitter.particleScaleRange = 0.8
        emitter.particleScaleSpeed = CGFloat.random(in: 0.3...0.7)
        emitter.particleColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.8)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleSpeed = 250 + CGFloat.random(in: -30...30)
        emitter.particleSpeedRange = 120
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.4
        emitter.particleAlphaSpeed = CGFloat.random(in: -0.8 ... -0.4)
        emitter.emissionAngle = direction > 0 ? 0 : .pi
        emitter.emissionAngleRange = 0.8
        emitter.position = position
        
        // Enhanced visual effects with more randomness
        emitter.particleBlendMode = .add
        emitter.particleRotation = CGFloat.random(in: -0.5...0.5)
        emitter.particleRotationRange = .pi / 2
        emitter.particleRotationSpeed = CGFloat.random(in: 0.5...1.5)
        
        // Scale effect based on magnitude with enhanced impact
        emitter.particleScale *= CGFloat(min(1.2 + abs(magnitude) * 1.2, 3.0))
        
        // More pronounced color variations based on direction and theme
        let currentTheme = BackgroundManager.shared.getThemeColors()
        if direction > 0 {
            emitter.particleColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.8) // Brighter blue
            // Create diverse color sequence based on theme
            let colorVariants = getWindColorVariants(for: currentTheme, positive: true)
            emitter.particleColorSequence = SKKeyframeSequence(
                keyframeValues: colorVariants,
                times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            )
        } else {
            emitter.particleColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.8) // Softer blue
            // Create diverse color sequence based on theme
            let colorVariants = getWindColorVariants(for: currentTheme, positive: false)
            emitter.particleColorSequence = SKKeyframeSequence(
                keyframeValues: colorVariants,
                times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            )
        }
        
        // Add color blend factor randomness
        emitter.particleColorBlendFactorRange = 0.3
        emitter.particleColorBlendFactorSpeed = 0.3
        
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
        // Calculate shake amount based on magnitude (increased for more impact)
        let shakeAmount = CGFloat(min(abs(magnitude) * 12, 20))
        
        // Create more dramatic shake sequence
        let shakeSequence = SKAction.sequence([
            SKAction.moveBy(x: -shakeAmount, y: -shakeAmount/2, duration: 0.04),
            SKAction.moveBy(x: shakeAmount*2, y: shakeAmount/3, duration: 0.04),
            SKAction.moveBy(x: -shakeAmount*2, y: shakeAmount, duration: 0.04),
            SKAction.moveBy(x: shakeAmount*1.5, y: -shakeAmount*1.5, duration: 0.04),
            SKAction.moveBy(x: -shakeAmount, y: shakeAmount/2, duration: 0.04),
            SKAction.moveBy(x: shakeAmount/2, y: 0, duration: 0.05),
            SKAction.moveBy(x: 0, y: 0, duration: 0.06) // Settle
        ])
        
        // Add a slight zoom effect for extra impact
        let zoomIn = SKAction.scale(to: 1.02, duration: 0.1)
        let zoomOut = SKAction.scale(to: 1.0, duration: 0.15)
        let zoomSequence = SKAction.sequence([zoomIn, zoomOut])
        
        return SKAction.group([shakeSequence, zoomSequence])
    }
    
    // Create haptic feedback based on perturbation strength
    func generateHapticFeedback(for magnitude: Double) {
        #if os(iOS)
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
    
    // MARK: - Theme-based Color Variants
    
    private func getImpulseColorVariants(for theme: BackgroundManager.ThemeColors, positive: Bool) -> [SKColor] {
        switch theme {
        case .golden:
            if positive {
                return [
                    SKColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0),   // Pale yellow
                    SKColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0), // Golden yellow
                    SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0),  // Amber
                    SKColor(red: 0.9, green: 0.5, blue: 0.0, alpha: 1.0),  // Dark amber
                    SKColor(red: 0.8, green: 0.3, blue: 0.0, alpha: 0.8),  // Burnt orange
                    SKColor(red: 0.6, green: 0.2, blue: 0.0, alpha: 0.6)   // Dark brown
                ]
            } else {
                return [
                    SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0), // Pale blue
                    SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0), // Sky blue
                    SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0),  // Medium blue
                    SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0),  // Royal blue
                    SKColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.8),  // Deep blue
                    SKColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 0.6)   // Dark blue
                ]
            }
            
        case .sunset:
            if positive {
                return [
                    SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1.0),  // Champagne
                    SKColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0),  // Peach
                    SKColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0),  // Coral
                    SKColor(red: 0.9, green: 0.4, blue: 0.5, alpha: 1.0),  // Salmon pink
                    SKColor(red: 0.8, green: 0.3, blue: 0.6, alpha: 0.8),  // Magenta
                    SKColor(red: 0.6, green: 0.2, blue: 0.7, alpha: 0.6)   // Purple
                ]
            } else {
                return [
                    SKColor(red: 0.7, green: 0.6, blue: 0.9, alpha: 1.0),  // Lavender
                    SKColor(red: 0.5, green: 0.4, blue: 0.8, alpha: 1.0),  // Periwinkle
                    SKColor(red: 0.4, green: 0.3, blue: 0.7, alpha: 1.0),  // Violet
                    SKColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 1.0),  // Indigo
                    SKColor(red: 0.2, green: 0.1, blue: 0.5, alpha: 0.8),  // Deep purple
                    SKColor(red: 0.1, green: 0.05, blue: 0.4, alpha: 0.6)  // Midnight
                ]
            }
            
        case .ocean:
            if positive {
                return [
                    SKColor(red: 0.6, green: 1.0, blue: 0.9, alpha: 1.0),  // Aqua mint
                    SKColor(red: 0.4, green: 0.9, blue: 0.8, alpha: 1.0),  // Turquoise
                    SKColor(red: 0.2, green: 0.8, blue: 0.7, alpha: 1.0),  // Teal
                    SKColor(red: 0.0, green: 0.7, blue: 0.6, alpha: 1.0),  // Sea green
                    SKColor(red: 0.0, green: 0.6, blue: 0.5, alpha: 0.8),  // Emerald
                    SKColor(red: 0.0, green: 0.4, blue: 0.4, alpha: 0.6)   // Deep teal
                ]
            } else {
                return [
                    SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0),  // Light cyan
                    SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0),  // Sky blue
                    SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0),  // Ocean blue
                    SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),  // Deep ocean
                    SKColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 0.8),  // Navy
                    SKColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 0.6)   // Midnight blue
                ]
            }
            
        case .forest:
            if positive {
                return [
                    SKColor(red: 0.8, green: 1.0, blue: 0.6, alpha: 1.0),  // Spring green
                    SKColor(red: 0.6, green: 0.9, blue: 0.4, alpha: 1.0),  // Lime
                    SKColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 1.0),  // Grass green
                    SKColor(red: 0.3, green: 0.7, blue: 0.1, alpha: 1.0),  // Forest green
                    SKColor(red: 0.2, green: 0.6, blue: 0.0, alpha: 0.8),  // Deep green
                    SKColor(red: 0.1, green: 0.4, blue: 0.0, alpha: 0.6)   // Dark forest
                ]
            } else {
                return [
                    SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0),  // Sand
                    SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0),  // Beige
                    SKColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 1.0),  // Tan
                    SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0),  // Light brown
                    SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 0.8),  // Brown
                    SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.6)   // Dark brown
                ]
            }
            
        default:
            // Fallback to generic color scheme
            if positive {
                return [
                    SKColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0),
                    SKColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0),
                    SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0),
                    SKColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0),
                    SKColor(red: 0.8, green: 0.2, blue: 0.0, alpha: 0.8),
                    SKColor(red: 0.6, green: 0.1, blue: 0.0, alpha: 0.6)
                ]
            } else {
                return [
                    SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0),
                    SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0),
                    SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
                    SKColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0),
                    SKColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 0.8),
                    SKColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 0.6)
                ]
            }
        }
    }
    
    private func getWindColorVariants(for theme: BackgroundManager.ThemeColors, positive: Bool) -> [SKColor] {
        switch theme {
        case .golden:
            if positive {
                return [
                    SKColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 0.9), // Soft yellow
                    SKColor(red: 0.95, green: 0.9, blue: 0.7, alpha: 0.8), // Pale gold
                    SKColor(red: 0.85, green: 0.8, blue: 0.5, alpha: 0.7), // Light gold
                    SKColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 0.6), // Soft amber
                    SKColor(red: 0.65, green: 0.6, blue: 0.3, alpha: 0.5), // Muted gold
                    SKColor(red: 0.5, green: 0.45, blue: 0.2, alpha: 0.4)  // Faded gold
                ]
            } else {
                return [
                    SKColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 0.9),// Soft blue-white
                    SKColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 0.8),// Pale blue
                    SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.7),  // Light blue
                    SKColor(red: 0.6, green: 0.7, blue: 0.85, alpha: 0.6), // Soft blue
                    SKColor(red: 0.5, green: 0.6, blue: 0.8, alpha: 0.5),  // Muted blue
                    SKColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 0.4)   // Faded blue
                ]
            }
            
        case .sunset:
            if positive {
                return [
                    SKColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 0.9), // Soft pink
                    SKColor(red: 0.95, green: 0.85, blue: 0.8, alpha: 0.8),// Pale rose
                    SKColor(red: 0.9, green: 0.75, blue: 0.7, alpha: 0.7), // Light coral
                    SKColor(red: 0.85, green: 0.65, blue: 0.6, alpha: 0.6),// Soft salmon
                    SKColor(red: 0.8, green: 0.55, blue: 0.5, alpha: 0.5), // Muted rose
                    SKColor(red: 0.7, green: 0.45, blue: 0.4, alpha: 0.4)  // Faded pink
                ]
            } else {
                return [
                    SKColor(red: 0.9, green: 0.85, blue: 0.95, alpha: 0.9),// Soft lavender
                    SKColor(red: 0.8, green: 0.75, blue: 0.9, alpha: 0.8), // Pale purple
                    SKColor(red: 0.7, green: 0.65, blue: 0.85, alpha: 0.7),// Light violet
                    SKColor(red: 0.6, green: 0.55, blue: 0.8, alpha: 0.6), // Soft purple
                    SKColor(red: 0.5, green: 0.45, blue: 0.75, alpha: 0.5),// Muted violet
                    SKColor(red: 0.4, green: 0.35, blue: 0.65, alpha: 0.4) // Faded purple
                ]
            }
            
        case .ocean:
            if positive {
                return [
                    SKColor(red: 0.9, green: 1.0, blue: 0.95, alpha: 0.9), // Soft aqua
                    SKColor(red: 0.8, green: 0.95, blue: 0.9, alpha: 0.8), // Pale turquoise
                    SKColor(red: 0.7, green: 0.9, blue: 0.85, alpha: 0.7), // Light cyan
                    SKColor(red: 0.6, green: 0.85, blue: 0.8, alpha: 0.6), // Soft teal
                    SKColor(red: 0.5, green: 0.8, blue: 0.75, alpha: 0.5), // Muted aqua
                    SKColor(red: 0.4, green: 0.7, blue: 0.65, alpha: 0.4)  // Faded teal
                ]
            } else {
                return [
                    SKColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 0.9), // Soft sky
                    SKColor(red: 0.75, green: 0.85, blue: 0.95, alpha: 0.8),// Pale ocean
                    SKColor(red: 0.65, green: 0.8, blue: 0.9, alpha: 0.7), // Light sea
                    SKColor(red: 0.55, green: 0.75, blue: 0.85, alpha: 0.6),// Soft blue
                    SKColor(red: 0.45, green: 0.65, blue: 0.8, alpha: 0.5),// Muted ocean
                    SKColor(red: 0.35, green: 0.55, blue: 0.7, alpha: 0.4) // Faded blue
                ]
            }
            
        case .forest:
            if positive {
                return [
                    SKColor(red: 0.9, green: 1.0, blue: 0.85, alpha: 0.9), // Soft lime
                    SKColor(red: 0.8, green: 0.95, blue: 0.75, alpha: 0.8),// Pale green
                    SKColor(red: 0.7, green: 0.9, blue: 0.65, alpha: 0.7), // Light grass
                    SKColor(red: 0.6, green: 0.85, blue: 0.55, alpha: 0.6),// Soft green
                    SKColor(red: 0.5, green: 0.8, blue: 0.45, alpha: 0.5), // Muted lime
                    SKColor(red: 0.4, green: 0.7, blue: 0.35, alpha: 0.4)  // Faded green
                ]
            } else {
                return [
                    SKColor(red: 0.95, green: 0.9, blue: 0.85, alpha: 0.9),// Soft cream
                    SKColor(red: 0.9, green: 0.85, blue: 0.75, alpha: 0.8),// Pale sand
                    SKColor(red: 0.85, green: 0.8, blue: 0.65, alpha: 0.7),// Light beige
                    SKColor(red: 0.8, green: 0.75, blue: 0.55, alpha: 0.6),// Soft tan
                    SKColor(red: 0.7, green: 0.65, blue: 0.45, alpha: 0.5),// Muted brown
                    SKColor(red: 0.6, green: 0.55, blue: 0.35, alpha: 0.4) // Faded earth
                ]
            }
            
        default:
            // Fallback to generic wind colors
            if positive {
                return [
                    SKColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 0.9),
                    SKColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 0.8),
                    SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 0.7),
                    SKColor(red: 0.7, green: 0.8, blue: 0.85, alpha: 0.6),
                    SKColor(red: 0.6, green: 0.75, blue: 0.8, alpha: 0.5),
                    SKColor(red: 0.5, green: 0.65, blue: 0.75, alpha: 0.4)
                ]
            } else {
                return [
                    SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.9),
                    SKColor(red: 0.8, green: 0.9, blue: 0.95, alpha: 0.8),
                    SKColor(red: 0.7, green: 0.85, blue: 0.9, alpha: 0.7),
                    SKColor(red: 0.6, green: 0.8, blue: 0.85, alpha: 0.6),
                    SKColor(red: 0.5, green: 0.7, blue: 0.8, alpha: 0.5),
                    SKColor(red: 0.4, green: 0.6, blue: 0.75, alpha: 0.4)
                ]
            }
        }
    }
}