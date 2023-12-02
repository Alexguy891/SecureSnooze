//
//  SettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var settings = Settings()
    var passcode = Passcode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSettings()
        passcode.loadPasscode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.saveSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected alarm
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        switch selectedCell?.reuseIdentifier {
        case "sleepGoal":
            if settings.requirePasscodeToChangeSleepGoal {
                performSegue(withIdentifier: "sleepGoalPasscode", sender: selectedCell)
            } else {
                performSegue(withIdentifier: "sleepGoalTapped", sender: selectedCell)
            }
        case "reminders":
            if settings.requirePasscodeToChangeReminderSettings {
                performSegue(withIdentifier: "reminderPasscode", sender: selectedCell)
            } else {
                performSegue(withIdentifier: "reminderTapped", sender: selectedCell)
            }
        case "securityPasscode":
            if passcode.passcode == "" {
                performSegue(withIdentifier: "securityPasscodeTapped", sender: selectedCell)
            } else {
                performSegue(withIdentifier: "securityPasscode", sender: selectedCell)
            }
        case "calendar":
            performSegue(withIdentifier: "calendarTapped", sender: selectedCell)
        case "extraSecuritySteps":
            performSegue(withIdentifier: "extraSecurityStepsTapped", sender: selectedCell)
        default:
            performSegue(withIdentifier: "sleepGoalTapped", sender: selectedCell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SleepGoalSettingsTableViewController {
            destinationViewController.settings = settings
        } else if let destinationViewController = segue.destination as? ReminderSettingsTableViewController {
            destinationViewController.settings = settings
        } else if let destinationViewController = segue.destination as? SecurityPasscodeSettingsTableViewController {
            destinationViewController.settings = settings
        } else if let destinationViewController = segue.destination as? CalendarSettingsTableViewController {
            destinationViewController.settings = settings
        } else if let destinationViewController = segue.destination as? PasscodeViewController {
            if segue.identifier == "sleepGoalPasscode" {
                destinationViewController.dismissalCallback = {
                    self.performSegue(withIdentifier: "sleepGoalTapped", sender: sender)
                }
            } else if segue.identifier == "reminderPasscode" {
                destinationViewController.dismissalCallback = {
                    self.performSegue(withIdentifier: "reminderTapped", sender: sender)
                }
            } else if segue.identifier == "securityPasscode" {
                destinationViewController.dismissalCallback = {
                    self.performSegue(withIdentifier: "securityPasscodeTapped", sender: sender)
                }
            }
        }
    }
    
    func loadSettings() {
        print("SettingsTableViewController loadSettings()")
        if let settingsData = UserDefaults.standard.data(forKey: UserDefaultsKeys.settings.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedSettings = try decoder.decode(Settings.self, from: settingsData)
                settings = decodedSettings
            } catch {
                print("Error decoding settings array: \(error)")
            }
        } else {
            // print failure and return empty array if cast fails
            print("Failed to load settings from UserDefaults")
            settings = Settings()
        }
    }
}
