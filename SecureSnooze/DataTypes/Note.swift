import Foundation

// sleep moods user can choose
enum Mood: Int, CaseIterable, Codable {
    case veryBad = 1
    case bad = 2
    case okay = 3
    case good = 4
    case great = 5
    
    // returns name of the current mood
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

// holds sleep note data
class Note: Codable, Equatable {
    var date: Date = Date() // date the note represents
    var mood: Mood = .okay // the current sleep mood
    var text: String = "" // the users text in the note
    var timeAsleep: Date = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date() // the indicated time the user fell asleep
    var timeAwake: Date = Date() // the indicated time the user woke up
    
    // for default initialization
    init() { }
    
    // regular initializer
    init(date: Date, mood: Mood, text: String, timeAsleep: Date, timeAwake: Date) {
        self.date = date
        self.mood = mood
        self.text = text
        self.timeAsleep = timeAsleep
        self.timeAwake = timeAwake
    }
    
    // allowing usage of == operator
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.date == rhs.date && lhs.mood == rhs.mood && lhs.text == rhs.text && lhs.timeAsleep == rhs.timeAsleep && lhs.timeAwake == rhs.timeAwake
    }
}

// to have reference type array of notes
class Notes {
    var notes: [Note] = []
    
    init() { }
    
    init(notes: [Note]) {
        self.notes = notes
    }
}
