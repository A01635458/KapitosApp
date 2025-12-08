//
//  AppDelegate.swift
//  KapitosApp
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
        
        print(" KapitosApp launched successfully")
        
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
        
        let userInfo = notification.request.content.userInfo
        
        print("📦 UserInfo: \(userInfo)")
        
        // Mostrar notificación del sistema cuando la app está en foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        print("👆 User tapped notification: \(notification.request.identifier)")
        print("📦 UserInfo: \(userInfo)")
        print("🎬 Action: \(actionIdentifier)")
        
        // Handle different actions
        switch actionIdentifier {
        case "VIEW_PROFILE":
            print("→ User wants to view profile")
            Task { @MainActor in
                NavigationManager.shared.handleNotification(userInfo: userInfo)
            }
            
        case "SEND_MESSAGE":
            print("→ User wants to send message")
            Task { @MainActor in
                NavigationManager.shared.navigationScreen = .mensajesCliente
            }
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped notification itself (most common case)
            print("→ User opened notification (default action)")
            Task { @MainActor in
                NavigationManager.shared.handleNotification(userInfo: userInfo)
            }
            
        default:
            break
        }
        
        completionHandler()
    }
}
