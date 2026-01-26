import SwiftUI

struct SobrietyImportanceView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedImportance: String?

    private let importanceOptions = [
        ("Critical", "I need to change now"),
        ("Very", "It's a top focus for me"),
        ("Somewhat", "I'd like to improve this"),
        ("Nice to have", "I'm just exploring")
    ]

    private var canContinue: Bool {
        selectedImportance != nil
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .improvementGoals
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
                        Text("How important is sobriety to you right now?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 32)
                            .padding(.horizontal, 24)

                        // Options list
                        VStack(spacing: 0) {
                            ForEach(importanceOptions, id: \.0) { option in
                                SobrietyImportanceOptionRow(
                                    title: option.0,
                                    subtitle: option.1,
                                    isSelected: selectedImportance == option.0,
                                    onTap: {
                                        selectedImportance = option.0
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
struct SobrietyImportanceOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }

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
