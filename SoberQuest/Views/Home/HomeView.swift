import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var superwallService: SuperwallService
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var badgeService = BadgeService.shared
    
    @State private var timeComponents: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) = (0, 0, 0, 0, 0, 0)
    @State private var showAddictionSelector = false
    @State private var showAddAddiction = false
    @State private var showBadgeUnlock = false
    @State private var unlockedBadge: BadgeDefinition?
    @State private var showBadgeCollection = false
    @State private var showSharePreview = false
    @State private var sharePreviewBadge: BadgeDefinition?
    @State private var showLogUrge = false
    @State private var showResetConfirmation = false
    @State private var showSettings = false
    @State private var showEditMotivation = false
    @State private var showEditDate = false
    @State private var showUrgeGame = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if !superwallService.hasProAccess {
                PaywallRequiredView()
            } else if let addiction = appState.currentAddiction {
                mainContentView(addiction: addiction)
            } else {
                emptyStateView
            }
        }
        .background(AppTheme.background)
        .onAppear {
            updateTimer()
            appState.refreshAddiction()
            checkForInitialBadge()
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
        .sheet(isPresented: $showAddictionSelector) {
            AddictionSelectorView(isPresented: $showAddictionSelector)
        }
        .sheet(isPresented: $showAddAddiction) {
            AddAddictionView(isPresented: $showAddAddiction)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showBadgeUnlock) {
            if let badge = unlockedBadge, let addiction = appState.currentAddiction {
                BadgeUnlockView(
                    badge: badge,
                    addiction: addiction,
                    isPresented: $showBadgeUnlock
                )
            }
        }
        .sheet(isPresented: $showBadgeCollection) {
            if let addiction = appState.currentAddiction {
                BadgeCollectionView(addiction: addiction, isPresented: $showBadgeCollection)
            }
        }
        .fullScreenCover(isPresented: $showSharePreview) {
            if let badge = sharePreviewBadge, let addiction = appState.currentAddiction {
                SharePreviewView(
                    badge: badge,
                    addiction: addiction,
                    isPresented: $showSharePreview
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView()
            }
        }
        .sheet(isPresented: $showEditMotivation) {
            if let addiction = appState.currentAddiction {
                EditMotivationView(isPresented: $showEditMotivation, addiction: addiction)
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showEditDate) {
            if let addiction = appState.currentAddiction {
                EditDateView(isPresented: $showEditDate, addiction: addiction)
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showUrgeGame) {
            if let addiction = appState.currentAddiction {
                UrgeGameView(isPresented: $showUrgeGame, addiction: addiction)
                    .environmentObject(appState)
            }
        }
    }
    
    @ViewBuilder
    private func mainContentView(addiction: Addiction) -> some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Section with Character
                    heroSection(addiction: addiction)

                    // "Why I'm doing this" Section
                    motivationSection(addiction: addiction)
                        .padding(.top, 16)

                    // Urge Game Section
                    urgeGameSection(addiction: addiction)
                }
            }
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image("badge_day3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)

                VStack(spacing: 8) {
                    Text("No Trackers Yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Start your journey by adding\na tracker for what you want to quit.")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    showAddAddiction = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Add Tracker")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.buttonPrimaryText)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(AppTheme.buttonPrimary)
                    .cornerRadius(12)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Hero Section
    @ViewBuilder
    private func heroSection(addiction: Addiction) -> some View {
        ZStack {
            // Solid background for hero area
            AppTheme.backgroundSecondary
            
            VStack(spacing: 20) {
                // Settings button (top left), Addiction switcher (center), Badge collection (top right)
                HStack {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Spacer()

                    // Addiction Switcher - tappable indicator showing current addiction
                    Button(action: {
                        showAddictionSelector = true
                    }) {
                        HStack(spacing: 6) {
                            Text(addiction.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.cardBackgroundDark)
                        .cornerRadius(20)
                    }

                    Spacer()

                    Button(action: {
                        showBadgeCollection = true
                    }) {
                        Image("diamond")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Character/Badge Image
                if let highestBadge = getHighestUnlockedBadge(for: addiction) {
                    BadgeImageView(
                        imageAssetName: highestBadge.imageAssetName,
                        milestoneDays: highestBadge.milestoneDays,
                        size: 220
                    )
                } else {
                    // Default character placeholder
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.cardBackgroundDark)
                        .frame(width: 220, height: 220)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textMuted)
                        )
                }
                
                // "You've been X-free for:" text
                Text("You've been \(addiction.name.lowercased())-free for:")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 8)
                
                // Large Days Counter
                Text(formatDaysDisplay())
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .tracking(-2)
                
                // Timer Pill
                timerPill
                    .padding(.top, -8)
                
                // Action Buttons Row
                actionButtonsRow(addiction: addiction)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Timer Pill
    @ViewBuilder
    private var timerPill: some View {
        let display = formatTimerDisplay()
        if !display.isEmpty {
            Text(display)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppTheme.timerPillBackground)
                .cornerRadius(24)
        }
    }
    
    // MARK: - Action Buttons Row
    @ViewBuilder
    private func actionButtonsRow(addiction: Addiction) -> some View {
        HStack(spacing: 32) {
            // Reset Button
            actionButton(
                icon: "arrow.counterclockwise",
                label: "Reset"
            ) {
                showResetConfirmation = true
            }

            // Edit Date Button
            actionButton(
                icon: "calendar",
                label: "Edit"
            ) {
                showEditDate = true
            }

            // Share Button
            actionButton(
                icon: "square.and.arrow.up",
                label: "Share"
            ) {
                generateShareCard(for: addiction)
            }
        }
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetProgress(for: addiction)
            }
        } message: {
            Text("Your streak will be reset to 0 and the start date will be updated to today. Your unlocked badges will be preserved.")
        }
    }
    
    @ViewBuilder
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 48, height: 48)

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Motivation Section
    @ViewBuilder
    private func motivationSection(addiction: Addiction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 8) {
                Text("Why I'm doing this")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)

                Circle()
                    .fill(AppTheme.textMuted)
                    .frame(width: 6, height: 6)

                Spacer()

                Button(action: {
                    showEditMotivation = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)

            // Motivation Card
            Button(action: {
                showEditMotivation = true
            }) {
                VStack(spacing: 0) {
                    Text(getMotivationQuote(for: addiction))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 28)
                }
                .frame(maxWidth: .infinity)
                .background(AppTheme.backgroundSecondary)
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 32)
    }

    // MARK: - Urge Game Section
    @ViewBuilder
    private func urgeGameSection(addiction: Addiction) -> some View {
        Button(action: {
            showUrgeGame = true
        }) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.2),
                        Color(red: 0.1, green: 0.08, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Content
                HStack(spacing: 16) {
                    // Monster image
                    ZStack {
                        // Glow effect behind monster
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .blur(radius: 8)

                        Image("urge_monster")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }

                    // Text content
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("Slay Urge Monsters")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Image(systemName: "bolt.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }

                        if addiction.urgesDefeated > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.orange)
                                Text("\(addiction.urgesDefeated) defeated")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        } else {
                            Text("Feeling an urge? Fight back!")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }

                    Spacer()

                    // Play button style arrow
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 36, height: 36)

                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }

    // MARK: - Helper Functions
    
    private func updateTimer() {
        if let addiction = appState.currentAddiction {
            timeComponents = addiction.timeComponents
        }
    }
    
    private func formatDaysDisplay() -> String {
        // Hierarchical display: years > months > days > hours > minutes > seconds
        if timeComponents.years >= 1 {
            if timeComponents.years == 1 {
                return "1 year"
            } else {
                return "\(timeComponents.years) years"
            }
        } else if timeComponents.months >= 1 {
            if timeComponents.months == 1 {
                return "1 month"
            } else {
                return "\(timeComponents.months) months"
            }
        } else if timeComponents.days >= 1 {
            if timeComponents.days == 1 {
                return "1 day"
            } else {
                return "\(timeComponents.days) days"
            }
        } else if timeComponents.hours >= 1 {
            if timeComponents.hours == 1 {
                return "1 hour"
            } else {
                return "\(timeComponents.hours) hours"
            }
        } else if timeComponents.minutes >= 1 {
            if timeComponents.minutes == 1 {
                return "1 minute"
            } else {
                return "\(timeComponents.minutes) mins"
            }
        } else {
            if timeComponents.seconds == 1 {
                return "1 second"
            } else {
                return "\(timeComponents.seconds) secs"
            }
        }
    }

    private func formatTimerDisplay() -> String {
        // Secondary display based on primary tier
        if timeComponents.years >= 1 {
            // Primary is years, show months/days/hours in pill
            var parts: [String] = []
            if timeComponents.months > 0 {
                parts.append("\(timeComponents.months)mo")
            }
            if timeComponents.days > 0 {
                parts.append("\(timeComponents.days)d")
            }
            parts.append(String(format: "%dhr %02dm", timeComponents.hours, timeComponents.minutes))
            return parts.joined(separator: " ")
        } else if timeComponents.months >= 1 {
            // Primary is months, show days/hours/minutes in pill
            var parts: [String] = []
            if timeComponents.days > 0 {
                parts.append("\(timeComponents.days)d")
            }
            parts.append(String(format: "%dhr %02dm", timeComponents.hours, timeComponents.minutes))
            return parts.joined(separator: " ")
        } else if timeComponents.days >= 1 {
            // Primary is days, show hours/minutes/seconds in pill
            return String(format: "%dhr %02dm %02ds", timeComponents.hours, timeComponents.minutes, timeComponents.seconds)
        } else if timeComponents.hours >= 1 {
            // Primary is hours, show minutes/seconds in pill
            return String(format: "%02dm %02ds", timeComponents.minutes, timeComponents.seconds)
        } else if timeComponents.minutes >= 1 {
            // Primary is minutes, show seconds in pill
            return String(format: "%02ds", timeComponents.seconds)
        } else {
            // Primary is seconds, show empty or minimal pill
            return ""
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
    
    private func resetProgress(for addiction: Addiction) {
        var updatedAddiction = addiction
        updatedAddiction.startDate = Date()
        updatedAddiction.currentStreak = 0
        
        dataManager.saveAddiction(updatedAddiction)
        appState.setCurrentAddiction(updatedAddiction)
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
            sharePreviewBadge = highestBadge
            showSharePreview = true
        }
    }
    
    private func checkForInitialBadge() {
        guard !dataManager.isInitialBadgeShown(),
              let addiction = appState.currentAddiction else {
            return
        }

        let unlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        if let highestBadge = badgeService.getHighestUnlockedBadge(for: addiction.id, unlockedBadges: unlockedBadges) {
            dataManager.setInitialBadgeShown(true)
            self.unlockedBadge = highestBadge
            showBadgeUnlock = true
        }
    }
    
    private func getMotivationQuote(for addiction: Addiction) -> String {
        if let motivation = addiction.motivation, !motivation.isEmpty {
            return motivation
        }
        return "Tap to add your motivation..."
    }
}

// MARK: - Edit Motivation View
struct EditMotivationView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var appState: AppState
    let addiction: Addiction
    @State private var motivationText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your motivation")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            TextEditor(text: $motivationText)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 150)
                                .padding(16)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(16)
                                .focused($isTextFieldFocused)
                                .overlay(
                                    Group {
                                        if motivationText.isEmpty {
                                            Text("e.g., To be healthier for my family, to feel more present, to save money...")
                                                .font(.system(size: 16))
                                                .foregroundColor(AppTheme.textMuted)
                                                .padding(20)
                                                .allowsHitTesting(false)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        Spacer()
                    }
                }
                .onTapGesture {
                    isTextFieldFocused = false
                }
            }
            .navigationTitle("Why I'm doing this")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let trimmed = motivationText.trimmingCharacters(in: .whitespacesAndNewlines)
                        var updatedAddiction = addiction
                        updatedAddiction.motivation = trimmed.isEmpty ? nil : trimmed
                        DataManager.shared.saveAddiction(updatedAddiction)
                        appState.setCurrentAddiction(updatedAddiction)
                        isPresented = false
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            motivationText = addiction.motivation ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
}

struct PaywallRequiredView: View {
    @EnvironmentObject private var superwallService: SuperwallService
    @State private var isLoading = false
    @State private var hasAutoPresented = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Pro Access Required")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Subscribe to unlock all features")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)

                Button(action: {
                    presentPaywall()
                }) {
                    Group {
                        if isLoading {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.buttonPrimaryText))
                                Text("Loading...")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        } else {
                            Text("Subscribe")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(AppTheme.buttonPrimaryText)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(AppTheme.buttonPrimary)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.top, 8)
            }
        }
        .onAppear {
            // Auto-present winback paywall immediately for cancelled users
            // Guard against multiple presentations (e.g., tab switching)
            guard !hasAutoPresented && !isLoading else { return }
            hasAutoPresented = true
            presentPaywall()
        }
    }

    private func presentPaywall() {
        guard !isLoading else { return }
        isLoading = true
        superwallService.presentOnboardingPaywall { result in
            isLoading = false
            // The subscription status will be updated via Combine observation
            // hasActiveSubscription change will automatically switch away from this view
        }
    }
}
