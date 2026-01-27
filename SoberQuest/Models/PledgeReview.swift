import Foundation

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case notBad = "Not bad"
    case questionable = "Questionable"
    case hard = "Hard"
    case impossible = "Impossible"
}

enum MoodOption: String, Codable, CaseIterable {
    case accomplished = "Accomplished"
    case ambitious = "Ambitious"
    case angry = "Angry"
    case annoyed = "Annoyed"
    case anxious = "Anxious"
    case appreciated = "Appreciated"
    case ashamed = "Ashamed"
    case awkward = "Awkward"
    case blessed = "Blessed"
    case bored = "Bored"
    case busy = "Busy"
    case calm = "Calm"
    case cautious = "Cautious"
    case confident = "Confident"
    case confused = "Confused"
    case content = "Content"
    case courageous = "Courageous"
    case crappy = "Crappy"
    case crazy = "Crazy"
    case defeated = "Defeated"
    case depressed = "Depressed"
    case determined = "Determined"
    case disappointed = "Disappointed"
    case driven = "Driven"
    case excited = "Excited"
    case exhausted = "Exhausted"
    case fine = "Fine"
    case frustrated = "Frustrated"
    case good = "Good"
    case grateful = "Grateful"
    case grief = "Grief"
    case grumpy = "Grumpy"

    var emoji: String {
        switch self {
        case .accomplished: return "🏆"
        case .ambitious: return "🚀"
        case .angry: return "😡"
        case .annoyed: return "🙄"
        case .anxious: return "😰"
        case .appreciated: return "🥺"
        case .ashamed: return "😣"
        case .awkward: return "😬"
        case .blessed: return "🙏"
        case .bored: return "😑"
        case .busy: return "🥴"
        case .calm: return "😌"
        case .cautious: return "😟"
        case .confident: return "😎"
        case .confused: return "🤔"
        case .content: return "🙂"
        case .courageous: return "💪"
        case .crappy: return "💩"
        case .crazy: return "🤪"
        case .defeated: return "🏳"
        case .depressed: return "😞"
        case .determined: return "🔥"
        case .disappointed: return "☹️"
        case .driven: return "⚡️"
        case .excited: return "🤩"
        case .exhausted: return "😮‍💨"
        case .fine: return "😐"
        case .frustrated: return "😤"
        case .good: return "😇"
        case .grateful: return "🥰"
        case .grief: return "💔"
        case .grumpy: return "😠"
        }
    }
}

enum ActivityOption: String, Codable, CaseIterable {
    case work = "Work"
    case family = "Family"
    case friends = "Friends"
    case group = "Group"
    case dating = "Dating"
    case exercising = "Exercising"
    case school = "School"
    case hobbies = "Hobbies"
    case relaxing = "Relaxing"
    case chores = "Chores"
    case chilling = "Chilling"
}

struct PledgeReview: Codable {
    let id: UUID
    let date: Date
    let addictionId: UUID
    let stayedSober: Bool
    let difficultyLevel: DifficultyLevel?
    let moods: [MoodOption]
    let activities: [ActivityOption]
    let notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        addictionId: UUID,
        stayedSober: Bool,
        difficultyLevel: DifficultyLevel? = nil,
        moods: [MoodOption] = [],
        activities: [ActivityOption] = [],
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.addictionId = addictionId
        self.stayedSober = stayedSober
        self.difficultyLevel = difficultyLevel
        self.moods = moods
        self.activities = activities
        self.notes = notes
    }
}
