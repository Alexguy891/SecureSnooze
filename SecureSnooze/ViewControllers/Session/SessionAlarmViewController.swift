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
        alarmNotificationManager.snoozeAlarm()
        dismiss(animated: true) {
            self.alarmEndCallback?("snooze")
        }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        alarmNotificationManager.stopAlarm()
        dismiss(animated: true) {
            self.alarmEndCallback?("stop")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeLabel.text = dateFormatter.string(from: alarm.time)
    }
}
