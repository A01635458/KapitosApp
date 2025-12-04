//
//  ProducerMapService.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 04/12/25.
//

import SwiftUI
import Supabase
import CoreLocation
import Combine 

/// Model for producer data from database
struct ProducerMapData: Identifiable, Codable {
    let id: UUID
    let farm_name: String
    let latitude: Double?
    let longitude: Double?
    let municipality: String?
    let state: String?
    let photo_url: String?
    let varieties: [String]?
    let processes: [String]?
    let certifications: [String]?
    let has_tourist_area: Bool?
    let tourist_accessible: Bool?
    let status: String?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var displayName: String {
        farm_name
    }
    
    var locationDescription: String {
        var parts: [String] = []
        if let municipality = municipality {
            parts.append(municipality)
        }
        if let state = state {
            parts.append(state)
        }
        return parts.isEmpty ? "México" : parts.joined(separator: ", ")
    }
}

@MainActor
class ProducerMapService: ObservableObject {
    
    @Published var producers: [ProducerMapData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    /// Fetch all approved producers with location data
    func fetchProducers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [ProducerMapData] = try await supabase
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .not("latitude", operator: .is, value: "null")
                .not("longitude", operator: .is, value: "null")
                .execute()
                .value
            
            producers = response
            print("✅ Loaded \(producers.count) producers from database")
            
        } catch {
            errorMessage = "Error al cargar productores: \(error.localizedDescription)"
            print("❌ Error fetching producers: \(error)")
        }
        
        isLoading = false
    }
    
    /// Fetch producers within a specific region (for optimization)
    func fetchProducersInRegion(
        minLat: Double,
        maxLat: Double,
        minLon: Double,
        maxLon: Double
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [ProducerMapData] = try await supabase
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .gte("latitude", value: minLat)
                .lte("latitude", value: maxLat)
                .gte("longitude", value: minLon)
                .lte("longitude", value: maxLon)
                .execute()
                .value
            
            producers = response
            print("✅ Loaded \(producers.count) producers in region")
            
        } catch {
            errorMessage = "Error al cargar productores: \(error.localizedDescription)"
            print("❌ Error fetching producers in region: \(error)")
        }
        
        isLoading = false
    }
    
    /// Fetch producers by state
    func fetchProducersByState(_ state: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [ProducerMapData] = try await supabase
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .eq("state", value: state)
                .not("latitude", operator: .is, value: "null")
                .not("longitude", operator: .is, value: "null")
                .execute()
                .value
            
            producers = response
            print("✅ Loaded \(producers.count) producers from \(state)")
            
        } catch {
            errorMessage = "Error al cargar productores: \(error.localizedDescription)"
            print("❌ Error fetching producers by state: \(error)")
        }
        
        isLoading = false
    }
}
