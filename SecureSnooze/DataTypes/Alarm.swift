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
    
    // returns name of the sound
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
    var time: Date = Date() // time to trigger alarm
    var sound: AlarmSound = .sound1 // alarm sound to play
    var canSnooze: Bool = true // whether the alarm can be snoozed
    var limitSnoozes: Bool = false // whether the alarm can be snoozed only a set amount of times
    var snoozeTries: Int = 1 // number of times the user can snooze the alarm
    var snoozeLength: Int = 5 // the length in minutes of each snooze
    var requiresPasscodeToSnooze = false // whether the alarm needs the passcode to snooze
    
    // for default initialization
    init() {
        
    }
    
    // regular initializer
    init(time: Date, sound: AlarmSound, canSnooze: Bool, limitSnoozes: Bool, snoozeTries: Int, snoozeLength: Int, requiresPasscodeToSnooze: Bool = false) {
        self.time = time
        self.sound = sound
        self.canSnooze = canSnooze
        self.limitSnoozes = limitSnoozes
        self.snoozeTries = snoozeTries
        self.snoozeLength = snoozeLength
        self.requiresPasscodeToSnooze = requiresPasscodeToSnooze
    }
    
    // load last set alarm
    func loadAlarm() {
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
    
    // save current alarm
    func saveAlarm() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.alarm.rawValue)
        } catch {
            print("Error encoding alarm: \(error)")
        }
    }
}
