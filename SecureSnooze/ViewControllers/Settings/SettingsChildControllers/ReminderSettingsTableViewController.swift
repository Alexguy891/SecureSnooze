//
//  ReminderSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class ReminderSettingsTableViewController: UITableViewController {
    var settings: Settings = Settings()
    var alarmNotificationManager: AlarmNotificationManager = AlarmNotificationManager()
    
    @IBOutlet weak var remindBeforeBedtimeStepper: UIStepper!
    @IBOutlet weak var remindBeforeBedtimeLabel: UILabel!
    @IBOutlet weak var enableBedtimeReminderSwitch: UISwitch!
    
    @IBAction func remindBeforeBedtimeStepperChanged(_ sender: Any) {
        updateRemindBeforeBedtimeLabel(timeInterval: Int(remindBeforeBedtimeStepper.value))
        settings.reminderBeforeBedtimeIntervalMinutes = Int(remindBeforeBedtimeStepper.value)
        alarmNotificationManager.descheduleReminder()
        alarmNotificationManager.scheduleBedtimeReminder(settings.bedtime, settings.reminderBeforeBedtimeIntervalMinutes, settings.enableBedtimeReminder)
    }
    @IBAction func enableBedtimeReminderSwitchChanged(_ sender: Any) {
        settings.enableBedtimeReminder = enableBedtimeReminderSwitch.isOn
        remindBeforeBedtimeStepper.isEnabled = enableBedtimeReminderSwitch.isOn
        alarmNotificationManager.descheduleReminder()
        alarmNotificationManager.scheduleBedtimeReminder(settings.bedtime, settings.reminderBeforeBedtimeIntervalMinutes, settings.enableBedtimeReminder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enableBedtimeReminderSwitch.isOn = settings.enableBedtimeReminder
        remindBeforeBedtimeStepper.isEnabled = enableBedtimeReminderSwitch.isOn
        remindBeforeBedtimeStepper.value = Double(settings.reminderBeforeBedtimeIntervalMinutes)
        updateRemindBeforeBedtimeLabel(timeInterval: settings.reminderBeforeBedtimeIntervalMinutes)
        alarmNotificationManager.loadAlarmNotificationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.saveSettings()
    }
    
    func updateRemindBeforeBedtimeLabel(timeInterval: Int) {
        if timeInterval < 60 {
            remindBeforeBedtimeLabel.text = "\(timeInterval) mins"
        } else {
            let timeIntervalInHours = Double(timeInterval) / 60.0
            remindBeforeBedtimeLabel.text = "\(timeIntervalInHours) hrs"
        }
    }
}
