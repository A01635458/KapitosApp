//
//  ProducerProductCardView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 05/12/25.
//

import SwiftUI

struct ProducerProductCardView: View {
    let product: ProducerProduct
    
    @EnvironmentObject var theme: AppThemeManager
    
    var body: some View {
        HStack(spacing: 14) {
            // Imagen del producto
            if let imageUrl = product.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    case .failure(_), .empty:
                        placeholderImage()
                    @unknown default:
                        placeholderImage()
                    }
                }
            } else if let imgData = product.image,
                      let uiImg = UIImage(data: imgData) {
                Image(uiImage: uiImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                placeholderImage()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                
                Text("\(product.weight) · $\(product.price, specifier: "%.0f")")
                    .font(.subheadline)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
                
                if let description = product.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .cornerRadius(14)
    }
    
    func placeholderImage() -> some View {
        RoundedRectangle(cornerRadius: 14)
            .fill((theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight).opacity(0.6))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.5) : AppColors.textLight.opacity(0.5))
            )
    }
}
