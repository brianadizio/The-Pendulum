import Foundation
import UIKit
import ObjectiveC

// MARK: - Scientific Metrics Diagnostic
/// Diagnoses exactly why SimpleDashboard scientific metrics show 0.00

class ScientificMetricsDiagnostic {
    
    static let shared = ScientificMetricsDiagnostic()
    
    private init() {}
    
    /// Run comprehensive diagnostic of scientific metrics for SimpleDashboard
    func diagnoseScientificMetrics() -> String {
        var report = """
        🔍 SCIENTIFIC METRICS DIAGNOSTIC REPORT
        =======================================
        
        """
        
        let analytics = AnalyticsManager.shared
        
        // 1. Check if metrics calculator exists and has data
        report += "1. MetricsCalculator Status:\n"
        
        // Trigger the MetricsCalculator creation
        analytics.trackEnhancedPendulumState(time: 0.0, angle: Double.pi, angleVelocity: 0.0)
        
        // Try to access through reflection
        let keyString = "metricsCalculator"
        let key = UnsafeRawPointer(Unmanaged.passUnretained(keyString as NSString).toOpaque())
        
        if let calculator = objc_getAssociatedObject(analytics, key) as? MetricsCalculator {
            report += "   ✅ MetricsCalculator found via string key\n"
            report += "   📊 Data check: Angle history count = \\(getAngleHistoryCount(calculator))\n"
        } else {
            report += "   ❌ MetricsCalculator NOT found via string key\n"
        }
        
        // 2. Test actual scientific metrics calculation
        report += "\n2. Scientific Metrics Calculation Test:\n"
        
        let scientificMetrics = analytics.calculateMetrics(for: .scientific)
        
        for metric in scientificMetrics {
            let valueStr = formatMetricValue(metric)
            let isZero = isZeroValue(metric: metric)
            let status = isZero ? "❌ ZERO" : "✅ HAS VALUE"
            report += "   \(status) \(metric.type.rawValue): \(valueStr)\n"
        }
        
        // 3. Try applying DirectMetricsFix and retest
        report += "\n3. Applying DirectMetricsFix and retesting:\n"
        
        DirectMetricsFix.shared.fixScientificMetricsDirectly()
        
        let metricsAfterFix = analytics.calculateMetrics(for: .scientific)
        
        for metric in metricsAfterFix {
            let valueStr = formatMetricValue(metric)
            let isZero = isZeroValue(metric: metric)
            let status = isZero ? "❌ STILL ZERO" : "✅ NOW HAS VALUE"
            report += "   \(status) \(metric.type.rawValue): \(valueStr)\n"
        }
        
        // 4. Final diagnosis
        report += "\n4. DIAGNOSIS:\n"
        
        let workingMetrics = metricsAfterFix.filter { !isZeroValue(metric: $0) }.count
        let totalMetrics = metricsAfterFix.count
        
        if workingMetrics == 0 {
            report += "   💥 PROBLEM: All scientific metrics are still 0.00\n"
            report += "   🔧 LIKELY CAUSE: MetricsCalculator instance mismatch\n"
            report += "   💡 SOLUTION: Need to fix key reference issue\n"
        } else if workingMetrics < totalMetrics {
            report += "   ⚠️  PARTIAL SUCCESS: \(workingMetrics)/\(totalMetrics) metrics working\n"
            report += "   🔧 LIKELY CAUSE: Some data thresholds not met\n"
        } else {
            report += "   🎉 SUCCESS: All scientific metrics are working!\n"
        }
        
        report += """
        
        =======================================
        For SimpleDashboard: Switch to 'Scientific' tab to see results
        
        """
        
        print(report)
        return report
    }
    
    private func getAngleHistoryCount(_ calculator: MetricsCalculator) -> Int {
        // Use reflection to get the angle history count
        let mirror = Mirror(reflecting: calculator)
        
        for child in mirror.children {
            if child.label == "angleHistory" {
                if let angleHistory = child.value as? [(time: Double, angle: Double)] {
                    return angleHistory.count
                }
            }
        }
        return 0
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
            return String(format: "%.2f", value)
        case let value as Int:
            return "\(value)"
        case let value as String:
            return value
        default:
            return "Unknown"
        }
    }
}

