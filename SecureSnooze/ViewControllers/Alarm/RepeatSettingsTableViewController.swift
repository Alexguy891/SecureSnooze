//
//  RepeatSettingsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/27/23.
//

import UIKit

class RepeatSettingsTableViewController: UITableViewController {
    var alarm: Alarm = Alarm()
    var selectedDays: [DaysOfTheWeek] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedDays = alarm.daysToRepeat
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        alarm.daysToRepeat = selectedDays
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DaysOfTheWeek.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayOfTheWeek", for: indexPath)
        let dayLabel = cell.viewWithTag(1) as? UILabel
        dayLabel?.text = DaysOfTheWeek.allCases[indexPath.row].rawValue
        
        cell.accessoryType = selectedDays.contains(DaysOfTheWeek.allCases[indexPath.row]) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedDays.contains(DaysOfTheWeek.allCases[indexPath.row]) {
            selectedDays.removeAll { $0 == DaysOfTheWeek.allCases[indexPath.row]}
        } else {
            selectedDays.append(DaysOfTheWeek.allCases[indexPath.row])
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
