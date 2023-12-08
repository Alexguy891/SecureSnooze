//
//  SleepGoalSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class SleepGoalSettingsTableViewController: UITableViewController {
    var settings = Settings() // the current settings
    var alarmNotificationManager = AlarmNotificationManager() // the current alarm notification manager
    
    @IBOutlet weak var sleepGoalStepper: UIStepper!
    @IBOutlet weak var sleepGoalLabel: UILabel!
    @IBOutlet weak var bedtimeDatePicker: UIDatePicker!
    
    // when the sleep goal stepper is modified
    @IBAction func sleepGoalStepperChanged(_ sender: Any) {
        // update the label
        sleepGoalLabel.text = "\(Int(sleepGoalStepper.value)) hrs"
        
        // set the settings
        settings.sleepGoalHours = Int(sleepGoalStepper.value)
    }
    
    // when the bedtime date picker is changed
    @IBAction func bedtimeDatePickerChanged(_ sender: Any) {
        // update the settings
        settings.bedtime = bedtimeDatePicker.date
        
        // reschedule reminders with new bedtime
        alarmNotificationManager.descheduleReminder()
        alarmNotificationManager.scheduleBedtimeReminder(settings.bedtime, settings.reminderBeforeBedtimeIntervalMinutes, settings.enableBedtimeReminder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disables row highlighting on tap
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update on screen options with settings
        sleepGoalStepper.value = Double(settings.sleepGoalHours)
        sleepGoalLabel.text = "\(settings.sleepGoalHours) hrs"
        bedtimeDatePicker.date = settings.bedtime
        alarmNotificationManager.loadAlarmNotificationManager()
        alarmNotificationManager.loadSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // save settings when closing
        settings.saveSettings()
    }
}
