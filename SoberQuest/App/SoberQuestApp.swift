import SwiftUI
import StoreKit
import SuperwallKit

@main
struct SoberQuestApp: App {
    @ObservedObject private var appState = AppState.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Ensure Superwall is configured at app launch
        _ = SuperwallService.shared

        // Set up notification delegate to handle notification taps
        NotificationService.shared.setupNotificationDelegate()

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
    @State private var showCopiedToast = false
    @State private var pledgeSettings = DataManager.shared.loadDailyPledgeSettings()
    @State private var showingPledgeTimePicker = false
    @State private var showingReviewTimePicker = false
    
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
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Button(action: {
                        UIPasteboard.general.string = Superwall.shared.userId
                        showCopiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopiedToast = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("User ID")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text(showCopiedToast ? "Copied!" : String(Superwall.shared.userId.prefix(8)) + "...")
                                .foregroundColor(showCopiedToast ? .green : AppTheme.textSecondary)
                                .font(.system(size: 14, design: .monospaced))
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
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

                // MARK: - Daily Check-in Section
                Section {
                    Toggle(isOn: $pledgeSettings.isEnabled) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Daily Check-in")
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .tint(AppTheme.ancientGold)
                    .onChange(of: pledgeSettings.isEnabled) { _ in
                        savePledgeSettings()
                    }

                    if pledgeSettings.isEnabled {
                        Button(action: {
                            showingPledgeTimePicker = true
                        }) {
                            HStack {
                                Image(systemName: "sunrise.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Pledge Time")
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(pledgeSettings.pledgeTimeFormatted)
                                    .foregroundColor(AppTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }

                        Button(action: {
                            showingReviewTimePicker = true
                        }) {
                            HStack {
                                Image(systemName: "sunset.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Review Time")
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(pledgeSettings.reviewTimeFormatted)
                                    .foregroundColor(AppTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                    }
                } header: {
                    Text("Daily Check-in")
                        .foregroundColor(AppTheme.textSecondary)
                } footer: {
                    Text("Receive daily reminders to pledge your commitment and reflect on your progress.")
                        .foregroundColor(AppTheme.textMuted)
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
        .sheet(isPresented: $showingPledgeTimePicker) {
            SettingsTimePickerSheet(
                title: "Pledge Time",
                subtitle: "Set when you want your morning pledge reminder",
                selectedTime: $pledgeSettings.pledgeTime,
                isPresented: $showingPledgeTimePicker,
                onSave: savePledgeSettings
            )
        }
        .sheet(isPresented: $showingReviewTimePicker) {
            SettingsTimePickerSheet(
                title: "Review Time",
                subtitle: "Set when you want your evening review reminder",
                selectedTime: $pledgeSettings.reviewTime,
                isPresented: $showingReviewTimePicker,
                onSave: savePledgeSettings
            )
        }
    }

    private func savePledgeSettings() {
        DataManager.shared.saveDailyPledgeSettings(pledgeSettings)
        NotificationService.shared.updateDailyPledgeNotifications()
    }
}

// MARK: - Settings Time Picker Sheet
struct SettingsTimePickerSheet: View {
    let title: String
    let subtitle: String
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    let onSave: () -> Void

    @State private var tempTime: Date = Date()

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Cancel button
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Cancel")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Title and subtitle
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 24)

                // Time picker
                DatePicker("", selection: $tempTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                Spacer()

                // Save button
                Button(action: {
                    selectedTime = tempTime
                    onSave()
                    isPresented = false
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            tempTime = selectedTime
        }
    }
}
