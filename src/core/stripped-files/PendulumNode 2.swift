// PendulumNode.swift
import SpriteKit

class PendulumNode: SKNode {
    private let rodNode: SKShapeNode
    private let massNode: SKShapeNode
    private let length: CGFloat
    
    init(length: CGFloat, massRadius: CGFloat) {
        self.length = length
        
        // Create rod
        rodNode = SKShapeNode(rectOf: CGSize(width: 4, height: length))
        rodNode.fillColor = .white
        rodNode.strokeColor = .white
        rodNode.position = CGPoint(x: 0, y: -length/2)
        
        // Create mass
        massNode = SKShapeNode(circleOfRadius: massRadius)
        massNode.fillColor = .red
        massNode.strokeColor = .red
        massNode.position = CGPoint(x: 0, y: -length)
        
        super.init()
        
        addChild(rodNode)
        addChild(massNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAngle(_ angle: Double) {
        zRotation = CGFloat(angle)
        print("Updating pendulum visual angle to: \(angle)")
    }
}