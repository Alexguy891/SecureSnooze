//
//  Alarm.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import Foundation

// all possible days of the week options
enum DaysOfTheWeek: String, CaseIterable, Codable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

// all stored alarm sounds
enum AlarmSound: String, CaseIterable, Codable {
    case sound1 = "sound1.mp3"
    case sound2 = "sound2.mp3"
    case sound3 = "sound3.mp3"
}

// alarm object
class Alarm: Codable {
    // alarm params
    var time: Date = Date()
    var name: String = "Alarm"
    var sound: AlarmSound = .sound1
    var canSnooze: Bool = true
    var limitSnoozes: Bool = false
    var snoozeTries: Int = 1
    var snoozeLength: Int = 5
    var daysToRepeat: [DaysOfTheWeek] = []
    var enableReminder: Bool = false
    var requiresPasscodeToSnooze = false
    
    // for default init
    init() {
        
    }
    
    // regular init
    init(time: Date, name: String, sound: AlarmSound, canSnooze: Bool, limitSnoozes: Bool, snoozeTries: Int, snoozeLength: Int, daysToRepeat: [DaysOfTheWeek], enableReminder: Bool, requiresPasscodeToSnooze: Bool = false) {
        self.time = time
        self.name = name
        self.sound = sound
        self.canSnooze = canSnooze
        self.limitSnoozes = limitSnoozes
        self.snoozeTries = snoozeTries
        self.snoozeLength = snoozeLength
        self.daysToRepeat = daysToRepeat
        self.enableReminder = enableReminder
        self.requiresPasscodeToSnooze = requiresPasscodeToSnooze
    }
    
    // returns time param formatted
    func getTimeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
}

class Alarms {
    var alarms: [Alarm] = []
    
    init() {
        
    }
    
    init(alarms: [Alarm]) {
        self.alarms = alarms
    }
}
