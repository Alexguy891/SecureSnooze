//
//  Settings.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//
import Foundation

class Settings: Codable {
    var sleepGoalHours: Int = 2
    var bedtime: Date = Date()
    var enableBedtimeReminder: Bool = false
    var reminderBeforeBedtimeIntervalMinutes: Int = 15
    var requirePasscodeToChangeSleepGoal: Bool = false
    var requirePasscodeToChangeReminderSettings: Bool = false
    var requirePasscodeToChangeAlarm: Bool = false
    
    init () { }
    
    init(sleepGoalHours: Int, bedtime: Date, enableBedtimeReminder: Bool, reminderBeforeBedtimeIntervalMinutes: Int, requirePasscodeToChangeSleepGoal: Bool, requirePasscodeToChangeReminderSettings: Bool, requirePasscodeToChangeAlarm: Bool) {
        self.sleepGoalHours = sleepGoalHours
        self.bedtime = bedtime
        self.enableBedtimeReminder = enableBedtimeReminder
        self.reminderBeforeBedtimeIntervalMinutes = reminderBeforeBedtimeIntervalMinutes
        self.requirePasscodeToChangeSleepGoal = requirePasscodeToChangeSleepGoal
        self.requirePasscodeToChangeReminderSettings = requirePasscodeToChangeReminderSettings
        self.requirePasscodeToChangeAlarm = requirePasscodeToChangeAlarm
    }
    
    func saveSettings() {
        print("Settings saveSettings()")
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.settings.rawValue)
        } catch {
            print("Error encoding settings: \(error)")
        }
    }
    
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
            // print failure and return empty array if cast fails
            print("Failed to load settings from UserDefaults")
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
