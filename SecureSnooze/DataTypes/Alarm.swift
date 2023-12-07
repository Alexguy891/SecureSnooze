//
//  Alarm.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import Foundation

// all stored alarm sounds
enum AlarmSound: String, CaseIterable, Codable {
    case sound1 = "digital"
    case sound2 = "analog"
    case sound3 = "future"
    
    func getSoundName() -> String {
        switch self {
        case .sound1:
            return "Digital"
        case .sound2:
            return "Analog"
        case .sound3:
            return "Future"
        }
    }
}

// alarm object
class Alarm: Codable {
    // alarm params
    var time: Date = Date()
    var sound: AlarmSound = .sound1
    var canSnooze: Bool = true
    var limitSnoozes: Bool = false
    var snoozeTries: Int = 1
    var snoozeLength: Int = 5
    var enableReminder: Bool = false
    var requiresPasscodeToSnooze = false
    
    // for default init
    init() {
        
    }
    
    // regular init
    init(time: Date, sound: AlarmSound, canSnooze: Bool, limitSnoozes: Bool, snoozeTries: Int, snoozeLength: Int, enableReminder: Bool, requiresPasscodeToSnooze: Bool = false) {
        self.time = time
        self.sound = sound
        self.canSnooze = canSnooze
        self.limitSnoozes = limitSnoozes
        self.snoozeTries = snoozeTries
        self.snoozeLength = snoozeLength
        self.enableReminder = enableReminder
        self.requiresPasscodeToSnooze = requiresPasscodeToSnooze
    }
    
    // returns time param formatted
    func getTimeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
    
    func loadAlarm() {
        print("loadAlarm()")
        // cast to array of alarm and return
        if let alarmData = UserDefaults.standard.data(forKey: UserDefaultsKeys.alarm.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedAlarm = try decoder.decode(Alarm.self, from: alarmData)
                self.time = decodedAlarm.time
                self.sound = decodedAlarm.sound
                self.canSnooze = decodedAlarm.canSnooze
                self.limitSnoozes = decodedAlarm.limitSnoozes
                self.snoozeTries = decodedAlarm.snoozeTries
                self.snoozeLength = decodedAlarm.snoozeLength
                self.requiresPasscodeToSnooze = decodedAlarm.requiresPasscodeToSnooze
            } catch {
                print("Error decoding alarm: \(error)")
            }
        }
    }
    
    func saveAlarm() {
        print("saveAlarm()")
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.alarm.rawValue)
        } catch {
            print("Error encoding alarm: \(error)")
        }
    }
}
