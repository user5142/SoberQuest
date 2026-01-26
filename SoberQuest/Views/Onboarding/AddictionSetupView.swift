import SwiftUI

// MARK: - Data Models
struct AddictionSection: Identifiable {
    let id = UUID()
    let title: String
    let addictions: [String]
}

struct AddictionSetupView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var selectedAddictionName: String
    @State private var selectedAddiction: String = ""
    @State private var customAddiction: String = ""
    @State private var showCustomInput: Bool = false
    @State private var searchText: String = ""
    @FocusState private var isCustomInputFocused: Bool
    @FocusState private var isSearchFocused: Bool

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
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("What are you quitting?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("You can add more later")
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
        .preferredColorScheme(.dark)
    }
    
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
}
