//
//  ProducersListView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct ProducersListView: View {

    @EnvironmentObject var theme: AppThemeManager

    var producers = ["Finca La Esperanza", "Café El Roble", "Montaña Azul"]

    var body: some View {
        List {
            ForEach(producers, id: \.self) { p in
                Text(p)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Productores")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
    }
}
