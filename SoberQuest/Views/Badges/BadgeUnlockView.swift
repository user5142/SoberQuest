import SwiftUI

struct BadgeUnlockView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    @Binding var isPresented: Bool
    let onShare: (UIImage) -> Void
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()

                // "Milestone Unlocked" header
                VStack(spacing: 8) {
                    Text("MILESTONE UNLOCKED")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(3)
                        .foregroundColor(AppTheme.textPrimary)
                        .opacity(showContent ? 1 : 0)
                }

                // Badge with animation
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(AppTheme.divider, lineWidth: 1)
                        .frame(width: 240, height: 240)
                        .scaleEffect(scale * 1.1)
                        .opacity(opacity * 0.5)

                    BadgeImageView(
                        imageAssetName: badge.imageAssetName,
                        milestoneDays: badge.milestoneDays,
                        size: 200
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                }
                .onAppear {
                    // Animate badge entrance
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        scale = 1.0
                        opacity = 1.0
                    }

                    withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                        showContent = true
                    }
                }

                // Badge info
                VStack(spacing: 12) {
                    Text(badge.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(badge.milestoneDays == 0 ? "Your Journey Begins" : "Day \(badge.milestoneDays) Achieved")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    if badge.milestoneDays > 0 {
                        Text("\(badge.milestoneDays) days sober from \(addiction.name)")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 4)
                    }
                }
                .opacity(showContent ? 1 : 0)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 14) {
                    // Share button
                    Button(action: {
                        let shareCard = ShareCardView(
                            badge: badge,
                            addiction: addiction,
                            daysSober: badge.milestoneDays
                        )
                        if let image = shareCard.asUIImage() {
                            onShare(image)
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .medium))
                            Text("Share Your Milestone")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.buttonPrimary)
                        .cornerRadius(14)
                    }
                    
                    // Continue button
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.divider, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(showContent ? 1 : 0)
            }
        }
        .preferredColorScheme(.dark)
    }
}
