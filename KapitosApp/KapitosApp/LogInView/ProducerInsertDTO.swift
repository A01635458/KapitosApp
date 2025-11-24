//
//  ProducerInsertDTO.swift
//  KapitosApp
//
//  Created by Leobardo Navarro Márquez on 24/11/25.
//


import Foundation

struct ProducerInsertDTO: Codable {
    let id: UUID?              // matches table (uuid) & allows default generation
    let farm_name: String
    let experience_years: Int?
    let phone: String
    let photo_url: String?
    let farm_size_ha: Double?
    let country: String?
    let state: String?
    let municipality: String?
    let shade_type: String?
    let annual_production_kg: Int?
    let last_harvest_date: String? // formatted "YYYY-MM-DD" for Postgres date
    let yield_per_ha: Double?
    let price_per_kg: Double?
    let current_buyers: String?
    let min_contract_volume: Int?
    let open_to_export: Bool?
    let sells_online: Bool?
    let online_store_url: String?
    let needs: String?
    let has_tourist_area: Bool?
    let tourist_accessible: Bool?
    let tourism_details: String?
    let varieties: [String]
    let processes: [String]
    let certifications: [String]
}
