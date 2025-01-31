// PendulumScene.swift
import SpriteKit

class PendulumScene: SKScene {
    private let pendulumPivot = SKShapeNode(circleOfRadius: 5)
    private let pendulumRod = SKShapeNode()
    private let pendulumBob = SKShapeNode(circleOfRadius: 15)
    private let trailNode = SKNode()
    private let maxTrailPoints = 50
    private var trailPoints: [CGPoint] = []
    
    var viewModel: PendulumViewModel?
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        // Setup pivot point
        pendulumPivot.fillColor = .black
        pendulumPivot.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(pendulumPivot)
        
        // Setup pendulum rod
        pendulumRod.strokeColor = .black
        pendulumRod.lineWidth = 2
        addChild(pendulumRod)
        
        // Setup bob
        pendulumBob.fillColor = .blue
        addChild(pendulumBob)
        
        // Setup trail
        addChild(trailNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let viewModel = viewModel else { return }
        
        // Calculate pendulum position
        let angle = viewModel.currentState.theta
        let length = CGFloat(viewModel.length * 100) // Scale up for visualization
        let bobX = pendulumPivot.position.x + length * sin(angle)
        let bobY = pendulumPivot.position.y - length * cos(angle)
        let bobPosition = CGPoint(x: bobX, y: bobY)
        
        // Update pendulum rod
        let path = CGMutablePath()
        path.move(to: pendulumPivot.position)
        path.addLine(to: bobPosition)
        pendulumRod.path = path
        
        // Update bob position
        pendulumBob.position = bobPosition
        
        // Update trail
        if viewModel.isSimulating {
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
            let trailLine = SKShapeNode(path: trailPath)
            trailLine.strokeColor = .blue.withAlphaComponent(0.3)
            trailLine.lineWidth = 2
            trailNode.addChild(trailLine)
        }
    }
}
