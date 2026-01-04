import SwiftUI

struct AddictionSelectorView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showAddAddiction = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(dataManager.loadAddictions()) { addiction in
                            Button(action: {
                                appState.setCurrentAddiction(addiction)
                                isPresented = false
                            }) {
                                HStack(spacing: 16) {
                                    // Days counter circle
                                    ZStack {
                                        Circle()
                                            .fill(addiction.isActive ? AppTheme.cardBackgroundDark : AppTheme.backgroundSecondary)
                                            .frame(width: 50, height: 50)

                                        Text("\(addiction.daysSober)")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(addiction.isActive ? AppTheme.textPrimary : AppTheme.textSecondary)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(addiction.name)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)

                                        Text("\(addiction.daysSober) days sober")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }

                                    Spacer()

                                    if addiction.isActive {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(addiction.isActive ? AppTheme.cardBackgroundDark : AppTheme.backgroundSecondary)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(addiction.isActive ? AppTheme.divider : Color.clear, lineWidth: 1)
                                )
                            }
                        }

                        // Add New Tracker Button
                        Button(action: {
                            showAddAddiction = true
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.backgroundSecondary)
                                        .frame(width: 50, height: 50)

                                    Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)
                                }

                                Text("Add New Tracker")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.divider, lineWidth: 1)
                            )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Select Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddAddiction) {
                AddAddictionView(isPresented: $showAddAddiction)
                    .environmentObject(appState)
            }
        }
        .preferredColorScheme(.dark)
    }
}
