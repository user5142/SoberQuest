import SwiftUI

struct BadgePreviewView: View {
    @Binding var currentStep: OnboardingStep
    @StateObject private var appState = AppState.shared
    let addictionName: String
    let lastUsedDate: Date
    
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
                // Save addiction and proceed to paywall
                let addiction = Addiction(
                    name: addictionName,
                    startDate: lastUsedDate,
                    currentStreak: 0,
                    isActive: true
                )
                DataManager.shared.saveAddiction(addiction)
                appState.setCurrentAddiction(addiction)
                
                withAnimation {
                    currentStep = .paywall
                }
            }) {
                Text("Continue")
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

