import SwiftUI

struct BadgePreviewView: View {
    @Binding var currentStep: OnboardingStep
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var superwallService: SuperwallService
    let addictionName: String
    let lastUsedDate: Date
    let motivationText: String
    
    @State private var isLoading = false
    @State private var animatedBadges: [Bool] = [false, false, false]
    
    let badges = Array(BadgeDefinition.defaultBadges.prefix(3))
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Header
                VStack(spacing: 12) {
                    Text("Unlock Milestone Badges")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Earn collectible badges as you reach milestones")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)
                
                // Badge preview grid
                HStack(spacing: 24) {
                    ForEach(Array(badges.enumerated()), id: \.element.id) { index, badge in
                        VStack(spacing: 12) {
                            BadgeImageView(
                                imageAssetName: badge.imageAssetName,
                                milestoneDays: badge.milestoneDays,
                                size: 90
                            )
                            .scaleEffect(animatedBadges[index] ? 1.0 : 0.5)
                            .opacity(animatedBadges[index] ? 1.0 : 0.0)
                            .onAppear {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.15)) {
                                    animatedBadges[index] = true
                                }
                            }

                            Text(badge.milestoneDisplayText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(.vertical, 24)
                
                // Feature callouts
                VStack(spacing: 16) {
                    featureCallout(icon: "sparkles", text: "Beautiful artwork for each milestone")
                    featureCallout(icon: "square.and.arrow.up", text: "Share your achievements on social media")
                    featureCallout(icon: "trophy.fill", text: "Collect all badges as you progress")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    continueToApp()
                }) {
                    Group {
                        if isLoading {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.buttonPrimaryText))
                                Text("Loading...")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        } else {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(AppTheme.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.buttonPrimary)
                    .cornerRadius(14)
                }
                .disabled(isLoading)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private func featureCallout(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 32, height: 32)
                .background(AppTheme.backgroundSecondary)
                .cornerRadius(8)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
    }
    
    private func continueToApp() {
        // Save addiction data with motivation
        let trimmedMotivation = motivationText.trimmingCharacters(in: .whitespacesAndNewlines)
        // If user selected "today", use current time so timer starts from now
        let startDate = Calendar.current.isDateInToday(lastUsedDate) ? Date() : lastUsedDate
        let addiction = Addiction(
            name: addictionName,
            startDate: startDate,
            currentStreak: 0,
            isActive: true,
            motivation: trimmedMotivation.isEmpty ? nil : trimmedMotivation
        )
        DataManager.shared.saveAddiction(addiction)
        appState.setCurrentAddiction(addiction)
        
        // Grant all badges earned based on days sober
        let daysSober = addiction.daysSober
        for badge in BadgeDefinition.defaultBadges {
            if daysSober >= badge.milestoneDays {
                let unlockedBadge = UnlockedBadge(badgeId: badge.id, addictionId: addiction.id)
                DataManager.shared.saveUnlockedBadge(unlockedBadge)
            }
        }
        
        // Present Superwall paywall directly
        isLoading = true
        superwallService.presentOnboardingPaywall { result in
            isLoading = false
            
            switch result {
            case .purchased, .restored:
                appState.hasProAccess = true
                appState.completeOnboarding()
            case .declined:
                appState.completeOnboarding()
            case .skipped:
                appState.hasProAccess = superwallService.hasActiveSubscription
                appState.completeOnboarding()
            }
        }
    }
}
