//
//  Passcode.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/30/23.
//

import Foundation
import CryptoKit

// holds user passcode
class Passcode: Codable {
    var passcode: String = ""
    
    // returns SHA256 hash of given string
    func hashPasscode(_ input: String) -> String {
        guard let inputData = input.data(using: .utf8) else {
            fatalError("Failed to convert string to data")
        }
        
        let hashedData = SHA256.hash(data: inputData)
        let hashedString = hashedData.map { String(format: "%02hhx", $0) }.joined()
        
        return hashedString
    }
    
    // sets passcode to new hashed string
    func setNewPasscode(input: String) {
        passcode = hashPasscode(input)
    }
    
    // returns if given string is the passcode
    func checkPasscode(input: String) -> Bool {
        return passcode == hashPasscode(input)
    }
    
    // saves current passcode
    func savePasscode() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.passcode.rawValue)
        } catch {
            print("Error encoding passcode: \(error)")
        }
    }
    
    // loads last passcode
    func loadPasscode() {
        if let passcodeData = UserDefaults.standard.data(forKey: UserDefaultsKeys.passcode.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedPasscode = try decoder.decode(Passcode.self, from: passcodeData)
                self.passcode = decodedPasscode.passcode
            } catch {
                print("Error decoding passcode: \(error)")
            }
        } else {
            self.passcode = ""
        }
    }
}
