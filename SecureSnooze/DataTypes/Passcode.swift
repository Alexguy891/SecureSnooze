//
//  Passcode.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/30/23.
//

import Foundation
import CryptoKit

class Passcode: Codable {
    var passcode: String = ""
    
    func hashPasscode(_ input: String) -> String {
        guard let inputData = input.data(using: .utf8) else {
            fatalError("Failed to convert string to data")
        }
        
        let hashedData = SHA256.hash(data: inputData)
        let hashedString = hashedData.map { String(format: "%02hhx", $0) }.joined()
        
        return hashedString
    }
    
    func setNewPasscode(input: String) {
        passcode = hashPasscode(input)
    }
    
    func checkPasscode(input: String) -> Bool {
        return passcode == hashPasscode(input)
    }
    
    func savePasscode() {
        print("Passcode savePasscode()")
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.passcode.rawValue)
        } catch {
            print("Error encoding passcode: \(error)")
        }
    }
    
    func loadPasscode() {
        print("Passcode loadPasscode()")
        if let passcodeData = UserDefaults.standard.data(forKey: UserDefaultsKeys.passcode.rawValue) {
            do {
                let decoder = JSONDecoder()
                let decodedPasscode = try decoder.decode(Passcode.self, from: passcodeData)
                self.passcode = decodedPasscode.passcode
            } catch {
                print("Error decoding passcode: \(error)")
            }
        } else {
            // print failure and return empty array if cast fails
            print("Failed to load passcode from UserDefaults")
            self.passcode = ""
        }
    }
}
