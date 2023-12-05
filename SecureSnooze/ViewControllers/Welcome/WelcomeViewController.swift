//
//  WelcomeViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBAction func createPasscodeButtonTapped(_ sender: Any) {
        isModalInPresentation = false
        performSegue(withIdentifier: "welcomeCreatePasscodeTapped", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        hidesBottomBarWhenPushed = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeViewController {
            destinationViewController.creatingNewPasscode = true
            destinationViewController.dismissalCallback = {
                self.dismiss(animated: true)
            }
        }
    }
}
