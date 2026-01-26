import SwiftUI

struct ImprovementGoalsView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedGoals: Set<String>

    private let improvementOptions = [
        "Better mental wellness",
        "Take back control",
        "Better physical health",
        "Stronger relationships",
        "Deeper spiritual connection",
        "Build self-confidence",
        "Boost productivity",
        "Better sleep and energy",
        "Manage legal matters",
        "Explore new hobbies",
        "Financial savings"
    ]

    private var canContinue: Bool {
        !selectedGoals.isEmpty
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Text("What areas would you like to focus on improving?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Choose up to 3")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 48)
                    .padding(.horizontal, 24)

                    // Options list
                    VStack(spacing: 0) {
                        ForEach(improvementOptions, id: \.self) { option in
                            ImprovementOptionRow(
                                title: option,
                                isSelected: selectedGoals.contains(option),
                                onTap: {
                                    toggleSelection(option)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }

            // Continue button fixed at bottom
            VStack {
                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .sobrietyImportance
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

    private func toggleSelection(_ option: String) {
        if selectedGoals.contains(option) {
            selectedGoals.remove(option)
        } else if selectedGoals.count < 3 {
            selectedGoals.insert(option)
        }
    }
}

// MARK: - Option Row Component
struct ImprovementOptionRow: View {
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
            .padding(.horizontal, 20)
            .background(AppTheme.background)
        }
        .buttonStyle(PlainButtonStyle())

        Divider()
            .background(AppTheme.backgroundSecondary)
            .padding(.leading, 20)
    }
}
