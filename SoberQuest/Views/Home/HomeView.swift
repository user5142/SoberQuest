import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var superwallService: SuperwallService
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var badgeService = BadgeService.shared
    
    @State private var timeComponents: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) = (0, 0, 0, 0, 0, 0)
    @State private var showAddictionSelector = false
    @State private var showBadgeUnlock = false
    @State private var unlockedBadge: BadgeDefinition?
    @State private var showBadgeCollection = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if !superwallService.hasProAccess {
                PaywallRequiredView()
            } else if let addiction = appState.currentAddiction {
                mainContentView(addiction: addiction)
            } else {
                Text("No addiction selected")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            updateTimer()
            appState.refreshAddiction()
            checkForPhoenixRisingBadge()
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
        .sheet(isPresented: $showAddictionSelector) {
            AddictionSelectorView(isPresented: $showAddictionSelector)
        }
        .sheet(isPresented: $showBadgeUnlock) {
            if let badge = unlockedBadge, let addiction = appState.currentAddiction {
                BadgeUnlockView(
                    badge: badge,
                    addiction: addiction,
                    isPresented: $showBadgeUnlock,
                    onShare: { shareImage in
                        self.shareImage = shareImage
                        self.showShareSheet = true
                    }
                )
            }
        }
        .sheet(isPresented: $showBadgeCollection) {
            if let addiction = appState.currentAddiction {
                BadgeCollectionView(addiction: addiction, isPresented: $showBadgeCollection)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    @ViewBuilder
    private func mainContentView(addiction: Addiction) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header with addiction name and share button
                HStack {
                    Button(action: {
                        showAddictionSelector = true
                    }) {
                        HStack {
                            Text(addiction.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Share current progress
                        generateShareCard(for: addiction)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Highest unlocked badge (most prominent)
                if let highestBadge = getHighestUnlockedBadge(for: addiction) {
                    VStack(spacing: 8) {
                        Text("Latest Achievement")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        BadgeImageView(imageAssetName: highestBadge.imageAssetName, milestoneDays: highestBadge.milestoneDays, size: 120)
                        
                        Text(highestBadge.name)
                            .font(.headline)
                        
                        Text(highestBadge.milestoneDisplayText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Sobriety timer
                VStack(spacing: 12) {
                    Text(formatTimeComponents())
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("sober from \(addiction.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                
                // Daily check-in button
                Button(action: {
                    handleDailyCheckIn(for: addiction)
                }) {
                    Text("I stayed sober today")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Next milestone preview
                if let nextBadge = getNextMilestoneBadge(for: addiction) {
                    VStack(spacing: 12) {
                        Text("Next Milestone")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            BadgeImageView(imageAssetName: nextBadge.imageAssetName, milestoneDays: nextBadge.milestoneDays, size: 60)
                                .opacity(0.5)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextBadge.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("\(nextBadge.milestoneDays) days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if nextBadge.milestoneDays > addiction.daysSober {
                                    Text("\(nextBadge.milestoneDays - addiction.daysSober) days to go")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                
                // Badge collection button
                Button(action: {
                    showBadgeCollection = true
                }) {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("View All Badges")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .padding(.vertical)
        }
    }
    
    private func updateTimer() {
        if let addiction = appState.currentAddiction {
            timeComponents = addiction.timeComponents
        }
    }
    
    private func formatTimeComponents() -> String {
        var parts: [String] = []
        
        if timeComponents.years > 0 {
            parts.append("\(timeComponents.years) year\(timeComponents.years > 1 ? "s" : "")")
        }
        if timeComponents.months > 0 {
            parts.append("\(timeComponents.months) month\(timeComponents.months > 1 ? "s" : "")")
        }
        if timeComponents.days > 0 {
            parts.append("\(timeComponents.days) day\(timeComponents.days > 1 ? "s" : "")")
        }
        
        // Always show hours:minutes:seconds as a ticking clock
        let timeString = String(format: "%02d:%02d:%02d", timeComponents.hours, timeComponents.minutes, timeComponents.seconds)
        
        if parts.isEmpty {
            return timeString
        } else {
            return parts.joined(separator: " ") + "\n" + timeString
        }
    }
    
    private func handleDailyCheckIn(for addiction: Addiction) {
        // Update streak
        dataManager.updateStreak(for: addiction.id)
        
        // Check for badge unlock
        let unlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        if let newBadge = badgeService.checkForNewBadges(addiction: addiction, unlockedBadges: unlockedBadges) {
            // Unlock the badge
            let unlockedBadge = UnlockedBadge(badgeId: newBadge.id, addictionId: addiction.id)
            dataManager.saveUnlockedBadge(unlockedBadge)
            
            // Show unlock view
            self.unlockedBadge = newBadge
            showBadgeUnlock = true
        }
        
        // Refresh addiction
        appState.refreshAddiction()
    }
    
    private func getHighestUnlockedBadge(for addiction: Addiction) -> BadgeDefinition? {
        let unlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        return badgeService.getHighestUnlockedBadge(for: addiction.id, unlockedBadges: unlockedBadges)
    }
    
    private func getNextMilestoneBadge(for addiction: Addiction) -> BadgeDefinition? {
        let unlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        return badgeService.getNextMilestoneBadge(for: addiction, unlockedBadges: unlockedBadges)
    }
    
    private func generateShareCard(for addiction: Addiction) {
        if let highestBadge = getHighestUnlockedBadge(for: addiction) {
            let shareCard = ShareCardView(badge: highestBadge, addiction: addiction, daysSober: addiction.daysSober)
            shareImage = shareCard.asUIImage()
            showShareSheet = true
        }
    }
    
    private func checkForPhoenixRisingBadge() {
        // Show Phoenix Rising badge unlock if it hasn't been shown yet
        guard !dataManager.isPhoenixRisingBadgeShown(),
              let addiction = appState.currentAddiction,
              let phoenixBadge = badgeService.getPhoenixRisingBadge() else {
            return
        }
        
        // Verify the badge is unlocked
        let unlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        if badgeService.isBadgeUnlocked(badgeId: phoenixBadge.id, for: addiction.id, unlockedBadges: unlockedBadges) {
            // Mark as shown and display the unlock view
            dataManager.setPhoenixRisingBadgeShown(true)
            self.unlockedBadge = phoenixBadge
            showBadgeUnlock = true
        }
    }
}

struct PaywallRequiredView: View {
    @EnvironmentObject private var superwallService: SuperwallService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pro Access Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Subscribe to unlock all features")
                .foregroundColor(.secondary)
            
            Button(action: {
                superwallService.presentPaywall()
            }) {
                Text("Subscribe")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }
}

