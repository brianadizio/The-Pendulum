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
    private let margin: CGFloat = 50 // Increased from 30 to accommodate y-axis labels
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
        // Ensure this view doesn't conflict with Auto Layout
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = FocusCalendarTheme.secondaryBackgroundColor
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
    
    // Helper to extract unit from title
    func getUnitFromTitle() -> String {
        let lowerTitle = title.lowercased()
        if lowerTitle.contains("angle") || lowerTitle.contains("variance") {
            return "°"
        } else if lowerTitle.contains("frequency") {
            return "/s"
        } else if lowerTitle.contains("time") && !lowerTitle.contains("completion") {
            return "s"
        } else if lowerTitle.contains("magnitude") {
            return "N"
        } else if lowerTitle.contains("reaction") {
            return "s"
        } else if lowerTitle.contains("score") || lowerTitle.contains("stability") || lowerTitle.contains("efficiency") {
            return "%"
        } else if lowerTitle.contains("level") && lowerTitle.contains("completion") {
            return " levels"
        } else if lowerTitle.contains("parameter") {
            // Parameters have their own units
            return ""
        } else if lowerTitle.contains("curve") || lowerTitle.contains("learning") {
            return "%"
        }
        return ""
    }
    
    // Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Removed debug print - chart drawing with unique identifier
        let chartId = "\(type(of: self))_\(title)"
        
        // Debug: Check for NaN in data points
        var hasNaN = false
        for (index, point) in dataPoints.enumerated() {
            if point.isNaN || point.isInfinite {
                print("ERROR: NaN/Infinite detected in '\(chartId)' at index \(index): \(point)")
                print("DEBUG: Chart is visible: \(self.window != nil), Alpha: \(self.alpha), Hidden: \(self.isHidden)")
                hasNaN = true
            }
        }
        
        // Check if rect is valid
        if rect.width.isNaN || rect.height.isNaN || rect.width.isInfinite || rect.height.isInfinite {
            print("ERROR: Invalid rect for '\(chartId)': \(rect)")
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("ERROR: No graphics context for '\(chartId)'")
            return
        }
        
        // If we have no data points, show the no data message
        if dataPoints.isEmpty {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Draw title
        drawTitle(in: rect)
        
        // Draw chart area based on type (only if no NaN)
        if !hasNaN {
            drawChartContent(context: context, in: rect)
        } else {
            print("WARNING: Skipping chart content drawing for '\(chartId)' due to NaN data")
            drawNoDataMessage(in: rect)
        }
    }
    
    func drawChartContent(context: CGContext, in rect: CGRect) {
        // Override in subclasses
    }
    
    func drawTitle(in rect: CGRect) {
        // Skip if title is empty
        guard !title.isEmpty else { return }
        
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
        
        // Validate title rect
        guard titleRect.width > 0 && titleRect.height > 0 && 
              !titleRect.width.isNaN && !titleRect.height.isNaN else { return }
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    func drawNoDataMessage(in rect: CGRect) {
        // Validate rect
        guard rect.width > 0 && rect.height > 0 && !rect.width.isNaN && !rect.height.isNaN else {
            print("WARNING: Invalid rect in drawNoDataMessage")
            return
        }
        
        // Get the message from the title if it contains "No Data", otherwise use generic message
        let defaultMessage = "No data available"
        let message = title.contains("No Data") ? title : defaultMessage
        
        // Draw background
        let insetRect = rect.insetBy(dx: margin, dy: topMargin)
        guard insetRect.width > 0 && insetRect.height > 0 else { return }
        
        let bgPath = UIBezierPath(roundedRect: insetRect, cornerRadius: 8)
        FocusCalendarTheme.secondaryBackgroundColor.setFill()
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
        let chartArea = CGRect(
            x: margin,
            y: topMargin,
            width: rect.width - (margin * 2),
            height: rect.height - topMargin - bottomMargin
        )
        
        // Debug logging
        if chartArea.width <= 0 || chartArea.height <= 0 || chartArea.width.isNaN || chartArea.height.isNaN {
            print("WARNING: Invalid chart area for \(title): width=\(chartArea.width), height=\(chartArea.height)")
            print("  Original rect: \(rect)")
            print("  Margins: top=\(topMargin), bottom=\(bottomMargin), margin=\(margin)")
        }
        
        // Ensure valid dimensions
        guard chartArea.width > 0 && chartArea.height > 0 && !chartArea.width.isNaN && !chartArea.height.isNaN else {
            return CGRect.zero
        }
        
        return chartArea
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
        
        // Validate chart area
        guard chartArea.width > 0 && chartArea.height > 0 && !chartArea.width.isNaN && !chartArea.height.isNaN else {
            print("WARNING: Invalid chart area in drawXAxisLabels")
            return
        }
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9), // Smaller font for better fit
            .foregroundColor: UIColor.darkGray
        ]
        
        // Calculate spacing based on chart type
        let stepWidth = labels.count > 1 ? chartArea.width / CGFloat(labels.count - 1) : chartArea.width
        
        // Adaptive label showing based on available space
        let avgLabelWidth: CGFloat = 60 // Estimated average label width
        let maxLabelsForSpace = Int(chartArea.width / avgLabelWidth)
        let maxLabels = min(maxLabelsForSpace, 6) // Never show more than 6 labels
        let skipFactor = max(1, labels.count / maxLabels)
        
        for (index, label) in labels.enumerated() where index % skipFactor == 0 {
            let x = chartArea.minX + (CGFloat(index) * stepWidth)
            let labelSize = label.size(withAttributes: labelAttributes)
            
            // Ensure label doesn't go outside chart bounds
            let labelX = max(chartArea.minX, min(x - (labelSize.width / 2), chartArea.maxX - labelSize.width))
            
            let labelRect = CGRect(
                x: labelX,
                y: chartArea.maxY + 8, // More spacing from axis
                width: labelSize.width,
                height: labelSize.height
            )
            
            label.draw(in: labelRect, withAttributes: labelAttributes)
        }
    }
    
    // Helper to draw X-axis title
    func drawXAxisTitle(_ axisTitle: String, in chartArea: CGRect, rect: CGRect) {
        guard !axisTitle.isEmpty else { return }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        let titleSize = axisTitle.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (rect.width - titleSize.width) / 2,
            y: rect.height - 20, // Position at bottom
            width: titleSize.width,
            height: titleSize.height
        )
        
        axisTitle.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    // Helper to draw Y-axis labels with tick marks
    func drawYAxisLabels(in context: CGContext, chartArea: CGRect, minValue: Double, maxValue: Double, unit: String = "") {
        // Validate inputs
        guard chartArea.height > 0 && !minValue.isNaN && !minValue.isInfinite && 
              !maxValue.isNaN && !maxValue.isInfinite else { return }
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9), // Slightly smaller font to prevent overlap
            .foregroundColor: UIColor.darkGray
        ]
        
        // Determine optimal number of tick marks based on chart height and value range
        let tickCount = chartArea.height > 120 ? 5 : 3 // Fewer ticks on smaller charts
        
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)
        
        for i in 0...tickCount {
            let progress = CGFloat(i) / CGFloat(tickCount)
            let y = chartArea.maxY - (progress * chartArea.height)
            let value = minValue + ((maxValue - minValue) * Double(progress))
            
            // Skip if y or value is invalid
            guard !y.isNaN && !y.isInfinite && !value.isNaN && !value.isInfinite else { continue }
            
            // Draw tick mark
            context.move(to: CGPoint(x: chartArea.minX - 5, y: y))
            context.addLine(to: CGPoint(x: chartArea.minX, y: y))
            
            // Draw value label with appropriate formatting
            let labelText: String
            let valueRange = maxValue - minValue
            
            // Smart formatting based on value range
            if valueRange < 0.1 {
                labelText = String(format: "%.3f%@", value, unit)
            } else if valueRange < 1 {
                labelText = String(format: "%.2f%@", value, unit)
            } else if valueRange < 10 {
                labelText = String(format: "%.1f%@", value, unit)
            } else if valueRange > 1000 {
                labelText = String(format: "%.0f%@", value / 1000, "k" + unit)
            } else {
                labelText = String(format: "%.0f%@", value, unit)
            }
            
            let labelSize = labelText.size(withAttributes: labelAttributes)
            
            let labelRect = CGRect(
                x: chartArea.minX - labelSize.width - 10, // More spacing from axis
                y: y - (labelSize.height / 2),
                width: labelSize.width,
                height: labelSize.height
            )
            
            labelText.draw(in: labelRect, withAttributes: labelAttributes)
        }
        
        context.strokePath()
    }
}

// MARK: - Line Chart

class SimpleLineChartView: SimpleChartView {
    // Custom unit override for special charts like Pendulum Parameters
    var customUnit: String = ""
    
    func updateDataWithUnit(data: [Double], labels: [String], title: String, color: UIColor = .systemBlue, unit: String = "") {
        self.customUnit = unit
        updateData(data: data, labels: labels, title: title, color: color)
    }
    
    override func getUnitFromTitle() -> String {
        // Use custom unit if set, otherwise fall back to title-based detection
        if !customUnit.isEmpty {
            return customUnit
        }
        return super.getUnitFromTitle()
    }
    
    override func drawChartContent(context: CGContext, in rect: CGRect) {
        let chartArea = getChartArea(in: rect)
        
        // Check for valid chart area
        guard chartArea.width > 0 && chartArea.height > 0 else { return }
        
        // Check for empty data
        guard !dataPoints.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Filter out any NaN or infinite values
        let validDataPoints = dataPoints.filter { !$0.isNaN && !$0.isInfinite }
        guard !validDataPoints.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Find min/max values for scaling
        let minValue = validDataPoints.min() ?? 0
        let maxValue = max(validDataPoints.max() ?? 1, minValue + 1) // Ensure range is at least 1
        
        // Draw axes
        drawAxes(in: context, chartArea: chartArea)
        
        // Draw X-axis labels
        drawXAxisLabels(in: chartArea)
        
        // Draw Y-axis labels with tick marks
        drawYAxisLabels(in: context, chartArea: chartArea, minValue: minValue, maxValue: maxValue, unit: getUnitFromTitle())
        
        // Calculate step sizes
        let stepX = chartArea.width / CGFloat(dataPoints.count > 1 ? dataPoints.count - 1 : 1)
        let valueRange = max(maxValue - minValue, 0.001) // Prevent division by zero
        
        // Set line properties
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        context.setLineJoin(.round)
        
        // Create the line path
        if dataPoints.count > 0 {
            var validStartIndex = -1
            
            // Find first valid data point
            for i in 0..<dataPoints.count {
                if !dataPoints[i].isNaN && !dataPoints[i].isInfinite {
                    validStartIndex = i
                    break
                }
            }
            
            guard validStartIndex >= 0 else { return }
            
            let normalizedY = CGFloat(1 - ((dataPoints[validStartIndex] - minValue) / valueRange))
            let startX = chartArea.minX + (CGFloat(validStartIndex) * stepX)
            let startY = chartArea.minY + (normalizedY * chartArea.height)
            
            context.move(to: CGPoint(x: startX, y: startY))
            
            for i in (validStartIndex + 1)..<dataPoints.count {
                if !dataPoints[i].isNaN && !dataPoints[i].isInfinite {
                    let normalizedY = CGFloat(1 - ((dataPoints[i] - minValue) / valueRange))
                    let pointX = chartArea.minX + (CGFloat(i) * stepX)
                    let pointY = chartArea.minY + (normalizedY * chartArea.height)
                    
                    context.addLine(to: CGPoint(x: pointX, y: pointY))
                }
            }
            
            context.strokePath()
            
            // Draw data points
            for i in 0..<dataPoints.count {
                if !dataPoints[i].isNaN && !dataPoints[i].isInfinite {
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
}

// MARK: - Bar Chart

class SimpleBarChartView: SimpleChartView {
    
    override func drawChartContent(context: CGContext, in rect: CGRect) {
        // Check for empty data FIRST before doing any calculations
        guard !dataPoints.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        let chartArea = getChartArea(in: rect)
        
        // Check for valid chart area
        guard chartArea.width > 0 && chartArea.height > 0 else {
            print("WARNING: Invalid chart area for bar chart '\(title)'")
            return
        }
        
        // Filter out any NaN or infinite values
        let validDataPoints = dataPoints.filter { !$0.isNaN && !$0.isInfinite }
        guard !validDataPoints.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Find max value for scaling
        let minValue: Double = 0 // Bar charts typically start from 0
        let maxValue = max(validDataPoints.max() ?? 1, 1) // Ensure at least 1 to prevent division by zero
        
        // Draw axes
        drawAxes(in: context, chartArea: chartArea)
        
        // Draw X-axis labels
        drawXAxisLabels(in: chartArea)
        
        // Draw X-axis title for specific charts
        if title.lowercased().contains("magnitude") || title.lowercased().contains("force") {
            drawXAxisTitle("Force Magnitude", in: chartArea, rect: rect)
        }
        
        // Draw Y-axis labels with tick marks
        drawYAxisLabels(in: context, chartArea: chartArea, minValue: minValue, maxValue: maxValue, unit: getUnitFromTitle())
        
        // Calculate bar width - protect against division by zero
        guard dataPoints.count > 0 else { return }
        let barWidth = (chartArea.width / CGFloat(dataPoints.count)) * 0.8
        let barSpacing = (chartArea.width / CGFloat(dataPoints.count)) * 0.2
        
        // Draw bars
        context.setFillColor(color.cgColor)
        
        for (index, value) in dataPoints.enumerated() {
            if !value.isNaN && !value.isInfinite {
                let normalizedHeight = CGFloat((value - minValue) / (maxValue - minValue)) * chartArea.height
                let barX = chartArea.minX + (CGFloat(index) * (barWidth + barSpacing)) + (barSpacing / 2)
                let barY = chartArea.maxY - normalizedHeight
                
                if normalizedHeight > 0 {
                    context.fill(CGRect(
                        x: barX,
                        y: barY,
                        width: barWidth,
                        height: normalizedHeight
                    ))
                }
            }
        }
    }
}

// MARK: - Pie Chart

class SimplePieChartView: SimpleChartView {
    var segments: [(value: Double, label: String, color: UIColor)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.title = "Pie Chart" // Default title to prevent empty string
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.title = "Pie Chart" // Default title to prevent empty string
    }
    
    func updateSegments(_ segments: [(value: Double, label: String, color: UIColor)]) {
        self.segments = segments
        setNeedsDisplay()
    }
    
    override func drawChartContent(context: CGContext, in rect: CGRect) {
        // Removed debug print - pie chart segment count
        guard !segments.isEmpty else { return }
        
        let chartArea = getChartArea(in: rect)
        guard chartArea != CGRect.zero else {
            print("WARNING: Pie chart area is zero")
            return
        }
        
        let center = CGPoint(x: chartArea.midX, y: chartArea.midY)
        let radius = min(chartArea.width, chartArea.height) / 2
        
        // Check for NaN in center or radius
        if center.x.isNaN || center.y.isNaN || radius.isNaN || radius.isInfinite {
            print("ERROR: NaN/Infinite in pie chart geometry - center: \(center), radius: \(radius)")
            return
        }
        
        // Calculate total value
        let total = segments.reduce(0) { $0 + $1.value }
        
        // If total is 0, show no data message
        guard total > 0 else {
            drawNoDataMessage(in: rect)
            return
        }
        
        // Track start angle
        var startAngle: CGFloat = -.pi / 2 // Start at top
        
        // Draw segments
        for segment in segments {
            // Skip segments with 0 or invalid value
            guard segment.value > 0 && !segment.value.isNaN && !segment.value.isInfinite else { continue }
            
            // Calculate angle for this segment
            let angle = CGFloat(segment.value / total) * .pi * 2
            
            // Skip segments with 0 or invalid angle
            guard angle > 0 && !angle.isNaN && !angle.isInfinite else { continue }
            
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
        let holeRadius = radius * 0.5
        let holeRect = CGRect(
            x: center.x - holeRadius,
            y: center.y - holeRadius,
            width: holeRadius * 2,
            height: holeRadius * 2
        )
        
        // Check for NaN before drawing
        if holeRect.origin.x.isNaN || holeRect.origin.y.isNaN || holeRect.width.isNaN || holeRect.height.isNaN {
            print("ERROR: NaN in pie chart hole rect: \(holeRect)")
        } else {
            context.setFillColor(FocusCalendarTheme.secondaryBackgroundColor.cgColor)
            context.fillEllipse(in: holeRect)
        }
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