import Foundation

struct BadgeDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let milestoneDays: Int
    let imageAssetName: String
    let rarityLevel: String
    let description: String

    static let defaultBadges: [BadgeDefinition] = [
        BadgeDefinition(id: "day0", name: "Lantern", milestoneDays: 0, imageAssetName: "badge_day0", rarityLevel: "starter", description: "Every journey begins with a single spark. This lantern lights your path through the darkness ahead."),
        BadgeDefinition(id: "day1", name: "Apprentice", milestoneDays: 1, imageAssetName: "badge_day1", rarityLevel: "common", description: "You've taken your first step on the path of mastery. The apprentice learns that strength comes from within."),
        BadgeDefinition(id: "day3", name: "Compass", milestoneDays: 3, imageAssetName: "badge_day3", rarityLevel: "common", description: "Three days of clarity! This compass always points toward your true north, guiding you through temptation."),
        BadgeDefinition(id: "day7", name: "Shield", milestoneDays: 7, imageAssetName: "badge_day7", rarityLevel: "uncommon", description: "A full week of resilience! This shield protects you from the arrows of doubt and craving."),
        BadgeDefinition(id: "day14", name: "Campfire", milestoneDays: 14, imageAssetName: "badge_day14", rarityLevel: "uncommon", description: "Two weeks strong! Gather around this campfire - a place of warmth, rest, and renewed determination."),
        BadgeDefinition(id: "day30", name: "Traveler's Sword", milestoneDays: 30, imageAssetName: "badge_day30", rarityLevel: "rare", description: "One month of victory! This sword was forged in the fires of your commitment and tempered by your will."),
        BadgeDefinition(id: "day60", name: "Glint Fox", milestoneDays: 60, imageAssetName: "badge_day60", rarityLevel: "rare", description: "Two months of cunning! Like the Glint Fox, you've learned to outsmart temptation at every turn."),
        BadgeDefinition(id: "day90", name: "Crystal Drake", milestoneDays: 90, imageAssetName: "badge_day90", rarityLevel: "epic", description: "Three months of transformation! The Crystal Drake represents your evolution into something truly magnificent."),
        BadgeDefinition(id: "day100", name: "Phoenix Guardian", milestoneDays: 100, imageAssetName: "badge_day100", rarityLevel: "epic", description: "100 days of rebirth! Like the Phoenix, you've risen from the ashes, reborn stronger and more radiant than ever."),
        BadgeDefinition(id: "day120", name: "Ancient Key", milestoneDays: 120, imageAssetName: "badge_day120", rarityLevel: "legendary", description: "120 days of discovery! This ancient key unlocks doors once thought sealed forever—the doors to your true potential."),
        BadgeDefinition(id: "day150", name: "Leather-bound Map", milestoneDays: 150, imageAssetName: "badge_day150", rarityLevel: "legendary", description: "150 days of exploration! This weathered map charts the territory you've conquered and reveals paths yet to come."),
        BadgeDefinition(id: "day180", name: "Obsidian Crown", milestoneDays: 180, imageAssetName: "badge_day180", rarityLevel: "mythic", description: "Half a year of sovereignty! The Obsidian Crown marks you as ruler of your own destiny, unshakeable and resolute."),
        BadgeDefinition(id: "day200", name: "Eternal Star Clock", milestoneDays: 200, imageAssetName: "badge_day200", rarityLevel: "mythic", description: "200 days of timeless dedication! The Eternal Star Clock marks the moment when time itself bows to your unwavering resolve."),
        BadgeDefinition(id: "day210", name: "Sky Temple", milestoneDays: 210, imageAssetName: "badge_day210", rarityLevel: "mythic", description: "210 days of ascension! The Sky Temple floats above the clouds, a sacred sanctuary reached only by those with unwavering dedication."),
        BadgeDefinition(id: "day240", name: "Shroomfolk", milestoneDays: 240, imageAssetName: "badge_day240", rarityLevel: "mythic", description: "240 days of growth! The Shroomfolk emerges from the forest floor, a symbol of resilience thriving in the darkest places.")
    ]
    
    /// Returns the display text for the milestone (e.g., "Day 1" or "Start" for day 0)
    var milestoneDisplayText: String {
        milestoneDays == 0 ? "Start" : "Day \(milestoneDays)"
    }
}

