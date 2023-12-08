//
//  WelcomeViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import UIKit

class WelcomeViewController: UIViewController {
    var firstTimeOpen = true // for displaying on first open
    
    // when user taps the create passcode button
    @IBAction func createPasscodeButtonTapped(_ sender: Any) {
        // enabled swiping screen away
        isModalInPresentation = false
        
        // go to passcode screen
        performSegue(withIdentifier: "welcomeCreatePasscodeTapped", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable swiping screen away
        isModalInPresentation = true
        
        // hide tab bar when shown
        hidesBottomBarWhenPushed = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeViewController {
            // update passcode screen parameters
            destinationViewController.creatingNewPasscode = true
            
            // if a passcode was enterd
            destinationViewController.dismissalCallback = {
                // no longer show welcome screen on opening
                self.firstTimeOpen = false
                self.saveFirstTimeOpen()
                
                // dismiss the welcome screen
                self.dismiss(animated: true)
            }
        }
    }
    
    // save if the app was opened for the first time
    func saveFirstTimeOpen() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(firstTimeOpen)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.firstTimeOpen.rawValue)
        } catch {
            print("Error encoding settings: \(error)")
        }
    }
}
