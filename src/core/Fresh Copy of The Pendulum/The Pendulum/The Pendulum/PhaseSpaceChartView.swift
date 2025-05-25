import UIKit

class PhaseSpaceChartView: UIView {
    private var levelData: [Int: [(theta: Double, omega: Double)]] = [:]
    private var selectedLevel: Int?
    private var levelSelector: UISegmentedControl!
    
    // Scaling factors (same as PhaseSpaceView)
    private let thetaScale: CGFloat = 100.0 // pixels per radian
    private let omegaScale: CGFloat = 50.0  // pixels per radian/sec
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = FocusCalendarTheme.lightBorderColor.cgColor
        
        // Subtle shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 4
        
        // Add level selector
        setupLevelSelector()
    }
    
    private func setupLevelSelector() {
        levelSelector = UISegmentedControl()
        levelSelector.translatesAutoresizingMaskIntoConstraints = false
        levelSelector.backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
        levelSelector.selectedSegmentTintColor = FocusCalendarTheme.accentGold
        levelSelector.setTitleTextAttributes([
            .foregroundColor: FocusCalendarTheme.primaryTextColor,
            .font: FocusCalendarTheme.bodyFont
        ], for: .normal)
        levelSelector.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: FocusCalendarTheme.buttonFont
        ], for: .selected)
        
        levelSelector.addTarget(self, action: #selector(levelSelectionChanged(_:)), for: .valueChanged)
        
        addSubview(levelSelector)
        
        NSLayoutConstraint.activate([
            levelSelector.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            levelSelector.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            levelSelector.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            levelSelector.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func levelSelectionChanged(_ sender: UISegmentedControl) {
        selectedLevel = sender.selectedSegmentIndex + 1 // Levels start at 1
        setNeedsDisplay()
    }
    
    func updateLevelData(_ data: [Int: [(theta: Double, omega: Double)]]) {
        levelData = data
        
        // Update segment control with available levels
        levelSelector.removeAllSegments()
        let sortedLevels = data.keys.sorted()
        
        for (index, level) in sortedLevels.enumerated() {
            levelSelector.insertSegment(withTitle: "Level \(level)", at: index, animated: false)
        }
        
        // Select the first level by default
        if let firstLevel = sortedLevels.first {
            levelSelector.selectedSegmentIndex = 0
            selectedLevel = firstLevel
        }
        
        setNeedsDisplay()
    }
    
    private func convert(theta: Double, omega: Double) -> CGPoint {
        // Convert physics coordinates to view coordinates
        // Center of phase space area (accounting for level selector)
        let centerX = bounds.width / 2
        let centerY = (bounds.height - 52) / 2 + 52 // Offset for level selector
        
        // Normalize angle to [-π, π] for inverted pendulum
        let normalizedTheta = atan2(sin(theta - Double.pi), cos(theta - Double.pi))
        
        let x = centerX + CGFloat(normalizedTheta) * thetaScale
        let y = centerY - CGFloat(omega) * omegaScale // Negative because UI coordinates go down
        
        return CGPoint(x: x, y: y)
    }
    
    private func getRainbowColor(for progress: CGFloat) -> UIColor {
        // Create rainbow gradient: Red -> Orange -> Yellow -> Green -> Blue -> Indigo -> Violet
        // Progress goes from 0.0 (start) to 1.0 (end)
        
        let hue = progress * 0.83 // 0.83 represents most of the hue spectrum (avoiding wrap-around to red)
        let saturation: CGFloat = 0.9
        let brightness: CGFloat = 0.9
        let alpha: CGFloat = 0.85
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw axes
        let centerX = bounds.width / 2
        let centerY = (bounds.height - 52) / 2 + 52
        
        context.setLineWidth(1.0)
        context.setStrokeColor(FocusCalendarTheme.tertiaryTextColor.cgColor)
        
        // X-axis (theta)
        context.move(to: CGPoint(x: 10, y: centerY))
        context.addLine(to: CGPoint(x: bounds.width - 10, y: centerY))
        
        // Y-axis (omega)
        context.move(to: CGPoint(x: centerX, y: 52))
        context.addLine(to: CGPoint(x: centerX, y: bounds.height - 10))
        
        context.strokePath()
        
        // Draw axis labels
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: FocusCalendarTheme.bodyFont,
            .foregroundColor: FocusCalendarTheme.secondaryTextColor
        ]
        
        // Theta label
        let thetaLabel = "θ"
        let thetaSize = thetaLabel.size(withAttributes: labelAttrs)
        thetaLabel.draw(at: CGPoint(x: bounds.width - thetaSize.width - 15, y: centerY + 5), withAttributes: labelAttrs)
        
        // Omega label
        let omegaLabel = "ω"
        let omegaSize = omegaLabel.size(withAttributes: labelAttrs)
        omegaLabel.draw(at: CGPoint(x: centerX + 5, y: 57), withAttributes: labelAttrs)
        
        // Draw grid lines
        context.setLineWidth(0.5)
        context.setStrokeColor(FocusCalendarTheme.lightBorderColor.cgColor)
        
        let gridSpacing: CGFloat = 50
        for i in stride(from: centerX, to: bounds.width, by: gridSpacing) {
            context.move(to: CGPoint(x: i, y: 52))
            context.addLine(to: CGPoint(x: i, y: bounds.height))
        }
        for i in stride(from: centerX, to: 0, by: -gridSpacing) {
            context.move(to: CGPoint(x: i, y: 52))
            context.addLine(to: CGPoint(x: i, y: bounds.height))
        }
        for i in stride(from: centerY, to: bounds.height, by: gridSpacing) {
            context.move(to: CGPoint(x: 0, y: i))
            context.addLine(to: CGPoint(x: bounds.width, y: i))
        }
        for i in stride(from: centerY, to: 52, by: -gridSpacing) {
            context.move(to: CGPoint(x: 0, y: i))
            context.addLine(to: CGPoint(x: bounds.width, y: i))
        }
        context.strokePath()
        
        // Draw origin point
        context.setFillColor(FocusCalendarTheme.accentGold.cgColor)
        context.fillEllipse(in: CGRect(x: centerX - 4, y: centerY - 4, width: 8, height: 8))
        
        // Draw phase space trajectory for selected level
        guard let selectedLevel = selectedLevel,
              let points = levelData[selectedLevel],
              points.count > 1 else { return }
        
        context.setLineWidth(2.0)
        
        // Draw level-specific phase space with rainbow gradient
        // Start path at first point
        let firstPoint = convert(theta: points[0].theta, omega: points[0].omega)
        
        // Draw lines between all points with rainbow gradient
        for i in 1..<points.count {
            let point = convert(theta: points[i].theta, omega: points[i].omega)
            let previousPoint = convert(theta: points[i-1].theta, omega: points[i-1].omega)
            
            // Calculate rainbow color based on progression through time
            let progress = CGFloat(i) / CGFloat(points.count)
            let rainbowColor = getRainbowColor(for: progress)
            
            context.setStrokeColor(rainbowColor.cgColor)
            context.setLineWidth(2.5)
            
            // Draw line segment from previous point to current point
            context.move(to: previousPoint)
            context.addLine(to: point)
            context.strokePath()
        }
        
        // Draw current point as a larger dot with final rainbow color
        if let lastPoint = points.last {
            let finalPoint = convert(theta: lastPoint.theta, omega: lastPoint.omega)
            let finalColor = getRainbowColor(for: 1.0) // End of rainbow
            context.setFillColor(finalColor.cgColor)
            context.fillEllipse(in: CGRect(x: finalPoint.x - 5, y: finalPoint.y - 5, width: 10, height: 10))
        }
        
        // Draw level label
        let levelText = "Level \(selectedLevel) Average Phase Space"
        let levelAttrs: [NSAttributedString.Key: Any] = [
            .font: FocusCalendarTheme.titleFont,
            .foregroundColor: FocusCalendarTheme.primaryTextColor
        ]
        
        let levelSize = levelText.size(withAttributes: levelAttrs)
        levelText.draw(at: CGPoint(x: (bounds.width - levelSize.width) / 2, y: bounds.height - 30), withAttributes: levelAttrs)
    }
}