import UIKit
import SpriteKit

// MARK: - Sparkle Particle View
class SparkleParticleView: UIView {
    private var particleEmitter: CAEmitterLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupParticles()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupParticles()
    }
    
    private func setupParticles() {
        particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        particleEmitter.emitterSize = bounds.size
        particleEmitter.emitterShape = .rectangle
        particleEmitter.renderMode = .additive
        
        let sparkleCell = CAEmitterCell()
        sparkleCell.birthRate = 20
        sparkleCell.lifetime = 1.5
        sparkleCell.velocity = 50
        sparkleCell.velocityRange = 30
        sparkleCell.emissionRange = .pi * 2
        sparkleCell.spin = 2
        sparkleCell.spinRange = 3
        sparkleCell.scale = 0.15
        sparkleCell.scaleRange = 0.1
        sparkleCell.alphaSpeed = -0.8
        
        // Create sparkle image
        sparkleCell.contents = createSparkleImage().cgImage
        
        particleEmitter.emitterCells = [sparkleCell]
        layer.addSublayer(particleEmitter)
        
        isUserInteractionEnabled = false
    }
    
    private func createSparkleImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw a star/sparkle shape
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius: CGFloat = 8
        
        // Create gradient from gold to white
        let colors = [
            FocusCalendarTheme.accentGold.cgColor,
            UIColor.white.cgColor
        ]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: [0, 1])!
        
        // Draw radial gradient
        context.drawRadialGradient(gradient,
                                   startCenter: center,
                                   startRadius: 0,
                                   endCenter: center,
                                   endRadius: radius,
                                   options: [])
        
        // Add glow effect
        context.setBlendMode(.screen)
        context.drawRadialGradient(gradient,
                                   startCenter: center,
                                   startRadius: 0,
                                   endCenter: center,
                                   endRadius: radius * 1.5,
                                   options: [])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        particleEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        particleEmitter.emitterSize = bounds.size
    }
    
    func startSparkles() {
        particleEmitter.birthRate = 20
    }
    
    func stopSparkles() {
        particleEmitter.birthRate = 0
    }
}

// MARK: - Enhanced AI Assistance Label
class EnhancedAIAssistanceView: UIView {
    private let label = UILabel()
    private let sparkleView = SparkleParticleView()
    private let aiParticleView = AIAssistanceParticleView()
    private let aiIconView = UIImageView()
    private let pulseLayer = CAShapeLayer()
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure container
        backgroundColor = FocusCalendarTheme.cardBackgroundColor
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = FocusCalendarTheme.accentGold.cgColor
        
        // Add shadow for depth
        layer.shadowColor = FocusCalendarTheme.accentGold.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Add AI particle view (behind everything)
        aiParticleView.translatesAutoresizingMaskIntoConstraints = false
        aiParticleView.alpha = 0.6
        addSubview(aiParticleView)
        
        // Add sparkle view
        sparkleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sparkleView)
        
        // Add AI icon
        aiIconView.image = UIImage(named: "AIicon")
        aiIconView.contentMode = .scaleAspectFit
        aiIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(aiIconView)
        
        // Configure label
        label.text = "AI Assistance Active"
        label.textColor = FocusCalendarTheme.primaryTextColor
        label.font = FocusCalendarTheme.Fonts.titleFont(size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        // Setup pulse layer
        setupPulseAnimation()
        
        NSLayoutConstraint.activate([
            // AI particle view fills the entire view
            aiParticleView.topAnchor.constraint(equalTo: topAnchor),
            aiParticleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            aiParticleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            aiParticleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            sparkleView.topAnchor.constraint(equalTo: topAnchor),
            sparkleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sparkleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sparkleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // AI icon on the left
            aiIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            aiIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            aiIconView.widthAnchor.constraint(equalToConstant: 30),
            aiIconView.heightAnchor.constraint(equalToConstant: 30),
            
            // Label next to icon
            label.leadingAnchor.constraint(equalTo: aiIconView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    private func setupPulseAnimation() {
        pulseLayer.fillColor = FocusCalendarTheme.accentGold.withAlphaComponent(0.3).cgColor
        pulseLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        layer.insertSublayer(pulseLayer, below: layer.sublayers?.first)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 20)
        pulseLayer.path = path.cgPath
        pulseLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        pulseLayer.bounds = bounds
    }
    
    func show(animated: Bool = true) {
        isHidden = false
        sparkleView.startSparkles()
        aiParticleView.startEmitting()
        
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = .identity
            }) { _ in
                self.startPulseAnimation()
                self.animateAIIcon()
            }
        } else {
            alpha = 1
            transform = .identity
            startPulseAnimation()
            animateAIIcon()
        }
    }
    
    func hide(animated: Bool = true) {
        stopPulseAnimation()
        sparkleView.stopSparkles()
        aiParticleView.stopEmitting()
        aiIconView.layer.removeAllAnimations()
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.isHidden = true
            }
        } else {
            isHidden = true
        }
    }
    
    private func animateAIIcon() {
        // Gentle rotation animation for AI icon
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = -0.1
        rotationAnimation.toValue = 0.1
        rotationAnimation.duration = 2.0
        rotationAnimation.autoreverses = true
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        aiIconView.layer.add(rotationAnimation, forKey: "iconRotation")
    }
    
    private func startPulseAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.05
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(pulseAnimation, forKey: "pulse")
        
        // Glow animation
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0.5
        glowAnimation.toValue = 0.8
        glowAnimation.duration = 1.0
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(glowAnimation, forKey: "glow")
    }
    
    private func stopPulseAnimation() {
        isAnimating = false
        layer.removeAnimation(forKey: "pulse")
        layer.removeAnimation(forKey: "glow")
    }
}

// MARK: - AI Push Indicator with Sparkles
class SparklingPushIndicator: UIView {
    private let arrowImageView = UIImageView()
    private let sparkleView = SparkleParticleView()
    private let aiParticleView = AIAssistanceParticleView()
    private let aiIconView = UIImageView()
    private let isLeft: Bool
    
    init(isLeft: Bool) {
        self.isLeft = isLeft
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.isLeft = false
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = FocusCalendarTheme.accentGold.withAlphaComponent(0.3)
        layer.cornerRadius = 30
        layer.borderWidth = 3
        layer.borderColor = FocusCalendarTheme.accentGold.cgColor
        
        // Add glow
        layer.shadowColor = FocusCalendarTheme.accentGold.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 15
        layer.shadowOffset = .zero
        
        // Add AI particles
        aiParticleView.translatesAutoresizingMaskIntoConstraints = false
        aiParticleView.alpha = 0.8
        addSubview(aiParticleView)
        
        // Add sparkles
        sparkleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sparkleView)
        
        // Add small AI icon
        aiIconView.image = UIImage(named: "AIicon")
        aiIconView.contentMode = .scaleAspectFit
        aiIconView.alpha = 0.9
        aiIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(aiIconView)
        
        // Configure arrow
        arrowImageView.image = UIImage(systemName: isLeft ? "arrow.right" : "arrow.left")
        arrowImageView.tintColor = FocusCalendarTheme.primaryTextColor
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            aiParticleView.topAnchor.constraint(equalTo: topAnchor),
            aiParticleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            aiParticleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            aiParticleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            sparkleView.topAnchor.constraint(equalTo: topAnchor),
            sparkleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sparkleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sparkleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Small AI icon in corner
            aiIconView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            aiIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            aiIconView.widthAnchor.constraint(equalToConstant: 20),
            aiIconView.heightAnchor.constraint(equalToConstant: 20),
            
            arrowImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 30),
            arrowImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        isHidden = true
    }
    
    func showPush() {
        isHidden = false
        alpha = 1.0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        sparkleView.startSparkles()
        aiParticleView.startEmitting()
        
        // Animate AI icon
        UIView.animate(withDuration: 0.2) {
            self.aiIconView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        
        // Animate push effect
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.1, options: [], animations: {
                self.alpha = 0.3
                self.aiIconView.transform = .identity
            }) { _ in
                self.sparkleView.stopSparkles()
                self.aiParticleView.stopEmitting()
                self.isHidden = true
            }
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}