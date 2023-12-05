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
    var settings: Settings = Settings()
    var currentlyEditing: Bool = false
    
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
        updateEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // for debugging
        print("AlarmSettingsTableViewController viewWillAppear()")
        
        alarm.loadAlarm()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        settings.loadSettings()
        currentlyEditing = false
        setEditing()
        updateEditButton()
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
            destinationViewController.hidesBottomBarWhenPushed = true
        } else if let destinationViewController = segue.destination as? SessionViewController {
            destinationViewController.alarm = alarm
            destinationViewController.hidesBottomBarWhenPushed = true
        } else if let destinationViewController = segue.destination as? PasscodeViewController {
            destinationViewController.creatingNewPasscode = false
            destinationViewController.dismissalCallback = {
                self.currentlyEditing = true
                self.setEditing()
                self.updateEditButton()
            }
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
        alarmSnoozeLimitSwitch.isEnabled = alarm.canSnooze && currentlyEditing
        alarmSnoozeAttemptsStepper.isEnabled = (alarm.canSnooze && alarm.limitSnoozes && currentlyEditing)
        alarmSnoozeLengthStepper.isEnabled = alarm.canSnooze && currentlyEditing
        alarmSnoozePasscodeSwitch.isEnabled = alarm.canSnooze && currentlyEditing
    }
    
    func setEditing() {
        alarmSoundLabel.isEnabled = currentlyEditing
        alarmSnoozeSwitch.isEnabled = currentlyEditing
        toggleSnoozeOptions()
        alarmReminderSwitch.isEnabled = currentlyEditing
        alarmDatePicker.isEnabled = currentlyEditing
    }
    
    func updateEditButton() {
        let newEditButton = UIBarButtonItem(title: currentlyEditing ? "Done" : "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.leftBarButtonItem = newEditButton
    }
    
    @objc func startButtonTapped() {
        alarmNotificationManager.scheduleAlarm(alarm)
        performSegue(withIdentifier: "startButtonTapped", sender: self)
    }
    
    @objc func editButtonTapped() {
        if settings.requirePasscodeToChangeAlarm && !currentlyEditing {
            performSegue(withIdentifier: "alarmEditTapped", sender: self)
        } else if !settings.requirePasscodeToChangeAlarm && !currentlyEditing {
            currentlyEditing = true
            setEditing()
            updateEditButton()
        }
        else {
            currentlyEditing = false
            setEditing()
            updateEditButton()
        }
    }
}
