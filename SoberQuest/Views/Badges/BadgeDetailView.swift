import SwiftUI

struct BadgeDetailView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    let isUnlocked: Bool
    let onDismiss: () -> Void

    @State private var showSharePreview = false

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)

                Spacer()

                // Badge display
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(AppTheme.divider, lineWidth: 1)
                        .frame(width: 240, height: 240)
                        .opacity(isUnlocked ? 0.5 : 0.2)

                    BadgeImageView(
                        imageAssetName: badge.imageAssetName,
                        milestoneDays: badge.milestoneDays,
                        size: 200
                    )
                    .opacity(isUnlocked ? 1.0 : 0.3)
                    .saturation(isUnlocked ? 1.0 : 0.0)

                    // Lock overlay for locked badges
                    if !isUnlocked {
                        Circle()
                            .fill(AppTheme.background.opacity(0.6))
                            .frame(width: 200, height: 200)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }

                // Badge info
                VStack(spacing: 12) {
                    Text(isUnlocked ? badge.name : "???")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted)

                    Text(badge.milestoneDays == 0 ? "Your Journey Begins" : "Day \(badge.milestoneDays) Achieved")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    if isUnlocked {
                        // Badge description
                        Text(badge.description)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    } else {
                        Text("Reach \(badge.milestoneDays) days to unlock")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(.top, 4)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 14) {
                    if isUnlocked {
                        // Share button - only for unlocked badges
                        Button(action: {
                            showSharePreview = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Share Badge")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(AppTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.buttonPrimary)
                            .cornerRadius(14)
                        }
                    }

                    // Close button
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("Close")
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
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showSharePreview) {
            SharePreviewView(
                badge: badge,
                addiction: addiction,
                isPresented: $showSharePreview,
                useMilestoneDays: true
            )
        }
    }
}
