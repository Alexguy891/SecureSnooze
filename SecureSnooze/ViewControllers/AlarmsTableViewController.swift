//
//  AlarmsTableTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

class AlarmsTableViewController: UITableViewController {
    // array of Alarm objects
    var alarms: Alarms = Alarms()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        print("AlarmsTableViewController viewWillAppear()")
        print("alarms.count is \(alarms.alarms.count)")
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(alarms.alarms)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.alarms.rawValue)
        } catch {
            print("Error conding alarms array: \(error)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected alarm
        let selectedAlarm = alarms.alarms[indexPath.row]
        // segue with the selected alarm
        performSegue(withIdentifier: "alarmTapped", sender: selectedAlarm)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returns row per alarm
        return alarms.alarms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get alarm cell
        print("getting cell...")
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath)
        
        // get alarm cell labels
        print("getting cell labels...")
        let nameLabel = cell.viewWithTag(2) as? UILabel
        let timeLabel = cell.viewWithTag(1) as? UILabel
        
        // if there are alarms, update labels with name and time for alarm
        if !alarms.alarms.isEmpty {
            print("alarms is not empty, updating cell...")
            let alarm = alarms.alarms[indexPath.row]
            nameLabel?.text = alarm.name
            timeLabel?.text = alarm.getTimeAsString()
        }
        
        cell.accessoryType = .disclosureIndicator
        
        // return the cell changes
        print("returning cell...")
        return cell
    }
    
    // for moving to add screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check for alarm tap or add button tap
        if segue.identifier == "alarmTapped" {
            if let destinationViewController = segue.destination as? AlarmSettingsTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationViewController.alarms = self.alarms
                    destinationViewController.selectedAlarmIndex = indexPath.row
                }
            }
        } else if segue.identifier == "addButtonTapped" {
            if let destinationViewController = segue.destination as? AlarmSettingsTableViewController {
                destinationViewController.alarms = self.alarms
                destinationViewController.selectedAlarmIndex = -1
            }
        }
    }
    
    // gets all alarms in user defaults
    func loadAlarms() -> Alarms {
        // cast to array of alarms and return
        if let alarmsData = UserDefaults.standard.data(forKey: UserDefaultsKeys.alarms.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedAlarms = try decoder.decode([Alarm].self, from: alarmsData)
                return Alarms(alarms: decodedAlarms)
            } catch {
                print("Error decoding alarms array: \(error)")
            }
        }
        
        // print failure and return empty array if cast fails
        print("Failed to load alarms from UserDefaults")
        return Alarms()
    }
    
    // go to empty alarm page when add button tapped
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "addButtonTapped", sender: self)
    }
}
