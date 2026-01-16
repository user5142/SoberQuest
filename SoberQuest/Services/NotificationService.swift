import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private let trialReminderIdentifier = "trial_ending_reminder"
    private let trialStartDateKey = "TrialStartDate"

    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NotificationService: Permission error - \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }

    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Trial Reminder

    /// Requests permission and schedules a reminder notification for 1 day before the 7-day trial ends
    func scheduleTrialEndingReminder() {
        // First request permission, then schedule if granted
        requestPermission { [weak self] granted in
            guard granted, let self = self else {
                print("NotificationService: Permission not granted, skipping reminder")
                return
            }
            self.scheduleReminderNotification()
        }
    }

    /// Internal method to schedule the actual notification (called after permission is granted)
    private func scheduleReminderNotification() {
        // Store trial start date
        let trialStartDate = Date()
        UserDefaults.standard.set(trialStartDate, forKey: trialStartDateKey)

        // Calculate reminder date: 6 days from now (1 day before trial ends)
        guard let reminderDate = Calendar.current.date(byAdding: .day, value: 6, to: trialStartDate) else {
            print("NotificationService: Failed to calculate reminder date")
            return
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Your trial ends tomorrow"
        content.body = "Keep your sobriety streak going! Subscribe to continue tracking your progress and earning badges."
        content.sound = .default

        // Create trigger for the reminder date at 10 AM local time
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create and schedule the request
        let request = UNNotificationRequest(
            identifier: trialReminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("NotificationService: Failed to schedule reminder - \(error.localizedDescription)")
            } else {
                print("NotificationService: Trial reminder scheduled for \(reminderDate)")
            }
        }
    }

    /// Cancels the trial ending reminder (call this when user subscribes)
    func cancelTrialEndingReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [trialReminderIdentifier])
        print("NotificationService: Trial reminder cancelled")
    }

    // MARK: - Trial Date Tracking

    func getTrialStartDate() -> Date? {
        return UserDefaults.standard.object(forKey: trialStartDateKey) as? Date
    }

    func getTrialEndDate() -> Date? {
        guard let startDate = getTrialStartDate() else { return nil }
        return Calendar.current.date(byAdding: .day, value: 7, to: startDate)
    }

    func getDaysRemainingInTrial() -> Int? {
        guard let endDate = getTrialEndDate() else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day
        return max(0, days ?? 0)
    }
}
