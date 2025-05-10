// PendulumScene.swift
import SpriteKit

class PendulumScene: SKScene {
    // Pendulum visual elements
    private let pendulumPivot = SKShapeNode(circleOfRadius: 5)
    private let pendulumRod = SKShapeNode()
    private var pendulumBob = SKShapeNode(circleOfRadius: 15) // Changed to var
    
    // Trail visualization
    private let trailNode = SKNode()
    private let maxTrailPoints = 80
    private var trailPoints: [CGPoint] = []
    
    // Phase space visualization
    private var phaseSpaceNode: SKNode?
    private var phaseSpacePoints: [CGPoint] = []
    private let maxPhasePoints = 100
    
    // Background elements
    private var backgroundType: BackgroundType = .plain
    
    // UI elements
    private var controlButtons: [SKNode] = []
    private var visualizationNodes: [SKNode] = []
    
    // Animation properties
    private var pendulumAnimationTime: TimeInterval = 0
    
    var viewModel: PendulumViewModel?
    
    // Perturbation manager
    var perturbationManager: PerturbationManager?
    
    // Background types
    enum BackgroundType {
        case plain
        case grid
        case particles
        case fluid
    }
    
    override func didMove(to view: SKView) {
        print("PendulumScene: didMove called")
        
        // Log view and scene information for debugging
        print("Scene size: \(self.size)")
        print("View size: \(view.bounds.size)")
        
        // Set up a gradient background based on UI designs
        setupBackground()
        
        // Setup decorative grid for perspective
        setupGrid()
        
        // Setup visualization background elements
        setupVisualizationBackground()
        
        // We'll use the PhaseSpaceView from PendulumViewController instead
        // setupPhaseSpaceVisualization()
        
        // Setup pivot point - more refined design and centered horizontally
        pendulumPivot.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark gray
        pendulumPivot.strokeColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        // Position the pendulum pivot very low in the container (at 15% height)
        // Right near the bottom where it will be just above the buttons
        pendulumPivot.position = CGPoint(x: frame.midX, y: frame.height * 0.15)
        pendulumPivot.lineWidth = 2
        pendulumPivot.glowWidth = 1
        pendulumPivot.zPosition = 10
        addChild(pendulumPivot)

        // Add a platform/base for the inverted pendulum
        setupPlatform()

        // Setup pendulum rod - thicker for better visibility with the longer length
        pendulumRod.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        pendulumRod.lineWidth = 5 // More thickness for better visibility with longer rod
        pendulumRod.zPosition = 5
        addChild(pendulumRod)

        // Setup bob - sized appropriately for the longer pendulum
        pendulumBob = SKShapeNode(circleOfRadius: 18) // Larger bob for better visibility
        pendulumBob.fillColor = UIColor(red: 0.0, green: 0.5, blue: 0.9, alpha: 1.0) // Brighter blue
        pendulumBob.strokeColor = UIColor(red: 0.0, green: 0.3, blue: 0.7, alpha: 1.0)
        pendulumBob.lineWidth = 3 // Thicker stroke
        pendulumBob.glowWidth = 2 // Moderate glow
        pendulumBob.zPosition = 15
        addChild(pendulumBob)
        
        // Setup trail with better appearance
        setupTrailVisualization()
        
        // Setup control buttons (following UI designs in slides)
        setupControlButtonsUI()
        
        // Force update of initial pendulum position
        if let viewModel = viewModel {
            updatePendulumPosition(with: viewModel.currentState)
        } else {
            // If no viewModel, set a default position
            let defaultState = PendulumState(theta: 0.05, thetaDot: 0, time: 0)
            updatePendulumPosition(with: defaultState)
        }
        
        // Print pendulum positions for debugging
        print("PendulumScene: Pivot position: \(pendulumPivot.position)")
        print("PendulumScene: Bob position: \(pendulumBob.position)")
        print("PendulumScene: didMove completed - scene size: \(self.size)")
    }
    
    // Set up a gradient background based on UI design
    private func setupBackground() {
        let gradientNode = SKSpriteNode(color: .clear, size: self.size)
        gradientNode.zPosition = -100
        addChild(gradientNode)
        
        // Create the gradient texture using a different approach - light cream color from UI designs
        let startColor = UIColor(red: 0.98, green: 0.96, blue: 0.9, alpha: 1.0) // Light cream
        let endColor = UIColor(red: 0.95, green: 0.93, blue: 0.87, alpha: 1.0) // Slightly darker cream
        
        // Create a gradient image using UIKit - hide the title block that's still showing
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: self.size)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // This gradient will cover the title area that's still showing

        // Ensure we have a valid size - prevent the zero size error
        let contextSize = CGSize(
            width: max(1, self.size.width),
            height: max(1, self.size.height)
        )

        // Use UIGraphicsImageRenderer when available (iOS 10+)
        let gradientImage: UIImage
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: contextSize)
            gradientImage = renderer.image { ctx in
                gradientLayer.frame = CGRect(origin: .zero, size: contextSize)
                gradientLayer.render(in: ctx.cgContext)
            }
        } else {
            // Fallback for older iOS versions
            UIGraphicsBeginImageContextWithOptions(contextSize, false, 0)
            gradientLayer.frame = CGRect(origin: .zero, size: contextSize)
            if let context = UIGraphicsGetCurrentContext() {
                gradientLayer.render(in: context)
                gradientImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            } else {
                gradientImage = UIImage()
            }
            UIGraphicsEndImageContext()
        }

        let texture = SKTexture(image: gradientImage)
        
        gradientNode.texture = texture
    }
    
    // Setup an enhanced trail visualization
    private func setupTrailVisualization() {
        trailNode.alpha = 0.7
        trailNode.zPosition = 3
        addChild(trailNode)
    }
    
    // Setup phase space visualization (from UI designs)
    private func setupPhaseSpaceVisualization() {
        phaseSpaceNode = SKNode()
        phaseSpaceNode?.position = CGPoint(x: 80, y: frame.height - 120)
        phaseSpaceNode?.zPosition = 20
        
        // Add phase space background
        let phaseSpaceBackground = SKShapeNode(rectOf: CGSize(width: 120, height: 120), cornerRadius: 10)
        phaseSpaceBackground.fillColor = UIColor.white.withAlphaComponent(0.7)
        phaseSpaceBackground.strokeColor = UIColor.gray.withAlphaComponent(0.3)
        phaseSpaceBackground.lineWidth = 1
        phaseSpaceNode?.addChild(phaseSpaceBackground)
        
        // Add axes
        let axesPath = CGMutablePath()
        axesPath.move(to: CGPoint(x: -60, y: 0))
        axesPath.addLine(to: CGPoint(x: 60, y: 0))
        axesPath.move(to: CGPoint(x: 0, y: -60))
        axesPath.addLine(to: CGPoint(x: 0, y: 60))
        
        let axesNode = SKShapeNode(path: axesPath)
        axesNode.strokeColor = UIColor.black.withAlphaComponent(0.4)
        axesNode.lineWidth = 1
        phaseSpaceNode?.addChild(axesNode)
        
        // Add a center point
        let centerPoint = SKShapeNode(circleOfRadius: 3)
        centerPoint.fillColor = .red
        centerPoint.strokeColor = .clear
        phaseSpaceNode?.addChild(centerPoint)
        
        // Add a label
        let label = SKLabelNode(text: "Phase Space")
        label.fontName = "HelveticaNeue"
        label.fontSize = 12
        label.fontColor = UIColor.darkGray
        label.position = CGPoint(x: 0, y: -70)
        label.horizontalAlignmentMode = .center
        phaseSpaceNode?.addChild(label)
        
        // Initialize the phase space trajectory container
        let phaseTrajectoryNode = SKShapeNode()
        phaseTrajectoryNode.strokeColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 0.7)
        phaseTrajectoryNode.lineWidth = 2
        phaseTrajectoryNode.name = "phaseTrajectory"
        phaseSpaceNode?.addChild(phaseTrajectoryNode)
        
        if let phaseSpaceNode = phaseSpaceNode {
            addChild(phaseSpaceNode)
        }
    }
    
    // Setup control buttons UI based on designs
    private func setupControlButtonsUI() {
        // This would implement the control buttons from UI slides
        // Currently we're using the PendulumViewController's buttons
    }
    
    private func setupPlatform() {
        // Create a small ground platform at the bottom for inverted pendulum
        let platformWidth: CGFloat = 80
        let platformHeight: CGFloat = 8

        let platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight))
        platform.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        platform.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        platform.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y + platformHeight/2)
        platform.zPosition = 5
        addChild(platform)

        // Add small decorative base elements
        let baseWidth: CGFloat = 50 // Smaller base for bottom position
        let baseHeight: CGFloat = 12 // Much shorter

        let base = SKShapeNode(rectOf: CGSize(width: baseWidth, height: baseHeight))
        base.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        base.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        base.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y + baseHeight/2 + platformHeight)
        base.zPosition = 6
        addChild(base)

        // Add a tiny vertical support above the pivot for connection to the rod
        let supportWidth: CGFloat = 4
        let supportHeight: CGFloat = 6

        let support = SKShapeNode(rectOf: CGSize(width: supportWidth, height: supportHeight))
        support.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        support.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        support.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y - supportHeight/2)
        support.zPosition = 7
        addChild(support)

        // Add a floor line just below the pendulum base
        let floorPath = CGMutablePath()
        floorPath.move(to: CGPoint(x: 0, y: pendulumPivot.position.y + 15)) // Just below the platform
        floorPath.addLine(to: CGPoint(x: frame.width, y: pendulumPivot.position.y + 15))

        let floor = SKShapeNode(path: floorPath)
        floor.strokeColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        floor.lineWidth = 1
        floor.zPosition = 4
        addChild(floor)
    }
    
    private func setupGrid() {
        // Create a grid for perspective/aesthetic based on UI designs
        let gridNode = SKNode()
        gridNode.alpha = 0.1
        gridNode.zPosition = -50
        
        let horizontalLines = 12
        let verticalLines = 10
        let horizontalSpacing = size.height / CGFloat(horizontalLines)
        let verticalSpacing = size.width / CGFloat(verticalLines)
        
        // Add horizontal grid lines
        for i in 0...horizontalLines {
            let y = CGFloat(i) * horizontalSpacing
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = .darkGray
            line.lineWidth = 1
            gridNode.addChild(line)
        }
        
        // Add vertical grid lines
        for i in 0...verticalLines {
            let x = CGFloat(i) * verticalSpacing
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = .darkGray
            line.lineWidth = 1
            gridNode.addChild(line)
        }
        
        addChild(gridNode)
    }
    
    // Create a modern visualization background based on UI designs
    private func setupVisualizationBackground() {
        let visualBackground = SKNode()
        visualBackground.zPosition = -40
        
        // Create a much larger circular orbit pattern for the very long pendulum
        let orbitRadius = frame.height * 0.65 // Very large radius to match the much longer pendulum
        let orbitNode = SKShapeNode(circleOfRadius: orbitRadius)
        orbitNode.position = pendulumPivot.position // Center on the pendulum pivot
        orbitNode.strokeColor = UIColor.darkGray.withAlphaComponent(0.15) // Slightly more subtle
        orbitNode.lineWidth = 1
        
        // Create a dashed circle using multiple short line segments instead of lineDashPattern
        let dashedOrbitNode = SKNode()
        dashedOrbitNode.position = orbitNode.position
        let segments = 36
        for i in 0..<segments {
            if i % 2 == 0 { // Only add every other segment to create dashes
                let angle1 = CGFloat(i) * 2 * .pi / CGFloat(segments)
                let angle2 = CGFloat(i+1) * 2 * .pi / CGFloat(segments)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: orbitRadius * cos(angle1), y: orbitRadius * sin(angle1)))
                path.addLine(to: CGPoint(x: orbitRadius * cos(angle2), y: orbitRadius * sin(angle2)))
                let segment = SKShapeNode(path: path)
                segment.strokeColor = UIColor.darkGray.withAlphaComponent(0.15)
                segment.lineWidth = 1
                dashedOrbitNode.addChild(segment)
            }
        }
        visualBackground.addChild(dashedOrbitNode)
        visualBackground.addChild(orbitNode)
        
        // Add radius line adjusted for new orbit size
        let radiusPath = CGMutablePath()
        radiusPath.move(to: CGPoint(x: orbitNode.position.x, y: orbitNode.position.y))
        radiusPath.addLine(to: CGPoint(x: orbitNode.position.x + orbitRadius, y: orbitNode.position.y))

        let radiusLine = SKShapeNode(path: radiusPath)
        radiusLine.strokeColor = UIColor.black.withAlphaComponent(0.2)
        radiusLine.lineWidth = 1
        visualBackground.addChild(radiusLine)

        // Add dot at end of radius
        let endDot = SKShapeNode(circleOfRadius: 3)
        endDot.position = CGPoint(x: orbitNode.position.x + orbitRadius, y: orbitNode.position.y)
        endDot.fillColor = UIColor.black.withAlphaComponent(0.3)
        visualBackground.addChild(endDot)
        
        addChild(visualBackground)
    }
    
    // Helper method to update the pendulum position for an inverted pendulum
    private func updatePendulumPosition(with state: PendulumState) {
        let angle = state.theta

        // Use a much longer pendulum rod (2.15x longer)
        // This makes the pendulum extend almost to the top of the container
        let baseLength: CGFloat = frame.height * 0.75 // Approximately 2.15 times the previous length
        let modelLength = viewModel?.length ?? 1.0
        let length = baseLength * CGFloat(modelLength)

        // Calculate bob position based on angle for inverted pendulum
        // For inverted pendulum, the bob is ABOVE the pivot point when at rest (π)
        let bobX = pendulumPivot.position.x + length * sin(angle)
        let bobY = pendulumPivot.position.y - length * cos(angle)
        let bobPosition = CGPoint(x: bobX, y: bobY)

        // Only print the bob position occasionally for debugging
        if Int(angle * 100) % 300 == 0 {
            print("Bob position: \(bobPosition) for angle: \(angle), theta: \(state.theta)")
        }

        // Update rod path with slight curve for aesthetics
        let path = CGMutablePath()
        path.move(to: pendulumPivot.position)

        // Add a slight curve to the rod for a more natural look
        let controlPoint = CGPoint(
            x: pendulumPivot.position.x + length * 0.5 * sin(angle),
            y: pendulumPivot.position.y - length * 0.48 * cos(angle)
        )
        path.addQuadCurve(to: bobPosition, control: controlPoint)
        pendulumRod.path = path

        // Update bob position directly (no animation for now)
        pendulumBob.position = bobPosition

        // Add subtle rotation to the bob based on velocity for more dynamic feel
        let rotationAngle = min(max(CGFloat(state.thetaDot) * 0.1, -0.3), 0.3)
        pendulumBob.run(SKAction.rotate(toAngle: rotationAngle, duration: 0.05))

        // Ensure the bob is always large enough to be visible
        if pendulumBob.frame.width < 40 {
            // Create a new larger bob
            let newBob = SKShapeNode(circleOfRadius: 25)
            newBob.fillColor = UIColor(red: 0.0, green: 0.5, blue: 0.9, alpha: 1.0) // Brighter blue
            newBob.strokeColor = UIColor(red: 0.0, green: 0.3, blue: 0.7, alpha: 1.0)
            newBob.lineWidth = 3
            newBob.glowWidth = 3
            newBob.zPosition = 15
            newBob.position = bobPosition

            pendulumBob.removeFromParent()
            addChild(newBob)
            pendulumBob = newBob
        }

        // Add shadow under the bob if needed
        if pendulumBob.children.isEmpty {
            let shadow = SKShapeNode(circleOfRadius: pendulumBob.frame.width / 2)
            shadow.fillColor = UIColor.black.withAlphaComponent(0.2)
            shadow.strokeColor = .clear
            shadow.position = CGPoint(x: 2, y: -2)
            shadow.zPosition = -1
            pendulumBob.addChild(shadow)
        }
    }
    
    private func drawTestPath() {
        let testNode = SKShapeNode(circleOfRadius: 30)
        testNode.position = CGPoint(x: frame.midX, y: frame.midY)
        testNode.fillColor = .purple
        testNode.strokeColor = .yellow
        testNode.lineWidth = 4
        addChild(testNode)
        print("PendulumScene: Added test circle at center")
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let viewModel = viewModel else { 
            return 
        }
        
        // Update animation time
        pendulumAnimationTime = currentTime
        
        // IMPORTANT: Only update visual elements if simulation is actually running
        // This ensures the pendulum completely stops when stopSimulation() is called
        if viewModel.isSimulating {
            // Update pendulum position
            updatePendulumPosition(with: viewModel.currentState)
            
            // Update trail visualization
            updateTrailVisualization(with: viewModel)
            
            // Update phase space visualization
            updatePhaseSpaceVisualization(with: viewModel.currentState)
            
            // Update perturbation manager if it exists
            if let perturbationManager = self.perturbationManager {
                perturbationManager.update(currentTime: currentTime)
            }
        }
    }
    
    // MARK: - Visualization Updates
    
    // Enhanced trail visualization based on UI designs
    private func updateTrailVisualization(with viewModel: PendulumViewModel) {
        if viewModel.isSimulating {
            let bobPosition = pendulumBob.position
            trailPoints.append(bobPosition)
            if trailPoints.count > maxTrailPoints {
                trailPoints.removeFirst()
            }
            
            let trailPath = CGMutablePath()
            for (i, point) in trailPoints.enumerated() {
                if i == 0 {
                    trailPath.move(to: point)
                } else {
                    trailPath.addLine(to: point)
                }
            }
            
            trailNode.removeAllChildren()
            
            // Create an elegant trail with gradient effect
            let trailLine = SKShapeNode(path: trailPath)
            
            // Create a beautiful trail color gradient - blue to purple/pink
            let trailColor = UIColor(red: 0.0, green: 0.4, blue: 0.9, alpha: 0.3)
            trailLine.strokeColor = trailColor
            trailLine.lineWidth = 3
            
            // Add a glow effect to the trail
            trailLine.blendMode = .screen
            
            trailNode.addChild(trailLine)
            
            // Add indicator dots along the path for visual interest - based on UI designs
            if trailPoints.count > 5 {
                for i in stride(from: 0, to: trailPoints.count, by: 5) {
                    let dotSize = 3.0 * (CGFloat(i) / CGFloat(trailPoints.count))
                    let dot = SKShapeNode(circleOfRadius: dotSize)
                    dot.position = trailPoints[i]
                    
                    // Create color gradient effect for dots
                    let progress = CGFloat(i) / CGFloat(trailPoints.count)
                    let dotColor = UIColor(
                        red: 0.0,
                        green: 0.4 * (1.0 - progress) + 0.2 * progress,
                        blue: 0.9 * (1.0 - progress) + 0.8 * progress,
                        alpha: 0.5
                    )
                    
                    dot.fillColor = dotColor
                    dot.strokeColor = .clear
                    trailNode.addChild(dot)
                }
            }
        }
    }
    
    // Phase space visualization update (from UI slide designs)
    private func updatePhaseSpaceVisualization(with state: PendulumState) {
        // Scale factors for phase space visualization
        let thetaScale: CGFloat = 30.0
        let omegaScale: CGFloat = 15.0
        
        // Calculate normalized phase space position
        let normalizedTheta = state.theta - Double.pi
        let x = CGFloat(normalizedTheta) * thetaScale
        let y = CGFloat(state.thetaDot) * omegaScale
        
        // Add point to phase space trajectory
        if x.isFinite && y.isFinite {
            phaseSpacePoints.append(CGPoint(x: x, y: y))
            if phaseSpacePoints.count > maxPhasePoints {
                phaseSpacePoints.removeFirst()
            }
            
            // Update the phase space visualization
            if let phaseSpaceNode = phaseSpaceNode,
               let trajectoryNode = phaseSpaceNode.childNode(withName: "phaseTrajectory") as? SKShapeNode {
                
                // Create path from points
                let path = CGMutablePath()
                if let firstPoint = phaseSpacePoints.first {
                    path.move(to: firstPoint)
                    for point in phaseSpacePoints.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                
                trajectoryNode.path = path
                
                // Add current position marker
                if let lastPoint = phaseSpacePoints.last {
                    // Remove old current position marker if it exists
                    phaseSpaceNode.childNode(withName: "currentPositionMarker")?.removeFromParent()
                    
                    // Create new marker
                    let marker = SKShapeNode(circleOfRadius: 4)
                    marker.position = lastPoint
                    marker.fillColor = .red
                    marker.name = "currentPositionMarker"
                    phaseSpaceNode.addChild(marker)
                }
            }
        }
    }
    
    // Method to update the pendulum's appearance based on ViewModel parameters
    func updatePendulumAppearance() {
        guard let viewModel = viewModel else { return }
        
        // Update the bob appearance based on mass
        let bobRadius = 10 + CGFloat(viewModel.mass) * 2
        let newBob = SKShapeNode(circleOfRadius: bobRadius)
        newBob.fillColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) // Royal blue
        newBob.strokeColor = UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0)
        newBob.lineWidth = 2
        newBob.glowWidth = 2
        
        // Save position before replacing bob
        let bobPosition = pendulumBob.position
        
        // Remove old bob and its shadow
        pendulumBob.removeFromParent()
        
        // Add new bob to scene
        addChild(newBob)
        pendulumBob = newBob
        pendulumBob.position = bobPosition
        
        // Add shadow to new bob
        let shadow = SKShapeNode(circleOfRadius: bobRadius)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        pendulumBob.addChild(shadow)
        
        // Update the pendulum position to reflect the new length
        updatePendulumPosition(with: viewModel.currentState)
    }

    // MARK: - Particle Effects (Note: These effects are confined to the SpriteKit scene, not the entire UI)

    /// Shows a level completion particle effect
    func showLevelCompletionEffect(at position: CGPoint? = nil) {
        // Instead of single position, create multiple particle systems at various positions
        // This creates a more immersive effect across the screen

        let mainPosition = position ?? CGPoint(x: frame.midX, y: frame.midY)

        // Create multiple particle emission points for immersive effect
        let emissionPoints = [
            mainPosition, // Center
            CGPoint(x: frame.midX * 0.5, y: frame.midY * 0.7), // Lower left
            CGPoint(x: frame.midX * 1.5, y: frame.midY * 0.7), // Lower right
            CGPoint(x: frame.midX * 0.6, y: frame.midY * 1.3), // Upper left
            CGPoint(x: frame.midX * 1.4, y: frame.midY * 1.3), // Upper right
            pendulumBob.position // At the pendulum bob
        ]

        // Different sizes for variety
        let particleSizes = [1.0, 0.8, 0.7, 0.9, 0.6, 1.2]

        // Create effects at each point
        for (index, point) in emissionPoints.enumerated() {
            createRockyFluidParticleEffect(at: point,
                                          scale: particleSizes[min(index, particleSizes.count-1)],
                                          delay: Double(index) * 0.05)
        }

        // Debug print to confirm effect is triggered
        print("Immersive level completion particle effects shown")
    }

    /// Creates a more realistic rocky/fluid particle effect
    private func createRockyFluidParticleEffect(at position: CGPoint, scale: CGFloat, delay: TimeInterval) {
        // Try to load the base particle system
        if let particleSystem = SKEmitterNode(fileNamed: "LevelCompletionParticle") {
            particleSystem.position = position
            particleSystem.zPosition = 100
            addChild(particleSystem)

            // Make it more rocky/realistic by adjusting parameters
            particleSystem.particleBirthRate = 300 * scale // Slightly fewer but more distinct particles
            particleSystem.particleLifetime = 1.5 * scale
            particleSystem.particleScale = 1.2 * scale

            // More jagged/rocky movement
            particleSystem.particleSpeed = 150 * scale
            particleSystem.particleSpeedRange = 100 * scale
            particleSystem.particleRotationRange = 4.0 // Full rotation for sizzling effect
            particleSystem.particleRotationSpeed = 2.0 // Fast rotation

            // Add gravity for a more natural falling effect
            particleSystem.yAcceleration = -150 // Gravity pulling particles down

            // Add random X acceleration for fluid-like turbulence
            particleSystem.xAcceleration = CGFloat.random(in: -30...30) // Random lateral movement

            // More alpha variance for sparkle effect
            particleSystem.particleAlphaRange = 0.6
            particleSystem.particleAlphaSpeed = -0.8 // Faster fade

            // Add a slight delayed start if specified
            if delay > 0 {
                particleSystem.particleBirthRate = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    particleSystem.particleBirthRate = 300 * scale
                }
            }

            // Extremely short lifetime to prevent overlap between level transitions
            particleSystem.particleLifetime = 0.6 // Shorter particle lifetime

            // Stop emission very quickly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // Stop emitting new particles
                particleSystem.particleBirthRate = 0

                // Force cleanup immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    particleSystem.removeFromParent()
                }
            }
        } else {
            // Fallback to creating manual particles if the SKS file isn't available
            createFallbackCompletionEffect(at: position)
        }
    }

    // Fallback effect using SKShapeNodes for level completion if particle system fails
    private func createFallbackCompletionEffect(at position: CGPoint) {
        print("Creating fallback level completion effect")

        // Create multiple circles that expand outward
        for i in 0..<12 {
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.position = position
            circle.fillColor = .clear
            circle.strokeColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Golden color
            circle.lineWidth = 3
            circle.zPosition = 100
            addChild(circle)

            // Random direction and distance
            let angle = CGFloat.random(in: 0..<CGFloat.pi * 2)
            let distance = CGFloat.random(in: 50..<150)
            let destinationX = position.x + cos(angle) * distance
            let destinationY = position.y + sin(angle) * distance

            // Actions
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let expand = SKAction.scale(to: CGFloat.random(in: 1.5..<3.0), duration: 0.7)
            let move = SKAction.move(to: CGPoint(x: destinationX, y: destinationY), duration: 0.7)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)

            // Sequence
            let sequence = SKAction.sequence([
                fadeIn,
                SKAction.group([expand, move]),
                fadeOut,
                SKAction.removeFromParent()
            ])

            // Delay each particle slightly
            let delay = CGFloat(i) * 0.05
            circle.run(SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval(delay)),
                sequence
            ]))
        }
    }

    /// Shows a new level start particle effect
    func showNewLevelEffect(at position: CGPoint? = nil) {
        // Create a scene-wide fluid-like effect to indicate a new level

        // Define quadrants for particle emission
        let quadrants = [
            CGPoint(x: frame.width * 0.25, y: frame.height * 0.25), // Bottom left
            CGPoint(x: frame.width * 0.75, y: frame.height * 0.25), // Bottom right
            CGPoint(x: frame.width * 0.25, y: frame.height * 0.75), // Top left
            CGPoint(x: frame.width * 0.75, y: frame.height * 0.75), // Top right
            CGPoint(x: frame.midX, y: frame.midY),                  // Center
            pendulumBob.position                                     // Pendulum bob
        ]

        // Create flowing particles in each quadrant with different colors and behaviors
        for (index, quadPoint) in quadrants.enumerated() {
            // Slightly staggered creation for more natural flow
            let delay = Double(index) * 0.08

            // Create primary fluid effect
            createRockyFluidNewLevelEffect(
                at: quadPoint,
                scale: CGFloat.random(in: 0.8...1.2),
                delay: delay
            )

            // Create some secondary scattered effects
            for _ in 0..<3 {
                let randomOffset = CGPoint(
                    x: CGFloat.random(in: -50...50),
                    y: CGFloat.random(in: -50...50)
                )
                let scatteredPosition = CGPoint(
                    x: quadPoint.x + randomOffset.x,
                    y: quadPoint.y + randomOffset.y
                )

                createRockyFluidNewLevelEffect(
                    at: scatteredPosition,
                    scale: CGFloat.random(in: 0.4...0.7),
                    delay: delay + Double.random(in: 0.05...0.2)
                )
            }
        }

        // Create a special effect at the pendulum bob (tracking its movement)
        createBobTrackingEffect()

        // Debug print to confirm effect is triggered
        print("Immersive new level particle effects shown")
    }

    /// Creates a more rock/fluid-like particle effect for new level
    private func createRockyFluidNewLevelEffect(at position: CGPoint, scale: CGFloat, delay: TimeInterval) {
        // Try to load the base particle system
        if let particleSystem = SKEmitterNode(fileNamed: "NewLevelParticle") {
            particleSystem.position = position
            particleSystem.zPosition = 100
            addChild(particleSystem)

            // Make it more rock-like with jagged movements - but much shorter lifetime
            particleSystem.particleBirthRate = 300 * scale  // Higher birth rate for quicker effect
            particleSystem.particleLifetime = 0.5 * scale  // Drastically shorter lifetime
            particleSystem.particleScale = 1.0 * scale

            // More sizzling, sparkling movement
            particleSystem.particleSpeed = 100 * scale
            particleSystem.particleSpeedRange = 80 * scale
            particleSystem.particleRotationRange = 2 * .pi // Full rotation range
            particleSystem.particleRotationSpeed = 2.5 // Faster rotation for sizzling feel

            // Physics simulation for more realistic movement
            particleSystem.particleAction = SKAction.sequence([
                SKAction.scale(by: CGFloat.random(in: 0.7...1.3), duration: 0.3),
                SKAction.scale(by: CGFloat.random(in: 0.8...1.2), duration: 0.3)
            ])

            // Natural forces
            particleSystem.yAcceleration = -80 // Gentle gravity
            particleSystem.xAcceleration = CGFloat.random(in: -40...40) // Random drift

            // Color variance for more natural, rocky appearance
            particleSystem.particleColorBlendFactor = 0.8
            particleSystem.particleColorBlendFactorRange = 0.3

            // Add a slight delayed start if specified
            if delay > 0 {
                particleSystem.particleBirthRate = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    particleSystem.particleBirthRate = 250 * scale
                }
            }

            // Extremely short duration to avoid overlap during quick level transitions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Stop emitting new particles immediately
                particleSystem.particleBirthRate = 0

                // Forcefully remove with minimal delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    particleSystem.removeFromParent()
                }
            }
        } else {
            print("Failed to load NewLevelParticle.sks")
            createFallbackNewLevelEffect(at: position)
        }
    }

    /// Creates a particle effect that follows the pendulum bob
    private func createBobTrackingEffect() {
        // Create an extremely brief particle burst attached to the bob
        if let trackingEffect = SKEmitterNode(fileNamed: "NewLevelParticle") {
            pendulumBob.addChild(trackingEffect)
            trackingEffect.position = CGPoint.zero // Relative to bob
            trackingEffect.particleBirthRate = 80  // Higher birth rate for quicker effect
            trackingEffect.particleLifetime = 0.4  // Very short lifetime
            trackingEffect.particleScale = 0.6
            trackingEffect.particleAlphaSpeed = -1.5 // Very fast fade

            // Make particles fall away from the bob
            trackingEffect.emissionAngle = .pi / 2 // Downward
            trackingEffect.emissionAngleRange = .pi / 3

            // Extremely short burst - almost immediate stop
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Stop emission immediately
                trackingEffect.particleBirthRate = 0

                // Force removal quickly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    trackingEffect.removeFromParent()
                }
            }
        }
    }

    // Fallback effect using SKShapeNodes for new level if particle system fails
    private func createFallbackNewLevelEffect(at position: CGPoint) {
        print("Creating fallback new level effect")

        // Create a series of expanding rings
        for i in 0..<6 {
            let ring = SKShapeNode(circleOfRadius: 25)
            ring.position = position
            ring.fillColor = .clear
            ring.strokeColor = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 0.8) // Blue color
            ring.lineWidth = 4
            ring.zPosition = 100
            ring.alpha = 0
            addChild(ring)

            // Delay based on ring index
            let delay = Double(i) * 0.15

            // Actions
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let expand = SKAction.scale(to: 3.5, duration: 0.7)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)

            // Sequence
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                fadeIn,
                expand,
                fadeOut,
                SKAction.removeFromParent()
            ])

            ring.run(sequence)
        }

        // Add some sparkles at the center
        for _ in 0..<15 {
            let sparkle = SKShapeNode(circleOfRadius: 3)
            sparkle.position = position
            sparkle.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0) // Bright yellow
            sparkle.strokeColor = .clear
            sparkle.zPosition = 101
            addChild(sparkle)

            // Random direction and distance
            let angle = CGFloat.random(in: 0..<CGFloat.pi * 2)
            let distance = CGFloat.random(in: 30..<120)
            let destinationX = position.x + cos(angle) * distance
            let destinationY = position.y + sin(angle) * distance

            // Actions
            let move = SKAction.move(to: CGPoint(x: destinationX, y: destinationY), duration: 0.6)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)

            // Sequence
            let sequence = SKAction.sequence([
                move,
                fadeOut,
                SKAction.removeFromParent()
            ])

            // Random delay
            let delay = CGFloat.random(in: 0..<0.3)

            sparkle.run(SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval(delay)),
                sequence
            ]))
        }
    }

    /// Shows an achievement unlocked particle effect
    func showAchievementEffect(at position: CGPoint? = nil) {
        // Use the center of the scene if no position is provided
        let effectPosition = position ?? CGPoint(x: frame.midX, y: frame.midY)

        // Create the particle effect from the pre-designed SKS file
        if let achievementParticle = SKEmitterNode(fileNamed: "GoldenAchievementParticle") {
            achievementParticle.position = effectPosition
            achievementParticle.zPosition = 100 // Above all other elements
            addChild(achievementParticle)

            // Set a lifetime for the particle effect
            let particleLifetime: TimeInterval = 3.0

            // Remove after particles finish emitting
            DispatchQueue.main.asyncAfter(deadline: .now() + particleLifetime) {
                achievementParticle.removeFromParent()
            }
        }
    }

    /// Shows a balance maintained particle effect around the pendulum bob
    func showBalanceEffect() {
        // Create the particle effect at the bob position
        if let balanceParticle = SKEmitterNode(fileNamed: "BalanceParticle") {
            balanceParticle.position = pendulumBob.position
            balanceParticle.zPosition = 14 // Just below the bob
            balanceParticle.targetNode = self // Set the scene as the target
            addChild(balanceParticle)

            // Set a lifetime for the particle effect
            let particleLifetime: TimeInterval = 1.0

            // Remove after particles finish emitting
            DispatchQueue.main.asyncAfter(deadline: .now() + particleLifetime) {
                balanceParticle.removeFromParent()
            }
        }
    }

    /// Clears the phase space visualization for mode changes
    func clearPhaseSpace() {
        // Reset phase space data
        phaseSpacePoints.removeAll()

        // Clear the phase trajectory path if it exists
        if let phaseSpaceNode = phaseSpaceNode,
           let trajectoryNode = phaseSpaceNode.childNode(withName: "phaseTrajectory") as? SKShapeNode {
            trajectoryNode.path = nil
        }
    }
}