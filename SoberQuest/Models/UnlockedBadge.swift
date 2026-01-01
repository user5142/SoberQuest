import Foundation

struct UnlockedBadge: Identifiable, Codable {
    let id: UUID
    let badgeId: String
    let addictionId: UUID
    let unlockedDate: Date
    
    init(id: UUID = UUID(), badgeId: String, addictionId: UUID, unlockedDate: Date = Date()) {
        self.id = id
        self.badgeId = badgeId
        self.addictionId = addictionId
        self.unlockedDate = unlockedDate
    }
}

