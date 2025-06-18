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
    
    // MARK: - Mode-Specific Curved Particle Effects
    
    // Create curved particle effect for specific perturbation modes using existing particle systems
    func createCurvedPerturbationEffect(
        mode: PerturbationType,
        at position: CGPoint,
        direction: CGFloat,
        magnitude: Double,
        scene: SKNode
    ) -> SKNode {
        let effectNode = SKNode()
        effectNode.position = position
        
        switch mode {
        case .impulse:
            let impulseEffect = createCurvedImpulseEffect(direction: direction, magnitude: magnitude)
            effectNode.addChild(impulseEffect)
            
        case .sine:
            let sineEffect = createCurvedSineEffect(direction: direction, magnitude: magnitude)
            effectNode.addChild(sineEffect)
            
        case .dataSet:
            let dataEffect = createCurvedDataSetEffect(direction: direction, magnitude: magnitude)
            effectNode.addChild(dataEffect)
            
        case .random:
            let randomEffect = createCurvedRandomEffect(direction: direction, magnitude: magnitude)
            effectNode.addChild(randomEffect)
            
        case .compound:
            let compoundEffect = createCurvedCompoundEffect(direction: direction, magnitude: magnitude)
            effectNode.addChild(compoundEffect)
        }
        
        return effectNode
    }
    
    // Create curved impulse effect - explosive radial burst with directional bias using existing particles
    private func createCurvedImpulseEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(15 + magnitude * 25)
        
        // Use existing coast textures and colors from DynamicParticleManager
        let colors = DynamicParticleManager.orangeRedPalette // Intense colors for impulse
        
        // Create curved burst pattern
        for i in 0..<particleCount {
            // Use coast texture if available, fallback to colored particle
            let particle: SKNode
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 8...16), height: CGFloat.random(in: 8...16))
                textureParticle.color = colors[i % colors.count]
                textureParticle.colorBlendFactor = 0.7
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
                shapeParticle.fillColor = colors[i % colors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.3)
                shapeParticle.glowWidth = 2.0
                particle = shapeParticle
            }
            
            // Calculate curved trajectory with strong directional bias
            let baseAngle = direction > 0 ? 0 : CGFloat.pi
            let angleSpread = CGFloat.pi / 2.5 // Wide spread for explosive effect
            let particleAngle = baseAngle + CGFloat.random(in: -angleSpread/2...angleSpread/2)
            
            // Create curved path with more dramatic curves
            let distance = CGFloat(60 + magnitude * 120)
            let curvature = CGFloat.random(in: 0.4...1.0) * (direction > 0 ? 1 : -1)
            
            let startPoint = CGPoint.zero
            let controlPoint = CGPoint(
                x: cos(particleAngle) * distance * 0.6 + curvature * 40,
                y: sin(particleAngle) * distance * 0.6 + CGFloat.random(in: -25...25)
            )
            let endPoint = CGPoint(
                x: cos(particleAngle) * distance,
                y: sin(particleAngle) * distance + curvature * 50
            )
            
            particle.position = startPoint
            particle.zPosition = CGFloat(i)
            
            // Create curved path animation with explosive dynamics
            let path = CGMutablePath()
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint, control: controlPoint)
            
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 0.7)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.8, duration: 0.15),
                SKAction.scale(to: 0.1, duration: 0.55)
            ])
            let rotation = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi*2...CGFloat.pi*2), duration: 0.7)
            
            particle.run(SKAction.group([followPath, fadeOut, scale, rotation]))
            container.addChild(particle)
        }
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
        
        return container
    }
    
    // Create curved sine effect - flowing wave pattern using existing particles
    private func createCurvedSineEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(12 + magnitude * 20)
        
        // Use blue-teal palette for smooth sine waves
        let colors = DynamicParticleManager.blueTealPalette
        
        // Create flowing sine wave pattern
        for i in 0..<particleCount {
            // Use star textures for flowing effect
            let particle: SKNode
            if let starTexture = DynamicParticleManager.getCoastTexture(index: i % 9) {
                let textureParticle = SKSpriteNode(texture: starTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
                textureParticle.color = colors[i % colors.count]
                textureParticle.colorBlendFactor = 0.6
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                shapeParticle.fillColor = colors[i % colors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.2)
                shapeParticle.alpha = 0.8
                particle = shapeParticle
            }
            
            // Calculate wave parameters with directional flow
            let waveLength: CGFloat = 150
            let amplitude: CGFloat = CGFloat(25 + magnitude * 40)
            let phase = CGFloat(i) / CGFloat(particleCount) * CGFloat.pi * 2
            
            // Create smooth sine wave path
            let path = CGMutablePath()
            let steps = 60
            
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let x = t * waveLength * (direction > 0 ? 1 : -1)
                let y = sin(t * CGFloat.pi * 3 + phase) * amplitude * sin(t * CGFloat.pi) // Envelope
                
                if step == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(i)
            
            // Create smooth flowing animation with staggered timing
            let delay = Double(i) * 0.08
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 1.8)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let gentlePulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.4),
                SKAction.scale(to: 0.9, duration: 0.4)
            ])
            let gentleRotation = SKAction.rotate(byAngle: CGFloat.pi, duration: 1.8)
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([followPath, fadeIn, gentleRotation]),
                SKAction.repeat(gentlePulse, count: 2),
                fadeOut
            ])
            
            particle.run(sequence)
            container.addChild(particle)
        }
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ]))
        
        return container
    }
    
    // Create curved data set effect - structured geometric patterns using existing particles
    private func createCurvedDataSetEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(10 + magnitude * 18)
        
        // Use rainbow colors for data visualization
        let fullRainbow = DynamicParticleManager.createFullRainbowPalette()
        
        // Create geometric spiral pattern
        for i in 0..<particleCount {
            // Alternate between different shapes for data variety
            let particle: SKNode
            if i % 3 == 0 {
                // Use coast texture
                if let coastTexture = DynamicParticleManager.getCoastTexture(index: i % 9) {
                    let textureParticle = SKSpriteNode(texture: coastTexture)
                    textureParticle.size = CGSize(width: 8, height: 8)
                    textureParticle.color = fullRainbow[i % fullRainbow.count]
                    textureParticle.colorBlendFactor = 0.8
                    particle = textureParticle
                } else {
                    let shapeParticle = SKShapeNode(rectOf: CGSize(width: 6, height: 6))
                    shapeParticle.fillColor = fullRainbow[i % fullRainbow.count]
                    shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.4)
                    particle = shapeParticle
                }
            } else if i % 3 == 1 {
                // Hexagon for data points
                let hexagon = SKShapeNode()
                let path = CGMutablePath()
                for j in 0..<6 {
                    let angle = CGFloat(j) * CGFloat.pi / 3
                    let point = CGPoint(x: cos(angle) * 4, y: sin(angle) * 4)
                    if j == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
                hexagon.path = path
                hexagon.fillColor = fullRainbow[i % fullRainbow.count]
                hexagon.strokeColor = hexagon.fillColor.withAlphaComponent(0.3)
                hexagon.glowWidth = 1.5
                particle = hexagon
            } else {
                // Triangle for data points
                let triangle = SKShapeNode()
                let trianglePath = CGMutablePath()
                trianglePath.move(to: CGPoint(x: 0, y: 5))
                trianglePath.addLine(to: CGPoint(x: -4, y: -3))
                trianglePath.addLine(to: CGPoint(x: 4, y: -3))
                trianglePath.closeSubpath()
                triangle.path = trianglePath
                triangle.fillColor = fullRainbow[i % fullRainbow.count]
                triangle.strokeColor = triangle.fillColor.withAlphaComponent(0.3)
                particle = triangle
            }
            
            // Calculate data-driven spiral parameters
            let spiralTurns: CGFloat = 3.0
            let maxRadius: CGFloat = CGFloat(50 + magnitude * 80)
            let angleStep = (spiralTurns * CGFloat.pi * 2) / CGFloat(particleCount)
            let currentAngle = CGFloat(i) * angleStep
            let radius = (CGFloat(i) / CGFloat(particleCount)) * maxRadius
            
            // Apply directional bias to spiral
            let biasAngle = direction > 0 ? 0 : CGFloat.pi
            let finalAngle = currentAngle + biasAngle
            
            // Create precise data spiral path
            let path = CGMutablePath()
            let steps = 40
            
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let stepAngle = finalAngle * t
                let stepRadius = radius * t
                let x = cos(stepAngle) * stepRadius
                let y = sin(stepAngle) * stepRadius
                
                if step == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(i)
            
            // Create precise data animation
            let delay = Double(i) * 0.1
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: true, duration: 1.4)
            let preciseRotation = SKAction.rotate(byAngle: CGFloat.pi * 6, duration: 1.4)
            let dataFadeOut = SKAction.fadeOut(withDuration: 0.5)
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([followPath, preciseRotation]),
                dataFadeOut
            ])
            
            particle.run(sequence)
            container.addChild(particle)
        }
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.removeFromParent()
        ]))
        
        return container
    }
    
    // Create curved random effect - chaotic swirling patterns using existing particles
    private func createCurvedRandomEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(6 + magnitude * 12)
        
        // Use mixed spectrum palette for chaotic random effects
        let mixedColors = DynamicParticleManager.mixedSpectrumPalette
        
        // Create chaotic swirl patterns
        for i in 0..<particleCount {
            // Random particle types for chaos
            let particle: SKNode
            let randomType = Int.random(in: 0...2)
            
            if randomType == 0 && Int.random(in: 0...1) == 0 {
                // Use star texture for sparkle chaos
                if let starTexture = DynamicParticleManager.getCoastTexture(index: Int.random(in: 0...8)) {
                    let textureParticle = SKSpriteNode(texture: starTexture)
                    textureParticle.size = CGSize(width: CGFloat.random(in: 4...10), height: CGFloat.random(in: 4...10))
                    textureParticle.color = mixedColors[i % mixedColors.count]
                    textureParticle.colorBlendFactor = CGFloat.random(in: 0.4...0.9)
                    particle = textureParticle
                } else {
                    let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
                    shapeParticle.fillColor = mixedColors[i % mixedColors.count]
                    shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.4)
                    particle = shapeParticle
                }
            } else {
                // Create random geometric shapes
                let shapes = ["circle", "square", "diamond"]
                let shapeType = shapes.randomElement()!
                
                switch shapeType {
                case "circle":
                    let circle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                    circle.fillColor = mixedColors[i % mixedColors.count]
                    circle.strokeColor = circle.fillColor.withAlphaComponent(0.3)
                    particle = circle
                case "square":
                    let size = CGFloat.random(in: 4...8)
                    let square = SKShapeNode(rectOf: CGSize(width: size, height: size))
                    square.fillColor = mixedColors[i % mixedColors.count]
                    square.strokeColor = square.fillColor.withAlphaComponent(0.3)
                    particle = square
                default: // diamond
                    let diamond = SKShapeNode()
                    let diamondPath = CGMutablePath()
                    let size: CGFloat = CGFloat.random(in: 3...6)
                    diamondPath.move(to: CGPoint(x: 0, y: size))
                    diamondPath.addLine(to: CGPoint(x: size, y: 0))
                    diamondPath.addLine(to: CGPoint(x: 0, y: -size))
                    diamondPath.addLine(to: CGPoint(x: -size, y: 0))
                    diamondPath.closeSubpath()
                    diamond.path = diamondPath
                    diamond.fillColor = mixedColors[i % mixedColors.count]
                    diamond.strokeColor = diamond.fillColor.withAlphaComponent(0.3)
                    particle = diamond
                }
            }
            
            // Create truly random curved path with strong directional bias
            let path = CGMutablePath()
            let steps = Int.random(in: 25...45)
            var currentPoint = CGPoint.zero
            
            path.move(to: currentPoint)
            
            for step in 1...steps {
                let randomAngle = CGFloat.random(in: -CGFloat.pi...CGFloat.pi)
                let directionBias = direction > 0 ? CGFloat.random(in: 0.2...0.6) : CGFloat.random(in: -0.6...(-0.2))
                let biasedAngle = randomAngle + directionBias
                
                let stepDistance = CGFloat.random(in: 4...12)
                let nextPoint = CGPoint(
                    x: currentPoint.x + cos(biasedAngle) * stepDistance,
                    y: currentPoint.y + sin(biasedAngle) * stepDistance
                )
                
                // Add chaotic curvature
                let controlPoint = CGPoint(
                    x: (currentPoint.x + nextPoint.x) / 2 + CGFloat.random(in: -15...15),
                    y: (currentPoint.y + nextPoint.y) / 2 + CGFloat.random(in: -15...15)
                )
                
                path.addQuadCurve(to: nextPoint, control: controlPoint)
                currentPoint = nextPoint
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(i)
            
            // Create truly chaotic animation
            let delay = Double.random(in: 0...0.8)
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: Double.random(in: 1.0...2.0))
            let chaoticRotation = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi*4...CGFloat.pi*4), duration: Double.random(in: 0.8...1.5))
            let fadeOut = SKAction.fadeOut(withDuration: Double.random(in: 0.4...0.8))
            let chaoticScale = SKAction.sequence([
                SKAction.scale(to: CGFloat.random(in: 0.3...2.5), duration: Double.random(in: 0.2...0.5)),
                SKAction.scale(to: 0.05, duration: Double.random(in: 0.5...1.0))
            ])
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([followPath, chaoticRotation, chaoticScale]),
                fadeOut
            ])
            
            particle.run(sequence)
            container.addChild(particle)
        }
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.removeFromParent()
        ]))
        
        return container
    }
    
    // Create curved compound effect - combination of multiple patterns using existing particles
    private func createCurvedCompoundEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        
        // Create multiple effect layers with reduced intensity to avoid overwhelming
        let impulseLayer = createCurvedImpulseEffect(direction: direction, magnitude: magnitude * 0.5)
        let sineLayer = createCurvedSineEffect(direction: direction, magnitude: magnitude * 0.4)
        let dataLayer = createCurvedDataSetEffect(direction: direction, magnitude: magnitude * 0.3)
        let randomLayer = createCurvedRandomEffect(direction: direction, magnitude: magnitude * 0.2)
        
        // Add slight offsets for visual depth and complexity
        impulseLayer.position = CGPoint(x: 0, y: 0)
        sineLayer.position = CGPoint(x: CGFloat.random(in: -8...8), y: CGFloat.random(in: -8...8))
        dataLayer.position = CGPoint(x: CGFloat.random(in: -12...12), y: CGFloat.random(in: -12...12))
        randomLayer.position = CGPoint(x: CGFloat.random(in: -6...6), y: CGFloat.random(in: -6...6))
        
        // Set different z-positions for layering
        impulseLayer.zPosition = 10
        sineLayer.zPosition = 8
        dataLayer.zPosition = 6
        randomLayer.zPosition = 4
        
        // Add with cascading delays for complex compound effect
        container.addChild(impulseLayer)
        
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.run { container.addChild(sineLayer) }
        ]))
        
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run { container.addChild(dataLayer) }
        ]))
        
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.45),
            SKAction.run { container.addChild(randomLayer) }
        ]))
        
        // Add compound-specific envelope effect
        let envelopeParticleCount = Int(8 + magnitude * 12)
        for i in 0..<envelopeParticleCount {
            let delay = Double(i) * 0.1 + 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let glowTexture = DynamicParticleManager.getRandomCoastTexture() {
                    let envelope = SKSpriteNode(texture: glowTexture)
                    envelope.size = CGSize(width: CGFloat.random(in: 12...20), height: CGFloat.random(in: 12...20))
                    envelope.color = DynamicParticleManager.yellowGoldPalette[i % DynamicParticleManager.yellowGoldPalette.count]
                    envelope.colorBlendFactor = 0.5
                    envelope.alpha = 0.6
                    envelope.position = CGPoint(
                        x: CGFloat.random(in: -40...40),
                        y: CGFloat.random(in: -40...40)
                    )
                    envelope.zPosition = 2
                    
                    container.addChild(envelope)
                    
                    // Envelope animation
                    let envelopeAction = SKAction.sequence([
                        SKAction.group([
                            SKAction.scale(to: 2.0, duration: 0.8),
                            SKAction.fadeOut(withDuration: 0.8),
                            SKAction.rotate(byAngle: CGFloat.pi, duration: 0.8)
                        ])
                    ])
                    
                    envelope.run(envelopeAction)
                }
            }
        }
        
        // Remove container after all animations complete
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 4.0),
            SKAction.removeFromParent()
        ]))
        
        return container
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