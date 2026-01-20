import SwiftUI

struct BadgePreviewView: View {
    @Binding var currentStep: OnboardingStep
    let addictionName: String
    let lastUsedDate: Date
    let motivationText: String

    @State private var animatedBadges: [Bool] = [false, false, false]
    
    let badges = BadgeDefinition.defaultBadges.filter { ["day7", "day100", "day365"].contains($0.id) }
    
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
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .notificationPermission
                    }
                }) {
                    Text("Continue")
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
}
