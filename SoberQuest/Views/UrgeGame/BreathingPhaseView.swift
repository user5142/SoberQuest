import SwiftUI

struct BreathingPhaseView: View {
    var onComplete: () -> Void

    @State private var pulseScale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    @State private var canContinue = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Breathing circles animation
            ZStack {
                // Outer ring (slow pulse)
                Circle()
                    .stroke(AppTheme.textSecondary, lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseScale)
                    .opacity(opacity * 0.4)

                // Middle ring
                Circle()
                    .stroke(AppTheme.textPrimary, lineWidth: 3)
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseScale)
                    .opacity(opacity * 0.7)

                // Inner circle (solid)
                Circle()
                    .fill(AppTheme.backgroundSecondary)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)
                    .opacity(opacity)

                // Center icon
                Image("calm_wave_2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .accessibilityLabel("Breathing circle")
            .accessibilityHint("Tap to continue to the next phase")

            // Instructions
            VStack(spacing: 12) {
                Text("Take a deep breath")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(canContinue ? "Tap when you're ready" : "Breathe in... and out...")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                    .opacity(canContinue ? 1.0 : 0.7)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .contentShape(Rectangle())
        .onTapGesture {
            if canContinue {
                onComplete()
            }
        }
        .onAppear {
            // Start pulsing animation
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.3
                opacity = 1.0
            }

            // Enable tap after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    canContinue = true
                }
            }
        }
    }
}
