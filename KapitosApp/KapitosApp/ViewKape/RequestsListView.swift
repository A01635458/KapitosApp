//
//  RequestsListView.swift
//  KapitosApp
//  Created by Luisa Cardona on 23/11/25.
//  NOTE: This view is deprecated. Use ProducerListView instead for real data.
//

import SwiftUI

struct RequestsListView: View {
    @EnvironmentObject var theme: AppThemeManager

    // Sample data - replace with ProducerListView for real functionality
    var sampleProducers = [
        Producer(id: UUID(), farm_name: "Finca La Esperanza", experience_years: nil, phone: nil, photo_url: nil, farm_size_ha: nil, country: nil, state: nil, municipality: nil, latitude: nil, longitude: nil, shade_coverage_percent: nil, annual_production_kg: nil, last_harvest_date: nil, yield_per_ha: nil, price_per_kg: nil, sales_types: nil, min_contract_volume: nil, open_to_export: nil, sells_online: nil, online_store_url: nil, has_tourist_area: nil, tourist_accessible: nil, tourism_details: nil, consent_gps: nil, consent_ai: nil, consent_notifications: nil, varieties: nil, processes: nil, certifications: nil, altitude: nil, status: "pending", created_at: Date()),
        Producer(id: UUID(), farm_name: "Café El Roble", experience_years: nil, phone: nil, photo_url: nil, farm_size_ha: nil, country: nil, state: nil, municipality: nil, latitude: nil, longitude: nil, shade_coverage_percent: nil, annual_production_kg: nil, last_harvest_date: nil, yield_per_ha: nil, price_per_kg: nil, sales_types: nil, min_contract_volume: nil, open_to_export: nil, sells_online: nil, online_store_url: nil, has_tourist_area: nil, tourist_accessible: nil, tourism_details: nil, consent_gps: nil, consent_ai: nil, consent_notifications: nil, varieties: nil, processes: nil, certifications: nil, altitude: nil, status: "pending", created_at: Date()),
        Producer(id: UUID(), farm_name: "Montaña Azul", experience_years: nil, phone: nil, photo_url: nil, farm_size_ha: nil, country: nil, state: nil, municipality: nil, latitude: nil, longitude: nil, shade_coverage_percent: nil, annual_production_kg: nil, last_harvest_date: nil, yield_per_ha: nil, price_per_kg: nil, sales_types: nil, min_contract_volume: nil, open_to_export: nil, sells_online: nil, online_store_url: nil, has_tourist_area: nil, tourist_accessible: nil, tourism_details: nil, consent_gps: nil, consent_ai: nil, consent_notifications: nil, varieties: nil, processes: nil, certifications: nil, altitude: nil, status: "pending", created_at: Date())
    ]

    var body: some View {
        List {
            ForEach(sampleProducers) { producer in
                NavigationLink {
                    RequestDetailView(producer: producer)
                        .environmentObject(theme)
                } label: {
                    Text(producer.displayName)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Solicitudes")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RequestsListView()
        .environmentObject(AppThemeManager())
}
