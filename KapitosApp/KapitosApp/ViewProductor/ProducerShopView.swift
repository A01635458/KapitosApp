//
//  ProducerShopView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//
//
//  ProducerShopView.swift
//  KapitosApp
//
//
//  ProducerShopView.swift
//  KapitosApp
//

import SwiftUI

struct ProducerShopView: View {

    @EnvironmentObject var store: ProducerStore
    @State private var showAddOptions = false

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

                    VStack(spacing: 16) {
                        ForEach(store.products) { product in
                            productCard(product)
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
    }

    // -------------------------
    // TARJETA DE PRODUCTO
    // -------------------------

    func productCard(_ product: ProducerProduct) -> some View {
        HStack(spacing: 14) {

            if let imgData = product.image,
               let uiImg = UIImage(data: imgData) {

                Image(uiImage: uiImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

            } else {

                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.cardLight.opacity(0.6))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(AppColors.textLight.opacity(0.5))
                    )
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
}
