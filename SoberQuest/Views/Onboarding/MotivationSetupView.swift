import SwiftUI

struct MotivationSetupView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var motivationText: String
    let addictionName: String

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Why are you doing this?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Your motivation will keep you going")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 48)

                    // Text input area
                    VStack(spacing: 16) {
                        TextEditor(text: $motivationText)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 150)
                            .padding(16)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(16)
                            .focused($isTextFieldFocused)
                            .overlay(
                                Group {
                                    if motivationText.isEmpty {
                                        Text("e.g., To be healthier for my family, to feel more present, to save money...")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppTheme.textMuted)
                                            .padding(20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }

            // Continue button fixed at bottom
            VStack {
                Spacer()

                Button(action: {
                    isTextFieldFocused = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .dailyPledgeTimes
                    }
                }) {
                    Text(motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Skip" : "Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
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
