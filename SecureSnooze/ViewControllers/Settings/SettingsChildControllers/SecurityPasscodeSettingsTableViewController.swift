//
//  SecurityPasscodeTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class SecurityPasscodeSettingsTableViewController: UITableViewController {
    var settings = Settings() // the current settings
    
    @IBOutlet weak var requirePasscodeToChangeSleepGoalSwitch: UISwitch!
    @IBOutlet weak var requirePasscodeToChangeRemindersSwitch: UISwitch!
    @IBOutlet weak var requirePasscodeToChangeAlarmSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    
    // update settings when option changed
    @IBAction func requirePasscodeToChangeSleepGoalSwitchChanged(_ sender: Any) {
        settings.requirePasscodeToChangeSleepGoal = requirePasscodeToChangeSleepGoalSwitch.isOn
    }
    @IBAction func requirePasscodeToChangeRemindersSwitchChanged(_ sender: Any) {
        settings.requirePasscodeToChangeReminderSettings = requirePasscodeToChangeRemindersSwitch.isOn
    }
    @IBAction func requirePasscodeToChangeAlarmSwitchChanged(_ sender: Any) {
        settings.requirePasscodeToChangeAlarm = requirePasscodeToChangeAlarmSwitch.isOn
    }
    
    // go to passcode screen when change passcode button tapped
    @IBAction func changePasscodeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "changePasscodeTapped", sender: changePasscodeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disables row highlighting on tap
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update options to match settings
        requirePasscodeToChangeSleepGoalSwitch.isOn = settings.requirePasscodeToChangeSleepGoal
        requirePasscodeToChangeRemindersSwitch.isOn = settings.requirePasscodeToChangeReminderSettings
        requirePasscodeToChangeAlarmSwitch.isOn = settings.requirePasscodeToChangeAlarm
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // save current settings upon exiting
        settings.saveSettings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeViewController {
            // update passcode screen parameters before segue
            destinationViewController.creatingNewPasscode = true
            destinationViewController.nextScreenIdentifier = "newPasscodeSaved"
        }
    }
}
