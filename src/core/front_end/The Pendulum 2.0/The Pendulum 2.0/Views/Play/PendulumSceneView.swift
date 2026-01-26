// PendulumSceneView.swift
// The Pendulum 2.0
// UIViewRepresentable wrapper for SpriteKit scene

import SwiftUI
import SpriteKit

struct PendulumSceneView: UIViewRepresentable {
    @ObservedObject var viewModel: PendulumViewModel

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .clear

        return skView
    }

    func updateUIView(_ skView: SKView, context: Context) {
        // Only create scene once we have a valid size
        if skView.scene == nil && skView.bounds.size.width > 0 && skView.bounds.size.height > 0 {
            let scene = PendulumScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            scene.viewModel = viewModel
            scene.backgroundColor = UIColor.systemBackground
            skView.presentScene(scene)
        }

        // Update existing scene with new size if needed
        if let scene = skView.scene as? PendulumScene {
            if scene.size != skView.bounds.size && skView.bounds.size.width > 0 {
                scene.size = skView.bounds.size
                scene.layoutPendulum()
            }
            // Keep viewModel reference updated
            scene.viewModel = viewModel
        }
    }
}

// MARK: - Pendulum Scene
class PendulumScene: SKScene {
    weak var viewModel: PendulumViewModel?

    // Visual elements
    private var pivotNode: SKShapeNode!
    private var rodNode: SKShapeNode!
    private var bobNode: SKShapeNode!
    private var groundNode: SKShapeNode!
    private var balanceZoneNode: SKShapeNode!

    // Pendulum dimensions
    private var pendulumLength: CGFloat = 200
    private var bobRadius: CGFloat = 25
    private var pivotRadius: CGFloat = 10

    // Colors
    private let pivotColor = UIColor.systemGray
    private let rodColor = UIColor.systemGray2
    private let bobColor = UIColor.systemBlue
    private let balancedBobColor = UIColor.systemGreen
    private let groundColor = UIColor.systemGray4
    private let balanceZoneColor = UIColor.systemGreen.withAlphaComponent(0.15)

    override func didMove(to view: SKView) {
        backgroundColor = UIColor.systemBackground
        setupScene()
    }

    private func setupScene() {
        guard size.width > 0 && size.height > 0 else { return }

        // Calculate pendulum length based on screen size
        pendulumLength = min(size.height * 0.35, size.width * 0.4)
        bobRadius = pendulumLength * 0.125
        pivotRadius = pendulumLength * 0.05

        // Create ground line
        groundNode = SKShapeNode(rect: CGRect(x: 0, y: size.height * 0.15, width: size.width, height: 2))
        groundNode.fillColor = groundColor
        groundNode.strokeColor = .clear
        groundNode.zPosition = 0
        addChild(groundNode)

        // Create balance zone indicator
        let balanceZoneHeight = size.height * 0.3
        balanceZoneNode = SKShapeNode(rect: CGRect(
            x: size.width * 0.3,
            y: size.height * 0.5 - balanceZoneHeight / 2,
            width: size.width * 0.4,
            height: balanceZoneHeight
        ))
        balanceZoneNode.fillColor = balanceZoneColor
        balanceZoneNode.strokeColor = UIColor.systemGreen.withAlphaComponent(0.3)
        balanceZoneNode.lineWidth = 2
        balanceZoneNode.zPosition = 1
        addChild(balanceZoneNode)

        // Create pivot point (at 15% height - near bottom for INVERTED pendulum)
        let pivotPosition = CGPoint(x: size.width / 2, y: size.height * 0.15)
        pivotNode = SKShapeNode(circleOfRadius: pivotRadius)
        pivotNode.position = pivotPosition
        pivotNode.fillColor = pivotColor
        pivotNode.strokeColor = .clear
        pivotNode.zPosition = 10
        addChild(pivotNode)

        // Create rod - will be updated in update() method
        let rodPath = CGMutablePath()
        rodPath.move(to: pivotPosition)
        rodPath.addLine(to: CGPoint(x: pivotPosition.x, y: pivotPosition.y + pendulumLength))
        rodNode = SKShapeNode(path: rodPath)
        rodNode.strokeColor = rodColor
        rodNode.lineWidth = 4
        rodNode.lineCap = .round
        rodNode.zPosition = 5
        addChild(rodNode)

        // Create bob (ABOVE pivot when balanced - theta near 0)
        bobNode = SKShapeNode(circleOfRadius: bobRadius)
        bobNode.position = CGPoint(x: pivotPosition.x, y: pivotPosition.y + pendulumLength)
        bobNode.fillColor = bobColor
        bobNode.strokeColor = UIColor.white.withAlphaComponent(0.5)
        bobNode.lineWidth = 3
        bobNode.zPosition = 15
        addChild(bobNode)

        // Add glow effect to bob
        let glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        let glowCircle = SKShapeNode(circleOfRadius: bobRadius * 1.2)
        glowCircle.fillColor = bobColor.withAlphaComponent(0.3)
        glowCircle.strokeColor = .clear
        glowNode.addChild(glowCircle)
        bobNode.addChild(glowNode)
    }

    func layoutPendulum() {
        guard pivotNode != nil else { return }

        // Recalculate dimensions
        pendulumLength = min(size.height * 0.35, size.width * 0.4)
        bobRadius = pendulumLength * 0.125
        pivotRadius = pendulumLength * 0.05

        // Update positions (pivot at 15% height for INVERTED pendulum)
        let pivotPosition = CGPoint(x: size.width / 2, y: size.height * 0.15)
        pivotNode.position = pivotPosition

        // Update ground
        groundNode.path = CGPath(rect: CGRect(x: 0, y: size.height * 0.15, width: size.width, height: 2), transform: nil)

        // Update balance zone
        let balanceZoneHeight = size.height * 0.3
        balanceZoneNode.path = CGPath(rect: CGRect(
            x: size.width * 0.3,
            y: size.height * 0.5 - balanceZoneHeight / 2,
            width: size.width * 0.4,
            height: balanceZoneHeight
        ), transform: nil)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let viewModel = viewModel else { return }

        // Get current angle (inverted pendulum: π = upright, 0 = hanging down)
        let theta = viewModel.currentState.theta

        // Update bob position for INVERTED pendulum
        // Physics model: θ = π is upright (unstable), θ = 0 is hanging down (stable)
        // Visual mapping: We need bob ABOVE pivot when θ ≈ π
        // When θ = π: sin(π) = 0, cos(π) = -1
        // We use -cos(theta) so that when θ = π, bobY = pivot.y + length (above)
        // When θ = 0, bobY = pivot.y - length (below)
        let pivotPosition = pivotNode.position
        let bobX = pivotPosition.x + pendulumLength * CGFloat(sin(theta))
        let bobY = pivotPosition.y - pendulumLength * CGFloat(cos(theta))
        bobNode.position = CGPoint(x: bobX, y: bobY)

        // Update rod to connect pivot to bob
        let rodPath = CGMutablePath()
        rodPath.move(to: pivotPosition)
        rodPath.addLine(to: bobNode.position)
        rodNode.path = rodPath

        // Update bob color based on balance state
        let isBalanced = viewModel.isWithinBalanceThreshold
        let targetColor = isBalanced ? balancedBobColor : bobColor

        if bobNode.fillColor != targetColor {
            bobNode.run(SKAction.customAction(withDuration: 0.2) { [weak self] node, elapsed in
                guard let bob = node as? SKShapeNode else { return }
                let progress = elapsed / 0.2
                bob.fillColor = self?.interpolateColor(
                    from: bob.fillColor,
                    to: targetColor,
                    progress: progress
                ) ?? targetColor
            })
        }
    }

    private func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        let r = fromR + (toR - fromR) * progress
        let g = fromG + (toG - fromG) * progress
        let b = fromB + (toB - fromB) * progress
        let a = fromA + (toA - fromA) * progress

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
