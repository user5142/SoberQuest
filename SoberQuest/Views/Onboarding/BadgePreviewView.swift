import SwiftUI

struct BadgePreviewView: View {
    @Binding var currentStep: OnboardingStep
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var superwallService: SuperwallService
    let addictionName: String
    let lastUsedDate: Date
    
    @State private var isLoading = false
    
    let badges = BadgeDefinition.defaultBadges.prefix(3) // Show first 3 badges as preview
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Unlock Milestone Badges")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Earn collectible badges as you reach milestones")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Badge preview grid
            HStack(spacing: 20) {
                ForEach(Array(badges), id: \.id) { badge in
                    VStack(spacing: 8) {
                        BadgeImageView(imageAssetName: badge.imageAssetName, milestoneDays: badge.milestoneDays, size: 80)
                        
                        Text("Day \(badge.milestoneDays)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 20)
            
            Text("Share your achievements on social media")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                // Save addiction data
                let addiction = Addiction(
                    name: addictionName,
                    startDate: lastUsedDate,
                    currentStreak: 0,
                    isActive: true
                )
                DataManager.shared.saveAddiction(addiction)
                appState.setCurrentAddiction(addiction)
                
                // Present Superwall paywall directly
                isLoading = true
                superwallService.presentOnboardingPaywall { result in
                    isLoading = false
                    
                    switch result {
                    case .purchased, .restored:
                        // User subscribed - grant pro access and complete onboarding
                        appState.hasProAccess = true
                        appState.completeOnboarding()
                    case .declined:
                        // User declined the paywall - still complete onboarding
                        // They can access the app without pro features or subscribe later
                        appState.completeOnboarding()
                    case .skipped:
                        // Paywall was skipped (already subscribed or no paywall configured)
                        appState.hasProAccess = superwallService.hasActiveSubscription
                        appState.completeOnboarding()
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                } else {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .disabled(isLoading)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

