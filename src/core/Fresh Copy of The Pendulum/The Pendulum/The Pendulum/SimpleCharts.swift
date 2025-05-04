// SimpleCharts.swift
// A lightweight chart implementation without external dependencies

import UIKit

// MARK: - Base Chart View

class SimpleChartView: UIView {
    // Chart data
    var dataPoints: [Double] = []
    var labels: [String] = []
    var title: String = ""
    var color: UIColor = .systemBlue
    
    // Styling
    private let margin: CGFloat = 30
    private let bottomMargin: CGFloat = 40
    private let topMargin: CGFloat = 40
    private let labelHeight: CGFloat = 20
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
    }
    
    // Method to update data
    func updateData(data: [Double], labels: [String], title: String, color: UIColor = .systemBlue) {
        self.dataPoints = data
        self.labels = labels
        self.title = title
        self.color = color
        setNeedsDisplay()
    }
    
    // Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext(), !dataPoints.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Draw title
        drawTitle(in: rect)
        
        // Draw chart area based on type
        drawChartContent(context: context, in: rect)
    }
    
    func drawChartContent(context: CGContext, in rect: CGRect) {
        // Override in subclasses
    }
    
    func drawTitle(in rect: CGRect) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (rect.width - titleSize.width) / 2,
            y: 10,
            width: titleSize.width,
            height: titleSize.height
        )
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    func drawNoDataMessage(in rect: CGRect) {
        // Get the message from the title if it contains "No Data", otherwise use generic message
        let defaultMessage = "No data available"
        let message = title.contains("No Data") ? title : defaultMessage
        
        // Draw background
        let bgPath = UIBezierPath(roundedRect: rect.insetBy(dx: margin, dy: topMargin), cornerRadius: 8)
        UIColor.systemGray6.setFill()
        bgPath.fill()
        
        // Draw message text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ]
        
        let messageSize = message.size(withAttributes: attributes)
        let messageRect = CGRect(
            x: (rect.width - messageSize.width) / 2,
            y: (rect.height - messageSize.height) / 2,
            width: messageSize.width,
            height: messageSize.height
        )
        
        message.draw(in: messageRect, withAttributes: attributes)
    }
    
    // Helper function to get chart area
    func getChartArea(in rect: CGRect) -> CGRect {
        return CGRect(
            x: margin,
            y: topMargin,
            width: rect.width - (margin * 2),
            height: rect.height - topMargin - bottomMargin
        )
    }
    
    // Helper function to draw axes
    func drawAxes(in context: CGContext, chartArea: CGRect) {
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)
        
        // Draw X-axis
        context.move(to: CGPoint(x: chartArea.minX, y: chartArea.maxY))
        context.addLine(to: CGPoint(x: chartArea.maxX, y: chartArea.maxY))
        
        // Draw Y-axis
        context.move(to: CGPoint(x: chartArea.minX, y: chartArea.minY))
        context.addLine(to: CGPoint(x: chartArea.minX, y: chartArea.maxY))
        
        context.strokePath()
    }
    
    // Helper to draw axis labels
    func drawXAxisLabels(in chartArea: CGRect) {
        guard !labels.isEmpty else { return }
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        
        let stepWidth = chartArea.width / CGFloat(labels.count > 1 ? labels.count - 1 : 1)
        
        // Only draw a subset of labels if there are too many
        let maxLabels = 5
        let skipFactor = max(1, labels.count / maxLabels)
        
        for (index, label) in labels.enumerated() where index % skipFactor == 0 {
            let x = chartArea.minX + (CGFloat(index) * stepWidth)
            let labelSize = label.size(withAttributes: labelAttributes)
            
            let labelRect = CGRect(
                x: x - (labelSize.width / 2),
                y: chartArea.maxY + 5,
                width: labelSize.width,
                height: labelSize.height
            )
            
            label.draw(in: labelRect, withAttributes: labelAttributes)
        }
    }
}

// MARK: - Line Chart

class SimpleLineChartView: SimpleChartView {
    
    override func drawChartContent(context: CGContext, in rect: CGRect) {
        let chartArea = getChartArea(in: rect)
        
        // Find min/max values for scaling
        let minValue = dataPoints.min() ?? 0
        let maxValue = max(dataPoints.max() ?? 1, minValue + 1) // Ensure range is at least 1
        
        // Draw axes
        drawAxes(in: context, chartArea: chartArea)
        
        // Draw X-axis labels
        drawXAxisLabels(in: chartArea)
        
        // Calculate step sizes
        let stepX = chartArea.width / CGFloat(dataPoints.count > 1 ? dataPoints.count - 1 : 1)
        let valueRange = maxValue - minValue
        
        // Set line properties
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        context.setLineJoin(.round)
        
        // Create the line path
        if dataPoints.count > 0 {
            let normalizedY = CGFloat(1 - ((dataPoints[0] - minValue) / valueRange))
            let startX = chartArea.minX
            let startY = chartArea.minY + (normalizedY * chartArea.height)
            
            context.move(to: CGPoint(x: startX, y: startY))
            
            for i in 1..<dataPoints.count {
                let normalizedY = CGFloat(1 - ((dataPoints[i] - minValue) / valueRange))
                let pointX = chartArea.minX + (CGFloat(i) * stepX)
                let pointY = chartArea.minY + (normalizedY * chartArea.height)
                
                context.addLine(to: CGPoint(x: pointX, y: pointY))
            }
            
            context.strokePath()
            
            // Draw data points
            for i in 0..<dataPoints.count {
                let normalizedY = CGFloat(1 - ((dataPoints[i] - minValue) / valueRange))
                let pointX = chartArea.minX + (CGFloat(i) * stepX)
                let pointY = chartArea.minY + (normalizedY * chartArea.height)
                
                context.setFillColor(color.cgColor)
                context.fillEllipse(in: CGRect(
                    x: pointX - 3,
                    y: pointY - 3,
                    width: 6,
                    height: 6
                ))
            }
        }
    }
}

// MARK: - Bar Chart

class SimpleBarChartView: SimpleChartView {
    
    override func drawChartContent(context: CGContext, in rect: CGRect) {
        let chartArea = getChartArea(in: rect)
        
        // Find max value for scaling
        let maxValue = dataPoints.max() ?? 1
        
        // Draw axes
        drawAxes(in: context, chartArea: chartArea)
        
        // Draw X-axis labels
        drawXAxisLabels(in: chartArea)
        
        // Calculate bar width
        let barWidth = (chartArea.width / CGFloat(dataPoints.count)) * 0.8
        let barSpacing = (chartArea.width / CGFloat(dataPoints.count)) * 0.2
        
        // Draw bars
        context.setFillColor(color.cgColor)
        
        for (index, value) in dataPoints.enumerated() {
            let normalizedHeight = CGFloat(value / maxValue) * chartArea.height
            let barX = chartArea.minX + (CGFloat(index) * (barWidth + barSpacing)) + (barSpacing / 2)
            let barY = chartArea.maxY - normalizedHeight
            
            context.fill(CGRect(
                x: barX,
                y: barY,
                width: barWidth,
                height: normalizedHeight
            ))
        }
    }
}

// MARK: - Pie Chart

class SimplePieChartView: SimpleChartView {
    var segments: [(value: Double, label: String, color: UIColor)] = []
    
    func updateSegments(_ segments: [(value: Double, label: String, color: UIColor)]) {
        self.segments = segments
        setNeedsDisplay()
    }
    
    override func drawChartContent(context: CGContext, in rect: CGRect) {
        guard !segments.isEmpty else { return }
        
        let chartArea = getChartArea(in: rect)
        let center = CGPoint(x: chartArea.midX, y: chartArea.midY)
        let radius = min(chartArea.width, chartArea.height) / 2
        
        // Calculate total value
        let total = segments.reduce(0) { $0 + $1.value }
        
        // Track start angle
        var startAngle: CGFloat = -.pi / 2 // Start at top
        
        // Draw segments
        for segment in segments {
            // Calculate angle for this segment
            let angle = CGFloat(segment.value / total) * .pi * 2
            
            // Set fill color
            context.setFillColor(segment.color.cgColor)
            
            // Draw pie segment
            context.move(to: center)
            context.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: startAngle + angle,
                clockwise: false
            )
            context.closePath()
            context.fillPath()
            
            // Calculate position for label
            let labelAngle = startAngle + (angle / 2)
            let labelDistance = radius * 0.7
            let labelX = center.x + cos(labelAngle) * labelDistance
            let labelY = center.y + sin(labelAngle) * labelDistance
            
            // Draw percentage label if slice is big enough
            if angle > 0.2 {
                let percentage = Int((segment.value / total) * 100)
                let label = "\(percentage)%"
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.white
                ]
                
                let labelSize = label.size(withAttributes: attributes)
                let labelRect = CGRect(
                    x: labelX - (labelSize.width / 2),
                    y: labelY - (labelSize.height / 2),
                    width: labelSize.width,
                    height: labelSize.height
                )
                
                label.draw(in: labelRect, withAttributes: attributes)
            }
            
            // Update start angle for next segment
            startAngle += angle
        }
        
        // Draw center circle (hole)
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(
            x: center.x - (radius * 0.5),
            y: center.y - (radius * 0.5),
            width: radius,
            height: radius
        ))
    }
    
    override func drawXAxisLabels(in chartArea: CGRect) {
        // Pie charts don't have x-axis labels in the same way
        // Instead, we'll add a legend below the chart
        
        let legendItemHeight: CGFloat = 20
        let legendItemWidth: CGFloat = 100
        let legendMargin: CGFloat = 10
        let colorSquareSize: CGFloat = 10
        
        var currentY = chartArea.maxY + legendMargin
        var currentX = chartArea.minX
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        
        for (index, segment) in segments.enumerated() {
            // Draw color square
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(segment.color.cgColor)
                context.fill(CGRect(
                    x: currentX,
                    y: currentY + (legendItemHeight - colorSquareSize) / 2,
                    width: colorSquareSize,
                    height: colorSquareSize
                ))
            }
            
            // Draw label
            segment.label.draw(
                in: CGRect(
                    x: currentX + colorSquareSize + 5,
                    y: currentY,
                    width: legendItemWidth - colorSquareSize - 5,
                    height: legendItemHeight
                ),
                withAttributes: attributes
            )
            
            // Update position for next item
            if (index + 1) % 2 == 0 {
                currentY += legendItemHeight + 5
                currentX = chartArea.minX
            } else {
                currentX = chartArea.midX
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext(), !segments.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Draw title
        drawTitle(in: rect)
        
        // Draw chart area based on type
        drawChartContent(context: context, in: rect)
    }
}