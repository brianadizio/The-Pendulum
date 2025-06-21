import SpriteKit
import UIKit

// MARK: - Perturbation Visualizer
class PerturbationVisualizer {
    // Scene reference
    weak var scene: PendulumScene?
    
    // Visualization nodes
    private var waveformNode: SKShapeNode?
    private var waveformPath: CGMutablePath?
    private var dataPointNodes: [SKShapeNode] = []
    private var perturbationIndicator: SKNode?
    private var magnitudeBar: SKShapeNode?
    private var directionArrow: SKShapeNode?
    
    // Waveform history for visualization
    private var waveformHistory: [CGFloat] = []
    private let maxHistoryPoints = 100
    
    // Colors for different modes
    private let sineWaveColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.8)
    private let dataColor = UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 0.8)
    private let compoundColor = UIColor(red: 0.8, green: 0.3, blue: 0.8, alpha: 0.8)
    
    // Current visualization mode
    private var currentMode: String = ""
    
    init(scene: PendulumScene) {
        self.scene = scene
        setupVisualizationComponents()
    }
    
    private func setupVisualizationComponents() {
        guard let scene = scene else { return }
        
        // Create perturbation indicator container
        perturbationIndicator = SKNode()
        perturbationIndicator?.position = CGPoint(x: scene.size.width - 150, y: scene.size.height - 100)
        perturbationIndicator?.zPosition = 100
        scene.addChild(perturbationIndicator!)
        
        // Create waveform display
        waveformNode = SKShapeNode()
        waveformNode?.strokeColor = sineWaveColor
        waveformNode?.lineWidth = 2.0
        waveformNode?.glowWidth = 1.0
        waveformNode?.position = CGPoint(x: -100, y: 0)
        perturbationIndicator?.addChild(waveformNode!)
        
        // Create magnitude bar
        let barBackground = SKShapeNode(rect: CGRect(x: 0, y: -50, width: 10, height: 100))
        barBackground.fillColor = UIColor.darkGray.withAlphaComponent(0.3)
        barBackground.strokeColor = UIColor.lightGray
        barBackground.lineWidth = 1.0
        perturbationIndicator?.addChild(barBackground)
        
        magnitudeBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 0))
        magnitudeBar?.fillColor = sineWaveColor
        magnitudeBar?.strokeColor = .clear
        perturbationIndicator?.addChild(magnitudeBar!)
        
        // Create direction arrow
        directionArrow = createDirectionArrow()
        directionArrow?.position = CGPoint(x: 30, y: 0)
        perturbationIndicator?.addChild(directionArrow!)
        
        // Add labels
        let waveformLabel = SKLabelNode(text: "Perturbation")
        waveformLabel.fontSize = 12
        waveformLabel.fontColor = .white
        waveformLabel.position = CGPoint(x: -50, y: 60)
        perturbationIndicator?.addChild(waveformLabel)
        
        let magnitudeLabel = SKLabelNode(text: "Force")
        magnitudeLabel.fontSize = 10
        magnitudeLabel.fontColor = .white
        magnitudeLabel.position = CGPoint(x: 5, y: -70)
        perturbationIndicator?.addChild(magnitudeLabel)
    }
    
    private func createDirectionArrow() -> SKShapeNode {
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: 0, y: -20))
        arrowPath.addLine(to: CGPoint(x: 0, y: 20))
        arrowPath.move(to: CGPoint(x: 0, y: 20))
        arrowPath.addLine(to: CGPoint(x: -10, y: 10))
        arrowPath.move(to: CGPoint(x: 0, y: 20))
        arrowPath.addLine(to: CGPoint(x: 10, y: 10))
        
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = sineWaveColor
        arrow.lineWidth = 3.0
        arrow.glowWidth = 1.0
        
        return arrow
    }
    
    // MARK: - Mode Activation
    
    func activateForMode(_ mode: String) {
        currentMode = mode
        waveformHistory.removeAll()
        
        // Reset visualization
        perturbationIndicator?.isHidden = false
        
        // Set colors based on mode
        switch mode {
        case "sine":
            updateColors(sineWaveColor)
            showSineWaveIndicator()
        case "data":
            updateColors(dataColor)
            showDataDrivenIndicator()
        case "compound":
            updateColors(compoundColor)
            showCompoundIndicator()
        default:
            perturbationIndicator?.isHidden = true
        }
    }
    
    func deactivate() {
        perturbationIndicator?.isHidden = true
        perturbationIndicator?.removeAllChildren()
        perturbationIndicator?.removeFromParent()
        waveformHistory.removeAll()
        clearDataPoints()
    }
    
    private func updateColors(_ color: UIColor) {
        waveformNode?.strokeColor = color
        magnitudeBar?.fillColor = color
        directionArrow?.strokeColor = color
    }
    
    // MARK: - Mode-Specific Visualizations
    
    private func showSineWaveIndicator() {
        // Add sine wave animation
        guard let scene = scene else { return }
        
        // Create smooth sine wave preview
        let sinePreview = SKShapeNode()
        let sinePath = CGMutablePath()
        
        let amplitude: CGFloat = 30
        let frequency: CGFloat = 2
        let width: CGFloat = 200
        
        sinePath.move(to: CGPoint(x: -width/2, y: 0))
        
        for x in stride(from: -width/2, through: width/2, by: 2) {
            let y = amplitude * sin(frequency * x * CGFloat.pi / width)
            sinePath.addLine(to: CGPoint(x: x, y: y))
        }
        
        sinePreview.path = sinePath
        sinePreview.strokeColor = sineWaveColor
        sinePreview.lineWidth = 2.0
        sinePreview.glowWidth = 2.0
        sinePreview.position = CGPoint(x: scene.size.width/2, y: scene.size.height - 50)
        sinePreview.zPosition = 110
        scene.addChild(sinePreview)
        
        // Animate the sine wave
        let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 2.0)
        let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 2.0)
        let sequence = SKAction.sequence([moveLeft, moveRight])
        sinePreview.run(SKAction.repeatForever(sequence))
        
        // Remove after 5 seconds
        sinePreview.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showDataDrivenIndicator() {
        guard let scene = scene else { return }
        
        // Create data visualization preview
        let dataPreview = SKNode()
        dataPreview.position = CGPoint(x: scene.size.width/2, y: scene.size.height - 50)
        dataPreview.zPosition = 110
        scene.addChild(dataPreview)
        
        // Create random data points
        for i in 0..<10 {
            let dataPoint = SKShapeNode(circleOfRadius: 3)
            dataPoint.fillColor = dataColor
            dataPoint.strokeColor = dataColor.withAlphaComponent(0.5)
            dataPoint.glowWidth = 2.0
            
            let x = CGFloat(i - 5) * 20
            let y = CGFloat.random(in: -30...30)
            dataPoint.position = CGPoint(x: x, y: y)
            
            dataPreview.addChild(dataPoint)
            
            // Animate data points
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            let wait = SKAction.wait(forDuration: Double(i) * 0.1)
            let sequence = SKAction.sequence([wait, scaleUp, scaleDown])
            dataPoint.run(SKAction.repeatForever(sequence))
        }
        
        // Remove after 5 seconds
        dataPreview.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showCompoundIndicator() {
        guard let scene = scene else { return }
        
        // Create compound visualization preview
        let compoundPreview = SKNode()
        compoundPreview.position = CGPoint(x: scene.size.width/2, y: scene.size.height - 50)
        compoundPreview.zPosition = 110
        scene.addChild(compoundPreview)
        
        // Create multiple wave layers
        let colors = [
            UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.6),
            UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 0.6),
            UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 0.6)
        ]
        
        for (index, color) in colors.enumerated() {
            let wave = SKShapeNode()
            let wavePath = CGMutablePath()
            
            let amplitude: CGFloat = 20 - CGFloat(index) * 5
            let frequency: CGFloat = CGFloat(index + 1)
            let width: CGFloat = 200
            
            wavePath.move(to: CGPoint(x: -width/2, y: 0))
            
            for x in stride(from: -width/2, through: width/2, by: 2) {
                let y = amplitude * sin(frequency * x * CGFloat.pi / width)
                wavePath.addLine(to: CGPoint(x: x, y: y))
            }
            
            wave.path = wavePath
            wave.strokeColor = color
            wave.lineWidth = 2.0
            wave.glowWidth = 1.0
            compoundPreview.addChild(wave)
            
            // Animate each wave differently
            let duration = 2.0 + Double(index) * 0.5
            let moveLeft = SKAction.moveBy(x: -30, y: 0, duration: duration)
            let moveRight = SKAction.moveBy(x: 30, y: 0, duration: duration)
            let sequence = SKAction.sequence([moveLeft, moveRight])
            wave.run(SKAction.repeatForever(sequence))
        }
        
        // Remove after 5 seconds
        compoundPreview.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Real-time Update
    
    func updateVisualization(magnitude: Double, elapsedTime: TimeInterval) {
        // Update waveform history
        waveformHistory.append(CGFloat(magnitude))
        if waveformHistory.count > maxHistoryPoints {
            waveformHistory.removeFirst()
        }
        
        // Update waveform display
        updateWaveform()
        
        // Update magnitude bar
        updateMagnitudeBar(magnitude)
        
        // Update direction arrow
        updateDirectionArrow(magnitude)
        
        // Generate real-time particle effects
        if abs(magnitude) > 0.1 {
            generateRealtimeParticles(magnitude: magnitude)
        }
        
        // Trigger haptic feedback
        if abs(magnitude) > 0.3 {
            triggerHapticFeedback(magnitude: magnitude)
        }
    }
    
    private func updateWaveform() {
        guard !waveformHistory.isEmpty else { return }
        
        let path = CGMutablePath()
        let width: CGFloat = 200
        let stepWidth = width / CGFloat(maxHistoryPoints)
        
        path.move(to: CGPoint(x: -width/2, y: waveformHistory[0] * 30))
        
        for (index, value) in waveformHistory.enumerated() {
            let x = -width/2 + CGFloat(index) * stepWidth
            let y = value * 30 // Scale for visibility
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        waveformNode?.path = path
    }
    
    private func updateMagnitudeBar(_ magnitude: Double) {
        let height = abs(magnitude) * 50 // Scale to fit bar
        let barRect = CGRect(x: 0, y: 0, width: 10, height: height)
        magnitudeBar?.path = CGPath(rect: barRect, transform: nil)
        
        // Color based on intensity
        let intensity = min(abs(magnitude), 1.0)
        let color: UIColor
        
        switch currentMode {
        case "sine":
            color = sineWaveColor.withAlphaComponent(0.5 + intensity * 0.5)
        case "data":
            color = dataColor.withAlphaComponent(0.5 + intensity * 0.5)
        case "compound":
            color = compoundColor.withAlphaComponent(0.5 + intensity * 0.5)
        default:
            color = .white
        }
        
        magnitudeBar?.fillColor = color
    }
    
    private func updateDirectionArrow(_ magnitude: Double) {
        // Rotate arrow based on direction
        let rotation = magnitude > 0 ? 0 : CGFloat.pi
        directionArrow?.zRotation = rotation
        
        // Scale based on magnitude
        let scale = 0.8 + abs(magnitude) * 0.4
        directionArrow?.setScale(CGFloat(scale))
        
        // Pulse effect for strong forces
        if abs(magnitude) > 0.5 {
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            directionArrow?.run(SKAction.sequence([scaleUp, scaleDown]))
        }
    }
    
    private func generateRealtimeParticles(magnitude: Double) {
        guard let scene = scene else { return }
        
        // Create particle burst at pendulum position
        let particles = SKEmitterNode()
        
        particles.particleBirthRate = 50 * abs(magnitude)
        particles.numParticlesToEmit = Int(20 * abs(magnitude))
        particles.particleLifetime = 0.5
        particles.particleLifetimeRange = 0.2
        particles.particleSize = CGSize(width: 4, height: 4)
        particles.particleScale = 0.5
        particles.particleScaleRange = 0.3
        particles.particleSpeed = 100 * abs(magnitude)
        particles.particleSpeedRange = 50
        
        // Set color based on mode and direction
        switch currentMode {
        case "sine":
            particles.particleColor = magnitude > 0 ? 
                UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.8) :
                UIColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 0.8)
        case "data":
            particles.particleColor = magnitude > 0 ? 
                UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.8) :
                UIColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 0.8)
        case "compound":
            particles.particleColor = magnitude > 0 ? 
                UIColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 0.8) :
                UIColor(red: 0.5, green: 1.0, blue: 1.0, alpha: 0.8)
        default:
            particles.particleColor = .white
        }
        
        particles.particleColorBlendFactor = 1.0
        particles.particleAlpha = 0.8
        particles.particleAlphaSpeed = -1.5
        particles.emissionAngle = magnitude > 0 ? 0 : .pi
        particles.emissionAngleRange = .pi / 3
        
        // Position at pendulum
        particles.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.15)
        particles.zPosition = 30
        
        scene.addChild(particles)
        
        // Remove after emission
        particles.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func triggerHapticFeedback(magnitude: Double) {
        #if os(iOS)
        let impactStyle: UIImpactFeedbackGenerator.FeedbackStyle
        
        if abs(magnitude) > 0.7 {
            impactStyle = .heavy
        } else if abs(magnitude) > 0.5 {
            impactStyle = .medium
        } else {
            impactStyle = .light
        }
        
        let generator = UIImpactFeedbackGenerator(style: impactStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    // MARK: - Data Visualization
    
    func visualizeDataPoint(_ value: Double, index: Int) {
        guard currentMode == "data", let scene = scene else { return }
        
        // Clear old data points if needed
        if dataPointNodes.count > 20 {
            dataPointNodes.first?.removeFromParent()
            dataPointNodes.removeFirst()
        }
        
        // Create new data point
        let dataPoint = SKShapeNode(circleOfRadius: 4)
        dataPoint.fillColor = dataColor
        dataPoint.strokeColor = dataColor.withAlphaComponent(0.5)
        dataPoint.glowWidth = 2.0
        
        // Position based on value
        let x = scene.size.width / 2 + CGFloat(value) * 100
        let y = scene.size.height * 0.15
        dataPoint.position = CGPoint(x: x, y: y)
        dataPoint.zPosition = 35
        
        scene.addChild(dataPoint)
        dataPointNodes.append(dataPoint)
        
        // Animate data point
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let group = SKAction.group([fadeOut, moveUp])
        let sequence = SKAction.sequence([scaleUp, group, SKAction.removeFromParent()])
        
        dataPoint.run(sequence)
    }
    
    private func clearDataPoints() {
        dataPointNodes.forEach { $0.removeFromParent() }
        dataPointNodes.removeAll()
    }
    
    // MARK: - Sound Correlation
    
    func playSoundForPerturbation(_ magnitude: Double) {
        guard let soundManager = (scene as? PendulumScene)?.soundManager else { return }
        
        // Play different sounds based on mode and intensity
        switch currentMode {
        case "sine":
            if abs(magnitude) > 0.5 {
                soundManager.playSound(.windStrong)
            } else if abs(magnitude) > 0.2 {
                soundManager.playSound(.windGentle)
            }
            
        case "data":
            if abs(magnitude) > 0.7 {
                soundManager.playSound(.impulseStrong)
            } else if abs(magnitude) > 0.3 {
                soundManager.playSound(.impulseWeak)
            }
            
        case "compound":
            // Play layered sounds for compound mode
            if abs(magnitude) > 0.5 {
                soundManager.playSound(.windStrong)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    soundManager.playSound(.impulseWeak)
                }
            }
            
        default:
            break
        }
    }
}