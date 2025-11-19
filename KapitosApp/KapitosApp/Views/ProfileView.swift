//
//  ProfileView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 18/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        ZStack {
            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Circle()
                    .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    )

                Text("Tu Nombre")
                    .font(.title2)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)

                Spacer()
            }
            .padding()
        }
    }
}
