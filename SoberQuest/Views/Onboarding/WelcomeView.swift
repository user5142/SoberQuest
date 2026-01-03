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
                ZStack {
                    // Icon background
                    Circle()
                        .fill(AppTheme.backgroundSecondary)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.divider, lineWidth: 1)
                        )

                    // Star icon
                    Image(systemName: "star.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.bottom, 20)
                
                // Title
                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("SoberQuest")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                // Description
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "clock.arrow.circlepath",
                        title: "Track Your Journey",
                        description: "Monitor your sobriety progress in real-time"
                    )
                    
                    FeatureRow(
                        icon: "trophy.fill",
                        title: "Unlock Badges",
                        description: "Earn fantasy-themed milestone achievements"
                    )
                    
                    FeatureRow(
                        icon: "square.and.arrow.up",
                        title: "Share Progress",
                        description: "Celebrate milestones with beautiful share cards"
                    )
                }
                .padding(.top, 20)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .addictionSetup
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppTheme.backgroundSecondary)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()
        }
    }
}

enum OnboardingStep {
    case welcome
    case addictionSetup
    case dateSelection
    case badgePreview
}
