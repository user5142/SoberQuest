import SwiftUI

struct RelapseView: View {
    let addiction: Addiction
    @Binding var isPresented: Bool
    @StateObject private var appState = AppState.shared
    @StateObject private var dataManager = DataManager.shared
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Reset Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("This will reset your streak and start date, but your unlocked badges will remain.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(label: "Current Streak", value: "\(addiction.currentStreak) days")
                    InfoRow(label: "Days Sober", value: "\(addiction.daysSober) days")
                    InfoRow(label: "Unlocked Badges", value: "\(dataManager.loadUnlockedBadges(for: addiction.id).count) badges")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    showConfirmation = true
                }) {
                    Text("Reset Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Reset Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Reset Progress?", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("Your streak will be reset to 0 and the start date will be updated to today. Your unlocked badges will be preserved.")
            }
        }
    }
    
    private func resetProgress() {
        var updatedAddiction = addiction
        updatedAddiction.startDate = Date()
        updatedAddiction.currentStreak = 0
        
        dataManager.saveAddiction(updatedAddiction)
        appState.setCurrentAddiction(updatedAddiction)
        isPresented = false
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

