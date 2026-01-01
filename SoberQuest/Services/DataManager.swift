import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let addictionsKey = "SavedAddictions"
    private let unlockedBadgesKey = "UnlockedBadges"
    private let onboardingCompletedKey = "OnboardingCompleted"
    
    private init() {}
    
    // MARK: - Addictions
    
    func saveAddiction(_ addiction: Addiction) {
        var addictions = loadAddictions()
        if let index = addictions.firstIndex(where: { $0.id == addiction.id }) {
            addictions[index] = addiction
        } else {
            addictions.append(addiction)
        }
        saveAddictions(addictions)
    }
    
    func loadAddictions() -> [Addiction] {
        guard let data = UserDefaults.standard.data(forKey: addictionsKey),
              let addictions = try? JSONDecoder().decode([Addiction].self, from: data) else {
            return []
        }
        return addictions
    }
    
    private func saveAddictions(_ addictions: [Addiction]) {
        if let data = try? JSONEncoder().encode(addictions) {
            UserDefaults.standard.set(data, forKey: addictionsKey)
        }
    }
    
    func deleteAddiction(_ addiction: Addiction) {
        var addictions = loadAddictions()
        addictions.removeAll { $0.id == addiction.id }
        saveAddictions(addictions)
    }
    
    func getActiveAddiction() -> Addiction? {
        return loadAddictions().first { $0.isActive }
    }
    
    func setActiveAddiction(_ addiction: Addiction) {
        var addictions = loadAddictions()
        for i in addictions.indices {
            addictions[i].isActive = (addictions[i].id == addiction.id)
        }
        saveAddictions(addictions)
    }
    
    func updateStreak(for addictionId: UUID) {
        var addictions = loadAddictions()
        if let index = addictions.firstIndex(where: { $0.id == addictionId }) {
            let daysSober = addictions[index].daysSober
            addictions[index].currentStreak = max(addictions[index].currentStreak, daysSober)
            saveAddictions(addictions)
        }
    }
    
    // MARK: - Unlocked Badges
    
    func saveUnlockedBadge(_ badge: UnlockedBadge) {
        var badges = loadUnlockedBadges()
        // Don't duplicate if already unlocked
        if !badges.contains(where: { $0.badgeId == badge.badgeId && $0.addictionId == badge.addictionId }) {
            badges.append(badge)
            saveUnlockedBadges(badges)
        }
    }
    
    func loadUnlockedBadges() -> [UnlockedBadge] {
        guard let data = UserDefaults.standard.data(forKey: unlockedBadgesKey),
              let badges = try? JSONDecoder().decode([UnlockedBadge].self, from: data) else {
            return []
        }
        return badges
    }
    
    func loadUnlockedBadges(for addictionId: UUID) -> [UnlockedBadge] {
        return loadUnlockedBadges().filter { $0.addictionId == addictionId }
    }
    
    private func saveUnlockedBadges(_ badges: [UnlockedBadge]) {
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: unlockedBadgesKey)
        }
    }
    
    // MARK: - Onboarding
    
    func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingCompletedKey)
    }
    
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
}

