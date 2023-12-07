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
    var notificationPermission = false
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var alarm: Alarm = Alarm()
    var settings: Settings = Settings()
    var snoozeAmount = 0
    let eventStore = EKEventStore()
    
    func requestNotificationPermission() {
        print("AlarmNotificationManager requestNotificationPermission()")
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            self.notificationPermission = granted
        }
    }
    
    func scheduleBedtimeReminder(_ bedtime: Date, _ interval: Int, _ enabled: Bool) {
        if !enabled {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        let bedtimeCategory = UNNotificationCategory(identifier: "bedtimeCategory", actions: [], intentIdentifiers: [], options: [])
        
        let calendar = Calendar.current
        let reminderTime = Calendar.current.date(byAdding: .minute, value: -interval, to: bedtime) ?? bedtime
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedBedtime = dateFormatter.string(from: bedtime)
        
        center.setNotificationCategories([bedtimeCategory])
        let content = UNMutableNotificationContent()
        content.title = "It's almost time for bed!"
        content.body = "Bedtime is set for \(formattedBedtime)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "bedtimeCategory"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "bedtimeReminder", content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            } else {
                print("Reminder scheduled successfully for Time: \(components), current time is: \(calendar.dateComponents([.hour, .minute], from: Date()))")
            }
        }
        
        addReminderToCalendar(bedtime: bedtime)
    }
    
    func descheduleReminder() {
        print("descheduleReminder()")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["bedtimeReminder"])
        removeRemindersFromCalendar()
    }
    
    func addReminderToCalendar(bedtime: Date) {
        print("addReminderToCalendar()")
        settings.loadSettings()
        eventStore.requestFullAccessToEvents(completion: { success, error in
            print("Asking for permission")
            if success, error == nil {
                print("Permission success")
                DispatchQueue.main.async {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: bedtime)
                    
                    let reminderEvent = EKEvent (eventStore: self.eventStore)
                    reminderEvent.title = "Bedtime"
                    let startDate = Calendar.current.date(bySetting: .hour, value: components.hour ?? 0, of: Date())
                    reminderEvent.startDate = Calendar.current.date(bySetting: .minute, value: components.minute ?? 0, of: startDate ?? Date())
                    reminderEvent.endDate = Calendar.current.date(byAdding: .hour, value: self.settings.sleepGoalHours, to: startDate ?? Date())
                    let eventController = EKEventViewController()
                    eventController.event = reminderEvent
                    
                    do {
                        try self.eventStore.save(reminderEvent, span: .thisEvent)
                        print("Bedtime event added to the calendar")
                    } catch {
                        print("Error saving event: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    func removeRemindersFromCalendar() {
        eventStore.requestFullAccessToEvents(completion: { success, error in
            print("Asking for permission")
            if success, error == nil {
                let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(365 * 24 * 60 * 60), calendars: nil)
                let events = self.eventStore.events(matching: predicate)
                
                for event in events {
                    if event.title == "Bedtime" {
                        do {
                            try self.eventStore.remove(event, span: .thisEvent)
                            print("Bedtime event removed from the calendar")
                        } catch {
                            print("Error removing event: \(error.localizedDescription)")
                        }
                    }
                }
            }
        })
    }
    
    func scheduleAlarm(_ alarm: Alarm) {
        print("AlarmNotificationManager scheduleAlarm()")
        let center = UNUserNotificationCenter.current()
        
        let alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([alarmCategory])
        
        let content = UNMutableNotificationContent()
        content.title = "Time to wake up!"
        content.body = "Your alarm is going off!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "alarmCategory"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
            
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "alarmNotification", content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    func descheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["alarmNotification"])
    }
    
    func startSleepSession() {
        stopAlarm()
        guard let soundURL = Bundle.main.url(forResource: "silence", withExtension: ".mp3") else {
            print("Error: Sound file not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
            
            if audioPlayer.isPlaying {
                print("Audio player is playing")
            } else {
                print("Audio player is not playing")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func playAlarm() {
        alarm.loadAlarm()
        stopAlarm()
        print("AlarmNotificationManager playAlarm()")
        
        // Get the URL of the sound file
        guard let soundURL = Bundle.main.url(forResource: alarm.sound.rawValue, withExtension: ".mp3") else {
            print("Error: Sound file not found")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
            
            if audioPlayer.isPlaying {
                print("Audio player is playing")
            } else {
                print("Audio player is not playing")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func snoozeAlarm() {
        alarm.loadAlarm()
        print("AlarmNotificationManager snoozeAlarm()")
        stopAlarm()
        snoozeAmount += 1
        let newAlarm = Alarm(time: alarm.time, sound: alarm.sound, canSnooze: alarm.canSnooze, limitSnoozes: alarm.limitSnoozes, snoozeTries: alarm.snoozeTries, snoozeLength: alarm.snoozeLength, enableReminder: alarm.enableReminder)
        newAlarm.time = Calendar.current.date(byAdding: .minute, value: newAlarm.snoozeLength, to: newAlarm.time) ?? Date()
        scheduleAlarm(newAlarm)
        alarm = newAlarm
        startSleepSession()
    }
    
    func stopAlarm() {
        print("AlarmNotificationManager stopAlarm()")
        audioPlayer.stop()
    }
    
    func saveAlarmNotificationManager() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.alarmNotificationManager.rawValue)
        } catch {
            print("Error encoding alarm notification manager: \(error)")
        }
    }
    
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
            // print failure and return empty array if cast fails
            print("Failed to load alarm notification manager from UserDefaults")
            self.notificationPermission = false
        }
    }
        
    func loadSettings() {
        settings.loadSettings()
    }
    
    enum CodingKeys: String, CodingKey {
        case notificationPermission
    }
}
