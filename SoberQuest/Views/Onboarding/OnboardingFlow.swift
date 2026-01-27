import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedAddictionName: String = ""
    @State private var lastUsedDate: Date = Date()
    @State private var selectedImprovementGoals: Set<String> = []
    @State private var selectedSobrietyImportance: String? = nil
    @State private var selectedPersonalIdentity: String? = nil
    @State private var selectedImprovementAreas: Set<String> = []
    @State private var selectedMilestone: String? = nil
    @State private var motivationText: String = ""
    @State private var pledgeSettings: DailyPledgeSettings = .default

    private var stepIndex: Int {
        OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
    }

    private var totalSteps: Int {
        OnboardingStep.allCases.count
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                OnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // Content
                ZStack {
                    switch currentStep {
                    case .welcome:
                        WelcomeView(currentStep: $currentStep)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    case .addictionSetup:
                        AddictionSetupView(
                            currentStep: $currentStep,
                            selectedAddictionName: $selectedAddictionName
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .dateSelection:
                        DateSelectionView(
                            currentStep: $currentStep,
                            lastUsedDate: $lastUsedDate,
                            addictionName: selectedAddictionName
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .improvementGoals:
                        ImprovementGoalsView(
                            currentStep: $currentStep,
                            selectedGoals: $selectedImprovementGoals
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .sobrietyImportance:
                        SobrietyImportanceView(
                            currentStep: $currentStep,
                            selectedImportance: $selectedSobrietyImportance
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .personalIdentity:
                        PersonalIdentityView(
                            currentStep: $currentStep,
                            selectedIdentity: $selectedPersonalIdentity
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .improvementAreas:
                        ImprovementAreasView(
                            currentStep: $currentStep,
                            selectedAreas: $selectedImprovementAreas
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .milestoneLookingForward:
                        MilestoneLookingForwardView(
                            currentStep: $currentStep,
                            selectedMilestone: $selectedMilestone
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .motivationSetup:
                        MotivationSetupView(
                            currentStep: $currentStep,
                            motivationText: $motivationText,
                            addictionName: selectedAddictionName
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .dailyPledgeTimes:
                        DailyPledgeTimesView(
                            currentStep: $currentStep,
                            pledgeSettings: $pledgeSettings
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    // case .badgePreview - Disabled, not part of current flow
                    case .notificationPermission:
                        NotificationPermissionView(
                            currentStep: $currentStep,
                            addictionName: selectedAddictionName,
                            lastUsedDate: lastUsedDate,
                            motivationText: motivationText
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    case .onboardingRecap:
                        OnboardingRecapView(
                            currentStep: $currentStep,
                            addictionName: selectedAddictionName,
                            lastUsedDate: lastUsedDate,
                            selectedPersonalIdentity: selectedPersonalIdentity,
                            selectedMilestone: selectedMilestone,
                            selectedImprovementAreas: selectedImprovementAreas,
                            pledgeSettings: pledgeSettings,
                            motivationText: motivationText
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Progress Bar Component
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.white : AppTheme.backgroundSecondary)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
}
