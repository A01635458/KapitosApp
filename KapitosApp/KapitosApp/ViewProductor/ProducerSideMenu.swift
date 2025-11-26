//
//  ProducerSideMenu.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerSideMenu: View {

    @Binding var current: ProducerScreen
    @Binding var showMenu: Bool
    @EnvironmentObject var theme: AppThemeManager
    @EnvironmentObject var store: ProducerStore

    @State private var goToLogin = false   // navegación LoginView()

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {

            Text("Panel Productor")
                .font(.largeTitle.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .padding(.top, 60)

            menuButton("Dashboard", icon: "house.fill", page: .dashboard)
            menuButton("Mi negocio", icon: "building.2.fill", page: .business)
            menuButton("Tienda", icon: "bag.fill", page: .shop)
            menuButton("Vista cliente", icon: "eye.fill", page: .customerPreview)
            menuButton("Perfil", icon: "person.crop.circle.fill", page: .profile)

            Spacer()

            // ----------- CERRAR SESIÓN -----------
            Button {
                withAnimation(.smooth) {
                    goToLogin = true
                    showMenu = false
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.headline)

                    Text("Cerrar sesión")
                        .font(.headline)
                }
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 24)
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

    func menuButton(_ title: String, icon: String, page: ProducerScreen) -> some View {
        Button {
            withAnimation(.smooth) {
                if current == page {
                    showMenu = false
                    return
                }
                current = page
                showMenu = false
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ProducerSideMenu(current: .constant(.dashboard), showMenu: .constant(true))
        .environmentObject(AppThemeManager())
        .environmentObject(ProducerStore())
}
