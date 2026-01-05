import SwiftUI

struct EditDateView: View {
    @Binding var isPresented: Bool
    let addiction: Addiction

    @EnvironmentObject private var appState: AppState
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var badgeService = BadgeService.shared

    @State private var selectedDate: Date
    @State private var showConfirmation = false

    init(isPresented: Binding<Bool>, addiction: Addiction) {
        self._isPresented = isPresented
        self.addiction = addiction
        self._selectedDate = State(initialValue: addiction.startDate)
    }

    private var hasDateChanged: Bool {
        !Calendar.current.isDate(selectedDate, inSameDayAs: addiction.startDate)
    }

    private var newDaysSober: Int {
        Calendar.current.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0
    }

    private var badgesWillBeLocked: Bool {
        let currentUnlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        let allBadges = BadgeDefinition.defaultBadges

        // Check if any currently unlocked badge will be locked
        for unlockedBadge in currentUnlockedBadges {
            if let badge = allBadges.first(where: { $0.id == unlockedBadge.badgeId }) {
                if newDaysSober < badge.milestoneDays {
                    return true
                }
            }
        }
        return false
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Change Start Date")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Adjust when you started your \(addiction.name.lowercased())-free journey")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        // Current vs New Stats
                        if hasDateChanged {
                            statsComparison
                                .padding(.horizontal, 24)
                        }

                        // Date picker
                        VStack(spacing: 16) {
                            DatePicker(
                                "Start date",
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .accentColor(AppTheme.textPrimary)
                            .colorScheme(.dark)
                            .padding()
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)

                        // Warning if badges will be locked
                        if hasDateChanged && badgesWillBeLocked {
                            warningBanner
                                .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 100)
                    }
                }

                // Save button fixed at bottom
                VStack {
                    Spacer()

                    Button(action: {
                        if badgesWillBeLocked {
                            showConfirmation = true
                        } else {
                            saveDate()
                        }
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(hasDateChanged ? AppTheme.buttonPrimaryText : AppTheme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(hasDateChanged ? AppTheme.buttonPrimary : AppTheme.backgroundSecondary)
                            .cornerRadius(14)
                    }
                    .disabled(!hasDateChanged)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
            .alert("Some Badges Will Be Locked", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Continue", role: .destructive) {
                    saveDate()
                }
            } message: {
                Text("Moving the date forward will lock badges you haven't reached yet. You can unlock them again as you progress.")
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Stats Comparison
    @ViewBuilder
    private var statsComparison: some View {
        HStack(spacing: 16) {
            // Current
            VStack(spacing: 8) {
                Text("Current")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(addiction.daysSober)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textMuted)
                Text("days")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(12)

            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            // New
            VStack(spacing: 8) {
                Text("New")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(newDaysSober)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text("days")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(12)
        }
    }

    // MARK: - Warning Banner
    @ViewBuilder
    private var warningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)

            Text("Some badges will be locked because you haven't reached those milestones with the new date.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Save Logic
    private func saveDate() {
        var updatedAddiction = addiction
        updatedAddiction.startDate = selectedDate

        // Save the updated addiction
        dataManager.saveAddiction(updatedAddiction)
        appState.setCurrentAddiction(updatedAddiction)

        // Re-evaluate badges based on new date
        syncBadgesForNewDate(addiction: updatedAddiction)

        isPresented = false
    }

    private func syncBadgesForNewDate(addiction: Addiction) {
        let currentUnlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        let allBadges = BadgeDefinition.defaultBadges
        let daysSober = addiction.daysSober

        // 1. Lock badges that exceed new days sober
        for unlockedBadge in currentUnlockedBadges {
            if let badge = allBadges.first(where: { $0.id == unlockedBadge.badgeId }) {
                if daysSober < badge.milestoneDays {
                    // Remove this badge
                    dataManager.removeBadge(badgeId: badge.id, for: addiction.id)
                }
            }
        }

        // 2. Unlock badges that should now be unlocked
        let updatedUnlockedBadges = dataManager.loadUnlockedBadges(for: addiction.id)
        let unlockedBadgeIds = Set(updatedUnlockedBadges.map { $0.badgeId })

        for badge in allBadges {
            if daysSober >= badge.milestoneDays && !unlockedBadgeIds.contains(badge.id) {
                let newBadge = UnlockedBadge(badgeId: badge.id, addictionId: addiction.id)
                dataManager.saveUnlockedBadge(newBadge)
            }
        }
    }
}
