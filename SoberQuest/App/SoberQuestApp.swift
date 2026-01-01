import SwiftUI

@main
struct SoberQuestApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var superwallService = SuperwallService.shared
    
    init() {
        // Initialize Superwall (placeholder for MVP)
        // In production, configure with actual API key
        superwallService.checkEntitlement()
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
        }
    }
}

struct MainTabView: View {
    @StateObject private var appState = AppState.shared
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
    @StateObject private var appState = AppState.shared
    
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
        }
    }
}

