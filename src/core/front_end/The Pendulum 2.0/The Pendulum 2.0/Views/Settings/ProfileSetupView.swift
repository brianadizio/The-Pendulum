// ProfileSetupView.swift
// The Pendulum 2.0
// Step-by-step profile creation modal

import SwiftUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileManager = ProfileManager.shared

    // Existing profile for edit mode
    var existingProfile: UserProfile?

    // Form state
    @State private var currentStep: SetupStep = .welcome
    @State private var displayName: String = ""
    @State private var trainingGoal: TrainingGoal = .focus
    @State private var ageRange: AgeRange?
    @State private var dominantHand: DominantHand?

    var isEditMode: Bool {
        existingProfile != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicator(currentStep: currentStep, isEditMode: isEditMode)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // Step content
                ScrollView {
                    VStack(spacing: 24) {
                        stepContent
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .background(PendulumColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PendulumColors.textSecondary)
                }
            }
            .onAppear {
                if let profile = existingProfile {
                    // Populate from existing profile
                    displayName = profile.displayName
                    trainingGoal = profile.trainingGoal
                    ageRange = profile.ageRange
                    dominantHand = profile.dominantHand
                    currentStep = .name  // Skip welcome in edit mode
                }
            }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .welcome:
            WelcomeStep()

        case .name:
            NameStep(displayName: $displayName)

        case .goal:
            GoalStep(selectedGoal: $trainingGoal)

        case .optional:
            OptionalInfoStep(
                ageRange: $ageRange,
                dominantHand: $dominantHand
            )

        case .done:
            DoneStep(
                displayName: displayName,
                trainingGoal: trainingGoal,
                ageRange: ageRange,
                dominantHand: dominantHand
            )
        }
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button (not on welcome or done)
            if currentStep != .welcome && currentStep != .done {
                Button(action: goBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            // Primary action button
            Button(action: primaryAction) {
                Text(primaryButtonText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canProceed ? PendulumColors.gold : PendulumColors.iron.opacity(0.5))
                    )
            }
            .disabled(!canProceed)
        }
    }

    private var primaryButtonText: String {
        switch currentStep {
        case .welcome:
            return "Get Started"
        case .optional:
            return "Skip & Finish"
        case .done:
            return isEditMode ? "Save Changes" : "Create Profile"
        default:
            return "Continue"
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case .name:
            return !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        default:
            return true
        }
    }

    // MARK: - Navigation Actions

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch currentStep {
            case .name:
                if !isEditMode { currentStep = .welcome }
            case .goal:
                currentStep = .name
            case .optional:
                currentStep = .goal
            case .done:
                currentStep = .optional
            default:
                break
            }
        }
    }

    private func primaryAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch currentStep {
            case .welcome:
                currentStep = .name
            case .name:
                currentStep = .goal
            case .goal:
                currentStep = .optional
            case .optional:
                currentStep = .done
            case .done:
                saveProfile()
            }
        }
    }

    private func saveProfile() {
        let profile = UserProfile(
            id: existingProfile?.id ?? UUID(),
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            trainingGoal: trainingGoal,
            ageRange: ageRange,
            dominantHand: dominantHand,
            createdAt: existingProfile?.createdAt ?? Date(),
            updatedAt: Date()
        )

        if isEditMode {
            profileManager.updateProfile(profile)
        } else {
            profileManager.createProfile(profile)
        }

        dismiss()
    }
}

// MARK: - Setup Steps

enum SetupStep: Int, CaseIterable {
    case welcome = 0
    case name = 1
    case goal = 2
    case optional = 3
    case done = 4
}

// MARK: - Progress Indicator

struct ProgressIndicator: View {
    let currentStep: SetupStep
    let isEditMode: Bool

    private var steps: [SetupStep] {
        isEditMode ? [.name, .goal, .optional, .done] : SetupStep.allCases
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(steps, id: \.rawValue) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? PendulumColors.gold : PendulumColors.bronze.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(PendulumColors.gold)
                .padding(.top, 40)

            Text("Create Your Profile")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Text("Personalize your training experience and track your progress over time.")
                .font(.system(size: 16))
                .foregroundStyle(PendulumColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer().frame(height: 20)

            // Benefits list
            VStack(alignment: .leading, spacing: 16) {
                BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Track your learning progress")
                BenefitRow(icon: "brain.head.profile", text: "Personalized insights")
                BenefitRow(icon: "square.and.arrow.up", text: "Export your data anytime")
            }
            .padding(.horizontal, 20)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 30)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(PendulumColors.text)
        }
    }
}

// MARK: - Name Step

struct NameStep: View {
    @Binding var displayName: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("What should we call you?")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Text("This is just for personalization - you can use a nickname.")
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.textSecondary)
                .multilineTextAlignment(.center)

            TextField("Enter your name", text: $displayName)
                .font(.system(size: 18))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PendulumColors.backgroundTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? PendulumColors.gold : PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                )
                .focused($isFocused)
                .onAppear { isFocused = true }
        }
        .padding(.top, 40)
    }
}

// MARK: - Goal Step

struct GoalStep: View {
    @Binding var selectedGoal: TrainingGoal

    var body: some View {
        VStack(spacing: 20) {
            Text("Why are you training?")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Text("This helps us personalize your experience.")
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.textSecondary)

            VStack(spacing: 12) {
                ForEach(TrainingGoal.allCases) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: selectedGoal == goal
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedGoal = goal
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}

struct GoalOptionCard: View {
    let goal: TrainingGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? PendulumColors.gold : PendulumColors.bronze)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text(goal.description)
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(PendulumColors.gold)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? PendulumColors.gold.opacity(0.1) : PendulumColors.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? PendulumColors.gold : PendulumColors.bronze.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Optional Info Step

struct OptionalInfoStep: View {
    @Binding var ageRange: AgeRange?
    @Binding var dominantHand: DominantHand?

    var body: some View {
        VStack(spacing: 24) {
            Text("Optional Information")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            Text("This helps with future health integrations. You can skip this.")
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.textSecondary)
                .multilineTextAlignment(.center)

            // Age Range
            VStack(alignment: .leading, spacing: 12) {
                Text("AGE RANGE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PendulumColors.textTertiary)

                HStack(spacing: 8) {
                    ForEach(AgeRange.allCases) { range in
                        OptionalChip(
                            text: range.rawValue,
                            isSelected: ageRange == range
                        ) {
                            ageRange = ageRange == range ? nil : range
                        }
                    }
                }
            }

            // Dominant Hand
            VStack(alignment: .leading, spacing: 12) {
                Text("DOMINANT HAND")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PendulumColors.textTertiary)

                HStack(spacing: 8) {
                    ForEach(DominantHand.allCases) { hand in
                        OptionalChip(
                            text: hand.rawValue,
                            isSelected: dominantHand == hand
                        ) {
                            dominantHand = dominantHand == hand ? nil : hand
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}

struct OptionalChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : PendulumColors.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? PendulumColors.gold : PendulumColors.backgroundTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? .clear : PendulumColors.bronze.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Done Step

struct DoneStep: View {
    let displayName: String
    let trainingGoal: TrainingGoal
    let ageRange: AgeRange?
    let dominantHand: DominantHand?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(PendulumColors.success)
                .padding(.top, 20)

            Text("Looking Good!")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(PendulumColors.text)

            // Profile summary
            VStack(spacing: 16) {
                SummaryRow(label: "Name", value: displayName)
                SummaryRow(label: "Goal", value: trainingGoal.rawValue)
                if let age = ageRange {
                    SummaryRow(label: "Age Range", value: age.rawValue)
                }
                if let hand = dominantHand {
                    SummaryRow(label: "Dominant Hand", value: hand.rawValue)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(PendulumColors.backgroundTertiary)
            )
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PendulumColors.text)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileSetupView()
}
