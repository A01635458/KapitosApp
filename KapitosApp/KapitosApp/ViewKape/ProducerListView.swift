//
//  ProducerListView.swift
//  KapitosApp
//  List of pending producer applications
//

import SwiftUI

struct ProducerListView: View {
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var approvalService = ProducerApprovalService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if approvalService.isLoading && approvalService.pendingProducers.isEmpty {
                ProgressView("Cargando solicitudes...")
                    .padding()
            } else if approvalService.pendingProducers.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(approvalService.pendingProducers) { producer in
                            NavigationLink(destination: ProducerApprovalView(producer: producer).environmentObject(theme)) {
                                producerCard(producer)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Solicitudes Pendientes")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await approvalService.fetchPendingProducers()
        }
        .refreshable {
            await approvalService.fetchPendingProducers()
        }
    }
    
    // MARK: - Producer Card
    private func producerCard(_ producer: Producer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(producer.displayName)
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    
                    if !producer.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(producer.location)
                                .font(.subheadline)
                        }
                        .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            }
            
            // Details
            HStack(spacing: 20) {
                if let years = producer.experience_years {
                    detailChip(icon: "clock.fill", text: "\(years) años")
                }
                if let altitude = producer.altitude {
                    detailChip(icon: "mountain.2.fill", text: "\(altitude)m")
                }
                if let size = producer.farm_size_ha {
                    detailChip(icon: "leaf.fill", text: String(format: "%.1f ha", size))
                }
            }
            
            // Varieties
            if let varieties = producer.varieties, !varieties.isEmpty {
                Text("Variedades: \\(varieties.joined(separator: \", \"))")
                    .font(.caption)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
    
    private func detailChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.isDarkMode ? AppColors.accentDark.opacity(0.2) : AppColors.accentLight.opacity(0.2))
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            
            Text("No hay solicitudes pendientes")
                .font(.title3.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            Text("Todas las solicitudes han sido revisadas")
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ProducerListView().environmentObject(AppThemeManager())
    }
}
