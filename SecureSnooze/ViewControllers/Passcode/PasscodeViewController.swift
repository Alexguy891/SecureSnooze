//
//  PasscodeViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/30/23.
//

import UIKit

class PasscodeViewController: UIViewController {
    var passcode = Passcode()
    var creatingNewPasscode = false
    var nextScreenIdentifier = ""
    var newPasscode = ""
    var passcodeDoesExist = true
    var correctPasscodeEntered = false
    var dismissalCallback: (() -> Void)?
    
    @IBOutlet weak var passcodeEnterLabel: UILabel!
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var invalidPasscodeLabel: UILabel!
    
    
    @IBAction func passcodeTextFieldChanged(_ sender: Any) {
        if passcodeTextField.text?.count == 4 {
            if creatingNewPasscode {
                if passcodeDoesExist {
                    if correctPasscodeEntered {
                        updateLabelsToChangeNewPasscode()
                        if newPasscode == "" {
                            newPasscode = passcode.hashPasscode(passcodeTextField.text ?? "")
                            resetPasscodeTextField()
                            updateLabelsToVerifyNewPasscode()
                        } else if newPasscode == passcode.hashPasscode(passcodeTextField.text ?? "") {
                            passcode.passcode = newPasscode
                            saveNewPasscode()
                            goToNextScreen()
                        } else {
                            resetPasscodeTextField()
                            showPasscodesDoNotMatchLabel()
                        }
                    } else {
                        if checkEnteredPasscode() {
                            resetPasscodeTextField()
                            updateLabelsToChangeNewPasscode()
                            correctPasscodeEntered = true
                        } else {
                            resetPasscodeTextField()
                            showIncorrectPasscodeEnteredLabel()
                        }
                    }
                    
                } else {
                    if newPasscode == "" {
                        newPasscode = passcode.hashPasscode(passcodeTextField.text ?? "")
                        resetPasscodeTextField()
                        updateLabelsToVerifyNewPasscode()
                    } else if newPasscode == passcode.hashPasscode(passcodeTextField.text ?? "") {
                        passcode.passcode = newPasscode
                        saveNewPasscode()
                        goToNextScreen()
                    } else {
                        resetPasscodeTextField()
                        showPasscodesDoNotMatchLabel()
                    }
                }
            } else {
                if checkEnteredPasscode() {
                    goToNextScreen()
                } else {
                    resetPasscodeTextField()
                    showIncorrectPasscodeEnteredLabel()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PasscodeViewController viewWillAppear()")
        loadPasscode()
        invalidPasscodeLabel.isHidden = true
        passcodeTextField.becomeFirstResponder()
        
        if passcode.passcode == "" {
            passcodeDoesExist = false
            updateLabelsToChangeNewPasscode()
        }
    }
    
    func updateLabelsToChangeNewPasscode() {
        passcodeEnterLabel.text = "Enter new passcode"
        invalidPasscodeLabel.isHidden = true
    }
    
    func updateLabelsToVerifyNewPasscode() {
        passcodeEnterLabel.text = "Enter new passcode again"
        invalidPasscodeLabel.isHidden = true
    }
    
    func resetPasscodeTextField() {
        passcodeTextField.text = ""
    }
    
    func showIncorrectPasscodeEnteredLabel() {
        invalidPasscodeLabel.text = "Incorrect password, please try again"
        invalidPasscodeLabel.isHidden = false
    }
    
    func showPasscodesDoNotMatchLabel() {
        invalidPasscodeLabel.text = "Passcode does not match, please try again"
        invalidPasscodeLabel.isHidden = false
    }
    
    func verifyNewPasscode() -> Bool {
        print("Passcode verifyNewPasscode()")
        return newPasscode == passcode.hashPasscode(passcodeTextField.text ?? "")
    }
    
    func checkEnteredPasscode() -> Bool {
        print("Passcode checkEnteredPasscode()")
        return passcode.checkPasscode(input: passcodeTextField.text ?? "")
    }
    
    func goToNextScreen() {
        dismiss(animated: true) {
            self.dismissalCallback?()
        }
    }
    
    func createNewPasscode() {
        print("Passcode createNewPasscode()")
        if verifyNewPasscode() {
            passcode.setNewPasscode(input: passcodeTextField.text ?? "")
            saveNewPasscode()
        }
    }
    
    func saveNewPasscode() {
        print("Passcode saveNewPasscode()")
        passcode.savePasscode()
    }
    
    func loadPasscode() {
        print("loadPasscode()")
        passcode.loadPasscode()
    }
}
