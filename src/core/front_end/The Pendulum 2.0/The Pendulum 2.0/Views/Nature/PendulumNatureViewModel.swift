// PendulumNatureViewModel.swift
// The Pendulum 2.0
// Orchestrates data loading and animation state for the Pendulum Nature sheet

import SwiftUI
import Combine

@MainActor
class PendulumNatureViewModel: ObservableObject {
  @Published var natureData: NatureData?
  @Published var isLoading = true
  @Published var animationProgress: Double = 0.0
  @Published var drawAnimationComplete = false

  // Multi-day progression
  @Published var progressionDay: Int = 1
  @Published var previousDayData: NatureData?
  @Published var allDaysData: [Int: NatureData]?

  private var animationTimer: AnyCancellable?

  func loadData(from sessionManager: CSVSessionManager) {
    isLoading = true
    Task.detached { [weak self] in
      let currentDay = CSVSessionManager.currentPlayDay
      let data = NatureDataProvider.extractNatureData(from: sessionManager)

      // For Day 2+, also load per-day data for comparisons
      var prevData: NatureData? = nil
      var allDays: [Int: NatureData]? = nil
      if currentDay >= 2 {
        let byDay = NatureDataProvider.extractNatureDataByDay(from: sessionManager)
        allDays = byDay
        // Previous day data = day before current
        prevData = byDay[currentDay - 1] ?? byDay[1]
      }

      await MainActor.run {
        self?.progressionDay = currentDay
        self?.natureData = data
        self?.previousDayData = prevData
        self?.allDaysData = allDays
        self?.isLoading = false
      }
    }
  }

  func startDrawAnimation() {
    animationProgress = 0.0
    drawAnimationComplete = false

    let duration = 3.5
    let fps = 60.0
    let increment = 1.0 / (duration * fps)
    var elapsed = 0.0

    animationTimer?.cancel()
    animationTimer = Timer.publish(every: 1.0 / fps, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self else { return }
        elapsed += increment
        if elapsed >= 1.0 {
          self.animationProgress = 1.0
          self.drawAnimationComplete = true
          self.animationTimer?.cancel()
        } else {
          // Ease-in-out curve
          let t = elapsed
          self.animationProgress = t < 0.5
            ? 2.0 * t * t
            : 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0
        }
      }
  }

  func renderShareImage() -> UIImage? {
    guard let data = natureData else { return nil }
    return NatureShareRenderer.renderShareImage(natureData: data)
  }
}
