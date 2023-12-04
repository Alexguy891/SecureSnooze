//
//  AnalyticsTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/28/23.
//

import UIKit
import SwiftUI

class AnalyticsTableViewController: UITableViewController {
    // placeholder
    var sleepGoal: Int = 8
    
    var notes: Notes = Notes()
    var notesInDateRange: [Note] = []
    var startDate: Date = Date()
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
    
    @IBAction func analyticsDateRangeSegmentedControlChanged(_ sender: Any) {
        getStartDateForSelectedDateRange()
        getNotesInDateRange()
        calculateStats()
        updateLabels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AnalyticsTableViewController viewWillAppear()")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("AnalyticsTableViewController viewDidAppear()")
        loadNotes()
        getStartDateForSelectedDateRange()
        getNotesInDateRange()
        calculateStats()
        updateLabels()
        tableView.reloadData()
    }
    
    func getStartDateForSelectedDateRange() {
        switch analyticsDateRangeSegmentedControl.selectedSegmentIndex {
        case 0:
            startDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        case 1:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case 2:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        case 3:
            let sortedNotes = notes.notes.sorted(by: { $0.date < $1.date })
            startDate = sortedNotes.first?.date ?? Date()
        default:
            startDate = Date()
        }
    }
    
    func getNotesInDateRange() {
        let sortedNotesByDate = notes.notes.sorted(by: { $0.date < $1.date })
        notesInDateRange = sortedNotesByDate.filter({ $0.date >= startDate && $0.date <= Date() })
    }
    
    func calculateStats() {
        if !notesInDateRange.isEmpty {
            calculateAverageHoursAsleep()
            calculateMedianMood()
            calculateAverageOverallSleepQuality()
            calculateMedianBedtime()
            calculateMedianWakeTime()
        }
    }
    
    func calculateAverageHoursAsleep() {
        let totalHoursAsleep = notesInDateRange.map { ($0.timeAwake.timeIntervalSince($0.timeAsleep)) / 60 / 60}

        averageHoursAsleep = round(Double(totalHoursAsleep.reduce(0, +)) / Double(notesInDateRange.count) * 10) / 10
    }
    
    func calculateMedianMood() {
        let sortedNotesInDateRangeByMood = notesInDateRange.sorted(by: { $0.mood.rawValue < $1.mood.rawValue })
        
        medianMood = sortedNotesInDateRangeByMood[sortedNotesInDateRangeByMood.count / 2].mood
    }
    
    func calculateAverageOverallSleepQuality() {
        let totalSleepQualityPoints = sleepGoal + Mood.great.rawValue
        
        averageOverallSleepQuality = round((averageHoursAsleep + Double(medianMood.rawValue)) / Double(totalSleepQualityPoints) * 1000) / 10
    }
    
    func calculateMedianBedtime() {
        let sortedNotesInDateRangeByTimeAsleep = notesInDateRange.sorted(by: {
            let bedtime1 = Calendar.current.dateComponents([.hour, .minute], from: $0.timeAsleep)
            let bedtime2 = Calendar.current.dateComponents([.hour, .minute], from: $1.timeAsleep)
            return bedtime1.hour ?? 0 < bedtime2.hour ?? 0 && bedtime1.minute ?? 0 < bedtime2.minute ?? 0
        })
        
        medianBedtime = sortedNotesInDateRangeByTimeAsleep[sortedNotesInDateRangeByTimeAsleep.count / 2].timeAsleep
    }
    
    func calculateMedianWakeTime() {
        let sortedNotesInDateRangeByTimeAwake = notesInDateRange.sorted(by: {
            let wakeTime1 = Calendar.current.dateComponents([.hour, .minute], from: $0.timeAwake)
            let wakeTime2 = Calendar.current.dateComponents([.hour, .minute], from: $1.timeAwake)
            return wakeTime1.hour ?? 0 < wakeTime2.hour ?? 0 && wakeTime1.minute ?? 0 < wakeTime2.minute ?? 0
        })
        medianWakeTime = sortedNotesInDateRangeByTimeAwake[sortedNotesInDateRangeByTimeAwake.count / 2].timeAwake
    }
    
    func updateLabels() {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateRangeLabel.text = "\(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: Date()))"
        
        if notesInDateRange.isEmpty {
            analyticsAverageHoursAsleepLabel.text = "N/A"
            analyticsMedianMoodLabel.text = "N/A"
            analyticsAverageOverallSleepQualityLabel.text = "N/A"
            analyticsMedianBedtimeLabel.text = "N/A"
            analyticsMedianWakeTimeLabel.text = "N/A"
            
            return
        }
        
        analyticsAverageHoursAsleepLabel.text = averageHoursAsleep == 1 ?  "\(String(averageHoursAsleep)) hr" : "\(String(averageHoursAsleep)) hrs"
        
        analyticsMedianMoodLabel.text = medianMood.getMoodName()
        
        analyticsAverageOverallSleepQualityLabel.text = "\(String(averageOverallSleepQuality)) %"
        
        dateFormatter.dateFormat = "h:mm a"
        
        analyticsMedianBedtimeLabel.text = dateFormatter.string(from: medianBedtime)
        
        analyticsMedianWakeTimeLabel.text = dateFormatter.string(from: medianWakeTime)
    }
    
    func loadNotes() {
        print("AnalyticsTableController loadNotes()")
        if let notesData = UserDefaults.standard.data(forKey: UserDefaultsKeys.notes.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedNotes = try decoder.decode([Note].self, from: notesData)
                notes = Notes(notes: decodedNotes)
            } catch {
                print("Error decoding notes array: \(error)")
            }
        } else {
            // print failure and return empty array if cast fails
            print("Failed to load notes from UserDefaults")
            notes = Notes()
        }
    }
}
