import SwiftUI

struct BadgeCollectionView: View {
    let addiction: Addiction
    @Binding var isPresented: Bool
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var badgeService = BadgeService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(badgeService.getAllBadges()) { badge in
                        BadgeCell(
                            badge: badge,
                            isUnlocked: isBadgeUnlocked(badge.id)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Badge Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
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
        VStack(spacing: 8) {
            BadgeImageView(imageAssetName: badge.imageAssetName, milestoneDays: badge.milestoneDays, size: 80)
                .opacity(isUnlocked ? 1.0 : 0.3)
                .overlay(
                    Group {
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                )
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(isUnlocked ? .medium : .regular)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
            
            Text("Day \(badge.milestoneDays)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

