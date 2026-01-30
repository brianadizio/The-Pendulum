// PendulumSceneView.swift
// The Pendulum 2.0
// UIViewRepresentable wrapper for SpriteKit scene

import SwiftUI
import SpriteKit

struct PendulumSceneView: UIViewRepresentable {
    @ObservedObject var viewModel: PendulumViewModel
    var isPaused: Bool = false  // Control SKView pausing to free Metal resources

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .clear

        return skView
    }

    func updateUIView(_ skView: SKView, context: Context) {
        // Control SKView pausing - this frees Metal drawable resources
        skView.isPaused = isPaused

        // Only create scene once we have a valid size and not paused
        if skView.scene == nil && skView.bounds.size.width > 0 && skView.bounds.size.height > 0 {
            let scene = PendulumScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            scene.viewModel = viewModel
            // Golden Theme parchment/cream background
            scene.backgroundColor = UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)
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

    // Radial danger zone layers (green → yellow → orange → red)
    private var zoneNodes: [SKShapeNode] = []

    // Current balance threshold for zone rendering (tracks viewModel's threshold)
    private var currentBalanceThreshold: CGFloat = 0.35

    // Pendulum dimensions
    private var pendulumLength: CGFloat = 200
    private var bobRadius: CGFloat = 25
    private var pivotRadius: CGFloat = 12

    // Golden Theme Colors
    private let parchmentColor = UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)
    private let goldColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)      // DAA520
    private let bronzeColor = UIColor(red: 0.55, green: 0.41, blue: 0.08, alpha: 1.0)   // Bronze dark
    private let ironColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)     // Iron

    // Zone colors (radial gradient from pivot)
    private let greenZoneColor = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 0.25)   // Success green
    private let yellowZoneColor = UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 0.25) // Warning yellow
    private let orangeZoneColor = UIColor(red: 0.95, green: 0.55, blue: 0.13, alpha: 0.25) // Orange
    private let redZoneColor = UIColor(red: 0.80, green: 0.20, blue: 0.15, alpha: 0.25)    // Danger red

    // Bob colors
    private let bobNormalColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)  // Gold
    private let bobBalancedColor = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0) // Green

    override func didMove(to view: SKView) {
        backgroundColor = parchmentColor
        setupScene()
    }

    private func setupScene() {
        guard size.width > 0 && size.height > 0 else { return }

        // Calculate pendulum length based on screen size
        pendulumLength = min(size.height * 0.30, size.width * 0.35)
        bobRadius = pendulumLength * 0.12
        pivotRadius = pendulumLength * 0.05

        // Pivot position - moved UP to 35% from bottom (was 15%)
        let pivotPosition = CGPoint(x: size.width / 2, y: size.height * 0.35)

        // Create radial danger zones (arcs emanating from pivot)
        createRadialZones(at: pivotPosition)

        // Create ground/base platform
        let platformWidth: CGFloat = 80
        let platformHeight: CGFloat = 12
        let platformPath = CGMutablePath()
        platformPath.addRoundedRect(
            in: CGRect(
                x: pivotPosition.x - platformWidth / 2,
                y: pivotPosition.y - platformHeight / 2 - 5,
                width: platformWidth,
                height: platformHeight
            ),
            cornerWidth: 4,
            cornerHeight: 4
        )
        groundNode = SKShapeNode(path: platformPath)
        groundNode.fillColor = bronzeColor
        groundNode.strokeColor = ironColor
        groundNode.lineWidth = 2
        groundNode.zPosition = 8
        addChild(groundNode)

        // Create pivot point
        pivotNode = SKShapeNode(circleOfRadius: pivotRadius)
        pivotNode.position = pivotPosition
        pivotNode.fillColor = goldColor
        pivotNode.strokeColor = bronzeColor
        pivotNode.lineWidth = 2
        pivotNode.zPosition = 10
        addChild(pivotNode)

        // Create rod
        let rodPath = CGMutablePath()
        rodPath.move(to: pivotPosition)
        rodPath.addLine(to: CGPoint(x: pivotPosition.x, y: pivotPosition.y + pendulumLength))
        rodNode = SKShapeNode(path: rodPath)
        rodNode.strokeColor = ironColor
        rodNode.lineWidth = 5
        rodNode.lineCap = .round
        rodNode.zPosition = 5
        addChild(rodNode)

        // Create bob
        bobNode = SKShapeNode(circleOfRadius: bobRadius)
        bobNode.position = CGPoint(x: pivotPosition.x, y: pivotPosition.y + pendulumLength)
        bobNode.fillColor = bobNormalColor
        bobNode.strokeColor = bronzeColor
        bobNode.lineWidth = 3
        bobNode.zPosition = 15
        addChild(bobNode)

        // Add subtle inner highlight to bob
        let highlightNode = SKShapeNode(circleOfRadius: bobRadius * 0.6)
        highlightNode.position = CGPoint(x: -bobRadius * 0.15, y: bobRadius * 0.15)
        highlightNode.fillColor = UIColor.white.withAlphaComponent(0.2)
        highlightNode.strokeColor = .clear
        highlightNode.zPosition = 1
        bobNode.addChild(highlightNode)
    }

    private func createRadialZones(at pivot: CGPoint) {
        // Clear existing zones
        zoneNodes.forEach { $0.removeFromParent() }
        zoneNodes.removeAll()

        // Zone angles (in radians from upright)
        // Green zone matches the current balance threshold (dynamic for Spatial mode)
        // Remaining zones subdivide the space between threshold and fall (π/2)
        let bt = currentBalanceThreshold
        let fallAngle = CGFloat.pi / 2
        let remaining = fallAngle - bt
        let zones: [(maxAngle: CGFloat, color: UIColor)] = [
            (bt, greenZoneColor),                          // 0 to threshold - Safe/balanced
            (bt + remaining / 3.0, yellowZoneColor),       // threshold to 1/3 remaining - Caution
            (bt + remaining * 2.0 / 3.0, orangeZoneColor), // 1/3 to 2/3 remaining - Warning
            (fallAngle, redZoneColor)                       // 2/3 to fall - Danger
        ]

        // Create arc zones (drawn as pie slices from pivot)
        var previousAngle: CGFloat = 0

        for (index, zone) in zones.enumerated() {
            // Create left and right arcs for this zone
            let zoneRadius = pendulumLength * 1.15  // Slightly larger than pendulum

            // Left arc (negative angles)
            let leftArcPath = CGMutablePath()
            leftArcPath.move(to: pivot)
            // Angles measured from straight up (12 o'clock = π/2 in SpriteKit coords)
            let startAngleLeft = CGFloat.pi / 2 + previousAngle
            let endAngleLeft = CGFloat.pi / 2 + zone.maxAngle
            leftArcPath.addArc(center: pivot, radius: zoneRadius,
                              startAngle: startAngleLeft, endAngle: endAngleLeft,
                              clockwise: false)
            leftArcPath.closeSubpath()

            let leftNode = SKShapeNode(path: leftArcPath)
            leftNode.fillColor = zone.color
            leftNode.strokeColor = zone.color.withAlphaComponent(0.4)
            leftNode.lineWidth = 1
            leftNode.zPosition = CGFloat(index)
            addChild(leftNode)
            zoneNodes.append(leftNode)

            // Right arc (negative angles - mirrored)
            let rightArcPath = CGMutablePath()
            rightArcPath.move(to: pivot)
            let startAngleRight = CGFloat.pi / 2 - previousAngle
            let endAngleRight = CGFloat.pi / 2 - zone.maxAngle
            rightArcPath.addArc(center: pivot, radius: zoneRadius,
                               startAngle: startAngleRight, endAngle: endAngleRight,
                               clockwise: true)
            rightArcPath.closeSubpath()

            let rightNode = SKShapeNode(path: rightArcPath)
            rightNode.fillColor = zone.color
            rightNode.strokeColor = zone.color.withAlphaComponent(0.4)
            rightNode.lineWidth = 1
            rightNode.zPosition = CGFloat(index)
            addChild(rightNode)
            zoneNodes.append(rightNode)

            previousAngle = zone.maxAngle
        }
    }

    func layoutPendulum() {
        guard pivotNode != nil else { return }

        // Recalculate dimensions
        pendulumLength = min(size.height * 0.30, size.width * 0.35)
        bobRadius = pendulumLength * 0.12
        pivotRadius = pendulumLength * 0.05

        // Update pivot position (35% from bottom)
        let pivotPosition = CGPoint(x: size.width / 2, y: size.height * 0.35)
        pivotNode.position = pivotPosition

        // Update ground platform
        let platformWidth: CGFloat = 80
        let platformHeight: CGFloat = 12
        let platformPath = CGMutablePath()
        platformPath.addRoundedRect(
            in: CGRect(
                x: pivotPosition.x - platformWidth / 2,
                y: pivotPosition.y - platformHeight / 2 - 5,
                width: platformWidth,
                height: platformHeight
            ),
            cornerWidth: 4,
            cornerHeight: 4
        )
        groundNode.path = platformPath

        // Recreate radial zones
        createRadialZones(at: pivotPosition)
    }

    /// Update the balance threshold and rebuild zones if it changed
    func updateBalanceThreshold(_ threshold: CGFloat) {
        guard abs(threshold - currentBalanceThreshold) > 0.001 else { return }
        currentBalanceThreshold = threshold
        if let pivot = pivotNode?.position {
            createRadialZones(at: pivot)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard let viewModel = viewModel else { return }

        // Check if balance threshold changed (e.g. Spatial mode level advance)
        let vmThreshold = CGFloat(viewModel.balanceThreshold)
        if abs(vmThreshold - currentBalanceThreshold) > 0.001 {
            updateBalanceThreshold(vmThreshold)
        }

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
        let targetColor = isBalanced ? bobBalancedColor : bobNormalColor

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
