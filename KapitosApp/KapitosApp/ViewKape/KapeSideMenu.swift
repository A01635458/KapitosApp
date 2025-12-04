//
//  KapeSideMenu.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI
import Combine 

struct KapeSideMenu: View {

    @Binding var currentPage: KapePage
    @Binding var showMenu: Bool
    @EnvironmentObject var theme: AppThemeManager
    
    @State private var goToLogin = false  // <- para mostrar LoginView()

    var body: some View {
        ZStack(alignment: .leading) {
            
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

                // -------- LOG OUT BUTTON --------
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
                    .padding(.vertical, 10)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
            .frame(width: 260, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
            .shadow(color: .black.opacity(0.3), radius: 12, x: 5, y: 0)
            
            
            // -------- FULLSCREEN LOGINVIEW --------
            NavigationLink("", destination: LoginView(), isActive: $goToLogin)
                .opacity(0)
        }
    }

    func menuButton(_ title: String, icon: String, page: KapePage) -> some View {
        Button {
            withAnimation(.smooth) {
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
