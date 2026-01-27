import SwiftUI

struct OnboardingRecapView: View {
    @Binding var currentStep: OnboardingStep
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var superwallService: SuperwallService

    let addictionName: String
    let lastUsedDate: Date
    let selectedPersonalIdentity: String?
    let selectedMilestone: String?
    let selectedImprovementAreas: Set<String>
    let pledgeSettings: DailyPledgeSettings
    let motivationText: String

    @State private var isLoading = false

    private var startDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: lastUsedDate)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Celebration icon
                        // Text("💯")
                        //   .font(.system(size: 80))
                        //   .padding(.top, 40)

                        // Header
                        VStack(spacing: 12) {
                            Text("Well done, Adventurer!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 40)

                            Text("These are the foundations of your journey:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)

                        // Accomplishments list
                        VStack(spacing: 16) {
                            accomplishmentRow(
                                title: "Named what you're quitting",
                                subtitle: addictionName
                            )

                            accomplishmentRow(
                                title: "Set your start date",
                                subtitle: startDateFormatted
                            )

                            if let identity = selectedPersonalIdentity {
                                accomplishmentRow(
                                    title: "Decided on who you're becoming",
                                    subtitle: identity
                                )
                            }

                            if let milestone = selectedMilestone {
                                accomplishmentRow(
                                    title: "Chose your first milestone",
                                    subtitle: milestone
                                )
                            }

                            if !selectedImprovementAreas.isEmpty {
                                accomplishmentRow(
                                    title: "Identified what you want to improve",
                                    subtitle: selectedImprovementAreas.joined(separator: ", ")
                                )
                            }

                            if !motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                accomplishmentRow(
                                    title: "Defined your motivation",
                                    subtitle: String(motivationText.prefix(50)) + (motivationText.count > 50 ? "..." : "")
                                )
                            }

                            accomplishmentRow(
                                title: "Planned your daily check-ins",
                                subtitle: "\(pledgeSettings.pledgeTimeFormatted) and \(pledgeSettings.reviewTimeFormatted)"
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)

                        Spacer(minLength: 120)
                    }
                }

                // Continue button fixed at bottom
                VStack {
                    Button(action: {
                        continueToPaywall()
                    }) {
                        Text("Let's Do This!")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.buttonPrimary)
                            .cornerRadius(14)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.background.opacity(0), AppTheme.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .offset(y: -40)
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func accomplishmentRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkmark icon
            Image(systemName: "checkmark")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(3)
            }

            Spacer()
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
