import SwiftUI

struct WelcomeView: View {
    @Binding var currentStep: OnboardingStep
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo placeholder
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Welcome to SoberQuest")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Text("Track your sobriety journey")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("Unlock fantasy-themed milestone badges as you progress")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    currentStep = .addictionSetup
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

enum OnboardingStep {
    case welcome
    case addictionSetup
    case badgePreview
}

