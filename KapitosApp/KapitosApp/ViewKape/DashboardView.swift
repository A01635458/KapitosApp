//
//  DashboardView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct DashboardView: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var approvalService = ProducerApprovalService.shared
    @StateObject private var adminService = AdminDataService.shared
    
    @State private var pendingCount = 0
    @State private var approvedCount = 0
    @State private var userCount = 0
    @State private var producerCount = 0
    @State private var adminCount = 0

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
                    NavigationLink(destination: ProducerListView().environmentObject(theme)) {
                        dashboardCard(
                            title: "Solicitudes pendientes",
                            value: "\(pendingCount)",
                            icon: "tray.full.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: ProducersListView().environmentObject(theme)) {
                        dashboardCard(
                            title: "Productores aprobados",
                            value: "\(producerCount)",
                            icon: "leaf.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: ClientsListView().environmentObject(theme)) {
                        dashboardCard(
                            title: "Clientes registrados",
                            value: "\(userCount)",
                            icon: "person.3.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: AccountGeneratorView().environmentObject(theme)) {
                        dashboardCard(
                            title: "Crear cuenta manual",
                            value: "\(adminCount)",
                            icon: "person.badge.plus"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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
        .task {
            await loadDashboardData()
        }
    }
    
    // MARK: - Data Loading
    private func loadDashboardData() async {
        let producerCounts = await approvalService.getProducerCounts()
        pendingCount = producerCounts.pending
        approvedCount = producerCounts.approved
        
        let userCounts = await adminService.getUserCountsByRole()
        userCount = userCounts.users
        producerCount = userCounts.producers
        adminCount = userCounts.admins
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
