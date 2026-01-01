import SwiftUI

@main
struct SoberQuestApp: App {
    // Use ObservedObject for singletons that are already instantiated
    @ObservedObject private var appState = AppState.shared
    
    init() {
        // Ensure Superwall is configured at app launch
        // Accessing .shared triggers the private init() which calls configureSuperwall()
        _ = SuperwallService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isOnboardingCompleted {
                    MainTabView()
                } else {
                    OnboardingFlow()
                }
            }
            .environmentObject(appState)
            .environmentObject(SuperwallService.shared)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSettings = false
    @State private var showRelapseView = false
    
    var body: some View {
        NavigationView {
            HomeView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(isPresented: $showSettings, showRelapseView: $showRelapseView)
                }
                .sheet(isPresented: $showRelapseView) {
                    if let addiction = appState.currentAddiction {
                        RelapseView(addiction: addiction, isPresented: $showRelapseView)
                    }
                }
        }
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @Binding var showRelapseView: Bool
    @EnvironmentObject private var appState: AppState
    @State private var showClearSessionConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let addiction = appState.currentAddiction {
                        Button(action: {
                            showRelapseView = true
                        }) {
                            HStack {
                                Text("Reset Progress")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Progress")
                }
                
                #if DEBUG
                Section {
                    Button(action: {
                        showClearSessionConfirmation = true
                    }) {
                        HStack {
                            Text("Clear Session & Restart Onboarding")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Development")
                } footer: {
                    Text("This will clear all data and return you to the onboarding flow.")
                }
                #endif
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            #if DEBUG
            .alert("Clear Session?", isPresented: $showClearSessionConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    appState.resetToOnboarding()
                    isPresented = false
                }
            } message: {
                Text("This will delete all your data (addictions, badges, progress) and return you to the onboarding screen. This action cannot be undone.")
            }
            #endif
        }
    }
}

