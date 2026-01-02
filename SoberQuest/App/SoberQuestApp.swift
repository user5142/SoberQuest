import SwiftUI

@main
struct SoberQuestApp: App {
    @ObservedObject private var appState = AppState.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Ensure Superwall is configured at app launch
        _ = SuperwallService.shared
        
        // Configure global appearance for dark mode
        configureAppearance()
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
            .preferredColorScheme(.dark)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // Refresh entitlement when app becomes active
                    // This ensures subscription status is up-to-date after:
                    // - App was backgrounded and user subscribed/cancelled via Settings
                    // - App was relaunched after a subscription change
                    Task {
                        await SuperwallService.shared.refreshEntitlement()
                    }
                }
            }
        }
    }
    
    private func configureAppearance() {
        // Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(AppTheme.tabBarBackground)
        
        // Tab bar item colors
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.tabBarUnselected)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.tabBarUnselected)]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.tabBarSelected)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.tabBarSelected)]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Navigation Bar Appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(AppTheme.background)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppTheme.gold)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case toolkit
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }
            }
            .tag(Tab.home)
            
            // Toolkit Tab
            NavigationView {
                ToolkitView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image(systemName: selectedTab == .toolkit ? "square.grid.2x2.fill" : "square.grid.2x2")
                    Text("Toolkit")
                }
            }
            .tag(Tab.toolkit)
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image(systemName: selectedTab == .settings ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
            }
            .tag(Tab.settings)
        }
        .accentColor(AppTheme.tabBarSelected)
    }
}

// MARK: - Toolkit View (Placeholder)
struct ToolkitView: View {
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.gold.opacity(0.6))
                
                Text("Toolkit")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Coming Soon")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .navigationTitle("Toolkit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showRelapseView = false
    @State private var showClearSessionConfirmation = false
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            List {
                Section {
                    if let addiction = appState.currentAddiction {
                        Button(action: {
                            showRelapseView = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.red)
                                Text("Reset Progress")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Progress")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.backgroundSecondary)
                
                #if DEBUG
                Section {
                    Button(action: {
                        showClearSessionConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear Session & Restart Onboarding")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Development")
                        .foregroundColor(AppTheme.textSecondary)
                } footer: {
                    Text("This will clear all data and return you to the onboarding flow.")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.backgroundSecondary)
                #endif
                
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                } header: {
                    Text("About")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.backgroundSecondary)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        #if DEBUG
        .alert("Clear Session?", isPresented: $showClearSessionConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                appState.resetToOnboarding()
            }
        } message: {
            Text("This will delete all your data (addictions, badges, progress) and return you to the onboarding screen. This action cannot be undone.")
        }
        #endif
        .sheet(isPresented: $showRelapseView) {
            if let addiction = appState.currentAddiction {
                RelapseView(addiction: addiction, isPresented: $showRelapseView)
            }
        }
    }
}
