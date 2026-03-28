// BalanceTimelineView.swift
// The Pendulum 2.0
// Canvas-based color-coded balance waveform with per-attempt coloring, glow, and animations

import SwiftUI

struct BalanceTimelineView: View {
  let natureData: NatureData
  let animationProgress: Double
  let drawComplete: Bool

  @State private var glowPulse: Double = 0.0
  @State private var showStreakDefinition = false

  // Single green used for fill tint and attempt dots
  private static let attemptGreen = Color(red: 0.00, green: 0.80, blue: 0.40)

  // Color thresholds (radians deviation from upright)
  private let stableThreshold = 0.087   // ~5 degrees
  private let moderateThreshold = 0.262  // ~15 degrees
  private let severeThreshold = 0.524    // ~30 degrees

  // Inset so labels and last attempt don't clip
  private let leftPad: CGFloat = 4
  private let rightPad: CGFloat = 16

  var body: some View {
    GeometryReader { geo in
      ZStack {
        // Dark background
        Color(red: 0.051, green: 0.051, blue: 0.102) // #0D0D1A

        Canvas { context, size in
          let drawWidth = size.width - leftPad - rightPad
          let centerY = size.height / 2.0
          let samples = natureData.allAngleSamples
          guard samples.count >= 2 else { return }

          let totalTime = natureData.totalDuration
          guard totalTime > 0 else { return }

          // Clamp vertical scale: use 85th percentile to prevent extreme spikes
          // from flattening subtle oscillations, but cap at a reasonable range
          let sortedAngles = samples.map { abs($0.angle) }.sorted()
          let p85Index = min(Int(Double(sortedAngles.count) * 0.85), sortedAngles.count - 1)
          let p85Angle = sortedAngles[p85Index]
          // Clamp between ~5 degrees and ~45 degrees for readable scaling
          let maxAngle = min(max(p85Angle, 0.09), 0.8)
          let verticalScale = (size.height * 0.35) / maxAngle
          let timeScale = drawWidth / totalTime
          let startTime = samples.first!.time

          let clipX = leftPad + drawWidth * animationProgress

          // Animation clip
          context.clip(to: Path(CGRect(x: 0, y: 0, width: clipX, height: size.height)))

          // --- ANNOTATIONS: stable streak highlight band ---
          for annotation in natureData.annotations where annotation.type == .longestStableStreak {
            if let endTime = annotation.endTime {
              let x1 = leftPad + (annotation.time - startTime) * timeScale
              let x2 = leftPad + (endTime - startTime) * timeScale
              let rect = CGRect(x: x1, y: centerY - size.height * 0.3,
                                width: x2 - x1, height: size.height * 0.6)
              context.fill(Path(rect),
                           with: .color(Color(red: 0.30, green: 0.69, blue: 0.31).opacity(0.06)))
            }
          }

          // --- CENTER LINE ---
          let centerLinePath = Path { p in
            p.move(to: CGPoint(x: leftPad, y: centerY))
            p.addLine(to: CGPoint(x: leftPad + drawWidth, y: centerY))
          }
          context.stroke(centerLinePath,
                         with: .color(.white.opacity(0.08)),
                         style: StrokeStyle(lineWidth: 0.5, dash: [8, 4]))

          // --- Stability gradient: green at center (balanced), red at edges (falling) ---
          let stabilityGradient = Gradient(stops: [
            .init(color: Color(red: 0.83, green: 0.0, blue: 0.0), location: 0.0),     // Red (top = max tilt)
            .init(color: Color(red: 1.0, green: 0.43, blue: 0.0), location: 0.15),     // Orange
            .init(color: Color(red: 1.0, green: 0.84, blue: 0.0), location: 0.30),     // Yellow
            .init(color: Color(red: 0.00, green: 0.90, blue: 0.46), location: 0.5),    // Green (center = balanced)
            .init(color: Color(red: 1.0, green: 0.84, blue: 0.0), location: 0.70),     // Yellow
            .init(color: Color(red: 1.0, green: 0.43, blue: 0.0), location: 0.85),     // Orange
            .init(color: Color(red: 0.83, green: 0.0, blue: 0.0), location: 1.0),      // Red (bottom = max tilt)
          ])

          // --- DRAW EACH ATTEMPT AS A SEPARATE PATH ---
          for (attemptIdx, attempt) in natureData.attempts.enumerated() {
            let attemptSamples = attempt.angleSamples
            guard attemptSamples.count >= 2 else { continue }

            let points: [CGPoint] = attemptSamples.map { sample in
              CGPoint(
                x: leftPad + (sample.time - startTime) * timeScale,
                y: centerY - sample.angle * verticalScale
              )
            }

            let renderPoints = points.count > 300
              ? stride(from: 0, to: points.count, by: max(1, points.count / 300)).map { points[$0] }
              : points

            guard renderPoints.count >= 2 else { continue }
            let path = catmullRomPath(points: renderPoints)

            // Fill under curve (subtle green tint)
            let attemptGreen = Self.attemptGreen
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: renderPoints.last!.x, y: centerY))
            fillPath.addLine(to: CGPoint(x: renderPoints.first!.x, y: centerY))
            fillPath.closeSubpath()
            context.fill(fillPath, with: .linearGradient(
              Gradient(colors: [attemptGreen.opacity(0.06), attemptGreen.opacity(0.01)]),
              startPoint: CGPoint(x: 0, y: centerY),
              endPoint: CGPoint(x: 0, y: centerY - size.height * 0.35)
            ))

            // Glow layer
            let glowOpacity = drawComplete ? 0.25 + glowPulse * 0.1 : 0.3
            context.drawLayer { glowCtx in
              glowCtx.addFilter(.blur(radius: 5))
              glowCtx.stroke(path, with: .linearGradient(
                stabilityGradient,
                startPoint: CGPoint(x: 0, y: centerY - size.height * 0.35),
                endPoint: CGPoint(x: 0, y: centerY + size.height * 0.35)
              ), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
              glowCtx.opacity = glowOpacity
            }

            // Crisp stroke — stability coloring for all attempts
            context.stroke(path, with: .linearGradient(
              stabilityGradient,
              startPoint: CGPoint(x: 0, y: centerY - size.height * 0.35),
              endPoint: CGPoint(x: 0, y: centerY + size.height * 0.35)
            ), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
          }

          // --- ATTEMPT SEPARATORS & LABELS ---
          for (i, attempt) in natureData.attempts.enumerated() {
            let hue = Self.attemptGreen

            if i > 0 {
              let x = leftPad + (attempt.startTime - startTime) * timeScale
              let dashPath = Path { p in
                p.move(to: CGPoint(x: x, y: 20))
                p.addLine(to: CGPoint(x: x, y: size.height - 20))
              }
              context.stroke(dashPath, with: .color(.white.opacity(0.2)),
                             style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }

            // Attempt label with color dot
            let labelX = leftPad + (attempt.startTime - startTime) * timeScale + 8
            let durationText = String(format: "%.1fs", attempt.duration)
            var labelStr = "Attempt \(attempt.attemptNumber): \(durationText)"
            if i > 0 && attempt.duration > natureData.attempts[i - 1].duration {
              labelStr += " \u{2191}"
            }

            // Color dot
            let dotRect = CGRect(x: labelX - 6, y: 10, width: 5, height: 5)
            context.fill(Path(ellipseIn: dotRect), with: .color(hue))

            let label = context.resolve(
              Text(labelStr)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            )
            context.draw(label, at: CGPoint(x: labelX + 2, y: 8), anchor: .topLeading)
          }

          // --- ANNOTATION LABELS ---
          let streakGreen = Color(red: 0.30, green: 0.69, blue: 0.31)
          for annotation in natureData.annotations {
            let x = leftPad + (annotation.time - startTime) * timeScale

            switch annotation.type {
            case .longestStableStreak:
              let midX: CGFloat
              if let endTime = annotation.endTime {
                let x2 = leftPad + (endTime - startTime) * timeScale
                midX = (x + x2) / 2.0
              } else { midX = x }

              let labelY = centerY - size.height * 0.32
              let connectorPath = Path { p in
                p.move(to: CGPoint(x: midX, y: labelY + 4))
                p.addLine(to: CGPoint(x: midX, y: centerY - 4))
              }
              context.stroke(connectorPath, with: .color(streakGreen.opacity(0.3)),
                             style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
              let label = context.resolve(
                Text(annotation.label)
                  .font(.system(size: 9, weight: .semibold))
                  .foregroundColor(streakGreen.opacity(0.9))
              )
              context.draw(label, at: CGPoint(x: midX, y: labelY), anchor: .bottom)

            case .bestRecovery:
              let y = centerY - annotation.angle * verticalScale
              let arrowPath = Path { p in
                p.move(to: CGPoint(x: x - 6, y: y - 10))
                p.addQuadCurve(to: CGPoint(x: x + 6, y: y - 10), control: CGPoint(x: x, y: y - 20))
              }
              context.stroke(arrowPath, with: .color(.white.opacity(0.5)),
                             style: StrokeStyle(lineWidth: 1.5))
              let label = context.resolve(
                Text(annotation.label)
                  .font(.system(size: 9, weight: .semibold))
                  .foregroundColor(.white.opacity(0.7))
              )
              context.draw(label, at: CGPoint(x: x, y: y - 22), anchor: .bottom)

            case .fallPoint:
              let y = centerY - annotation.angle * verticalScale
              for offset in [(-3.0, -4.0), (4.0, -2.0), (-2.0, 5.0), (5.0, 3.0), (-4.0, 1.0)] {
                let particleRect = CGRect(x: x + offset.0 - 1.5, y: y + offset.1 - 1.5,
                                          width: 3, height: 3)
                context.fill(Path(ellipseIn: particleRect),
                             with: .color(Color(red: 0.83, green: 0, blue: 0).opacity(0.7)))
              }
            }
          }

          // --- Y-AXIS LABELS ---
          let balancedLabel = context.resolve(
            Text("Balanced")
              .font(.system(size: 8, weight: .medium))
              .foregroundColor(.white.opacity(0.25))
          )
          context.draw(balancedLabel, at: CGPoint(x: leftPad + 2, y: centerY - 6), anchor: .topLeading)

          let tiltDownLabel = context.resolve(
            Text("Tilt \u{2190}")
              .font(.system(size: 7, weight: .regular))
              .foregroundColor(.white.opacity(0.15))
          )
          context.draw(tiltDownLabel, at: CGPoint(x: leftPad + 2, y: centerY + size.height * 0.28), anchor: .topLeading)

          let tiltUpLabel = context.resolve(
            Text("Tilt \u{2192}")
              .font(.system(size: 7, weight: .regular))
              .foregroundColor(.white.opacity(0.15))
          )
          context.draw(tiltUpLabel, at: CGPoint(x: leftPad + 2, y: centerY - size.height * 0.28), anchor: .bottomLeading)

          // --- TIME AXIS TICKS ---
          let tickInterval = timeAxisInterval(totalDuration: totalTime)
          var tickTime = tickInterval
          while tickTime < totalTime {
            let tickX = leftPad + tickTime * timeScale
            let tickPath = Path { p in
              p.move(to: CGPoint(x: tickX, y: size.height - 16))
              p.addLine(to: CGPoint(x: tickX, y: size.height - 10))
            }
            context.stroke(tickPath, with: .color(.white.opacity(0.15)),
                           style: StrokeStyle(lineWidth: 0.5))
            let tickLabel = context.resolve(
              Text(formatTickTime(tickTime))
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.25))
            )
            context.draw(tickLabel, at: CGPoint(x: tickX, y: size.height - 6), anchor: .bottom)
            tickTime += tickInterval
          }
        }

      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .onAppear {
      if drawComplete { startBreathing() }
    }
    .onChange(of: drawComplete) { _, complete in
      if complete {
        startBreathing()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
      }
    }
  }

  private func startBreathing() {
    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
      glowPulse = 1.0
    }
  }

  // MARK: - Time Axis Helpers

  private func timeAxisInterval(totalDuration: Double) -> Double {
    if totalDuration <= 10 { return 2.0 }
    if totalDuration <= 30 { return 5.0 }
    if totalDuration <= 60 { return 10.0 }
    return 15.0
  }

  private func formatTickTime(_ time: Double) -> String {
    if time < 60 {
      return String(format: "%.0fs", time)
    } else {
      let mins = Int(time) / 60
      let secs = Int(time) % 60
      return "\(mins):\(String(format: "%02d", secs))"
    }
  }

  // MARK: - Catmull-Rom to Bezier Path

  private func catmullRomPath(points: [CGPoint]) -> Path {
    Path { path in
      guard points.count >= 2 else { return }
      path.move(to: points[0])

      if points.count == 2 {
        path.addLine(to: points[1])
        return
      }

      for i in 0..<(points.count - 1) {
        let p0 = i > 0 ? points[i - 1] : points[i]
        let p1 = points[i]
        let p2 = points[i + 1]
        let p3 = i + 2 < points.count ? points[i + 2] : points[i + 1]

        let cp1 = CGPoint(
          x: p1.x + (p2.x - p0.x) / 6.0,
          y: p1.y + (p2.y - p0.y) / 6.0
        )
        let cp2 = CGPoint(
          x: p2.x - (p3.x - p1.x) / 6.0,
          y: p2.y - (p3.y - p1.y) / 6.0
        )

        path.addCurve(to: p2, control1: cp1, control2: cp2)
      }
    }
  }
}
