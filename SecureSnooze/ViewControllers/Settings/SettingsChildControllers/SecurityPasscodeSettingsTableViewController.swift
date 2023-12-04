//
//  SecurityPasscodeTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class SecurityPasscodeSettingsTableViewController: UITableViewController {
    var settings = Settings()
    
    @IBOutlet weak var requirePasscodeToChangeSleepGoalSwitch: UISwitch!
    @IBOutlet weak var requirePasscodeToChangeRemindersSwitch: UISwitch!
    @IBOutlet weak var requirePasscodeToChangeAlarmSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    
    @IBAction func requirePasscodeToChangeSleepGoalSwitchChanged(_ sender: Any) {
        settings.requirePasscodeToChangeSleepGoal = requirePasscodeToChangeSleepGoalSwitch.isOn
    }
    @IBAction func requirePasscodeToChangeRemindersSwitchChanged(_ sender: Any) {
        settings.requirePasscodeToChangeReminderSettings = requirePasscodeToChangeRemindersSwitch.isOn
    }
    @IBAction func requirePasscodeToChangeAlarmSwitchChanged(_ sender: Any) {
        settings.requirePasscodeToChangeAlarm = requirePasscodeToChangeAlarmSwitch.isOn
    }
    @IBAction func changePasscodeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "changePasscodeTapped", sender: changePasscodeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        requirePasscodeToChangeSleepGoalSwitch.isOn = settings.requirePasscodeToChangeSleepGoal
        requirePasscodeToChangeRemindersSwitch.isOn = settings.requirePasscodeToChangeReminderSettings
        requirePasscodeToChangeAlarmSwitch.isOn = settings.requirePasscodeToChangeAlarm
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.saveSettings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeViewController {
            destinationViewController.creatingNewPasscode = true
            destinationViewController.nextScreenIdentifier = "newPasscodeSaved"
        }
    }
}
