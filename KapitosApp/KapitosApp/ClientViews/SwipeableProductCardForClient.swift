//
//  SwipeableProductCardForClient.swift
//  KapitosApp
//
//  Tarjeta de producto con swipe para clientes
//

import SwiftUI

struct SwipeableProductCardForClient: View {
    let product: ProducerProduct
    let onTap: () -> Void
    let onSwipeToChat: () -> Void
    
    @EnvironmentObject var theme: AppThemeManager
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Botón de chat en el fondo
            HStack {
                Spacer()
                Button(action: {
                    // Haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    withAnimation(.spring()) {
                        onSwipeToChat()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            .frame(width: 80)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                            Text("Chat")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 88)
            
            // Tarjeta del producto
            ProductCardForClientContent(product: product)
                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .cornerRadius(14)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                offset = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring()) {
                                if gesture.translation.width < -50 {
                                    offset = -80
                                    isSwiped = true
                                } else {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    if isSwiped {
                        withAnimation(.spring()) {
                            offset = 0
                            isSwiped = false
                        }
                    } else {
                        onTap()
                    }
                }
        }
    }
}

// MARK: - Product Card Content

struct ProductCardForClientContent: View {
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
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
