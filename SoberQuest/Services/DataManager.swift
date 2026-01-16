import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let addictionsKey = "SavedAddictions"
    private let unlockedBadgesKey = "UnlockedBadges"
    private let onboardingCompletedKey = "OnboardingCompleted"
    private let lanternBadgeShownKey = "LanternBadgeShown"
    private let hasUsedTrialKey = "HasUsedTrial"
    private let userMotivationKey = "UserMotivation"
    
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

        // Also delete associated badges
        deleteBadges(for: addiction.id)
    }

    func deleteBadges(for addictionId: UUID) {
        var badges = loadUnlockedBadges()
        badges.removeAll { $0.addictionId == addictionId }
        saveUnlockedBadges(badges)
    }

    func removeBadge(badgeId: String, for addictionId: UUID) {
        var badges = loadUnlockedBadges()
        badges.removeAll { $0.badgeId == badgeId && $0.addictionId == addictionId }
        saveUnlockedBadges(badges)
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

    /// Silently unlocks all badges the user qualifies for but hasn't unlocked yet.
    /// Called at app launch to retroactively grant badges when new milestones are added.
    func syncBadgesForAddiction(_ addiction: Addiction) {
        let unlockedBadges = loadUnlockedBadges(for: addiction.id)
        let missingBadges = BadgeService.shared.getAllMissingBadges(addiction: addiction, unlockedBadges: unlockedBadges)

        for badge in missingBadges {
            let unlockedBadge = UnlockedBadge(badgeId: badge.id, addictionId: addiction.id)
            saveUnlockedBadge(unlockedBadge)
        }
    }

    // MARK: - Onboarding
    
    func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingCompletedKey)
    }
    
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    // MARK: - Initial Badge Shown

    func setInitialBadgeShown(_ shown: Bool) {
        UserDefaults.standard.set(shown, forKey: lanternBadgeShownKey)
    }

    func isInitialBadgeShown() -> Bool {
        return UserDefaults.standard.bool(forKey: lanternBadgeShownKey)
    }
    
    // MARK: - Trial Usage Tracking

    func setHasUsedTrial(_ used: Bool) {
        UserDefaults.standard.set(used, forKey: hasUsedTrialKey)
    }

    func hasUsedTrial() -> Bool {
        return UserDefaults.standard.bool(forKey: hasUsedTrialKey)
    }

    // MARK: - User Motivation

    func saveMotivation(_ motivation: String) {
        UserDefaults.standard.set(motivation, forKey: userMotivationKey)
    }

    func loadMotivation() -> String? {
        return UserDefaults.standard.string(forKey: userMotivationKey)
    }

    // MARK: - Urge Game Tracking

    func incrementUrgesDefeated(for addictionId: UUID) {
        var addictions = loadAddictions()
        if let index = addictions.firstIndex(where: { $0.id == addictionId }) {
            addictions[index].urgesDefeated += 1
            saveAddictions(addictions)
        }
    }

    func getUrgesDefeated(for addictionId: UUID) -> Int {
        return loadAddictions().first(where: { $0.id == addictionId })?.urgesDefeated ?? 0
    }

    // MARK: - Clear All Data

    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: addictionsKey)
        UserDefaults.standard.removeObject(forKey: unlockedBadgesKey)
        UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
        UserDefaults.standard.removeObject(forKey: lanternBadgeShownKey)
        UserDefaults.standard.removeObject(forKey: hasUsedTrialKey)
        UserDefaults.standard.removeObject(forKey: userMotivationKey)
        UserDefaults.standard.removeObject(forKey: "TrialStartDate")
    }
}

