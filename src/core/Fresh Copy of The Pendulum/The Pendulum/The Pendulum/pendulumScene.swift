// PendulumScene.swift
import SpriteKit

class PendulumScene: SKScene {
    // Pendulum visual elements
    private let pendulumPivot = SKShapeNode(circleOfRadius: 5)
    private let pendulumRod = SKShapeNode()
    private var pendulumBob: SKNode = SKShapeNode(circleOfRadius: 15) // Changed to var, using SKNode to allow both shape and sprite
    
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
    private var sceneBackgroundLayer: SKShapeNode?
    
    // Status message label
    private var statusMessageLabel: SKLabelNode?
    
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
        print("Scene frame: \(self.frame)")
        print("View frame: \(view.frame)")
        
        // CRITICAL: Check if scene has valid size
        if self.size.width <= 0 || self.size.height <= 0 {
            print("ERROR: Scene has invalid size! width: \(self.size.width), height: \(self.size.height)")
            // Force a reasonable size
            self.size = CGSize(width: max(375, view.bounds.width), height: max(667, view.bounds.height))
            print("Scene size corrected to: \(self.size)")
        }
        
        // Set background color to white for clean appearance
        self.backgroundColor = UIColor.white
        print("DEBUG: Background color set to white")
        
        // Set up the background based on current state (after initial setup)
        // updateSceneBackground()  // Disabled - causing visibility issues
        
        // Setup decorative grid for perspective
        setupGrid()
        
        // Setup visualization background elements
        setupVisualizationBackground()
        
        // We'll use the PhaseSpaceView from PendulumViewController instead
        // setupPhaseSpaceVisualization()
        
        // Setup pivot point - more refined design and centered horizontally
        pendulumPivot.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Dark gray
        pendulumPivot.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Darker gray

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
        pendulumRod.strokeColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Medium gray
        pendulumRod.lineWidth = 5 // More thickness for better visibility with longer rod
        pendulumRod.zPosition = 5
        pendulumRod.alpha = 1.0  // Ensure full opacity
        addChild(pendulumRod)

        // Setup bob with shape node for now - ensure it's visible
        print("DEBUG: Creating pendulum bob")
        let shapeNode = SKShapeNode(circleOfRadius: 23) // 30% bigger (18 * 1.3 = 23.4)
        shapeNode.fillColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) // Rich blue
        shapeNode.strokeColor = UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0) // Darker blue stroke
        shapeNode.lineWidth = 3 // Thicker stroke
        shapeNode.glowWidth = 0 // Remove glow to eliminate shadow
        shapeNode.zPosition = 15
        shapeNode.alpha = 1.0  // Ensure full opacity
        pendulumBob = shapeNode
        print("DEBUG: Pendulum bob created - zPosition: \(pendulumBob.zPosition), alpha: \(pendulumBob.alpha)")
        addChild(pendulumBob)
        
        // Setup trail with better appearance
        setupTrailVisualization()
        
        // Setup control buttons (following UI designs in slides)
        setupControlButtonsUI()
        
        // Setup status message label in center of scene
        setupStatusMessageLabel()
        
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
        print("PendulumScene: Scene size: \(self.size)")
        print("PendulumScene: Scene background color: \(self.backgroundColor)")
        print("PendulumScene: Number of children: \(self.children.count)")
        
        // Debug pendulum visibility
        print("PendulumScene: Bob alpha: \(pendulumBob.alpha)")
        print("PendulumScene: Bob zPosition: \(pendulumBob.zPosition)")
        print("PendulumScene: Rod alpha: \(pendulumRod.alpha)")
        print("PendulumScene: Rod zPosition: \(pendulumRod.zPosition)")
        print("PendulumScene: didMove completed - scene size: \(self.size)")
    }
    
    // Set up the background based on BackgroundManager state
    func updateSceneBackground() {
        // ALWAYS keep the scene visible with white background for clean appearance
        // The pendulum game mechanics need to be visible at all times
        self.backgroundColor = UIColor.white
        
        // Always keep full opacity for game elements
        updateSceneTransparency(transparency: 1.0)
        
        // Note: Background images should be handled by the UIView layer behind the scene,
        // not by making the scene transparent
        
        print("PendulumScene: updateSceneBackground called - background set to white")
    }
    
    // Set up a gradient background based on UI design (for when background is None)
    private func setupGradientBackground() {
        guard let sceneBackgroundLayer = sceneBackgroundLayer else { return }
        
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

        // Use SpriteKit's built-in gradient capabilities
        sceneBackgroundLayer.fillColor = UIColor.white
        
        // Create a gradient effect using a child node
        let gradientOverlay = SKSpriteNode(color: endColor, size: self.size)
        gradientOverlay.position = CGPoint.zero
        gradientOverlay.zPosition = 1  // Above the background but below other elements
        gradientOverlay.alpha = 0.2  // Subtle gradient effect
        sceneBackgroundLayer.addChild(gradientOverlay)
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
        platform.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Dark gray
        platform.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Darker gray
        platform.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y + platformHeight/2)
        platform.zPosition = 5
        addChild(platform)

        // Add small decorative base elements
        let baseWidth: CGFloat = 50 // Smaller base for bottom position
        let baseHeight: CGFloat = 12 // Much shorter

        let base = SKShapeNode(rectOf: CGSize(width: baseWidth, height: baseHeight))
        base.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) // Dark gray
        base.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Darker gray
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
        floor.name = "floor"  // Add name for later reference
        floor.strokeColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        floor.lineWidth = 1
        floor.zPosition = 4
        addChild(floor)
    }
    
    private func setupGrid() {
        print("DEBUG: setupGrid called - scene size: \(size)")
        
        // Create a grid for perspective/aesthetic based on UI designs
        let gridNode = SKNode()
        gridNode.name = "gridNode"  // Add name for later reference
        gridNode.alpha = 1.0  // Full visibility for grid lines
        gridNode.zPosition = -10  // Bring closer but still behind pendulum
        
        let horizontalLines = 12
        let verticalLines = 10
        let horizontalSpacing = size.height / CGFloat(horizontalLines)
        let verticalSpacing = size.width / CGFloat(verticalLines)
        
        print("DEBUG: Grid spacing - horizontal: \(horizontalSpacing), vertical: \(verticalSpacing)")
        
        // Add horizontal grid lines
        for i in 0...horizontalLines {
            let y = CGFloat(i) * horizontalSpacing
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = UIColor.lightGray  // Explicitly use light gray
            line.lineWidth = 1
            line.alpha = 0.8  // Make grid lines visible but subtle
            gridNode.addChild(line)
        }
        
        // Add vertical grid lines
        for i in 0...verticalLines {
            let x = CGFloat(i) * verticalSpacing
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = UIColor.lightGray  // Explicitly use light gray
            line.lineWidth = 1
            line.alpha = 0.8  // Make grid lines visible but subtle
            gridNode.addChild(line)
        }
        
        addChild(gridNode)
        print("DEBUG: Grid added with \(gridNode.children.count) lines")
    }
    
    // Create a modern visualization background based on UI designs
    private func setupVisualizationBackground() {
        // Removed orbit circle visualizations to reduce visual clutter
        // Only keeping grid and other minimal background elements
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
            print("Bob position: \(bobPosition) for angle: \(angle)")
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
        
        // Debug logging
        if Int.random(in: 0...60) == 0 { // Log every ~1 second at 60fps
            print("DEBUG: Pendulum - bob position: \(bobPosition), angle: \(angle), visible: \(pendulumBob.parent != nil)")
            print("DEBUG: Pendulum - scene size: \(self.size), frame: \(self.frame)")
        }

        // Add subtle rotation to the bob based on velocity for more dynamic feel
        let rotationAngle = min(max(CGFloat(state.thetaDot) * 0.1, -0.3), 0.3)
        pendulumBob.run(SKAction.rotate(toAngle: rotationAngle, duration: 0.05))

        // Ensure the bob is always large enough to be visible
        if pendulumBob.frame.width < 40 {
            // Create a new larger bob
            let newBob = createPendulumBob(radius: 25)
            newBob.zPosition = 15
            newBob.position = bobPosition

            pendulumBob.removeFromParent()
            addChild(newBob)
            pendulumBob = newBob
        }

        // Shadow removed for cleaner appearance
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
            
            // Track phase space data for analytics
            AnalyticsManager.shared.trackPhaseSpacePoint(theta: viewModel.currentState.theta, omega: viewModel.currentState.thetaDot)
            
            // Update perturbation manager if it exists
            if let perturbationManager = self.perturbationManager {
                perturbationManager.update(currentTime: currentTime)
            }
            
            // Play sound effects based on pendulum state
            updatePendulumSounds(with: viewModel.currentState)
        }
    }
    
    // MARK: - Sound Effects
    
    private func updatePendulumSounds(with state: PendulumState) {
        // Play swing sound based on angle and velocity
        let angle = CGFloat(state.theta)
        let velocity = CGFloat(state.thetaDot)
        
        // Only play sound at certain intervals to avoid overwhelming audio
        if Int(pendulumAnimationTime * 10) % 5 == 0 {
            PendulumSoundManager.shared.playSwingSound(angle: angle, velocity: velocity)
        }
        
        // Play collision sound when pendulum hits extreme angles
        if abs(angle) > CGFloat.pi * 0.9 {
            PendulumSoundManager.shared.playCollisionSound()
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
        let newBob = createPendulumBob(radius: bobRadius)
        newBob.zPosition = 15
        
        // Save position before replacing bob
        let bobPosition = pendulumBob.position
        
        // Remove old bob and its shadow
        pendulumBob.removeFromParent()
        
        // Add new bob to scene
        addChild(newBob)
        pendulumBob = newBob
        pendulumBob.position = bobPosition
        
        // Shadow removed for cleaner appearance
        
        // Update the pendulum position to reflect the new length
        updatePendulumPosition(with: viewModel.currentState)
    }

    // MARK: - Particle Effects (Note: These effects are confined to the SpriteKit scene, not the entire UI)

    /// Shows a level completion particle effect
    func showLevelCompletionEffect(at position: CGPoint? = nil, level: Int = 1) {
        print("🔥 showLevelCompletionEffect called for level \(level)")
        
        // Use the new dynamic particle manager for colorful firework effects
        let effectPosition = position ?? pendulumBob.position
        DynamicParticleManager.createLevelCompletionEffect(for: level, at: effectPosition, in: self)
    }

    /// Creates an immersive full-screen explosion effect
    private func createImmersiveExplosionEffect() {
        // Create multiple emission points across the entire screen
        let emissionPoints: [CGPoint] = [
            CGPoint(x: frame.midX, y: frame.midY),  // Center
            CGPoint(x: frame.width * 0.15, y: frame.height * 0.15),
            CGPoint(x: frame.width * 0.85, y: frame.height * 0.15),
            CGPoint(x: frame.width * 0.15, y: frame.height * 0.85),
            CGPoint(x: frame.width * 0.85, y: frame.height * 0.85),
            CGPoint(x: frame.width * 0.5, y: frame.height * 0.05),
            CGPoint(x: frame.width * 0.5, y: frame.height * 0.95),
            CGPoint(x: frame.width * 0.05, y: frame.height * 0.5),
            CGPoint(x: frame.width * 0.95, y: frame.height * 0.5),
            // Additional points for more coverage
            CGPoint(x: frame.width * 0.3, y: frame.height * 0.3),
            CGPoint(x: frame.width * 0.7, y: frame.height * 0.3),
            CGPoint(x: frame.width * 0.3, y: frame.height * 0.7),
            CGPoint(x: frame.width * 0.7, y: frame.height * 0.7),
            // Pendulum position
            pendulumBob.position
        ]
        
        // Create the main explosion effect at each point
        for (index, point) in emissionPoints.enumerated() {
            // Slight random delay for wave effect
            let delay = Double(index) * 0.02 + Double.random(in: 0...0.05)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.createExplosionBurst(at: point, scale: CGFloat.random(in: 0.8...1.2))
            }
        }
        
        // Removed screen flash - just use particles
    }
    
    /// Creates a single explosion burst at a specific position
    private func createExplosionBurst(at position: CGPoint, scale: CGFloat) {
        print("🌟 Creating burst at \(position) with scale \(scale)")
        
        let explosionEmitter = SKEmitterNode()
        explosionEmitter.position = position
        explosionEmitter.zPosition = 100
        
        // Use simple circle texture
        let size: CGFloat = 32
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        explosionEmitter.particleTexture = SKTexture(image: circleImage)
        
        // Explosion properties
        explosionEmitter.particleBirthRate = 2500 * scale
        explosionEmitter.particleLifetime = 1.45
        explosionEmitter.particleLifetimeRange = 0.6
        
        // Use pre-colored textures from reference image palettes
        let paletteIndex = Int.random(in: 0..<DynamicParticleManager.allPalettes.count)
        let palette = DynamicParticleManager.allPalettes[paletteIndex]
        let color = palette.randomElement() ?? UIColor.white
        explosionEmitter.particleTexture = DynamicParticleManager.createGlowTexture(color: color)
        explosionEmitter.particleColorBlendFactor = 0.0  // Use texture colors only
        
        // Small particles
        explosionEmitter.particleScale = 0.15 * scale
        explosionEmitter.particleScaleRange = 0.08 * scale
        explosionEmitter.particleScaleSpeed = -0.4
        
        // Radial explosion
        explosionEmitter.emissionAngle = 0
        explosionEmitter.emissionAngleRange = CGFloat.pi * 2
        explosionEmitter.particleSpeed = 500 * scale
        explosionEmitter.particleSpeedRange = 200 * scale
        
        // Physics
        explosionEmitter.yAcceleration = -200
        
        // Rotation
        explosionEmitter.particleRotationRange = CGFloat.pi / 4
        explosionEmitter.particleRotationSpeed = 2.0
        
        // Alpha fade
        explosionEmitter.particleAlpha = 1.0
        explosionEmitter.particleAlphaRange = 0.0
        explosionEmitter.particleAlphaSpeed = -0.65
        
        // Alpha blending preserves colors better
        explosionEmitter.particleBlendMode = .alpha
        
        addChild(explosionEmitter)
        print("🌟 Added emitter to scene. emitter.particleTexture: \(explosionEmitter.particleTexture != nil)")
        print("🌟 Emitter position: \(explosionEmitter.position)")
        print("🌟 Emitter birthRate: \(explosionEmitter.particleBirthRate)")
        
        // Single burst - stop emitting immediately
        explosionEmitter.numParticlesToEmit = Int(500 * scale)  // More particles for denser fire effect
        
        // Debug the particle count
        print("🌟 Number of particles to emit: \(explosionEmitter.numParticlesToEmit)")
        
        // Remove after particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.15) {  // Reduced by 0.35
            print("🌟 Removing emitter from scene")
            explosionEmitter.removeFromParent()
        }
    }
    
    /// Creates a screen flash effect for impact
    private func createScreenFlash() {
        let flashLayer = SKShapeNode(rectOf: frame.size)
        flashLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        flashLayer.fillColor = UIColor(red: 1.0, green: 0.85, blue: 0.75, alpha: 0.5)  // Soft sunset peach
        flashLayer.strokeColor = .clear
        flashLayer.zPosition = 99  // Just below particles
        flashLayer.alpha = 0
        
        addChild(flashLayer)
        
        // Quick flash animation
        let flashIn = SKAction.fadeAlpha(to: 0.8, duration: 0.05)
        let flashOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let remove = SKAction.removeFromParent()
        
        flashLayer.run(SKAction.sequence([flashIn, flashOut, remove]))
    }
    
    /// Creates a glowing orb texture for fire particles
    private func createFireOrbTexture() -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Create radial gradient for glowing orb
            let colors = [
                UIColor.white.withAlphaComponent(1.0).cgColor,
                UIColor.white.withAlphaComponent(0.8).cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.3, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates fire color sequence for glowing particles
    private func createFireColorSequence() -> SKKeyframeSequence {
        let colors = [
            UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0),     // Bright white-yellow center
            UIColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 1.0),    // Hot yellow
            UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0),     // Orange
            UIColor(red: 1.0, green: 0.5, blue: 0.25, alpha: 0.9),    // Deep orange
            UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.7),     // Red-orange
            UIColor(red: 0.7, green: 0.2, blue: 0.15, alpha: 0.4),    // Dark red
            UIColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.1)      // Smoke fade
        ]
        
        let times: [NSNumber] = [0.0, 0.1, 0.25, 0.4, 0.6, 0.8, 1.0]
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
    
    /// Creates explosion color sequence based on desert sunset palette
    private func createExplosionColorSequence() -> SKKeyframeSequence {
        let colors = [
            UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0),      // Soft white with warm tint
            UIColor(red: 1.0, green: 0.9, blue: 0.75, alpha: 1.0),      // Pale sunset yellow
            UIColor(red: 1.0, green: 0.8, blue: 0.65, alpha: 1.0),      // Warm peach
            UIColor(red: 0.95, green: 0.7, blue: 0.55, alpha: 0.9),     // Soft coral
            UIColor(red: 0.9, green: 0.6, blue: 0.5, alpha: 0.7),       // Muted sunset orange
            UIColor(red: 0.7, green: 0.5, blue: 0.5, alpha: 0.4),       // Dusty rose fade
            UIColor(red: 0.5, green: 0.4, blue: 0.45, alpha: 0.2)       // Soft purple-gray fade
        ]
        
        let times: [NSNumber] = [0.0, 0.1, 0.25, 0.4, 0.6, 0.8, 1.0]
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
    
    /// Creates a subtle spark effect for accents
    private func createSubtleSparkEffect(at position: CGPoint, scale: CGFloat) {
        let sparkEmitter = SKEmitterNode()
        sparkEmitter.position = position
        sparkEmitter.zPosition = 99
        
        // Small point texture for sparks
        sparkEmitter.particleTexture = SKTexture(imageNamed: "spark")  // If unavailable, will be white square
        
        // Fewer, more distinct sparks
        sparkEmitter.particleBirthRate = 50 * scale
        sparkEmitter.particleLifetime = 0.8
        sparkEmitter.particleLifetimeRange = 0.2
        
        // Use texture colors without tinting
        sparkEmitter.particleColorBlendFactor = 0.0
        
        // Very small particles
        sparkEmitter.particleScale = 0.1 * scale
        sparkEmitter.particleScaleRange = 0.05 * scale
        sparkEmitter.particleScaleSpeed = -0.1
        
        // Random directions
        sparkEmitter.emissionAngle = 0
        sparkEmitter.emissionAngleRange = CGFloat.pi * 2
        sparkEmitter.particleSpeed = 150 * scale
        sparkEmitter.particleSpeedRange = 50
        
        // Gravity
        sparkEmitter.yAcceleration = -100
        
        // Sparkle rotation
        sparkEmitter.particleRotationSpeed = 10.0
        
        // Alpha
        sparkEmitter.particleAlpha = 1.0
        sparkEmitter.particleAlphaSpeed = -1.2
        
        addChild(sparkEmitter)
        
        // Very short emission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sparkEmitter.particleBirthRate = 0
        }
        
        // Remove after particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sparkEmitter.removeFromParent()
        }
    }
    
    // Setup balance progress bar above pendulum bob - NOT USED (Using UIProgressView in HUD instead)
    /*
    private func setupBalanceProgressBar() {
        balanceProgressBar = SKNode()
        balanceProgressBar?.zPosition = 25  // Above most elements but below particles
        
        // Progress bar background
        let barWidth: CGFloat = 50
        let barHeight: CGFloat = 8
        
        balanceProgressBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight/2)
        balanceProgressBackground?.fillColor = UIColor.darkGray.withAlphaComponent(0.4)
        balanceProgressBackground?.strokeColor = UIColor.darkGray.withAlphaComponent(0.8)
        balanceProgressBackground?.lineWidth = 1
        
        // Progress bar fill container
        let fillContainer = SKNode()
        fillContainer.position = CGPoint(x: -barWidth/2, y: 0)  // Position at left edge of bar
        
        // Progress bar fill - start as a small rectangle
        balanceProgressFill = SKShapeNode(rectOf: CGSize(width: 1, height: barHeight), cornerRadius: barHeight/2)
        balanceProgressFill?.fillColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)  // Green color
        balanceProgressFill?.strokeColor = .clear
        balanceProgressFill?.position = CGPoint(x: 0.5, y: 0)  // Center the 1-pixel width shape
        
        fillContainer.addChild(balanceProgressFill!)
        
        if let balanceProgressBar = balanceProgressBar,
           let balanceProgressBackground = balanceProgressBackground {
            balanceProgressBar.addChild(balanceProgressBackground)
            balanceProgressBar.addChild(fillContainer)
            addChild(balanceProgressBar)
        }
    }
    */
    
    // Update balance progress bar - NOT USED (Using UIProgressView in HUD instead)
    /*
    func updateBalanceProgressBar(progress: CGFloat, above bobPosition: CGPoint) {
        guard let balanceProgressBar = balanceProgressBar else { return }
        
        // Position the bar above the pendulum bob
        let barOffset: CGFloat = 35  // Distance above the bob
        balanceProgressBar.position = CGPoint(x: bobPosition.x, y: bobPosition.y + barOffset)
        
        // Update the progress fill by recreating it with new width
        let barWidth: CGFloat = 50
        let barHeight: CGFloat = 8
        let fillWidth = max(1, barWidth * progress)  // Minimum 1 pixel width
        
        // Get the fill container (parent of the fill)
        if let fillContainer = self.balanceProgressFill?.parent {
            self.balanceProgressFill?.removeFromParent()
            
            // Create new fill with appropriate width
            let newFill = SKShapeNode(rectOf: CGSize(width: fillWidth, height: barHeight), cornerRadius: barHeight/2)
            
            // Change color based on progress
            if progress < 0.3 {
                newFill.fillColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)  // Red
            } else if progress < 0.7 {
                newFill.fillColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)  // Orange
            } else {
                newFill.fillColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)  // Green
            }
            
            newFill.strokeColor = .clear
            newFill.position = CGPoint(x: fillWidth/2, y: 0)  // Position based on width
            fillContainer.addChild(newFill)
            
            self.balanceProgressFill = newFill
        }
    }
    */
    
    // Setup status message label
    private func setupStatusMessageLabel() {
        statusMessageLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        statusMessageLabel?.fontSize = 24
        statusMessageLabel?.fontColor = .black
        statusMessageLabel?.position = CGPoint(x: frame.midX, y: frame.midY)
        statusMessageLabel?.zPosition = 100  // On top of everything
        statusMessageLabel?.alpha = 0  // Start hidden
        addChild(statusMessageLabel!)
    }
    
    // Show status message in the center of the scene
    func showStatusMessage(_ message: String, color: UIColor = .white) {
        guard let statusMessageLabel = statusMessageLabel else { return }
        
        statusMessageLabel.text = message
        statusMessageLabel.fontColor = color
        
        // Fade in
        statusMessageLabel.removeAllActions()
        statusMessageLabel.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    // Hide status message
    func hideStatusMessage() {
        guard let statusMessageLabel = statusMessageLabel else { return }
        
        statusMessageLabel.removeAllActions()
        statusMessageLabel.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    // Update transparency of scene elements (when background is displayed)
    private func updateSceneTransparency(transparency: CGFloat) {
        // Update grid transparency - always keep it visible
        if let gridNode = childNode(withName: "gridNode") {
            gridNode.alpha = 1.0  // Keep grid fully visible
        }
        
        // Update visualization background transparency
        if let visualBackground = childNode(withName: "visualBackground") {
            visualBackground.alpha = transparency
        }
        
        // Update floor line transparency  
        if let floor = childNode(withName: "floor") {
            floor.alpha = 1.0  // Keep floor fully visible
        }
        
        // Keep bob, pendulum rod, and base fully opaque
        // These should always be clearly visible
    }
    
    /// Creates a star-shaped texture for particles
    private func createStarTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            
            // Create a 6-pointed star
            let outerRadius: CGFloat = 14
            let innerRadius: CGFloat = 6
            let points = 6
            
            ctx.move(to: CGPoint(x: 0, y: -outerRadius))
            
            for i in 0..<points * 2 {
                let angle = CGFloat(i) * CGFloat.pi / CGFloat(points)
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let x = sin(angle) * radius
                let y = -cos(angle) * radius
                ctx.addLine(to: CGPoint(x: x, y: y))
            }
            
            ctx.closePath()
            
            // Use a white star that can be tinted by particle color
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillPath()
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates a simple but effective golden explosion
    private func createSimpleGoldenExplosion() {
        // Create multiple emission points for full-screen coverage
        let emissionPoints: [CGPoint] = [
            pendulumBob.position,
            CGPoint(x: frame.width * 0.2, y: frame.height * 0.2),
            CGPoint(x: frame.width * 0.8, y: frame.height * 0.2),
            CGPoint(x: frame.width * 0.2, y: frame.height * 0.8),
            CGPoint(x: frame.width * 0.8, y: frame.height * 0.8),
            CGPoint(x: frame.width * 0.5, y: frame.height * 0.1),
            CGPoint(x: frame.width * 0.5, y: frame.height * 0.9),
            CGPoint(x: frame.width * 0.1, y: frame.height * 0.5),
            CGPoint(x: frame.width * 0.9, y: frame.height * 0.5),
        ]
        
        for (index, point) in emissionPoints.enumerated() {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.createGoldenBurst(at: point)
            }
        }
    }
    
    /// Creates a golden burst at a specific position
    private func createGoldenBurst(at position: CGPoint) {
        // Create a single emitter with color sequence for variety
        let explosionEmitter = SKEmitterNode()
        explosionEmitter.position = position
        explosionEmitter.zPosition = 100
        
        // Use simple circle texture
        let size: CGFloat = 32
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        explosionEmitter.particleTexture = SKTexture(image: circleImage)
        
        // Configure for firework explosion
        explosionEmitter.particleBirthRate = 800
        explosionEmitter.particleLifetime = 1.3
        explosionEmitter.particleLifetimeRange = 0.4
        
        // Use actual sunset colors with full blending
        let sunsetColors = [
            UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0),  // Light peach
            UIColor(red: 1.0, green: 0.85, blue: 0.6, alpha: 1.0),  // Peach
            UIColor(red: 1.0, green: 0.7, blue: 0.5, alpha: 1.0),   // Orange
            UIColor(red: 0.95, green: 0.6, blue: 0.6, alpha: 1.0),  // Coral
            UIColor(red: 0.85, green: 0.5, blue: 0.7, alpha: 1.0),  // Pink-purple
            UIColor(red: 0.7, green: 0.6, blue: 0.85, alpha: 1.0)   // Blue-purple
        ]
        
        // Use pre-colored texture from palette colors
        let paletteIndex = Int.random(in: 0..<DynamicParticleManager.allPalettes.count)
        let palette = DynamicParticleManager.allPalettes[paletteIndex]
        let color = palette.randomElement() ?? UIColor.orange
        explosionEmitter.particleTexture = DynamicParticleManager.createGlowTexture(color: color)
        explosionEmitter.particleColorBlendFactor = 0.0  // Use texture colors only
        
        // Small particles
        explosionEmitter.particleScale = 0.12
        explosionEmitter.particleScaleRange = 0.06
        explosionEmitter.particleScaleSpeed = -0.3
        
        // Full 360 degree emission
        explosionEmitter.emissionAngle = 0
        explosionEmitter.emissionAngleRange = CGFloat.pi * 2
        explosionEmitter.particleSpeed = 400
        explosionEmitter.particleSpeedRange = 150
        
        // Physics
        explosionEmitter.yAcceleration = -200
        
        // Rotation for sparkle
        explosionEmitter.particleRotationRange = CGFloat.pi / 4
        explosionEmitter.particleRotationSpeed = 2.0
        
        // Fading
        explosionEmitter.particleAlpha = 1.0
        explosionEmitter.particleAlphaRange = 0.1
        explosionEmitter.particleAlphaSpeed = -0.8
        
        // Alpha blending for better color preservation
        explosionEmitter.particleBlendMode = .alpha
        
        // Single burst
        explosionEmitter.numParticlesToEmit = 200
        
        addChild(explosionEmitter)
        
        // Remove after particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            explosionEmitter.removeFromParent()
        }
    }
    
    /// Creates a simple golden color sequence
    private func createSimpleGoldenColorSequence() -> SKKeyframeSequence {
        let colors = [
            UIColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0),   // Bright golden
            UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0),   // Orange-gold
            UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 0.7),   // Deep orange
            UIColor(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.3)    // Dark fade
        ]
        
        let times: [NSNumber] = [0.0, 0.3, 0.7, 1.0]
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
    
    /// Creates a colored orb texture with golden hues
    private func createColoredOrbTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Create a radial gradient with sunset colors
            let colors = [
                UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0).cgColor,  // Bright golden center
                UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 0.8).cgColor,  // Orange-gold
                UIColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 0.4).cgColor,  // Deep orange
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.4, 0.8, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates a simple glowing orb texture
    private func createGlowingOrbTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Simple radial gradient
            let colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates an enhanced sunset orb texture with vibrant desert colors
    private func createEnhancedSunsetOrbTexture() -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Create a vibrant radial gradient with desert sunset colors
            let colors = [
                UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0).cgColor,  // Bright yellow-white center
                UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0).cgColor,   // Golden yellow
                UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 1.0).cgColor,  // Bright orange
                UIColor(red: 0.95, green: 0.5, blue: 0.25, alpha: 0.8).cgColor, // Deep orange-red
                UIColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.5).cgColor,   // Dark red-orange
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
            
            // Add a subtle bright spot at the center for extra luminosity
            ctx.saveGState()
            ctx.setBlendMode(.screen)
            
            let innerColors = [
                UIColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 0.6).cgColor,
                UIColor.clear.cgColor
            ]
            let innerLocations: [CGFloat] = [0.0, 0.3]
            
            if let innerGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: innerColors as CFArray,
                locations: innerLocations
            ) {
                ctx.drawRadialGradient(
                    innerGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius * 0.5,
                    options: []
                )
            }
            ctx.restoreGState()
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates pre-colored star textures with sunset gradient
    private func createColoredStarTexture() -> SKTexture {
        let size = CGSize(width: 48, height: 48)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            
            // Pick a random sunset color for this star - more vibrant colors
            let colors = [
                UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0),     // Bright orange
                UIColor(red: 1.0, green: 0.45, blue: 0.35, alpha: 1.0),   // Deep coral
                UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0),     // Golden yellow
                UIColor(red: 0.95, green: 0.4, blue: 0.35, alpha: 1.0),   // Red-orange
                UIColor(red: 0.9, green: 0.35, blue: 0.45, alpha: 1.0),   // Deep rose  
                UIColor(red: 1.0, green: 0.65, blue: 0.45, alpha: 1.0),   // Peach
                UIColor(red: 0.85, green: 0.45, blue: 0.55, alpha: 1.0)   // Dusky pink
            ]
            let randomColor = colors.randomElement()!
            
            // Create a 5-pointed star with sharper points
            let outerRadius: CGFloat = 20
            let innerRadius: CGFloat = 8
            let points = 5
            
            // Draw a filled star
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
            
            // Fill with solid color first
            randomColor.setFill()
            path.fill()
            
            // Add inner glow for brightness
            ctx.saveGState()
            let innerGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.white.withAlphaComponent(0.6).cgColor,
                    randomColor.cgColor
                ] as CFArray,
                locations: [0.0, 0.8]
            )!
            
            path.addClip()
            ctx.drawRadialGradient(
                innerGradient,
                startCenter: CGPoint.zero,
                startRadius: 0,
                endCenter: CGPoint.zero,
                endRadius: outerRadius * 0.6,
                options: []
            )
            ctx.restoreGState()
            
            // Add outer glow
            ctx.setShadow(offset: .zero, blur: 3, color: randomColor.cgColor)
            randomColor.setStroke()
            path.lineWidth = 0.5
            path.stroke()
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates a sunset color sequence matching the desert theme
    private func createGoldenColorSequence() -> SKKeyframeSequence {
        let colors = [
            UIColor(red: 1.0, green: 0.92, blue: 0.85, alpha: 1.0),  // Soft peachy white
            UIColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1.0),   // Warm sunset peach
            UIColor(red: 0.98, green: 0.75, blue: 0.6, alpha: 1.0),  // Soft coral
            UIColor(red: 0.9, green: 0.65, blue: 0.55, alpha: 0.8),  // Muted rose-orange
            UIColor(red: 0.7, green: 0.5, blue: 0.5, alpha: 0.4)     // Dusty desert fade
        ]
        
        let times: [NSNumber] = [0.0, 0.2, 0.5, 0.8, 1.0]
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
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
    func showNewLevelEffect(at position: CGPoint? = nil, level: Int = 1) {
        // Add sparkling trail to pendulum bob for visual interest
        // Use total completions for color variety instead of level
        if let viewModel = viewModel {
            addSparklingTrailToBob(for: viewModel.totalCompletions)
        } else {
            addSparklingTrailToBob(for: level)
        }
        
        // Create a subtle level start effect
        let effectPosition = position ?? pendulumBob.position
        
        // Create a shimmer effect with texture-based particles
        let shimmerEmitter = SKEmitterNode()
        shimmerEmitter.position = effectPosition
        
        // Get palette for shimmer effect
        let paletteIndex = level % DynamicParticleManager.allPalettes.count
        let palette = DynamicParticleManager.allPalettes[paletteIndex]
        let shimmerColor = palette.last ?? UIColor.white
        
        // Use star texture for shimmer
        shimmerEmitter.particleTexture = DynamicParticleManager.createStarTexture(color: shimmerColor, points: 4)
        shimmerEmitter.particleBirthRate = 200  // More particles for initial burst
        shimmerEmitter.numParticlesToEmit = 100  // Limited burst
        shimmerEmitter.particleLifetime = 1.0
        shimmerEmitter.particleSize = CGSize(width: 16, height: 16)
        shimmerEmitter.particleScale = 1.0
        shimmerEmitter.particleScaleRange = 0.5
        shimmerEmitter.particleScaleSpeed = -0.8
        shimmerEmitter.emissionAngle = -CGFloat.pi / 2
        shimmerEmitter.emissionAngleRange = CGFloat.pi / 4
        shimmerEmitter.particleSpeed = 50
        shimmerEmitter.particleSpeedRange = 30
        shimmerEmitter.particleAlpha = 0.9
        shimmerEmitter.particleAlphaSpeed = -0.8
        shimmerEmitter.particleColorBlendFactor = 0.0  // Use texture color only
        shimmerEmitter.particleBlendMode = .alpha  // Better color preservation
        shimmerEmitter.particleRotation = 0
        shimmerEmitter.particleRotationRange = CGFloat.pi * 2
        shimmerEmitter.particleRotationSpeed = CGFloat.pi * 3  // Spinning stars
        addChild(shimmerEmitter)
        
        // Remove after short time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            shimmerEmitter.removeFromParent()
        }
    }

    /// Creates a comet trail effect rising upward
    private func createCometTrailEffect(at position: CGPoint) {
        let cometEmitter = SKEmitterNode()
        cometEmitter.position = position
        cometEmitter.zPosition = 100
        
        // Diamond/crystal texture for comet particles
        let diamondTexture = createDiamondTexture()
        cometEmitter.particleTexture = diamondTexture
        
        // Comet properties - dense trail
        cometEmitter.particleBirthRate = 300
        cometEmitter.particleLifetime = 1.0
        cometEmitter.particleLifetimeRange = 0.3
        
        // Use pre-colored comet texture
        let texture = DynamicParticleManager.createGlowTexture(color: UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0))
        cometEmitter.particleTexture = texture
        cometEmitter.particleColorBlendFactor = 0.0  // Use texture colors only
        
        // Size variation
        cometEmitter.particleScale = 0.4
        cometEmitter.particleScaleRange = 0.2
        cometEmitter.particleScaleSpeed = -0.3
        
        // Upward movement with spread
        cometEmitter.emissionAngle = -CGFloat.pi / 2  // Straight up
        cometEmitter.emissionAngleRange = CGFloat.pi / 6  // Narrow spread
        cometEmitter.particleSpeed = 300
        cometEmitter.particleSpeedRange = 50
        
        // Physics - strong upward movement
        cometEmitter.yAcceleration = 200  // Accelerate upward
        cometEmitter.xAcceleration = 0
        
        // Rotation for shimmer
        cometEmitter.particleRotationRange = CGFloat.pi
        cometEmitter.particleRotationSpeed = 8.0
        
        // Alpha fade
        cometEmitter.particleAlpha = 0.9
        cometEmitter.particleAlphaRange = 0.1
        cometEmitter.particleAlphaSpeed = -0.6
        
        // Alpha blend for color preservation
        cometEmitter.particleBlendMode = .alpha
        
        addChild(cometEmitter)
        
        // Move the emitter upward while emitting
        let moveUp = SKAction.moveBy(x: 0, y: frame.height * 0.6, duration: 0.8)
        moveUp.timingMode = .easeIn
        cometEmitter.run(moveUp)
        
        // Stop emission after brief period
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            cometEmitter.particleBirthRate = 0
        }
        
        // Remove after particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            cometEmitter.removeFromParent()
        }
    }
    
    /// Creates a starburst effect
    private func createStarburstEffect(at position: CGPoint, scale: CGFloat) {
        let burstEmitter = SKEmitterNode()
        burstEmitter.position = position
        burstEmitter.zPosition = 101
        
        // Use star texture
        burstEmitter.particleTexture = createStarTexture()
        
        // Burst properties
        burstEmitter.particleBirthRate = 200 * scale
        burstEmitter.particleLifetime = 0.6
        burstEmitter.particleLifetimeRange = 0.1
        
        // Use pre-colored burst texture
        let texture = DynamicParticleManager.createStarTexture(color: UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0), points: 6)
        burstEmitter.particleTexture = texture
        burstEmitter.particleColorBlendFactor = 0.0  // Use texture colors only
        
        // Size
        burstEmitter.particleScale = 0.3 * scale
        burstEmitter.particleScaleRange = 0.1 * scale
        burstEmitter.particleScaleSpeed = -0.5
        
        // Radial burst in all directions
        burstEmitter.emissionAngle = 0
        burstEmitter.emissionAngleRange = CGFloat.pi * 2
        burstEmitter.particleSpeed = 250 * scale
        burstEmitter.particleSpeedRange = 50
        
        // Deceleration
        burstEmitter.yAcceleration = -50
        
        // Sparkle rotation
        burstEmitter.particleRotationSpeed = 12.0
        
        // Alpha
        burstEmitter.particleAlpha = 1.0
        burstEmitter.particleAlphaSpeed = -1.5
        
        // Alpha blend for color preservation
        burstEmitter.particleBlendMode = .alpha
        
        addChild(burstEmitter)
        
        // Single burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            burstEmitter.particleBirthRate = 0
        }
        
        // Remove after particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            burstEmitter.removeFromParent()
        }
    }
    
    /// Creates a diamond/crystal texture
    private func createDiamondTexture() -> SKTexture {
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            
            // Create a diamond shape
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: -10))
            path.addLine(to: CGPoint(x: 8, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: -8, y: 0))
            path.close()
            
            // Fill with gradient
            ctx.saveGState()
            let colors = [UIColor.white.cgColor, UIColor(white: 0.8, alpha: 0.5).cgColor]
            let locations: [CGFloat] = [0.0, 1.0]
            
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations) {
                ctx.addPath(path.cgPath)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: CGPoint(x: -8, y: -10), end: CGPoint(x: 8, y: 10), options: [])
            }
            ctx.restoreGState()
            
            // Add bright edge
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(1)
            ctx.addPath(path.cgPath)
            ctx.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates a comet color sequence
    private func createCometColorSequence() -> SKKeyframeSequence {
        let colors = [
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),       // Pure white
            UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0),      // Light blue
            UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.8),       // Medium blue
            UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.5),       // Dark blue
            UIColor(red: 0.1, green: 0.1, blue: 0.4, alpha: 0.2)        // Very dark blue
        ]
        
        let times: [NSNumber] = [0.0, 0.2, 0.5, 0.8, 1.0]
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
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
    
    /// Adds a sparkling trail effect to the pendulum bob
    func addSparklingTrailToBob(for level: Int) {
        // Remove any existing trail
        pendulumBob.removeAllChildren()
        
        // Create a sparkling trail with texture-based particles
        let sparklingTrail = SKEmitterNode()
        
        // Get palette colors for this level/completion
        let paletteIndex = level % DynamicParticleManager.allPalettes.count
        let palette = DynamicParticleManager.allPalettes[paletteIndex]
        let trailColor = palette[min(3, palette.count - 1)]
        
        // Use soft particle texture for trails
        sparklingTrail.particleTexture = DynamicParticleManager.createSoftParticle(color: trailColor)
        sparklingTrail.particleBirthRate = 50
        sparklingTrail.particleLifetime = 0.8
        sparklingTrail.particleLifetimeRange = 0.3
        sparklingTrail.particleSize = CGSize(width: 12, height: 12)
        sparklingTrail.particleScale = 1.0
        sparklingTrail.particleScaleRange = 0.5
        sparklingTrail.particleScaleSpeed = -0.8
        sparklingTrail.emissionAngle = CGFloat.pi / 2  // Downward
        sparklingTrail.emissionAngleRange = CGFloat.pi / 6
        sparklingTrail.particleSpeed = 40
        sparklingTrail.particleSpeedRange = 20
        sparklingTrail.particleAlpha = 0.9
        sparklingTrail.particleAlphaSpeed = -0.8
        sparklingTrail.yAcceleration = -50
        sparklingTrail.particleColorBlendFactor = 0.0  // Use texture colors only
        sparklingTrail.targetNode = self // Particles remain in scene
        sparklingTrail.zPosition = pendulumBob.zPosition - 1
        sparklingTrail.particleBlendMode = .alpha  // Better color preservation
        pendulumBob.addChild(sparklingTrail)
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
    
    /// Creates a pendulum bob node with the specified size (30% bigger)
    private func createPendulumBob(radius: CGFloat = 23) -> SKNode { // 30% bigger default (18 * 1.3)
        // Try to create sprite node with image first
        if let bobImage = UIImage(named: "pendulumBob1") {
            let texture = SKTexture(image: bobImage)
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.size = CGSize(width: radius * 2, height: radius * 2)
            // Remove any shadow effects
            spriteNode.shadowCastBitMask = 0
            spriteNode.shadowedBitMask = 0
            return spriteNode
        } else {
            // Fallback to shape node if image not found
            let shapeNode = SKShapeNode(circleOfRadius: radius)
            shapeNode.fillColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
            shapeNode.strokeColor = UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0)
            shapeNode.lineWidth = 3
            shapeNode.glowWidth = 0 // Remove glow to eliminate shadow
            return shapeNode
        }
    }
    
    /// Creates a sunset gradient texture
    private func createSunsetGradientTexture() -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Create gradient with sunset colors from the desert image
            let colors = [
                UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0).cgColor,  // Light peach
                UIColor(red: 1.0, green: 0.85, blue: 0.6, alpha: 1.0).cgColor,  // Peach
                UIColor(red: 1.0, green: 0.7, blue: 0.5, alpha: 0.9).cgColor,   // Orange-peach
                UIColor(red: 0.95, green: 0.6, blue: 0.6, alpha: 0.8).cgColor,  // Coral
                UIColor(red: 0.85, green: 0.5, blue: 0.7, alpha: 0.7).cgColor,  // Pink-purple
                UIColor(red: 0.7, green: 0.6, blue: 0.85, alpha: 0.5).cgColor,  // Soft blue-purple
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.15, 0.3, 0.45, 0.6, 0.8, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
            
            // Add bright center spot
            ctx.setFillColor(UIColor(white: 1.0, alpha: 0.9).cgColor)
            ctx.fillEllipse(in: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
        }
        
        return SKTexture(image: image)
    }
    
    /// Creates a firework particle texture with wider range of colors
    private func createFireworkParticleTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)  // Smaller for firework particles
        let textures: [SKTexture] = [
            createFireworkParticleWithColor(
                center: UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0),  // Light yellow
                edge: UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.3),    // Golden
                size: size
            ),
            createFireworkParticleWithColor(
                center: UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1.0),   // Pink-white
                edge: UIColor(red: 1.0, green: 0.5, blue: 0.7, alpha: 0.3),    // Pink
                size: size
            ),
            createFireworkParticleWithColor(
                center: UIColor(red: 0.9, green: 0.85, blue: 1.0, alpha: 1.0),  // Light purple
                edge: UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 0.3),    // Purple
                size: size
            ),
            createFireworkParticleWithColor(
                center: UIColor(red: 1.0, green: 0.85, blue: 0.6, alpha: 1.0),  // Peach
                edge: UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 0.3),    // Orange
                size: size
            ),
            createFireworkParticleWithColor(
                center: UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0),   // Blue-white  
                edge: UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.3),    // Sky blue
                size: size
            )
        ]
        
        // Return random texture for variety
        return textures.randomElement()!
    }
    
    /// Creates a single firework particle with given colors
    private func createFireworkParticleWithColor(center: UIColor, edge: UIColor, size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Create radial gradient
            let colors = [
                center.cgColor,
                center.withAlphaComponent(0.8).cgColor,
                edge.cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.3, 0.7, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )!
            
            ctx.drawRadialGradient(
                gradient,
                startCenter: centerPoint,
                startRadius: 0,
                endCenter: centerPoint,
                endRadius: radius,
                options: []
            )
            
            // Add bright center spot for sparkle
            ctx.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
            ctx.fillEllipse(in: CGRect(x: centerPoint.x - 2, y: centerPoint.y - 2, width: 4, height: 4))
        }
        
        return SKTexture(image: image)
    }
}