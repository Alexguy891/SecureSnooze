//
//  SessionViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import UIKit

class SessionViewController: UIViewController {
    var alarm = Alarm()
    var alarmNotificationManager = AlarmNotificationManager()
    var timer = Timer()
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        setupTimer()
        alarmTimeLabel.text = dateFormatter.string(from: alarm.time)
        alarmNotificationManager.loadSettings()
        alarmNotificationManager.loadAlarmNotificationManager()
        alarmNotificationManager.alarm = alarm
        alarmNotificationManager.startSleepSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        alarmNotificationManager.descheduleAlarm()
        alarmNotificationManager.stopAlarm()
    }
    
    func setupTimer() {
        print("setupTimer()")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        currentTimeLabel.text = dateFormatter.string(from: Date())
        let calendar = Calendar.current
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarmNotificationManager.alarm.time)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: Date())
        
        if alarmComponents == currentComponents {
            alarmNotificationManager.playAlarm()
            timer.invalidate()
            performSegue(withIdentifier: "sessionAlarm", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SessionAlarmViewController {
            destinationViewController.alarmNotificationManager = alarmNotificationManager
            destinationViewController.alarm = alarm
            destinationViewController.alarmEndCallback = { response in
                if response == "stop" {
                    print("stop selected")
                    if let navigationController = self.navigationController {
                        navigationController.popViewController(animated: true)
                    }
                } else {
                    print("snooze selected")
                    self.setupTimer()
                }
            }
        }
    }
}
