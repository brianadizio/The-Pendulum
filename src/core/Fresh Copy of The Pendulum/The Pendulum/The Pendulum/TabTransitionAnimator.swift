import UIKit

class TabTransitionAnimator {
    
    // Rainbow colors from the painting
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
    
    /// Creates a burst of colored particles at the tap location
    static func createTabTransitionBurst(at point: CGPoint, in view: UIView) {
        // Create 15-20 particles
        for i in 0..<15 {
            createParticle(at: point, in: view, index: i)
        }
    }
    
    /// Creates a corner burst animation (bottom right by default)
    static func createCornerBurst(in view: UIView, corner: UIRectCorner = .bottomRight) {
        let point: CGPoint
        switch corner {
        case .topLeft:
            point = CGPoint(x: 30, y: 30)
        case .topRight:
            point = CGPoint(x: view.bounds.width - 30, y: 30)
        case .bottomLeft:
            point = CGPoint(x: 30, y: view.bounds.height - 30)
        case .bottomRight:
            point = CGPoint(x: view.bounds.width - 30, y: view.bounds.height - 100) // Above tab bar
        default:
            point = CGPoint(x: view.bounds.width - 30, y: view.bounds.height - 100)
        }
        
        createTabTransitionBurst(at: point, in: view)
    }
    
    private static func createParticle(at origin: CGPoint, in view: UIView, index: Int) {
        // Create particle view
        let particleSize = CGFloat.random(in: 8...16)
        let particle = UIView(frame: CGRect(x: 0, y: 0, width: particleSize, height: particleSize))
        particle.center = origin
        particle.backgroundColor = rainbowColors[index % rainbowColors.count]
        particle.layer.cornerRadius = particleSize / 2
        particle.alpha = 0.9
        
        // Add glow effect
        particle.layer.shadowColor = particle.backgroundColor?.cgColor
        particle.layer.shadowOffset = .zero
        particle.layer.shadowRadius = 4
        particle.layer.shadowOpacity = 0.8
        
        view.addSubview(particle)
        
        // Random direction and distance
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let distance = CGFloat.random(in: 50...150)
        let endPoint = CGPoint(
            x: origin.x + cos(angle) * distance,
            y: origin.y + sin(angle) * distance
        )
        
        // Create animation
        UIView.animate(withDuration: 0.6, delay: Double(index) * 0.02, options: .curveEaseOut, animations: {
            particle.center = endPoint
            particle.alpha = 0
            particle.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { _ in
            particle.removeFromSuperview()
        }
    }
    
    /// Creates a ripple effect with rainbow colors
    static func createRippleEffect(at point: CGPoint, in view: UIView) {
        for i in 0..<5 {
            let delay = Double(i) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let ripple = UIView()
                ripple.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
                ripple.center = point
                ripple.layer.cornerRadius = 10
                ripple.backgroundColor = .clear
                ripple.layer.borderColor = rainbowColors[i % rainbowColors.count].cgColor
                ripple.layer.borderWidth = 2
                ripple.alpha = 0.8
                
                view.addSubview(ripple)
                
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
                    ripple.transform = CGAffineTransform(scaleX: 4, y: 4)
                    ripple.alpha = 0
                }) { _ in
                    ripple.removeFromSuperview()
                }
            }
        }
    }
    
    /// Creates a trail of colored dots
    static func createColorTrail(from startPoint: CGPoint, to endPoint: CGPoint, in view: UIView) {
        let steps = 10
        
        for i in 0..<steps {
            let progress = CGFloat(i) / CGFloat(steps - 1)
            let x = startPoint.x + (endPoint.x - startPoint.x) * progress
            let y = startPoint.y + (endPoint.y - startPoint.y) * progress
            
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            dot.center = CGPoint(x: x, y: y)
            dot.backgroundColor = rainbowColors[i % rainbowColors.count]
            dot.layer.cornerRadius = 3
            dot.alpha = 0
            
            view.addSubview(dot)
            
            UIView.animate(withDuration: 0.3, delay: Double(i) * 0.03, options: .curveEaseInOut, animations: {
                dot.alpha = 0.8
                dot.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    dot.alpha = 0
                    dot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }) { _ in
                    dot.removeFromSuperview()
                }
            }
        }
    }
}