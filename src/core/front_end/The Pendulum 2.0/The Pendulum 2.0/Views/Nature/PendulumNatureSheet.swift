// PendulumNatureSheet.swift
// The Pendulum 2.0
// Main "Your Pendulum Nature" sheet with balance timeline, archetype, and share

import SwiftUI

struct PendulumNatureSheet: View {
  @ObservedObject var gameState: GameState
  @StateObject private var viewModel = PendulumNatureViewModel()
  @Environment(\.dismiss) private var dismiss

  @State private var showingShareSheet = false
  @State private var shareItems: [Any] = []
  @State private var showScienceCard = true
  @State private var showingChatView = false

  var body: some View {
    NavigationView {
      Group {
        if viewModel.isLoading {
          loadingView
        } else if let data = viewModel.natureData {
          contentView(data: data)
        } else {
          noDataView
        }
      }
      .background(PendulumColors.background)
      .navigationTitle("Your Pendulum Nature")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
            .foregroundStyle(PendulumColors.gold)
        }
      }
    }
    .onAppear {
      if let sessionManager = gameState.csvSessionManager {
        print("[Nature] Sheet appeared, csvSessionManager exists, isRecording: \(sessionManager.isRecording)")
        viewModel.loadData(from: sessionManager)
      } else {
        print("[Nature] Sheet appeared but csvSessionManager is NIL")
        viewModel.isLoading = false
      }
    }
    .sheet(isPresented: $showingShareSheet) {
      ShareSheet(items: shareItems)
    }
  }

  // MARK: - Content

  private func contentView(data: NatureData) -> some View {
    ScrollView {
      VStack(spacing: 24) {
        switch viewModel.progressionDay {
        case 1:
          day1Content(data: data)
        case 2:
          day2Content(data: data)
        default:
          day3Content(data: data)
        }
      }
      .padding(.top, 8)
    }
  }

  // MARK: - Day 1 Content (current layout + invitation card)

  private func day1Content(data: NatureData) -> some View {
    Group {
      // Hero: Balance Timeline Waveform
      BalanceTimelineView(
        natureData: data,
        animationProgress: viewModel.animationProgress,
        drawComplete: viewModel.drawAnimationComplete
      )
      .frame(height: UIScreen.main.bounds.height * 0.42)
      .padding(.horizontal, 16)
      .onAppear {
        viewModel.startDrawAnimation()
      }

      archetypeSection(data: data)

      HStack(alignment: .top, spacing: 20) {
        StabilityScoreRing(score: data.stabilityScore)
          .frame(width: 100, height: 120)
        attemptBarsView(data: data)
          .frame(maxWidth: .infinity)
      }
      .padding(.horizontal, 20)

      if showScienceCard { scienceCard }

      shareButton(data: data)

      ReturnInvitationCard(
        day: viewModel.progressionDay,
        onPlayMore: { dismiss() },
        onExploreDashboard: {
          dismiss()
          NotificationCenter.default.post(name: .switchToDashboard, object: nil)
        }
      )

      Spacer(minLength: 20)
    }
  }

  // MARK: - Day 2 Content (comparison layout)

  private func day2Content(data: NatureData) -> some View {
    Group {
      if let previousData = viewModel.previousDayData {
        DayComparisonView(
          currentData: data,
          previousData: previousData,
          animationProgress: viewModel.animationProgress,
          drawComplete: viewModel.drawAnimationComplete
        )
        .onAppear { viewModel.startDrawAnimation() }
      } else {
        // Fallback: show current data like Day 1 if no previous
        BalanceTimelineView(
          natureData: data,
          animationProgress: viewModel.animationProgress,
          drawComplete: viewModel.drawAnimationComplete
        )
        .frame(height: UIScreen.main.bounds.height * 0.42)
        .padding(.horizontal, 16)
        .onAppear { viewModel.startDrawAnimation() }
      }

      archetypeSection(data: data)

      HStack(alignment: .top, spacing: 20) {
        StabilityScoreRing(score: data.stabilityScore)
          .frame(width: 100, height: 120)
        attemptBarsView(data: data)
          .frame(maxWidth: .infinity)
      }
      .padding(.horizontal, 20)

      HealthPromptCard()

      if showScienceCard { scienceCard }

      shareButton(data: data)

      ReturnInvitationCard(
        day: viewModel.progressionDay,
        onPlayMore: { dismiss() },
        onExploreDashboard: {
          dismiss()
          NotificationCenter.default.post(name: .switchToDashboard, object: nil)
        }
      )

      Spacer(minLength: 20)
    }
  }

  // MARK: - Day 3+ Content (paywall teaser)

  @State private var showingPaywall = false

  private func day3Content(data: NatureData) -> some View {
    Group {
      // Stacked waveforms for all days
      if let allDays = viewModel.allDaysData {
        VStack(spacing: 8) {
          ForEach(Array(allDays.keys.sorted()), id: \.self) { dayNum in
            if let dayData = allDays[dayNum] {
              VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                  Text("Day \(dayNum)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(dayNum == allDays.keys.max() ? PendulumColors.gold : PendulumColors.silver)
                  Text("Score: \(Int(dayData.stabilityScore))")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(PendulumColors.textTertiary)
                  Spacer()
                }
                .padding(.horizontal, 16)

                BalanceTimelineView(
                  natureData: dayData,
                  animationProgress: 1.0,
                  drawComplete: true
                )
                .frame(height: UIScreen.main.bounds.height * 0.14)
                .opacity(dayNum == allDays.keys.max() ? 1.0 : 0.6)
                .padding(.horizontal, 16)
              }
            }
          }
        }
        .onAppear { viewModel.startDrawAnimation() }
      } else {
        BalanceTimelineView(
          natureData: data,
          animationProgress: viewModel.animationProgress,
          drawComplete: viewModel.drawAnimationComplete
        )
        .frame(height: UIScreen.main.bounds.height * 0.42)
        .padding(.horizontal, 16)
        .onAppear { viewModel.startDrawAnimation() }
      }

      archetypeSection(data: data)

      // Trended stability scores
      if let allDays = viewModel.allDaysData, allDays.count >= 2 {
        stabilityTrendRow(allDays: allDays)
      }

      // AI Chat — unlocked if purchased/trial, locked if expired
      aiChatCard

      // Golden Mode CTA
      Button {
        showingPaywall = true
      } label: {
        HStack(spacing: 8) {
          Image(systemName: "crown.fill")
          Text("Unlock Golden Mode")
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(GoldButtonStyle())
      .padding(.horizontal, 20)
      .sheet(isPresented: $showingPaywall) {
        PaywallView(purchaseManager: PurchaseManager.shared)
      }

      shareButton(data: data)

      ReturnInvitationCard(
        day: viewModel.progressionDay,
        onPlayMore: { dismiss() },
        onExploreDashboard: {
          dismiss()
          NotificationCenter.default.post(name: .switchToDashboard, object: nil)
        }
      )

      Spacer(minLength: 20)
    }
  }

  // MARK: - Stability Trend Row

  private func stabilityTrendRow(allDays: [Int: NatureData]) -> some View {
    let sortedDays = allDays.keys.sorted()
    let scores = sortedDays.compactMap { allDays[$0]?.stabilityScore }
    let scoreText = scores.map { String(format: "%.0f", $0) }.joined(separator: " → ")

    return HStack(spacing: 12) {
      Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.system(size: 16))
        .foregroundStyle(PendulumColors.gold)

      VStack(alignment: .leading, spacing: 2) {
        Text("Stability Trend")
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(PendulumColors.textTertiary)
        Text(scoreText)
          .font(.system(size: 18, weight: .bold, design: .monospaced))
          .foregroundStyle(PendulumColors.text)
      }

      Spacer()
    }
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(PendulumColors.backgroundTertiary)
    )
    .padding(.horizontal, 20)
  }

  // MARK: - AI Chat Card (unlocked if purchased/trial, locked if expired)

  private var aiChatCard: some View {
    let canAccess = PurchaseManager.shared.canAccessApp

    return Button {
      if canAccess {
        showingChatView = true
      } else {
        showingPaywall = true
      }
    } label: {
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 8) {
          Image(systemName: canAccess ? "bubble.left.and.bubble.right.fill" : "lock.fill")
            .font(.system(size: 14))
            .foregroundStyle(canAccess ? PendulumColors.gold : PendulumColors.silver)

          Text("AI Balance Coach")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(PendulumColors.text)

          Spacer()

          if canAccess {
            Image(systemName: "chevron.right")
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(PendulumColors.textTertiary)
          }
        }

        HStack(spacing: 10) {
          Image(systemName: "bubble.left.fill")
            .font(.system(size: 14))
            .foregroundStyle(PendulumColors.gold.opacity(canAccess ? 0.8 : 0.5))

          Text("\"Ask me about your balance trajectory\"")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(PendulumColors.textSecondary)
            .italic()
        }
        .padding(10)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(PendulumColors.background)
        )

        if !canAccess {
          Text("Unlock Golden Mode to chat with your AI coach")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(PendulumColors.silver)
        }
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(PendulumColors.backgroundTertiary)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke((canAccess ? PendulumColors.gold : PendulumColors.silver).opacity(0.15), lineWidth: 1)
      )
    }
    .buttonStyle(PlainButtonStyle())
    .padding(.horizontal, 20)
    .sheet(isPresented: $showingChatView) {
      ChatView(metricsCalculator: CSVMetricsCalculator())
    }
  }

  // MARK: - Archetype Section

  private func archetypeSection(data: NatureData) -> some View {
    VStack(spacing: 8) {
      HStack(spacing: 10) {
        let archetype = data.archetypeResult.archetype
        Image(systemName: archetype.icon)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(Color(
            red: archetype.color.red,
            green: archetype.color.green,
            blue: archetype.color.blue
          ))

        Text(archetype.displayName)
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(PendulumColors.text)
      }

      Text(data.archetypeResult.archetype.insight)
        .font(.system(size: 14, weight: .regular))
        .foregroundStyle(PendulumColors.textSecondary)
        .multilineTextAlignment(.center)
        .lineSpacing(3)
        .padding(.horizontal, 24)
    }
  }

  // MARK: - Attempt Comparison Bars

  private func attemptBarsView(data: NatureData) -> some View {
    let attempts = Array(data.attempts.prefix(5))
    let typicalAverage = 12.0 // Typical first-session average (seconds)
    let scaleMax = max(attempts.map { $0.duration }.max() ?? 1.0, typicalAverage * 1.2)
    let improving = attempts.count >= 2 && attempts.last!.duration > attempts.first!.duration

    return VStack(alignment: .leading, spacing: 8) {
      Text("ATTEMPTS")
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(PendulumColors.textTertiary)

      ZStack(alignment: .bottom) {
        // Reference line: typical user average
        VStack(spacing: 0) {
          Spacer()
          HStack(spacing: 0) {
            Rectangle()
              .fill(PendulumColors.silver.opacity(0.3))
              .frame(height: 0.5)
            Text("avg")
              .font(.system(size: 7, weight: .medium))
              .foregroundStyle(PendulumColors.silver.opacity(0.5))
              .padding(.leading, 3)
          }
          .offset(y: -CGFloat(typicalAverage / scaleMax) * 60.0)
        }
        .frame(height: 74)

        HStack(alignment: .bottom, spacing: 8) {
          ForEach(Array(attempts.enumerated()), id: \.offset) { idx, attempt in
            VStack(spacing: 4) {
              Text(String(format: "%.1fs", attempt.duration))
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(PendulumColors.textSecondary)

              RoundedRectangle(cornerRadius: 4)
                .fill(barColor(duration: attempt.duration))
                .frame(
                  width: 22,
                  height: max(CGFloat(attempt.duration / scaleMax) * 60.0, 6.0)
                )
            }
          }
        }
      }

      if improving {
        HStack(spacing: 4) {
          Image(systemName: "arrow.up.right")
            .font(.system(size: 10))
          Text("Improving")
            .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(PendulumColors.success)
      }
    }
  }

  private func barColor(duration: TimeInterval) -> Color {
    if duration > 10 {
      return PendulumColors.success
    } else if duration > 5 {
      return PendulumColors.warning
    } else {
      return PendulumColors.caution
    }
  }

  // MARK: - Science Card

  private var scienceCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: "brain.head.profile")
          .font(.system(size: 18))
          .foregroundStyle(PendulumColors.bronze)

        Text("The Science of Your Score")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(PendulumColors.text)
      }

      Text("Balance control involves three systems: vision, proprioception, and the vestibular organs of your inner ear. The Pendulum measures how these systems work together. This same dynamics analysis is used in vestibular rehabilitation research at the Ashton Graybiel Spatial Orientation Lab at Brandeis University.")
        .font(.system(size: 12, weight: .regular))
        .foregroundStyle(PendulumColors.textSecondary)
        .lineSpacing(3)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(red: 0.96, green: 0.94, blue: 0.92)) // #F5F0EB warm gray
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(PendulumColors.bronze.opacity(0.15), lineWidth: 1)
    )
    .padding(.horizontal, 20)
  }

  // MARK: - Loading / Empty States

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .tint(PendulumColors.gold)
      Text("Analyzing your balance...")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)
    }
  }

  private var noDataView: some View {
    VStack(spacing: 16) {
      Image(systemName: "waveform.path.ecg")
        .font(.system(size: 40))
        .foregroundStyle(PendulumColors.silver)
      Text("Play a few rounds to discover your Pendulum Nature")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
  }

  // MARK: - Share Button

  private func shareButton(data: NatureData) -> some View {
    Button {
      shareBalance(data: data)
    } label: {
      HStack(spacing: 8) {
        Image(systemName: "square.and.arrow.up")
        Text("Share Your Balance")
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(GoldButtonStyle())
    .padding(.horizontal, 20)
  }

  private func shareBalance(data: NatureData) {
    let archetype = data.archetypeResult.archetype.displayName
    let score = Int(data.stabilityScore)
    let shareText = "My Balance Style: \(archetype). Stability Score: \(score)/100. Discover yours."

    if let image = viewModel.renderShareImage() {
      shareItems = [image, shareText]
    } else {
      shareItems = [shareText]
    }
    showingShareSheet = true
  }
}

// MARK: - Notification Name

extension Notification.Name {
  static let pendulumNatureReady = Notification.Name("pendulumNatureReady")
  static let switchToDashboard = Notification.Name("switchToDashboard")
  static let progressionNotificationTapped = Notification.Name("progressionNotificationTapped")
}
