//
//  ReminderSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class ReminderSettingsTableViewController: UITableViewController {
    var settings: Settings = Settings() // the current settings
    var alarmNotificationManager: AlarmNotificationManager = AlarmNotificationManager() // the current alarm notification manager
    
    @IBOutlet weak var remindBeforeBedtimeStepper: UIStepper!
    @IBOutlet weak var remindBeforeBedtimeLabel: UILabel!
    @IBOutlet weak var enableBedtimeReminderSwitch: UISwitch!
    
    // when the remindBeforeBedtime stepper is modified
    @IBAction func remindBeforeBedtimeStepperChanged(_ sender: Any) {
        // update label
        updateRemindBeforeBedtimeLabel(timeInterval: Int(remindBeforeBedtimeStepper.value))
        
        // update settings
        settings.reminderBeforeBedtimeIntervalMinutes = Int(remindBeforeBedtimeStepper.value)
        
        // reschedule reminders with new interval
        alarmNotificationManager.descheduleReminder()
        alarmNotificationManager.scheduleBedtimeReminder(settings.bedtime, settings.reminderBeforeBedtimeIntervalMinutes, settings.enableBedtimeReminder)
    }
    
    // when the enable bedtime reminder switch is modified
    @IBAction func enableBedtimeReminderSwitchChanged(_ sender: Any) {
        // update settings
        settings.enableBedtimeReminder = enableBedtimeReminderSwitch.isOn
        
        // allow changing stepper when switch is on
        remindBeforeBedtimeStepper.isEnabled = enableBedtimeReminderSwitch.isOn
        
        // reschedule reminders
        alarmNotificationManager.descheduleReminder()
        alarmNotificationManager.scheduleBedtimeReminder(settings.bedtime, settings.reminderBeforeBedtimeIntervalMinutes, settings.enableBedtimeReminder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disables row highlighting on tap
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update options with settings
        enableBedtimeReminderSwitch.isOn = settings.enableBedtimeReminder
        remindBeforeBedtimeStepper.value = Double(settings.reminderBeforeBedtimeIntervalMinutes)
        updateRemindBeforeBedtimeLabel(timeInterval: settings.reminderBeforeBedtimeIntervalMinutes)
        
        // enable stepper if reminder is enabled
        remindBeforeBedtimeStepper.isEnabled = enableBedtimeReminderSwitch.isOn
        
        // load current alarm notification manager
        alarmNotificationManager.loadAlarmNotificationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // save current settings upon exiting
        settings.saveSettings()
    }
    
    func updateRemindBeforeBedtimeLabel(timeInterval: Int) {
        // update time interval label with minutes or hours units depending on amount
        if timeInterval < 60 {
            remindBeforeBedtimeLabel.text = "\(timeInterval) mins"
        } else {
            let timeIntervalInHours = Double(timeInterval) / 60.0
            remindBeforeBedtimeLabel.text = "\(timeIntervalInHours) hrs"
        }
    }
}
