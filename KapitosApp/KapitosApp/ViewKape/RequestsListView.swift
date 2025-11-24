//
//  RequestsListView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct RequestsListView: View {

    @EnvironmentObject var theme: AppThemeManager

    var sampleRequests = [
        "Finca La Esperanza",
        "Café El Roble",
        "Montaña Azul",
        "Café San Marcos"
    ]

    var body: some View {
        List {
            ForEach(sampleRequests, id: \.self) { producer in
                NavigationLink {
                    RequestDetailView(producerName: producer)
                        .environmentObject(theme)
                } label: {
                    Text(producer)
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
