import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var appState = AppState.shared
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
                    addictionName: $selectedAddictionName,
                    lastUsedDate: $lastUsedDate
                )
            case .paywall:
                PaywallView(currentStep: $currentStep)
            }
        }
    }
}

struct PaywallView: View {
    @Binding var currentStep: OnboardingStep
    @StateObject private var appState = AppState.shared
    @StateObject private var superwallService = SuperwallService.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Unlock SoberQuest Pro")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                FeatureRow(icon: "checkmark.circle.fill", text: "Daily check-ins")
                FeatureRow(icon: "checkmark.circle.fill", text: "Streak tracking")
                FeatureRow(icon: "checkmark.circle.fill", text: "Sobriety timer")
                FeatureRow(icon: "checkmark.circle.fill", text: "Milestone badges")
                FeatureRow(icon: "checkmark.circle.fill", text: "Share cards")
                FeatureRow(icon: "checkmark.circle.fill", text: "Multiple addictions")
            }
            .padding(.vertical, 30)
            
            Text("7-day free trial, then $X.XX/month")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                // Present Superwall paywall
                superwallService.presentPaywall()
                
                // For MVP: Simulate subscription success
                // In production, this would be handled by Superwall callbacks
                superwallService.setSubscriptionActive(true)
                appState.hasProAccess = true
                appState.completeOnboarding()
            }) {
                Text("Start Free Trial")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

