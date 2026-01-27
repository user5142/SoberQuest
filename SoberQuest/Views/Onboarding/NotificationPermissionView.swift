import SwiftUI

struct NotificationPermissionView: View {
    @Binding var currentStep: OnboardingStep
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
                    benefitRow(icon: "calendar.badge.clock", text: "Daily pledge reminders")
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
                    continueToRecap()
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
            if granted {
                // Schedule daily pledge notifications
                NotificationService.shared.scheduleDailyPledgeNotificationsIfPermitted()
            }
            continueToRecap()
        }
    }

    private func continueToRecap() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .onboardingRecap
        }
    }
}
