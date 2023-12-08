//
//  ExtrasTableViewController.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/8/23.
//

import UIKit

class ExtrasTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disables row highlighting on tap
        tableView.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // shows warning upon opening
        performSegue(withIdentifier: "showWarning", sender: self)
    }
    
    // forces back to settings screen if warning understand button not tapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? WarningViewController {
            destinationViewController.dismissalCallback = { result in
                if result != "i understand" {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
