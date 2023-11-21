//
//  AlarmSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

class AlarmSettingsTableViewController: UITableViewController {
    @IBOutlet weak var alarmRepeatsLabel: UILabel!
    @IBOutlet weak var alarmNameLabel: UITextField!
    @IBOutlet weak var alarmSoundLabel: UILabel!
    @IBOutlet weak var alarmSnoozeSwitch: UISwitch!
    @IBOutlet weak var alarmSnoozeLimitSwitch: UISwitch!
    @IBOutlet weak var alarmSnoozeAttemptsStepper: UIStepper!
    @IBOutlet weak var alarmSnoozesAttemptsLabel: UILabel!
    @IBOutlet weak var alarmSnoozeLengthStepper: UIStepper!
    @IBOutlet weak var alarmSnoozeLengthLabel: UILabel!
    @IBOutlet weak var alarmSnoozePasscodeSwitch: UISwitch!
    @IBOutlet weak var alarmReminderSwitch: UISwitch!
    var alarm: Alarm = Alarm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        <#code#>
    }
}
