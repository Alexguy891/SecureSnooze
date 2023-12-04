//
//  NotesTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/27/23.
//

import UIKit

class NotesTableViewController: UITableViewController {
    var notes: Notes = Notes()
    var note: Note = Note()
    var date: Date = Date()
    var editEnabled: Bool = false
    
    @IBOutlet weak var notesDatePicker: UIDatePicker!
    @IBOutlet weak var notesMoodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var notesTimeAsleepDatePicker: UIDatePicker!
    @IBOutlet weak var notesTimeAwakeDatePicker: UIDatePicker!
    
    @IBAction func notesDatePickerChanged(_ sender: Any) {
        print("NotesTableViewController notesDatePickerChanged()")
        addNewNote(note)
        date = notesDatePicker.date
        getNote()
        updateDateTimePickersToDate()
        updateNoteSettings()
        tableView.reloadData()

//        if note == Note() {
//            editEnabled = true
//        } else {
//            editEnabled = false
//        }
//        
//        updateNoteSettingsIsEnabled()
    }
    @IBAction func notesMoodSegmentedControlChanged(_ sender: Any) {
        note.mood = Mood(rawValue: notesMoodSegmentedControl.selectedSegmentIndex + 1) ?? .okay
    }
    @IBAction func notesTextFieldChanged(_ sender: Any) {
        note.text = notesTextField.text ?? ""
    }
    @IBAction func notesTimeAsleepDatePickerChanged(_ sender: Any) {
        note.timeAsleep = notesTimeAsleepDatePicker.date
        notesTimeAwakeDatePicker.minimumDate = notesTimeAsleepDatePicker.date
    }
    @IBAction func notesTimeAwakeDatePickerChanged(_ sender: Any) {
        note.timeAwake = notesTimeAwakeDatePicker.date
        notesTimeAsleepDatePicker.maximumDate = notesTimeAwakeDatePicker.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//      self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.definesPresentationContext = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("NotesTableViewController viewWillAppear()")
        notesDatePicker.maximumDate = Date()
        loadNotes()
        getNote()
        updateDateTimePickersToDate()
        updateNoteSettings()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addNewNote(note)
        saveNotes()
        print("NotesTableViewController viewWillDisappear()")
    }
    
    func getNoteForDate(dateToFind: Date) -> Note {
        if let newNote = self.notes.notes.first(where: { note in
            let calendar = Calendar.current
            let componentsToFind = calendar.dateComponents([.year, .month, .day], from: dateToFind)
            let componentsOfNote = calendar.dateComponents([.year, .month, .day], from: note.date)
            
            return componentsToFind == componentsOfNote
        }) {
            return newNote
        } else {
            let newNote = Note()
            newNote.date = date
            newNote.timeAsleep = Calendar.current.date(byAdding: .hour, value: -8, to: date) ?? Date()
            newNote.timeAwake = date
            return newNote
        }
    }
    
    func updateDateTimePickersToDate() {
        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? Date()
        notesTimeAwakeDatePicker.date = note.timeAwake
        notesTimeAsleepDatePicker.date = note.timeAsleep
        notesTimeAsleepDatePicker.minimumDate = Calendar.current.startOfDay(for: previousDay)
        notesTimeAwakeDatePicker.maximumDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        notesTimeAsleepDatePicker.maximumDate = notesTimeAwakeDatePicker.date
        notesTimeAwakeDatePicker.minimumDate = notesTimeAsleepDatePicker.date
    }
    
//    func updateNoteSettingsIsEnabled() {
//        notesMoodSegmentedControl.isEnabled = editEnabled
//        notesTextField.isEnabled = editEnabled
//        notesTimeAsleepDatePicker.isEnabled = editEnabled
//        notesTimeAwakeDatePicker.isEnabled = editEnabled
//    }
    
    func addNewNote(_ newNote: Note) {
        if newNote.text != "" && newNote.timeAwake.timeIntervalSince(newNote.timeAsleep) > 0 {
            let calendar = Calendar.current
            
            
            for note in notes.notes {
                let originalDateComponents = calendar.dateComponents([.day, .month, .year], from: note.date)
                let newNoteDateComponents = calendar.dateComponents([.day, .month, .year], from: newNote.date)
                
                if originalDateComponents == newNoteDateComponents {
                    return
                }
            }
            
            notes.notes.append(newNote)
        }
        
        
    }
    
    func getNote() {
        print("NotesTableViewController getNote()")
        note = getNoteForDate(dateToFind: date)
    }
    
    func updateNoteSettings() {
        print("NotesTableViewController updateNoteSettings()")
        notesDatePicker.date = note.date
        notesMoodSegmentedControl.selectedSegmentIndex = note.mood.rawValue - 1
        notesTextField.text = note.text
    }
    
    @objc func clearButtonTapped() {
        notes.notes.removeAll(where: {$0.date == date})
        note = Note()
        note.date = date
        note.timeAsleep = Calendar.current.date(byAdding: .hour, value: -8, to: date) ?? Date()
        note.timeAwake = date
        updateNoteSettings()
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func loadNotes() {
        print("NotesTableViewController loadNotes()")
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
    
    func saveNotes() {
        print("NotesTableViewController saveNotes()")
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(notes.notes)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.notes.rawValue)
        } catch {
            print("Error encoding notes array: \(error)")
        }
    }
}
