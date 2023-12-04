//
//  AlarmSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

class AlarmSettingsTableViewController: UITableViewController {
    // all options that change or are interactable
    @IBOutlet weak var alarmSoundLabel: UILabel!
    @IBOutlet weak var alarmSnoozeSwitch: UISwitch!
    @IBOutlet weak var alarmSnoozeLimitSwitch: UISwitch!
    @IBOutlet weak var alarmSnoozeAttemptsStepper: UIStepper!
    @IBOutlet weak var alarmSnoozesAttemptsLabel: UILabel!
    @IBOutlet weak var alarmSnoozeLengthStepper: UIStepper!
    @IBOutlet weak var alarmSnoozeLengthLabel: UILabel!
    @IBOutlet weak var alarmSnoozePasscodeSwitch: UISwitch!
    @IBOutlet weak var alarmReminderSwitch: UISwitch!
    @IBOutlet weak var alarmDatePicker: UIDatePicker!
    
    // selected alarm
    var alarm: Alarm = Alarm()
    var alarmNotificationManager = AlarmNotificationManager()
    
    @IBAction func alarmSnoozeSwitchChanged(_ sender: Any) {
        alarm.canSnooze = alarmSnoozeSwitch.isOn
        toggleSnoozeOptions()
    }
    @IBAction func alarmSnoozeLimitSwitchChanged(_ sender: Any) {
        alarm.limitSnoozes = alarmSnoozeLimitSwitch.isOn
        toggleSnoozeOptions()
    }
    @IBAction func alarmSnoozeAttemptsStepperChanged(_ sender: Any) {
        alarm.snoozeTries = Int(alarmSnoozeAttemptsStepper.value)
        alarmSnoozesAttemptsLabel.text = String(Int(alarmSnoozeAttemptsStepper.value))
    }
    @IBAction func alarmSnoozeLengthStepperChanged(_ sender: Any) {
        alarm.snoozeLength = Int(alarmSnoozeLengthStepper.value)
        alarmSnoozeLengthLabel.text = String("\(Int(alarmSnoozeLengthStepper.value)) min")
    }
    @IBAction func alarmSnoozePasscodeSwitchChanged(_ sender: Any) {
        alarm.requiresPasscodeToSnooze = alarmSnoozePasscodeSwitch.isOn
    }
    @IBAction func alarmReminderSwitchChanged(_ sender: Any) {
        alarm.enableReminder = alarmReminderSwitch.isOn
    }
    @IBAction func alarmDatePickerChanged(_ sender: Any) {
        alarm.time = alarmDatePicker.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let startButton = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startButtonTapped))
        navigationItem.rightBarButtonItem = startButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // for debugging
        print("AlarmSettingsTableViewController viewWillAppear()")
        
        // applying all views to hold current alarm settings
        alarmSoundLabel.text = alarm.sound.getSoundName()
        alarmSnoozeSwitch.isOn = alarm.canSnooze
        alarmSnoozeLimitSwitch.isOn = alarm.limitSnoozes
        alarmSnoozesAttemptsLabel.text = String(Int(alarm.snoozeTries))
        alarmSnoozeAttemptsStepper.value = Double(alarm.snoozeTries)
        alarmSnoozeLengthLabel.text = String("\(Int(alarm.snoozeLength)) min")
        alarmSnoozeLengthStepper.value = Double(alarm.snoozeLength)
        alarmSnoozePasscodeSwitch.isOn = alarm.requiresPasscodeToSnooze
        alarmReminderSwitch.isOn = alarm.enableReminder
        alarmDatePicker.date = alarm.time
        
        // enable snooze options depending on snooze toggle
        toggleSnoozeOptions()
        alarmNotificationManager.loadAlarmNotificationManager()
        alarmNotificationManager.alarm.loadAlarm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // for debugging
        print("AlarmSettingsTableViewController viewWillDisappear()")
        alarm.saveAlarm()
        alarmNotificationManager.saveAlarmNotificationManager()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SoundSettingsTableViewController {
            destinationViewController.alarm = alarm
        } else if let destinationViewController = segue.destination as? SessionViewController {
            destinationViewController.alarm = alarm
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            if selectedCell.reuseIdentifier == "repeatSelection" {
                performSegue(withIdentifier: "repeatsTapped", sender: selectedCell)
            } else if selectedCell.reuseIdentifier == "selectSound" {
                performSegue(withIdentifier: "soundsTapped", sender: selectedCell)
            }
        }
    }
    
    func toggleSnoozeOptions() {
        alarmSnoozeLimitSwitch.isEnabled = alarm.canSnooze
        alarmSnoozeAttemptsStepper.isEnabled = (alarm.canSnooze && alarm.limitSnoozes)
        alarmSnoozeLengthStepper.isEnabled = alarm.canSnooze
        alarmSnoozePasscodeSwitch.isEnabled = alarm.canSnooze
    }
    
    @objc func startButtonTapped() {
        alarmNotificationManager.scheduleAlarm(alarm)
        performSegue(withIdentifier: "startButtonTapped", sender: self)
    }
}
