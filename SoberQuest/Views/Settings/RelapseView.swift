import SwiftUI

struct RelapseView: View {
    let addiction: Addiction
    @Binding var isPresented: Bool
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 28) {
                    // Warning icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.top, 32)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Reset Progress")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("This will reset your streak and start date. All badges will be locked except the starter Lantern badge.")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Stats card
                    VStack(spacing: 0) {
                        InfoRow(label: "Current Streak", value: "\(addiction.currentStreak) days")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .background(AppTheme.divider)
                        
                        InfoRow(label: "Days Sober", value: "\(addiction.daysSober) days")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .background(AppTheme.divider)
                        
                        InfoRow(label: "Unlocked Badges", value: "\(dataManager.loadUnlockedBadges(for: addiction.id).count) badges")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                    .background(AppTheme.backgroundSecondary)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Reset button
                    Button(action: {
                        showConfirmation = true
                    }) {
                        Text("Reset Progress")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.red)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Reset Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .alert("Reset Progress?", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("Your streak will be reset to 0 and the start date will be updated to today. All badges will be locked except the starter Lantern badge.")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func resetProgress() {
        var updatedAddiction = addiction
        updatedAddiction.startDate = Date()
        updatedAddiction.currentStreak = 0

        // Delete all existing badges for this addiction
        dataManager.deleteBadges(for: addiction.id)

        // Unlock only the day 0 Lantern badge
        if let lanternBadge = BadgeService.shared.getLanternBadge() {
            let unlockedBadge = UnlockedBadge(badgeId: lanternBadge.id, addictionId: addiction.id)
            dataManager.saveUnlockedBadge(unlockedBadge)
        }

        dataManager.saveAddiction(updatedAddiction)
        appState.setCurrentAddiction(updatedAddiction)
        isPresented = false
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}
