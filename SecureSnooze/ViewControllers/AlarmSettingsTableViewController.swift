//
//  AlarmSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

class AlarmSettingsTableViewController: UITableViewController {
    // all options that change or are interactable
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
    @IBOutlet weak var alarmDatePicker: UIDatePicker!
    
    // selected alarm
    var alarms: Alarms = Alarms()
    var selectedAlarmIndex: Int = 0
    var alarm: Alarm = Alarm()
    
    // update alarm based on setting change
    @IBAction func alarmNameChanged(_ sender: Any) {
        alarm.name = alarmNameLabel.text ?? ""
        print(alarm.name)
    }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // for debugging
        print("AlarmSettingsTableViewController viewWillAppear()")
        
        // getting the sent alarm from the table
        if selectedAlarmIndex != -1 {
            alarm = alarms.alarms[selectedAlarmIndex]
        }
        
        // applying all views to hold current alarm settings
        alarmRepeatsLabel.text = updateRepeatLabel()
        alarmNameLabel.text = alarm.name
        alarmSoundLabel.text = String(describing: alarm.sound)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // for debugging
        print("AlarmSettingsTableViewController viewWillDisappear()")
        
        if selectedAlarmIndex != -1 {
            alarms.alarms[selectedAlarmIndex] = alarm
        } else {
            alarms.alarms.append(alarm)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? AlarmsTableViewController {
            print("passing alarms array")
            destinationViewController.alarms = alarms
        }
    }
    
    // returns appropriate string for selected repeated options
    func updateRepeatLabel() -> String {
        let weekdays: [DaysOfTheWeek] = [.friday, .monday, .thursday, .tuesday, .wednesday]
        let weekends: [DaysOfTheWeek] = [.saturday, .sunday]
        
        // sorts selected repeats
        let sortedDaysToRepeat: [DaysOfTheWeek] = alarm.daysToRepeat.sorted { $0.rawValue < $1.rawValue }
        
        // returns string dependnent on length of selected repeats
        switch sortedDaysToRepeat.count {
        case 0:
            return "Never"
        case 1:
            return sortedDaysToRepeat.first?.rawValue ?? "Monday"
        case 2:
            if sortedDaysToRepeat.elementsEqual(weekends) {
                return "Weekends"
            }
            
            return "Custom"
        case 5:
            if sortedDaysToRepeat.elementsEqual(weekdays) {
                return "Weekdays"
            }
            
            return "Custom"
        case 7:
            return "Everyday"
        default:
            return "Custom"
        }
    }
    
    func toggleSnoozeOptions() {
        alarmSnoozeLimitSwitch.isEnabled = alarm.canSnooze
        alarmSnoozeAttemptsStepper.isEnabled = (alarm.canSnooze && alarm.limitSnoozes)
        alarmSnoozeLengthStepper.isEnabled = alarm.canSnooze
        alarmSnoozePasscodeSwitch.isEnabled = alarm.canSnooze
    }
}
