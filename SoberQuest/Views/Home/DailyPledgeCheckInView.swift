import SwiftUI

enum CheckInType {
    case pledge
    case review

    var title: String {
        switch self {
        case .pledge:
            return "Daily Pledge"
        case .review:
            return "Daily Review"
        }
    }

    var subtitle: String {
        switch self {
        case .pledge:
            return "Start your day with intention"
        case .review:
            return "Reflect on your progress today"
        }
    }

    var buttonText: String {
        switch self {
        case .pledge:
            return "I pledge to stay sober today"
        case .review:
            return "I stayed true to my pledge"
        }
    }

    var icon: String {
        switch self {
        case .pledge:
            return "sunrise.fill"
        case .review:
            return "sunset.fill"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .pledge:
            return "You've made your pledge. Stay strong today!"
        case .review:
            return "Great job reflecting on your day. Keep it up!"
        }
    }
}

struct DailyPledgeCheckInView: View {
    let checkInType: CheckInType
    @Binding var isPresented: Bool
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if showConfirmation {
                // Confirmation state
                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text(checkInType.confirmationMessage)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()

                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.buttonPrimary)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            } else {
                // Main check-in state
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Spacer()

                    // Icon
                    Image(systemName: checkInType.icon)
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "4A90A4"))
                        .padding(.bottom, 24)

                    // Title
                    Text(checkInType.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.bottom, 8)

                    // Subtitle
                    Text(checkInType.subtitle)
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()

                    // Pledge/Review button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showConfirmation = true
                        }
                    }) {
                        Text(checkInType.buttonText)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.buttonPrimary)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)

                    // Skip button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Skip for now")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.vertical, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
