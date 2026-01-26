import SwiftUI

struct ImprovementAreasView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedAreas: Set<String>

    private let improvementOptions = [
        "Motivation",
        "Self-awareness",
        "Stress management",
        "Support network",
        "Handling triggers",
        "Self-care habits",
        "Difficult emotions",
        "Clearer boundaries",
        "Healthy alternatives",
        "Social pressure"
    ]

    private var canContinue: Bool {
        !selectedAreas.isEmpty
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .personalIdentity
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
                            Text("Where do you have the most room for improvement?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Choose up to 3")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, 24)

                        // Options list
                        VStack(spacing: 0) {
                            ForEach(improvementOptions, id: \.self) { option in
                                ImprovementAreaOptionRow(
                                    title: option,
                                    isSelected: selectedAreas.contains(option),
                                    onTap: {
                                        toggleSelection(option)
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

    private func toggleSelection(_ option: String) {
        if selectedAreas.contains(option) {
            selectedAreas.remove(option)
        } else if selectedAreas.count < 3 {
            selectedAreas.insert(option)
        }
    }
}

// MARK: - Option Row Component
struct ImprovementAreaOptionRow: View {
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
