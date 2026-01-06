import SwiftUI

struct CompletionPhaseView: View {
    var totalUrgesDefeated: Int
    var onContinue: () -> Void

    @State private var celebrationScale: CGFloat = 0.3

    private let encouragingMessages = [
        "You're stronger than the craving!",
        "Every urge resisted is a victory!",
        "You've got this! Keep going!",
        "That's the warrior spirit!",
        "Another step towards freedom!",
        "You're in control!",
        "Proud of your strength!",
        "The urge will pass, and you'll be stronger!"
    ]

    private var randomMessage: String {
        encouragingMessages.randomElement() ?? encouragingMessages[0]
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success icon with animation
            ZStack {
                Circle()
                    .stroke(AppTheme.textPrimary, lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(celebrationScale)
                    .opacity(0.3)

                Image("knight_helmet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .scaleEffect(celebrationScale)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    celebrationScale = 1.0
                }
            }

            // Encouraging messages
            VStack(spacing: 12) {
                Text("Urge Conquered!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(randomMessage)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Stats display
            VStack(spacing: 8) {
                Text("\(totalUrgesDefeated)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(totalUrgesDefeated == 1 ? "urge conquered" : "urges conquered")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(16)

            Spacer()

            // Continue button
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.backgroundSecondary)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }
}
