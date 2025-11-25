//
//  RequestDetailView.swift
//  KapitosApp
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct RequestDetailView: View {
    @EnvironmentObject var theme: AppThemeManager
    let producer: Producer

    @State private var goToApproval = false

    var body: some View {
        VStack(spacing: 20) {

            Text(producer.displayName)
                .font(.largeTitle.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("Revisa los datos completos y decide si aceptar o rechazar.")
                .font(.callout)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            Button {
                goToApproval = true
            } label: {
                Text("Aprobar productor")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 26)

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $goToApproval) {
            ProducerApprovalView(producer: producer)
                .environmentObject(theme)
        }
    }
}

#Preview {
    RequestDetailView(producer: Producer(
        id: UUID(),
        farm_name: "Finca San José",
        experience_years: nil,
        phone: nil,
        photo_url: nil,
        farm_size_ha: nil,
        country: nil,
        state: nil,
        municipality: nil,
        shade_type: nil,
        annual_production_kg: nil,
        last_harvest_date: nil,
        yield_per_ha: nil,
        price_per_kg: nil,
        current_buyers: nil,
        min_contract_volume: nil,
        open_to_export: nil,
        sells_online: nil,
        online_store_url: nil,
        needs: nil,
        has_tourist_area: nil,
        tourist_accessible: nil,
        tourism_details: nil,
        consent_gps: nil,
        consent_ai: nil,
        consent_notifications: nil,
        varieties: nil,
        processes: nil,
        certifications: nil,
        altitude: nil,
        coffee_type: nil,
        status: "pending",
        created_at: Date()
    ))
    .environmentObject(AppThemeManager())
}
