import UIKit
import SpriteKit
extension PendulumScene {
    func setupControls() {
        let leftButton = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        leftButton.fillColor = .blue.withAlphaComponent(0.3)
        leftButton.strokeColor = .blue
        leftButton.position = CGPoint(x: 100, y: 100)
        leftButton.name = "leftControl"
        addChild(leftButton)
        
        let leftArrow = SKLabelNode(text: "←")
        leftArrow.fontSize = 40
        leftArrow.position = CGPoint(x: 0, y: -10)
        leftButton.addChild(leftArrow)
        
        let rightButton = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        rightButton.fillColor = .blue.withAlphaComponent(0.3)
        rightButton.strokeColor = .blue
        rightButton.position = CGPoint(x: frame.maxX - 100, y: 100)
        rightButton.name = "rightControl"
        addChild(rightButton)
        
        let rightArrow = SKLabelNode(text: "→")
        rightArrow.fontSize = 40
        rightArrow.position = CGPoint(x: 0, y: -10)
        rightButton.addChild(rightArrow)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes {
                if node.name == "leftControl" {
                    applyForce(-0.5)
                } else if node.name == "rightControl" {
                    applyForce(0.5)
                }
            }
        }
    }
    
    private func applyForce(_ magnitude: Double) {
        guard let viewModel = viewModel else { return }
        var newState = viewModel.currentState
        newState.thetaDot += magnitude
        viewModel.currentState = newState
    }
}

extension PendulumPhysics {
    func loadTestData(from file: String) -> [PendulumState] {
        var states: [PendulumState] = []
        let lines = try? String(contentsOfFile: file).split(separator: "\n")
        
        lines?.forEach { line in
            let values = line.split(separator: ",").map { Double($0) ?? 0.0 }
            if values.count >= 3 {
                states.append(PendulumState(
                    theta: values[0],
                    thetaDot: values[1],
                    time: values[2]
                ))
            }
        }
        
        return states
    }
}

extension PendulumViewModel {
    func importTestData(from file: String) {
        let testStates = physics.loadTestData(from: file)
        var index = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: physics.timeStep, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if index < testStates.count {
                self.currentState = testStates[index]
                index += 1
            } else {
                self.stopSimulation()
            }
        }
    }
}
