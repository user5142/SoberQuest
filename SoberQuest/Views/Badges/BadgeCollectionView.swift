import SwiftUI

struct BadgeCollectionView: View {
    let addiction: Addiction
    @Binding var isPresented: Bool
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var badgeService = BadgeService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header info
                        VStack(spacing: 8) {
                            Text("Your Collection")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            let unlockedCount = dataManager.loadUnlockedBadges(for: addiction.id).count
                            let totalCount = badgeService.getAllBadges().count
                            
                            Text("\(unlockedCount) / \(totalCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.gold)
                        }
                        .padding(.top, 16)
                        
                        // Badge Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(badgeService.getAllBadges()) { badge in
                                BadgeCell(
                                    badge: badge,
                                    isUnlocked: isBadgeUnlocked(badge.id)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Badge Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.gold)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func isBadgeUnlocked(_ badgeId: String) -> Bool {
        let unlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        return badgeService.isBadgeUnlocked(badgeId: badgeId, for: addiction.id, unlockedBadges: unlockedBadges)
    }
}

struct BadgeCell: View {
    let badge: BadgeDefinition
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Badge Image
                BadgeImageView(
                    imageAssetName: badge.imageAssetName,
                    milestoneDays: badge.milestoneDays,
                    size: 72
                )
                .opacity(isUnlocked ? 1.0 : 0.25)
                .saturation(isUnlocked ? 1.0 : 0.0)
                
                // Lock overlay
                if !isUnlocked {
                    Circle()
                        .fill(AppTheme.background.opacity(0.5))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.system(size: 12, weight: isUnlocked ? .semibold : .regular))
                    .foregroundColor(isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.milestoneDisplayText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isUnlocked ? AppTheme.gold : AppTheme.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? AppTheme.backgroundSecondary : AppTheme.cardBackgroundDark.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? AppTheme.gold.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
