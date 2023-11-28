import Foundation

enum Mood: Int, CaseIterable, Codable {
    case veryBad = 1
    case bad = 2
    case okay = 3
    case good = 4
    case great = 5
    
    func getMoodName() -> String {
        switch self {
        case .veryBad:
            return "Very Bad"
        case .bad:
            return "Bad"
        case .okay:
            return "Okay"
        case .good:
            return "Good"
        case .great:
            return "Great"
        }
    }
}

class Note: Codable, Equatable {
    var date: Date = Date()
    var mood: Mood = .okay
    var text: String = ""
    var timeAsleep: Date = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date()
    var timeAwake: Date = Date()
    
    init() { }
    
    init(date: Date, mood: Mood, text: String, timeAsleep: Date, timeAwake: Date) {
        self.date = date
        self.mood = mood
        self.text = text
        self.timeAsleep = timeAsleep
        self.timeAwake = timeAwake
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.date == rhs.date && lhs.mood == rhs.mood && lhs.text == rhs.text && lhs.timeAsleep == rhs.timeAsleep && lhs.timeAwake == rhs.timeAwake
    }
}

class Notes {
    var notes: [Note] = []
    
    init() { }
    
    init(notes: [Note]) {
        self.notes = notes
    }
}
