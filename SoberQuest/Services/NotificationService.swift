import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private let trialReminderIdentifier = "trial_ending_reminder"
    let dailyPledgeIdentifier = "daily_pledge_reminder"
    let dailyReviewIdentifier = "daily_review_reminder"
    private let trialStartDateKey = "TrialStartDate"

    private override init() {
        super.init()
    }

    /// Sets up this service as the notification center delegate. Call this early in app lifecycle.
    func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Called when user taps a notification to open the app
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier

        if identifier == dailyPledgeIdentifier {
            AppState.shared.triggerCheckIn(.pledge)
        } else if identifier == dailyReviewIdentifier {
            AppState.shared.triggerCheckIn(.review)
        }

        completionHandler()
    }

    /// Called when a notification arrives while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show the notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

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
    /// NOTE: This method is deprecated. Use scheduleTrialReminderIfPermitted() instead.
    /// Permission should now be requested during onboarding.
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

    /// Schedules a trial reminder notification without requesting permission.
    /// Only works if permission was already granted (e.g., during onboarding).
    func scheduleTrialReminderIfPermitted() {
        checkPermissionStatus { [weak self] status in
            guard let self = self, status == .authorized else {
                print("NotificationService: Permission not authorized, skipping reminder")
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

    // MARK: - Daily Pledge Notifications

    /// Schedules daily pledge and review notifications based on saved settings.
    /// Only works if permission was already granted.
    func scheduleDailyPledgeNotificationsIfPermitted() {
        checkPermissionStatus { [weak self] status in
            guard let self = self, status == .authorized else {
                print("NotificationService: Permission not authorized, skipping daily pledge notifications")
                return
            }
            self.scheduleDailyPledgeNotifications()
        }
    }

    /// Internal method to schedule the daily pledge and review notifications
    private func scheduleDailyPledgeNotifications() {
        let settings = DataManager.shared.loadDailyPledgeSettings()

        guard settings.isEnabled else {
            print("NotificationService: Daily pledge is disabled, not scheduling notifications")
            cancelDailyPledgeNotifications()
            return
        }

        // Cancel existing notifications first
        cancelDailyPledgeNotifications()

        // Schedule daily pledge notification
        scheduleDailyNotification(
            identifier: dailyPledgeIdentifier,
            title: "Time for your daily pledge",
            body: "Start your day with intention. Take a moment to commit to your sobriety.",
            hour: settings.pledgeHour,
            minute: settings.pledgeMinute
        )

        // Schedule daily review notification
        scheduleDailyNotification(
            identifier: dailyReviewIdentifier,
            title: "Time for your daily review",
            body: "How did today go? Take a moment to reflect on your progress.",
            hour: settings.reviewHour,
            minute: settings.reviewMinute
        )

        print("NotificationService: Daily pledge notifications scheduled at \(settings.pledgeTimeFormatted) and \(settings.reviewTimeFormatted)")
    }

    /// Helper method to schedule a repeating daily notification
    private func scheduleDailyNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("NotificationService: Failed to schedule \(identifier) - \(error.localizedDescription)")
            }
        }
    }

    /// Cancels all daily pledge notifications
    func cancelDailyPledgeNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [dailyPledgeIdentifier, dailyReviewIdentifier]
        )
        print("NotificationService: Daily pledge notifications cancelled")
    }

    /// Updates daily pledge notifications with new settings
    func updateDailyPledgeNotifications() {
        scheduleDailyPledgeNotificationsIfPermitted()
    }
}
