//
//  SleepGoalSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class SleepGoalSettingsTableViewController: UITableViewController {
    var settings = Settings()
    
    @IBOutlet weak var sleepGoalStepper: UIStepper!
    @IBOutlet weak var sleepGoalLabel: UILabel!
    
    @IBAction func sleepGoalStepperChanged(_ sender: Any) {
        sleepGoalLabel.text = "\(Int(sleepGoalStepper.value)) hrs"
        settings.sleepGoalHours = Int(sleepGoalStepper.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sleepGoalStepper.value = Double(settings.sleepGoalHours)
        sleepGoalLabel.text = "\(settings.sleepGoalHours) hrs"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.saveSettings()
    }
}
