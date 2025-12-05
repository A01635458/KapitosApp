//
//  SmartNotificationService.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 05/12/25.
//

import Foundation
import UserNotifications
import CoreLocation
import Supabase
import Combine

/// Service for managing contextual intelligent notifications
@MainActor
class SmartNotificationService: NSObject, ObservableObject {
    
    static let shared = SmartNotificationService()
    
    @Published var notificationPermissionGranted = false
    @Published var locationPermissionGranted = false
    @Published var isSchedulingNotifications = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let locationManager = CLLocationManager()
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    // MARK: - Notification Types
    
    enum NotificationTrigger {
        case newMatchingProducer(producerId: UUID, farmName: String, state: String, process: String, score: Double)
        case harvestAlert(producerId: UUID, farmName: String, daysUntil: Int, score: Double)
        case nearbyTourAvailable(producerId: UUID, farmName: String, distance: Double)
        case conversationUpdate(producerId: UUID, farmName: String, messageCount: Int)
        
        var identifier: String {
            switch self {
            case .newMatchingProducer(let id, _, _, _, _):
                return "new-match-\(id.uuidString)"
            case .harvestAlert(let id, _, _, _):
                return "harvest-\(id.uuidString)"
            case .nearbyTourAvailable(let id, _, _):
                return "tour-\(id.uuidString)"
            case .conversationUpdate(let id, _, _):
                return "conversation-\(id.uuidString)"
            }
        }
        
        var category: String {
            switch self {
            case .newMatchingProducer:
                return "NEW_MATCH"
            case .harvestAlert:
                return "HARVEST_ALERT"
            case .nearbyTourAvailable:
                return "TOUR_AVAILABLE"
            case .conversationUpdate:
                return "CONVERSATION_UPDATE"
            }
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        checkPermissions()
        registerNotificationCategories()
    }
    
    // MARK: - Permission Management
    
    /// Request notification permissions
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                notificationPermissionGranted = granted
            }
            print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
            return granted
        } catch {
            print("❌ Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Request location permissions
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Check current permission status
    func checkPermissions() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
        
        let locationStatus = locationManager.authorizationStatus
        locationPermissionGranted = locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways
    }
    
    // MARK: - Notification Categories Setup
    
    private func registerNotificationCategories() {
        // Actions for new match notifications
        let viewProfileAction = UNNotificationAction(
            identifier: "VIEW_PROFILE",
            title: "Ver Perfil",
            options: .foreground
        )
        
        let sendMessageAction = UNNotificationAction(
            identifier: "SEND_MESSAGE",
            title: "Enviar Mensaje",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Cerrar",
            options: .destructive
        )
        
        // Categories
        let newMatchCategory = UNNotificationCategory(
            identifier: "NEW_MATCH",
            actions: [viewProfileAction, sendMessageAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let harvestCategory = UNNotificationCategory(
            identifier: "HARVEST_ALERT",
            actions: [viewProfileAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let tourCategory = UNNotificationCategory(
            identifier: "TOUR_AVAILABLE",
            actions: [viewProfileAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([newMatchCategory, harvestCategory, tourCategory])
    }
    
    // MARK: - Contextual Notification Generation
    
    /// Generate and schedule contextual notifications for a user
    func generateContextualNotifications(userId: UUID) async {
        guard notificationPermissionGranted else {
            print("⚠️ Notification permission not granted")
            return
        }
        
        isSchedulingNotifications = true
        
        // 1. Check for new matching producers
        await checkNewMatchingProducers(userId: userId)
        
        // 2. Check for upcoming harvests
        await checkUpcomingHarvests(userId: userId)
        
        // 3. Check for nearby tours (if location available)
        if locationPermissionGranted, let location = locationManager.location {
            await checkNearbyTours(userId: userId, userLocation: location)
        }
        
        isSchedulingNotifications = false
    }
    
    // MARK: - New Matching Producers
    
    /// Check for newly approved producers that match user preferences
    private func checkNewMatchingProducers(userId: UUID) async {
        do {
            // Get user preferences
            let preferencesService = UserPreferencesService()
            await preferencesService.fetchUserPreferences(userId: userId)
            
            guard let preferences = preferencesService.preferences else {
                return
            }
            
            // Get producers approved in the last 7 days
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            let dateFormatter = ISO8601DateFormatter()
            
            struct ProducerResponse: Codable {
                let id: UUID
                let farm_name: String
                let state: String?
                let processes: [String]?
                let varieties: [String]?
                let created_at: String?
            }
            
            let newProducers: [ProducerResponse] = try await supabase
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .gte("created_at", value: dateFormatter.string(from: sevenDaysAgo))
                .execute()
                .value
            
            // Score each producer
            let recommendationEngine = RecommendationEngine()
            
            for producer in newProducers {
                // Simple matching: check if producer processes match user preferences
                guard let producerProcesses = producer.processes,
                      let userProcesses = preferences.processes else {
                    continue
                }
                
                let matches = Set(userProcesses).intersection(Set(producerProcesses))
                
                if !matches.isEmpty {
                    let matchScore = Double(matches.count) / Double(userProcesses.count) * 100
                    
                    if matchScore >= 60 { // 60% threshold for notification
                        let matchingProcess = matches.first ?? "tu proceso favorito"
                        
                        await scheduleNotification(
                            trigger: .newMatchingProducer(
                                producerId: producer.id,
                                farmName: producer.farm_name,
                                state: producer.state ?? "México",
                                process: matchingProcess,
                                score: matchScore
                            ),
                            delaySeconds: 2 // Small delay to avoid spam
                        )
                        
                        print("✅ Scheduled notification for new match: \(producer.farm_name) (\(Int(matchScore))%)")
                    }
                }
            }
            
        } catch {
            print("❌ Error checking new matching producers: \(error)")
        }
    }
    
    // MARK: - Harvest Alerts
    
    /// Check for upcoming harvests from compatible producers
    private func checkUpcomingHarvests(userId: UUID) async {
        do {
            // Get user preferences
            let preferencesService = UserPreferencesService()
            await preferencesService.fetchUserPreferences(userId: userId)
            
            guard preferencesService.preferences != nil else {
                return
            }
            
            // Calculate date range: 60-90 days from last harvest = next harvest window
            let today = Date()
            let sixtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 60, to: today)!
            let ninetyDaysFromNow = Calendar.current.date(byAdding: .day, value: 90, to: today)!
            
            struct HarvestProducer: Codable {
                let id: UUID
                let farm_name: String
                let last_harvest_date: String?
                let processes: [String]?
            }
            
            let producers: [HarvestProducer] = try await supabase
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .not("last_harvest_date", operator: .is, value: "null")
                .execute()
                .value
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate]
            
            for producer in producers {
                guard let lastHarvestStr = producer.last_harvest_date,
                      let lastHarvestDate = dateFormatter.date(from: lastHarvestStr) else {
                    continue
                }
                
                // Calculate next harvest (assuming ~365 day cycle)
                guard let nextHarvest = Calendar.current.date(byAdding: .day, value: 365, to: lastHarvestDate) else {
                    continue
                }
                
                // Check if next harvest is in the 60-90 day window
                if nextHarvest >= sixtyDaysFromNow && nextHarvest <= ninetyDaysFromNow {
                    let daysUntil = Calendar.current.dateComponents([.day], from: today, to: nextHarvest).day ?? 0
                    
                    // Only notify about producers with good compatibility (simplified check)
                    await scheduleNotification(
                        trigger: .harvestAlert(
                            producerId: producer.id,
                            farmName: producer.farm_name,
                            daysUntil: daysUntil,
                            score: 85 // Placeholder score
                        ),
                        delaySeconds: 5
                    )
                    
                    print("✅ Scheduled harvest alert for \(producer.farm_name) in \(daysUntil) days")
                }
            }
            
        } catch {
            print("❌ Error checking upcoming harvests: \(error)")
        }
    }
    
    // MARK: - Nearby Tours
    
    /// Check for producers with tours near user location
    private func checkNearbyTours(userId: UUID, userLocation: CLLocation) async {
        do {
            struct TourProducer: Codable {
                let id: UUID
                let farm_name: String
                let latitude: Double?
                let longitude: Double?
                let has_tourist_area: Bool?
                let tourist_accessible: Bool?
            }
            
            let producers: [TourProducer] = try await supabase
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .eq("has_tourist_area", value: true)
                .eq("tourist_accessible", value: true)
                .not("latitude", operator: .is, value: "null")
                .not("longitude", operator: .is, value: "null")
                .execute()
                .value
            
            for producer in producers {
                guard let lat = producer.latitude, let lon = producer.longitude else {
                    continue
                }
                
                let producerLocation = CLLocation(latitude: lat, longitude: lon)
                let distanceKm = userLocation.distance(from: producerLocation) / 1000
                
                // Notify if within 50km
                if distanceKm <= 50 {
                    await scheduleNotification(
                        trigger: .nearbyTourAvailable(
                            producerId: producer.id,
                            farmName: producer.farm_name,
                            distance: distanceKm
                        ),
                        delaySeconds: 8
                    )
                    
                    print("✅ Scheduled tour notification for \(producer.farm_name) at \(Int(distanceKm))km")
                }
            }
            
        } catch {
            print("❌ Error checking nearby tours: \(error)")
        }
    }
    
    // MARK: - Notification Scheduling
    
    /// Schedule a notification based on trigger type
    private func scheduleNotification(trigger: NotificationTrigger, delaySeconds: TimeInterval) async {
        let content = UNMutableNotificationContent()
        
        // Extract producerId and farmName for all trigger types
        var producerId: UUID?
        var farmName: String?
        
        switch trigger {
        case .newMatchingProducer(let id, let name, let state, let process, let score):
            producerId = id
            farmName = name
            content.title = "Nuevo Productor Compatible 🌟"
            content.body = "\(name) en \(state) con proceso \(process) que te encanta (\(Int(score))% compatible)"
            content.sound = .default
            content.badge = 1
            
        case .harvestAlert(let id, let name, let daysUntil, let score):
            producerId = id
            farmName = name
            content.title = "Próxima Cosecha ☕️"
            content.body = "La cosecha de \(name) (\(Int(score))% compatible) estará lista en \(daysUntil) días"
            content.sound = .default
            
        case .nearbyTourAvailable(let id, let name, let distance):
            producerId = id
            farmName = name
            content.title = "Tour de Cafetal Cercano 🗺️"
            content.body = "\(name) ofrece tours de cafetales a solo \(Int(distance))km de ti"
            content.sound = .default
            
        case .conversationUpdate(let id, let name, let messageCount):
            producerId = id
            farmName = name
            content.title = "Nuevos Mensajes 💬"
            content.body = "\(messageCount) nuevos mensajes de \(name)"
            content.sound = .default
            content.badge = NSNumber(value: messageCount)
        }
        
        content.categoryIdentifier = trigger.category
        
        // Add producer ID and farm name to userInfo for deep linking
        if let producerId = producerId {
            var userInfoDict: [String: Any] = [
                "producerId": producerId.uuidString,
                "category": trigger.category
            ]
            if let farmName = farmName {
                userInfoDict["farmName"] = farmName
            }
            content.userInfo = userInfoDict
        }
        
        // Time-based trigger with delay
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: trigger.identifier,
            content: content,
            trigger: timeTrigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled notification: \(trigger.identifier)")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }
    
    // MARK: - Notification Management
    
    /// Remove all pending notifications
    func removeAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("🗑️ Removed all pending notifications")
    }
    
    /// Remove notifications of a specific type
    func removeNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Removed \(identifiers.count) notifications")
    }
    
    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }
}

// MARK: - CLLocationManagerDelegate

extension SmartNotificationService: CLLocationManagerDelegate {
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            locationPermissionGranted = status == .authorizedWhenInUse || status == .authorizedAlways
            print("📍 Location permission status: \(status.rawValue)")
        }
    }
}
