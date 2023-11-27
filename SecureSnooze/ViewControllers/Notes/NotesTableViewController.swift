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
        date = notesDatePicker.date
        getNote()
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
        note.timeAsleep = notesTimeAwakeDatePicker.date
    }
    @IBAction func notesTimeAwakeDatePickerChanged(_ sender: Any) {
        note.timeAwake = notesTimeAwakeDatePicker.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.definesPresentationContext = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("NotesTableViewController viewWillAppear()")
        loadNotes()
        getNote()
        updateNoteSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("NotesTableViewController viewWillDisappear()")
        saveNotes()
    }
    
    func getNoteForDate(dateToFind: Date) -> Note {
        print("NotesTableViewController getNoteForDate(dateToFind: \(dateToFind)")
        print("Note Dates in notes")
        if let newNote = self.notes.notes.first(where: { note in
            let calendar = Calendar.current
            let componentsToFind = calendar.dateComponents([.year, .month, .day], from: dateToFind)
            let componentsOfNote = calendar.dateComponents([.year, .month, .day], from: note.date)
            
            return componentsToFind == componentsOfNote
        }) {
            print("note found")
            return newNote
        } else {
            print("note not found, creating...")
            let newNote = Note()
            notes.notes.append(newNote)
            print("newNote appended to notes")
            return newNote
        }
    }
    
//    func updateNoteSettingsIsEnabled() {
//        notesMoodSegmentedControl.isEnabled = editEnabled
//        notesTextField.isEnabled = editEnabled
//        notesTimeAsleepDatePicker.isEnabled = editEnabled
//        notesTimeAwakeDatePicker.isEnabled = editEnabled
//    }
    
    func getNote() {
        print("NotesTableViewController getNotes()")
        note = getNoteForDate(dateToFind: date)
        note.date = date
    }
    
    func updateNoteSettings() {
        print("NotesTableViewController updateNoteSettings()")
        notesDatePicker.date = note.date
        notesMoodSegmentedControl.selectedSegmentIndex = note.mood.rawValue - 1
        notesTextField.text = note.text
        notesTimeAsleepDatePicker.date = note.timeAsleep
        notesTimeAwakeDatePicker.date = note.timeAsleep
    }
    
    @objc func clearButtonTapped() {
        notes.notes.removeAll(where: {$0.date == date})
        note = Note()
        note.date = date
        updateNoteSettings()
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
