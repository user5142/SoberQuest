import Foundation
import Combine

class BadgeService: ObservableObject {
    static let shared = BadgeService()
    
    private init() {}
    
    func checkForNewBadges(addiction: Addiction, unlockedBadges: [UnlockedBadge]) -> BadgeDefinition? {
        let daysSober = addiction.daysSober
        let unlockedBadgeIds = Set(unlockedBadges.map { $0.badgeId })
        
        // Find the highest milestone that should be unlocked but isn't
        let allBadges = BadgeDefinition.defaultBadges.sorted { $0.milestoneDays > $1.milestoneDays }
        
        for badge in allBadges {
            if daysSober >= badge.milestoneDays && !unlockedBadgeIds.contains(badge.id) {
                return badge
            }
        }
        
        return nil
    }
    
    func getHighestUnlockedBadge(for addictionId: UUID, unlockedBadges: [UnlockedBadge]) -> BadgeDefinition? {
        let addictionBadges = unlockedBadges.filter { $0.addictionId == addictionId }
        let unlockedBadgeIds = Set(addictionBadges.map { $0.badgeId })
        
        let allBadges = BadgeDefinition.defaultBadges.sorted { $0.milestoneDays > $1.milestoneDays }
        
        for badge in allBadges {
            if unlockedBadgeIds.contains(badge.id) {
                return badge
            }
        }
        
        return nil
    }
    
    func getNextMilestoneBadge(for addiction: Addiction, unlockedBadges: [UnlockedBadge]) -> BadgeDefinition? {
        let daysSober = addiction.daysSober
        let unlockedBadgeIds = Set(unlockedBadges.filter { $0.addictionId == addiction.id }.map { $0.badgeId })
        
        let allBadges = BadgeDefinition.defaultBadges.sorted { $0.milestoneDays < $1.milestoneDays }
        
        for badge in allBadges {
            if badge.milestoneDays > daysSober && !unlockedBadgeIds.contains(badge.id) {
                return badge
            }
        }
        
        return nil
    }
    
    func getAllBadges() -> [BadgeDefinition] {
        return BadgeDefinition.defaultBadges.sorted { $0.milestoneDays < $1.milestoneDays }
    }
    
    func isBadgeUnlocked(badgeId: String, for addictionId: UUID, unlockedBadges: [UnlockedBadge]) -> Bool {
        return unlockedBadges.contains { $0.badgeId == badgeId && $0.addictionId == addictionId }
    }
    
    /// Returns the Phoenix Rising (day 0) starter badge
    func getPhoenixRisingBadge() -> BadgeDefinition? {
        return BadgeDefinition.defaultBadges.first { $0.id == "day0" }
    }
}

