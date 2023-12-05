//
//  SessionAlarmViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import UIKit

class SessionAlarmViewController: UIViewController {
    var alarm = Alarm()
    var alarmNotificationManager = AlarmNotificationManager()
    var alarmEndCallback: ((String) -> Void)?

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func snoozeButton(_ sender: Any) {
        if alarm.requiresPasscodeToSnooze {
            performSegue(withIdentifier: "snoozePasscode", sender: self)
        } else {
            alarmNotificationManager.snoozeAlarm()
            dismiss(animated: true) {
                self.alarmEndCallback?("snooze")
            }
        }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        alarmNotificationManager.stopAlarm()
        dismiss(animated: true) {
            self.alarmEndCallback?("stop")
        }
    }
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeLabel.text = dateFormatter.string(from: alarm.time)
        
        if (alarmNotificationManager.snoozeAmount >= alarm.snoozeTries && alarm.limitSnoozes) || !alarm.canSnooze {
            snoozeButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeViewController {
            destinationViewController.creatingNewPasscode = false
            destinationViewController.dismissalCallback = {
                self.alarmNotificationManager.snoozeAlarm()
                self.dismiss(animated: true) {
                    self.alarmEndCallback?("snooze")
                }
            }
        }
    }
}
