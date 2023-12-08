import UIKit

class SettingsTableViewController: UITableViewController {
    var settings = Settings() // the current settings
    var passcode = Passcode() // the current passcode
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get current settings
        settings.loadSettings()
        
        // get current passcode
        passcode.loadPasscode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // save current settings on exit
        settings.saveSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // deselect all rows after leaving
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    // when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected row
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        // check which cell was selected by reuseidentifier
        switch selectedCell?.reuseIdentifier {
        case "sleepGoal":
            // check if passcode needed before going to screen
            if settings.requirePasscodeToChangeSleepGoal {
                performSegue(withIdentifier: "sleepGoalPasscode", sender: selectedCell)
            } else {
                performSegue(withIdentifier: "sleepGoalTapped", sender: selectedCell)
            }
        case "reminders":
            // check if passcode needed before going to screen
            if settings.requirePasscodeToChangeReminderSettings {
                performSegue(withIdentifier: "reminderPasscode", sender: selectedCell)
            } else {
                performSegue(withIdentifier: "reminderTapped", sender: selectedCell)
            }
        case "securityPasscode":
            // check if passcode exists before going to screen
            if passcode.passcode == "" {
                performSegue(withIdentifier: "securityPasscodeTapped", sender: selectedCell)
            } else {
                performSegue(withIdentifier: "securityPasscode", sender: selectedCell)
            }
        // go to extra security steps screen
        case "extraSecuritySteps":
            performSegue(withIdentifier: "extraSecurityStepsTapped", sender: selectedCell)
        default:
            performSegue(withIdentifier: "sleepGoalTapped", sender: selectedCell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // go to settings screen tapped and update parameters
        if let destinationViewController = segue.destination as? SleepGoalSettingsTableViewController {
            destinationViewController.settings = settings
            destinationViewController.hidesBottomBarWhenPushed = true
        } else if let destinationViewController = segue.destination as? ReminderSettingsTableViewController {
            destinationViewController.settings = settings
            destinationViewController.hidesBottomBarWhenPushed = true
        } else if let destinationViewController = segue.destination as? SecurityPasscodeSettingsTableViewController {
            destinationViewController.settings = settings
            destinationViewController.hidesBottomBarWhenPushed = true
        // check if going to passcode screen
        } else if let destinationViewController = segue.destination as? PasscodeViewController {
            // go to proper screen if passcode entered
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
}
