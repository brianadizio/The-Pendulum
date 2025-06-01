import UIKit

/// View Controller Level Particle System
/// Replaces SpriteKit-confined particles with full-screen UIView-based effects
/// Uses texture assets and bright rainbow colors like TabTransitionAnimator
class ViewControllerParticleSystem {
    
    // MARK: - Rainbow Colors (from TabTransitionAnimator)
    static let rainbowColors = [
        UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0),    // Bright yellow
        UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0),   // Golden yellow
        UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),    // Bright orange
        UIColor(red: 0.95, green: 0.4, blue: 0.1, alpha: 1.0),   // Red-orange
        UIColor(red: 0.9, green: 0.3, blue: 0.15, alpha: 1.0),   // Warm red
        UIColor(red: 0.7, green: 0.2, blue: 0.5, alpha: 1.0),    // Magenta
        UIColor(red: 0.5, green: 0.2, blue: 0.5, alpha: 1.0),    // Purple
        UIColor(red: 0.2, green: 0.55, blue: 0.6, alpha: 1.0),   // Teal blue
        UIColor(red: 0.1, green: 0.4, blue: 0.6, alpha: 1.0),    // Deep blue
        UIColor(red: 0.3, green: 0.6, blue: 0.4, alpha: 1.0),    // Green
        UIColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0)     // Yellow-green
    ]
    
    // MARK: - Texture Assets
    static let coastTextures = [
        "textureCoast1", "textureCoast2", "textureCoast3",
        "textureCoast4", "textureCoast5", "textureCoast6",
        "textureCoast7", "textureCoast8", "textureCoast9"
    ]
    
    static let starTextures = [
        "textureStars1", "textureStars2", "textureStars3",
        "textureStars4", "textureStars5", "textureStars6",
        "textureStars7", "textureStars8", "textureStars9"
    ]
    
    // MARK: - Main Explosion Effect
    /// Creates multiple random explosions throughout the screen with texture-based particles
    static func createMultipleExplosions(in view: UIView, count: Int = 5) {
        // Bound the maximum number of explosions to prevent overwhelming effects
        let boundedCount = min(count, 6) // Cap at 6 explosions max
        
        for i in 0..<boundedCount {
            let delay = Double(i) * 0.16 // Reduced from 0.2 to 0.16 (82% of original)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Random position on screen
                let x = CGFloat.random(in: 50...(view.bounds.width - 50))
                let y = CGFloat.random(in: 100...(view.bounds.height - 100))
                let position = CGPoint(x: x, y: y)
                
                // Create explosion at random position with color cycling
                createTextureExplosion(at: position, in: view, colorOffset: i)
            }
        }
    }
    
    /// Creates a texture-based explosion with bright rainbow colors
    static func createTextureExplosion(at origin: CGPoint, in view: UIView, colorOffset: Int = 0) {
        // Create 32-42 particles per explosion (1.75x increase: 18-24 * 1.75 = 31.5-42)
        let particleCount = Int.random(in: 32...42)
        
        for i in 0..<particleCount {
            let delay = Double(i) * 0.008 // Reduced from 0.01 to 0.008 (82% of original)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Cycle through ALL rainbow colors systematically
                let colorIndex = (i + colorOffset * 3) % rainbowColors.count
                createTextureParticle(at: origin, in: view, colorIndex: colorIndex)
            }
        }
        
        // Add ripple effect with reduced timing
        createRippleEffect(at: origin, in: view)
    }
    
    /// Creates a single texture-based particle with glow
    static func createTextureParticle(at origin: CGPoint, in view: UIView, colorIndex: Int) {
        // 50% chance to create a colored particle instead of texture
        if Int.random(in: 0...9) < 5 {
            createFallbackParticle(at: origin, in: view, colorIndex: colorIndex)
            return
        }
        
        // Random texture from assets
        let allTextures = coastTextures + starTextures
        guard let textureName = allTextures.randomElement(),
              let textureImage = UIImage(named: textureName) else {
            // Fallback to simple colored particle
            createFallbackParticle(at: origin, in: view, colorIndex: colorIndex)
            return
        }
        
        // Create particle view with texture
        let particleSize = CGFloat.random(in: 16...32)
        let particle = UIImageView(image: textureImage)
        particle.frame = CGRect(x: 0, y: 0, width: particleSize, height: particleSize)
        particle.center = origin
        particle.contentMode = .scaleAspectFill
        particle.layer.cornerRadius = particleSize / 2
        particle.clipsToBounds = true
        
        // Don't tint the texture - let it show its natural colors
        particle.alpha = 0.9
        
        view.addSubview(particle)
        
        // Random direction and distance
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let distance = CGFloat.random(in: 80...200)
        let endPoint = CGPoint(
            x: origin.x + cos(angle) * distance,
            y: origin.y + sin(angle) * distance
        )
        
        // Create animation with rotation - reduced duration to 82% (0.98s)
        UIView.animate(withDuration: 0.98, delay: 0, options: .curveEaseOut, animations: {
            particle.center = endPoint
            particle.alpha = 0
            particle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: CGFloat.pi * 2)
        }) { _ in
            particle.removeFromSuperview()
        }
    }
    
    /// Fallback particle when texture loading fails
    static func createFallbackParticle(at origin: CGPoint, in view: UIView, colorIndex: Int) {
        let particleSize = CGFloat.random(in: 12...20)
        let particle = UIView(frame: CGRect(x: 0, y: 0, width: particleSize, height: particleSize))
        particle.center = origin
        particle.backgroundColor = rainbowColors[colorIndex % rainbowColors.count]
        particle.layer.cornerRadius = particleSize / 2
        particle.alpha = 0.9
        
        // Add glow effect
        particle.layer.shadowColor = particle.backgroundColor?.cgColor
        particle.layer.shadowOffset = .zero
        particle.layer.shadowRadius = 6
        particle.layer.shadowOpacity = 0.8
        
        view.addSubview(particle)
        
        // Animation with reduced duration (82%)
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let distance = CGFloat.random(in: 60...150)
        let endPoint = CGPoint(
            x: origin.x + cos(angle) * distance,
            y: origin.y + sin(angle) * distance
        )
        
        UIView.animate(withDuration: 0.82, delay: 0, options: .curveEaseOut, animations: {
            particle.center = endPoint
            particle.alpha = 0
            particle.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { _ in
            particle.removeFromSuperview()
        }
    }
    
    /// Creates shaded ball particles like TabTransitionAnimator instead of ripples
    static func createRippleEffect(at point: CGPoint, in view: UIView) {
        // Create 21-26 small shaded ball particles instead of ripples (1.75x increase: 12-15 * 1.75 = 21-26.25)
        for i in 0..<26 {
            let delay = Double(i) * 0.02 // Reduced timing (82% of 0.025)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Create particle view like TabTransitionAnimator
                let particleSize = CGFloat.random(in: 8...16)
                let particle = UIView(frame: CGRect(x: 0, y: 0, width: particleSize, height: particleSize))
                particle.center = point
                particle.backgroundColor = rainbowColors[i % rainbowColors.count]
                particle.layer.cornerRadius = particleSize / 2
                particle.alpha = 0.9
                
                // Add glow effect like TabTransitionAnimator
                particle.layer.shadowColor = particle.backgroundColor?.cgColor
                particle.layer.shadowOffset = .zero
                particle.layer.shadowRadius = 4
                particle.layer.shadowOpacity = 0.8
                
                view.addSubview(particle)
                
                // Random direction and distance
                let angle = CGFloat.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 50...120) // Smaller spread than main particles
                let endPoint = CGPoint(
                    x: point.x + cos(angle) * distance,
                    y: point.y + sin(angle) * distance
                )
                
                // Create animation like TabTransitionAnimator - reduced duration (82%)
                UIView.animate(withDuration: 0.49, delay: 0, options: .curveEaseOut, animations: {
                    particle.center = endPoint
                    particle.alpha = 0
                    particle.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                }) { _ in
                    particle.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: - Achievement Celebration
    /// Creates a full-screen celebration effect for level completion
    static func createAchievementCelebration(in view: UIView) {
        // Multiple waves of explosions with 82% timing
        for wave in 0..<3 {
            let waveDelay = Double(wave) * 0.66 // Reduced from 0.8 to 0.66 (82%)
            DispatchQueue.main.asyncAfter(deadline: .now() + waveDelay) {
                createMultipleExplosions(in: view, count: 4)
            }
        }
        
        // Add corner bursts with reduced timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { // Reduced from 0.3 to 0.25 (82%)
            createCornerBurst(in: view, corner: .topLeft)
            createCornerBurst(in: view, corner: .topRight)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.82) { // Reduced from 1.0 to 0.82 (82%)
            createCornerBurst(in: view, corner: .bottomLeft)
            createCornerBurst(in: view, corner: .bottomRight)
        }
        
        // Rain effect with reduced timing and duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.41) { // Reduced from 0.5 to 0.41 (82%)
            createTextureRain(in: view, duration: 1.64) // Reduced from 2.0 to 1.64 (82%)
        }
    }
    
    /// Creates a corner burst (like TabTransitionAnimator)
    static func createCornerBurst(in view: UIView, corner: UIRectCorner) {
        let point: CGPoint
        switch corner {
        case .topLeft:
            point = CGPoint(x: 50, y: 100)
        case .topRight:
            point = CGPoint(x: view.bounds.width - 50, y: 100)
        case .bottomLeft:
            point = CGPoint(x: 50, y: view.bounds.height - 150)
        case .bottomRight:
            point = CGPoint(x: view.bounds.width - 50, y: view.bounds.height - 150)
        default:
            point = CGPoint(x: view.bounds.width - 50, y: view.bounds.height - 150)
        }
        
        createTextureExplosion(at: point, in: view)
    }
    
    /// Creates a rain effect with texture particles
    static func createTextureRain(in view: UIView, duration: TimeInterval) {
        let particleCount = 56 // Increased from 32 (1.75x increase: 32 * 1.75 = 56)
        
        for i in 0..<particleCount {
            let delay = Double(i) * (duration / Double(particleCount))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // 50% chance for colored particle
                if Int.random(in: 0...9) < 5 {
                    // Create colored raindrop
                    let particleSize = CGFloat.random(in: 10...18)
                    let particle = UIView(frame: CGRect(x: 0, y: 0, width: particleSize, height: particleSize))
                    let color = rainbowColors[i % rainbowColors.count]
                    particle.backgroundColor = color
                    particle.layer.cornerRadius = particleSize / 2
                    particle.alpha = 0.8
                    
                    // Add glow
                    particle.layer.shadowColor = color.cgColor
                    particle.layer.shadowOffset = .zero
                    particle.layer.shadowRadius = 4
                    particle.layer.shadowOpacity = 0.6
                    
                    // Start above screen
                    let startX = CGFloat.random(in: 0...view.bounds.width)
                    particle.center = CGPoint(x: startX, y: -particleSize)
                    
                    view.addSubview(particle)
                    
                    // Fall down animation
                    let endX = startX + CGFloat.random(in: -50...50)
                    let endY = view.bounds.height + particleSize
                    
                    UIView.animate(withDuration: 1.64, delay: 0, options: .curveLinear, animations: {
                        particle.center = CGPoint(x: endX, y: endY)
                        particle.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    }) { _ in
                        particle.removeFromSuperview()
                    }
                    return
                }
                
                // Random texture
                let allTextures = coastTextures + starTextures
                guard let textureName = allTextures.randomElement(),
                      let textureImage = UIImage(named: textureName) else { return }
                
                // Create raindrop particle
                let particleSize = CGFloat.random(in: 8...16)
                let particle = UIImageView(image: textureImage)
                particle.frame = CGRect(x: 0, y: 0, width: particleSize, height: particleSize)
                particle.contentMode = .scaleAspectFill
                particle.layer.cornerRadius = particleSize / 2
                particle.clipsToBounds = true
                
                // Don't tint - show natural texture colors
                particle.alpha = 0.7
                
                // Start above screen
                let startX = CGFloat.random(in: 0...view.bounds.width)
                particle.center = CGPoint(x: startX, y: -particleSize)
                
                view.addSubview(particle)
                
                // Fall down with slight horizontal drift - reduced duration (82%)
                let endX = startX + CGFloat.random(in: -50...50)
                let endY = view.bounds.height + particleSize
                
                UIView.animate(withDuration: 1.64, delay: 0, options: .curveLinear, animations: {
                    particle.center = CGPoint(x: endX, y: endY)
                    particle.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }) { _ in
                    particle.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: - Quick Effects
    /// Creates a simple burst at a specific point
    static func createQuickBurst(at point: CGPoint, in view: UIView) {
        TabTransitionAnimator.createTabTransitionBurst(at: point, in: view)
    }
    
    /// Creates a trail effect between two points using textures
    static func createTextureTrail(from startPoint: CGPoint, to endPoint: CGPoint, in view: UIView) {
        let steps = 21 // Increased from 12 (1.75x increase: 12 * 1.75 = 21)
        
        for i in 0..<steps {
            let progress = CGFloat(i) / CGFloat(steps - 1)
            let x = startPoint.x + (endPoint.x - startPoint.x) * progress
            let y = startPoint.y + (endPoint.y - startPoint.y) * progress
            
            // Random texture
            guard let textureName = starTextures.randomElement(),
                  let textureImage = UIImage(named: textureName) else { continue }
            
            let particle = UIImageView(image: textureImage)
            particle.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
            particle.center = CGPoint(x: x, y: y)
            particle.contentMode = .scaleAspectFill
            particle.layer.cornerRadius = 4
            particle.clipsToBounds = true
            particle.tintColor = rainbowColors[i % rainbowColors.count]
            particle.alpha = 0
            
            view.addSubview(particle)
            
            UIView.animate(withDuration: 0.3, delay: Double(i) * 0.05, options: .curveEaseInOut, animations: {
                particle.alpha = 0.8
                particle.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            }) { _ in
                UIView.animate(withDuration: 0.4, animations: {
                    particle.alpha = 0
                    particle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }) { _ in
                    particle.removeFromSuperview()
                }
            }
        }
    }
}