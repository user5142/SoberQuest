import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedAddictionName: String = ""
    @State private var lastUsedDate: Date = Date()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
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
            case .badgePreview:
                BadgePreviewView(
                    currentStep: $currentStep,
                    addictionName: selectedAddictionName,
                    lastUsedDate: lastUsedDate
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .preferredColorScheme(.dark)
    }
}
