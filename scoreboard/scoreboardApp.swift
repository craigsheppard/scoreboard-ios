//
//  scoreboardApp.swift
//  scoreboard
//
//  Created by Craig Sheppard on 2025-02-01.
//

import SwiftUI
import UserNotifications
import CloudKit

@main
struct scoreboardApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Request permission for notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    // Handle remote notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If this is a CloudKit notification
        if let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            // Process CloudKit notification
            CloudKitManager.shared.handleRemoteNotification(userInfo: userInfo)
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Successfully registered for remote notifications
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
