//
//  ClientsListView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct ClientsListView: View {

    @EnvironmentObject var theme: AppThemeManager

    var clients = ["Andrea M.", "Carlos P.", "María L.", "Luis C."]

    var body: some View {
        List {
            ForEach(clients, id: \.self) { c in
                Text(c)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Clientes")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
    }
}
