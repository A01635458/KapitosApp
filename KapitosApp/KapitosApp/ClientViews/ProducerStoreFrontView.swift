//
//  ProducerStoreFrontView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI
import Combine 

struct ProducerStoreFrontView: View {

    @EnvironmentObject var theme: AppThemeManager
    let producer: MockProducer

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Image(producer.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding(.top, 30)

                Text(producer.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                Text(producer.bio)
                    .font(.body)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)

                    Text(producer.schedule)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
                .padding()

                Divider().padding(.horizontal)

                // Productos Hardcodeados
                VStack(alignment: .leading, spacing: 16) {
                    Text("Productos")
                        .font(.title2.bold())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                    productCard(name: "Café Lavado 500g", price: "$220 MXN")
                    productCard(name: "Café Natural 1kg", price: "$450 MXN")
                    productCard(name: "Blend Tradicional 250g", price: "$140 MXN")
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 40)
            }
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .ignoresSafeArea()
    }

    func productCard(name: String, price: String) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: "bag.fill")
                        .font(.title)
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                )

            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                Text(price)
                    .font(.subheadline)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.8))
            }

            Spacer()
        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .cornerRadius(16)
    }
}
