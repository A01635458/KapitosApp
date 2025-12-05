//
//  ProducerCustomerPreviewView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerCustomerPreviewView: View {

    @EnvironmentObject var store: ProducerStore

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                // Banner con logo del productor
                ZStack {
                    // Fondo del banner
                    LinearGradient(
                        colors: [AppColors.accentLight, AppColors.accentLight.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 210)
                    
                    // Logo del productor
                    if let profileImage = store.logoImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.accentLight.opacity(0.3), lineWidth: 4)
                                )
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.accentLight)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                }

                Text(store.businessName)
                    .font(.largeTitle.bold())

                Text("Productos")
                    .font(.title2.bold())
                    .padding(.top)

                ForEach(store.products) { product in
                    HStack {
                        // Imagen del producto
                        if let imageUrl = product.imageUrl {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                case .failure(_), .empty:
                                    placeholderProductImage()
                                @unknown default:
                                    placeholderProductImage()
                                }
                            }
                        } else if let imgData = product.image,
                                  let uiImg = UIImage(data: imgData) {
                            Image(uiImage: uiImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            placeholderProductImage()
                        }

                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text("\(product.weight) · $\(product.price, specifier: "%.0f")")
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 10)
                }

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
    }
    
    func placeholderProductImage() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.25))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray.opacity(0.5))
            )
    }
}
