import SwiftUI

enum CheckInType {
    case pledge
    case review

    var title: String {
        switch self {
        case .pledge:
            return "Daily Pledge"
        case .review:
            return "Daily Review"
        }
    }

    var subtitle: String {
        switch self {
        case .pledge:
            return "Start your day with intention"
        case .review:
            return "Reflect on your progress today"
        }
    }

    var buttonText: String {
        switch self {
        case .pledge:
            return "I pledge to stay sober today"
        case .review:
            return "I stayed true to my pledge"
        }
    }

    var icon: String {
        switch self {
        case .pledge:
            return "sunrise.fill"
        case .review:
            return "sunset.fill"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .pledge:
            return "You've made your pledge. Stay strong today!"
        case .review:
            return "Great job reflecting on your day. Keep it up!"
        }
    }
}

enum ReviewStep {
    case sobriety
    case difficulty
    case mood
    case activities
    case notes
}

struct DailyPledgeCheckInView: View {
    let checkInType: CheckInType
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState

    @State private var currentStep: ReviewStep = .sobriety
    @State private var showConfirmation = false

    // Review data
    @State private var stayedSober: Bool? = nil
    @State private var difficultyLevel: DifficultyLevel? = nil
    @State private var selectedMoods: Set<MoodOption> = []
    @State private var selectedActivities: Set<ActivityOption> = []
    @State private var notes: String = ""

    // Random inspirational quote for confirmation
    @State private var selectedQuote: String = ""

    // Inspirational quotes for pledge
    private let inspirationalQuotes = [
        "One day at a time.",
        "Progress, not perfection.",
        "You are stronger than your cravings.",
        "Every day sober is a victory.",
        "Your future is created by what you do today.",
        "Recovery is a journey, not a destination.",
        "You didn't come this far to only come this far.",
        "Strength grows in the moments when you think you can't go on.",
        "The only way out is through.",
        "Today is a new beginning.",
        "You are worthy of a healthy life.",
        "Small steps lead to big changes.",
        "Believe in yourself and all that you are.",
        "The best time for a new beginning is now.",
        "You have the power to change your story."
    ]

    // Inspirational quotes for review
    private let reviewQuotes = [
        "Another day won.",
        "Your commitment is your strength.",
        "Each sober day is a gift to yourself.",
        "You showed up for yourself today.",
        "Consistency builds character.",
        "Your choices today shape tomorrow.",
        "You're building a better future.",
        "Reflection is the path to growth.",
        "You're proving your strength daily.",
        "Every day clean is a step forward.",
        "Your perseverance is powerful.",
        "You're writing a new story.",
        "This is what courage looks like.",
        "You're becoming who you're meant to be.",
        "Your dedication inspires change."
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if checkInType == .pledge {
                // Simple pledge flow
                if showConfirmation {
                    confirmationView
                } else {
                    pledgeView
                }
            } else {
                // Multi-step review flow
                if showConfirmation {
                    confirmationView
                } else {
                    reviewFlowView
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Pledge View
    private var pledgeView: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 32, height: 32)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Day of week header
            Text("PLEDGE FOR \(dayOfWeek.uppercased())")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.5)
                .padding(.top, 32)

            // Main pledge text in dark box
            Text("Today, I will stay sober")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(hex: "3D3D3D"))
                .padding(.horizontal, 40)
                .padding(.top, 32)

            // Why I'm doing this section
            VStack(spacing: 16) {
                Text("Why I'm doing this")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)

                // Motivation card
                if let motivation = appState.currentAddiction?.motivation, !motivation.isEmpty {
                    Text(motivation)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                } else {
                    Text("For my future")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                }
            }
            .padding(.top, 48)

            Spacer()

            // Pledge button (white background, dark text)
            Button(action: {
                // Select random quote for confirmation screen
                selectedQuote = inspirationalQuotes.randomElement() ?? inspirationalQuotes[0]

                withAnimation(.easeInOut(duration: 0.3)) {
                    showConfirmation = true
                }
            }) {
                Text("I Will Stay Sober Today!")
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

    // MARK: - Review Flow View
    private var reviewFlowView: some View {
        VStack(spacing: 0) {
            // Header with navigation and progress
            headerView

            // Current step content
            ScrollView {
                VStack(spacing: 0) {
                    switch currentStep {
                    case .sobriety:
                        sobrietyStepView
                    case .difficulty:
                        difficultyStepView
                    case .mood:
                        moodStepView
                    case .activities:
                        activitiesStepView
                    case .notes:
                        notesStepView
                    }
                }
                .padding(.top, 32)
            }

            Spacer()

            // Bottom button
            bottomButtonView
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                if currentStep != .sobriety {
                    Button(action: goToPreviousStep) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 32, height: 32)
                    }
                } else {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 32, height: 32)
                    }
                }

                Spacer()

                if currentStep == .notes {
                    Button(action: completeReview) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index <= stepIndex(currentStep) ? Color.white : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    // MARK: - Step 1: Sobriety
    private var sobrietyStepView: some View {
        VStack(spacing: 32) {
            Text(appState.currentAddiction?.name ?? "Substance")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Did you stay sober today?")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.textSecondary)

            Text(formatDate(Date()))
                .font(.system(size: 17))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.top, 16)

            HStack(spacing: 16) {
                Button(action: {
                    stayedSober = true
                }) {
                    HStack {
                        if stayedSober == true {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                        Text("No")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(stayedSober == true ? .white : AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(stayedSober == true ? Color.white.opacity(0.1) : Color.clear)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(stayedSober == true ? Color.white : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }

                Button(action: {
                    stayedSober = false
                }) {
                    HStack {
                        if stayedSober == false {
                            Image(systemName: "xmark")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Text("Yes")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(stayedSober == false ? Color.gray.opacity(0.1) : Color.clear)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(stayedSober == false ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
    }

    // MARK: - Step 2: Difficulty
    private var difficultyStepView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("How hard was it today?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 24)

            Text(formatDate(Date()))
                .font(.system(size: 17))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    Button(action: {
                        difficultyLevel = level
                    }) {
                        HStack {
                            Circle()
                                .fill(colorForDifficulty(level))
                                .frame(width: 24, height: 24)

                            Text(level.rawValue)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            Spacer()

                            if difficultyLevel == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(difficultyLevel == level ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(difficultyLevel == level ? Color.white : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 3: Mood
    private var moodStepView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("How was your mood?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Check as many as you want")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 24)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(MoodOption.allCases, id: \.self) { mood in
                    Button(action: {
                        if selectedMoods.contains(mood) {
                            selectedMoods.remove(mood)
                        } else {
                            selectedMoods.insert(mood)
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 32))

                            Text(mood.rawValue)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMoods.contains(mood) ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMoods.contains(mood) ? Color.white : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 4: Activities
    private var activitiesStepView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What were you up to?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Check as many as you want")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(ActivityOption.allCases, id: \.self) { activity in
                    Button(action: {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }) {
                        HStack {
                            Text(activity.rawValue)
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.textPrimary)

                            Spacer()

                            if selectedActivities.contains(activity) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.05))
                    }

                    if activity != ActivityOption.allCases.last {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

    // MARK: - Step 5: Notes
    private var notesStepView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(formatDate(Date()))
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 24)

            TextEditor(text: $notes)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(16)
                .background(AppTheme.backgroundSecondary)
                .cornerRadius(12)
                .foregroundColor(AppTheme.textPrimary)
                .font(.system(size: 17))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if notes.isEmpty {
                            Text("This can be anything you want to remember about today...")
                                .foregroundColor(AppTheme.textSecondary)
                                .font(.system(size: 17))
                                .padding(.top, 24)
                                .padding(.leading, 20)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Bottom Button
    private var bottomButtonView: some View {
        Button(action: {
            if currentStep == .notes {
                completeReview()
            } else {
                goToNextStep()
            }
        }) {
            Text("Next")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(canProceed ? AppTheme.buttonPrimaryText : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(canProceed ? AppTheme.buttonPrimary : Color.gray.opacity(0.3))
                .cornerRadius(14)
        }
        .disabled(!canProceed)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    // MARK: - Confirmation View
    private var confirmationView: some View {
        ZStack {
            // Dark theme gradient background
            LinearGradient(
                colors: [
                    Color(hex: "2A2A2A"),
                    Color(hex: "1A1A1A"),
                    Color(hex: "0D0D0D")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar with close button only
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Date and quote
                VStack(spacing: 16) {
                    Text("Today, \(formattedDate)")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))

                    Text(selectedQuote)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Swipe indicator
                VStack(spacing: 8) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Helper Properties
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Helper Functions
    private func goToNextStep() {
        withAnimation {
            switch currentStep {
            case .sobriety:
                currentStep = .difficulty
            case .difficulty:
                currentStep = .mood
            case .mood:
                currentStep = .activities
            case .activities:
                currentStep = .notes
            case .notes:
                break
            }
        }
    }

    private func goToPreviousStep() {
        withAnimation {
            switch currentStep {
            case .sobriety:
                break
            case .difficulty:
                currentStep = .sobriety
            case .mood:
                currentStep = .difficulty
            case .activities:
                currentStep = .mood
            case .notes:
                currentStep = .activities
            }
        }
    }

    private func completeReview() {
        // Save the review data
        if let addiction = appState.currentAddiction, let stayedSober = stayedSober {
            let review = PledgeReview(
                addictionId: addiction.id,
                stayedSober: stayedSober,
                difficultyLevel: difficultyLevel,
                moods: Array(selectedMoods),
                activities: Array(selectedActivities),
                notes: notes
            )

            // TODO: Save review to DataManager
            // For now, just show confirmation
        }

        // Select random quote for confirmation screen
        selectedQuote = reviewQuotes.randomElement() ?? reviewQuotes[0]

        withAnimation(.easeInOut(duration: 0.3)) {
            showConfirmation = true
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case .sobriety:
            return stayedSober != nil
        case .difficulty:
            return true // Can skip this step
        case .mood:
            return true // Can skip this step
        case .activities:
            return true // Can skip this step
        case .notes:
            return true // Can skip this step
        }
    }

    private func stepIndex(_ step: ReviewStep) -> Int {
        switch step {
        case .sobriety: return 0
        case .difficulty: return 1
        case .mood: return 2
        case .activities: return 3
        case .notes: return 4
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d"
        return formatter.string(from: date)
    }

    private func colorForDifficulty(_ level: DifficultyLevel) -> Color {
        switch level {
        case .easy:
            return .green
        case .notBad:
            return Color(hex: "4A90A4")
        case .questionable:
            return Color.gray
        case .hard:
            return Color(hex: "1E3A5F")
        case .impossible:
            return Color.red
        }
    }
}
