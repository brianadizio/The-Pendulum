// DashboardDescriptions.swift
// Provides descriptive text for all dashboard metrics and charts

import Foundation

struct DashboardDescriptions {
    
    // MARK: - Summary Metric Descriptions
    
    static let summaryMetrics: [String: (title: String, description: String)] = [
        "Stability Score": (
            title: "Stability Score",
            description: "Measures how well you keep the pendulum upright (0-100)."
        ),
        "Efficiency Rating": (
            title: "Efficiency Rating", 
            description: "Shows how effectively you use force to maintain balance."
        ),
        "Player Style": (
            title: "Player Style",
            description: "Your playing pattern based on correction behavior."
        ),
        "Reaction Time": (
            title: "Reaction Time",
            description: "Average time to respond when pendulum becomes unstable."
        ),
        "Directional Bias": (
            title: "Directional Bias",
            description: "Tendency to favor left or right corrections."
        ),
        "Session Time": (
            title: "Session Time",
            description: "Total time spent playing in this period."
        )
    ]
    
    // MARK: - Chart Descriptions
    
    static let chartDescriptions: [String: (title: String, description: String)] = [
        "AngleVariance": (
            title: "Pendulum Angle Variance",
            description: "Shows pendulum deviation from vertical over time - lower values mean better stability."
        ),
        "PushFrequency": (
            title: "Push Frequency Distribution",
            description: "How often you apply corrections - optimal frequency balances responsiveness with efficiency."
        ),
        "PushMagnitude": (
            title: "Push Magnitude Distribution",
            description: "Strength of your corrections - smaller forces indicate more precise control."
        ),
        "ReactionTime": (
            title: "Reaction Time Analysis",
            description: "Speed of response to instability - faster reactions typically yield better control."
        ),
        "LearningCurve": (
            title: "Learning Curve",
            description: "Your improvement trend over time based on stability scores."
        ),
        "DirectionalBias": (
            title: "Directional Bias",
            description: "Balance between left and right corrections - centered distribution shows unbiased control."
        ),
        "PhaseSpace": (
            title: "Average Phase Space by Level",
            description: "Pendulum's angle vs velocity patterns - tighter loops indicate better control."
        ),
        "LevelCompletions": (
            title: "Level Completions Over Time",
            description: "Number of levels successfully completed in each time period."
        ),
        "PendulumParameters": (
            title: "Pendulum Parameters Over Time",
            description: "How game physics parameters change across levels to increase difficulty."
        )
    ]
    
    // MARK: - Additional Metric Descriptions
    
    static let additionalMetrics: [String: (title: String, description: String)] = [
        "Total Levels\nBalanced": (
            title: "Total Levels Balanced",
            description: "Cumulative count of all levels completed successfully."
        ),
        "Average Time\nPer Level": (
            title: "Average Time Per Level",
            description: "Mean duration to complete each level - lower times indicate mastery."
        ),
        "Longest Balance\nStreak": (
            title: "Longest Balance Streak",
            description: "Maximum continuous time maintaining stability without major corrections."
        ),
        "Play Sessions\n(Last Week)": (
            title: "Play Sessions (Last Week)",
            description: "Number of times you've played in the past 7 days - consistency improves skill."
        )
    ]
    
    // MARK: - Metric Interpretation Helpers
    
    static func getInterpretation(for metric: String, value: Double) -> String {
        switch metric {
        case "Stability Score":
            if value >= 85 { return "Excellent control!" }
            else if value >= 70 { return "Good stability" }
            else if value >= 50 { return "Moderate control" }
            else { return "Needs improvement" }
            
        case "Efficiency Rating":
            if value >= 80 { return "Very efficient!" }
            else if value >= 60 { return "Good efficiency" }
            else if value >= 40 { return "Average efficiency" }
            else { return "Try using less force" }
            
        case "Reaction Time":
            if value < 0.3 { return "Lightning fast!" }
            else if value < 0.5 { return "Quick reflexes" }
            else if value < 0.7 { return "Average speed" }
            else { return "Try reacting sooner" }
            
        default:
            return ""
        }
    }
    
    // MARK: - Player Style Descriptions
    
    static let playerStyleDescriptions: [String: String] = [
        "Expert Balancer": "Masters the pendulum with minimal effort and maximum precision.",
        "Right-Dominant": "Tends to favor rightward corrections - try balancing your approach.",
        "Left-Dominant": "Tends to favor leftward corrections - try balancing your approach.",
        "Overcorrector": "Often applies opposite forces too quickly - try smoother transitions.",
        "Methodical": "Takes a careful, measured approach to balance control.",
        "Quick but Erratic": "Fast reactions but inconsistent results - focus on precision.",
        "Proactive Controller": "Anticipates instability well and corrects early.",
        "Reactive Controller": "Responds after instability occurs - try anticipating more.",
        "Steady Handler": "Maintains consistent control with good stability.",
        "Efficient Handler": "Uses force effectively to maintain balance.",
        "Balanced Controller": "Shows a well-rounded approach to pendulum control."
    ]
    
    // MARK: - Time Range Descriptions
    
    static func getTimeRangeDescription(_ timeRange: String) -> String {
        switch timeRange {
        case "Session":
            return "Data from your current or most recent play session"
        case "Daily":
            return "Aggregated data from the last 24 hours"
        case "Weekly", "Week":
            return "Performance trends over the past 7 days"
        case "Monthly", "Month":
            return "Monthly summary showing long-term patterns"
        case "Yearly", "Year":
            return "Annual overview of your progress and improvement"
        default:
            return "Performance data for the selected time period"
        }
    }
}