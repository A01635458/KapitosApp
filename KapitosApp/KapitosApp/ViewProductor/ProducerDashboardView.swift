//
//  ProducerDashboardView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerDashboardView: View {

    @EnvironmentObject var store: ProducerStore
    @EnvironmentObject var theme: AppThemeManager

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Text("Dashboard")
                    .font(.largeTitle.bold())

                Text("Hola, \(store.businessName)")
                    .font(.title3)

                dashboardCard(title: "Productos publicados", value: "\(store.products.count)")
                dashboardCard(title: "Clientes esta semana", value: "12")
                dashboardCard(title: "Calificación promedio", value: "4.8 ★")

                Spacer()
                    .frame(height: 80)
            }
            .padding(.horizontal, 22)
        }
    }

    func dashboardCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
    }
}
