import Foundation

struct BadgeDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let milestoneDays: Int
    let imageAssetName: String
    let rarityLevel: String
    
    static let defaultBadges: [BadgeDefinition] = [
        BadgeDefinition(id: "day0", name: "Lantern", milestoneDays: 0, imageAssetName: "badge_day0", rarityLevel: "starter"),
        BadgeDefinition(id: "day1", name: "First Step", milestoneDays: 1, imageAssetName: "badge_day1", rarityLevel: "common"),
        BadgeDefinition(id: "day3", name: "Early Warrior", milestoneDays: 3, imageAssetName: "badge_day3", rarityLevel: "common"),
        BadgeDefinition(id: "day7", name: "Week Warrior", milestoneDays: 7, imageAssetName: "badge_day7", rarityLevel: "uncommon"),
        BadgeDefinition(id: "day14", name: "Fortnight Champion", milestoneDays: 14, imageAssetName: "badge_day14", rarityLevel: "uncommon"),
        BadgeDefinition(id: "day30", name: "Month Master", milestoneDays: 30, imageAssetName: "badge_day30", rarityLevel: "rare"),
        BadgeDefinition(id: "day60", name: "Two Month Hero", milestoneDays: 60, imageAssetName: "badge_day60", rarityLevel: "rare"),
        BadgeDefinition(id: "day90", name: "Quarter Century", milestoneDays: 90, imageAssetName: "badge_day90", rarityLevel: "epic")
    ]
    
    /// Returns the display text for the milestone (e.g., "Day 1" or "Start" for day 0)
    var milestoneDisplayText: String {
        milestoneDays == 0 ? "Start" : "Day \(milestoneDays)"
    }
}

