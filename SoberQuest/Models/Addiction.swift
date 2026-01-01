import Foundation

struct Addiction: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var currentStreak: Int
    var isActive: Bool
    
    init(id: UUID = UUID(), name: String, startDate: Date, currentStreak: Int = 0, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.currentStreak = currentStreak
        self.isActive = isActive
    }
    
    var daysSober: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }
    
    var timeComponents: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate, to: Date())
        return (
            years: components.year ?? 0,
            months: components.month ?? 0,
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0
        )
    }
}

