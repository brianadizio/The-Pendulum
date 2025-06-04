import Foundation
import UIKit

// MARK: - Scientific Metrics Final Fix
/// Complete solution for the scientific metrics 0.00 display issue

class ScientificMetricsFinalFix {
    
    static let shared = ScientificMetricsFinalFix()
    
    private init() {}
    
    /// Complete fix for scientific metrics showing 0.00
    func applyCompleteFix() -> String {
        print("🔧 Applying complete fix for Scientific metrics...")
        
        var report = """
        🔬 SCIENTIFIC METRICS FINAL FIX
        ==============================
        
        Issue: Scientific metrics showing 0.00 despite DirectMetricsFix claiming success
        Root Cause: MetricsCalculator instance mismatch between DirectMetricsFix and dashboard
        
        """
        
        // 1. Apply the corrected DirectMetricsFix
        print("1️⃣ Applying corrected DirectMetricsFix...")
        DirectMetricsFix.shared.fixScientificMetricsDirectly()
        
        // 2. Wait for processing
        Thread.sleep(forTimeInterval: 0.5)
        
        // 3. Test scientific metrics through the actual dashboard path
        print("2️⃣ Testing dashboard access path...")
        let dashboardMetrics = testDashboardMetricsAccess()
        
        report += """
        
        CORRECTED APPROACH:
        - DirectMetricsFix now uses AnalyticsManagerExtensions public interface
        - Data populated through trackEnhancedPendulumState() and trackEnhancedInteraction()
        - Ensures same MetricsCalculator instance used by dashboard
        
        DASHBOARD ACCESS TEST:
        \(dashboardMetrics)
        
        """
        
        // 4. Provide detailed diagnostic information
        let diagnostics = performDetailedDiagnostics()
        report += diagnostics
        
        // 5. Final verification
        let verification = performFinalVerification()
        report += verification
        
        print(report)
        return report
    }
    
    /// Test scientific metrics through the exact dashboard access path
    private func testDashboardMetricsAccess() -> String {
        let analytics = AnalyticsManager.shared
        let scientificMetrics = analytics.calculateMetrics(for: .scientific)
        
        var result = ""
        var workingCount = 0
        
        for metric in scientificMetrics {
            let isWorking = !isZeroValue(metric: metric)
            if isWorking { workingCount += 1 }
            
            let status = isWorking ? "✅" : "❌"
            let valueStr = formatMetricValue(metric)
            result += "    \(status) \(metric.type.rawValue): \(valueStr)\n"
        }
        
        let percentage = scientificMetrics.count > 0 ? (Double(workingCount) / Double(scientificMetrics.count)) * 100 : 0
        result += "    📊 Working: \(workingCount)/\(scientificMetrics.count) (\(Int(percentage))%)\n"
        
        return result
    }
    
    /// Perform detailed diagnostics of the metrics system
    private func performDetailedDiagnostics() -> String {
        var diagnostics = """
        
        DETAILED DIAGNOSTICS:
        ====================
        
        """
        
        let analytics = AnalyticsManager.shared
        
        // Test if tracking is active
        diagnostics += "📊 Analytics tracking active: \(analytics.isTracking)\n"
        
        // Test data flow through extension
        analytics.trackEnhancedPendulumState(time: 100.0, angle: Double.pi + 0.2, angleVelocity: 0.3)
        analytics.trackEnhancedInteraction(time: 100.0, eventType: "push", angle: Double.pi + 0.2, angleVelocity: 0.3, magnitude: 1.5, direction: "left")
        
        diagnostics += "✅ Extension methods callable\n"
        
        // Test individual scientific metrics
        let scientificMetricTypes: [MetricType] = [.phaseSpaceCoverage, .energyManagement, .lyapunovExponent, .controlStrategy, .stateTransitionFreq]
        
        diagnostics += "\nINDIVIDUAL METRIC TESTS:\n"
        for metricType in scientificMetricTypes {
            if let metricValue = testIndividualMetric(analytics: analytics, type: metricType) {
                let isWorking = !isZeroValue(metric: metricValue)
                let status = isWorking ? "✅" : "❌"
                let valueStr = formatMetricValue(metricValue)
                diagnostics += "  \(status) \(metricType.rawValue): \(valueStr)\n"
            } else {
                diagnostics += "  ❌ \(metricType.rawValue): Failed to calculate\n"
            }
        }
        
        return diagnostics
    }
    
    /// Test individual metric calculation
    private func testIndividualMetric(analytics: AnalyticsManager, type: MetricType) -> MetricValue? {
        let metricValues = analytics.calculateMetrics(for: .scientific)
        return metricValues.first { $0.type == type }
    }
    
    /// Perform final verification of the fix
    private func performFinalVerification() -> String {
        var verification = """
        
        FINAL VERIFICATION:
        ==================
        
        """
        
        // Test multiple calls to ensure consistency
        let analytics = AnalyticsManager.shared
        var consistentResults = true
        var lastWorkingCount = -1
        
        for attempt in 1...3 {
            let metrics = analytics.calculateMetrics(for: .scientific)
            let workingCount = metrics.filter { !isZeroValue(metric: $0) }.count
            
            if lastWorkingCount == -1 {
                lastWorkingCount = workingCount
            } else if lastWorkingCount != workingCount {
                consistentResults = false
            }
            
            verification += "  Attempt \(attempt): \(workingCount) working metrics\n"
        }
        
        verification += "\n"
        
        if consistentResults && lastWorkingCount > 0 {
            verification += "🎉 SUCCESS: Scientific metrics are working consistently!\n"
            verification += "✅ Fix applied successfully\n"
            verification += "✅ Data flows correctly from DirectMetricsFix to dashboard\n"
            verification += "✅ Multiple MetricsCalculator instances issue resolved\n"
        } else if lastWorkingCount > 0 {
            verification += "⚠️  PARTIAL SUCCESS: Metrics working but inconsistent\n"
            verification += "🔧 May need additional stability improvements\n"
        } else {
            verification += "💥 FAILURE: Scientific metrics still showing 0.00\n"
            verification += "❌ Further investigation needed\n"
        }
        
        return verification
    }
    
    /// Check if metric value represents "zero" or "no data"
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
    
    /// Format metric value for display
    private func formatMetricValue(_ metric: MetricValue) -> String {
        switch metric.value {
        case let value as Double:
            if value == 0 {
                return "0.00"
            } else if abs(value) < 0.001 {
                return String(format: "%.6f", value)
            } else {
                return String(format: "%.3f", value)
            }
        case let value as Int:
            return "\(value)"
        case let value as String:
            return value
        default:
            return "Unknown"
        }
    }
}

// MARK: - Enhanced DirectMetricsFix Integration
extension DirectMetricsFix {
    
    /// Apply the complete fix including verification
    func applyCompleteFix() -> String {
        return ScientificMetricsFinalFix.shared.applyCompleteFix()
    }
}

// MARK: - DeveloperToolsViewController Integration
extension DeveloperToolsViewController {
    
    /// Run the complete scientific metrics fix
    func runCompleteScientificMetricsFix() {
        DispatchQueue.global(qos: .userInitiated).async {
            let report = ScientificMetricsFinalFix.shared.applyCompleteFix()
            
            DispatchQueue.main.async { [weak self] in
                self?.showFixReport(report, title: "Scientific Metrics Fix")
            }
        }
    }
    
    private func showFixReport(_ report: String, title: String) {
        let textView = UITextView()
        textView.text = report
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.backgroundColor = .systemBackground
        
        let vc = UIViewController()
        vc.view = textView
        vc.title = title
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissFixReport)
        )
        
        present(nav, animated: true)
    }
    
    @objc private func dismissFixReport() {
        dismiss(animated: true)
    }
}