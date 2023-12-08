//
//  AnalyticsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/28/23.
//

import UIKit
import SwiftUI

class AnalyticsTableViewController: UITableViewController {
    var notes: Notes = Notes() // array of all saved notes
    var notesInDateRange: [Note] = [] // array of notes in the selected date range
    var startDate: Date = Date() // start date for the date range
    var settings = Settings() // current settings
    
    // calaculated stats
    var averageHoursAsleep: Double = 0.0
    var medianMood: Mood = .okay
    var averageOverallSleepQuality: Double = 0.0
    var medianBedtime: Date = Date()
    var medianWakeTime: Date = Date()
    
    @IBOutlet weak var analyticsDateRangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var analyticsAverageHoursAsleepLabel: UILabel!
    @IBOutlet weak var analyticsMedianMoodLabel: UILabel!
    @IBOutlet weak var analyticsAverageOverallSleepQualityLabel: UILabel!
    @IBOutlet weak var analyticsMedianBedtimeLabel: UILabel!
    @IBOutlet weak var analyticsMedianWakeTimeLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    // when the date range is changed
    @IBAction func analyticsDateRangeSegmentedControlChanged(_ sender: Any) {
        // get the start date for the date range
        getStartDateForSelectedDateRange()
        // get all notes in the date range
        getNotesInDateRange()
        
        // calculate all stats
        calculateStats()
        
        // update all labels
        updateLabels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disables row highlighting on tap
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get current settings
        settings.loadSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // get current notes array
        loadNotes()
        
        // get the start date for the date range
        getStartDateForSelectedDateRange()
        // get the notes in the date range
        getNotesInDateRange()
        
        // calculate all stats
        calculateStats()
        
        // update all labels
        updateLabels()
        
        // reload table data
        tableView.reloadData()
    }
    
    // get the start date for the date range
    func getStartDateForSelectedDateRange() {
        // check which range is selected
        switch analyticsDateRangeSegmentedControl.selectedSegmentIndex {
        // calculate the start day by removing the number of units from the current date for the date range
        case 0:
            startDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        case 1:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case 2:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        // get all notes
        case 3:
            let sortedNotes = notes.notes.sorted(by: { $0.date < $1.date })
            startDate = sortedNotes.first?.date ?? Date()
        default:
            startDate = Date()
        }
    }
    
    // get all notes in the date range
    func getNotesInDateRange() {
        // sort all the notes by date
        let sortedNotesByDate = notes.notes.sorted(by: { $0.date < $1.date })
        
        // filter for notes within the date range
        notesInDateRange = sortedNotesByDate.filter({ $0.date >= startDate && $0.date <= Date() })
    }
    
    // calculate all stats
    func calculateStats() {
        // check if notes in date range array is empty before calculating
        if !notesInDateRange.isEmpty {
            calculateAverageHoursAsleep()
            calculateMedianMood()
            calculateAverageOverallSleepQuality()
            calculateMedianBedtime()
            calculateMedianWakeTime()
        }
    }
    
    // calculate average hours asleep
    func calculateAverageHoursAsleep() {
        // sum of every timeAsleep to timeAwake amount
        let totalHoursAsleep = notesInDateRange.map { ($0.timeAwake.timeIntervalSince($0.timeAsleep)) / 60 / 60}
        
        // round average to nearest 10th decimal place
        averageHoursAsleep = round(Double(totalHoursAsleep.reduce(0, +)) / Double(notesInDateRange.count) * 10) / 10
    }
    
    // calculate median mood
    func calculateMedianMood() {
        // sort notes in date range by mood integer
        let sortedNotesInDateRangeByMood = notesInDateRange.sorted(by: { $0.mood.rawValue < $1.mood.rawValue })
        
        // get middle mood in sorted array
        medianMood = sortedNotesInDateRangeByMood[sortedNotesInDateRangeByMood.count / 2].mood
    }
    
    // calculate average sleep quality
    func calculateAverageOverallSleepQuality() {
        // total quality is sum of highest mood integer and sleep goal
        let totalSleepQualityPoints = settings.sleepGoalHours + Mood.great.rawValue
        
        // calculate average score and round to nearest 10th decimal
        averageOverallSleepQuality = round((averageHoursAsleep + Double(medianMood.rawValue)) / Double(totalSleepQualityPoints) * 1000) / 10
    }
    
    // calculate median time asleep
    func calculateMedianBedtime() {
        // sort notes in date range by time sleep
        let sortedNotesInDateRangeByTimeAsleep = notesInDateRange.sorted(by: {
            let bedtime1 = Calendar.current.dateComponents([.hour, .minute], from: $0.timeAsleep)
            let bedtime2 = Calendar.current.dateComponents([.hour, .minute], from: $1.timeAsleep)
            return bedtime1.hour ?? 0 < bedtime2.hour ?? 0 && bedtime1.minute ?? 0 < bedtime2.minute ?? 0
        })
        
        // get middle in sorted array
        medianBedtime = sortedNotesInDateRangeByTimeAsleep[sortedNotesInDateRangeByTimeAsleep.count / 2].timeAsleep
    }
    
    // calculate median time awake
    func calculateMedianWakeTime() {
        // sort notes in date range by time awake
        let sortedNotesInDateRangeByTimeAwake = notesInDateRange.sorted(by: {
            let wakeTime1 = Calendar.current.dateComponents([.hour, .minute], from: $0.timeAwake)
            let wakeTime2 = Calendar.current.dateComponents([.hour, .minute], from: $1.timeAwake)
            return wakeTime1.hour ?? 0 < wakeTime2.hour ?? 0 && wakeTime1.minute ?? 0 < wakeTime2.minute ?? 0
        })
        
        // get middle in sorted array
        medianWakeTime = sortedNotesInDateRangeByTimeAwake[sortedNotesInDateRangeByTimeAwake.count / 2].timeAwake
    }
    
    // update all labels
    func updateLabels() {
        // format date range label and update with start date and current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateRangeLabel.text = "\(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: Date()))"
        
        // update labels to N/A if no notes in date range
        if notesInDateRange.isEmpty {
            analyticsAverageHoursAsleepLabel.text = "N/A"
            analyticsMedianMoodLabel.text = "N/A"
            analyticsAverageOverallSleepQualityLabel.text = "N/A"
            analyticsMedianBedtimeLabel.text = "N/A"
            analyticsMedianWakeTimeLabel.text = "N/A"
            
            return
        }
        
        // update labels
        analyticsAverageHoursAsleepLabel.text = averageHoursAsleep == 1 ?  "\(String(averageHoursAsleep)) hr" : "\(String(averageHoursAsleep)) hrs"
        analyticsMedianMoodLabel.text = medianMood.getMoodName()
        analyticsAverageOverallSleepQualityLabel.text = "\(String(averageOverallSleepQuality)) %"
        
        // change date formatting
        dateFormatter.dateFormat = "h:mm a"
        
        // continue updating labels
        analyticsMedianBedtimeLabel.text = dateFormatter.string(from: medianBedtime)
        analyticsMedianWakeTimeLabel.text = dateFormatter.string(from: medianWakeTime)
    }
    
    // load current notes
    func loadNotes() {
        if let notesData = UserDefaults.standard.data(forKey: UserDefaultsKeys.notes.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedNotes = try decoder.decode([Note].self, from: notesData)
                notes = Notes(notes: decodedNotes)
            } catch {
                print("Error decoding notes array: \(error)")
            }
        } else {
            notes = Notes()
        }
    }
}
