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
    
    // Create curved impulse effect - explosive AI-like particles with directional bias
    private func createCurvedImpulseEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(25 + magnitude * 35)
        
        // Use existing coast textures and colors from DynamicParticleManager
        let colors = DynamicParticleManager.orangeRedPalette // Intense colors for impulse
        
        // Create explosive AI-like burst pattern
        for i in 0..<particleCount {
            // Create glowing particles similar to AI effects
            let particle: SKNode
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 15...25), height: CGFloat.random(in: 15...25))
                textureParticle.color = colors[i % colors.count]
                textureParticle.colorBlendFactor = 0.8
                textureParticle.blendMode = .add
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...10))
                shapeParticle.fillColor = colors[i % colors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.5)
                shapeParticle.glowWidth = 4.0
                shapeParticle.blendMode = .add
                particle = shapeParticle
            }
            
            // Calculate explosive trajectory with strong directional bias
            let baseAngle = direction > 0 ? 0 : CGFloat.pi
            let angleSpread = CGFloat.pi / 2.2 // Wide spread for explosive effect
            let particleAngle = baseAngle + CGFloat.random(in: -angleSpread/2...angleSpread/2)
            
            // Create curved path with more dramatic curves
            let distance = CGFloat(80 + magnitude * 140)
            let curvature = CGFloat.random(in: 0.3...0.8) * (direction > 0 ? 1 : -1)
            
            let path = CGMutablePath()
            let steps = 25
            
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                
                // Explosive outward motion with curvature
                let explosionFactor = pow(t, 0.7) // Faster initial expansion
                let x = cos(particleAngle) * distance * explosionFactor + sin(t * CGFloat.pi) * curvature * 40
                let y = sin(particleAngle) * distance * explosionFactor + cos(t * CGFloat.pi * 0.5) * curvature * 30
                
                if step == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(particleCount - i)
            particle.alpha = 0
            
            // Create explosive animation
            let delay = Double(i) * 0.015 // Rapid emission
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 0.8)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let scale = SKAction.sequence([
                SKAction.scale(to: 2.0, duration: 0.15),
                SKAction.scale(to: 0.05, duration: 0.65)
            ])
            let rotation = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi*3...CGFloat.pi*3), duration: 0.8)
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([fadeIn, followPath, scale, rotation]),
                fadeOut
            ])
            
            particle.run(sequence)
            container.addChild(particle)
        }
        
        // Add explosion glow effect
        let explosionGlow = SKShapeNode(circleOfRadius: 60)
        explosionGlow.fillColor = colors[0].withAlphaComponent(0.4)
        explosionGlow.strokeColor = .clear
        explosionGlow.blendMode = .add
        explosionGlow.zPosition = -1
        explosionGlow.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.5, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ])
        ]))
        container.addChild(explosionGlow)
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
        
        return container
    }
    
    // Create curved sine effect - AI-like particles following sine wave trajectories
    private func createCurvedSineEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(20 + magnitude * 30)
        
        // Use blue-teal palette for sine waves
        let colors = DynamicParticleManager.blueTealPalette
        
        // Create AI-like particles that move in sine wave patterns
        for i in 0..<particleCount {
            // Create glowing particle similar to AI effects
            let particle: SKNode
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 12...20), height: CGFloat.random(in: 12...20))
                textureParticle.color = colors[i % colors.count]
                textureParticle.colorBlendFactor = 0.8
                textureParticle.blendMode = .add
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...8))
                shapeParticle.fillColor = colors[i % colors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.5)
                shapeParticle.glowWidth = 3.0
                shapeParticle.blendMode = .add
                particle = shapeParticle
            }
            
            // Calculate sine wave trajectory
            let distance = CGFloat(80 + magnitude * 100)
            let amplitude = CGFloat(30 + magnitude * 50)
            let frequency = CGFloat.random(in: 2...4)
            let phase = CGFloat(i) / CGFloat(particleCount) * CGFloat.pi * 2
            let speed = CGFloat.random(in: 0.8...1.2)
            
            // Create AI-like curved path with sine wave modulation
            let path = CGMutablePath()
            let steps = 30
            let baseAngle = direction > 0 ? 0 : CGFloat.pi
            
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                
                // Base movement in direction with spreading
                let spread = CGFloat.random(in: -0.3...0.3)
                let x = cos(baseAngle + spread) * distance * t
                
                // Sine wave modulation for y-position
                let sineOffset = sin(t * frequency * CGFloat.pi + phase) * amplitude * (1.0 - t * 0.5)
                let y = sin(baseAngle + spread) * distance * t + sineOffset
                
                if step == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(particleCount - i) // Higher particles render on top
            particle.alpha = 0
            
            // Create dynamic animation similar to AI particles
            let delay = Double(i) * 0.04 // Staggered emission
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 1.2 * Double(speed))
            let fadeIn = SKAction.fadeAlpha(to: 0.9, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.3),
                SKAction.scale(to: 0.1, duration: 0.9)
            ])
            let rotation = SKAction.rotate(byAngle: CGFloat.pi * frequency, duration: 1.2 * Double(speed))
            
            // Add pulsing effect
            let pulse = SKAction.sequence([
                SKAction.scale(by: 1.2, duration: 0.1),
                SKAction.scale(by: 0.833, duration: 0.1)
            ])
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    fadeIn,
                    SKAction.group([followPath, scale, rotation]),
                    SKAction.repeat(pulse, count: Int(frequency))
                ]),
                fadeOut
            ])
            
            particle.run(sequence)
            container.addChild(particle)
        }
        
        // Add additional glow effect for sine wave
        let glowNode = SKShapeNode(circleOfRadius: 40)
        glowNode.fillColor = colors[0].withAlphaComponent(0.2)
        glowNode.strokeColor = .clear
        glowNode.blendMode = .add
        glowNode.zPosition = -1
        glowNode.run(SKAction.sequence([
            SKAction.scale(to: 3.0, duration: 1.5),
            SKAction.fadeOut(withDuration: 1.5)
        ]))
        container.addChild(glowNode)
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
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
    
    // Create curved random effect - AI-like particles with chaotic movements
    private func createCurvedRandomEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let particleCount = Int(15 + magnitude * 25)
        
        // Use mixed spectrum palette for chaotic random effects
        let mixedColors = DynamicParticleManager.mixedSpectrumPalette
        
        // Create AI-like particles with chaotic behavior
        for i in 0..<particleCount {
            // Create glowing particles similar to AI effects
            let particle: SKNode
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 10...20), height: CGFloat.random(in: 10...20))
                textureParticle.color = mixedColors[i % mixedColors.count]
                textureParticle.colorBlendFactor = CGFloat.random(in: 0.6...0.9)
                textureParticle.blendMode = .add
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...8))
                shapeParticle.fillColor = mixedColors[i % mixedColors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.5)
                shapeParticle.glowWidth = CGFloat.random(in: 2...4)
                shapeParticle.blendMode = .add
                particle = shapeParticle
            }
            
            // Create truly random curved path with directional bias
            let path = CGMutablePath()
            let steps = 30
            let baseAngle = direction > 0 ? 0 : CGFloat.pi
            
            // Random walk with directional tendency
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var velocity = CGVector(dx: cos(baseAngle) * 5, dy: sin(baseAngle) * 5)
            
            path.move(to: CGPoint(x: currentX, y: currentY))
            
            for step in 1...steps {
                let t = CGFloat(step) / CGFloat(steps)
                
                // Apply random acceleration with directional bias
                let randomAccel = CGVector(
                    dx: CGFloat.random(in: -3...3) + cos(baseAngle) * 2,
                    dy: CGFloat.random(in: -3...3) + sin(baseAngle) * 2
                )
                
                velocity.dx += randomAccel.dx
                velocity.dy += randomAccel.dy
                
                // Apply damping
                velocity.dx *= 0.95
                velocity.dy *= 0.95
                
                // Update position
                currentX += velocity.dx
                currentY += velocity.dy
                
                // Add chaotic control point
                let controlX = currentX + CGFloat.random(in: -20...20) * (1 - t)
                let controlY = currentY + CGFloat.random(in: -20...20) * (1 - t)
                
                path.addQuadCurve(
                    to: CGPoint(x: currentX, y: currentY),
                    control: CGPoint(x: controlX, y: controlY)
                )
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(particleCount - i)
            particle.alpha = 0
            
            // Create chaotic animation
            let delay = Double.random(in: 0...0.5)
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: Double.random(in: 1.0...1.8))
            let fadeIn = SKAction.fadeAlpha(to: CGFloat.random(in: 0.7...1.0), duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: Double.random(in: 0.3...0.6))
            let chaoticRotation = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi*6...CGFloat.pi*6), duration: Double.random(in: 1.0...1.8))
            let chaoticScale = SKAction.sequence([
                SKAction.scale(to: CGFloat.random(in: 1.2...2.0), duration: Double.random(in: 0.2...0.4)),
                SKAction.scale(to: 0.05, duration: Double.random(in: 0.8...1.4))
            ])
            
            // Add random pulsing
            let pulse = SKAction.sequence([
                SKAction.scale(by: 1.3, duration: 0.1),
                SKAction.scale(by: 0.77, duration: 0.1)
            ])
            let randomPulseCount = Int.random(in: 0...3)
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    fadeIn,
                    followPath,
                    chaoticRotation,
                    chaoticScale,
                    SKAction.repeat(pulse, count: randomPulseCount)
                ]),
                fadeOut
            ])
            
            particle.run(sequence)
            container.addChild(particle)
        }
        
        // Add chaotic glow bursts
        for _ in 0..<3 {
            let glowBurst = SKShapeNode(circleOfRadius: CGFloat.random(in: 20...40))
            glowBurst.fillColor = mixedColors.randomElement()!.withAlphaComponent(0.3)
            glowBurst.strokeColor = .clear
            glowBurst.blendMode = .add
            glowBurst.position = CGPoint(
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -30...30)
            )
            glowBurst.zPosition = -1
            
            let glowDelay = Double.random(in: 0...0.8)
            glowBurst.alpha = 0
            glowBurst.run(SKAction.sequence([
                SKAction.wait(forDuration: glowDelay),
                SKAction.fadeAlpha(to: 0.3, duration: 0.1),
                SKAction.group([
                    SKAction.scale(to: CGFloat.random(in: 2...3), duration: 0.6),
                    SKAction.fadeOut(withDuration: 0.6)
                ])
            ]))
            container.addChild(glowBurst)
        }
        
        // Remove container after animation
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.removeFromParent()
        ]))
        
        return container
    }
    
    // Create curved compound effect - AI-like particles with multiple behavior patterns
    private func createCurvedCompoundEffect(direction: CGFloat, magnitude: Double) -> SKNode {
        let container = SKNode()
        let totalParticleCount = Int(30 + magnitude * 40)
        
        // Use mixed spectrum palette for compound effects
        let primaryColors = DynamicParticleManager.yellowGoldPalette
        let secondaryColors = DynamicParticleManager.mixedSpectrumPalette
        
        // Create three distinct particle groups that combine behaviors
        let groupSize = totalParticleCount / 3
        
        // Group 1: Explosive burst with sine wave aftereffect
        for i in 0..<groupSize {
            let particle: SKNode
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 14...22), height: CGFloat.random(in: 14...22))
                textureParticle.color = primaryColors[i % primaryColors.count]
                textureParticle.colorBlendFactor = 0.7
                textureParticle.blendMode = .add
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...9))
                shapeParticle.fillColor = primaryColors[i % primaryColors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.6)
                shapeParticle.glowWidth = 4.0
                shapeParticle.blendMode = .add
                particle = shapeParticle
            }
            
            // Explosive burst followed by sine wave
            let baseAngle = direction > 0 ? 0 : CGFloat.pi
            let angleSpread = CGFloat.random(in: -CGFloat.pi/3...CGFloat.pi/3)
            let distance = CGFloat(100 + magnitude * 120)
            
            let path = CGMutablePath()
            let steps = 40
            
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                
                // Initial burst (first 30% of animation)
                if t < 0.3 {
                    let burstT = t / 0.3
                    let x = cos(baseAngle + angleSpread) * distance * burstT * 0.6
                    let y = sin(baseAngle + angleSpread) * distance * burstT * 0.6
                    
                    if step == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                } else {
                    // Sine wave motion (remaining 70%)
                    let sineT = (t - 0.3) / 0.7
                    let baseX = cos(baseAngle + angleSpread) * distance * 0.6
                    let baseY = sin(baseAngle + angleSpread) * distance * 0.6
                    
                    let sineOffset = sin(sineT * CGFloat.pi * 3) * 30 * (1 - sineT)
                    let x = baseX + cos(baseAngle + angleSpread + CGFloat.pi/2) * sineOffset
                    let y = baseY + sin(baseAngle + angleSpread + CGFloat.pi/2) * sineOffset
                    
                    path.addLine(to: CGPoint(x: x + cos(baseAngle) * distance * sineT * 0.4, 
                                           y: y + sin(baseAngle) * distance * sineT * 0.4))
                }
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(totalParticleCount - i)
            particle.alpha = 0
            
            let delay = Double(i) * 0.02
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 1.5)
            let fadeIn = SKAction.fadeAlpha(to: 0.95, duration: 0.15)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.8, duration: 0.2),
                SKAction.scale(to: 0.05, duration: 1.3)
            ])
            let rotation = SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 1.5)
            
            particle.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([fadeIn, followPath, scale, rotation]),
                fadeOut
            ]))
            
            container.addChild(particle)
        }
        
        // Group 2: Spiral pattern with random perturbations
        for i in 0..<groupSize {
            let particle: SKNode
            let colorIndex = i + groupSize
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 10...18), height: CGFloat.random(in: 10...18))
                textureParticle.color = secondaryColors[colorIndex % secondaryColors.count]
                textureParticle.colorBlendFactor = 0.8
                textureParticle.blendMode = .add
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...7))
                shapeParticle.fillColor = secondaryColors[colorIndex % secondaryColors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.4)
                shapeParticle.glowWidth = 2.5
                shapeParticle.blendMode = .add
                particle = shapeParticle
            }
            
            // Spiral with random perturbations
            let path = CGMutablePath()
            let steps = 35
            let spiralTurns = CGFloat(2.5)
            let maxRadius = CGFloat(80 + magnitude * 100)
            
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let angle = t * spiralTurns * CGFloat.pi * 2 + (direction > 0 ? 0 : CGFloat.pi)
                let radius = t * maxRadius
                
                // Add random perturbations
                let randomX = CGFloat.random(in: -10...10) * t
                let randomY = CGFloat.random(in: -10...10) * t
                
                let x = cos(angle) * radius + randomX
                let y = sin(angle) * radius + randomY
                
                if step == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            particle.position = CGPoint.zero
            particle.zPosition = CGFloat(totalParticleCount - colorIndex)
            particle.alpha = 0
            
            let delay = Double(i) * 0.03 + 0.1
            let followPath = SKAction.follow(path, asOffset: true, orientToPath: true, duration: 1.3)
            let fadeIn = SKAction.fadeAlpha(to: 0.85, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.4, duration: 0.4),
                SKAction.scale(to: 0.1, duration: 0.9)
            ])
            let rotation = SKAction.rotate(byAngle: CGFloat.pi * spiralTurns * 2, duration: 1.3)
            
            particle.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([fadeIn, followPath, scale, rotation]),
                fadeOut
            ]))
            
            container.addChild(particle)
        }
        
        // Group 3: Pulsing wave front
        for i in 0..<groupSize {
            let particle: SKNode
            let colorIndex = i + groupSize * 2
            if let coastTexture = DynamicParticleManager.getRandomCoastTexture() {
                let textureParticle = SKSpriteNode(texture: coastTexture)
                textureParticle.size = CGSize(width: CGFloat.random(in: 16...24), height: CGFloat.random(in: 16...24))
                textureParticle.color = primaryColors[colorIndex % primaryColors.count]
                textureParticle.colorBlendFactor = 0.6
                textureParticle.blendMode = .add
                particle = textureParticle
            } else {
                let shapeParticle = SKShapeNode(circleOfRadius: CGFloat.random(in: 7...10))
                shapeParticle.fillColor = primaryColors[colorIndex % primaryColors.count]
                shapeParticle.strokeColor = shapeParticle.fillColor.withAlphaComponent(0.7)
                shapeParticle.glowWidth = 5.0
                shapeParticle.blendMode = .add
                particle = shapeParticle
            }
            
            // Wave front pattern
            let angle = (CGFloat(i) / CGFloat(groupSize)) * CGFloat.pi * 2
            let waveRadius = CGFloat(60 + magnitude * 80)
            let startX = cos(angle) * 20
            let startY = sin(angle) * 20
            let endX = cos(angle) * waveRadius * (direction > 0 ? 1 : -1)
            let endY = sin(angle) * waveRadius
            
            particle.position = CGPoint(x: startX, y: startY)
            particle.zPosition = CGFloat(colorIndex)
            particle.alpha = 0
            
            let delay = 0.3 + Double(i) * 0.01
            let moveAction = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.8)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 2.0, duration: 0.2),
                SKAction.scale(to: 0.5, duration: 0.6)
            ])
            
            particle.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([fadeIn, moveAction, pulse]),
                fadeOut
            ]))
            
            container.addChild(particle)
        }
        
        // Add central glow effect
        let centralGlow = SKShapeNode(circleOfRadius: 50)
        centralGlow.fillColor = primaryColors[0].withAlphaComponent(0.3)
        centralGlow.strokeColor = .clear
        centralGlow.blendMode = .add
        centralGlow.zPosition = -1
        centralGlow.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.5, duration: 1.8),
                SKAction.fadeOut(withDuration: 1.8)
            ])
        ]))
        container.addChild(centralGlow)
        
        // Remove container after all animations complete
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
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