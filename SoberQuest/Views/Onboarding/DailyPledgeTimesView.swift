import SwiftUI

struct DailyPledgeTimesView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var pledgeSettings: DailyPledgeSettings

    @State private var showingPledgeTimePicker = false
    @State private var showingReviewTimePicker = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .motivationSetup
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Confirm your daily pledge\nand review times")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)

                        // Time selection rows
                        VStack(spacing: 0) {
                            // Daily pledge row
                            Button(action: {
                                showingPledgeTimePicker = true
                            }) {
                                HStack {
                                    Text("Daily pledge")
                                        .font(.system(size: 17))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text(pledgeSettings.pledgeTimeFormatted)
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "4A90A4"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textMuted)
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 24)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()
                                .background(AppTheme.backgroundSecondary)
                                .padding(.horizontal, 24)

                            // Daily review row
                            Button(action: {
                                showingReviewTimePicker = true
                            }) {
                                HStack {
                                    Text("Daily review")
                                        .font(.system(size: 17))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text(pledgeSettings.reviewTimeFormatted)
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "4A90A4"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textMuted)
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 24)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()
                                .background(AppTheme.backgroundSecondary)
                                .padding(.horizontal, 24)
                        }

                        // Info text
                        Text("You'll receive notifications at these times.")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 8)

                        Spacer(minLength: 100)
                    }
                }

                // Next button fixed at bottom
                VStack {
                    Button(action: {
                        DataManager.shared.saveDailyPledgeSettings(pledgeSettings)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .notificationPermission
                        }
                    }) {
                        Text("Next")
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
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingPledgeTimePicker) {
            TimePickerSheet(
                title: "What time do you want your pledge reminder?",
                subtitle: "Ideally at the beginning of your day",
                selectedTime: $pledgeSettings.pledgeTime,
                isPresented: $showingPledgeTimePicker
            )
        }
        .sheet(isPresented: $showingReviewTimePicker) {
            TimePickerSheet(
                title: "What time do you want your review reminder?",
                subtitle: "Ideally at the end of your day",
                selectedTime: $pledgeSettings.reviewTime,
                isPresented: $showingReviewTimePicker
            )
        }
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    let title: String
    let subtitle: String
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool

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
                        .foregroundColor(Color(hex: "4A90A4"))
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
                        .foregroundColor(Color(hex: "4A90A4"))
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
                    isPresented = false
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(hex: "4A90A4"))
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

