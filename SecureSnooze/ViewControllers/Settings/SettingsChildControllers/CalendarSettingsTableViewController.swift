//
//  CalendarSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/29/23.
//

import UIKit

class CalendarSettingsTableViewController: UITableViewController {
    var settings = Settings()
    
    @IBOutlet weak var addRemindersToCalendarSwitch: UISwitch!
    
    @IBAction func addRemindersToCalendarSwitchChanged(_ sender: Any) {
        settings.addAlarmsToCalender = addRemindersToCalendarSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addRemindersToCalendarSwitch.isOn = settings.addAlarmsToCalender
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.saveSettings()
    }
}
