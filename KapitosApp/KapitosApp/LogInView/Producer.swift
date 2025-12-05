//
//  Producer.swift
//  KapitosApp
//
//  Created by Leobardo Navarro Márquez on 23/11/25.
//


import Foundation

struct Producer: Identifiable, Codable {
    let id: UUID
    let farm_name: String?
    let experience_years: Int?
    let phone: String?
    let photo_url: String?
    let farm_size_ha: Double?
    let country: String?
    let state: String?
    let municipality: String?
    let latitude: Double?
    let longitude: Double?
    let shade_coverage_percent: Int?
    let annual_production_kg: Int?
    let last_harvest_date: String?
    let yield_per_ha: Double?
    let price_per_kg: Double?
    let sales_types: [String]?
    let min_contract_volume: Int?
    let open_to_export: Bool?
    let sells_online: Bool?
    let online_store_url: String?
    let has_tourist_area: Bool?
    let tourist_accessible: Bool?
    let tourism_details: String?
    let consent_gps: Bool?
    let consent_ai: Bool?
    let consent_notifications: Bool?
    let varieties: [String]?
    let processes: [String]?
    let certifications: [String]?
    let altitude: Int?
    let status: String? // 'pending', 'approved', 'rejected'
    let created_at: Date?
    
    // Computed properties for UI
    var displayName: String {
        farm_name ?? "Productor sin nombre"
    }
    
    var location: String {
        [municipality, state, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
