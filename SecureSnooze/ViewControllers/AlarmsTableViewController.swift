//
//  AlarmsTableTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

class AlarmsTableViewController: UITableViewController {
    // array of Alarm objects
    var alarms: [Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for debugging
        print("AlarmsTableViewController viewDidLoad()")
        // grab all alarms from user defaults
        alarms = loadAlarms()
        
        // enable edit button
        navigationItem.leftBarButtonItem = editButtonItem
        
        // enable add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected alarm
        let selectedAlarm = alarms[indexPath.row]
        // segue with the selected alarm
        performSegue(withIdentifier: "alarmTapped", sender: selectedAlarm)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returns row per alarm
        return alarms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get alarm cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath)
        
        // get alarm cell labels
        let nameLabel = cell.viewWithTag(1) as? UILabel
        let timeLabel = cell.viewWithTag(2) as? UILabel
        
        // if there are alarms, update labels with name and time for alarm
        if !alarms.isEmpty {
            let alarm = alarms[indexPath.row]
            nameLabel?.text = alarm.name
            timeLabel?.text = alarm.getTimeAsString()
        }
        
        // return the cell changes
        return cell
    }
    
    // for moving to add screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check for alarm tap or add button tap
        if segue.identifier == "alarmTapped" {
            if let destinationViewController = segue.destination as? AlarmSettingsTableViewController {
                // check if sender is a selected alarm
                if let selectedAlarm = sender as? Alarm {
                    // Pass the selected alarm to the destination view controller
                    destinationViewController.alarm = selectedAlarm
                }
            }
        } else if segue.identifier == "addButtonTapped" {
            if let destinationViewController = segue.destination as? AlarmSettingsTableViewController {
                // new alarm code here
            }
        }
    }
    
    // gets all alarms in user defaults
    func loadAlarms() -> [Alarm] {
        // cast to array of alarms and return
        if let alarms = UserDefaults.standard.object(forKey: UserDefaultsKeys.alarms.rawValue) as? [Alarm] {
            return alarms
        }
        
        // print failure and return empty array if cast fails
        print("Failed to load alarms from UserDefaults")
        return [Alarm]()
    }
    
    // go to empty alarm page when add button tapped
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "addButtonTapped", sender: self)
    }
}
