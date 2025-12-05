//
//  ProductDetailView.swift
//  KapitosApp
//
//  Vista de solo lectura para ver detalles de productos (para clientes)
//

import SwiftUI

struct ProductDetailView: View {
    
    let product: ProducerProduct
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Imagen del producto
                    productImage
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Información básica
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.name)
                                .font(.title.bold())
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                            
                            HStack {
                                Text("$\(product.price, specifier: "%.0f")")
                                    .font(.title2.bold())
                                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                
                                Text("·")
                                    .foregroundColor(.gray)
                                
                                Text(product.weight)
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                        
                        // MARK: - Descripción
                        if let description = product.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Descripción", systemImage: "text.alignleft")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            }
                            
                            Divider()
                        }
                        
                        // MARK: - Notas de cata
                        if let tastingNotes = product.tastingNotes, !tastingNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Notas de cata", systemImage: "nose.fill")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(tastingNotes, id: \.self) { note in
                                        Text(note)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(theme.isDarkMode ? AppColors.accentDark.opacity(0.3) : AppColors.accentLight.opacity(0.2))
                                            .foregroundColor(theme.isDarkMode ? .white : AppColors.accentLight)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                        
                        // MARK: - Métodos de preparación
                        if let brewingMethods = product.brewingMethods, !brewingMethods.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Métodos de preparación", systemImage: "cup.and.saucer.fill")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(brewingMethods, id: \.self) { method in
                                        Text(method)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                            .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                        
                        // MARK: - Categoría
                        if let category = product.category {
                            HStack {
                                Label("Categoría", systemImage: "tag.fill")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                Spacer()
                                
                                Text(category)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // MARK: - Nivel de tueste
                        if let roastLevel = product.roastLevel {
                            HStack {
                                Label("Nivel de tueste", systemImage: "flame.fill")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                Spacer()
                                
                                Text(roastLevel)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // MARK: - Tipo de empaque
                        if let packagingType = product.packagingType {
                            HStack {
                                Label("Empaque", systemImage: "shippingbox.fill")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                Spacer()
                                
                                Text(packagingType)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // MARK: - Campos adicionales
                        if let categoryFields = product.categoryFields, !categoryFields.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Información adicional", systemImage: "info.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                
                                ForEach(categoryFields.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    HStack {
                                        Text(key)
                                            .font(.body)
                                            .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                        
                                        Spacer()
                                        
                                        Text(value)
                                            .font(.body)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            .navigationTitle("Detalles del producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                }
            }
        }
    }
    
    // MARK: - Product Image
    
    private var productImage: some View {
        Group {
            if let imageUrl = product.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
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
                    .frame(height: 300)
                    .clipped()
            } else {
                placeholderImage()
            }
        }
    }
    
    private func placeholderImage() -> some View {
        ZStack {
            Rectangle()
                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .frame(height: 300)
            
            VStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("Sin imagen")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProductDetailView(
        product: ProducerProduct(
            id: UUID(),
            name: "Café Especial Chiapas",
            price: 250,
            weight: "250g",
            image: nil,
            imageUrl: nil,
            description: "Café de altura cultivado en las montañas de Chiapas. Proceso lavado con notas dulces y afrutadas.",
            tastingNotes: ["Chocolate", "Caramelo", "Frutas rojas"],
            brewingMethods: ["Espresso", "Prensa francesa", "V60"],
            category: "Café en grano",
            roastLevel: "Medio",
            packagingType: "Bolsa con válvula"
        )
    )
    .environmentObject(AppThemeManager())
}
