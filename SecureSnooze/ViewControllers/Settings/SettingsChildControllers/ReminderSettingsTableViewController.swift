//
//  ReminderSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class ReminderSettingsTableViewController: UITableViewController {
    var settings: Settings = Settings()
    
    @IBOutlet weak var remindBeforeBedtimeStepper: UIStepper!
    @IBOutlet weak var remindBeforeBedtimeLabel: UILabel!
    
    @IBAction func remindBeforeBedtimeStepperChanged(_ sender: Any) {
        updateRemindBeforeBedtimeLabel(timeInterval: Int(remindBeforeBedtimeStepper.value))
        settings.reminderBeforeBedtimeIntervalMinutes = Int(remindBeforeBedtimeStepper.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        remindBeforeBedtimeStepper.value = Double(settings.reminderBeforeBedtimeIntervalMinutes)
        updateRemindBeforeBedtimeLabel(timeInterval: settings.reminderBeforeBedtimeIntervalMinutes)
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
