//
//  DashboardView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct DashboardView: View {

    @EnvironmentObject var theme: AppThemeManager

    // padding inicial arriba
    private let topSpacing: CGFloat = 60

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {

              
                Color.clear.frame(height: topSpacing)
                Color.clear.frame(height: topSpacing)
                

                // ---- TÍTULO ----
                Text("Panel de Administración")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    .padding(.bottom, 10)

                // ---- SECTION OF CARDS ----
                VStack(spacing: 16) {
                    dashboardCard(
                        title: "Solicitudes pendientes",
                        value: "12",
                        icon: "tray.full.fill"
                    )

                    dashboardCard(
                        title: "Productores activos",
                        value: "54",
                        icon: "leaf.fill"
                    )

                    dashboardCard(
                        title: "Clientes registrados",
                        value: "210",
                        icon: "person.3.fill"
                    )

                    dashboardCard(
                        title: "Cuentas creadas hoy",
                        value: "7",
                        icon: "key.fill"
                    )
                }

                // ---- STATS ----
                dashboardStatsCard

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - CARD COMPONENT
    func dashboardCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))

                Text(value)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            }

            Spacer()

            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    // MARK: - STATS BLOCK
    var dashboardStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actividad de hoy")
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.9) : AppColors.textLight.opacity(0.9))

            RoundedRectangle(cornerRadius: 12)
                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .frame(height: 140)
                .overlay(
                    Text("Gráfica aquí")
                        .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.6))
                )

        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark.opacity(0.5) : AppColors.cardLight.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }
}

#Preview {
    DashboardView().environmentObject(AppThemeManager())
}
