//
//  ClientsListView.swift
//  KapitosApp
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct ClientsListView: View {
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var adminService = AdminDataService.shared

    var body: some View {
        VStack {
            if adminService.isLoading && adminService.allUsers.isEmpty {
                VStack {
                    ProgressView("Cargando usuarios...")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)  
                .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            } else if adminService.allUsers.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(adminService.allUsers) { user in
                        userRow(user)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Usuarios")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .task {
            await adminService.fetchAllUsers()
        }
        .refreshable {
            await adminService.fetchAllUsers()
        }
    }
    
    private func userRow(_ user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(user.full_name)
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            HStack(spacing: 12) {
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                
                Spacer()
                
                roleBadge(user.displayRole)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func roleBadge(_ role: String) -> some View {
        Text(role)
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(roleColor(role))
            )
    }
    
    private func roleColor(_ role: String) -> Color {
        switch role {
        case "Admin": return .purple
        case "Productor": return theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight
        case "Cliente": return .blue
        default: return .gray
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            
            Text("No hay usuarios registrados")
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
    }

}
