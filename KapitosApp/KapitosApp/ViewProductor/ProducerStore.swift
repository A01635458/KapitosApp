//
//  ProducerStore.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//
import SwiftUI
import Combine
import Supabase

@MainActor
class ProducerStore: ObservableObject {
    
    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    let currentUserId: UUID

    // --- BUSINESS INFO ---
    @Published var businessName: String = "Cargando..."
    @Published var phone: String = ""
    @Published var address: String = ""
    @Published var schedule: String = "Lun - Vie · 8am - 6pm"
    @Published var description: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var bannerImage: UIImage? = UIImage(named: "banner_mock")
    @Published var profileImage: UIImage? = UIImage(systemName: "leaf.fill")

    // --- PRODUCTS ---
    @Published var products: [ProducerProduct] = []

    // --- CUSTOMER VIEW PREVIEW ---
    var displayName: String { businessName }
    var displayAddress: String { address }
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        Task {
            await loadProducerData()
        }
    }
    
    func loadProducerData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Loading producer data for user: \(currentUserId.uuidString)")
            
            // Load producer info from database
            let response: [Producer] = try await client
                .from("producers")
                .select()
                .eq("id", value: currentUserId.uuidString)
                .execute()
                .value
            
            if let producer = response.first {
                print("✅ Producer found: \(producer.displayName)")
                
                // Update business info with real fields from database
                businessName = producer.farm_name ?? "Productor"
                phone = producer.phone ?? ""
                
                // Build address from location fields
                var locationParts: [String] = []
                if let municipality = producer.municipality {
                    locationParts.append(municipality)
                }
                if let state = producer.state {
                    locationParts.append(state)
                }
                address = locationParts.joined(separator: ", ")
                
                // Build description from available data
                var descParts: [String] = []
                if let type = producer.coffee_type {
                    descParts.append("Café \(type)")
                }
                if let altitude = producer.altitude {
                    descParts.append("cultivado a \(altitude)m de altura")
                }
                if let municipality = producer.municipality {
                    descParts.append("en \(municipality)")
                }
                description = descParts.isEmpty ? "Productor de café" : descParts.joined(separator: " ")
                
                print("📋 Producer data loaded successfully")
            } else {
                print("⚠️ No producer found for this user")
                errorMessage = "No se encontró información del productor"
                businessName = "Productor"
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading producer data: \(error)")
            errorMessage = "Error al cargar datos: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
