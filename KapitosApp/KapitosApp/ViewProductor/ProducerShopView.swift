//
//  ProducerShopView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerShopView: View {

    @EnvironmentObject var store: ProducerStore
    @EnvironmentObject var theme: AppThemeManager
    @State private var showAddOptions = false
    @State private var selectedProduct: ProducerProduct?
    @State private var showEditSheet = false

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                // -------------------------
                // ENCABEZADO
                // -------------------------

                HStack {
                    Text("Mis Productos")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppColors.textLight)

                    Spacer()
                }

                // -------------------------
                // BOTÓN AGREGAR PRODUCTO
                // -------------------------

                Button {
                    showAddOptions = true
                } label: {
                    HStack(spacing: 12) {

                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text("Agregar producto")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.accentLight)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                }
                .padding(.top, 4)

                // -------------------------
                // LISTA O ESTADO VACÍO
                // -------------------------

                if store.products.isEmpty {

                    VStack(spacing: 16) {

                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 52))
                            .foregroundColor(AppColors.accentLight)

                        Text("No hay productos aún")
                            .font(.title3.bold())
                            .foregroundColor(AppColors.textLight)

                        Text("Cuando agregues productos, aparecerán aquí automáticamente.")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textLight.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                } else {

                    LazyVStack(spacing: 16) {
                        ForEach(store.products) { product in
                            SwipeableProductCard(
                                product: product,
                                onTap: {
                                    selectedProduct = product
                                    showEditSheet = true
                                },
                                onDelete: {
                                    Task {
                                        await store.deleteProduct(product)
                                    }
                                }
                            )
                        }
                    }
                }

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
        .background(AppColors.backgroundLight)
        .sheet(isPresented: $showAddOptions) {
            AddProductModeSheet(showAddOptions: $showAddOptions)
                .presentationDetents([.height(320)])
                .environmentObject(store)
        }
        .sheet(isPresented: $showEditSheet) {
            if let product = selectedProduct {
                EditProductView(product: product)
                    .environmentObject(store)
                    .environmentObject(theme)
            }
        }
    }
}

// MARK: - Swipeable Product Card

struct SwipeableProductCard: View {
    let product: ProducerProduct
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Botón de eliminar en el fondo
            HStack {
                Spacer()
                Button(action: {
                    // Haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    withAnimation(.spring()) {
                        onDelete()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.red)
                            .frame(width: 80)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 88)
            
            // Tarjeta del producto
            ProductCardContent(product: product)
                .background(AppColors.cardLight)
                .cornerRadius(18)
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

struct ProductCardContent: View {
    let product: ProducerProduct
    
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
                    .foregroundColor(AppColors.textLight)
                
                Text("\(product.weight) · $\(product.price, specifier: "%.0f")")
                    .foregroundColor(AppColors.textLight.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textLight.opacity(0.5))
        }
        .padding()
        .background(AppColors.cardLight)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    func placeholderImage() -> some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(AppColors.cardLight.opacity(0.6))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(AppColors.textLight.opacity(0.5))
            )
    }
}
