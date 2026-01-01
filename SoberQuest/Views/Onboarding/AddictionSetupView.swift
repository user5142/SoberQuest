import SwiftUI

struct AddictionSetupView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedAddictionName: String
    @Binding var lastUsedDate: Date
    @State private var selectedAddiction: String = ""
    @State private var customAddiction: String = ""
    @State private var showCustomInput: Bool = false
    
    let presetAddictions = ["Alcohol", "Weed", "Nicotine", "Porn", "Social Media"]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What are you quitting?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("You can add more later")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Preset options
            VStack(spacing: 12) {
                ForEach(presetAddictions, id: \.self) { addiction in
                    Button(action: {
                        selectedAddiction = addiction
                        selectedAddictionName = addiction
                        showCustomInput = false
                    }) {
                        HStack {
                            Text(addiction)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedAddiction == addiction {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(selectedAddiction == addiction ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                // Custom option
                Button(action: {
                    showCustomInput = true
                    selectedAddiction = "custom"
                }) {
                    HStack {
                        Text("Custom")
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedAddiction == "custom" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(selectedAddiction == "custom" ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                if showCustomInput {
                    TextField("Enter addiction name", text: $customAddiction)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: customAddiction) { newValue in
                            if !newValue.isEmpty {
                                selectedAddictionName = newValue
                            }
                        }
                }
            }
            .padding(.horizontal, 40)
            
            if !selectedAddictionName.isEmpty {
                VStack(spacing: 16) {
                    Text("When did you last use?")
                        .font(.headline)
                    
                    DatePicker("Last used date", selection: $lastUsedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: {
                if !selectedAddictionName.isEmpty {
                    withAnimation {
                        currentStep = .badgePreview
                    }
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAddictionName.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(selectedAddictionName.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

