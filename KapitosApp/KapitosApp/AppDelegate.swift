//
//  AppDelegate.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 05/12/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        print("✅ KapitosApp launched successfully")
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📬 Received notification in foreground: \(notification.request.identifier)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👆 User tapped notification: \(response.notification.request.identifier)")
        
        let actionIdentifier = response.actionIdentifier
        let notification = response.notification
        
        // Handle different actions
        switch actionIdentifier {
        case "VIEW_PROFILE":
            print("→ User wants to view profile")
            // TODO: Navigate to producer profile
            
        case "SEND_MESSAGE":
            print("→ User wants to send message")
            // TODO: Navigate to chat
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped notification itself
            print("→ User opened notification")
            // TODO: Navigate based on notification category
            
        default:
            break
        }
        
        completionHandler()
    }
}
