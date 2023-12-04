//
//  AppDelegate.swift
//  SecureSnooze
//
//  Created by Alex Ely on 11/20/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var alarmNotificationManager: AlarmNotificationManager = AlarmNotificationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        alarmNotificationManager.loadAlarmNotificationManager()
        alarmNotificationManager.requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter(center: willPresent: withCompletionHandler:")
        completionHandler([.badge, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificationCenter(center: didReceive: withCompletionHandler:")
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // User tapped on the notification body
            // Handle as needed
            break

        case "snoozeAction":
            // User clicked on the "Snooze" action
            alarmNotificationManager.snoozeAlarm()
            break

        case "stopAction":
            // User clicked on the "Stop" action
            alarmNotificationManager.stopAlarm()
            break

        default:
            // Handle other actions if needed
            break
        }

        completionHandler()
    }
}

