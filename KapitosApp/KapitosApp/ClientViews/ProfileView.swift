//
//  ProfileView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 18/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var theme: AppThemeManager
    let currentUserId: UUID
    
    @State private var showNotificationPreferences = false

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
                
                // Notification Settings Button
                Button {
                    showNotificationPreferences = true
                } label: {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                        Text("Notificaciones Inteligentes")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                            .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                    )
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showNotificationPreferences) {
            NotificationPreferencesView(currentUserId: currentUserId)
                .environmentObject(theme)
        }
    }
}
