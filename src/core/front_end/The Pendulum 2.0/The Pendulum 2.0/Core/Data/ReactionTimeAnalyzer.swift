// ReactionTimeAnalyzer.swift
// The Pendulum 2.0
// Statistical analysis of reaction time distributions for Golden Cipher

import Foundation

// MARK: - Reaction Time Distribution

/// Full statistical summary of reaction times within a session
struct ReactionTimeDistribution: Codable {
    let count: Int
    let mean: Double
    let median: Double
    let mode: Double
    let stdDev: Double
    let skewness: Double
    let kurtosis: Double
    let p25: Double
    let p75: Double
    let p90: Double
    let iqr: Double

    // Gamma distribution fit (method of moments)
    let gammaShape: Double
    let gammaScale: Double

    // Log-normal distribution fit (method of moments)
    let logNormalMu: Double
    let logNormalSigma: Double
}

// MARK: - Reaction Time Analyzer

enum ReactionTimeAnalyzer {

    /// Analyze an array of reaction times and return a full distribution summary.
    /// Returns nil if fewer than 3 valid reaction times are provided.
    static func analyze(_ times: [Double]) -> ReactionTimeDistribution? {
        guard times.count >= 3 else { return nil }

        let sorted = times.sorted()
        let n = Double(times.count)

        // Mean
        let mean = sorted.reduce(0, +) / n

        // Median
        let median = percentile(sorted, p: 0.5)

        // Mode (bin into 50ms buckets, find most frequent)
        let mode = computeMode(sorted)

        // Variance and standard deviation
        let variance = sorted.map { pow($0 - mean, 2) }.reduce(0, +) / n
        let stdDev = sqrt(variance)

        // Fisher skewness: E[(X-mu)^3] / sigma^3
        let skewness: Double
        if stdDev > 1e-10 {
            let m3 = sorted.map { pow($0 - mean, 3) }.reduce(0, +) / n
            skewness = m3 / pow(stdDev, 3)
        } else {
            skewness = 0.0
        }

        // Excess kurtosis: E[(X-mu)^4] / sigma^4 - 3
        let kurtosis: Double
        if stdDev > 1e-10 {
            let m4 = sorted.map { pow($0 - mean, 4) }.reduce(0, +) / n
            kurtosis = m4 / pow(stdDev, 4) - 3.0
        } else {
            kurtosis = 0.0
        }

        // Percentiles (linear interpolation)
        let p25 = percentile(sorted, p: 0.25)
        let p75 = percentile(sorted, p: 0.75)
        let p90 = percentile(sorted, p: 0.90)
        let iqr = p75 - p25

        // Gamma fit (method of moments): k = mean^2 / var, theta = var / mean
        let gammaShape: Double
        let gammaScale: Double
        if variance > 1e-10 && mean > 1e-10 {
            gammaShape = pow(mean, 2) / variance
            gammaScale = variance / mean
        } else {
            gammaShape = 1.0
            gammaScale = mean
        }

        // Log-normal fit (method of moments)
        let logNormalMu: Double
        let logNormalSigma: Double
        if mean > 1e-10 && variance > 0 {
            let cv2 = variance / pow(mean, 2)  // coefficient of variation squared
            logNormalSigma = sqrt(log(1 + cv2))
            logNormalMu = log(mean) - 0.5 * pow(logNormalSigma, 2)
        } else {
            logNormalMu = 0.0
            logNormalSigma = 0.0
        }

        return ReactionTimeDistribution(
            count: times.count,
            mean: mean,
            median: median,
            mode: mode,
            stdDev: stdDev,
            skewness: skewness,
            kurtosis: kurtosis,
            p25: p25,
            p75: p75,
            p90: p90,
            iqr: iqr,
            gammaShape: gammaShape,
            gammaScale: gammaScale,
            logNormalMu: logNormalMu,
            logNormalSigma: logNormalSigma
        )
    }

    // MARK: - Helpers

    /// Linear interpolation percentile on a sorted array
    private static func percentile(_ sorted: [Double], p: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        if sorted.count == 1 { return sorted[0] }

        let index = p * Double(sorted.count - 1)
        let lower = Int(floor(index))
        let upper = min(lower + 1, sorted.count - 1)
        let fraction = index - Double(lower)
        return sorted[lower] + fraction * (sorted[upper] - sorted[lower])
    }

    /// Compute mode by binning into 50ms buckets
    private static func computeMode(_ sorted: [Double]) -> Double {
        let binWidth = 0.05  // 50ms
        var bins: [Int: Int] = [:]
        for t in sorted {
            let bin = Int(t / binWidth)
            bins[bin, default: 0] += 1
        }
        let maxBin = bins.max(by: { $0.value < $1.value })?.key ?? 0
        return (Double(maxBin) + 0.5) * binWidth  // Center of bin
    }
}
