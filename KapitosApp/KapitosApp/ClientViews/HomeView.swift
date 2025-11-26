//
//  HomeView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var theme: AppThemeManager
    
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

        VStack(alignment: .leading, spacing: 20) {

            // --- TIPOS DE CAFÉ ---
            VStack(alignment: .leading, spacing: 12) {

                Text("Tipos de Café")
                    .font(.title2.bold())
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)

                Text("Conoce las variedades más comunes y sus características para aprender a identificarlas.")
                    .font(.subheadline)
                    .foregroundColor(
                        theme.isDarkMode
                        ? AppColors.textDark.opacity(0.8)
                        : AppColors.textLight.opacity(0.8)
                    )

                ForEach(cafes) { cafe in
                    VStack(alignment: .leading, spacing: 6) {

                        Text(cafe.nombre)
                            .font(.headline)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)

                        Text("Origen: \(cafe.origen)")
                            .font(.caption)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))

                        Text("Notas: \(cafe.notas)")
                            .font(.caption)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))

                        Text("Nivel de tueste sugerido: \(cafe.tueste)")
                            .font(.caption2)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.6) : AppColors.textLight.opacity(0.6))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.isDarkMode ? AppColors.cardDark : Color.white.opacity(0.9))
                            .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

#Preview { HomeView().environmentObject(AppThemeManager()) }
