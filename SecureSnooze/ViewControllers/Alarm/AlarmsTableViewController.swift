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
    var settings: Settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for debugging
        print("AlarmsTableViewController viewDidLoad()")
        // grab all alarms from user defaults
        alarms = loadAlarms()
        
        // enable edit button
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        navigationItem.leftBarButtonItem = editButton
        
        // enable add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AlarmsTableViewController viewWillAppear()")
        print("alarms.count is \(alarms.alarms.count)")
        settings.loadSettings()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveAlarms()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected alarm
        let selectedAlarm = alarms.alarms[indexPath.row]
        // segue with the selected alarm
        if settings.requirePasscodeToChangeAlarms {
            performSegue(withIdentifier: "alarmPasscode", sender: indexPath.row)
        } else {
            performSegue(withIdentifier: "alarmTapped", sender: selectedAlarm)
        }
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
    
    // for deleting alarms
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                alarms.alarms.remove(at: indexPath.row)
                saveAlarms()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
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
        } else if segue.identifier == "alarmPasscode", let passcodeDestination = segue.destination as? PasscodeViewController {
            passcodeDestination.dismissalCallback = {
                if sender is Int {
                    self.performSegue(withIdentifier: "alarmTapped", sender: self)
                } else if sender is AlarmsTableViewController {
                    self.performSegue(withIdentifier: "addButtonTapped", sender: self)
                } else if sender is UIBarButtonItem {
                    self.setEditing(true, animated: true)
                }
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
        if settings.requirePasscodeToChangeAlarms {
            performSegue(withIdentifier: "alarmPasscode", sender: self)
        } else {
            performSegue(withIdentifier: "addButtonTapped", sender: self)
        }
    }
    
    @objc func editButtonTapped() {
        if settings.requirePasscodeToChangeAlarms {
            if !isEditing {
                performSegue(withIdentifier: "alarmPasscode", sender: editButtonItem)
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editButtonTapped))
            } else {
                setEditing(false, animated: true)
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
            }
        } else {
            if !isEditing {
                setEditing(true, animated: true)
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editButtonTapped))
            } else {
                setEditing(false, animated: true)
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
            }
        }
    }
    
    // for saving the alarms into user defaults
    func saveAlarms() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(alarms.alarms)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.alarms.rawValue)
        } catch {
            print("Error encoding alarms array: \(error)")
        }
    }
}
