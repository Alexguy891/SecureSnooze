//
//  SleepGoalSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class SleepGoalSettingsTableViewController: UITableViewController {
    var settings = Settings()
    var alarmNotificationManager = AlarmNotificationManager()
    
    @IBOutlet weak var sleepGoalStepper: UIStepper!
    @IBOutlet weak var sleepGoalLabel: UILabel!
    @IBOutlet weak var bedtimeDatePicker: UIDatePicker!
    
    @IBAction func sleepGoalStepperChanged(_ sender: Any) {
        sleepGoalLabel.text = "\(Int(sleepGoalStepper.value)) hrs"
        settings.sleepGoalHours = Int(sleepGoalStepper.value)
    }
    
    @IBAction func bedtimeDatePickerChanged(_ sender: Any) {
        settings.bedtime = bedtimeDatePicker.date
        alarmNotificationManager.descheduleReminder()
        alarmNotificationManager.scheduleBedtimeReminder(settings.bedtime, settings.reminderBeforeBedtimeIntervalMinutes, settings.enableBedtimeReminder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sleepGoalStepper.value = Double(settings.sleepGoalHours)
        sleepGoalLabel.text = "\(settings.sleepGoalHours) hrs"
        bedtimeDatePicker.date = settings.bedtime
        alarmNotificationManager.loadAlarmNotificationManager()
        alarmNotificationManager.loadSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.saveSettings()
    }
}
