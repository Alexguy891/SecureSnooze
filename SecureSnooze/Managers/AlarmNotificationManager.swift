//
//  AlarmNotificationDelegate.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import Foundation
import UserNotifications
import AVFoundation
import EventKit
import EventKitUI

class AlarmNotificationManager: Codable {
    var notificationPermission = false // permission to present notifications
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer() // for alarm audio
    var alarm: Alarm = Alarm() // the current alarm
    var settings: Settings = Settings() // the current settings
    var snoozeAmount = 0 // number of times the user snoozed
    let eventStore = EKEventStore() // for calendar events
    
    // request permission for notifications
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            self.notificationPermission = granted
        }
    }
    
    // set reminder for bedtime
    func scheduleBedtimeReminder(_ bedtime: Date, _ interval: Int, _ enabled: Bool) {
        // exit scheduling if reminders are not enabled
        if !enabled {
            return
        }
        
        // get notification center
        let center = UNUserNotificationCenter.current()
        
        // create bedtime category for notifications
        let bedtimeCategory = UNNotificationCategory(identifier: "bedtimeCategory", actions: [], intentIdentifiers: [], options: [])
        
        // get hour and minutes for reminder trigger time
        let calendar = Calendar.current
        let reminderTime = Calendar.current.date(byAdding: .minute, value: -interval, to: bedtime) ?? bedtime
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // format bedtime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedBedtime = dateFormatter.string(from: bedtime)
        
        // set notification category
        center.setNotificationCategories([bedtimeCategory])
        
        // create notification
        let content = UNMutableNotificationContent()
        content.title = "It's almost time for bed!"
        content.body = "Bedtime is set for \(formattedBedtime)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "bedtimeCategory"
        
        // create notification trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // create notification request
        let request = UNNotificationRequest(identifier: "bedtimeReminder", content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            }
        }
        
        // add reminder to calendar
        addReminderToCalendar(bedtime: bedtime)
    }
    
    // disable all reminder notifications
    func descheduleReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["bedtimeReminder"])
        
        // remove all reminders from calendar
        removeRemindersFromCalendar()
    }
    
    // add reminder to calendar
    func addReminderToCalendar(bedtime: Date) {
        // load current settings
        settings.loadSettings()
        
        // request calendar access
        eventStore.requestFullAccessToEvents(completion: { success, error in
            // run if successful
            if success, error == nil {
                // perform on main process
                DispatchQueue.main.async {
                    // get hour and minute for reminder trigger
                    let components = Calendar.current.dateComponents([.hour, .minute], from: bedtime)
                    
                    // create reminder event
                    let reminderEvent = EKEvent (eventStore: self.eventStore)
                    reminderEvent.title = "Bedtime"
                    let startDate = Calendar.current.date(bySetting: .hour, value: components.hour ?? 0, of: Date())
                    reminderEvent.startDate = Calendar.current.date(bySetting: .minute, value: components.minute ?? 0, of: startDate ?? Date())
                    reminderEvent.endDate = Calendar.current.date(byAdding: .hour, value: self.settings.sleepGoalHours, to: startDate ?? Date())
                    
                    // add reminder event to calendar
                    let eventController = EKEventViewController()
                    eventController.event = reminderEvent
                    do {
                        try self.eventStore.save(reminderEvent, span: .thisEvent)
                    } catch {
                        print("Error saving event: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    // remove all reminders from calendar
    func removeRemindersFromCalendar() {
        // request calendar access
        eventStore.requestFullAccessToEvents(completion: { success, error in
            // run if successful
            if success, error == nil {
                // get all events from today to end of the year
                let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(365 * 24 * 60 * 60), calendars: nil)
                let events = self.eventStore.events(matching: predicate)
                
                // remove all events with title of Bedtime
                for event in events {
                    if event.title == "Bedtime" {
                        do {
                            try self.eventStore.remove(event, span: .thisEvent)
                        } catch {
                            print("Error removing event: \(error.localizedDescription)")
                        }
                    }
                }
            }
        })
    }
    
    // schedule alarm notification
    func scheduleAlarm(_ alarm: Alarm) {
        // get notification center
        let center = UNUserNotificationCenter.current()
        
        // create alarm notification category
        let alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [], intentIdentifiers: [], options: [])
        
        // set current notification category to alarmCategory
        center.setNotificationCategories([alarmCategory])
        
        // create alarm notification
        let content = UNMutableNotificationContent()
        content.title = "Time to wake up!"
        content.body = "Your alarm is going off!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "alarmCategory"
        
        // get hour and minute for the alarm time trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
            
        // create alarm trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // schedule notification
        let request = UNNotificationRequest(identifier: "alarmNotification", content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // remove all alarm notifications
    func descheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["alarmNotification"])
    }
    
    // start sleep session and check for alarm
    func startSleepSession() {
        // stop any previous alarm sound
        stopAlarm()
        
        // get silent audio
        guard let soundURL = Bundle.main.url(forResource: "silence", withExtension: ".mp3") else {
            print("Error: Sound file not found")
            return
        }
        
        // play silent audio indefinitely
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // play alarm sound
    func playAlarm() {
        // get current alarm settings
        alarm.loadAlarm()
        
        // stop any previous alarm sound
        stopAlarm()
        
        // get sound file
        guard let soundURL = Bundle.main.url(forResource: alarm.sound.rawValue, withExtension: ".mp3") else {
            print("Error: Sound file not found")
            return
        }
        
        // play alarm audio indefinitely
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // snooze current playing alarm
    func snoozeAlarm() {
        // get current alarm settings
        alarm.loadAlarm()
        
        // stop any previous alarm sounds
        stopAlarm()
        
        // increase number of times the user has snoozed
        snoozeAmount += 1
        
        // create copy of current alarm
        let newAlarm = Alarm(time: alarm.time, sound: alarm.sound, canSnooze: alarm.canSnooze, limitSnoozes: alarm.limitSnoozes, snoozeTries: alarm.snoozeTries, snoozeLength: alarm.snoozeLength, enableReminder: alarm.enableReminder)
        
        // set copied alarm time to the previous alarm time increased by the snooze length
        newAlarm.time = Calendar.current.date(byAdding: .minute, value: newAlarm.snoozeLength, to: newAlarm.time) ?? Date()
        
        // schedule the copied alarm
        scheduleAlarm(newAlarm)
        
        // set the current alarm to the copied alarm
        alarm = newAlarm
        
        // restart the sleep session
        startSleepSession()
    }
    
    // stop playing alarm sound
    func stopAlarm() {
        audioPlayer.stop()
    }
    
    // save the current alarm notification manager state
    func saveAlarmNotificationManager() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.alarmNotificationManager.rawValue)
        } catch {
            print("Error encoding alarm notification manager: \(error)")
        }
    }
    
    // load the last alarm notification manager state
    func loadAlarmNotificationManager() {
        if let alarmNotificationData = UserDefaults.standard.data(forKey: UserDefaultsKeys.alarmNotificationManager.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedAlarmNotificationData = try decoder.decode(AlarmNotificationManager.self, from: alarmNotificationData)
                self.notificationPermission = decodedAlarmNotificationData.notificationPermission
            } catch {
                print("Error decoding alarm notification manager: \(error)")
            }
        } else {
            self.notificationPermission = false
        }
    }
     
    // load current settings
    func loadSettings() {
        settings.loadSettings()
    }
    
    // saves only notificationPermission parameter in UserDefaults
    enum CodingKeys: String, CodingKey {
        case notificationPermission
    }
}
