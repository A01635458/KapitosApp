//
//  ProducersListView.swift
//  KapitosApp
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct ProducersListView: View {
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var adminService = AdminDataService.shared

    var body: some View {
        VStack {
            if adminService.isLoading && adminService.approvedProducers.isEmpty {
                ProgressView("Cargando productores...")
                    .padding()
            } else if adminService.approvedProducers.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(adminService.approvedProducers) { producer in
                        producerRow(producer)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Productores Aprobados")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await adminService.fetchApprovedProducers()
        }
        .refreshable {
            await adminService.fetchApprovedProducers()
        }
    }
    
    private func producerRow(_ producer: Producer) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(producer.displayName)
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            if !producer.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(producer.location)
                        .font(.caption)
                }
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
            }
            
            if let varieties = producer.varieties, !varieties.isEmpty {
                Text("Variedades: \(varieties.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 50))
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            
            Text("No hay productores aprobados")
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            Text("Los productores aparecerán aquí después de aprobar sus solicitudes")
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}


