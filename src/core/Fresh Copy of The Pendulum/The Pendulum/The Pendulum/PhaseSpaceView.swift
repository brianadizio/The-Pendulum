import UIKit

class PhaseSpaceView: UIView {
    private var points: [CGPoint] = []
    private let maxPoints = 500
    private let pointColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.9) // Bright blue for dark background
    private let axisColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8) // Light gray for dark background
    private let originColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0) // Bright red for dark background
    
    // Scaling factors
    private let thetaScale: CGFloat = 100.0 // pixels per radian
    private let omegaScale: CGFloat = 50.0  // pixels per radian/sec
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 0.1, alpha: 0.9) // Dark background for better visibility
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor // White border for contrast
        
        // Make the view more prominent
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 6
    }
    
    func addPoint(theta: Double, omega: Double) {
        let point = convert(theta: theta, omega: omega)
        points.append(point)
        
        if points.count > maxPoints {
            points.removeFirst()
        }
        
        setNeedsDisplay()
    }
    
    func clearPoints() {
        points.removeAll()
        setNeedsDisplay()
    }
    
    private func convert(theta: Double, omega: Double) -> CGPoint {
        // Convert physics coordinates to view coordinates
        // Center of view is origin of phase space
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        // Normalize angle to [-π, π] and adjust for inverted pendulum (centered at π)
        let normalizedTheta = atan2(sin(theta-Double.pi), cos(theta-Double.pi))
        
        let x = centerX + CGFloat(normalizedTheta) * thetaScale
        let y = centerY - CGFloat(omega) * omegaScale // Negative because UI coordinates go down
        
        return CGPoint(x: x, y: y)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw axes
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        context.setLineWidth(1.0)
        context.setStrokeColor(axisColor.cgColor)
        
        // X-axis (theta)
        context.move(to: CGPoint(x: 10, y: centerY))
        context.addLine(to: CGPoint(x: bounds.width - 10, y: centerY))
        
        // Y-axis (omega)
        context.move(to: CGPoint(x: centerX, y: bounds.height - 10))
        context.addLine(to: CGPoint(x: centerX, y: 10))
        
        context.strokePath()
        
        // Draw axis labels
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        
        // Theta label
        let thetaLabel = "θ"
        let thetaSize = thetaLabel.size(withAttributes: labelAttrs)
        thetaLabel.draw(at: CGPoint(x: bounds.width - thetaSize.width - 5, y: centerY + 5), withAttributes: labelAttrs)
        
        // Omega label
        let omegaLabel = "ω"
        let omegaSize = omegaLabel.size(withAttributes: labelAttrs)
        omegaLabel.draw(at: CGPoint(x: centerX + 5, y: 5), withAttributes: labelAttrs)
        
        // Draw origin point
        context.setFillColor(originColor.cgColor)
        context.fillEllipse(in: CGRect(x: centerX - 4, y: centerY - 4, width: 8, height: 8))
        
        // Draw points with gradient alpha
        if points.count > 1 {
            context.setLineWidth(2.0)
            
            // Start path at first point
            context.move(to: points[0])
            
            // Draw lines between all points
            for i in 1..<points.count {
                let alpha = CGFloat(i) / CGFloat(points.count)
                context.setStrokeColor(pointColor.withAlphaComponent(alpha).cgColor)
                
                context.addLine(to: points[i])
                context.strokePath()
                
                // Start next segment
                context.move(to: points[i])
            }
            
            // Draw current point as a larger dot
            if let lastPoint = points.last {
                context.setFillColor(pointColor.cgColor)
                context.fillEllipse(in: CGRect(x: lastPoint.x - 4, y: lastPoint.y - 4, width: 8, height: 8))
            }
        }
    }
}