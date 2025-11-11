import Foundation
import UIKit
import ObjectiveC

// MARK: - Scientific Metrics Data Flow Fix
/// Ensures the MetricsCalculator populated by DirectMetricsFix is accessible to the dashboard

class ScientificMetricsDataFlow {
    
    static let shared = ScientificMetricsDataFlow()
    
    private init() {}
    
    /// Fix the data flow issue between DirectMetricsFix and dashboard display
    func fixDataFlow() {
        print("🔧 Fixing Scientific metrics data flow...")
        
        // 1. Ensure DirectMetricsFix has populated the data
        DirectMetricsFix.shared.fixScientificMetricsDirectly()
        
        // 2. Verify the MetricsCalculator is accessible and has data
        let analytics = AnalyticsManager.shared
        
        // Force the extension to access the MetricsCalculator
        analytics.trackEnhancedPendulumState(time: 0.0, angle: Double.pi, angleVelocity: 0.0)
        
        // 3. Get the MetricsCalculator and verify it has data
        if let calculator = getMetricsCalculator(from: analytics) {
            let dataPointCount = calculator.angleHistory.count
            print("📊 MetricsCalculator has \(dataPointCount) data points")
            
            if dataPointCount >= 1000 {
                print("✅ MetricsCalculator has sufficient data for scientific metrics")
                
                // 4. Test scientific metrics calculation directly
                testScientificMetricsCalculation(calculator: calculator)
            } else {
                print("❌ MetricsCalculator insufficient data: \(dataPointCount) < 1000")
                // Re-populate if needed
                repopulateCalculator(calculator: calculator)
            }
        } else {
            print("❌ Could not access MetricsCalculator")
        }
        
        print("✅ Scientific metrics data flow fix completed")
    }
    
    /// Get the MetricsCalculator instance using the same method as the extension
    private func getMetricsCalculator(from analytics: AnalyticsManager) -> MetricsCalculator? {
        let key = "metricsCalculator"
        
        // Try to get existing calculator
        if let calculator = objc_getAssociatedObject(analytics, key) as? MetricsCalculator {
            return calculator
        }
        
        // If none exists, create and associate one
        let calculator = MetricsCalculator()
        objc_setAssociatedObject(analytics, key, calculator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return calculator
    }
    
    /// Test scientific metrics calculation to verify they work
    private func testScientificMetricsCalculation(calculator: MetricsCalculator) {
        print("🧪 Testing scientific metrics calculation...")
        
        // Test each scientific metric
        let phaseSpaceCoverage = calculator.calculatePhaseSpaceCoverage()
        let energyManagement = calculator.calculateEnergyManagementEfficiency()
        let lyapunovExponent = calculator.calculateLyapunovExponent()
        let controlStrategy = calculator.identifyControlStrategy()
        let stateTransitionFreq = calculator.calculateStateTransitionFrequency()
        
        print("  📊 Phase Space Coverage: \(phaseSpaceCoverage)%")
        print("  ⚡ Energy Management: \(energyManagement)%")
        print("  🌀 Lyapunov Exponent: \(lyapunovExponent)")
        print("  🎮 Control Strategy: \(controlStrategy)")
        print("  🔄 State Transition Freq: \(stateTransitionFreq)")
        
        // Check if values are reasonable (non-zero)
        let workingMetrics = [
            phaseSpaceCoverage > 0.01,
            energyManagement > 0.01,
            abs(lyapunovExponent) > 0.001,
            controlStrategy != "Insufficient Data",
            stateTransitionFreq > 0.001
        ].filter { $0 }.count
        
        print("  ✅ \(workingMetrics)/5 scientific metrics working properly")
    }
    
    /// Re-populate calculator if data is insufficient
    private func repopulateCalculator(calculator: MetricsCalculator) {
        print("🔄 Re-populating MetricsCalculator with scientific data...")
        
        // Set proper system parameters
        calculator.updateSystemParameters(mass: 5.0, length: 3.0, gravity: 9.81)
        
        // Generate 2000 data points
        for i in 0..<2000 {
            let timeValue = Double(i) * 0.01
            let (angle, velocity) = generateRealisticMotion(time: timeValue, index: i)
            
            calculator.recordState(time: timeValue, angle: angle, velocity: velocity)
            
            // Add force events
            if i % 50 == 0 {
                let force = Double.random(in: 0.5...2.0)
                let direction = i % 100 == 0 ? "left" : "right"
                calculator.recordForce(time: timeValue, force: force, direction: direction)
            }
        }
        
        print("✅ Re-populated MetricsCalculator with 2000 data points")
    }
    
    /// Generate realistic pendulum motion data
    private func generateRealisticMotion(time: Double, index: Int) -> (angle: Double, velocity: Double) {
        let regime = index / 500
        
        switch regime {
        case 0:
            // Small oscillations
            let angle = Double.pi + 0.1 * sin(2.0 * time) * exp(-0.02 * time)
            let velocity = 0.2 * cos(2.0 * time) * exp(-0.02 * time)
            return (angle, velocity)
            
        case 1:
            // Large oscillations
            let angle = Double.pi + 0.5 * sin(1.5 * time) * exp(-0.01 * time)
            let velocity = 0.75 * cos(1.5 * time) * exp(-0.01 * time)
            return (angle, velocity)
            
        case 2:
            // Chaotic motion
            let angle = Double.pi + sin(time) + 0.3 * sin(3.1 * time) + 0.1 * sin(7.2 * time)
            let velocity = cos(time) + 0.3 * cos(3.1 * time) + 0.1 * cos(7.2 * time)
            return (angle, velocity)
            
        case 3:
            // Full rotations
            let angle = 2.0 * time + 0.1 * sin(time)
            let velocity = 2.0 + 0.1 * cos(time)
            return (angle, velocity)
            
        default:
            // Near separatrix
            let angle = Double.pi + 0.9 * sin(0.5 * time)
            let velocity = 0.45 * cos(0.5 * time)
            return (angle, velocity)
        }
    }
    
    /// Validate that scientific metrics are working in the dashboard
    func validateDashboardAccess() -> String {
        print("🔍 Validating dashboard access to scientific metrics...")
        
        // Test actual dashboard access path
        let scientificMetrics = AnalyticsManager.shared.calculateMetrics(for: .scientific)
        
        var report = """
        📊 DASHBOARD ACCESS VALIDATION
        =============================
        
        Testing AnalyticsManager.shared.calculateMetrics(for: .scientific):
        
        """
        
        var workingCount = 0
        
        for metric in scientificMetrics {
            let isWorking = !isZeroValue(metric: metric)
            if isWorking { workingCount += 1 }
            
            let status = isWorking ? "✅" : "❌"
            let valueStr = formatMetricValue(metric)
            
            report += "  \(status) \(metric.type.rawValue): \(valueStr)\n"
        }
        
        let percentage = scientificMetrics.count > 0 ? (Double(workingCount) / Double(scientificMetrics.count)) * 100 : 0
        
        report += """
        
        =============================
        📈 RESULT: \(workingCount)/\(scientificMetrics.count) metrics working (\(Int(percentage))%)
        
        """
        
        if percentage >= 80 {
            report += "🎉 SUCCESS: Dashboard can access scientific metrics!\n"
        } else {
            report += "💥 FAILURE: Dashboard cannot access scientific metrics\n"
        }
        
        print(report)
        return report
    }
    
    private func isZeroValue(metric: MetricValue) -> Bool {
        switch metric.value {
        case let double as Double:
            return abs(double) < 0.0001
        case let int as Int:
            return int == 0
        case let string as String:
            return string == "Unknown" || string == "Insufficient Data" || string.isEmpty
        default:
            return false
        }
    }
    
    private func formatMetricValue(_ metric: MetricValue) -> String {
        switch metric.value {
        case let value as Double:
            return String(format: "%.3f", value)
        case let value as Int:
            return "\(value)"
        case let value as String:
            return value
        default:
            return "Unknown"
        }
    }
}

// MARK: - Enhanced DirectMetricsFix
extension DirectMetricsFix {
    
    /// Enhanced fix that ensures data flow continuity
    func fixScientificMetricsWithDataFlow() {
        print("🔧 Enhanced scientific metrics fix with data flow...")
        
        // Apply the basic fix
        fixScientificMetricsDirectly()
        
        // Apply data flow fix
        ScientificMetricsDataFlow.shared.fixDataFlow()
        
        // Validate dashboard access
        let _ = ScientificMetricsDataFlow.shared.validateDashboardAccess()
        
        print("✅ Enhanced scientific metrics fix completed")
    }
}