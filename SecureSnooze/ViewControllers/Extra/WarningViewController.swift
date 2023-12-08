//
//  WarningViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/8/23.
//

import UIKit

class WarningViewController: UIViewController {
    var dismissalCallback: ((String) -> Void)?
    
    // dismisses view and returns acknowledgment when understand button tapped
    @IBAction func understandButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.dismissalCallback?("i understand")
        }
    }
    
    // dismisses view and returns failure when go back button tapped
    @IBAction func goBackButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.dismissalCallback?("go back")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disables swiping view to close
        isModalInPresentation = true
    }
    
}
