//
//  HomeView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        ZStack {
            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                .ignoresSafeArea()

            VStack {
                Text("Home screen")
                    .font(.title)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)

                Spacer()
            }
            .padding()
        }
    }
}
