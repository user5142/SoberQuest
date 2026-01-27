import SwiftUI

struct PersonalIdentityView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedIdentity: String?

    private let identityOptions = [
        ("💪", "Making a healthy choice"),
        ("🧠", "Curious about a different lifestyle"),
        ("🙋", "Done feeling this way"),
        ("🎯", "Taking back control"),
        ("❤️", "Doing this for people I care about"),
        ("✨", "Ready for positive change")
    ]

    private var canContinue: Bool {
        selectedIdentity != nil
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .sobrietyImportance
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
                    VStack(spacing: 32) {
                        // Header
                        Text("I see myself as someone who is...")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 32)
                            .padding(.horizontal, 24)

                        // Options list
                        VStack(spacing: 0) {
                            ForEach(identityOptions, id: \.1) { option in
                                PersonalIdentityOptionRow(
                                    emoji: option.0,
                                    title: option.1,
                                    isSelected: selectedIdentity == option.1,
                                    onTap: {
                                        selectedIdentity = option.1
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
                        currentStep = .improvementAreas
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
struct PersonalIdentityOptionRow: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Text(emoji)
                    .font(.system(size: 20))

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
            .padding(.vertical, 20)
            .padding(.horizontal, 0)
            .background(AppTheme.background)
        }
        .buttonStyle(PlainButtonStyle())

        Divider()
            .background(AppTheme.backgroundSecondary)
    }
}
