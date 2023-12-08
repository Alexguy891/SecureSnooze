//
//  NotesTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/27/23.
//

import UIKit

class NotesTableViewController: UITableViewController {
    var notes: Notes = Notes() // the current notes
    var note: Note = Note() // the current note
    var date: Date = Date() // the date of the note
    
    @IBOutlet weak var notesDatePicker: UIDatePicker!
    @IBOutlet weak var notesMoodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var notesTimeAsleepDatePicker: UIDatePicker!
    @IBOutlet weak var notesTimeAwakeDatePicker: UIDatePicker!
    
    // when the date is changed
    @IBAction func notesDatePickerChanged(_ sender: Any) {
        // add the the new note
        addNewNote(note)
        
        // set the date to selected date
        date = notesDatePicker.date
        
        // get the note for the date
        getNote()
        
        // update the time pickers to the current date
        updateDateTimePickersToDate()
        
        // update the note settings to the current note
        updateNoteSettings()
        
        // reload the table data
        tableView.reloadData()
    }
    
    // set note settings to options
    @IBAction func notesMoodSegmentedControlChanged(_ sender: Any) {
        note.mood = Mood(rawValue: notesMoodSegmentedControl.selectedSegmentIndex + 1) ?? .okay
    }
    @IBAction func notesTextFieldChanged(_ sender: Any) {
        note.text = notesTextField.text ?? ""
    }
    @IBAction func notesTimeAsleepDatePickerChanged(_ sender: Any) {
        note.timeAsleep = notesTimeAsleepDatePicker.date
        
        // set awake picker minimum date to the date of the asleep picker
        notesTimeAwakeDatePicker.minimumDate = notesTimeAsleepDatePicker.date
    }
    @IBAction func notesTimeAwakeDatePickerChanged(_ sender: Any) {
        note.timeAwake = notesTimeAwakeDatePicker.date
        
        // set asleep picker maximum date to the date of the awake picker
        notesTimeAsleepDatePicker.maximumDate = notesTimeAwakeDatePicker.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allows viewWillAppear on every open
        self.definesPresentationContext = true
        
        // create clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set the max date to the current date
        notesDatePicker.maximumDate = Date()
        
        // load the notes array
        loadNotes()
        
        // get the current note for the date
        getNote()
        
        // update the time pickers to the current date
        updateDateTimePickersToDate()
        
        // update the options to the current note
        updateNoteSettings()
        
        // create tap recognizer to hide keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // add note to notes array
        addNewNote(note)
        
        // save the current notes array
        saveNotes()
    }
    
    func getNoteForDate(dateToFind: Date) -> Note {
        // get the note for the current month, year, and day
        if let newNote = self.notes.notes.first(where: { note in
            let calendar = Calendar.current
            let componentsToFind = calendar.dateComponents([.year, .month, .day], from: dateToFind)
            let componentsOfNote = calendar.dateComponents([.year, .month, .day], from: note.date)
            
            return componentsToFind == componentsOfNote
        }) {
            return newNote
        } else {
            // create a new blank note
            let newNote = Note()
            newNote.date = date
            newNote.timeAsleep = Calendar.current.date(byAdding: .hour, value: -8, to: date) ?? Date()
            newNote.timeAwake = date
            return newNote
        }
    }
    
    // update time pickers for the selected date
    func updateDateTimePickersToDate() {
        // get the date of the previous day
        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? Date()
        
        // update time pickers to the note
        notesTimeAwakeDatePicker.date = note.timeAwake
        notesTimeAsleepDatePicker.date = note.timeAsleep
        
        // set minimum and max dates for the pickers
        notesTimeAsleepDatePicker.minimumDate = Calendar.current.startOfDay(for: previousDay)
        notesTimeAwakeDatePicker.maximumDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        notesTimeAsleepDatePicker.maximumDate = notesTimeAwakeDatePicker.date
        notesTimeAwakeDatePicker.minimumDate = notesTimeAsleepDatePicker.date
    }
    
    // add a new note to the notes array
    func addNewNote(_ newNote: Note) {
        // check if the note has been edited
        if newNote.text != "" && newNote.timeAwake.timeIntervalSince(newNote.timeAsleep) > 0 {
            // check if a note for the date already exists
            let calendar = Calendar.current
            for note in notes.notes {
                let originalDateComponents = calendar.dateComponents([.day, .month, .year], from: note.date)
                let newNoteDateComponents = calendar.dateComponents([.day, .month, .year], from: newNote.date)
                
                if originalDateComponents == newNoteDateComponents {
                    return
                }
            }
            
            // add the new note if it does not exist
            notes.notes.append(newNote)
        }
    }
    
    // get the current note for the date
    func getNote() {
        note = getNoteForDate(dateToFind: date)
    }
    
    // update the note controls to match selected note
    func updateNoteSettings() {
        notesDatePicker.date = note.date
        notesMoodSegmentedControl.selectedSegmentIndex = note.mood.rawValue - 1
        notesTextField.text = note.text
    }
    
    // clear note options when clear button tapped
    @objc func clearButtonTapped() {
        // remove all notes from notes array where dates match
        notes.notes.removeAll(where: {
            Calendar.current.dateComponents([.month, .day, .year], from: $0.date) == Calendar.current.dateComponents([.month, .day, .year], from: date)})
        
        // reset note values
        note = Note()
        note.date = date
        note.timeAsleep = Calendar.current.date(byAdding: .hour, value: -8, to: date) ?? Date()
        note.timeAwake = date
        
        // update note options
        updateNoteSettings()
    }
    
    // close keyboard when text field is not tapped
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    // load notes array
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
    
    // save notes array
    func saveNotes() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(notes.notes)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.notes.rawValue)
        } catch {
            print("Error encoding notes array: \(error)")
        }
    }
}
