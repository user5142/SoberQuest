import Foundation

struct DailyPledgeSettings: Codable {
    var isEnabled: Bool
    var pledgeTime: Date
    var reviewTime: Date

    static var `default`: DailyPledgeSettings {
        let calendar = Calendar.current
        var pledgeComponents = DateComponents()
        pledgeComponents.hour = 8
        pledgeComponents.minute = 0

        var reviewComponents = DateComponents()
        reviewComponents.hour = 20
        reviewComponents.minute = 0

        let pledgeTime = calendar.date(from: pledgeComponents) ?? Date()
        let reviewTime = calendar.date(from: reviewComponents) ?? Date()

        return DailyPledgeSettings(
            isEnabled: true,
            pledgeTime: pledgeTime,
            reviewTime: reviewTime
        )
    }

    var pledgeTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: pledgeTime)
    }

    var reviewTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: reviewTime)
    }

    var pledgeHour: Int {
        Calendar.current.component(.hour, from: pledgeTime)
    }

    var pledgeMinute: Int {
        Calendar.current.component(.minute, from: pledgeTime)
    }

    var reviewHour: Int {
        Calendar.current.component(.hour, from: reviewTime)
    }

    var reviewMinute: Int {
        Calendar.current.component(.minute, from: reviewTime)
    }
}
