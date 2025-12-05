//
//  NavigationManager.swift
//  KapitosApp
//
//  Deep link navigation manager for handling notification taps
//

import Foundation
import SwiftUI
import Combine

@MainActor
class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    // Navigation triggers
    @Published var selectedProducerId: UUID?
    @Published var shouldShowProducerDetail = false
    @Published var navigationScreen: AppScreen?
    
    // Notification payload
    @Published var notificationPayload: [String: Any]?
    
    private init() {
        print("🧭 NavigationManager initialized")
    }
    
    /// Handle notification tap and navigate to appropriate view
    func handleNotification(userInfo: [AnyHashable: Any]) {
        print("🧭 NavigationManager handling notification with userInfo: \(userInfo)")
        
        // Extract producer ID from notification
        if let producerIdString = userInfo["producerId"] as? String,
           let producerId = UUID(uuidString: producerIdString) {
            
            print("🧭 Navigating to producer: \(producerId)")
            
            // Set the producer to show
            selectedProducerId = producerId
            shouldShowProducerDetail = true
            
            // Also navigate to home/map screen where producer detail can be shown
            navigationScreen = .home
            
        } else if let category = userInfo["category"] as? String {
            // Handle other navigation types based on category
            switch category {
            case "CONVERSATION_UPDATE":
                // Navigate to messages
                navigationScreen = .mensajesCliente
                
            case "NEW_MATCH", "HARVEST_ALERT", "TOUR_AVAILABLE":
                // Navigate to home/map where we can show producer detail
                navigationScreen = .home
                
            default:
                break
            }
        }
    }
    
    /// Reset navigation state
    func resetNavigation() {
        selectedProducerId = nil
        shouldShowProducerDetail = false
        navigationScreen = nil
        notificationPayload = nil
        print("🧭 Navigation state reset")
    }
    
    /// Navigate to specific producer
    func navigateToProducer(id: UUID) {
        print("🧭 Direct navigation to producer: \(id)")
        selectedProducerId = id
        shouldShowProducerDetail = true
        navigationScreen = .home
    }
    
    /// Navigate to specific screen
    func navigateToScreen(_ screen: AppScreen) {
        print("🧭 Navigating to screen: \(screen)")
        navigationScreen = screen
    }
}
