import SwiftUI

struct WelcomeView: View {
    @Binding var currentStep: OnboardingStep
    
    var body: some View {
        ZStack {
            // Dark background
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()

                // App Icon/Logo
                Image("badge_day3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                // Header and Subheader
                VStack(spacing: 16) {
                    Text("Congrats are in order!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("You've taken the first step on your quest for sobriety.")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)

                Spacer()
                
                // Get Started Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .addictionSetup
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }
}

enum OnboardingStep: CaseIterable {
    case welcome
    case addictionSetup
    case dateSelection
    case improvementGoals
    case sobrietyImportance
    case personalIdentity
    case improvementAreas
    case motivationSetup
    case badgePreview
    case notificationPermission
}
