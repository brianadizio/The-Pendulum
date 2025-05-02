// PendulumScene.swift
import SpriteKit

class PendulumScene: SKScene {
    private let pendulumPivot = SKShapeNode(circleOfRadius: 5)
    private let pendulumRod = SKShapeNode()
    private var pendulumBob = SKShapeNode(circleOfRadius: 15) // Changed to var
    private let trailNode = SKNode()
    private let maxTrailPoints = 50
    private var trailPoints: [CGPoint] = []
    
    var viewModel: PendulumViewModel?
    
    override func didMove(to view: SKView) {
        print("PendulumScene: didMove called")
        
        // Log view and scene information for debugging
        print("Scene size: \(self.size)")
        print("View size: \(view.bounds.size)")
        
        // Set up a gradient background
        let gradientNode = SKSpriteNode(color: .clear, size: self.size)
        gradientNode.zPosition = -100
        addChild(gradientNode)
        
        // Create the gradient texture using a different approach
        let startColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0) // Light blue-white
        let endColor = UIColor(red: 0.9, green: 0.9, blue: 0.98, alpha: 1.0) // Slightly darker blue-white
        
        // Create a gradient image using UIKit
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: self.size)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let texture = SKTexture(image: gradientImage!)
        
        gradientNode.texture = texture
        
        // Setup decorative grid for perspective
        setupGrid()
        
        // Add a visible center marker for debugging
        let centerMarker = SKShapeNode(circleOfRadius: 5)
        centerMarker.fillColor = .red
        centerMarker.position = CGPoint(x: frame.midX, y: frame.midY)
        centerMarker.zPosition = 100
        addChild(centerMarker)
        
        // Setup pivot point - more refined design and centered horizontally
        pendulumPivot.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark gray
        pendulumPivot.strokeColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        // Center the pendulum horizontally and position it in the lower portion for inverted pendulum
        pendulumPivot.position = CGPoint(x: frame.midX, y: frame.midY - 100)
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
        trailNode.alpha = 0.6
        trailNode.zPosition = 3
        addChild(trailNode)
        
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
    
    private func setupPlatform() {
        // Create a platform/base for the inverted pendulum
        let platformWidth: CGFloat = 120
        let platformHeight: CGFloat = 10
        
        let platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight))
        platform.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        platform.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        platform.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y - platformHeight/2)
        platform.zPosition = 5
        addChild(platform)
        
        // Add a small vertical support under the pivot
        let supportWidth: CGFloat = 8
        let supportHeight: CGFloat = 20
        
        let support = SKShapeNode(rectOf: CGSize(width: supportWidth, height: supportHeight))
        support.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        support.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        support.position = CGPoint(x: pendulumPivot.position.x, y: pendulumPivot.position.y - supportHeight/2)
        support.zPosition = 7
        addChild(support)
    }
    
    private func setupGrid() {
        // Create a grid for perspective/aesthetic
        let gridNode = SKNode()
        gridNode.alpha = 0.1
        gridNode.zPosition = -50
        
        let horizontalLines = 10
        let verticalLines = 8
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
    
    // Helper method to update the pendulum position
    private func updatePendulumPosition(with state: PendulumState) {
        let angle = state.theta
        
        // Use a larger base length to make pendulum more visible
        let baseLength: CGFloat = 100 // Reduced from 130 to better fit in view
        let modelLength = viewModel?.length ?? 1.0
        let length = baseLength * CGFloat(modelLength)
        
        // Calculate bob position based on angle
        let bobX = pendulumPivot.position.x + length * sin(angle)
        let bobY = pendulumPivot.position.y - length * cos(angle)
        let bobPosition = CGPoint(x: bobX, y: bobY)
        
        // Only print the bob position occasionally
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
        
        // Update pendulum position
        updatePendulumPosition(with: viewModel.currentState)
        
        // Update trail
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
            
            // Create a beautiful trail color
            let trailColor = UIColor(red: 0.0, green: 0.4, blue: 0.9, alpha: 0.3)
            trailLine.strokeColor = trailColor
            trailLine.lineWidth = 3
            
            // Add a glow effect to the trail
            trailLine.blendMode = .screen
            
            trailNode.addChild(trailLine)
            
            // Add indicator dots along the path for visual interest
            if trailPoints.count > 5 {
                for i in stride(from: 0, to: trailPoints.count, by: 5) {
                    let dotSize = 3.0 * (CGFloat(i) / CGFloat(trailPoints.count))
                    let dot = SKShapeNode(circleOfRadius: dotSize)
                    dot.position = trailPoints[i]
                    dot.fillColor = trailColor.withAlphaComponent(0.5)
                    dot.strokeColor = .clear
                    trailNode.addChild(dot)
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