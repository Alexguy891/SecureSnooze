//
//  PasscodeViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/30/23.
//

import UIKit

class PasscodeViewController: UIViewController {
    var passcode = Passcode() // the current passcode
    var creatingNewPasscode = false // whether user is creating a new passcode or verifying
    var nextScreenIdentifier = "" // the segue for the next screen
    var newPasscode = "" // the newly entered passcode
    var passcodeDoesExist = true // whether the user already has a passcode
    var correctPasscodeEntered = false // whether the correct passcode was entered
    var dismissalCallback: (() -> Void)? // when the user enters a passcode and the screen is dismissed
    
    @IBOutlet weak var passcodeEnterLabel: UILabel!
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var invalidPasscodeLabel: UILabel!
    
    // when anything is entered in the passcode field
    @IBAction func passcodeTextFieldChanged(_ sender: Any) {
        // check if the user entered 4 numbers
        if passcodeTextField.text?.count == 4 {
            // check if the user is creating a new passcode
            if creatingNewPasscode {
                // check if the user already has a passcode
                if passcodeDoesExist {
                    // check if the user entered the correct current passcode
                    if correctPasscodeEntered {
                        // check if user has entered a new passcode
                        if newPasscode == "" {
                            // update the label to show enter new passcode
                            updateLabelsToChangeNewPasscode()
                            
                            // set the newpasscode to a hash of itself
                            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: passcodeTextField.text ?? "")) {
                                newPasscode = passcode.hashPasscode(passcodeTextField.text ?? "")
                                
                                // reset the passcode text field
                                resetPasscodeTextField()
                                
                                // update label to show verify new passcode
                                updateLabelsToVerifyNewPasscode()
                            } else {
                                resetPasscodeTextField()
                                showInvalidPasscodeLabel()
                            }
                        // check if the new passcode matches the previously entered new passcode
                        } else if newPasscode == passcode.hashPasscode(passcodeTextField.text ?? "") {
                            // set the passcode to the new passcode
                            passcode.passcode = newPasscode
                            
                            // save the new passcode
                            saveNewPasscode()
                            
                            // go the next screen
                            goToNextScreen()
                        } else {
                            // reset the passcode text field
                            resetPasscodeTextField()
                            
                            // show warning that passcodes do not match
                            showPasscodesDoNotMatchLabel()
                        }
                    } else {
                        // check if the currently entered passcode matches the saved passcode
                        if checkEnteredPasscode() {
                            // reset the passcode text field
                            resetPasscodeTextField()
                            
                            // update the label to enter new passcode
                            updateLabelsToChangeNewPasscode()
                            
                            // update that the use entered the current passcode
                            correctPasscodeEntered = true
                        } else {
                            // reset the passcode text field
                            resetPasscodeTextField()
                            
                            // show label that the user entered the wrong passcode
                            showIncorrectPasscodeEnteredLabel()
                        }
                    }
                } else {
                    // check if the user has entered a new passcode
                    if newPasscode == "" {
                        // set the newpasscode to a hash of itself
                        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: passcodeTextField.text ?? "")) {
                            newPasscode = passcode.hashPasscode(passcodeTextField.text ?? "")
                            
                            // reset the passcode text field
                            resetPasscodeTextField()
                            
                            // update label to show verify new passcode
                            updateLabelsToVerifyNewPasscode()
                        } else {
                            resetPasscodeTextField()
                            showInvalidPasscodeLabel()
                        }
                    // check if the new entered passcode matches the previously entered new passcode
                    } else if newPasscode == passcode.hashPasscode(passcodeTextField.text ?? "") {
                        // set the current passcode to the new passcode
                        passcode.passcode = newPasscode
                        
                        // save the new passcode
                        saveNewPasscode()
                        
                        // go to the next screen
                        goToNextScreen()
                    } else {
                        // reset the passcode text field
                        resetPasscodeTextField()
                        
                        // show label that new passcode does not match previously entered new passcode
                        showPasscodesDoNotMatchLabel()
                    }
                }
            } else {
                // check if entered passcode matches current passcode
                if checkEnteredPasscode() {
                    // go to the next screen
                    goToNextScreen()
                } else {
                    // reset the passcode text field
                    resetPasscodeTextField()
                    
                    // show label that wrong passcode was entered
                    showIncorrectPasscodeEnteredLabel()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get the saved passcode
        loadPasscode()
        
        // hide the invalid passcode label
        invalidPasscodeLabel.isHidden = true
        
        // open passcode text field with keyboard
        passcodeTextField.becomeFirstResponder()
        
        // check if a current passcode was loaded
        if passcode.passcode == "" {
            // update to know a current passcode was not loaded
            passcodeDoesExist = false
            
            // show labels to create a new passcode
            updateLabelsToChangeNewPasscode()
        }
    }
    
    // update label to enter a new passcode
    func updateLabelsToChangeNewPasscode() {
        passcodeEnterLabel.text = "Enter new passcode"
        
        // hide invalid passcode text
        invalidPasscodeLabel.isHidden = true
    }
    
    // update label to verify new passcode
    func updateLabelsToVerifyNewPasscode() {
        passcodeEnterLabel.text = "Enter new passcode again"
        
        // hide invalid passcode text
        invalidPasscodeLabel.isHidden = true
    }
    
    // reset the passcode text field to be blank
    func resetPasscodeTextField() {
        passcodeTextField.text = ""
    }
    
    // show incorrect passcode label
    func showIncorrectPasscodeEnteredLabel() {
        // update label to show incorrect passcode
        invalidPasscodeLabel.text = "Incorrect passcode, please try again"
        
        // show label
        invalidPasscodeLabel.isHidden = false
    }
    
    // show invalid passcode label
    func showInvalidPasscodeLabel() {
        // update label to show invalid passcode
        invalidPasscodeLabel.text = "Passcode must only contain numbers"
        
        // show label
        invalidPasscodeLabel.isHidden = false
    }
    
    // show not matching passcode label
    func showPasscodesDoNotMatchLabel() {
        // update label to show passcode does not match
        invalidPasscodeLabel.text = "Passcode does not match, please try again"
        
        // show label
        invalidPasscodeLabel.isHidden = false
    }
    
    // check if the new passcode matches the entered passcode
    func verifyNewPasscode() -> Bool {
        return newPasscode == passcode.hashPasscode(passcodeTextField.text ?? "")
    }
    
    // check if the entered passcode matches the current passcode
    func checkEnteredPasscode() -> Bool {
        return passcode.checkPasscode(input: passcodeTextField.text ?? "")
    }
    
    // go to the next screen
    func goToNextScreen() {
        // dismiss with callback
        dismiss(animated: true) {
            self.dismissalCallback?()
        }
    }
    
    // save the new passcode
    func createNewPasscode() {
        // check if the new passcode matches the previously entered new passcode
        if verifyNewPasscode() {
            // update passcode to passcode entered
            passcode.setNewPasscode(input: passcodeTextField.text ?? "")
            
            // save the passcode
            saveNewPasscode()
        }
    }
    
    // save the passcode object
    func saveNewPasscode() {
        passcode.savePasscode()
    }
    
    // load the current passcode
    func loadPasscode() {
        passcode.loadPasscode()
    }
}
