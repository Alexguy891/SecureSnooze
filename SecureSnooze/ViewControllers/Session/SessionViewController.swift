//
//  SessionViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import UIKit

class SessionViewController: UIViewController {
    var alarm = Alarm() // the current alarm
    var alarmNotificationManager = AlarmNotificationManager() // the current alarm notification manager
    var timer = Timer() // for repeated time updating and checking
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var snoozeAttemptsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // for formatting shown time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        // create and start timer for updating time
        setupTimer()
        
        // set alarm time label to the formatted alarm time
        alarmTimeLabel.text = dateFormatter.string(from: alarm.time)
        
        // load current settings into alarm notification manager
        alarmNotificationManager.loadSettings()
        // load current alarm notification manager into alarm notification manager
        alarmNotificationManager.loadAlarmNotificationManager()
        // load current alarm into alarm notification manager
        alarmNotificationManager.alarm = alarm
        
        // start a sleep session
        alarmNotificationManager.startSleepSession()
        
        // check if user enabled limiting alarm snoozes
        if alarm.limitSnoozes {
            // show snoozes left
            snoozeAttemptsLabel.isHidden = false
            snoozeAttemptsLabel.text = "\(alarm.snoozeTries - alarmNotificationManager.snoozeAmount) snoozes left"
        } else {
            // hide alarm snooze label
            snoozeAttemptsLabel.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // stop timer
        timer.invalidate()
        
        // schedule the current alarm
        alarmNotificationManager.descheduleAlarm()
        
        // stop any alarm sounds
        alarmNotificationManager.stopAlarm()
    }
    
    // create a timer to update the time
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    // update the alarm to show snooze time and amounts
    func updateSnoozeTimeLabel() {
        // for formatting alarm time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        // update alarm time label to formatted alarm notification manager alarm time
        alarmTimeLabel.text = dateFormatter.string(from: alarmNotificationManager.alarm.time)
        
        // show snooze amount left if alarm has a limited number of snoozes enabled
        if alarm.limitSnoozes {
            snoozeAttemptsLabel.text = "\(alarm.snoozeTries - alarmNotificationManager.snoozeAmount) snoozes left"
        }
    }
    
    // update the times and check for alarm triggering
    @objc func updateTime() {
        // for formatting alarm times
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        // update the current time to the formatted time from the current date
        currentTimeLabel.text = dateFormatter.string(from: Date())
        
        // get hour and minutes of the current time and the alarm time
        let calendar = Calendar.current
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarmNotificationManager.alarm.time)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: Date())
        
        // check if the current time matches the alarm time nad trigger the alarm
        if alarmComponents == currentComponents {
            alarmNotificationManager.playAlarm()
            timer.invalidate()
            performSegue(withIdentifier: "sessionAlarm", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SessionAlarmViewController {
            // update next screen to contain the current alarm notification manager
            destinationViewController.alarmNotificationManager = alarmNotificationManager
            // update next screen to contain the current alarm
            destinationViewController.alarm = alarm
            
            // check if the user stopped or snoozes the alarm
            destinationViewController.alarmEndCallback = { response in
                if response == "stop" {
                    // go backt to alarm screen if the alarm was stopped
                    if let navigationController = self.navigationController {
                        navigationController.popViewController(animated: true)
                    }
                } else {
                    // setup the screen for the snoozed alarm
                    self.setupTimer()
                    self.updateSnoozeTimeLabel()
                }
            }
        }
    }
}
