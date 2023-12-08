//
//  Settings.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//
import Foundation

// holds all app settings
class Settings: Codable {
    var sleepGoalHours: Int = 2 // users sleep goal in hours
    var bedtime: Date = Date() // the users designated bedtime
    var enableBedtimeReminder: Bool = false // whether the user wants to receive bedtime reminders
    var reminderBeforeBedtimeIntervalMinutes: Int = 15 // how long before bedtime in minutes a bedtime reminder is sent
    var requirePasscodeToChangeSleepGoal: Bool = false // whether the passcode should be required to access the sleep goal settings screen
    var requirePasscodeToChangeReminderSettings: Bool = false // whether the passcode should be required to access the reminder settings screen
    var requirePasscodeToChangeAlarm: Bool = false // whether the passcode should be required after tapping the edit button the alarm screen
    
    // for default initialization
    init () { }
    
    // regular initializer
    init(sleepGoalHours: Int, bedtime: Date, enableBedtimeReminder: Bool, reminderBeforeBedtimeIntervalMinutes: Int, requirePasscodeToChangeSleepGoal: Bool, requirePasscodeToChangeReminderSettings: Bool, requirePasscodeToChangeAlarm: Bool) {
        self.sleepGoalHours = sleepGoalHours
        self.bedtime = bedtime
        self.enableBedtimeReminder = enableBedtimeReminder
        self.reminderBeforeBedtimeIntervalMinutes = reminderBeforeBedtimeIntervalMinutes
        self.requirePasscodeToChangeSleepGoal = requirePasscodeToChangeSleepGoal
        self.requirePasscodeToChangeReminderSettings = requirePasscodeToChangeReminderSettings
        self.requirePasscodeToChangeAlarm = requirePasscodeToChangeAlarm
    }
    
    // saves current settings
    func saveSettings() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.settings.rawValue)
        } catch {
            print("Error encoding settings: \(error)")
        }
    }
    
    // loads last settings
    func loadSettings() {
        if let settingsData = UserDefaults.standard.data(forKey: UserDefaultsKeys.settings.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedSettings = try decoder.decode(Settings.self, from: settingsData)
                sleepGoalHours = decodedSettings.sleepGoalHours
                bedtime = decodedSettings.bedtime
                enableBedtimeReminder = decodedSettings.enableBedtimeReminder
                reminderBeforeBedtimeIntervalMinutes = decodedSettings.reminderBeforeBedtimeIntervalMinutes
                requirePasscodeToChangeSleepGoal = decodedSettings.requirePasscodeToChangeSleepGoal
                requirePasscodeToChangeReminderSettings = decodedSettings.requirePasscodeToChangeReminderSettings
                requirePasscodeToChangeAlarm = decodedSettings.requirePasscodeToChangeAlarm
            } catch {
                print("Error decoding settings array: \(error)")
            }
        } else {
            sleepGoalHours = 2
            bedtime = Date()
            enableBedtimeReminder = false
            reminderBeforeBedtimeIntervalMinutes = 15
            requirePasscodeToChangeSleepGoal = false
            requirePasscodeToChangeReminderSettings = false
            requirePasscodeToChangeAlarm = false
        }
    }
}
