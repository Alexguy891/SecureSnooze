//
//  RepeatSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/27/23.
//

import UIKit

class SoundSettingsTableViewController: UITableViewController {
    var alarm: Alarm = Alarm() // the current alarm
    var selectedSound: AlarmSound = .sound1 // the current alarm sound
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        // set sound to alarm sound
        selectedSound = alarm.sound
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // set alarm sound to current sound
        alarm.sound = selectedSound
        
        // save current alarm
        alarm.saveAlarm()
    }
    
    // returns number of sections for dynamic cells
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // gets number rows equal to number of sound options
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmSound.allCases.count
    }

    // generate rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create row with label
        let cell = tableView.dequeueReusableCell(withIdentifier: "sound", for: indexPath)
        let soundLabel = cell.viewWithTag(1) as? UILabel
        
        // update label to name of the sound
        soundLabel?.text = AlarmSound.allCases[indexPath.row].getSoundName()
        
        // give row a checkmark on the right
        cell.accessoryType = selectedSound == AlarmSound.allCases[indexPath.row] ? .checkmark : .none
        
        // return the cell
        return cell
    }
    
    // when user selects a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the current selected row
        selectedSound = AlarmSound.allCases[indexPath.row]
        
        // reload the table rows
        tableView.reloadRows(at: [indexPath], with: .none)
        
        // show the sound options screen
        navigationController?.popViewController(animated: true)
    }
}
