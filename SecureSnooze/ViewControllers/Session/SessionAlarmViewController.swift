//
//  SessionAlarmViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import UIKit

class SessionAlarmViewController: UIViewController {
    var alarm = Alarm() // the current alarm
    var alarmNotificationManager = AlarmNotificationManager() // the current alarm notification manager
    var alarmEndCallback: ((String) -> Void)? // returns which alarm ending option was selected

    @IBOutlet weak var timeLabel: UILabel!
    
    // when snooze button option tapped
    @IBAction func snoozeButton(_ sender: Any) {
        // check if the passcode is required to snooze
        if alarm.requiresPasscodeToSnooze {
            // go to passcode screen
            performSegue(withIdentifier: "snoozePasscode", sender: self)
        } else {
            // snooze the current alarm
            alarmNotificationManager.snoozeAlarm()
            
            // go back to the session screen
            dismiss(animated: true) {
                self.alarmEndCallback?("snooze")
            }
        }
    }
    
    // when stop button option tapped
    @IBAction func stopButton(_ sender: Any) {
        // stop any alarm sounds
        alarmNotificationManager.stopAlarm()
        
        // go back to the alarm setting screen
        dismiss(animated: true) {
            self.alarmEndCallback?("stop")
        }
    }
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide tab bar when shown
        hidesBottomBarWhenPushed = true
        
        // prevent swiping screen away
        isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // format alarm time label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeLabel.text = dateFormatter.string(from: alarm.time)
        
        // disable snooze button if snooze attempt limiting is enabled and the user ran out of attempts
        if (alarmNotificationManager.snoozeAmount >= alarm.snoozeTries && alarm.limitSnoozes) || !alarm.canSnooze {
            snoozeButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeViewController {
            // update passcode screen paramters
            destinationViewController.creatingNewPasscode = false
            
            // snooze the alarm if the passcode was correct
            destinationViewController.dismissalCallback = {
                self.alarmNotificationManager.snoozeAlarm()
                self.dismiss(animated: true) {
                    self.alarmEndCallback?("snooze")
                }
            }
        }
    }
}
