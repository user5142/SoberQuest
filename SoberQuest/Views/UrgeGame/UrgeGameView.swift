import SwiftUI

enum GamePhase {
    case breathing
    case monsterSlaying
    case completion
}

struct UrgeGameView: View {
    @Binding var isPresented: Bool
    var addiction: Addiction

    @EnvironmentObject var appState: AppState
    @ObservedObject var dataManager = DataManager.shared

    @State private var gamePhase: GamePhase = .breathing
    @State private var totalUrgesDefeated: Int = 0

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                // Phase-based content
                switch gamePhase {
                case .breathing:
                    BreathingPhaseView {
                        withAnimation {
                            gamePhase = .monsterSlaying
                        }
                    }
                    .transition(.opacity)

                case .monsterSlaying:
                    MonsterSlayingPhaseView {
                        // Increment counter in data
                        dataManager.incrementUrgesDefeated(for: addiction.id)

                        // Update local state for display
                        totalUrgesDefeated = dataManager.getUrgesDefeated(for: addiction.id)

                        // Transition to completion
                        withAnimation {
                            gamePhase = .completion
                        }
                    }
                    .transition(.opacity)

                case .completion:
                    CompletionPhaseView(
                        totalUrgesDefeated: totalUrgesDefeated,
                        onContinue: {
                            // Refresh app state to show updated count
                            if let currentAddiction = dataManager.loadAddictions().first(where: { $0.id == addiction.id }) {
                                appState.setCurrentAddiction(currentAddiction)
                            }
                            isPresented = false
                        }
                    )
                    .transition(.opacity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            totalUrgesDefeated = dataManager.getUrgesDefeated(for: addiction.id)
        }
        .onDisappear {
            // Reset game state for next time
            gamePhase = .breathing
        }
    }
}
