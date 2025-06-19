import Foundation

// MARK: - Metric Group Types
enum MetricGroupType: String, CaseIterable {
    case basic = "Basic"
    case advanced = "Advanced"
    case scientific = "Scientific"
    case educational = "Educational"
    case topology = "Topology"
    case performance = "Performance"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .basic: return "📊"
        case .advanced: return "📈"
        case .scientific: return "🔬"
        case .educational: return "📚"
        case .topology: return "🔗"
        case .performance: return "⚡️"
        }
    }
    
    var description: String {
        switch self {
        case .basic:
            return "Essential metrics for quick understanding"
        case .advanced:
            return "Comprehensive behavioral and control metrics"
        case .scientific:
            return "Physics-based analysis and chaos measures"
        case .educational:
            return "Learning progress and skill development"
        case .topology:
            return "Topological invariants and phase space structure"
        case .performance:
            return "Real-time performance optimization metrics"
        }
    }
}

// MARK: - Individual Metric Types
enum MetricType: String, CaseIterable {
    // Basic Metrics
    case stabilityScore = "Stability Score"
    case balanceDuration = "Balance Duration"
    case pushCount = "Push Count"
    case currentLevel = "Current Level"
    case sessionTime = "Session Time"
    case playerStyle = "Player Style"
    
    // Additional Basic Dashboard Metrics
    case pushMagnitudeDistribution = "Push Magnitude Distribution"
    case reactionTimeAnalysis = "Reaction Time Analysis"
    case fullDirectionalBias = "Full Directional Bias"
    case levelCompletionsOverTime = "Level Completions Over Time"
    case pendulumParametersOverTime = "Pendulum Parameters Over Time"
    
    // Advanced Metrics
    case efficiencyRating = "Efficiency Rating"
    case directionalBias = "Directional Bias"
    case averageCorrectionTime = "Avg Correction Time"
    case overcorrectionRate = "Overcorrection Rate"
    case forceDistribution = "Force Distribution"
    case inputFrequencySpectrum = "Input Frequency"
    case responseDelay = "Response Delay"
    
    // Scientific Metrics
    case phaseSpaceCoverage = "Phase Space Coverage"
    case energyManagement = "Energy Management"
    case lyapunovExponent = "Lyapunov Exponent"
    case controlStrategy = "Control Strategy"
    case stateTransitionFreq = "State Transitions"
    case angularDeviation = "Angular Deviation"
    case phaseTrajectory = "Phase Trajectory"
    
    // Educational Metrics
    case learningCurve = "Learning Curve"
    case adaptationRate = "Adaptation Rate"
    case skillRetention = "Skill Retention"
    case failureModeAnalysis = "Failure Analysis"
    case challengeThreshold = "Challenge Level"
    case persistenceScore = "Persistence Score"
    case improvementRate = "Improvement Rate"
    
    // Topology Metrics
    case windingNumber = "Winding Number"
    case rotationNumber = "Rotation Number"
    case homoclinicTangle = "Homoclinic Tangle"
    case periodicOrbitCount = "Periodic Orbits"
    case basinStability = "Basin Stability"
    case topologicalEntropy = "Topological Entropy"
    case bettinumbers = "Betti Numbers"
    case persistentHomology = "Persistent Homology"
    case separatrixCrossings = "Separatrix Crossings"
    case phasePortraitStructure = "Phase Portrait Type"
    
    // Performance Metrics
    case realtimeStability = "Realtime Stability"
    case cpuUsage = "CPU Usage"
    case frameRate = "Frame Rate"
    case responseLatency = "Response Latency"
    case memoryEfficiency = "Memory Usage"
    case batteryImpact = "Battery Impact"
    
    var unit: String {
        switch self {
        case .stabilityScore, .efficiencyRating, .phaseSpaceCoverage, 
             .energyManagement, .skillRetention:
            return "%"
        case .balanceDuration, .sessionTime, .averageCorrectionTime, .responseDelay:
            return "s"
        case .pushCount, .stateTransitionFreq:
            return "count"
        case .currentLevel, .challengeThreshold:
            return "level"
        case .directionalBias, .lyapunovExponent:
            return "coefficient"
        case .overcorrectionRate, .adaptationRate, .improvementRate:
            return "rate"
        case .forceDistribution, .inputFrequencySpectrum, .pushMagnitudeDistribution:
            return "distribution"
        case .controlStrategy, .failureModeAnalysis, .phasePortraitStructure, .playerStyle:
            return "category"
        case .reactionTimeAnalysis:
            return "s"
        case .fullDirectionalBias:
            return "%"
        case .levelCompletionsOverTime:
            return "count"
        case .pendulumParametersOverTime:
            return "values"
        case .angularDeviation:
            return "rad"
        case .phaseTrajectory:
            return "path"
        case .learningCurve:
            return "slope"
        case .persistenceScore:
            return "attempts"
        case .windingNumber, .periodicOrbitCount, .separatrixCrossings:
            return "count"
        case .rotationNumber:
            return "ratio"
        case .homoclinicTangle:
            return "complexity"
        case .basinStability:
            return "%"
        case .topologicalEntropy:
            return "bits"
        case .bettinumbers, .persistentHomology:
            return "dimension"
        case .realtimeStability:
            return "variance"
        case .cpuUsage, .memoryEfficiency, .batteryImpact:
            return "%"
        case .frameRate:
            return "fps"
        case .responseLatency:
            return "ms"
        }
    }
    
    var isDistribution: Bool {
        switch self {
        case .forceDistribution, .inputFrequencySpectrum, .failureModeAnalysis, .bettinumbers, .persistentHomology, .pushMagnitudeDistribution, .fullDirectionalBias:
            return true
        default:
            return false
        }
    }
    
    var isTimeSeries: Bool {
        switch self {
        case .cpuUsage, .frameRate, .responseLatency, .realtimeStability, .phaseTrajectory, .learningCurve, .windingNumber, .separatrixCrossings, .angularDeviation, .reactionTimeAnalysis, .pendulumParametersOverTime, .levelCompletionsOverTime:
            return true
        default:
            return false
        }
    }
}

// MARK: - Metric Group Definitions
struct MetricGroupDefinition {
    static let groups: [MetricGroupType: [MetricType]] = [
        .basic: [
            .stabilityScore,
            .efficiencyRating,
            .playerStyle,
            .averageCorrectionTime,  // Shown as "Reaction Time"
            .directionalBias,
            .sessionTime,
            .angularDeviation,  // For pendulum angle variance chart
            .forceDistribution,  // For push frequency & magnitude
            .learningCurve,
            .phaseTrajectory,  // For average phase space by level
            .pushMagnitudeDistribution,
            .reactionTimeAnalysis,
            .fullDirectionalBias,
            .levelCompletionsOverTime,
            .pendulumParametersOverTime
        ],
        
        .advanced: [
            .efficiencyRating,
            .directionalBias,
            .averageCorrectionTime,
            .overcorrectionRate,
            .forceDistribution,
            .inputFrequencySpectrum,
            .responseDelay
        ],
        
        .scientific: [
            .phaseSpaceCoverage,
            .energyManagement,
            .lyapunovExponent,
            .controlStrategy,
            .stateTransitionFreq,
            .angularDeviation,
            .phaseTrajectory
        ],
        
        .educational: [
            .learningCurve,
            .adaptationRate,
            .skillRetention,
            .failureModeAnalysis,
            .challengeThreshold,
            .persistenceScore,
            .improvementRate
        ],
        
        .topology: [
            .windingNumber,
            .rotationNumber,
            .homoclinicTangle,
            .periodicOrbitCount,
            .basinStability,
            .topologicalEntropy,
            .bettinumbers,
            .persistentHomology,
            .separatrixCrossings,
            .phasePortraitStructure
        ],
        
        .performance: [
            .realtimeStability,
            .cpuUsage,
            .frameRate,
            .responseLatency,
            .memoryEfficiency,
            .batteryImpact
        ]
    ]
    
    static func metrics(for group: MetricGroupType) -> [MetricType] {
        return groups[group] ?? []
    }
    
    static func group(for metric: MetricType) -> MetricGroupType? {
        for (group, metrics) in groups {
            if metrics.contains(metric) {
                return group
            }
        }
        return nil
    }
}

// MARK: - Metric Value Container
struct MetricValue {
    let type: MetricType
    let value: Any
    let timestamp: Date
    let confidence: Double? // For metrics with uncertainty
    
    var formattedValue: String {
        switch value {
        case let doubleValue as Double:
            switch type.unit {
            case "%":
                return String(format: "%.1f%%", doubleValue)
            case "s":
                return String(format: "%.2fs", doubleValue)
            case "ms":
                return String(format: "%.0fms", doubleValue)
            case "rad":
                return String(format: "%.3f rad", doubleValue)
            case "coefficient":
                return String(format: "%.3f", doubleValue)
            case "rate":
                return String(format: "%.2f", doubleValue)
            case "N·s":
                return String(format: "%.1f N·s", doubleValue)
            case "fps":
                return String(format: "%.0f fps", doubleValue)
            case "correlation":
                return String(format: "%.3f", doubleValue)
            case "changes/min":
                return String(format: "%.1f/min", doubleValue)
            case "variance":
                return String(format: "%.4f", doubleValue)
            case "ratio":
                return String(format: "%.4f", doubleValue)
            case "complexity":
                return String(format: "%.2f", doubleValue)
            case "bits":
                return String(format: "%.2f bits", doubleValue)
            case "dimension":
                return String(format: "%.1f", doubleValue)
            default:
                return String(format: "%.2f", doubleValue)
            }
            
        case let intValue as Int:
            switch type.unit {
            case "count":
                return "\(intValue)"
            case "level":
                return "Level \(intValue)"
            case "attempts":
                return "\(intValue) attempts"
            default:
                return "\(intValue)"
            }
            
        case let stringValue as String:
            return stringValue
            
        case let distribution as [Double]:
            return "[\(distribution.count) points]"
            
        case let timeSeries as [(Date, Double)]:
            return "[\(timeSeries.count) samples]"
            
        case let bettiNumbers as [Int]:
            return "β₀=\(bettiNumbers[0]), β₁=\(bettiNumbers[1])"
            
        case let homology as [(birth: Double, death: Double, dimension: Int)]:
            return "\(homology.count) features"
            
        case let trajectory as [(theta: Double, omega: Double)]:
            return "[\(trajectory.count) points]"
            
        default:
            return "N/A"
        }
    }
}

// MARK: - Metric Display Configuration
struct MetricDisplayConfig {
    let primaryColor: String
    let secondaryColor: String
    let chartType: ChartType
    let refreshRate: TimeInterval
    
    enum ChartType {
        case gauge
        case line
        case bar
        case histogram
        case scatter
        case radar
        case text
    }
    
    static func defaultConfig(for type: MetricType) -> MetricDisplayConfig {
        switch type {
        case .stabilityScore, .efficiencyRating, .phaseSpaceCoverage, .energyManagement:
            return MetricDisplayConfig(
                primaryColor: "#007AFF",
                secondaryColor: "#5AC8FA",
                chartType: .gauge,
                refreshRate: 0.5
            )
            
        case .phaseTrajectory, .learningCurve, .realtimeStability, .cpuUsage, .frameRate, .responseLatency, .angularDeviation, .averageCorrectionTime, .reactionTimeAnalysis, .levelCompletionsOverTime, .pendulumParametersOverTime:
            return MetricDisplayConfig(
                primaryColor: "#FF9500",
                secondaryColor: "#FFCC00",
                chartType: .line,
                refreshRate: 0.1
            )
            
        case .forceDistribution, .inputFrequencySpectrum, .pushMagnitudeDistribution:
            return MetricDisplayConfig(
                primaryColor: "#4CD964",
                secondaryColor: "#7ED321",
                chartType: .histogram,
                refreshRate: 1.0
            )
            
        case .directionalBias, .controlStrategy, .fullDirectionalBias:
            return MetricDisplayConfig(
                primaryColor: "#FF3B30",
                secondaryColor: "#FF6B6B",
                chartType: .radar,
                refreshRate: 0.5
            )
            
        // Topology metrics
        case .windingNumber, .separatrixCrossings:
            return MetricDisplayConfig(
                primaryColor: "#A020F0",
                secondaryColor: "#DA70D6",
                chartType: .line,
                refreshRate: 0.5
            )
            
        case .basinStability:
            return MetricDisplayConfig(
                primaryColor: "#4B0082",
                secondaryColor: "#8A2BE2",
                chartType: .gauge,
                refreshRate: 1.0
            )
            
        case .bettinumbers, .persistentHomology:
            return MetricDisplayConfig(
                primaryColor: "#6A0DAD",
                secondaryColor: "#9932CC",
                chartType: .bar,
                refreshRate: 2.0
            )
            
        case .phasePortraitStructure:
            return MetricDisplayConfig(
                primaryColor: "#483D8B",
                secondaryColor: "#6A5ACD",
                chartType: .text,
                refreshRate: 5.0
            )
            
        case .homoclinicTangle, .topologicalEntropy:
            return MetricDisplayConfig(
                primaryColor: "#8B008B",
                secondaryColor: "#BA55D3",
                chartType: .scatter,
                refreshRate: 2.0
            )
            
        default:
            return MetricDisplayConfig(
                primaryColor: "#8E8E93",
                secondaryColor: "#C7C7CC",
                chartType: .text,
                refreshRate: 1.0
            )
        }
    }
}

// MARK: - Metric Calculation Priority
enum MetricPriority: Int {
    case realtime = 0    // Calculate every frame
    case high = 1        // Calculate every 0.1s
    case medium = 2      // Calculate every 0.5s
    case low = 3         // Calculate every 1s
    case background = 4  // Calculate when idle
    
    var interval: TimeInterval {
        switch self {
        case .realtime: return 0.016  // 60 fps
        case .high: return 0.1
        case .medium: return 0.5
        case .low: return 1.0
        case .background: return 5.0
        }
    }
}

// MARK: - Metric Calculation Requirements
struct MetricRequirements {
    let minimumDataPoints: Int
    let minimumSessionDuration: TimeInterval
    let requiredSensors: [SensorType]
    
    enum SensorType {
        case pendulumAngle
        case pendulumVelocity
        case userInput
        case systemPerformance
        case sessionTiming
    }
    
    static func requirements(for type: MetricType) -> MetricRequirements {
        switch type {
        case .lyapunovExponent:
            return MetricRequirements(
                minimumDataPoints: 1000,
                minimumSessionDuration: 30.0,
                requiredSensors: [.pendulumAngle, .pendulumVelocity]
            )
            
        case .learningCurve, .adaptationRate:
            return MetricRequirements(
                minimumDataPoints: 100,
                minimumSessionDuration: 60.0,
                requiredSensors: [.pendulumAngle, .userInput, .sessionTiming]
            )
            
        case .cpuUsage, .frameRate, .memoryEfficiency:
            return MetricRequirements(
                minimumDataPoints: 10,
                minimumSessionDuration: 1.0,
                requiredSensors: [.systemPerformance]
            )
            
        default:
            return MetricRequirements(
                minimumDataPoints: 10,
                minimumSessionDuration: 5.0,
                requiredSensors: [.pendulumAngle, .userInput]
            )
        }
    }
}