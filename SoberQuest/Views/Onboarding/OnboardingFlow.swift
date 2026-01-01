import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedAddictionName: String = ""
    @State private var lastUsedDate: Date = Date()
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView(currentStep: $currentStep)
            case .addictionSetup:
                AddictionSetupView(
                    currentStep: $currentStep,
                    selectedAddictionName: $selectedAddictionName,
                    lastUsedDate: $lastUsedDate
                )
            case .badgePreview:
                BadgePreviewView(
                    currentStep: $currentStep,
                    addictionName: selectedAddictionName,
                    lastUsedDate: lastUsedDate
                )
            }
        }
    }
}

