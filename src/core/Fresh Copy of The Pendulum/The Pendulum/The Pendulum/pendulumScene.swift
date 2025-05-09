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
        
        // Position the pendulum pivot in the upper middle area
        pendulumPivot.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        pendulumPivot.lineWidth = 2
        pendulumPivot.glowWidth = 1
        pendulumPivot.zPosition = 10
        addChild(pendulumPivot)
        
        // Add a platform/base for the inverted pendulum
        setupPlatform()
        
        // Setup pendulum rod - more refined look
        pendulumRod.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        pendulumRod.lineWidth = 3
        pendulumRod.zPosition = 5
        addChild(pendulumRod)
        
        // Setup bob - more professional appearance and ensure it's visible
        pendulumBob.fillColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) // Royal blue
        pendulumBob.strokeColor = UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0)
        pendulumBob.lineWidth = 2
        pendulumBob.glowWidth = 2
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
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let texture = SKTexture(image: gradientImage!)
        
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
        // Create a ground platform at the bottom for inverted pendulum
        let platformWidth: CGFloat = 150
        let platformHeight: CGFloat = 15
        
        let platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight))
        platform.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        platform.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        platform.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y + platformHeight/2)
        platform.zPosition = 5
        addChild(platform)
        
        // Add decorative base elements for a more professional look
        let baseWidth: CGFloat = 80
        let baseHeight: CGFloat = 30
        
        let base = SKShapeNode(rectOf: CGSize(width: baseWidth, height: baseHeight))
        base.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        base.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        base.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y + baseHeight/2 + platformHeight)
        base.zPosition = 6
        addChild(base)
        
        // Add a small vertical support above the pivot for connection to the rod
        let supportWidth: CGFloat = 8
        let supportHeight: CGFloat = 10
        
        let support = SKShapeNode(rectOf: CGSize(width: supportWidth, height: supportHeight))
        support.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        support.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        support.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y - supportHeight/2)
        support.zPosition = 7
        addChild(support)
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
        
        // Create a circular orbit pattern (from Slide 2 design)
        let orbitNode = SKShapeNode(circleOfRadius: 100)
        orbitNode.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        orbitNode.strokeColor = UIColor.darkGray.withAlphaComponent(0.2)
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
                path.move(to: CGPoint(x: 100 * cos(angle1), y: 100 * sin(angle1)))
                path.addLine(to: CGPoint(x: 100 * cos(angle2), y: 100 * sin(angle2)))
                let segment = SKShapeNode(path: path)
                segment.strokeColor = UIColor.darkGray.withAlphaComponent(0.2)
                segment.lineWidth = 1
                dashedOrbitNode.addChild(segment)
            }
        }
        visualBackground.addChild(dashedOrbitNode)
        visualBackground.addChild(orbitNode)
        
        // Add radius line
        let radiusPath = CGMutablePath()
        radiusPath.move(to: CGPoint(x: orbitNode.position.x, y: orbitNode.position.y))
        radiusPath.addLine(to: CGPoint(x: orbitNode.position.x + 100, y: orbitNode.position.y))
        
        let radiusLine = SKShapeNode(path: radiusPath)
        radiusLine.strokeColor = UIColor.black.withAlphaComponent(0.3)
        radiusLine.lineWidth = 1
        visualBackground.addChild(radiusLine)
        
        // Add dot at end of radius
        let endDot = SKShapeNode(circleOfRadius: 4)
        endDot.position = CGPoint(x: orbitNode.position.x + 100, y: orbitNode.position.y)
        endDot.fillColor = .black
        visualBackground.addChild(endDot)
        
        addChild(visualBackground)
    }
    
    // Helper method to update the pendulum position for an inverted pendulum
    private func updatePendulumPosition(with state: PendulumState) {
        let angle = state.theta
        
        // Use a longer length for the inverted pendulum to ensure bob is visible
        let baseLength: CGFloat = 220
        let modelLength = viewModel?.length ?? 1.0
        let length = baseLength * CGFloat(modelLength)
        
        // Calculate bob position based on angle for inverted pendulum
        // For inverted pendulum, the bob is ABOVE the pivot point when at rest (π)
        let bobX = pendulumPivot.position.x + length * sin(angle)
        let bobY = pendulumPivot.position.y - length * cos(angle)
        let bobPosition = CGPoint(x: bobX, y: bobY)
        
        // Only print the bob position occasionally
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
        
        // Add subtle rotation to the bob based on velocity
        let rotationAngle = min(max(CGFloat(state.thetaDot) * 0.1, -0.3), 0.3)
        pendulumBob.run(SKAction.rotate(toAngle: rotationAngle, duration: 0.05))
        
        // Ensure the bob is large enough to be visible
        if pendulumBob.frame.width < 20 {
            // Create a new larger bob
            let newBob = SKShapeNode(circleOfRadius: 20)
            newBob.fillColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
            newBob.strokeColor = UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0)
            newBob.lineWidth = 2
            newBob.glowWidth = 2
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
}