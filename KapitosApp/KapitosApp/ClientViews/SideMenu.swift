//
//  SideMenu.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI

struct SideMenu: View {
    @Binding var currentScreen: AppScreen
    @Binding var showMenu: Bool
    @EnvironmentObject var theme: AppThemeManager

    @State private var goToLogin = false   // navegación a LoginView

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {

            menuButton(title: "Home", icon: "house", screen: .home)
            menuButton(title: "Mapa", icon: "map", screen: .map)
            menuButton(title: "Perfil", icon: "person.crop.circle", screen: .profile)

            Toggle("Dark Mode", isOn: $theme.isDarkMode)
                .toggleStyle(SwitchToggleStyle(tint: AppColors.accentLight))

            Spacer()

            // ----------- CERRAR SESIÓN -----------
            Button {
                withAnimation(.smooth) {
                    goToLogin = true
                    showMenu = false
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.headline)

                    Text("Cerrar sesión")
                        .font(.headline)
                }
                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 24)
        }
        .padding(.top, 70)
        .padding(.horizontal, 20)
        .frame(width: 260, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .shadow(color: .black.opacity(0.3), radius: 12, x: 5, y: 0)
        .overlay(
            NavigationLink(destination: LoginView(), isActive: $goToLogin) {
                EmptyView()
            }
            .hidden()
        )
    }

    // BUTTON REUSABLE
    func menuButton(title: String, icon: String, screen: AppScreen) -> some View {
        Button {
            withAnimation(.smooth) {

                if currentScreen == screen {
                    showMenu = false
                    return
                }

                currentScreen = screen
                showMenu = false
            }
        } label: {
            Label(title, systemImage: icon)
                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                .padding(.vertical, 4)
        }
    }
}

#Preview {
    SideMenu(
        currentScreen: .constant(.home),
        showMenu: .constant(true)
    )
    .environmentObject(AppThemeManager())
}
