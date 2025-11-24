//
//  KapeSideMenu.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//


import SwiftUI

struct KapeSideMenu: View {

    @Binding var currentPage: KapePage
    @Binding var showMenu: Bool
    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {

            Text("Kape Panel")
                .font(.largeTitle.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .padding(.top, 60)

            menuButton("Dashboard", icon: "house.fill", page: .dashboard)
            menuButton("Solicitudes", icon: "tray.full.fill", page: .requests)
            menuButton("Productores", icon: "leaf.fill", page: .producers)
            menuButton("Clientes", icon: "person.3.fill", page: .clients)
            menuButton("Crear cuentas", icon: "key.fill", page: .accounts)

            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(width: 260, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .shadow(color: .black.opacity(0.3), radius: 12, x: 5, y: 0)
    }

    func menuButton(_ title: String, icon: String, page: KapePage) -> some View {
        Button {
            withAnimation(.smooth) {

                // si ya está en esa pantalla, solo cierra el menú
                if currentPage == page {
                    showMenu = false
                    return
                }

                currentPage = page
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
    KapeSideMenu(currentPage: .constant(.dashboard), showMenu: .constant(true))
        .environmentObject(AppThemeManager())
}
