import SwiftUI

struct NotificationPermissionView: View {
    @Binding var currentStep: OnboardingStep
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var superwallService: SuperwallService
    let addictionName: String
    let lastUsedDate: Date
    let motivationText: String

    @State private var isLoading = false
    @State private var permissionRequested = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Icon
                Image("ancient_bell")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)

                // Header
                VStack(spacing: 12) {
                    Text("Stay on Track")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Get helpful reminders and milestone celebrations")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Benefits
                VStack(spacing: 16) {
                    benefitRow(icon: "calendar.badge.clock", text: "Daily motivation")
                    benefitRow(icon: "trophy.fill", text: "Milestone achievements")
                    benefitRow(icon: "heart.fill", text: "Encouragement when you need it")
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)

                Spacer()

                // Enable Notifications button
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text("Enable Notifications")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .disabled(isLoading)
                .padding(.horizontal, 32)

                // Skip button
                Button(action: {
                    continueToPaywall()
                }) {
                    Text("Skip for Now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 12)
                }
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
    }

    private func requestNotificationPermission() {
        permissionRequested = true
        NotificationService.shared.requestPermission { granted in
            print("NotificationPermissionView: Permission \(granted ? "granted" : "denied")")
            continueToPaywall()
        }
    }

    private func continueToPaywall() {
        // Save addiction data with motivation
        let trimmedMotivation = motivationText.trimmingCharacters(in: .whitespacesAndNewlines)
        // If user selected "today", use current time so timer starts from now
        let startDate = Calendar.current.isDateInToday(lastUsedDate) ? Date() : lastUsedDate
        let addiction = Addiction(
            name: addictionName,
            startDate: startDate,
            currentStreak: 0,
            isActive: true,
            motivation: trimmedMotivation.isEmpty ? nil : trimmedMotivation
        )
        DataManager.shared.saveAddiction(addiction)
        appState.setCurrentAddiction(addiction)

        // Grant all badges earned based on days sober
        let daysSober = addiction.daysSober
        for badge in BadgeDefinition.defaultBadges {
            if daysSober >= badge.milestoneDays {
                let unlockedBadge = UnlockedBadge(badgeId: badge.id, addictionId: addiction.id)
                DataManager.shared.saveUnlockedBadge(unlockedBadge)
            }
        }

        // Present Superwall paywall directly
        isLoading = true
        superwallService.presentOnboardingPaywall { result in
            isLoading = false

            switch result {
            case .purchased, .restored:
                appState.hasProAccess = true
                appState.completeOnboarding()
            case .declined:
                appState.completeOnboarding()
            case .skipped:
                appState.hasProAccess = superwallService.hasActiveSubscription
                appState.completeOnboarding()
            }
        }
    }
}
