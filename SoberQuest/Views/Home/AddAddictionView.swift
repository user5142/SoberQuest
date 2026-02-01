import SwiftUI

struct AddAddictionView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var dataManager = DataManager.shared

    @State private var currentStep: AddAddictionStep = .nameSelection
    @State private var selectedAddictionName: String = ""
    @State private var lastUsedDate: Date = Date()
    @State private var motivationText: String = ""

    enum AddAddictionStep {
        case nameSelection
        case dateSelection
        case motivationSetup
    }

    let addictionSections: [AddictionSection] = [
        AddictionSection(title: "Alcoholic drinks", addictions: [
            "Alcohol", "Beer", "Binge Drinking", "Booze", "Bourbon", "Gin", "Rum", "Tequila", "Vodka", "Whiskey", "Wine"
        ]),
        AddictionSection(title: "Nicotine & tobacco", addictions: [
            "Chewing Tobacco", "Cigarettes", "Nicotine", "Snus", "Tobacco", "Vaping", "Zyn"
        ]),
        AddictionSection(title: "Cannabis products", addictions: [
            "Cannabis", "Cannabis (Synthetic)", "Marijuana", "Marijuana (Synthetic)", "Vaping (THC)"
        ]),
        AddictionSection(title: "Stimulants", addictions: [
            "3-MMC", "4-MMC", "Adderall", "Alpha-PVP (Flakka)", "Amphetamines", "Bath Salts", "Cocaine", "Crack Cocaine", "Crystal Meth", "Mephedrone", "Methamphetamine", "Methcathinone (CAT)", "Methylphenidate", "Mixed Amphetamine Salts", "Ritalin", "Synthetic Cathinones"
        ]),
        AddictionSection(title: "Depressants", addictions: [
            "Alprazolam", "Barbiturates", "Benzodiazepines", "Buprenorphine", "Codeine", "Fentanyl", "Heroin", "Kratom", "Lean (Codeine Mixture)", "Methadone", "Opiates", "Suboxone", "Xanax"
        ]),
        AddictionSection(title: "Other drugs", addictions: [
            "Antidepressants", "Benadryl", "Dextromethorphan (DXM)", "Diphenhydramine", "Ecstasy", "Gamma-Hydroxybutyrate (GHB)", "Inhalants", "Ketamine", "Lisdexamfetamine", "LSD", "Lyrica", "Mescaline", "Muscle Relaxants", "Nasal Spray", "Nitrous Oxide", "Pregabalin", "Salvia", "Sleeping Aids", "Solvents", "Tramadol", "Vyvanse"
        ]),
        AddictionSection(title: "Food & caffeine", addictions: [
            "Bread", "Caffeine", "Carbohydrates", "Cookies", "Dairy Products", "Energy Drinks", "Fast Food", "Gluten", "Junk Food", "Meat & Dairy", "Soft Drinks", "Sugar", "Sweets"
        ]),
        AddictionSection(title: "Eating disorders", addictions: [
            "Binge Eating", "Binging & Purging", "Chewing & Spitting", "Eating Disorder", "Eating Disorder (undereating)", "Food Restricting", "Laxatives", "Purging"
        ]),
        AddictionSection(title: "Sexual behaviors", addictions: [
            "Chemsex", "Masturbation", "Pornography", "Sex"
        ]),
        AddictionSection(title: "Body-focused behaviors", addictions: [
            "Cheek Biting", "Hair Pulling", "Knuckle Cracking", "Lip Biting", "Nail Biting", "Pica (Non-food Eating)", "Self-harm", "Skin Picking"
        ]),
        AddictionSection(title: "Impulsive behaviors", addictions: [
            "Compulsive Spending", "Excessive Exercising", "Gambling", "Online Shopping", "Shoplifting", "Stealing"
        ]),
        AddictionSection(title: "Social behaviors", addictions: [
            "Anger", "Attention Seeking", "Bad Language (Swearing)", "Codependency", "Gossiping", "Lying", "Stalking", "Toxic Relationships"
        ]),
        AddictionSection(title: "Technology", addictions: [
            "Chatbots (AI)", "Dating Apps", "Doomscrolling", "Instagram", "Internet", "Online Videos", "Short-Form Videos", "Social Media", "TikTok", "Video Games", "Virtual Reality"
        ])
    ]

    // Filtered sections based on search text
    var filteredSections: [AddictionSection] {
        if searchText.isEmpty {
            return addictionSections
        }

        let lowercasedSearch = searchText.lowercased()
        return addictionSections.compactMap { section in
            let filteredAddictions = section.addictions.filter { addiction in
                addiction.lowercased().contains(lowercasedSearch)
            }

            if filteredAddictions.isEmpty {
                return nil
            }

            return AddictionSection(title: section.title, addictions: filteredAddictions)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                switch currentStep {
                case .nameSelection:
                    nameSelectionView
                case .dateSelection:
                    dateSelectionView
                case .motivationSetup:
                    motivationSetupView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        switch currentStep {
                        case .nameSelection:
                            isPresented = false
                        case .dateSelection:
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .nameSelection
                            }
                        case .motivationSetup:
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .dateSelection
                            }
                        }
                    }) {
                        Image(systemName: currentStep == .nameSelection ? "xmark" : "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Name Selection View
    private var nameSelectionView: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("What are you quitting?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Add another tracker")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 32)

                        // Search bar
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppTheme.textMuted)
                                .font(.system(size: 16))

                            TextField("Search addictions", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textPrimary)
                                .focused($isSearchFocused)
                                .autocorrectionDisabled()

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.textMuted)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)

                        // Sectioned addiction list
                        VStack(spacing: 20) {
                            if filteredSections.isEmpty && !searchText.isEmpty {
                                // No results
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.textMuted)

                                    Text("No addictions found")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)

                                    Text("Try searching for something else or use the custom option below")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppTheme.textMuted)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                                .padding(.vertical, 40)
                            } else {
                                ForEach(filteredSections) { section in
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Section header
                                        Text(section.title)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(AppTheme.textMuted)
                                            .textCase(.uppercase)
                                            .padding(.horizontal, 24)

                                        // Section items
                                        VStack(spacing: 8) {
                                            ForEach(section.addictions, id: \.self) { addiction in
                                                addictionOption(addiction, isCustom: false)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }

                            // Custom option (always visible at the bottom)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Add a custom addiction")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.textMuted)
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 24)

                                VStack(spacing: 12) {
                                    addictionOption("Custom", isCustom: true)

                                    // Custom text input
                                    if showCustomInput {
                                        TextField("Enter addiction name", text: $customAddiction)
                                            .font(.system(size: 16))
                                            .foregroundColor(AppTheme.textPrimary)
                                            .padding()
                                            .background(AppTheme.backgroundSecondary)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.divider, lineWidth: 1)
                                            )
                                            .focused($isCustomInputFocused)
                                            .onChange(of: customAddiction) { newValue in
                                                if !newValue.isEmpty {
                                                    selectedAddictionName = newValue
                                                }
                                            }
                                            .id("customInput")
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 8)
                        }

                        // Extra bottom padding to ensure content is not hidden by button
                        Spacer(minLength: 150)
                    }
                    .onChange(of: showCustomInput) { newValue in
                        if newValue {
                            // Scroll to custom input and focus it
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo("customInput", anchor: .center)
                                }
                                isCustomInputFocused = true
                            }
                        }
                    }
                }
            }

            // Continue button fixed at bottom
            VStack {
                Spacer()

                Button(action: {
                    if !selectedAddictionName.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .dateSelection
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(selectedAddictionName.isEmpty ? AppTheme.textMuted : AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(selectedAddictionName.isEmpty ? AppTheme.backgroundSecondary : AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .disabled(selectedAddictionName.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .background(
                    LinearGradient(
                        colors: [AppTheme.background.opacity(0), AppTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .offset(y: -40)
                )
            }
        }
    }

    // State for name selection
    @State private var selectedAddiction: String = ""
    @State private var customAddiction: String = ""
    @State private var showCustomInput: Bool = false
    @State private var searchText: String = ""
    @FocusState private var isCustomInputFocused: Bool
    @FocusState private var isSearchFocused: Bool

    @ViewBuilder
    private func addictionOption(_ name: String, isCustom: Bool) -> some View {
        let isSelected = isCustom ? selectedAddiction == "custom" : selectedAddiction == name

        Button(action: {
            if isCustom {
                selectedAddiction = "custom"
                showCustomInput = true
                if !customAddiction.isEmpty {
                    selectedAddictionName = customAddiction
                } else {
                    selectedAddictionName = ""
                }
            } else {
                selectedAddiction = name
                selectedAddictionName = name
                showCustomInput = false
            }
        }) {
            HStack {
                Text(name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.textPrimary)
                } else {
                    Circle()
                        .stroke(AppTheme.textMuted, lineWidth: 2)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppTheme.cardBackgroundDark : AppTheme.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppTheme.divider : Color.clear, lineWidth: 1)
            )
        }
    }

    // MARK: - Date Selection View
    private var dateSelectionView: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Text("When did you last use?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("This helps us track your progress")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 24)

                    // Date picker
                    VStack(spacing: 16) {
                        DatePicker(
                            "Last used date",
                            selection: $lastUsedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .accentColor(AppTheme.textPrimary)
                        .colorScheme(.dark)
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }

            // Continue button fixed at bottom
            VStack {
                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .motivationSetup
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .background(
                    LinearGradient(
                        colors: [AppTheme.background.opacity(0), AppTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .offset(y: -40)
                )
            }
        }
    }

    // MARK: - Motivation Setup View
    @FocusState private var isMotivationFocused: Bool

    private var motivationSetupView: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Why are you quitting?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Your motivation will keep you going")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 24)

                    // Text input area
                    VStack(spacing: 16) {
                        TextEditor(text: $motivationText)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 150)
                            .padding(16)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(16)
                            .focused($isMotivationFocused)
                            .overlay(
                                Group {
                                    if motivationText.isEmpty {
                                        Text("e.g., To be healthier for my family, to feel more present, to save money...")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppTheme.textMuted)
                                            .padding(20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }
            .onTapGesture {
                isMotivationFocused = false
            }

            // Add Tracker button fixed at bottom
            VStack {
                Spacer()

                Button(action: {
                    isMotivationFocused = false
                    createAddictionAndDismiss()
                }) {
                    Text("Add Tracker")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.textMuted : AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.backgroundSecondary : AppTheme.buttonPrimary)
                        .cornerRadius(14)
                }
                .disabled(motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .background(
                    LinearGradient(
                        colors: [AppTheme.background.opacity(0), AppTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .offset(y: -40)
                )
            }
        }
    }

    // MARK: - Create Addiction
    private func createAddictionAndDismiss() {
        // Create new addiction with motivation (now required)
        let trimmedMotivation = motivationText.trimmingCharacters(in: .whitespacesAndNewlines)
        // If user selected "today", use current time so timer starts from now
        let startDate = Calendar.current.isDateInToday(lastUsedDate) ? Date() : lastUsedDate
        let newAddiction = Addiction(
            name: selectedAddictionName,
            startDate: startDate,
            currentStreak: 0,
            isActive: true,
            motivation: trimmedMotivation
        )

        // Save and set as active
        dataManager.saveAddiction(newAddiction)
        appState.setCurrentAddiction(newAddiction)

        // Award all badges based on days sober from the selected date
        let daysSober = newAddiction.daysSober
        for badge in BadgeDefinition.defaultBadges where badge.milestoneDays <= daysSober {
            let unlockedBadge = UnlockedBadge(badgeId: badge.id, addictionId: newAddiction.id)
            dataManager.saveUnlockedBadge(unlockedBadge)
        }

        // Dismiss
        isPresented = false
    }
}
