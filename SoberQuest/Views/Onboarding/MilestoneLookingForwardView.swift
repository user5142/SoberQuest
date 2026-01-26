import SwiftUI

struct MilestoneLookingForwardView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedMilestone: String?

    private let milestoneOptions = [
        "24 hours complete",
        "Weekend conquered",
        "Reaching one week",
        "First month milestone",
        "Saying 'no' when tempted",
        "First positive change",
        "Breaking your previous record",
        "First morning waking up proud",
        "Other"
    ]

    private var canContinue: Bool {
        selectedMilestone != nil
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .improvementAreas
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(12)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Which milestone are you most looking forward to?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, 24)

                        // Options list
                        VStack(spacing: 0) {
                            ForEach(milestoneOptions, id: \.self) { option in
                                MilestoneOptionRow(
                                    title: option,
                                    isSelected: selectedMilestone == option,
                                    onTap: {
                                        selectedMilestone = option
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 120)
                    }
                }
            }

            // Next button fixed at bottom
            VStack {
                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .motivationSetup
                    }
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(canContinue ? AppTheme.buttonPrimary : AppTheme.buttonPrimary.opacity(0.5))
                        .cornerRadius(14)
                }
                .disabled(!canContinue)
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
        .preferredColorScheme(.dark)
    }
}

// MARK: - Option Row Component
struct MilestoneOptionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimary)
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 0)
            .background(AppTheme.background)
        }
        .buttonStyle(PlainButtonStyle())

        Divider()
            .background(AppTheme.backgroundSecondary)
    }
}
