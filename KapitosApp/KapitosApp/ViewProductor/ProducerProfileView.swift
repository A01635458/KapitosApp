//
//  ProducerProfileView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerProfileView: View {

    @EnvironmentObject var store: ProducerStore
    @EnvironmentObject var theme: AppThemeManager

    var body: some View {

        ScrollView {
            VStack(spacing: 22) {

                Spacer().frame(height: 40)

                // Foto de perfil del productor
                ZStack {
                    if let profileImage = store.logoImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight, lineWidth: 3)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    } else {
                        ZStack {
                            Circle()
                                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(theme.isDarkMode ? AppColors.accentDark.opacity(0.3) : AppColors.accentLight.opacity(0.3), lineWidth: 3)
                                )
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50))
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    }
                }

                Text(store.businessName)
                    .font(.title.bold())
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                if !store.address.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        Text(store.address)
                            .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : .gray)
                    }
                }
                
                if !store.phone.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        Text(store.phone)
                            .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : .gray)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
    }
}
