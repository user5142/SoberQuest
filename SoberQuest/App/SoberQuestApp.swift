import SwiftUI
import StoreKit

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
                    // Sync check of current subscription status when app becomes active
                    // The Combine observer on $subscriptionStatus handles reactive updates
                    // This is a lightweight status read, not a restore (no alerts shown)
                    SuperwallService.shared.refreshEntitlement()

                    // Ensure SDK is ready for purchases after returning from background
                    // This helps with cold starts and long background periods
                    SuperwallService.shared.ensureReadyForPurchases()
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
        UINavigationBar.appearance().tintColor = UIColor.white
    }
}

// MARK: - Main Tab View (Tab bar temporarily disabled - using settings icon in HomeView instead)
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    // Tab bar temporarily disabled
    // @State private var selectedTab: Tab = .home
    //
    // enum Tab {
    //     case home
    //     case toolkit
    //     case settings
    // }

    var body: some View {
        // Tab bar temporarily disabled - showing HomeView directly
        // Settings accessible via gear icon in top left of HomeView
        NavigationView {
            HomeView()
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())

        // Original TabView (temporarily disabled)
        // TabView(selection: $selectedTab) {
        //     // Home Tab
        //     NavigationView {
        //         HomeView()
        //             .navigationBarHidden(true)
        //     }
        //     .navigationViewStyle(StackNavigationViewStyle())
        //     .tabItem {
        //         VStack {
        //             Image(systemName: selectedTab == .home ? "house.fill" : "house")
        //             Text("Home")
        //         }
        //     }
        //     .tag(Tab.home)
        //
        //     // Toolkit Tab
        //     NavigationView {
        //         ToolkitView()
        //     }
        //     .navigationViewStyle(StackNavigationViewStyle())
        //     .tabItem {
        //         VStack {
        //             Image(systemName: selectedTab == .toolkit ? "square.grid.2x2.fill" : "square.grid.2x2")
        //             Text("Toolkit")
        //         }
        //     }
        //     .tag(Tab.toolkit)
        //
        //     // Settings Tab
        //     NavigationView {
        //         SettingsView()
        //     }
        //     .navigationViewStyle(StackNavigationViewStyle())
        //     .tabItem {
        //         VStack {
        //             Image(systemName: selectedTab == .settings ? "gearshape.fill" : "gearshape")
        //             Text("Settings")
        //         }
        //     }
        //     .tag(Tab.settings)
        // }
        // .accentColor(AppTheme.tabBarSelected)
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
                    .foregroundColor(AppTheme.textSecondary)

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
                // MARK: - About Section
                Section {
                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Rate SoberQuest")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
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
                
                // MARK: - Support Section
                Section {
                    Button(action: {
                        if let url = URL(string: "https://www.studionoo.com/contact/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Contact Support")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                } header: {
                    Text("Support")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.backgroundSecondary)
                
                // MARK: - Legal Section
                Section {
                    Button(action: {
                        if let url = URL(string: "https://www.studionoo.com/soberquest/privacy/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Privacy Policy")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.studionoo.com/soberquest/terms/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Terms of Use")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                } header: {
                    Text("Legal")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.backgroundSecondary)

                // MARK: - Other Apps Section
                Section {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/us/app/rosemaryy-meal-planner/id6753137320") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(alignment: .center, spacing: 12) {
                            Image("rosemaryy_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 42, height: 42)
                                .cornerRadius(6)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Rosemaryy")
                                    .foregroundColor(AppTheme.textPrimary)
                                    .font(.system(size: 16, weight: .medium))
                                Text("Meal Planner & Recipes")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .font(.system(size: 13))
                            }

                            Spacer()

                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("More from Us")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.backgroundSecondary)

                // MARK: - Progress Section
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
                
                // MARK: - Development Section (DEBUG only)
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
