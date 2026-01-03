import SwiftUI

struct AddictionSetupView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedAddictionName: String
    @State private var selectedAddiction: String = ""
    @State private var customAddiction: String = ""
    @State private var showCustomInput: Bool = false
    
    let presetAddictions = ["Alcohol", "Weed", "Nicotine", "Porn", "Social Media"]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Text("What are you quitting?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("You can add more later")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 48)
                    
                    // Preset options
                    VStack(spacing: 12) {
                        ForEach(presetAddictions, id: \.self) { addiction in
                            addictionOption(addiction, isCustom: false)
                        }
                        
                        // Custom option
                        addictionOption("Custom", isCustom: true)
                        
                        // Custom text input
                        if showCustomInput {
                            TextField("Enter addiction name", text: $customAddiction)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding()
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.divider, lineWidth: 1)
                                )
                                .onChange(of: customAddiction) { newValue in
                                    if !newValue.isEmpty {
                                        selectedAddictionName = newValue
                                    }
                                }
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
                    if !selectedAddictionName.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .dateSelection
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(selectedAddictionName.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(selectedAddictionName.isEmpty ? AppTheme.backgroundSecondary : AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .disabled(selectedAddictionName.isEmpty)
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
    
    @ViewBuilder
    private func addictionOption(_ name: String, isCustom: Bool) -> some View {
        let isSelected = isCustom ? selectedAddiction == "custom" : selectedAddiction == name

        Button(action: {
            if isCustom {
                selectedAddiction = "custom"
                showCustomInput = true
                if !customAddiction.isEmpty {
                    selectedAddictionName = customAddiction
                } else {
                    selectedAddictionName = ""
                }
            } else {
                selectedAddiction = name
                selectedAddictionName = name
                showCustomInput = false
            }
        }) {
            HStack {
                Text(name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.textPrimary)
                } else {
                    Circle()
                        .stroke(AppTheme.textMuted, lineWidth: 2)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppTheme.cardBackgroundDark : AppTheme.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppTheme.divider : Color.clear, lineWidth: 1)
            )
        }
    }
}
