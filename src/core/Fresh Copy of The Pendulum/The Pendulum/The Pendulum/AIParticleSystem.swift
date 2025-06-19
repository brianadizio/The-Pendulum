import UIKit
import SpriteKit

// MARK: - AI Particle System
class AIParticleSystem {
    
    // Create AI-themed particle emitter
    static func createAIAssistanceParticles() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .circle
        emitter.renderMode = .additive
        
        // Create multiple particle types for a rich effect
        let cells = [
            createDataStreamCell(),
            createNeuralNodeCell(),
            createGoldenSwirlCell(),
            createRainbowSparkCell()
        ]
        
        emitter.emitterCells = cells
        return emitter
    }
    
    // Data stream particles (like binary 1s and 0s)
    private static func createDataStreamCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 15
        cell.lifetime = 2.0
        cell.velocity = 80
        cell.velocityRange = 20
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 1
        cell.scale = 0.3
        cell.scaleRange = 0.1
        cell.alphaSpeed = -0.5
        
        // Create binary-like particle
        cell.contents = createBinaryParticleImage().cgImage
        
        return cell
    }
    
    // Neural network node particles
    private static func createNeuralNodeCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 8
        cell.lifetime = 3.0
        cell.velocity = 50
        cell.velocityRange = 30
        cell.emissionRange = CGFloat.pi * 2
        cell.scale = 0.5
        cell.scaleRange = 0.2
        cell.alphaSpeed = -0.3
        
        // Create node-like particle
        cell.contents = createNeuralNodeImage().cgImage
        
        return cell
    }
    
    // Golden swirl particles (matching the AI icon)
    private static func createGoldenSwirlCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 5
        cell.lifetime = 4.0
        cell.velocity = 40
        cell.velocityRange = 20
        cell.emissionRange = CGFloat.pi * 2
        cell.spin = 3
        cell.spinRange = 2
        cell.scale = 0.4
        cell.scaleRange = 0.2
        cell.alphaSpeed = -0.25
        
        // Create swirl particle
        cell.contents = createSwirlParticleImage().cgImage
        
        return cell
    }
    
    // Rainbow spark particles (matching AI icon colors)
    private static func createRainbowSparkCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 1.5
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = CGFloat.pi * 2
        cell.scale = 0.2
        cell.scaleRange = 0.1
        cell.alphaSpeed = -0.7
        
        // Create rainbow spark
        cell.contents = createRainbowSparkImage().cgImage
        
        return cell
    }
    
    // MARK: - Particle Image Creation
    
    private static func createBinaryParticleImage() -> UIImage {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // Randomly choose 0 or 1
        let text = Bool.random() ? "1" : "0"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        // Add glow effect
        context.setBlendMode(.screen)
        context.setFillColor(UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.3).cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private static func createNeuralNodeImage() -> UIImage {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw neural node with connections
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let nodeRadius: CGFloat = 8
        
        // Draw connections
        context.setStrokeColor(UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.5).cgColor)
        context.setLineWidth(1)
        
        for angle in stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 3) {
            let endPoint = CGPoint(
                x: center.x + cos(angle) * 18,
                y: center.y + sin(angle) * 18
            )
            context.move(to: center)
            context.addLine(to: endPoint)
        }
        context.strokePath()
        
        // Draw central node with gradient
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).cgColor,
                UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0).cgColor
            ] as CFArray,
            locations: [0, 1]
        )!
        
        context.saveGState()
        context.addEllipse(in: CGRect(
            x: center.x - nodeRadius,
            y: center.y - nodeRadius,
            width: nodeRadius * 2,
            height: nodeRadius * 2
        ))
        context.clip()
        context.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: nodeRadius,
            options: []
        )
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private static func createSwirlParticleImage() -> UIImage {
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw golden swirl
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        context.setStrokeColor(FocusCalendarTheme.accentGold.cgColor)
        context.setLineWidth(3)
        context.setLineCap(.round)
        
        // Create spiral path
        var angle: CGFloat = 0
        var radius: CGFloat = 2
        context.move(to: center)
        
        while radius < 20 {
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            context.addLine(to: point)
            angle += 0.3
            radius += 0.5
        }
        
        context.strokePath()
        
        // Add glow
        context.setBlendMode(.screen)
        context.setFillColor(FocusCalendarTheme.accentGold.withAlphaComponent(0.3).cgColor)
        context.fillEllipse(in: CGRect(x: 5, y: 5, width: 40, height: 40))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private static func createRainbowSparkImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // Create rainbow gradient colors (matching AI icon)
        let colors = [
            UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),    // Red
            UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),    // Orange
            UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0),    // Yellow
            UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0),    // Green
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),    // Blue
        ].randomElement()!
        
        // Draw spark
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Create star shape
        let outerRadius: CGFloat = 8
        let innerRadius: CGFloat = 3
        let points = 4
        
        context.move(to: CGPoint(x: center.x, y: center.y - outerRadius))
        
        for i in 0..<points * 2 {
            let angle = (CGFloat.pi * 2 / CGFloat(points * 2)) * CGFloat(i) - CGFloat.pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            context.addLine(to: point)
        }
        
        context.closePath()
        context.setFillColor(colors.cgColor)
        context.fillPath()
        
        // Add glow
        context.setBlendMode(.screen)
        context.setFillColor(colors.withAlphaComponent(0.5).cgColor)
        context.fillEllipse(in: CGRect(x: 2, y: 2, width: 16, height: 16))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - AI Assistance Particle View
class AIAssistanceParticleView: UIView {
    private var particleEmitter: CAEmitterLayer!
    private let aiIconView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        isUserInteractionEnabled = false
        
        // Setup AI icon
        aiIconView.image = UIImage(named: "AIicon")
        aiIconView.contentMode = .scaleAspectFit
        aiIconView.alpha = 0.8
        aiIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(aiIconView)
        
        // Setup particle emitter
        particleEmitter = AIParticleSystem.createAIAssistanceParticles()
        layer.addSublayer(particleEmitter)
        
        // Layout
        NSLayoutConstraint.activate([
            aiIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            aiIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            aiIconView.widthAnchor.constraint(equalToConstant: 60),
            aiIconView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        particleEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        particleEmitter.emitterSize = CGSize(width: 100, height: 100)
    }
    
    func startEmitting() {
        particleEmitter.birthRate = 1.0
        
        // Pulse animation for AI icon
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        aiIconView.layer.add(pulseAnimation, forKey: "pulse")
        
        // Rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 10.0
        rotationAnimation.repeatCount = .infinity
        
        aiIconView.layer.add(rotationAnimation, forKey: "rotation")
    }
    
    func stopEmitting() {
        particleEmitter.birthRate = 0
        aiIconView.layer.removeAllAnimations()
    }
}