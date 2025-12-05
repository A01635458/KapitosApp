//  Created by Luisa Cardona on 15/11/25.
//
//  HomeView.swift
//  KapitosApp
//

import SwiftUI
import Combine 

struct HomeView: View {

    @EnvironmentObject var theme: AppThemeManager
    let currentUserId: UUID
    
    @StateObject private var recommendationEngine = RecommendationEngine()
    @StateObject private var preferencesChecker = UserPreferencesChecker()
    @State private var selectedProducer: ProducerMapData?
    @State private var showRecommendationDetail: RecommendationScore?
    @State private var showCompletePreferences = false
    
    struct CoffeeType: Identifiable {
        let id = UUID()
        let nombre: String
        let origen: String
        let notas: String
        let tueste: String
    }
    
    private let cafes: [CoffeeType] = [
        CoffeeType(nombre: "Arábica", origen: "Etiopía, Brasil, Colombia", notas: "Suave, ácido delicado, notas frutales y florales", tueste: "Medio para resaltar complejidad"),
        CoffeeType(nombre: "Robusta", origen: "Vietnam, Uganda", notas: "Más cuerpo, amargor pronunciado, notas terrosas", tueste: "Medio-Oscuro para balancear amargor"),
        CoffeeType(nombre: "Liberica", origen: "Filipinas", notas: "Aromas exóticos, afrutado, ligeramente ahumado", tueste: "Medio"),
        CoffeeType(nombre: "Excelsa", origen: "Sudeste Asiático", notas: "Acidez brillante, notas frutales profundas", tueste: "Medio"),
        CoffeeType(nombre: "Geisha", origen: "Panamá", notas: "Flor de jazmín, cítricos, miel, muy aromático", tueste: "Ligero-Medio para preservar aromas"),
    ]

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- BANNER PARA COMPLETAR PREFERENCIAS ---
                if !preferencesChecker.isLoading && !preferencesChecker.hasPreferences {
                    Button {
                        showCompletePreferences = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .font(.system(size: 28))
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Completa tu Perfil de Gustos")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                Text("Obtén mejores recomendaciones personalizadas")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.isDarkMode ? AppColors.accentDark.opacity(0.5) : AppColors.accentLight.opacity(0.5), lineWidth: 2)
                                )
                        )
                        .shadow(radius: 2)
                    }
                    .padding(.top, 10)
                }

                // --- PREVIEW DE CHATS ---
                ChatPreviewCard(currentUserId: currentUserId)
                    .environmentObject(theme)
                    .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .padding(.top, 10)

                // --- RECOMENDACIONES PERSONALIZADAS ---
                if !recommendationEngine.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            
                            Text("Recomendados para Ti")
                                .font(.title2.bold())
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                            
                            Spacer()
                        }
                        
                        Text("Productores compatibles con tus preferencias")
                            .font(.subheadline)
                            .foregroundColor(
                                theme.isDarkMode
                                ? AppColors.textDark.opacity(0.8)
                                : AppColors.textLight.opacity(0.8)
                            )
                        
                        // Top 5 recommendations
                        ForEach(Array(recommendationEngine.recommendations.prefix(5))) { recommendation in
                            RecommendedProducerCard(recommendation: recommendation) {
                                selectedProducer = recommendation.producer
                            }
                            .environmentObject(theme)
                            .contextMenu {
                                Button {
                                    showRecommendationDetail = recommendation
                                } label: {
                                    Label("Ver detalles de compatibilidad", systemImage: "info.circle")
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                } else if recommendationEngine.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight))
                        
                        Text("Generando recomendaciones personalizadas...")
                            .font(.subheadline)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .task {
            // Load recommendations and check preferences on appear
            await preferencesChecker.checkUserPreferences(userId: currentUserId)
            await recommendationEngine.generateRecommendations(for: currentUserId, limit: 5)
        }
        .sheet(isPresented: $showCompletePreferences) {
            CompletePreferencesSheet(currentUserId: currentUserId)
                .environmentObject(theme)
        }
        .sheet(item: $showRecommendationDetail) { recommendation in
            RecommendationDetailView(recommendation: recommendation)
                .environmentObject(theme)
        }
        .sheet(item: $selectedProducer) { producer in
            ProducerDetailSheetView(producer: producer, currentUserId: currentUserId)
                .environmentObject(theme)
        }
    }
}
#Preview {
    // Preview con datos de prueba - solo para desarrollo
    if let testUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
        HomeView(currentUserId: testUserId)
            .environmentObject(AppThemeManager())
    }
}

