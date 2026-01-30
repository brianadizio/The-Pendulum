// TutorialHintOverlay.swift
// The Pendulum 2.0
// Overlay displayed during tutorial mode showing direction, urgency, and explanation

import SwiftUI
import PendulumSolver

// MARK: - Tutorial Lesson Banner (top of screen)

struct TutorialLessonBanner: View {
  @ObservedObject var aiManager: AIManager

  var body: some View {
    VStack(spacing: 8) {
      // Lesson step indicator
      HStack(spacing: 4) {
        ForEach(0..<aiManager.tutorialLessonCount, id: \.self) { i in
          RoundedRectangle(cornerRadius: 2)
            .fill(i < aiManager.tutorialLessonIndex ? PendulumColors.success :
                  i == aiManager.tutorialLessonIndex ? PendulumColors.gold :
                  PendulumColors.backgroundSecondary)
            .frame(height: 4)
        }
      }
      .padding(.horizontal, 4)

      // Lesson title + phase icon
      HStack(spacing: 8) {
        Image(systemName: phaseIcon)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(PendulumColors.gold)

        VStack(alignment: .leading, spacing: 2) {
          Text("Lesson \(aiManager.tutorialLessonIndex + 1): \(aiManager.tutorialLessonTitle)")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(PendulumColors.text)

          Text(aiManager.tutorialLessonDescription)
            .font(.system(size: 12))
            .foregroundStyle(PendulumColors.textSecondary)
            .lineLimit(2)
        }

        Spacer()

        // Completion checkmark
        if aiManager.tutorialLessonComplete {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 22))
            .foregroundStyle(PendulumColors.success)
            .transition(.scale.combined(with: .opacity))
        }
      }

      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 3)
            .fill(PendulumColors.backgroundSecondary)

          RoundedRectangle(cornerRadius: 3)
            .fill(aiManager.tutorialLessonComplete ? PendulumColors.success : PendulumColors.gold)
            .frame(width: geometry.size.width * aiManager.tutorialLessonProgress)
            .animation(.easeInOut(duration: 0.3), value: aiManager.tutorialLessonProgress)
        }
      }
      .frame(height: 6)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(PendulumColors.backgroundTertiary.opacity(0.95))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(PendulumColors.gold.opacity(0.3), lineWidth: 1)
    )
    .shadow(color: PendulumColors.iron.opacity(0.15), radius: 8, y: 4)
    .padding(.horizontal, 16)
    .animation(.easeInOut(duration: 0.3), value: aiManager.tutorialLessonIndex)
    .animation(.easeInOut(duration: 0.3), value: aiManager.tutorialLessonComplete)
  }

  private var phaseIcon: String {
    switch aiManager.tutorialPhase {
    case .observation:     return "eye.fill"
    case .guidedPractice:  return "arrow.left.and.right"
    case .assistedPractice: return "hands.sparkles.fill"
    case .freePractice:    return "figure.walk"
    case .none:            return "lightbulb.fill"
    }
  }
}

// MARK: - Tutorial Complete Overlay

struct TutorialCompleteOverlay: View {
  @ObservedObject var aiManager: AIManager
  @State private var showCheckmark = false
  @State private var showText = false
  @State private var showButton = false

  var body: some View {
    VStack(spacing: 20) {
      // Checkmark with animation
      Image(systemName: "checkmark.seal.fill")
        .font(.system(size: 64))
        .foregroundStyle(PendulumColors.success)
        .scaleEffect(showCheckmark ? 1.0 : 0.3)
        .opacity(showCheckmark ? 1.0 : 0.0)

      // Congratulations text
      VStack(spacing: 8) {
        Text("Tutorial Complete!")
          .font(.system(size: 24, weight: .bold, design: .serif))
          .foregroundStyle(PendulumColors.text)

        Text("You've mastered the basics of balancing the pendulum. Ready to try again or explore other modes?")
          .font(.system(size: 14))
          .foregroundStyle(PendulumColors.textSecondary)
          .multilineTextAlignment(.center)
          .lineLimit(3)
      }
      .opacity(showText ? 1.0 : 0.0)
      .offset(y: showText ? 0 : 10)

      // Lesson summary
      HStack(spacing: 16) {
        LessonSummaryDot(number: 1, title: "Watch", done: true)
        LessonSummaryDot(number: 2, title: "Follow", done: true)
        LessonSummaryDot(number: 3, title: "Assisted", done: true)
        LessonSummaryDot(number: 4, title: "Solo", done: true)
      }
      .opacity(showText ? 1.0 : 0.0)

      // Restart button
      Button(action: {
        aiManager.restartTutorial()
      }) {
        HStack(spacing: 8) {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 16, weight: .semibold))
          Text("Restart Tutorial")
            .font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(PendulumColors.gold)
        )
      }
      .buttonStyle(PlainButtonStyle())
      .opacity(showButton ? 1.0 : 0.0)
      .scaleEffect(showButton ? 1.0 : 0.9)
    }
    .padding(32)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(PendulumColors.backgroundTertiary.opacity(0.97))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(PendulumColors.success.opacity(0.4), lineWidth: 2)
    )
    .shadow(color: PendulumColors.iron.opacity(0.25), radius: 16, y: 8)
    .padding(.horizontal, 32)
    .onAppear {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
        showCheckmark = true
      }
      withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
        showText = true
      }
      withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
        showButton = true
      }
    }
    .onDisappear {
      showCheckmark = false
      showText = false
      showButton = false
    }
  }
}

// MARK: - Lesson Summary Dot

private struct LessonSummaryDot: View {
  let number: Int
  let title: String
  let done: Bool

  var body: some View {
    VStack(spacing: 4) {
      ZStack {
        Circle()
          .fill(PendulumColors.success)
          .frame(width: 28, height: 28)

        Image(systemName: "checkmark")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(.white)
      }

      Text(title)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(PendulumColors.textSecondary)
    }
  }
}

// MARK: - Tutorial Hint Overlay (above controls)

struct TutorialHintOverlay: View {
  let hint: TutorialMode.Hint

  var body: some View {
    VStack(spacing: 10) {
      // Direction arrow
      HStack(spacing: 12) {
        directionIcon
          .font(.system(size: 32, weight: .bold))
          .foregroundStyle(urgencyColor)

        VStack(alignment: .leading, spacing: 4) {
          // Direction label
          Text(directionLabel)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(PendulumColors.text)

          // Urgency dots
          HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
              Circle()
                .fill(i < urgencyLevel ? urgencyColor : PendulumColors.backgroundSecondary)
                .frame(width: 8, height: 8)
            }
            Text(urgencyLabel)
              .font(.system(size: 11))
              .foregroundStyle(PendulumColors.textSecondary)
          }
        }
      }

      // Explanation text
      Text(hint.explanation)
        .font(.system(size: 13))
        .foregroundStyle(PendulumColors.textSecondary)
        .multilineTextAlignment(.center)
        .lineLimit(2)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(PendulumColors.backgroundTertiary.opacity(0.95))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(urgencyColor.opacity(0.4), lineWidth: 1.5)
    )
    .shadow(color: PendulumColors.iron.opacity(0.15), radius: 8, y: 4)
    .padding(.horizontal, 24)
    .transition(.opacity.combined(with: .scale(scale: 0.95)))
    .animation(.easeInOut(duration: 0.3), value: hint.explanation)
  }

  // MARK: - Computed Properties

  private var directionIcon: Image {
    switch hint.suggestedDirection {
    case .left:  return Image(systemName: "arrow.left.circle.fill")
    case .right: return Image(systemName: "arrow.right.circle.fill")
    case .none:  return Image(systemName: "checkmark.circle.fill")
    }
  }

  private var directionLabel: String {
    switch hint.suggestedDirection {
    case .left:  return "Push Left"
    case .right: return "Push Right"
    case .none:  return "Hold Steady"
    }
  }

  private var urgencyLevel: Int {
    if hint.urgency < 0.33 { return 1 }
    if hint.urgency < 0.66 { return 2 }
    return 3
  }

  private var urgencyLabel: String {
    switch urgencyLevel {
    case 1:  return "Low urgency"
    case 2:  return "Medium urgency"
    default: return "High urgency"
    }
  }

  private var urgencyColor: Color {
    switch urgencyLevel {
    case 1:  return PendulumColors.success
    case 2:  return PendulumColors.caution
    default: return PendulumColors.danger
    }
  }
}
