//
//  ProducerDashboardView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerDashboardView: View {

    let currentUserId: UUID
    
    @EnvironmentObject var store: ProducerStore
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var messagingService: MessagingService
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        _messagingService = StateObject(wrappedValue: MessagingService(currentUserId: currentUserId))
    }

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Text("Dashboard")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppColors.textLight)

                Text("Hola, \(store.businessName)")
                    .font(.title3)
                    .foregroundColor(AppColors.textLight)

                dashboardCard(title: "Productos publicados", value: "\(store.products.count)")
                
                ProducerChatPreviewCard(currentUserId: currentUserId)
                    .environmentObject(theme)
                
                Spacer()
                    .frame(height: 80)
            }
            .padding(22)
        }
        .background(AppColors.backgroundLight)
    }

    func dashboardCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textLight)
            Text(value)
                .font(.title.bold())
                .foregroundColor(AppColors.textLight)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardLight)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
