//
//  RepeatSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/27/23.
//

import UIKit

class SoundSettingsTableViewController: UITableViewController {
    var alarm: Alarm = Alarm()
    var selectedSound: AlarmSound = .sound1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedSound = alarm.sound
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        alarm.sound = selectedSound
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmSound.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sound", for: indexPath)
        let soundLabel = cell.viewWithTag(1) as? UILabel
        soundLabel?.text = AlarmSound.allCases[indexPath.row].getSoundName()
        
        cell.accessoryType = selectedSound == AlarmSound.allCases[indexPath.row] ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSound = AlarmSound.allCases[indexPath.row]
        tableView.reloadRows(at: [indexPath], with: .none)
        navigationController?.popViewController(animated: true)
    }
}
