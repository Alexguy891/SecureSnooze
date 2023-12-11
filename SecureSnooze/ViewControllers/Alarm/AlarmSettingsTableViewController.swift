//
//  AlarmSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

class AlarmSettingsTableViewController: UITableViewController {
    @IBOutlet weak var alarmSoundLabel: UILabel!
    @IBOutlet weak var alarmSnoozeSwitch: UISwitch!
    @IBOutlet weak var alarmSnoozeLimitSwitch: UISwitch!
    @IBOutlet weak var alarmSnoozeAttemptsStepper: UIStepper!
    @IBOutlet weak var alarmSnoozesAttemptsLabel: UILabel!
    @IBOutlet weak var alarmSnoozeLengthStepper: UIStepper!
    @IBOutlet weak var alarmSnoozeLengthLabel: UILabel!
    @IBOutlet weak var alarmSnoozePasscodeSwitch: UISwitch!
    @IBOutlet weak var alarmDatePicker: UIDatePicker!
    
    var alarm: Alarm = Alarm() // the current alarm
    var alarmNotificationManager = AlarmNotificationManager() // the current alarm notification manager
    var settings: Settings = Settings() // the current settings
    var currentlyEditing: Bool = false // if the screen is currently editable
    var firstTimeOpen = false // check if the user opened the app for the first time
    
    // update alarm to current options and update any labels
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
    @IBAction func alarmDatePickerChanged(_ sender: Any) {
        alarm.time = alarmDatePicker.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create start button
        let startButton = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startButtonTapped))
        navigationItem.rightBarButtonItem = startButton
        
        // update the edit button
        updateEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check if user has never opened app
        loadFirstTimeOpen()
        // show welcome screen if user has never opened app
        if firstTimeOpen {
            performSegue(withIdentifier: "showWelcomeScreen", sender: self)
        }
        
        // get current alarm
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
        alarmDatePicker.date = alarm.time
        
        // enable snooze options depending on snooze toggle
        toggleSnoozeOptions()
        
        // get current alarm notification manager
        alarmNotificationManager.loadAlarmNotificationManager()
        
        // update alarm notification manager alarm
        alarmNotificationManager.alarm.loadAlarm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // get current settings
        settings.loadSettings()
        
        // disable editing
        currentlyEditing = false
        // update options isEnabled
        setEditing()
        // change edit button
        updateEditButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // save current alarm upon exit
        alarm.saveAlarm()
        
        // save current alarm notification manager upon exit
        alarmNotificationManager.saveAlarmNotificationManager()
        
        // save first time open value
        saveFirstTimeOpen()
    }
    
    // deselect rows after exiting
    override func viewDidDisappear(_ animated: Bool) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // update parameters for next screen
        if let destinationViewController = segue.destination as? SoundSettingsTableViewController {
            destinationViewController.alarm = alarm
            destinationViewController.hidesBottomBarWhenPushed = true
        } else if let destinationViewController = segue.destination as? SessionViewController {
            destinationViewController.alarm = alarm
            destinationViewController.hidesBottomBarWhenPushed = true
        } else if let destinationViewController = segue.destination as? PasscodeViewController {
            destinationViewController.creatingNewPasscode = false
            
            // update editing if passcode entered
            destinationViewController.dismissalCallback = {
                // enable editing
                self.currentlyEditing = true
                // update options isEnabled
                self.setEditing()
                // change edit button
                self.updateEditButton()
            }
        }
    }
    
    // open sound screen if sound row tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            if selectedCell.reuseIdentifier == "selectSound" {
                performSegue(withIdentifier: "soundsTapped", sender: selectedCell)
            }
        }
    }
    
    // enable/disable snooze options if snoozing is enabled/disabled
    func toggleSnoozeOptions() {
        alarmSnoozeLimitSwitch.isEnabled = alarm.canSnooze && currentlyEditing
        alarmSnoozeAttemptsStepper.isEnabled = (alarm.canSnooze && alarm.limitSnoozes && currentlyEditing)
        alarmSnoozeLengthStepper.isEnabled = alarm.canSnooze && currentlyEditing
        alarmSnoozePasscodeSwitch.isEnabled = alarm.canSnooze && currentlyEditing
    }
    
    // enable options if editing is enabled
    func setEditing() {
        alarmSnoozeSwitch.isEnabled = currentlyEditing
        toggleSnoozeOptions()
        alarmDatePicker.isEnabled = currentlyEditing
    }
    
    // change edit button to edit or done depending on editing
    func updateEditButton() {
        let newEditButton = UIBarButtonItem(title: currentlyEditing ? "Done" : "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.leftBarButtonItem = newEditButton
    }
    
    // when sleep session started
    @objc func startButtonTapped() {
        // schedule the alarm
        alarmNotificationManager.scheduleAlarm(alarm)
        
        // go to sleep session screen
        performSegue(withIdentifier: "startButtonTapped", sender: self)
    }
    
    // save first time open
    func saveFirstTimeOpen() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(firstTimeOpen)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.firstTimeOpen.rawValue)
        } catch {
            print("Error encoding settings: \(error)")
        }
    }
    
    // load first time open
    func loadFirstTimeOpen() {
        if let firstTimeOpenData = UserDefaults.standard.data(forKey: UserDefaultsKeys.firstTimeOpen.rawValue) {
            do {
                let decoder = JSONDecoder()
                try decoder.decode(Bool.self, from: firstTimeOpenData)
                firstTimeOpen = false
            } catch {
                print("Error decoding firstTimeOpen: \(error)")
            }
        } else {
            firstTimeOpen = true
        }
    }
    
    // when edit button tapped
    @objc func editButtonTapped() {
        // check if the user is not currently editing and if the user requires the passcode to edit alarms
        if settings.requirePasscodeToChangeAlarm && !currentlyEditing {
            // go to passcode screen
            performSegue(withIdentifier: "alarmEditTapped", sender: self)
        // check if user does not required passcodes to edit alarms and not currently editing
        } else if !settings.requirePasscodeToChangeAlarm && !currentlyEditing {
            // enabled editing
            currentlyEditing = true
            // update options isEnabled
            setEditing()
            // change edit button
            updateEditButton()
        }
        else {
            // enabled editing
            currentlyEditing = false
            // update options isEnabled
            setEditing()
            // change edit button
            updateEditButton()
        }
    }
}
